import 'image_model.dart';
import 'audio_model.dart';

/// Model representing a place from the API
class PlaceModel {
  final String id;
  final String type;
  final int numericId;
  final String title;
  final String description;
  final String longitude;
  final String latitude;
  final List<ImageModel> images;
  final List<AudioModel> audios;

  PlaceModel({
    required this.id,
    required this.type,
    required this.numericId,
    required this.title,
    required this.description,
    required this.longitude,
    required this.latitude,
    required this.images,
    required this.audios,
  });

  /// Creates a PlaceModel from JSON
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['@id'] as String,
      type: json['@type'] as String,
      numericId: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      longitude: json['longitude'] as String,
      latitude: json['latitude'] as String,
      images: (json['images'] as List<dynamic>)
          .map((image) => ImageModel.fromJson(image as Map<String, dynamic>))
          .toList(),
      audios: (json['audios'] as List<dynamic>)
          .map((audio) => AudioModel.fromJson(audio as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts PlaceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '@id': id,
      '@type': type,
      'id': numericId,
      'title': title,
      'description': description,
      'longitude': longitude,
      'latitude': latitude,
      'images': images.map((image) => image.toJson()).toList(),
      'audios': audios.map((audio) => audio.toJson()).toList(),
    };
  }

  /// Gets the parsed longitude as double
  double get longitudeValue => double.tryParse(longitude) ?? 0.0;

  /// Gets the parsed latitude as double
  double get latitudeValue => double.tryParse(latitude) ?? 0.0;

  /// Checks if the place has images
  bool get hasImages => images.isNotEmpty;

  /// Checks if the place has audios
  bool get hasAudios => audios.isNotEmpty;
}
