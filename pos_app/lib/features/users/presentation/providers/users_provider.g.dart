// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Usuarios del negocio, también los inactivos, por nombre. Solo un MANAGER
/// puede consultarlos y modificarlos.

@ProviderFor(Users)
final usersProvider = UsersProvider._();

/// Usuarios del negocio, también los inactivos, por nombre. Solo un MANAGER
/// puede consultarlos y modificarlos.
final class UsersProvider extends $AsyncNotifierProvider<Users, List<AppUser>> {
  /// Usuarios del negocio, también los inactivos, por nombre. Solo un MANAGER
  /// puede consultarlos y modificarlos.
  UsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usersHash();

  @$internal
  @override
  Users create() => Users();
}

String _$usersHash() => r'5a0f4319287e4d6b544a28969be1563c359faf69';

/// Usuarios del negocio, también los inactivos, por nombre. Solo un MANAGER
/// puede consultarlos y modificarlos.

abstract class _$Users extends $AsyncNotifier<List<AppUser>> {
  FutureOr<List<AppUser>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<AppUser>>, List<AppUser>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AppUser>>, List<AppUser>>,
              AsyncValue<List<AppUser>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
