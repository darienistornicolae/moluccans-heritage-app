/// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: $message (Status Code: $statusCode)';
    }
    return 'ApiException: $message';
  }
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'No internet connection'});
}

class TimeoutException extends ApiException {
  TimeoutException({super.message = 'Request timeout'});
}

class ServerException extends ApiException {
  ServerException({super.message = 'Server error', super.statusCode});
}

class ClientException extends ApiException {
  ClientException({super.message = 'Client error', super.statusCode});
}

class ParseException extends ApiException {
  ParseException({super.message = 'Failed to parse response'});
}
