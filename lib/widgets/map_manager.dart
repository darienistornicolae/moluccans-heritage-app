import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../models/place_model.dart';
import '../models/route_model.dart';

class MapManager {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointManager;
  PolylineAnnotationManager? _routePolylineManager;
  List<PointAnnotation> _pointAnnotations = [];
  List<PlaceModel> _places = [];

  void setMapboxMap(MapboxMap map) {
    _mapboxMap = map;
  }

  Future<void> moveCamera(Position position, {double zoom = 15}) async {
    if (_mapboxMap == null) return;
    
    await _mapboxMap!.setCamera(CameraOptions(
      center: Point(coordinates: position),
      zoom: zoom,
    ));
  }

  Future<void> enableLocationComponent() async {
    if (_mapboxMap == null) return;
    
    await _mapboxMap!.location.updateSettings(LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
    ));
  }

  /// Add markers from backend PlaceModel data
  Future<void> addPlaceMarkers(
    List<PlaceModel> places,
    Function(PlaceModel) onPlaceClick,
  ) async {
    if (_mapboxMap == null) return;

    try {
      _places = places;
      _pointManager = await _mapboxMap!.annotations.createPointAnnotationManager();

      // Create custom marker
      final markerBytes = await _createCustomMarkerBitmap(Colors.red);
      await _addMarkerImage(markerBytes);

      // Add markers for each place from backend
      for (var place in places) {
        final annotation = await _pointManager!.create(
          PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(
                place.longitudeValue,
                place.latitudeValue,
              ),
            ),
            iconImage: "custom-marker",
            iconSize: 1.0,
            iconAnchor: IconAnchor.BOTTOM,
          ),
        );
        _pointAnnotations.add(annotation);
      }

      // Add click listener
      _pointManager!.addOnPointAnnotationClickListener(
        _PointAnnotationClickListener(
          onAnnotationClick: (annotation) {
            final index = _pointAnnotations.indexOf(annotation);
            if (index != -1 && index < _places.length) {
              onPlaceClick(_places[index]);
            }
          },
        ),
      );

      print('✅ Added ${places.length} place markers to map');
    } catch (e) {
      print("❌ Error adding markers: $e");
    }
  }

  Future<void> drawRoute(RouteModel routeData) async {
    if (_mapboxMap == null) return;

    try {
      await clearRoute();

      _routePolylineManager = await _mapboxMap!.annotations.createPolylineAnnotationManager();

      final coordinates = routeData.coordinates
          .map((coord) => Position(coord.longitude, coord.latitude))
          .toList();

      await _routePolylineManager!.create(PolylineAnnotationOptions(
        geometry: LineString(coordinates: coordinates),
        lineColor: Colors.blue.value,
        lineWidth: 6.0,
      ));

      _fitCameraToRoute(coordinates);
    } catch (e) {
      print("❌ Error drawing route: $e");
    }
  }

  Future<void> clearRoute() async {
    if (_routePolylineManager != null && _mapboxMap != null) {
      await _mapboxMap!.annotations.removeAnnotationManager(_routePolylineManager!);
      _routePolylineManager = null;
    }
  }

  void _fitCameraToRoute(List<Position> coordinates) {
    if (coordinates.isEmpty || _mapboxMap == null) return;

    double minLat = coordinates[0].lat.toDouble();
    double maxLat = coordinates[0].lat.toDouble();
    double minLng = coordinates[0].lng.toDouble();
    double maxLng = coordinates[0].lng.toDouble();

    for (var coord in coordinates) {
      if (coord.lat < minLat) minLat = coord.lat.toDouble();
      if (coord.lat > maxLat) maxLat = coord.lat.toDouble();
      if (coord.lng < minLng) minLng = coord.lng.toDouble();
      if (coord.lng > maxLng) maxLng = coord.lng.toDouble();
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    _mapboxMap!.setCamera(CameraOptions(
      center: Point(coordinates: Position(centerLng, centerLat)),
      zoom: 14,
    ));
  }

  Future<Uint8List> _createCustomMarkerBitmap(Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const size = 50.0;
    const pinWidth = 40.0;
    const pinHeight = 50.0;

    canvas.drawCircle(
      const Offset(size / 2, pinWidth / 2),
      pinWidth / 2,
      paint,
    );
    canvas.drawCircle(
      const Offset(size / 2, pinWidth / 2),
      pinWidth / 2,
      strokePaint,
    );

    final path = Path();
    path.moveTo(size / 2 - pinWidth / 2 + 5, pinWidth / 2 + 10);
    path.lineTo(size / 2, pinHeight);
    path.lineTo(size / 2 + pinWidth / 2 - 5, pinWidth / 2 + 10);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);

    canvas.drawCircle(
      const Offset(size / 2, pinWidth / 2),
      8,
      Paint()..color = Colors.white,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), pinHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _addMarkerImage(Uint8List markerBytes) async {
    final marker = MbxImage(width: 50, height: 50, data: markerBytes);
    await _mapboxMap!.style.addStyleImage(
      "custom-marker",
      1.0,
      marker,
      false,
      [],
      [],
      null,
    );
  }
}

class _PointAnnotationClickListener extends OnPointAnnotationClickListener {
  final Function(PointAnnotation) onAnnotationClick;

  _PointAnnotationClickListener({required this.onAnnotationClick});

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    onAnnotationClick(annotation);
  }
} // new map manager
