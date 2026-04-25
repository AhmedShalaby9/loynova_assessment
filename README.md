# shopplus_wallet

A Flutter wallet app supporting iOS, Android, and Web.

## Packages

This repo contains a local Dart package under `packages/`:

- `packages/shopplus_api_client` — reusable HTTP client with interceptors, retry, and typed errors. Wired into the app via `lib/core/network/api_client_provider.dart`.

### Running the package tests separately

```
cd packages/shopplus_api_client && dart test
```

## App development

```
flutter pub get
flutter run
flutter test
```
