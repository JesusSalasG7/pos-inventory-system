import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/presentation/screens/statistics_screen.dart';

import '../mocks/fake_repositories.dart';
import '../mocks/test_fonts.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting();
  });

  late FakeStatisticsRepository statistics;

  setUp(() => statistics = FakeStatisticsRepository());

  Future<void> pumpScreen(WidgetTester tester, {Size size = const Size(393, 3600)}) async {
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: manager(), hasSession: true),
        branches: FakeBranchRepository([villaLibertad]),
        preference: InMemoryBranchPreferenceStorage('VILLA_LIBERTAD'),
        rate: dec('150'),
        statistics: statistics,
      ),
    );
    addTearDown(container.dispose);
    await tester.runAsync(() => settledSession(container));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const StatisticsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra los KPIs con su variación y todas las secciones', (tester) async {
    await pumpScreen(tester);

    expect(find.text(r'$ 52,00'), findsOneWidget);
    expect(find.text('26,92 %'), findsOneWidget);
    // Suben los ingresos; el margen baja y va en puntos porcentuales.
    expect(find.text('420 %'), findsOneWidget);
    expect(find.text('23,1 pp'), findsOneWidget);
    // El ticket promedio no tiene con qué compararse.
    expect(find.text(Strings.statsNoPrevious), findsOneWidget);

    expect(find.text(Strings.statsByCategory), findsOneWidget);
    expect(find.text(Strings.statsGroupsHint), findsOneWidget);
    expect(find.text('Líquidos › Detergentes'), findsOneWidget);
    expect(find.text('${Strings.statsQuadrantStar} (1)'), findsNothing);
    expect(find.textContaining('${Strings.statsQuadrantStar} (1)'), findsOneWidget);
    expect(find.textContaining(Strings.statsActionReview), findsOneWidget);
    expect(find.text(r'$ 12,00'), findsOneWidget);
    expect(find.text(Strings.statsRunningOut(1)), findsOneWidget);
    expect(find.text(Strings.statsNoMovement(2)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reparte los ingresos y la ganancia entre contado y crédito', (tester) async {
    await pumpScreen(tester);

    final cash = find.byKey(const ValueKey('stats-split-cash'));
    final credit = find.byKey(const ValueKey('stats-split-credit'));
    expect(find.descendant(of: cash, matching: find.text(r'$ 42,00')), findsOneWidget);
    expect(
      find.descendant(of: cash, matching: find.text('${Strings.statsProfit} \$ 10,40')),
      findsOneWidget,
    );
    expect(find.descendant(of: credit, matching: find.text(r'$ 10,00')), findsOneWidget);
    expect(
      find.descendant(of: credit, matching: find.text('${Strings.statsProfit} \$ 3,60')),
      findsOneWidget,
    );
    expect(find.text(Strings.statsCreditShare('19,23 %')), findsOneWidget);
    // Lo que aún se debe de esas ventas y la ganancia que le corresponde.
    final pending = find.byKey(const ValueKey('stats-pending'));
    expect(find.descendant(of: pending, matching: find.text(r'$ 4,00')), findsOneWidget);
    expect(find.text(Strings.statsPendingProfit(r'$ 1,44')), findsOneWidget);
  });

  testWidgets('sin ventas a crédito lo dice y no muestra nada por cobrar', (tester) async {
    statistics.hasCreditSales = false;
    await pumpScreen(tester);

    expect(find.text(Strings.statsNoCreditSales), findsOneWidget);
    expect(find.byKey(const ValueKey('stats-pending')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('entrar en una categoría filtra toda la pantalla y el chip vuelve atrás', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('stats-group-1')));
    await tester.pumpAndSettle();

    expect(find.text(Strings.statsBySubcategory('Líquidos')), findsOneWidget);
    expect(find.byKey(const ValueKey('stats-category-chip')), findsOneWidget);
    // En el nivel de subcategorías ya no se puede entrar más.
    expect(find.text(Strings.statsGroupsHint), findsNothing);
    expect(find.text('Sin subcategoría'), findsWidgets);
    expect(statistics.summaryCalls.last.category?.id, 1);
    expect(statistics.creditCalls.last.category?.id, 1);
    expect(statistics.healthCalls.last, 1);

    await tester.tap(find.byTooltip(Strings.statsBackToOverview));
    await tester.pumpAndSettle();

    expect(find.text(Strings.statsByCategory), findsOneWidget);
    expect(statistics.groupCalls.last.category, isNull);
  });

  testWidgets('cambiar el orden del ranking solo recarga esa sección', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('stats-order-units')));
    await tester.pumpAndSettle();

    expect(statistics.rankingCalls, [RankingOrder.profit, RankingOrder.units]);
    expect(statistics.summaryCalls, hasLength(1));
    // La métrica elegida pasa a ser la destacada.
    expect(find.text('20 L'), findsOneWidget);
  });

  testWidgets('cambiar el período vuelve a pedir los datos', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('stats-range-days7')));
    await tester.pumpAndSettle();

    expect(statistics.summaryCalls.last.range, StatsRange.days7);
    expect(statistics.healthCalls, hasLength(1));
  });

  testWidgets('las listas de salud del inventario se despliegan', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text(Strings.statsRunningOut(1)));
    await tester.pumpAndSettle();
    expect(find.text(Strings.statsDaysLeft('9')), findsOneWidget);

    await tester.tap(find.text(Strings.statsNoMovement(2)));
    await tester.pumpAndSettle();
    expect(find.text(Strings.statsNeverSold), findsOneWidget);
    expect(find.text(Strings.statsNoSalesSince('01/03/2026')), findsOneWidget);
  });

  testWidgets('un período sin ventas muestra los KPIs en cero y un aviso', (tester) async {
    statistics.empty = true;
    await pumpScreen(tester);

    expect(find.text(r'$ 0,00'), findsNWidgets(3));
    expect(find.text(Strings.statsNoSales), findsOneWidget);
    expect(find.text(Strings.statsRankingTitle), findsNothing);
    // La salud del inventario no depende del período.
    expect(find.text(Strings.statsHealthTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('si una sección falla se puede reintentar y las demás se ven', (tester) async {
    statistics.matrixFailure = offline;
    await pumpScreen(tester);

    expect(find.text(offline.message), findsOneWidget);
    expect(find.text(r'$ 52,00'), findsOneWidget);
    expect(find.text('Líquidos › Detergentes'), findsOneWidget);

    statistics.matrixFailure = null;
    await tester.tap(find.text(Strings.retry));
    await tester.pumpAndSettle();

    expect(find.text(offline.message), findsNothing);
    expect(find.textContaining(Strings.statsQuadrantReview), findsWidgets);
  });

  testWidgets('en pantallas anchas los KPIs van en cuatro columnas', (tester) async {
    await pumpScreen(tester, size: const Size(900, 3000));

    final revenue = tester.getTopLeft(find.text(Strings.statsRevenue).first);
    final units = tester.getTopLeft(find.text(Strings.statsUnits).first);
    final sales = tester.getTopLeft(find.text(Strings.statsSalesCount).first);
    // Los cuatro primeros comparten fila; el quinto baja a la siguiente.
    expect(units.dy, revenue.dy);
    expect(sales.dy, greaterThan(revenue.dy));
    expect(tester.takeException(), isNull);
  });
}
