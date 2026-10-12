import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/presentation/providers/statistics_providers.dart';
import 'package:pos_app/features/statistics/presentation/widgets/credit_breakdown_view.dart';
import 'package:pos_app/features/statistics/presentation/widgets/group_performance_chart.dart';
import 'package:pos_app/features/statistics/presentation/widgets/inventory_health_view.dart';
import 'package:pos_app/features/statistics/presentation/widgets/kpi_grid.dart';
import 'package:pos_app/features/statistics/presentation/widgets/matrix_chart.dart';
import 'package:pos_app/features/statistics/presentation/widgets/product_ranking_list.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_filter_bar.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_section.dart';

/// Estadísticas de la tienda activa (solo MANAGER): KPIs, contado y crédito, rendimiento por
/// categoría, ranking de productos, matriz volumen vs. margen y salud del
/// inventario.
///
/// Cada sección tiene su propio provider: se piden todas a la vez y, si una
/// falla, las demás siguen mostrándose.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  /// Vuelve a pedir todas las secciones y espera a que terminen, fallen o no.
  Future<void> _refresh(WidgetRef ref) async {
    Future<void> settle(Future<Object?> request) async {
      try {
        await request;
      } on Object {
        // Cada sección pinta su propio error.
      }
    }

    await Future.wait([
      settle(ref.refresh(statsSummaryProvider.future)),
      settle(ref.refresh(statsCreditBreakdownProvider.future)),
      settle(ref.refresh(statsGroupsProvider.future)),
      settle(ref.refresh(statsRankingProvider.future)),
      settle(ref.refresh(statsMatrixProvider.future)),
      settle(ref.refresh(statsInventoryHealthProvider.future)),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(statsFilterControllerProvider);
    final summary = ref.watch(statsSummaryProvider);
    final credit = ref.watch(statsCreditBreakdownProvider);
    final groups = ref.watch(statsGroupsProvider);
    final ranking = ref.watch(statsRankingProvider);
    final matrix = ref.watch(statsMatrixProvider);
    final health = ref.watch(statsInventoryHealthProvider);
    final order = ref.watch(rankingOrderControllerProvider);

    final isLoading =
        summary.isLoading ||
        credit.isLoading ||
        groups.isLoading ||
        ranking.isLoading ||
        matrix.isLoading ||
        health.isLoading;
    // Con el resumen cargado y sin ventas, un solo aviso sustituye a las
    // secciones que saldrían vacías.
    final hasNoSales = summary.hasValue && !summary.isLoading && !summary.requireValue.hasSales;
    final category = filter.category;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.statisticsTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: isLoading
              ? const LinearProgressIndicator(minHeight: 2)
              : const SizedBox(height: 2),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const StatsFilterBar(),
            const SizedBox(height: AppSpacing.lg),
            if (summary.hasValue)
              KpiGrid(summary: summary.requireValue)
            else if (summary.hasError)
              SectionCard(
                child: StatsSectionError(
                  message: Failure.from(summary.error!).message,
                  onRetry: () => ref.invalidate(statsSummaryProvider),
                ),
              )
            else
              const SkeletonBox(height: 200),
            const SizedBox(height: AppSpacing.lg),
            if (hasNoSales)
              const SectionCard(child: StatsEmptyNote())
            else ...[
              StatsSection<CreditBreakdown>(
                title: Strings.statsCreditTitle,
                value: credit,
                onRetry: () => ref.invalidate(statsCreditBreakdownProvider),
                builder: (data) => CreditBreakdownView(breakdown: data),
              ),
              const SizedBox(height: AppSpacing.lg),
              StatsSection<GroupReport>(
                title: category == null
                    ? Strings.statsByCategory
                    : Strings.statsBySubcategory(category.name),
                value: groups,
                onRetry: () => ref.invalidate(statsGroupsProvider),
                loadingHeight: 240,
                builder: (report) => GroupPerformanceChart(
                  report: report,
                  onEnter: (group) => ref
                      .read(statsFilterControllerProvider.notifier)
                      .enterCategory(StatsCategory(id: group.id!, name: group.name)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                title: Strings.statsRankingTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RankingOrderChips(
                      selected: order,
                      onSelected: ref.read(rankingOrderControllerProvider.notifier).select,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (ranking.hasValue)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: ranking.isLoading ? 0.5 : 1,
                        child: ProductRankingList(products: ranking.requireValue, order: order),
                      )
                    else if (ranking.hasError)
                      StatsSectionError(
                        message: Failure.from(ranking.error!).message,
                        onRetry: () => ref.invalidate(statsRankingProvider),
                      )
                    else
                      const SkeletonBox(height: 200),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              StatsSection<StatsMatrix>(
                title: Strings.statsMatrixTitle,
                value: matrix,
                onRetry: () => ref.invalidate(statsMatrixProvider),
                loadingHeight: 260,
                builder: (data) => MatrixChart(matrix: data),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            StatsSection<InventoryHealth>(
              title: Strings.statsHealthTitle,
              value: health,
              onRetry: () => ref.invalidate(statsInventoryHealthProvider),
              builder: (data) => InventoryHealthView(health: data),
            ),
          ],
        ),
      ),
    );
  }
}
