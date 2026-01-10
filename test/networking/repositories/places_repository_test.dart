import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moluccans_heritage_app/networking/repositories/places_repository.dart';
import 'package:moluccans_heritage_app/networking/interfaces/places_api_service_interface.dart';
import 'package:moluccans_heritage_app/networking/core/api_exception.dart';
import 'package:moluccans_heritage_app/models/place_model.dart';
import 'package:moluccans_heritage_app/models/places_response.dart';
import '../../helpers/mock_models.dart';

import 'places_repository_test.mocks.dart';

@GenerateMocks([PlacesApiServiceInterface])
void main() {
  late PlacesRepository placesRepository;
  late MockPlacesApiServiceInterface mockApiService;

  setUp(() {
    mockApiService = MockPlacesApiServiceInterface();
    placesRepository = PlacesRepository(apiService: mockApiService);
  });

  group('PlacesRepository', () {
    test('fetchPlaces returns list of PlaceModel successfully', () async {
      final mockResponse = MockModels.createMockPlacesResponse();
      
      when(mockApiService.getPlaces(page: 1))
          .thenAnswer((_) async => mockResponse);

      final result = await placesRepository.fetchPlaces(page: 1);

      expect(result, isA<List<PlaceModel>>());
      expect(result.length, 3);
      expect(result.first.title, 'Place 1');
      verify(mockApiService.getPlaces(page: 1)).called(1);
    });

    test('fetchPlaces handles NetworkException', () async {
      when(mockApiService.getPlaces(page: 1))
          .thenThrow(NetworkException());

      expect(
        () => placesRepository.fetchPlaces(page: 1),
        throwsA(isA<PlacesRepositoryException>()),
      );
    });

    test('fetchPlaces handles TimeoutException', () async {
      when(mockApiService.getPlaces(page: 1))
          .thenThrow(TimeoutException());

      expect(
        () => placesRepository.fetchPlaces(page: 1),
        throwsA(isA<PlacesRepositoryException>()),
      );
    });

    test('fetchPlaces handles ClientException', () async {
      when(mockApiService.getPlaces(page: 1))
          .thenThrow(ClientException(message: 'Not Found', statusCode: 404));

      expect(
        () => placesRepository.fetchPlaces(page: 1),
        throwsA(isA<PlacesRepositoryException>()),
      );
    });

    test('fetchPlaces handles ServerException', () async {
      when(mockApiService.getPlaces(page: 1))
          .thenThrow(ServerException(message: 'Server Error', statusCode: 500));

      expect(
        () => placesRepository.fetchPlaces(page: 1),
        throwsA(isA<PlacesRepositoryException>()),
      );
    });

    test('fetchPlaceById returns PlaceModel successfully', () async {
      final mockPlaceJson = MockModels.createMockPlaceJson(id: 1);
      
      when(mockApiService.getPlaceById(1))
          .thenAnswer((_) async => mockPlaceJson);

      final result = await placesRepository.fetchPlaceById(1);

      expect(result, isA<PlaceModel>());
      expect(result?.numericId, 1);
      expect(result?.title, 'Test Place');
      verify(mockApiService.getPlaceById(1)).called(1);
    });

    test('fetchPlaceById returns null when place not found', () async {
      when(mockApiService.getPlaceById(999))
          .thenAnswer((_) async => null);

      final result = await placesRepository.fetchPlaceById(999);

      expect(result, isNull);
      verify(mockApiService.getPlaceById(999)).called(1);
    });

    test('fetchPlaceById handles API exceptions', () async {
      when(mockApiService.getPlaceById(999))
          .thenThrow(ClientException(message: 'Not Found', statusCode: 404));

      expect(
        () => placesRepository.fetchPlaceById(999),
        throwsA(isA<PlacesRepositoryException>()),
      );
    });

    test('baseUrl returns correct URL from apiService', () {
      when(mockApiService.baseUrl).thenReturn('https://test.com');

      expect(placesRepository.baseUrl, 'https://test.com');
    });
  });
}
