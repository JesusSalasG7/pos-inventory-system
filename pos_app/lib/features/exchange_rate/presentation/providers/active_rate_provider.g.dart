// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_rate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tasa activa global (VES por 1 USD); `null` si el backend aún no tiene ninguna.
///
/// Toda conversión USD → VES de la UI la lee de aquí, salvo cuando se pasa una
/// tasa congelada (comprobantes e historial de ventas). Se carga al quedar
/// lista la sesión.

@ProviderFor(ActiveRate)
final activeRateProvider = ActiveRateProvider._();

/// Tasa activa global (VES por 1 USD); `null` si el backend aún no tiene ninguna.
///
/// Toda conversión USD → VES de la UI la lee de aquí, salvo cuando se pasa una
/// tasa congelada (comprobantes e historial de ventas). Se carga al quedar
/// lista la sesión.
final class ActiveRateProvider extends $AsyncNotifierProvider<ActiveRate, Decimal?> {
  /// Tasa activa global (VES por 1 USD); `null` si el backend aún no tiene ninguna.
  ///
  /// Toda conversión USD → VES de la UI la lee de aquí, salvo cuando se pasa una
  /// tasa congelada (comprobantes e historial de ventas). Se carga al quedar
  /// lista la sesión.
  ActiveRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeRateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeRateHash();

  @$internal
  @override
  ActiveRate create() => ActiveRate();
}

String _$activeRateHash() => r'758c97fff56d3fc9b0177caca03a27114cd97ad6';

/// Tasa activa global (VES por 1 USD); `null` si el backend aún no tiene ninguna.
///
/// Toda conversión USD → VES de la UI la lee de aquí, salvo cuando se pasa una
/// tasa congelada (comprobantes e historial de ventas). Se carga al quedar
/// lista la sesión.

abstract class _$ActiveRate extends $AsyncNotifier<Decimal?> {
  FutureOr<Decimal?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Decimal?>, Decimal?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Decimal?>, Decimal?>,
              AsyncValue<Decimal?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
