import '../core/api_client.dart';
import '../../models/places_response.dart';
import '../core/api_exception.dart';
import '../interfaces/places_api_service_interface.dart';
import '../interfaces/api_client_interface.dart';

class PlacesApiService implements PlacesApiServiceInterface {
  final ApiClientInterface _apiClient;

  PlacesApiService({ApiClientInterface? apiClient})
      : _apiClient = apiClient ?? 
          ApiClient(baseUrl: 'https://wdbvg.yusufyildiz.nl');

  @override
  Future<PlacesResponse> getPlaces({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '/api/places',
        queryParameters: {'page': page},
      );

      return PlacesResponse.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse places response: $e');
    }
  }

  @override
  Future<dynamic> getPlaceById(int id) async {
    try {
      final response = await _apiClient.get('/api/places/$id');
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse place response: $e');
    }
  }

  @override
  String get baseUrl {
    final client = _apiClient;
    if (client is ApiClient) {
      return client.baseUrl;
    }
    return 'https://wdbvg.yusufyildiz.nl';
  }
}
