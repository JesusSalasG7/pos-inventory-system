import 'package:dio/dio.dart';

import 'package:pos_app/core/errors/error_messages.dart';
import 'package:pos_app/core/network/api_exception.dart';

/// Error ya listo para la capa de presentación.
///
/// Los repositorios convierten cualquier fallo en un `Failure`: las pantallas
/// nunca ven tipos de Dio.
class Failure implements Exception {
  const Failure({
    required this.code,
    required this.message,
    this.type = ApiErrorType.unknown,
    this.statusCode,
    this.meta = const {},
  });

  factory Failure.from(Object error) {
    if (error is Failure) return error;
    final source = error is DioException ? error.error : error;
    if (source is ApiException) {
      return Failure(
        code: source.code,
        message: ErrorMessages.forException(source),
        type: source.type,
        statusCode: source.statusCode,
        meta: source.meta,
      );
    }
    return const Failure(code: ApiException.unknownCode, message: ErrorMessages.generic);
  }

  final String code;

  /// Mensaje en español para mostrar al usuario.
  final String message;
  final ApiErrorType type;
  final int? statusCode;

  /// Datos adicionales del backend (p. ej. el stock disponible por producto).
  final Map<String, dynamic> meta;

  bool get isOffline => type == ApiErrorType.noConnection || type == ApiErrorType.timeout;

  /// Ejecuta una llamada de datos y relanza cualquier error como `Failure`.
  static Future<T> guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (error) {
      throw Failure.from(error);
    }
  }

  @override
  String toString() => 'Failure($code, $message)';
}
