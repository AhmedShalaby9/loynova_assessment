import 'dart:developer' as developer;

import '../models/api_request.dart';
import '../models/api_response.dart';

class LoggingInterceptor {
  final bool enabled;

  const LoggingInterceptor({this.enabled = true});

  void logRequest(ApiRequest request, Uri url) {
    if (!enabled) return;
    final masked = _maskAuth(request.headers ?? const {});
    developer.log(
      '→ ${request.method} $url\nheaders: $masked',
      name: 'shopplus_api_client',
    );
  }

  void logResponse(ApiResponse<dynamic> response, Duration duration) {
    if (!enabled) return;
    developer.log(
      '← ${response.statusCode} (${duration.inMilliseconds}ms)',
      name: 'shopplus_api_client',
    );
  }

  void logError(Object error, StackTrace stackTrace) {
    if (!enabled) return;
    developer.log(
      '✖ ${error.runtimeType}: $error',
      name: 'shopplus_api_client',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Map<String, String> _maskAuth(Map<String, String> headers) {
    final copy = Map<String, String>.from(headers);
    if (copy.containsKey('Authorization')) {
      copy['Authorization'] = '***';
    }
    return copy;
  }
}
