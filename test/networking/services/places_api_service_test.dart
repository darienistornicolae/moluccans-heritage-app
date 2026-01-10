import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moluccans_heritage_app/networking/services/places_api_service.dart';
import 'package:moluccans_heritage_app/networking/core/api_client.dart';
import 'package:moluccans_heritage_app/networking/interfaces/api_client_interface.dart';
import 'package:moluccans_heritage_app/networking/core/api_exception.dart';
import 'package:moluccans_heritage_app/models/places_response.dart';
import '../../helpers/mock_models.dart';

import 'places_api_service_test.mocks.dart';

@GenerateMocks([ApiClientInterface])
void main() {
  late PlacesApiService placesApiService;
  late MockApiClientInterface mockApiClient;
  const baseUrl = 'https://wdbvg.yusufyildiz.nl';

  setUp(() {
    mockApiClient = MockApiClientInterface();
    placesApiService = PlacesApiService(apiClient: mockApiClient);
  });

  group('PlacesApiService', () {
    test('getPlaces returns PlacesResponse successfully', () async {
      final mockResponse = MockModels.createMockPlacesResponseJson();
      
      when(mockApiClient.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      final result = await placesApiService.getPlaces(page: 1);

      expect(result, isA<PlacesResponse>());
      expect(result.totalItems, 3);
      expect(result.places.length, 3);
      verify(mockApiClient.get('/api/places', queryParameters: {'page': 1})).called(1);
    });

    test('getPlaces handles API exceptions', () async {
      when(mockApiClient.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(ClientException(message: 'Not Found', statusCode: 404));

      expect(
        () => placesApiService.getPlaces(page: 1),
        throwsA(isA<ClientException>()),
      );
    });

    test('getPlaces handles parse exceptions', () async {
      when(mockApiClient.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => {'invalid': 'data'});

      expect(
        () => placesApiService.getPlaces(page: 1),
        throwsA(isA<ParseException>()),
      );
    });

    test('getPlaceById returns place data successfully', () async {
      final mockPlaceJson = MockModels.createMockPlaceJson(id: 1);
      
      when(mockApiClient.get(any))
          .thenAnswer((_) async => mockPlaceJson);

      final result = await placesApiService.getPlaceById(1);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 1);
      verify(mockApiClient.get('/api/places/1')).called(1);
    });

    test('getPlaceById handles API exceptions', () async {
      when(mockApiClient.get(any))
          .thenThrow(ClientException(message: 'Not Found', statusCode: 404));

      expect(
        () => placesApiService.getPlaceById(999),
        throwsA(isA<ClientException>()),
      );
    });

    test('baseUrl returns correct URL when ApiClient is provided', () {
      final service = PlacesApiService(
        apiClient: ApiClient(baseUrl: baseUrl),
      );

      expect(service.baseUrl, baseUrl);
    });

    test('baseUrl returns default URL when custom client is provided', () {
      expect(placesApiService.baseUrl, baseUrl);
    });
  });
}
