class ApiResponse<T> {
  final int statusCode;
  final T data;
  final Map<String, String> headers;

  const ApiResponse({
    required this.statusCode,
    required this.data,
    required this.headers,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
