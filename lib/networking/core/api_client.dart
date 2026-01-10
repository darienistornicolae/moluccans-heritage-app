import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_exception.dart' as api_exceptions;
import 'status_code_handler.dart';
import '../interfaces/api_client_interface.dart';

class ApiClient implements ApiClientInterface {
  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  ApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(headers),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw api_exceptions.NetworkException();
    } on TimeoutException {
      throw api_exceptions.TimeoutException();
    } on http.ClientException catch (e) {
      throw api_exceptions.ApiException(message: 'Request failed: ${e.message}');
    }
  }

  @override
  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw api_exceptions.NetworkException();
    } on TimeoutException {
      throw api_exceptions.TimeoutException();
    } on http.ClientException catch (e) {
      throw api_exceptions.ApiException(message: 'Request failed: ${e.message}');
    }
  }

  @override
  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw api_exceptions.NetworkException();
    } on TimeoutException {
      throw api_exceptions.TimeoutException();
    } on http.ClientException catch (e) {
      throw api_exceptions.ApiException(message: 'Request failed: ${e.message}');
    }
  }

  @override
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client
          .delete(
            uri,
            headers: _buildHeaders(headers),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw api_exceptions.NetworkException();
    } on TimeoutException {
      throw api_exceptions.TimeoutException();
    } on http.ClientException catch (e) {
      throw api_exceptions.ApiException(message: 'Request failed: ${e.message}');
    }
  }

  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = '$baseUrl$path';
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return Uri.parse(url).replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    
    return Uri.parse(url);
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw api_exceptions.ParseException(message: 'Failed to parse JSON: $e');
      }
    }

    StatusCodeHandler.handleErrorResponse(response);
  }

  @override
  void dispose() {
    _client.close();
  }
}
