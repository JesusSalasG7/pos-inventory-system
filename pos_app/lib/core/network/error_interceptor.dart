import 'dart:io';

import 'package:dio/dio.dart';

import 'package:pos_app/core/network/api_exception.dart';

/// Convierte cualquier fallo de Dio en un `ApiException`.
///
/// El backend responde todos los errores como `{code, detail, meta}`. Los
/// fallos de red (timeout, sin conexión, 5xx sin sobre) reciben códigos locales.
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor({this.onReachabilityChanged});

  /// Avisa si el servidor dejó de responder (`false`) o volvió a hacerlo (`true`).
  final void Function({required bool reachable})? onReachabilityChanged;

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    onReachabilityChanged?.call(reachable: true);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is ApiException) {
      handler.next(err);
      return;
    }
    final exception = toApiException(err);
    if (exception.type == ApiErrorType.noConnection || exception.type == ApiErrorType.timeout) {
      onReachabilityChanged?.call(reachable: false);
    } else if (err.response != null) {
      onReachabilityChanged?.call(reachable: true);
    }
    handler.next(err.copyWith(error: exception));
  }

  /// Traduce un `DioException` crudo. Público para poder probarlo aislado.
  static ApiException toApiException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(type: ApiErrorType.timeout, code: ApiException.timeoutCode);
      case DioExceptionType.connectionError:
        return const ApiException(
          type: ApiErrorType.noConnection,
          code: ApiException.noConnectionCode,
        );
      case DioExceptionType.cancel:
        return const ApiException(type: ApiErrorType.cancelled, code: ApiException.cancelledCode);
      case DioExceptionType.badResponse:
        return _fromResponse(err.response);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          return const ApiException(
            type: ApiErrorType.noConnection,
            code: ApiException.noConnectionCode,
          );
        }
        return ApiException(
          type: ApiErrorType.unknown,
          code: ApiException.unknownCode,
          detail: err.message,
        );
    }
  }

  static ApiException _fromResponse(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    if (data is Map && data['code'] is String) {
      final meta = data['meta'];
      return ApiException(
        type: ApiErrorType.api,
        code: data['code'] as String,
        detail: data['detail']?.toString(),
        statusCode: statusCode,
        meta: meta is Map ? Map<String, dynamic>.from(meta) : const {},
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return ApiException(
        type: ApiErrorType.server,
        code: ApiException.serverCode,
        statusCode: statusCode,
      );
    }
    return ApiException(
      type: ApiErrorType.unknown,
      code: ApiException.unknownCode,
      statusCode: statusCode,
    );
  }
}
