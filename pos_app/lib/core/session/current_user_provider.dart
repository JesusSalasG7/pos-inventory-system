import 'package:pos_app/core/domain/app_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_provider.g.dart';

/// Usuario autenticado; `null` si no hay sesión.
///
/// El rol y la sucursal vienen de la cuenta (`auth/me/`), no se eligen en el login.
@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  @override
  AppUser? build() => null;

  void set(AppUser user) => state = user;

  void clear() => state = null;
}
