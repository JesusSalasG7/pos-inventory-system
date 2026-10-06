// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exchangeRateRepository)
final exchangeRateRepositoryProvider = ExchangeRateRepositoryProvider._();

final class ExchangeRateRepositoryProvider
    extends
        $FunctionalProvider<ExchangeRateRepository, ExchangeRateRepository, ExchangeRateRepository>
    with $Provider<ExchangeRateRepository> {
  ExchangeRateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exchangeRateRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exchangeRateRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExchangeRateRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExchangeRateRepository create(Ref ref) {
    return exchangeRateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExchangeRateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExchangeRateRepository>(value),
    );
  }
}

String _$exchangeRateRepositoryHash() => r'90abe46202471752e0110e713dc3aa23dd474dca';
