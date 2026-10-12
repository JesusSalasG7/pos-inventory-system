// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Filtros globales de la pantalla de estadísticas. Por defecto, los últimos
/// 30 días de la tienda, sin categoría.
///
/// Cada sección observa este filtro por su cuenta: al cambiarlo se vuelven a
/// pedir todas a la vez, y si una falla las demás siguen mostrándose.

@ProviderFor(StatsFilterController)
final statsFilterControllerProvider = StatsFilterControllerProvider._();

/// Filtros globales de la pantalla de estadísticas. Por defecto, los últimos
/// 30 días de la tienda, sin categoría.
///
/// Cada sección observa este filtro por su cuenta: al cambiarlo se vuelven a
/// pedir todas a la vez, y si una falla las demás siguen mostrándose.
final class StatsFilterControllerProvider
    extends $NotifierProvider<StatsFilterController, StatsFilter> {
  /// Filtros globales de la pantalla de estadísticas. Por defecto, los últimos
  /// 30 días de la tienda, sin categoría.
  ///
  /// Cada sección observa este filtro por su cuenta: al cambiarlo se vuelven a
  /// pedir todas a la vez, y si una falla las demás siguen mostrándose.
  StatsFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsFilterControllerHash();

  @$internal
  @override
  StatsFilterController create() => StatsFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsFilter>(value),
    );
  }
}

String _$statsFilterControllerHash() => r'4fdd7fd992c1fcb69c9d6af91ef931a29a842abb';

/// Filtros globales de la pantalla de estadísticas. Por defecto, los últimos
/// 30 días de la tienda, sin categoría.
///
/// Cada sección observa este filtro por su cuenta: al cambiarlo se vuelven a
/// pedir todas a la vez, y si una falla las demás siguen mostrándose.

abstract class _$StatsFilterController extends $Notifier<StatsFilter> {
  StatsFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StatsFilter, StatsFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StatsFilter, StatsFilter>,
              StatsFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Orden elegido en el ranking de productos. Cambiarlo solo recarga el ranking.

@ProviderFor(RankingOrderController)
final rankingOrderControllerProvider = RankingOrderControllerProvider._();

/// Orden elegido en el ranking de productos. Cambiarlo solo recarga el ranking.
final class RankingOrderControllerProvider
    extends $NotifierProvider<RankingOrderController, RankingOrder> {
  /// Orden elegido en el ranking de productos. Cambiarlo solo recarga el ranking.
  RankingOrderControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rankingOrderControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rankingOrderControllerHash();

  @$internal
  @override
  RankingOrderController create() => RankingOrderController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RankingOrder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RankingOrder>(value),
    );
  }
}

String _$rankingOrderControllerHash() => r'1098348374b51d212805494208efc62b260295aa';

/// Orden elegido en el ranking de productos. Cambiarlo solo recarga el ranking.

abstract class _$RankingOrderController extends $Notifier<RankingOrder> {
  RankingOrder build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RankingOrder, RankingOrder>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RankingOrder, RankingOrder>,
              RankingOrder,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(statsSummary)
final statsSummaryProvider = StatsSummaryProvider._();

final class StatsSummaryProvider
    extends $FunctionalProvider<AsyncValue<StatsSummary>, StatsSummary, FutureOr<StatsSummary>>
    with $FutureModifier<StatsSummary>, $FutureProvider<StatsSummary> {
  StatsSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsSummaryHash();

  @$internal
  @override
  $FutureProviderElement<StatsSummary> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<StatsSummary> create(Ref ref) {
    return statsSummary(ref);
  }
}

String _$statsSummaryHash() => r'3eea64495329f1baea1e245245cd3abe9a6908bd';

@ProviderFor(statsCreditBreakdown)
final statsCreditBreakdownProvider = StatsCreditBreakdownProvider._();

final class StatsCreditBreakdownProvider
    extends
        $FunctionalProvider<AsyncValue<CreditBreakdown>, CreditBreakdown, FutureOr<CreditBreakdown>>
    with $FutureModifier<CreditBreakdown>, $FutureProvider<CreditBreakdown> {
  StatsCreditBreakdownProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsCreditBreakdownProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsCreditBreakdownHash();

  @$internal
  @override
  $FutureProviderElement<CreditBreakdown> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CreditBreakdown> create(Ref ref) {
    return statsCreditBreakdown(ref);
  }
}

String _$statsCreditBreakdownHash() => r'74e4acd89dd059b2a68b58bd0684f65a5b13c012';

@ProviderFor(statsGroups)
final statsGroupsProvider = StatsGroupsProvider._();

final class StatsGroupsProvider
    extends $FunctionalProvider<AsyncValue<GroupReport>, GroupReport, FutureOr<GroupReport>>
    with $FutureModifier<GroupReport>, $FutureProvider<GroupReport> {
  StatsGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsGroupsHash();

  @$internal
  @override
  $FutureProviderElement<GroupReport> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GroupReport> create(Ref ref) {
    return statsGroups(ref);
  }
}

String _$statsGroupsHash() => r'eb13996f747e5819b49d20e6109ea5d60c7c242a';

@ProviderFor(statsRanking)
final statsRankingProvider = StatsRankingProvider._();

final class StatsRankingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductPerformance>>,
          List<ProductPerformance>,
          FutureOr<List<ProductPerformance>>
        >
    with $FutureModifier<List<ProductPerformance>>, $FutureProvider<List<ProductPerformance>> {
  StatsRankingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsRankingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsRankingHash();

  @$internal
  @override
  $FutureProviderElement<List<ProductPerformance>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductPerformance>> create(Ref ref) {
    return statsRanking(ref);
  }
}

String _$statsRankingHash() => r'f3c9875726208f903848669209679849fc5ac7d0';

@ProviderFor(statsMatrix)
final statsMatrixProvider = StatsMatrixProvider._();

final class StatsMatrixProvider
    extends $FunctionalProvider<AsyncValue<StatsMatrix>, StatsMatrix, FutureOr<StatsMatrix>>
    with $FutureModifier<StatsMatrix>, $FutureProvider<StatsMatrix> {
  StatsMatrixProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsMatrixProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsMatrixHash();

  @$internal
  @override
  $FutureProviderElement<StatsMatrix> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<StatsMatrix> create(Ref ref) {
    return statsMatrix(ref);
  }
}

String _$statsMatrixHash() => r'a9ee05fd7a4f349e08d6c502343e520974a54600';

/// Salud del inventario a la fecha de hoy. Solo depende de la categoría del
/// filtro: cambiar el período no la vuelve a pedir.

@ProviderFor(statsInventoryHealth)
final statsInventoryHealthProvider = StatsInventoryHealthProvider._();

/// Salud del inventario a la fecha de hoy. Solo depende de la categoría del
/// filtro: cambiar el período no la vuelve a pedir.

final class StatsInventoryHealthProvider
    extends
        $FunctionalProvider<AsyncValue<InventoryHealth>, InventoryHealth, FutureOr<InventoryHealth>>
    with $FutureModifier<InventoryHealth>, $FutureProvider<InventoryHealth> {
  /// Salud del inventario a la fecha de hoy. Solo depende de la categoría del
  /// filtro: cambiar el período no la vuelve a pedir.
  StatsInventoryHealthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsInventoryHealthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsInventoryHealthHash();

  @$internal
  @override
  $FutureProviderElement<InventoryHealth> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<InventoryHealth> create(Ref ref) {
    return statsInventoryHealth(ref);
  }
}

String _$statsInventoryHealthHash() => r'71c099a9651a5736c2bae8d74707f14c518a63f8';
