import '../../models/place_model.dart';
import '../services/places_api_service.dart';
import '../core/api_exception.dart';
import '../interfaces/places_repository_interface.dart';
import '../interfaces/places_api_service_interface.dart';

class PlacesRepository implements PlacesRepositoryInterface {
  final PlacesApiServiceInterface _apiService;

  PlacesRepository({PlacesApiServiceInterface? apiService})
      : _apiService = apiService ?? PlacesApiService();

  @override
  Future<List<PlaceModel>> fetchPlaces({int page = 1}) async {
    try {
      final response = await _apiService.getPlaces(page: page);
      return response.places;
    } on NetworkException catch (e) {
      // Handle network errors - could return cached data here
      throw PlacesRepositoryException(
        message: 'Network error: ${e.message}',
        cause: e,
      );
    } on TimeoutException catch (e) {
      throw PlacesRepositoryException(
        message: 'Request timeout: ${e.message}',
        cause: e,
      );
    } on ApiException catch (e) {
      throw PlacesRepositoryException(
        message: 'API error: ${e.message}',
        cause: e,
      );
    } catch (e) {
      throw PlacesRepositoryException(
        message: 'Unknown error: $e',
        cause: e,
      );
    }
  }

  @override
  Future<PlaceModel?> fetchPlaceById(int id) async {
    try {
      final response = await _apiService.getPlaceById(id);
      if (response == null) return null;
      return PlaceModel.fromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw PlacesRepositoryException(
        message: 'Failed to fetch place: ${e.message}',
        cause: e,
      );
    } catch (e) {
      throw PlacesRepositoryException(
        message: 'Unknown error: $e',
        cause: e,
      );
    }
  }

  @override
  String get baseUrl => _apiService.baseUrl;
}

/// Custom exception for repository-level errors
class PlacesRepositoryException implements Exception {
  final String message;
  final dynamic cause;

  PlacesRepositoryException({required this.message, this.cause});

  @override
  String toString() => 'PlacesRepositoryException: $message';
}
