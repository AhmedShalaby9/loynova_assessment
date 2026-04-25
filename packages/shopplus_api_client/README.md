# shopplus_api_client

A reusable HTTP client package for ShopPlus apps. Provides:

- `ApiClient` with `get` / `post` / `put` / `delete`
- `AuthInterceptor` for `Bearer` token injection via a `TokenProvider`
- `LoggingInterceptor` using `dart:developer` (masks `Authorization`)
- `RetryHandler` with exponential backoff for network and 5xx errors
- Typed `ApiException` hierarchy (`network`, `timeout`, `server`, `unauthorized`)

## Usage

```dart
import 'package:shopplus_api_client/shopplus_api_client.dart';

final client = ApiClient(
  baseUrl: 'https://api.shopplus.com',
  tokenProvider: () async => 'mock_token_dev',
  enableLogging: true,
);

final response = await client.get('/wallet/balance');
print(response.data);
```

## Running tests

```
cd packages/shopplus_api_client && dart test
```
