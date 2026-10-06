// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_rate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tasa activa del backend con su origen y el día al que corresponde; `null`
/// si todavía no hay ninguna.
///
/// La tasa cambia sola cuando el servidor sincroniza con el BCV, así que se
/// vuelve a consultar al abrir la app, al volver a primer plano y cada pocos
/// minutos mientras está abierta (ver `PosApp`).

@ProviderFor(ActiveExchangeRate)
final activeExchangeRateProvider = ActiveExchangeRateProvider._();

/// Tasa activa del backend con su origen y el día al que corresponde; `null`
/// si todavía no hay ninguna.
///
/// La tasa cambia sola cuando el servidor sincroniza con el BCV, así que se
/// vuelve a consultar al abrir la app, al volver a primer plano y cada pocos
/// minutos mientras está abierta (ver `PosApp`).
final class ActiveExchangeRateProvider
    extends $AsyncNotifierProvider<ActiveExchangeRate, ExchangeRate?> {
  /// Tasa activa del backend con su origen y el día al que corresponde; `null`
  /// si todavía no hay ninguna.
  ///
  /// La tasa cambia sola cuando el servidor sincroniza con el BCV, así que se
  /// vuelve a consultar al abrir la app, al volver a primer plano y cada pocos
  /// minutos mientras está abierta (ver `PosApp`).
  ActiveExchangeRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeExchangeRateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeExchangeRateHash();

  @$internal
  @override
  ActiveExchangeRate create() => ActiveExchangeRate();
}

String _$activeExchangeRateHash() => r'77d4dbeaa2aee9ff7cc27c0e12fc57ad5370a09f';

/// Tasa activa del backend con su origen y el día al que corresponde; `null`
/// si todavía no hay ninguna.
///
/// La tasa cambia sola cuando el servidor sincroniza con el BCV, así que se
/// vuelve a consultar al abrir la app, al volver a primer plano y cada pocos
/// minutos mientras está abierta (ver `PosApp`).

abstract class _$ActiveExchangeRate extends $AsyncNotifier<ExchangeRate?> {
  FutureOr<ExchangeRate?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ExchangeRate?>, ExchangeRate?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExchangeRate?>, ExchangeRate?>,
              AsyncValue<ExchangeRate?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Valor de la tasa activa (VES por 1 USD); `null` si no hay ninguna.
///
/// Toda conversión USD → VES de la UI la lee de aquí, salvo cuando se pasa una
/// tasa congelada (comprobantes e historial de ventas).

@ProviderFor(ActiveRate)
final activeRateProvider = ActiveRateProvider._();

/// Valor de la tasa activa (VES por 1 USD); `null` si no hay ninguna.
///
/// Toda conversión USD → VES de la UI la lee de aquí, salvo cuando se pasa una
/// tasa congelada (comprobantes e historial de ventas).
final class ActiveRateProvider extends $AsyncNotifierProvider<ActiveRate, Decimal?> {
  /// Valor de la tasa activa (VES por 1 USD); `null` si no hay ninguna.
  ///
  /// Toda conversión USD → VES de la UI la lee de aquí, salvo cuando se pasa una
  /// tasa congelada (comprobantes e historial de ventas).
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

String _$activeRateHash() => r'feda224e2e4d1077893bc706fb412e9978006aed';

/// Valor de la tasa activa (VES por 1 USD); `null` si no hay ninguna.
///
/// Toda conversión USD → VES de la UI la lee de aquí, salvo cuando se pasa una
/// tasa congelada (comprobantes e historial de ventas).

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
