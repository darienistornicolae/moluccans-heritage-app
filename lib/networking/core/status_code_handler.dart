import 'package:http/http.dart' as http;
import 'api_exception.dart' as api_exceptions;

typedef ExceptionFactory = api_exceptions.ApiException Function(String message, int? statusCode);

class StatusCodeHandler {
  static final Map<int, ExceptionFactory> _statusCodeMap = {
    400: (message, statusCode) => api_exceptions.ClientException(
      message: message,
      statusCode: statusCode,
    ),
    401: (message, statusCode) => api_exceptions.ClientException(
      message: message,
      statusCode: statusCode,
    ),
    403: (message, statusCode) => api_exceptions.ClientException(
      message: message,
      statusCode: statusCode,
    ),
    404: (message, statusCode) => api_exceptions.ClientException(
      message: message,
      statusCode: statusCode,
    ),
    408: (message, statusCode) => api_exceptions.TimeoutException(
      message: message,
    ),
    429: (message, statusCode) => api_exceptions.ClientException(
      message: message,
      statusCode: statusCode,
    ),
    500: (message, statusCode) => api_exceptions.ServerException(
      message: message,
      statusCode: statusCode,
    ),
    502: (message, statusCode) => api_exceptions.ServerException(
      message: message,
      statusCode: statusCode,
    ),
    503: (message, statusCode) => api_exceptions.ServerException(
      message: message,
      statusCode: statusCode,
    ),
    504: (message, statusCode) => api_exceptions.ServerException(
      message: message,
      statusCode: statusCode,
    ),
  };

  static final Map<int, String> _statusCodeMessages = {
    400: 'Bad Request',
    401: 'Unauthorized',
    403: 'Forbidden',
    404: 'Not Found',
    408: 'Request Timeout',
    429: 'Too Many Requests',
    500: 'Internal Server Error',
    502: 'Bad Gateway',
    503: 'Service Unavailable',
    504: 'Gateway Timeout',
  };

  static void handleErrorResponse(http.Response response) {
    final statusCode = response.statusCode;
    final factory = _statusCodeMap[statusCode];
    
    if (factory != null) {
      final message = _statusCodeMessages[statusCode] ?? response.reasonPhrase ?? 'Unknown error';
      throw factory(message, statusCode);
    }

    if (statusCode >= 400 && statusCode < 500) {
      throw api_exceptions.ClientException(
        message: 'Client error: ${response.reasonPhrase}',
        statusCode: statusCode,
      );
    }

    if (statusCode >= 500) {
      throw api_exceptions.ServerException(
        message: 'Server error: ${response.reasonPhrase}',
        statusCode: statusCode,
      );
    }

    throw api_exceptions.ApiException(
      message: 'Unexpected error: ${response.reasonPhrase}',
      statusCode: statusCode,
    );
  }
}
