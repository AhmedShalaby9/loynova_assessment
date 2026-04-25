class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final Object? originalError;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.originalError,
  });

  factory ApiException.network(String message, [Object? originalError]) {
    return ApiException(
      statusCode: 0,
      code: 'NETWORK_ERROR',
      message: message,
      originalError: originalError,
    );
  }

  factory ApiException.timeout([String message = 'Request timed out']) {
    return ApiException(
      statusCode: 0,
      code: 'TIMEOUT',
      message: message,
    );
  }

  factory ApiException.server(int statusCode, String code, String message) {
    return ApiException(
      statusCode: statusCode,
      code: code,
      message: message,
    );
  }

  factory ApiException.unauthorized([String message = 'Unauthorized']) {
    return ApiException(
      statusCode: 401,
      code: 'UNAUTHORIZED',
      message: message,
    );
  }

  @override
  String toString() =>
      'ApiException($statusCode, $code): $message';
}
