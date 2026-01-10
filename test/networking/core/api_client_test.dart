import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moluccans_heritage_app/networking/core/api_client.dart';
import 'package:moluccans_heritage_app/networking/core/api_exception.dart' as api_exceptions;

import 'api_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late ApiClient apiClient;
  late MockClient mockHttpClient;
  const baseUrl = 'https://api.example.com';

  setUp(() {
    mockHttpClient = MockClient();
    apiClient = ApiClient(baseUrl: baseUrl, client: mockHttpClient);
  });

  tearDown(() {
    apiClient.dispose();
  });

  group('ApiClient - GET requests', () {
    test('successful GET request returns JSON data', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'data': 'test'}),
                200,
              ));

      final result = await apiClient.get('/test');

      expect(result, isA<Map<String, dynamic>>());
      expect(result['data'], 'test');
      verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('GET request with query parameters', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'page': 1}), 200));

      await apiClient.get('/test', queryParameters: {'page': 1, 'limit': 10});

      verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('handles 400 Bad Request', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Bad Request', 400));

      expect(
        () => apiClient.get('/error'),
        throwsA(isA<api_exceptions.ClientException>()),
      );
    });

    test('handles 404 Not Found', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => apiClient.get('/not-found'),
        throwsA(isA<api_exceptions.ClientException>()),
      );
    });

    test('handles 500 Server Error', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      expect(
        () => apiClient.get('/error'),
        throwsA(isA<api_exceptions.ServerException>()),
      );
    });

    test('handles parse exception for invalid JSON', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('invalid json{', 200));

      expect(
        () => apiClient.get('/invalid-json'),
        throwsA(isA<api_exceptions.ParseException>()),
      );
    });
  });

  group('ApiClient - POST requests', () {
    test('successful POST request', () async {
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode({'id': 1}), 201));

      final result = await apiClient.post('/test', body: {'key': 'value'});

      expect(result, isA<Map<String, dynamic>>());
      verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .called(1);
    });
  });

  group('ApiClient - PUT requests', () {
    test('successful PUT request', () async {
      when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode({'updated': true}), 200));

      final result = await apiClient.put('/test/1', body: {'key': 'value'});

      expect(result, isA<Map<String, dynamic>>());
      verify(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .called(1);
    });
  });

  group('ApiClient - DELETE requests', () {
    test('successful DELETE request', () async {
      when(mockHttpClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 204));

      final result = await apiClient.delete('/test/1');

      expect(result, isNull);
      verify(mockHttpClient.delete(any, headers: anyNamed('headers'))).called(1);
    });
  });
}
