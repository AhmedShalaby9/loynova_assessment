import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../exceptions/api_exception.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../models/api_request.dart';
import '../models/api_response.dart';
import '../retry/retry_handler.dart';

class ApiClient {
  final String baseUrl;
  final Duration timeout;
  final http.Client _httpClient;
  final AuthInterceptor _authInterceptor;
  final LoggingInterceptor _loggingInterceptor;
  final RetryHandler _retryHandler;

  ApiClient({
    required this.baseUrl,
    required TokenProvider tokenProvider,
    this.timeout = const Duration(seconds: 30),
    bool enableLogging = true,
    http.Client? httpClient,
    RetryHandler? retryHandler,
  })  : _httpClient = httpClient ?? http.Client(),
        _authInterceptor = AuthInterceptor(tokenProvider: tokenProvider),
        _loggingInterceptor = LoggingInterceptor(enabled: enableLogging),
        _retryHandler = retryHandler ?? const RetryHandler();

  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? queryParams,
  }) {
    return _send(ApiRequest.get(path, queryParams: queryParams));
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _send(ApiRequest.post(path, body: body));
  }

  Future<ApiResponse<Map<String, dynamic>>> put(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _send(ApiRequest.put(path, body: body));
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(String path) {
    return _send(ApiRequest.delete(path));
  }

  void close() => _httpClient.close();

  Future<ApiResponse<Map<String, dynamic>>> _send(ApiRequest request) {
    return _retryHandler.execute(() => _executeOnce(request));
  }

  Future<ApiResponse<Map<String, dynamic>>> _executeOnce(
      ApiRequest request) async {
    final intercepted = await _authInterceptor.apply(request);
    final url = _buildUri(intercepted);
    _loggingInterceptor.logRequest(intercepted, url);

    final stopwatch = Stopwatch()..start();

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?intercepted.headers,
      };

      late http.Response response;
      switch (intercepted.method) {
        case 'GET':
          response =
              await _httpClient.get(url, headers: headers).timeout(timeout);
          break;
        case 'POST':
          response = await _httpClient
              .post(url,
                  headers: headers,
                  body: intercepted.body == null
                      ? null
                      : jsonEncode(intercepted.body))
              .timeout(timeout);
          break;
        case 'PUT':
          response = await _httpClient
              .put(url,
                  headers: headers,
                  body: intercepted.body == null
                      ? null
                      : jsonEncode(intercepted.body))
              .timeout(timeout);
          break;
        case 'DELETE':
          response =
              await _httpClient.delete(url, headers: headers).timeout(timeout);
          break;
        default:
          throw ApiException.server(
            0,
            'UNSUPPORTED_METHOD',
            'Unsupported method ${intercepted.method}',
          );
      }

      stopwatch.stop();
      final apiResponse = _toApiResponse(response);
      _loggingInterceptor.logResponse(apiResponse, stopwatch.elapsed);

      if (!apiResponse.isSuccess) {
        throw _mapErrorResponse(apiResponse);
      }
      return apiResponse;
    } on ApiException catch (error, stack) {
      _loggingInterceptor.logError(error, stack);
      rethrow;
    } on TimeoutException catch (error, stack) {
      _loggingInterceptor.logError(error, stack);
      throw ApiException.timeout();
    } on SocketException catch (error, stack) {
      _loggingInterceptor.logError(error, stack);
      throw ApiException.network(error.message, error);
    } on http.ClientException catch (error, stack) {
      _loggingInterceptor.logError(error, stack);
      throw ApiException.network(error.message, error);
    } catch (error, stack) {
      _loggingInterceptor.logError(error, stack);
      throw ApiException.network(error.toString(), error);
    }
  }

  Uri _buildUri(ApiRequest request) {
    final base = Uri.parse(baseUrl);
    final pathSegments = <String>[
      ...base.pathSegments,
      ...request.path.split('/').where((s) => s.isNotEmpty),
    ];
    return base.replace(
      pathSegments: pathSegments,
      queryParameters: request.queryParams,
    );
  }

  ApiResponse<Map<String, dynamic>> _toApiResponse(http.Response response) {
    Map<String, dynamic> data;
    if (response.body.isEmpty) {
      data = <String, dynamic>{};
    } else {
      try {
        final decoded = jsonDecode(response.body);
        data = decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{'data': decoded};
      } catch (_) {
        data = <String, dynamic>{'raw': response.body};
      }
    }

    return ApiResponse<Map<String, dynamic>>(
      statusCode: response.statusCode,
      data: data,
      headers: response.headers,
    );
  }

  ApiException _mapErrorResponse(ApiResponse<Map<String, dynamic>> response) {
    final code = (response.data['code'] ?? 'HTTP_${response.statusCode}')
        .toString();
    final message =
        (response.data['message'] ?? 'Request failed').toString();

    if (response.statusCode == 401) {
      return ApiException.unauthorized(message);
    }
    return ApiException.server(response.statusCode, code, message);
  }
}
