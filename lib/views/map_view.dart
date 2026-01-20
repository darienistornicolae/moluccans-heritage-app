import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../models/location_service.dart';
import '../models/mapbox_service.dart';
import '../models/marker_model.dart';
import '../models/route_model.dart';
import '../widgets/map_manager.dart';
import '../widgets/info_card.dart';
import '../widgets/direction_step.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapManager _mapManager = MapManager();
  final LocationService _locationService = LocationService();
  final MapboxService _mapboxService = MapboxService();

  geo.Position? _currentPosition;
  List<MarkerModel> _markers = [];
  RouteModel? _currentRouteData;
  MarkerModel? _currentDestination;
  
  bool _showMap = false;  // NEW: Controls whether to show map
  bool _isLoading = false;
  String _errorMessage = '';

  // This will be called when user taps the button
  Future<void> _loadMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔄 Starting location initialization...');
      final position = await _locationService.getCurrentLocation();
      
      if (position != null) {
        print('✅ Location received: ${position.latitude}, ${position.longitude}');
        setState(() {
          _currentPosition = position;
          _markers = _createMockMarkers(position);
          _isLoading = false;
          _showMap = true;  // Show the map
        });
      } else {
        print('❌ Location is null');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not get location. Please enable location services.';
        });
      }
    } catch (e) {
      print('❌ Error during initialization: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  List<MarkerModel> _createMockMarkers(geo.Position currentPos) {
    return [
      MarkerModel(
        id: 'marker1',
        title: 'Monument 1',
        description: 'First monument location',
        position: Position(currentPos.longitude, currentPos.latitude),
      ),
      MarkerModel(
        id: 'marker2',
        title: 'Monument 2',
        description: 'Second monument location',
        position: Position(
          currentPos.longitude + 0.001,
          currentPos.latitude + 0.001,
        ),
      ),
    ];
  }

  void _onMapCreated(MapboxMap map) async {
    print('🗺️ Map created callback triggered');
    _mapManager.setMapboxMap(map);
    if (_currentPosition != null) {
      try {
        final position = Position(_currentPosition!.longitude, _currentPosition!.latitude);
        print('📍 Moving camera to position: ${position.lng}, ${position.lat}');
        await _mapManager.moveCamera(position);
        await _mapManager.enableLocationComponent();
        await _mapManager.addMarkers(_markers, _onMarkerClick);
        print('✅ Map setup complete');
      } catch (e) {
        print('❌ Error setting up map: $e');
      }
    } else {
      print('⚠️ Current position is null in onMapCreated');
    }
  }

  void _onMarkerClick(MarkerModel marker) async {
    if (_currentPosition == null) return;

    final distance = _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      marker.position.lat.toDouble(),
      marker.position.lng.toDouble(),
    );

    _showLoadingDialog();

    final routeData = await _mapboxService.getRoute(
      _currentPosition!.longitude,
      _currentPosition!.latitude,
      marker.position.lng.toDouble(),
      marker.position.lat.toDouble(),
    );

    if (mounted) {
      Navigator.pop(context);

      if (routeData != null) {
        setState(() {
          _currentRouteData = routeData;
          _currentDestination = marker;
        });
        _showMarkerDetailsSheet(marker, distance, routeData);
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showMarkerDetailsSheet(
    MarkerModel marker,
    double distance,
    RouteModel routeData,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                _buildSheetHandle(),
                const SizedBox(height: 20),
                Text(
                  marker.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  marker.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InfoCard(
                        icon: Icons.straighten,
                        title: 'Distance',
                        value: _formatDistance(distance),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InfoCard(
                        icon: Icons.access_time,
                        title: 'Duration',
                        value: '${routeData.durationMinutes.toStringAsFixed(0)} min',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (routeData.steps.isNotEmpty) ...[
                  Text(
                    'Directions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...routeData.steps.asMap().entries.map((entry) {
                    return DirectionStep(
                      stepNumber: entry.key + 1,
                      instruction: entry.value.instruction,
                      distance: entry.value.formattedDistance,
                    );
                  }).toList(),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _startNavigation();
                  },
                  icon: const Icon(Icons.navigation),
                  label: const Text('Start Navigation'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _startNavigation() async {
    if (_currentRouteData != null) {
      await _mapManager.drawRoute(_currentRouteData!);
      _showNavigationSheet();
    }
  }

  void _showNavigationSheet() {
    if (_currentRouteData == null || _currentDestination == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSheetHandle(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Navigation',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentRouteData!.durationMinutes.toStringAsFixed(0)} min',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'To: ${_currentDestination!.title}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Divider(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: _currentRouteData!.steps.length,
                itemBuilder: (context, index) {
                  final step = _currentRouteData!.steps[index];
                  return DirectionStep(
                    stepNumber: index + 1,
                    instruction: step.instruction,
                    distance: step.formattedDistance,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _endNavigation();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('End Navigation'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      if (_currentPosition != null) {
                        final position = Position(
                          _currentPosition!.longitude,
                          _currentPosition!.latitude,
                        );
                        _mapManager.moveCamera(position);
                      }
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('My Location'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _endNavigation() async {
    await _mapManager.clearRoute();
    setState(() {
      _currentRouteData = null;
      _currentDestination = null;
    });
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    }
    return '${(distance / 1000).toStringAsFixed(2)} km';
  }

  @override
  Widget build(BuildContext context) {
    // Show the welcome screen with button if map hasn't been loaded yet
    if (!_showMap) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Map',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Explore locations on the map',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 40),
              
              // LOAD MAP BUTTON
              FilledButton.icon(
                onPressed: _isLoading ? null : _loadMap,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.map_outlined),
                label: Text(_isLoading ? 'Loading...' : 'Load Map'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              
              // Show error if any
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Show the actual map once loaded
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            styleUri: MapboxStyles.STANDARD,
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(0, 0)),
              zoom: 2,
            ),
            onMapCreated: _onMapCreated,
          ),
        ],
      ),
      floatingActionButton: _currentPosition != null
          ? FloatingActionButton(
              onPressed: () {
                final position = Position(
                  _currentPosition!.longitude,
                  _currentPosition!.latitude,
                );
                _mapManager.moveCamera(position);
              },
              child: const Icon(Icons.my_location),
            )
          : null,
    );
  }
}