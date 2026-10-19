import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers every Dio request with the last [respond] and remembers the requests.
class FakeHttpAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  late ResponseBody _response;

  RequestOptions? get lastRequest => requests.lastOrNull;

  void respond(int status, Object json, {String contentType = Headers.jsonContentType}) =>
      _response = ResponseBody.fromString(
        jsonEncode(json),
        status,
        headers: {
          Headers.contentTypeHeader: [contentType],
        },
      );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _response;
  }

  @override
  void close({bool force = false}) {}
}
