import 'package:pos_app/core/domain/app_user.dart';

/// Contrato de autenticación. La implementación vive en `data/`.
abstract interface class AuthRepository {
  /// Indica si hay tokens guardados de una sesión anterior.
  Future<bool> hasStoredSession();

  /// Inicia sesión y guarda el par de tokens. Lanza `Failure` si falla.
  Future<void> login({required String username, required String password});

  /// Usuario de la sesión (`auth/me/`): de aquí salen el rol y la sucursal.
  Future<AppUser> fetchCurrentUser();

  /// Borra los tokens del dispositivo. El backend no tiene endpoint de logout.
  Future<void> logout();
}
