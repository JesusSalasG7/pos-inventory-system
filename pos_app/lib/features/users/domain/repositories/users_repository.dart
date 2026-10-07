import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/enums.dart';

/// Contrato de administración de usuarios (solo MANAGER). Los usuarios no se
/// borran: se desactivan.
abstract interface class UsersRepository {
  /// Todos los usuarios, también los inactivos.
  Future<List<AppUser>> fetchUsers();

  /// Crea un usuario activo. `assignedBranch` nulo significa acceso a todas
  /// las tiendas, que el backend solo admite para un MANAGER.
  Future<AppUser> createUser({
    required String username,
    required String password,
    required String fullName,
    required UserRole role,
    required String? assignedBranch,
  });

  /// Actualiza un usuario. Con `password` le asigna una contraseña nueva.
  Future<AppUser> updateUser(
    int userId, {
    required String fullName,
    required UserRole role,
    required String? assignedBranch,
    required bool isActive,
    String? password,
  });
}
