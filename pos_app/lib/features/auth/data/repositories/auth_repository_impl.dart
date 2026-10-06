import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/core/storage/token_storage.dart';
import 'package:pos_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pos_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_impl.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    AuthRemoteDataSource(ref.watch(dioProvider)),
    ref.watch(tokenStorageProvider),
  );
}

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<bool> hasStoredSession() async => await _tokenStorage.readRefresh() != null;

  @override
  Future<void> login({required String username, required String password}) {
    return Failure.guard(() async {
      final tokens = await _remote.login(username: username.trim(), password: password);
      await _tokenStorage.save(access: tokens.access, refresh: tokens.refresh);
    });
  }

  @override
  Future<AppUser> fetchCurrentUser() {
    return Failure.guard(() async => (await _remote.fetchCurrentUser()).toEntity());
  }

  @override
  Future<void> logout() => _tokenStorage.clear();
}
