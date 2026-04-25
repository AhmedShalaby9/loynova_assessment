import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shopplus_api_client/shopplus_api_client.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUri());
  });

  group('AuthInterceptor', () {
    test('injects Authorization header when token is provided', () async {
      final interceptor =
          AuthInterceptor(tokenProvider: () async => 'abc123');
      final result = await interceptor.apply(ApiRequest.get('/x'));
      expect(result.headers?['Authorization'], 'Bearer abc123');
    });

    test('skips Authorization when tokenProvider returns null', () async {
      final interceptor = AuthInterceptor(tokenProvider: () async => null);
      final result = await interceptor.apply(ApiRequest.get('/x'));
      expect(result.headers, anyOf(isNull, isNot(contains('Authorization'))));
    });
  });

  group('RetryHandler', () {
    test('returns result immediately on first success', () async {
      final handler = RetryHandler(
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 1),
      );
      var calls = 0;
      final result = await handler.execute(() async {
        calls += 1;
        return 'ok';
      });
      expect(result, 'ok');
      expect(calls, 1);
    });

    test('retries on network error up to maxRetries', () async {
      final handler = RetryHandler(
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 1),
      );
      var calls = 0;
      final result = await handler.execute(() async {
        calls += 1;
        if (calls < 3) {
          throw ApiException.network('boom');
        }
        return 'ok';
      });
      expect(result, 'ok');
      expect(calls, 3);
    });

    test('stops and throws after maxRetries exhausted', () async {
      final handler = RetryHandler(
        maxRetries: 2,
        initialDelay: const Duration(milliseconds: 1),
      );
      var calls = 0;
      await expectLater(
        handler.execute(() async {
          calls += 1;
          throw ApiException.network('boom');
        }),
        throwsA(isA<ApiException>()),
      );
      expect(calls, 3);
    });

    test('does not retry on 400', () async {
      final handler = RetryHandler(
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 1),
      );
      var calls = 0;
      await expectLater(
        handler.execute(() async {
          calls += 1;
          throw ApiException.server(400, 'BAD_REQUEST', 'bad');
        }),
        throwsA(isA<ApiException>()),
      );
      expect(calls, 1);
    });

    test('does not retry on 401', () async {
      final handler = RetryHandler(
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 1),
      );
      var calls = 0;
      await expectLater(
        handler.execute(() async {
          calls += 1;
          throw ApiException.unauthorized();
        }),
        throwsA(isA<ApiException>()),
      );
      expect(calls, 1);
    });

    test('retries on 500', () async {
      final handler = RetryHandler(
        maxRetries: 2,
        initialDelay: const Duration(milliseconds: 1),
      );
      var calls = 0;
      await expectLater(
        handler.execute(() async {
          calls += 1;
          throw ApiException.server(500, 'SERVER_ERROR', 'oops');
        }),
        throwsA(isA<ApiException>()),
      );
      expect(calls, 3);
    });
  });

  group('ApiClient', () {
    late _MockHttpClient mockHttp;
    late ApiClient client;

    setUp(() {
      mockHttp = _MockHttpClient();
      client = ApiClient(
        baseUrl: 'https://api.example.com',
        tokenProvider: () async => 'tkn',
        enableLogging: false,
        httpClient: mockHttp,
        retryHandler: const RetryHandler(
          maxRetries: 0,
          initialDelay: Duration(milliseconds: 1),
        ),
      );
    });

    test('get() returns ApiResponse with status and data', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'hello': 'world'}),
                200,
                headers: {'x-test': '1'},
              ));

      final response = await client.get('/ping');

      expect(response.statusCode, 200);
      expect(response.data['hello'], 'world');
      expect(response.isSuccess, isTrue);
    });

    test('post() sends body and auth header', () async {
      when(() => mockHttp.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{}', 200));

      await client.post('/items', body: {'name': 'shoe'});

      final captured = verify(() => mockHttp.post(
            any(),
            headers: captureAny(named: 'headers'),
            body: captureAny(named: 'body'),
          )).captured;

      final headers = captured[0] as Map<String, String>;
      final body = captured[1] as String;
      expect(headers['Authorization'], 'Bearer tkn');
      expect(headers['Content-Type'], 'application/json');
      expect(jsonDecode(body), {'name': 'shoe'});
    });

    test('throws unauthorized on 401', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{}', 401));

      await expectLater(
        client.get('/me'),
        throwsA(isA<ApiException>().having(
            (e) => e.code, 'code', 'UNAUTHORIZED')),
      );
    });

    test('throws server on 500', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'code': 'SERVER_ERROR', 'message': 'boom'}),
                500,
              ));

      await expectLater(
        client.get('/x'),
        throwsA(isA<ApiException>().having(
            (e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('throws network on SocketException-like ClientException', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenThrow(http.ClientException('connection refused'));

      await expectLater(
        client.get('/x'),
        throwsA(isA<ApiException>().having(
            (e) => e.code, 'code', 'NETWORK_ERROR')),
      );
    });
  });
}
