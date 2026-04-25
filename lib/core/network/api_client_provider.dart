import 'package:flutter/foundation.dart';
import 'package:shopplus_api_client/shopplus_api_client.dart';

final ApiClient apiClient = ApiClient(
  baseUrl: 'https://api.shopplus.com',
  tokenProvider: _mockTokenProvider,
  enableLogging: kDebugMode,
);

Future<String?> _mockTokenProvider() async => 'mock_token_dev';
