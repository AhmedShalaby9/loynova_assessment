import 'dart:async';

import '../exceptions/api_exception.dart';

class RetryHandler {
  final int maxRetries;
  final Duration initialDelay;

  const RetryHandler({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
  });

  Future<T> execute<T>(Future<T> Function() action) async {
    var attempt = 0;
    var delay = initialDelay;

    while (true) {
      try {
        return await action();
      } catch (error) {
        if (!_shouldRetry(error) || attempt >= maxRetries) {
          rethrow;
        }
        await Future.delayed(delay);
        attempt += 1;
        delay *= 2;
      }
    }
  }

  bool _shouldRetry(Object error) {
    if (error is ApiException) {
      if (error.code == 'NETWORK_ERROR' || error.code == 'TIMEOUT') {
        return true;
      }
      const retryable = {500, 502, 503, 504};
      return retryable.contains(error.statusCode);
    }
    return false;
  }
}
