/// Origen de un fallo al hablar con el backend.
enum ApiErrorType {
  /// El backend respondió con su sobre `{code, detail, meta}`.
  api,
  timeout,
  noConnection,

  /// Respuesta 5xx sin sobre de error (el servidor falló de forma inesperada).
  server,
  cancelled,
  unknown,
}

/// Error de red o de negocio, ya normalizado por `ErrorInterceptor`.
class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.code,
    this.detail,
    this.statusCode,
    this.meta = const {},
  });

  static const String timeoutCode = 'timeout';
  static const String noConnectionCode = 'no_connection';
  static const String serverCode = 'server_error';
  static const String cancelledCode = 'cancelled';
  static const String unknownCode = 'unknown_error';

  final ApiErrorType type;

  /// Código estable del backend (`insufficient_stock`…) o uno local de red.
  final String code;

  /// Mensaje del backend, ya en español. Puede faltar en errores de red.
  final String? detail;
  final int? statusCode;
  final Map<String, dynamic> meta;

  @override
  String toString() => 'ApiException($code, $statusCode, $detail)';
}
