import 'place_model.dart';

/// Model representing the paginated response from the places API
class PlacesResponse {
  final String context;
  final String id;
  final String type;
  final int totalItems;
  final List<PlaceModel> places;

  PlacesResponse({
    required this.context,
    required this.id,
    required this.type,
    required this.totalItems,
    required this.places,
  });

  /// Creates a PlacesResponse from JSON
  factory PlacesResponse.fromJson(Map<String, dynamic> json) {
    return PlacesResponse(
      context: json['@context'] as String,
      id: json['@id'] as String,
      type: json['@type'] as String,
      totalItems: json['totalItems'] as int,
      places: (json['member'] as List<dynamic>)
          .map((place) => PlaceModel.fromJson(place as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts PlacesResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      '@context': context,
      '@id': id,
      '@type': type,
      'totalItems': totalItems,
      'member': places.map((place) => place.toJson()).toList(),
    };
  }
}
