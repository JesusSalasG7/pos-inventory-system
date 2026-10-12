import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/features/statistics/data/dtos/statistics_dtos.dart';
import 'package:pos_app/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/presentation/providers/statistics_providers.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_format.dart';

import '../mocks/fake_repositories.dart';

void main() {
  group('DTOs', () {
    test('leen los números de JSON como decimales exactos', () {
      final summary = SummaryDto.fromJson({
        'period': {'date_from': '2026-03-02', 'date_to': '2026-03-31'},
        'previous_period': {'date_from': '2026-01-31', 'date_to': '2026-03-01'},
        'current': {
          'revenue': 52.0,
          'profit': 14.0,
          'margin': 26.92,
          'units': 33.0,
          'sales_count': 2,
          'average_ticket': 26.0,
        },
        'previous': {
          'revenue': 0.0,
          'profit': 0.0,
          'margin': 0.0,
          // Un entero también es un número válido.
          'units': 0,
          'sales_count': 0,
          'average_ticket': 0.0,
        },
        'change': {
          'revenue': null,
          'profit': null,
          'margin': null,
          'units': null,
          'sales_count': null,
          'average_ticket': null,
        },
      }).toEntity();

      expect(summary.current.margin, dec('26.92'));
      expect(summary.current.revenue, dec('52'));
      expect(summary.period.from, DateTime(2026, 3, 2));
      expect(summary.hasSales, isTrue);
      expect(summary.change.revenue, isNull);
      expect(summary.change.margin, isNull);
    });

    test('leen grupos, matriz y salud del inventario', () {
      final report = GroupReportDto.fromJson({
        'level': 'subcategory',
        'category_id': 1,
        'category_name': 'Limpieza',
        'groups': [
          {
            'id': null,
            'name': 'Sin subcategoría',
            'units': 1.0,
            'revenue': 3.0,
            'profit': -1.5,
            'margin': -50.0,
          },
        ],
      }).toEntity();
      expect(report.level, GroupLevel.subcategory);
      expect(report.groups.single.id, isNull);
      expect(report.groups.single.profit, dec('-1.5'));

      final matrix = MatrixDto.fromJson({
        'median_units': 6.0,
        'median_margin': 25.0,
        'counts': <Object>[],
        'products': [
          {
            'product_id': 4,
            'name': 'Ambientador',
            'unit_of_measure': 'LITER',
            'units': 2.0,
            'revenue': 5.0,
            'profit': -1.0,
            'margin': -20.0,
            'quadrant': 'REVIEW',
          },
        ],
      }).toEntity();
      expect(matrix.products.single.quadrant, Quadrant.review);
      expect(matrix.products.single.unit, UnitOfMeasure.liter);
      expect(matrix.countOf(Quadrant.review), 1);
      expect(matrix.countOf(Quadrant.star), 0);

      final health = InventoryHealthDto.fromJson({
        'as_of': '2026-03-31',
        'no_sales_days': 30,
        'max_days_left': 15,
        'immobilized_capital_total': 12.0,
        'no_movement': [
          {
            'product_id': 6,
            'name': 'Nuevo',
            'unit_of_measure': 'UNIT',
            'stock': 2.0,
            'last_sale_date': null,
            'immobilized_capital': 2.0,
          },
        ],
        'running_out': [
          {
            'product_id': 1,
            'name': 'Detergente',
            'unit_of_measure': 'LITER',
            'stock': 3.0,
            'daily_rate': 0.333,
            'days_left': 9.0,
          },
        ],
      }).toEntity();
      expect(health.immobilizedCapitalTotal, dec('12'));
      expect(health.noMovement.single.lastSaleDate, isNull);
      expect(health.runningOut.single.daysLeft, dec('9'));
    });
  });

  test('lee el desglose de contado y crédito', () {
    final breakdown = CreditBreakdownDto.fromJson({
      'cash': {'revenue': 42.0, 'profit': 10.4, 'margin': 24.76},
      'credit': {'revenue': 10.0, 'profit': 3.6, 'margin': 36.0},
      'pending': {'revenue': 4.0, 'profit': 1.44},
      'credit_share': 19.23,
    }).toEntity();

    expect(breakdown.cash.profit, dec('10.4'));
    expect(breakdown.credit.margin, dec('36'));
    expect(breakdown.pendingProfit, dec('1.44'));
    expect(breakdown.creditShare, dec('19.23'));
    expect(breakdown.hasCreditSales, isTrue);
  });

  test('los filtros viajan como fechas de calendario y la categoría solo si se eligió', () {
    final filter = StatsFilter.lastDays(StatsRange.days7, today: DateTime(2026, 3, 31));

    expect(StatisticsRepositoryImpl.queryOf('VILLA_LIBERTAD', filter), {
      'branch': 'VILLA_LIBERTAD',
      'date_from': '2026-03-25',
      'date_to': '2026-03-31',
    });
    expect(
      StatisticsRepositoryImpl.queryOf(
        'VILLA_LIBERTAD',
        filter.withCategory(const StatsCategory(id: 3, name: 'Aromas')),
      )['category'],
      3,
    );
  });

  test('los ejes usan formato compacto', () {
    expect(StatsFormat.compact(850), '850');
    expect(StatsFormat.compact(1200), '1,2 K');
    expect(StatsFormat.compact(3400000), '3,4 M');
    expect(StatsFormat.compact(-1500), '-1,5 K');
    expect(StatsFormat.percent(dec('26.92')), '26,92 %');
    expect(StatsFormat.change(dec('-23.08'), inPoints: true), '23,1 pp');
  });

  group('providers', () {
    late FakeStatisticsRepository statistics;

    Future<ProviderContainer> readyContainer() async {
      statistics = FakeStatisticsRepository();
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: sessionOverrides(
          auth: FakeAuthRepository(user: manager(), hasSession: true),
          branches: FakeBranchRepository([villaLibertad, lasAmericas]),
          preference: InMemoryBranchPreferenceStorage('VILLA_LIBERTAD'),
          rate: dec('150'),
          statistics: statistics,
        ),
      );
      addTearDown(container.dispose);
      container
        ..listen(statsSummaryProvider, (_, _) {})
        ..listen(statsCreditBreakdownProvider, (_, _) {})
        ..listen(statsGroupsProvider, (_, _) {})
        ..listen(statsRankingProvider, (_, _) {})
        ..listen(statsMatrixProvider, (_, _) {})
        ..listen(statsInventoryHealthProvider, (_, _) {});
      await settledSession(container);
      return container;
    }

    Future<void> loadAll(ProviderContainer container) async {
      await container.read(statsSummaryProvider.future);
      await container.read(statsCreditBreakdownProvider.future);
      await container.read(statsGroupsProvider.future);
      await container.read(statsRankingProvider.future);
      await container.read(statsMatrixProvider.future);
      await container.read(statsInventoryHealthProvider.future);
    }

    test('por defecto se piden los últimos 30 días, ordenados por ganancia', () async {
      final container = await readyContainer();
      await loadAll(container);

      final filter = statistics.summaryCalls.single;
      expect(filter.range, StatsRange.days30);
      expect(filter.period.to.difference(filter.period.from).inDays, 29);
      expect(filter.category, isNull);
      expect(statistics.rankingCalls, [RankingOrder.profit]);
    });

    test('entrar en una categoría recarga todas las secciones filtradas', () async {
      final container = await readyContainer();
      await loadAll(container);

      container
          .read(statsFilterControllerProvider.notifier)
          .enterCategory(const StatsCategory(id: 1, name: 'Líquidos'));
      await loadAll(container);

      expect(statistics.summaryCalls.last.category?.id, 1);
      expect(statistics.matrixCalls.last.category?.id, 1);
      expect(statistics.healthCalls, [null, 1]);
      expect((await container.read(statsGroupsProvider.future)).level, GroupLevel.subcategory);

      container.read(statsFilterControllerProvider.notifier).clearCategory();
      await loadAll(container);
      expect(statistics.groupCalls.last.category, isNull);
    });

    test('cambiar el orden solo recarga el ranking', () async {
      final container = await readyContainer();
      await loadAll(container);

      container.read(rankingOrderControllerProvider.notifier).select(RankingOrder.units);
      final ranking = await container.read(statsRankingProvider.future);
      await loadAll(container);

      expect(ranking.first.name, 'Cloro');
      expect(statistics.rankingCalls, [RankingOrder.profit, RankingOrder.units]);
      expect(statistics.summaryCalls, hasLength(1));
      expect(statistics.matrixCalls, hasLength(1));
    });

    test('cambiar el período no vuelve a pedir la salud del inventario', () async {
      final container = await readyContainer();
      await loadAll(container);

      container.read(statsFilterControllerProvider.notifier).selectRange(StatsRange.days7);
      await loadAll(container);
      container
          .read(statsFilterControllerProvider.notifier)
          .selectCustomPeriod(DateTime(2026, 3), DateTime(2026, 3, 15));
      await loadAll(container);

      expect(statistics.summaryCalls.map((filter) => filter.range), [
        StatsRange.days30,
        StatsRange.days7,
        StatsRange.custom,
      ]);
      expect(statistics.summaryCalls.last.period.to, DateTime(2026, 3, 15));
      expect(statistics.healthCalls, hasLength(1));
    });

    test('si una sección falla las demás siguen cargando', () async {
      final container = await readyContainer();
      statistics.matrixFailure = offline;
      container.invalidate(statsMatrixProvider);

      await expectLater(container.read(statsMatrixProvider.future), throwsA(offline));
      expect((await container.read(statsSummaryProvider.future)).hasSales, isTrue);
      expect(await container.read(statsRankingProvider.future), hasLength(2));
    });
  });
}
