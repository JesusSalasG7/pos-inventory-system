// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_history_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Número de ventas y totales de la tienda activa en un día de Caracas.
/// `day` es una fecha de calendario (sin hora).

@ProviderFor(daySalesSummary)
final daySalesSummaryProvider = DaySalesSummaryFamily._();

/// Número de ventas y totales de la tienda activa en un día de Caracas.
/// `day` es una fecha de calendario (sin hora).

final class DaySalesSummaryProvider
    extends $FunctionalProvider<AsyncValue<SalesSummary>, SalesSummary, FutureOr<SalesSummary>>
    with $FutureModifier<SalesSummary>, $FutureProvider<SalesSummary> {
  /// Número de ventas y totales de la tienda activa en un día de Caracas.
  /// `day` es una fecha de calendario (sin hora).
  DaySalesSummaryProvider._({
    required DaySalesSummaryFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'daySalesSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$daySalesSummaryHash();

  @override
  String toString() {
    return r'daySalesSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SalesSummary> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SalesSummary> create(Ref ref) {
    final argument = this.argument as DateTime;
    return daySalesSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DaySalesSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$daySalesSummaryHash() => r'88e67bc8002ba2501470f3aa78bc1572767cbaf8';

/// Número de ventas y totales de la tienda activa en un día de Caracas.
/// `day` es una fecha de calendario (sin hora).

final class DaySalesSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SalesSummary>, DateTime> {
  DaySalesSummaryFamily._()
    : super(
        retry: null,
        name: r'daySalesSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Número de ventas y totales de la tienda activa en un día de Caracas.
  /// `day` es una fecha de calendario (sin hora).

  DaySalesSummaryProvider call(DateTime day) =>
      DaySalesSummaryProvider._(argument: day, from: this);

  @override
  String toString() => r'daySalesSummaryProvider';
}

/// Ventas de la tienda activa en un día de Caracas, de la más reciente a la
/// más antigua, cargadas página a página.

@ProviderFor(SalesHistory)
final salesHistoryProvider = SalesHistoryFamily._();

/// Ventas de la tienda activa en un día de Caracas, de la más reciente a la
/// más antigua, cargadas página a página.
final class SalesHistoryProvider extends $AsyncNotifierProvider<SalesHistory, PagedList<Sale>> {
  /// Ventas de la tienda activa en un día de Caracas, de la más reciente a la
  /// más antigua, cargadas página a página.
  SalesHistoryProvider._({required SalesHistoryFamily super.from, required DateTime super.argument})
    : super(
        retry: null,
        name: r'salesHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesHistoryHash();

  @override
  String toString() {
    return r'salesHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SalesHistory create() => SalesHistory();

  @override
  bool operator ==(Object other) {
    return other is SalesHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$salesHistoryHash() => r'baf4642e57af9de704723a63f2e2feb3492314a3';

/// Ventas de la tienda activa en un día de Caracas, de la más reciente a la
/// más antigua, cargadas página a página.

final class SalesHistoryFamily extends $Family
    with
        $ClassFamilyOverride<
          SalesHistory,
          AsyncValue<PagedList<Sale>>,
          PagedList<Sale>,
          FutureOr<PagedList<Sale>>,
          DateTime
        > {
  SalesHistoryFamily._()
    : super(
        retry: null,
        name: r'salesHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Ventas de la tienda activa en un día de Caracas, de la más reciente a la
  /// más antigua, cargadas página a página.

  SalesHistoryProvider call(DateTime day) => SalesHistoryProvider._(argument: day, from: this);

  @override
  String toString() => r'salesHistoryProvider';
}

/// Ventas de la tienda activa en un día de Caracas, de la más reciente a la
/// más antigua, cargadas página a página.

abstract class _$SalesHistory extends $AsyncNotifier<PagedList<Sale>> {
  late final _$args = ref.$arg as DateTime;
  DateTime get day => _$args;

  FutureOr<PagedList<Sale>> build(DateTime day);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PagedList<Sale>>, PagedList<Sale>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedList<Sale>>, PagedList<Sale>>,
              AsyncValue<PagedList<Sale>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
