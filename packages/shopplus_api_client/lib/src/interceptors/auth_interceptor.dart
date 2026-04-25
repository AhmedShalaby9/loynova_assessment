import '../models/api_request.dart';

typedef TokenProvider = Future<String?> Function();

class AuthInterceptor {
  final TokenProvider tokenProvider;

  const AuthInterceptor({required this.tokenProvider});

  Future<ApiRequest> apply(ApiRequest request) async {
    final token = await tokenProvider();
    if (token == null || token.isEmpty) return request;

    final headers = Map<String, String>.from(request.headers ?? {});
    headers['Authorization'] = 'Bearer $token';
    return request.copyWith(headers: headers);
  }
}
