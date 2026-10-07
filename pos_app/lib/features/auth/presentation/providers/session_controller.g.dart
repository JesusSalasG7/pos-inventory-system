// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(branchPreferenceStorage)
final branchPreferenceStorageProvider = BranchPreferenceStorageProvider._();

final class BranchPreferenceStorageProvider
    extends
        $FunctionalProvider<
          BranchPreferenceStorage,
          BranchPreferenceStorage,
          BranchPreferenceStorage
        >
    with $Provider<BranchPreferenceStorage> {
  BranchPreferenceStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'branchPreferenceStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$branchPreferenceStorageHash();

  @$internal
  @override
  $ProviderElement<BranchPreferenceStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BranchPreferenceStorage create(Ref ref) {
    return branchPreferenceStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BranchPreferenceStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BranchPreferenceStorage>(value),
    );
  }
}

String _$branchPreferenceStorageHash() => r'c552d39403269776094de26063e6a622b1e51d7d';

/// Orquesta el arranque de la sesión: tokens → usuario → sucursal activa.
///
/// El rol y la sucursal vienen de la cuenta; nunca se eligen en el login. La
/// sucursal se resuelve igual que en el backend (`resolve_branch`): la asignada
/// al usuario o, para un MANAGER con acceso a todas, la única activa o la que elija.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Orquesta el arranque de la sesión: tokens → usuario → sucursal activa.
///
/// El rol y la sucursal vienen de la cuenta; nunca se eligen en el login. La
/// sucursal se resuelve igual que en el backend (`resolve_branch`): la asignada
/// al usuario o, para un MANAGER con acceso a todas, la única activa o la que elija.
final class SessionControllerProvider extends $NotifierProvider<SessionController, SessionState> {
  /// Orquesta el arranque de la sesión: tokens → usuario → sucursal activa.
  ///
  /// El rol y la sucursal vienen de la cuenta; nunca se eligen en el login. La
  /// sucursal se resuelve igual que en el backend (`resolve_branch`): la asignada
  /// al usuario o, para un MANAGER con acceso a todas, la única activa o la que elija.
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }
}

String _$sessionControllerHash() => r'd213145fee10d498e88bffafb075bf048e3afb5f';

/// Orquesta el arranque de la sesión: tokens → usuario → sucursal activa.
///
/// El rol y la sucursal vienen de la cuenta; nunca se eligen en el login. La
/// sucursal se resuelve igual que en el backend (`resolve_branch`): la asignada
/// al usuario o, para un MANAGER con acceso a todas, la única activa o la que elija.

abstract class _$SessionController extends $Notifier<SessionState> {
  SessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SessionState, SessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SessionState, SessionState>,
              SessionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
