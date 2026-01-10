import '../../models/place_model.dart';

abstract class PlacesRepositoryInterface {
  Future<List<PlaceModel>> fetchPlaces({int page = 1});
  Future<PlaceModel?> fetchPlaceById(int id);
  String get baseUrl;
}
