// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rate_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tasa oficial del BCV, solo como referencia.

@ProviderFor(bcvRate)
final bcvRateProvider = BcvRateProvider._();

/// Tasa oficial del BCV, solo como referencia.

final class BcvRateProvider
    extends $FunctionalProvider<AsyncValue<BcvRate>, BcvRate, FutureOr<BcvRate>>
    with $FutureModifier<BcvRate>, $FutureProvider<BcvRate> {
  /// Tasa oficial del BCV, solo como referencia.
  BcvRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bcvRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bcvRateHash();

  @$internal
  @override
  $FutureProviderElement<BcvRate> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<BcvRate> create(Ref ref) {
    return bcvRate(ref);
  }
}

String _$bcvRateHash() => r'03c9f8c639d152904bfa445a224b1d71244aff9d';

/// Histórico de tasas, cargado página a página.

@ProviderFor(RateHistory)
final rateHistoryProvider = RateHistoryProvider._();

/// Histórico de tasas, cargado página a página.
final class RateHistoryProvider
    extends $AsyncNotifierProvider<RateHistory, PagedList<ExchangeRate>> {
  /// Histórico de tasas, cargado página a página.
  RateHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rateHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rateHistoryHash();

  @$internal
  @override
  RateHistory create() => RateHistory();
}

String _$rateHistoryHash() => r'80d960bb5f2d9142388dde543d04f9754b54ebfe';

/// Histórico de tasas, cargado página a página.

abstract class _$RateHistory extends $AsyncNotifier<PagedList<ExchangeRate>> {
  FutureOr<PagedList<ExchangeRate>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PagedList<ExchangeRate>>, PagedList<ExchangeRate>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedList<ExchangeRate>>, PagedList<ExchangeRate>>,
              AsyncValue<PagedList<ExchangeRate>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
