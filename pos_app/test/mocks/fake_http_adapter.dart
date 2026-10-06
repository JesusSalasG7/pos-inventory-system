import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Respuesta simulada del backend.
class FakeResponse {
  const FakeResponse(this.statusCode, [this.body = const <String, dynamic>{}]);

  final int statusCode;
  final Object body;
}

/// Adaptador HTTP en memoria para probar interceptores sin red.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);

  final FutureOr<FakeResponse> Function(RequestOptions options) handler;

  /// Peticiones recibidas, en orden.
  final List<RequestOptions> requests = [];

  int countFor(String pathSuffix) =>
      requests.where((request) => request.path.endsWith(pathSuffix)).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final response = await handler(options);
    return ResponseBody.fromString(
      jsonEncode(response.body),
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
