import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/users/data/datasources/users_remote_datasource.dart';
import 'package:pos_app/features/users/domain/repositories/users_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'users_repository_impl.g.dart';

@Riverpod(keepAlive: true)
UsersRepository usersRepository(Ref ref) {
  return UsersRepositoryImpl(UsersRemoteDataSource(ref.watch(dioProvider)));
}

class UsersRepositoryImpl implements UsersRepository {
  const UsersRepositoryImpl(this._remote);

  final UsersRemoteDataSource _remote;

  @override
  Future<List<AppUser>> fetchUsers() {
    return Failure.guard(() async {
      final dtos = await Paginated.fetchAll((page) => _remote.fetchUsers(page: page));
      return [for (final dto in dtos) dto.toEntity()];
    });
  }

  @override
  Future<AppUser> createUser({
    required String username,
    required String password,
    required String fullName,
    required UserRole role,
    required String? assignedBranch,
  }) {
    return Failure.guard(() async {
      final dto = await _remote.createUser({
        'username': username.trim(),
        'password': password,
        'full_name': fullName.trim(),
        'role': role.apiValue,
        // Siempre se envía: `null` es "todas las tiendas".
        'assigned_branch': assignedBranch,
      });
      return dto.toEntity();
    });
  }

  @override
  Future<AppUser> updateUser(
    int userId, {
    required String fullName,
    required UserRole role,
    required String? assignedBranch,
    required bool isActive,
    String? password,
  }) {
    return Failure.guard(() async {
      final dto = await _remote.updateUser(userId, {
        'full_name': fullName.trim(),
        'role': role.apiValue,
        'assigned_branch': assignedBranch,
        'is_active': isActive,
        'password': ?password,
      });
      return dto.toEntity();
    });
  }
}
