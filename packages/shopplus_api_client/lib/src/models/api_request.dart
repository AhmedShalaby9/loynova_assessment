class ApiRequest {
  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final Map<String, String>? queryParams;
  final Map<String, String>? headers;

  const ApiRequest({
    required this.method,
    required this.path,
    this.body,
    this.queryParams,
    this.headers,
  });

  factory ApiRequest.get(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) =>
      ApiRequest(
        method: 'GET',
        path: path,
        queryParams: queryParams,
        headers: headers,
      );

  factory ApiRequest.post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) =>
      ApiRequest(
        method: 'POST',
        path: path,
        body: body,
        queryParams: queryParams,
        headers: headers,
      );

  factory ApiRequest.put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) =>
      ApiRequest(
        method: 'PUT',
        path: path,
        body: body,
        queryParams: queryParams,
        headers: headers,
      );

  factory ApiRequest.delete(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) =>
      ApiRequest(
        method: 'DELETE',
        path: path,
        queryParams: queryParams,
        headers: headers,
      );

  ApiRequest copyWith({
    Map<String, String>? headers,
  }) =>
      ApiRequest(
        method: method,
        path: path,
        body: body,
        queryParams: queryParams,
        headers: headers ?? this.headers,
      );
}
