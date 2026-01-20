import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MarkerModel {
  final String id;
  final String title;
  final String description;
  final Position position;

  MarkerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
  });
}