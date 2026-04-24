class WalletException implements Exception {
  final String code;
  final String message;

  const WalletException(this.code, this.message);

  @override
  String toString() => 'WalletException($code): $message';
}
