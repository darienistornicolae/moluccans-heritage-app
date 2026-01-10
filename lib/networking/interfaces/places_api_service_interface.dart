import '../../models/places_response.dart';

abstract class PlacesApiServiceInterface {
  Future<PlacesResponse> getPlaces({int page = 1});
  Future<dynamic> getPlaceById(int id);
  String get baseUrl;
}
