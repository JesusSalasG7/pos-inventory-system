// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ventas de hoy (día de Caracas) en la sucursal activa.

@ProviderFor(todaySalesSummary)
final todaySalesSummaryProvider = TodaySalesSummaryProvider._();

/// Ventas de hoy (día de Caracas) en la sucursal activa.

final class TodaySalesSummaryProvider
    extends $FunctionalProvider<AsyncValue<SalesSummary>, SalesSummary, FutureOr<SalesSummary>>
    with $FutureModifier<SalesSummary>, $FutureProvider<SalesSummary> {
  /// Ventas de hoy (día de Caracas) en la sucursal activa.
  TodaySalesSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaySalesSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaySalesSummaryHash();

  @$internal
  @override
  $FutureProviderElement<SalesSummary> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SalesSummary> create(Ref ref) {
    return todaySalesSummary(ref);
  }
}

String _$todaySalesSummaryHash() => r'25de333780f8ebc1c2688035eeefb5221b48dd66';

/// Productos de la sucursal activa en o bajo su stock mínimo.

@ProviderFor(lowStockCount)
final lowStockCountProvider = LowStockCountProvider._();

/// Productos de la sucursal activa en o bajo su stock mínimo.

final class LowStockCountProvider extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Productos de la sucursal activa en o bajo su stock mínimo.
  LowStockCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lowStockCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lowStockCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return lowStockCount(ref);
  }
}

String _$lowStockCountHash() => r'71489fcd11633c12869f143ebc9a65a528f98d60';
