// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Usuario autenticado; `null` si no hay sesión.
///
/// El rol y la sucursal vienen de la cuenta (`auth/me/`), no se eligen en el login.

@ProviderFor(CurrentUser)
final currentUserProvider = CurrentUserProvider._();

/// Usuario autenticado; `null` si no hay sesión.
///
/// El rol y la sucursal vienen de la cuenta (`auth/me/`), no se eligen en el login.
final class CurrentUserProvider extends $NotifierProvider<CurrentUser, AppUser?> {
  /// Usuario autenticado; `null` si no hay sesión.
  ///
  /// El rol y la sucursal vienen de la cuenta (`auth/me/`), no se eligen en el login.
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  CurrentUser create() => CurrentUser();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUser? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AppUser?>(value));
  }
}

String _$currentUserHash() => r'e6de2a02fb0eeb22c314f834e0b428e0479f1710';

/// Usuario autenticado; `null` si no hay sesión.
///
/// El rol y la sucursal vienen de la cuenta (`auth/me/`), no se eligen en el login.

abstract class _$CurrentUser extends $Notifier<AppUser?> {
  AppUser? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppUser?, AppUser?>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<AppUser?, AppUser?>, AppUser?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
