import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;

  final String? statusCode;

  @override
  String toString() => message;
}

class SessionExpiredException extends ApiException {
  const SessionExpiredException() : super('Deine Anmeldung ist abgelaufen. Bitte melde dich erneut an.');
}

/// The backend wraps every response in a serialized `ResponseEntity`, errors too.
Object? unwrapEnvelope(Object? data) {
  if (data is! Map<String, dynamic> || !data.containsKey('statusCode')) {
    throw const ApiException('Unerwartete Antwort vom Server.');
  }
  final statusCode = data['statusCode']?.toString();
  if (statusCode != 'OK') {
    throw ApiException('Ein Fehler ist aufgetreten: ${data['body'] ?? statusCode}', statusCode: statusCode);
  }
  return data['body'];
}

class ApiClient {
  ApiClient({required Uri baseUrl, required Future<String?> Function() accessToken, Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl.toString()
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 20);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await accessToken();
            if (token != null) options.headers['Authorization'] = 'Bearer $token';
            handler.next(options);
          } on Exception catch (e) {
            handler.reject(DioException(requestOptions: options, error: e));
          }
        },
      ),
    );
  }

  final Dio _dio;

  Future<Object?> get(String path, {Map<String, Object?>? query}) =>
      _send(() => _dio.get<Object?>(path, queryParameters: query));

  Future<Object?> post(String path, Object? body) => _send(() => _dio.post<Object?>(path, data: body));

  Future<Object?> put(String path, Object? body) => _send(() => _dio.put<Object?>(path, data: body));

  Future<Object?> delete(String path) => _send(() => _dio.delete<Object?>(path));

  Future<Object?> _send(Future<Response<Object?>> Function() request) async {
    try {
      final response = await request();
      return unwrapEnvelope(response.data);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final cause = e.error;
    if (cause is ApiException) return cause;
    if (e.response?.statusCode == 401) return const SessionExpiredException();
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['body'] is String) {
      return ApiException(data['body'] as String, statusCode: data['statusCode']?.toString());
    }
    return switch (e.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => const ApiException(
        'Keine Verbindung zum Server. Bitte prüfe deine Internetverbindung.',
      ),
      _ => ApiException('Ein Fehler ist aufgetreten (${e.response?.statusCode ?? e.type.name}).'),
    };
  }
}
