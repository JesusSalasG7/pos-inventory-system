// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_branch_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sucursal sobre la que opera la app; `null` hasta que se resuelve tras el login.
///
/// Los repositorios envían siempre su `code` en `branch`, de modo que un MANAGER
/// con acceso a todas vea solo la sede elegida. Al cambiarla, los providers de
/// inventario, caja, ventas y reportes que la observan se recalculan solos.

@ProviderFor(ActiveBranch)
final activeBranchProvider = ActiveBranchProvider._();

/// Sucursal sobre la que opera la app; `null` hasta que se resuelve tras el login.
///
/// Los repositorios envían siempre su `code` en `branch`, de modo que un MANAGER
/// con acceso a todas vea solo la sede elegida. Al cambiarla, los providers de
/// inventario, caja, ventas y reportes que la observan se recalculan solos.
final class ActiveBranchProvider extends $NotifierProvider<ActiveBranch, Branch?> {
  /// Sucursal sobre la que opera la app; `null` hasta que se resuelve tras el login.
  ///
  /// Los repositorios envían siempre su `code` en `branch`, de modo que un MANAGER
  /// con acceso a todas vea solo la sede elegida. Al cambiarla, los providers de
  /// inventario, caja, ventas y reportes que la observan se recalculan solos.
  ActiveBranchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeBranchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeBranchHash();

  @$internal
  @override
  ActiveBranch create() => ActiveBranch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Branch? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Branch?>(value));
  }
}

String _$activeBranchHash() => r'3ff3d35ce39a066f7f894dead4409046691e172a';

/// Sucursal sobre la que opera la app; `null` hasta que se resuelve tras el login.
///
/// Los repositorios envían siempre su `code` en `branch`, de modo que un MANAGER
/// con acceso a todas vea solo la sede elegida. Al cambiarla, los providers de
/// inventario, caja, ventas y reportes que la observan se recalculan solos.

abstract class _$ActiveBranch extends $Notifier<Branch?> {
  Branch? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Branch?, Branch?>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<Branch?, Branch?>, Branch?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
