import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/features/users/data/repositories/users_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'users_provider.g.dart';

/// Usuarios del negocio, también los inactivos, por nombre. Solo un MANAGER
/// puede consultarlos y modificarlos.
@riverpod
class Users extends _$Users {
  @override
  Future<List<AppUser>> build() async {
    final users = await ref.watch(usersRepositoryProvider).fetchUsers();
    return users..sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
  }

  /// Crea un usuario. Lanza `Failure`.
  Future<AppUser> create({
    required String username,
    required String password,
    required String fullName,
    required UserRole role,
    required String? assignedBranch,
  }) async {
    final user = await ref
        .read(usersRepositoryProvider)
        .createUser(
          username: username,
          password: password,
          fullName: fullName,
          role: role,
          assignedBranch: assignedBranch,
        );
    ref.invalidateSelf();
    return user;
  }

  /// Actualiza un usuario; con `password` le cambia la contraseña. Lanza `Failure`.
  Future<AppUser> save(
    int userId, {
    required String fullName,
    required UserRole role,
    required String? assignedBranch,
    required bool isActive,
    String? password,
  }) async {
    final user = await ref
        .read(usersRepositoryProvider)
        .updateUser(
          userId,
          fullName: fullName,
          role: role,
          assignedBranch: assignedBranch,
          isActive: isActive,
          password: password,
        );
    // Si el gerente se editó a sí mismo, la sesión refleja el cambio de nombre.
    if (ref.read(currentUserProvider)?.id == user.id) {
      ref.read(currentUserProvider.notifier).set(user);
    }
    ref.invalidateSelf();
    return user;
  }
}
