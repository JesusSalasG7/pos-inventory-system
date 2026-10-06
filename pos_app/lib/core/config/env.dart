/// Configuración inyectada en tiempo de compilación con `--dart-define`.
abstract final class Env {
  /// URL base del backend, sin `/api/v1`. Con `adb reverse` es `http://localhost:8000`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Prefijo de todas las rutas de la API.
  static const String apiPrefix = '/api/v1/';
}
