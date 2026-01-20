import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../viewmodels/places_viewmodel.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late PlacesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PlacesViewModel();
    _viewModel.fetchPlaces();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Kamp Wyldemerk'),
          border: const Border(
            bottom: BorderSide(
              color: CupertinoColors.separator,
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: ChangeNotifierProvider.value(
          value: _viewModel,
          child: Consumer<PlacesViewModel>(
            builder: (context, viewModel, child) {
              return _buildBody(context, viewModel);
            },
          ),
        ),
      );
    }

    return Scaffold(
      body: ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<PlacesViewModel>(
          builder: (context, viewModel, child) {
            return _buildBody(context, viewModel);
          },
        ),
      ),
    );
  }
}

extension on _MapViewState {
  Widget _buildBody(BuildContext context, PlacesViewModel viewModel) {
    if (viewModel.isLoading && viewModel.places.isEmpty) {
      return _buildLoadingState(context);
    }

    if (viewModel.hasError && viewModel.places.isEmpty) {
      return _buildErrorState(context, viewModel);
    }

    if (viewModel.places.isEmpty) {
      return _buildEmptyState(context);
    }

    final markerData = _buildMarkerData(viewModel.places);
    if (markerData.isEmpty) {
      return _buildNoCoordinatesState(context);
    }

    final initialCenter = _selectInitialCenter(markerData);

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 12,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.moluccans_heritage_app',
          tileProvider: kIsWeb ? NetworkTileProvider() : null,
        ),
        MarkerLayer(
          markers: markerData.map((data) {
            return Marker(
              point: data.location,
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () => _showPlaceDetails(
                  context,
                  data.place,
                  viewModel.baseUrl,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 36,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!kIsWeb && Platform.isIOS)
            const CupertinoActivityIndicator(radius: 16)
          else
            const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text('Loading locations...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, PlacesViewModel viewModel) {
    final isCupertino = !kIsWeb && Platform.isIOS;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              viewModel.errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          if (isCupertino)
            CupertinoButton.filled(
              onPressed: () => viewModel.refresh(),
              child: const Text('Retry'),
            )
          else
            ElevatedButton.icon(
              onPressed: () => viewModel.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No places found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNoCoordinatesState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No coordinates available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Places are missing map coordinates',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  List<_PlaceMarkerData> _buildMarkerData(List<PlaceModel> places) {
    final markers = <_PlaceMarkerData>[];
    for (final place in places) {
      final location = _parseLocation(place);
      if (location == null) continue;
      markers.add(_PlaceMarkerData(place: place, location: location));
    }
    return markers;
  }

  LatLng? _parseLocation(PlaceModel place) {
    final latitude = double.tryParse(place.latitude);
    final longitude = double.tryParse(place.longitude);
    if (latitude == null || longitude == null) return null;
    if (!latitude.isFinite || !longitude.isFinite) return null;
    if (latitude.abs() > 90 || longitude.abs() > 180) return null;
    return LatLng(latitude, longitude);
  }

  LatLng _selectInitialCenter(List<_PlaceMarkerData> markers) {
    final featured = _findFeaturedMarker(markers);
    if (featured != null) {
      return featured.location;
    }

    if (markers.length == 1) {
      return markers.first.location;
    }

    var latitudeSum = 0.0;
    var longitudeSum = 0.0;
    for (final marker in markers) {
      latitudeSum += marker.location.latitude;
      longitudeSum += marker.location.longitude;
    }
    return LatLng(
      latitudeSum / markers.length,
      longitudeSum / markers.length,
    );
  }

  _PlaceMarkerData? _findFeaturedMarker(List<_PlaceMarkerData> markers) {
    for (final marker in markers) {
      if (_isKampWyldemerk(marker.place)) {
        return marker;
      }
    }
    return null;
  }

  bool _isKampWyldemerk(PlaceModel place) {
    final title = place.title.trim().toLowerCase();
    return title == 'kamp wyldemerk' || title.contains('kamp wyldemerk');
  }

  void _showPlaceDetails(
    BuildContext context,
    PlaceModel place,
    String baseUrl,
  ) {
    if (!kIsWeb && Platform.isIOS) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (context) {
          return CupertinoPopupSurface(
            isSurfacePainted: true,
            child: SafeArea(
              top: false,
              child: PlaceDetailsSheet(
                place: place,
                baseUrl: baseUrl,
                isCupertino: true,
              ),
            ),
          );
        },
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: PlaceDetailsSheet(
            place: place,
            baseUrl: baseUrl,
            isCupertino: false,
          ),
        );
      },
    );
  }
}

class PlaceDetailsSheet extends StatelessWidget {
  final PlaceModel place;
  final String baseUrl;
  final bool isCupertino;

  const PlaceDetailsSheet({
    super.key,
    required this.place,
    required this.baseUrl,
    required this.isCupertino,
  });

  @override
  Widget build(BuildContext context) {
    final description = place.description.isEmpty
        ? 'No description available.'
        : place.description;
    final latitude = place.latitude.trim();
    final longitude = place.longitude.trim();
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    final sheetWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(isCupertino: isCupertino),
            const SizedBox(height: 12),
            Text(
              place.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _PlaceImages(
              place: place,
              baseUrl: baseUrl,
              itemWidth: sheetWidth - 40,
            ),
            if (place.hasImages) const SizedBox(height: 12),
            Text(
              description,
              style: textStyle,
            ),
            const SizedBox(height: 12),
            _CoordinatesRow(
              latitude: latitude,
              longitude: longitude,
            ),
            if (isCupertino) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  final bool isCupertino;

  const _SheetHandle({required this.isCupertino});

  @override
  Widget build(BuildContext context) {
    final handleColor = isCupertino
        ? CupertinoColors.systemGrey3
        : Theme.of(context).colorScheme.outlineVariant;
    return Center(
      child: Container(
        width: 48,
        height: 4,
        decoration: BoxDecoration(
          color: handleColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _CoordinatesRow extends StatelessWidget {
  final String latitude;
  final String longitude;

  const _CoordinatesRow({
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    final valueStyle = Theme.of(context).textTheme.bodyMedium;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.place_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text('Coordinates', style: labelStyle),
          const Spacer(),
          Text('$latitude, $longitude', style: valueStyle),
        ],
      ),
    );
  }
}

class _PlaceImages extends StatelessWidget {
  final PlaceModel place;
  final String baseUrl;
  final double itemWidth;

  const _PlaceImages({
    required this.place,
    required this.baseUrl,
    required this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (!place.hasImages) {
      return const SizedBox.shrink();
    }

    final width = itemWidth.clamp(260, 520).toDouble();

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: place.images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final image = place.images[index];
          final imageUrl = image.getFullUrl(baseUrl);
          return SizedBox(
            width: width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                webHtmlElementStrategy: kIsWeb
                    ? WebHtmlElementStrategy.prefer
                    : WebHtmlElementStrategy.never,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlaceMarkerData {
  final PlaceModel place;
  final LatLng location;

  const _PlaceMarkerData({required this.place, required this.location});
}

