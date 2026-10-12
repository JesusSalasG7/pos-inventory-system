import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_providers.g.dart';

/// Filtros globales de la pantalla de estadísticas. Por defecto, los últimos
/// 30 días de la tienda, sin categoría.
///
/// Cada sección observa este filtro por su cuenta: al cambiarlo se vuelven a
/// pedir todas a la vez, y si una falla las demás siguen mostrándose.
@riverpod
class StatsFilterController extends _$StatsFilterController {
  @override
  StatsFilter build() => StatsFilter.lastDays(StatsRange.days30, today: _today());

  static DateTime _today() => DateFormatter.caracasDay(DateTime.now());

  /// Cambia a uno de los atajos (7, 30 o 90 días), contados hasta hoy.
  void selectRange(StatsRange range) {
    state = StatsFilter.lastDays(range, today: _today(), category: state.category);
  }

  /// Fija un rango de fechas de calendario elegido a mano.
  void selectCustomPeriod(DateTime from, DateTime to) {
    state = StatsFilter(
      range: StatsRange.custom,
      period: StatsPeriod(from: from, to: to),
      category: state.category,
    );
  }

  /// Entra en una categoría: toda la pantalla pasa a mostrar solo sus datos.
  void enterCategory(StatsCategory category) => state = state.withCategory(category);

  /// Vuelve a la vista general.
  void clearCategory() => state = state.withCategory(null);
}

/// Orden elegido en el ranking de productos. Cambiarlo solo recarga el ranking.
@riverpod
class RankingOrderController extends _$RankingOrderController {
  @override
  RankingOrder build() => RankingOrder.profit;

  void select(RankingOrder order) => state = order;
}

/// Código de la tienda activa. Las estadísticas solo se abren con la sesión
/// lista, así que siempre hay una.
String _branchCode(Ref ref) => ref.watch(activeBranchProvider)!.code;

@riverpod
Future<StatsSummary> statsSummary(Ref ref) {
  return ref
      .watch(statisticsRepositoryProvider)
      .fetchSummary(branchCode: _branchCode(ref), filter: ref.watch(statsFilterControllerProvider));
}

@riverpod
Future<CreditBreakdown> statsCreditBreakdown(Ref ref) {
  return ref
      .watch(statisticsRepositoryProvider)
      .fetchCreditBreakdown(
        branchCode: _branchCode(ref),
        filter: ref.watch(statsFilterControllerProvider),
      );
}

@riverpod
Future<GroupReport> statsGroups(Ref ref) {
  return ref
      .watch(statisticsRepositoryProvider)
      .fetchGroups(branchCode: _branchCode(ref), filter: ref.watch(statsFilterControllerProvider));
}

@riverpod
Future<List<ProductPerformance>> statsRanking(Ref ref) {
  return ref
      .watch(statisticsRepositoryProvider)
      .fetchRanking(
        branchCode: _branchCode(ref),
        filter: ref.watch(statsFilterControllerProvider),
        order: ref.watch(rankingOrderControllerProvider),
      );
}

@riverpod
Future<StatsMatrix> statsMatrix(Ref ref) {
  return ref
      .watch(statisticsRepositoryProvider)
      .fetchMatrix(branchCode: _branchCode(ref), filter: ref.watch(statsFilterControllerProvider));
}

/// Salud del inventario a la fecha de hoy. Solo depende de la categoría del
/// filtro: cambiar el período no la vuelve a pedir.
@riverpod
Future<InventoryHealth> statsInventoryHealth(Ref ref) {
  final category = ref.watch(statsFilterControllerProvider.select((filter) => filter.category));
  return ref
      .watch(statisticsRepositoryProvider)
      .fetchInventoryHealth(branchCode: _branchCode(ref), categoryId: category?.id);
}
