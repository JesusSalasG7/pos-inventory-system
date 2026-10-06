import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/rate_history_provider.dart';
import 'package:pos_app/features/home/presentation/providers/dashboard_providers.dart';

import '../mocks/fake_repositories.dart';

void main() {
  late FakeCashSessionRepository cash;
  late FakeExchangeRateRepository rates;
  late FakeSalesRepository sales;
  late FakeBranchRepository branches;

  Future<ProviderContainer> readyContainer({String branch = 'VILLA_LIBERTAD'}) async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: manager(), hasSession: true),
        branches: branches,
        preference: InMemoryBranchPreferenceStorage(branch),
        rates: rates,
        cash: cash,
        sales: sales,
      ),
    );
    addTearDown(container.dispose);
    await settledSession(container);
    return container;
  }

  setUp(() {
    cash = FakeCashSessionRepository();
    rates = FakeExchangeRateRepository(dec('150'));
    sales = FakeSalesRepository();
    branches = FakeBranchRepository([villaLibertad, lasAmericas]);
  });

  group('tasa activa', () {
    test('se carga al quedar lista la sesión', () async {
      final container = await readyContainer();

      expect(await container.read(activeRateProvider.future), dec('150'));
    });

    test('sin sesión no consulta al backend', () async {
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: sessionOverrides(auth: FakeAuthRepository(), branches: branches, rates: rates),
      );
      addTearDown(container.dispose);
      await settledSession(container);

      expect(await container.read(activeRateProvider.future), isNull);
    });

    test('registrar una tasa la deja como activa y refresca el histórico', () async {
      final container = await readyContainer();
      await container.read(activeRateProvider.future);
      expect((await container.read(rateHistoryProvider.future)).items, isEmpty);

      await container.read(activeExchangeRateProvider.notifier).register(dec('872.3927'));

      expect(await container.read(activeRateProvider.future), dec('872.3927'));
      final history = await container.read(rateHistoryProvider.future);
      expect(history.items.single.rate, dec('872.3927'));
    });

    test('la tasa BCV no disponible es un error, no una tasa', () async {
      final container = await readyContainer();

      // Se mantiene escuchado, como lo haría la pantalla.
      container.listen(bcvRateProvider, (_, _) {});

      await expectLater(
        container.read(bcvRateProvider.future),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'bcv_rate_unavailable')),
      );

      rates.bcv = BcvRate(rate: dec('870.10'), updatedAt: DateTime.utc(2026, 10, 6));
      container.invalidate(bcvRateProvider);
      expect((await container.read(bcvRateProvider.future)).rate, dec('870.10'));
    });
  });

  group('caja', () {
    test('sin caja abierta el estado es null', () async {
      final container = await readyContainer();

      expect(await container.read(currentSessionProvider.future), isNull);
    });

    test('abre la caja en la tienda activa', () async {
      final container = await readyContainer(branch: 'LAS_AMERICAS');
      await container.read(currentSessionProvider.future);

      final session = await container
          .read(currentSessionProvider.notifier)
          .open(openingFloat: dec('20.00'));

      expect(session.branchCode, 'LAS_AMERICAS');
      expect(container.read(currentSessionProvider).value!.openingFloat, dec('20.00'));
    });

    test('si el backend rechaza la apertura el estado no cambia', () async {
      cash.openFailure = const Failure(code: 'session_already_open', message: 'Ya hay una.');
      final container = await readyContainer();
      await container.read(currentSessionProvider.future);

      await expectLater(
        container.read(currentSessionProvider.notifier).open(openingFloat: dec('0')),
        throwsA(isA<Failure>()),
      );

      expect(container.read(currentSessionProvider).value, isNull);
    });

    test('un gasto refresca el arqueo y la lista de gastos', () async {
      final container = await readyContainer();
      await container.read(currentSessionProvider.future);
      final notifier = container.read(currentSessionProvider.notifier);
      final session = await notifier.open(openingFloat: dec('50'));

      final before = await container.read(sessionSummaryProvider(session.id).future);
      expect(before.expectedCashUsd, dec('50'));

      await notifier.registerExpense(
        sessionId: session.id,
        reason: 'Bolsas',
        amount: dec('7.50'),
        currency: Currency.usd,
      );

      final after = await container.read(sessionSummaryProvider(session.id).future);
      expect(after.expectedCashUsd, dec('42.50'));
      final expenses = await container.read(sessionExpensesProvider(session.id).future);
      expect(expenses.single.reason, 'Bolsas');
    });

    test('cerrar devuelve la diferencia del backend y deja al usuario sin caja', () async {
      cash.rate = dec('150');
      final container = await readyContainer();
      await container.read(currentSessionProvider.future);
      final notifier = container.read(currentSessionProvider.notifier);
      final session = await notifier.open(openingFloat: dec('50'));

      final closed = await notifier.close(
        sessionId: session.id,
        countedAmountUsd: dec('48'),
        countedAmountVes: dec('0'),
      );

      expect(closed.differenceUsd, dec('-2.00'));
      expect(closed.isOpen, isFalse);
      expect(container.read(currentSessionProvider).value, isNull);
      final history = await container.read(cashHistoryProvider.future);
      expect(history.items.single.id, session.id);
    });
  });

  group('dashboard', () {
    test('las ventas de hoy se piden para la tienda activa desde las 00:00 de Caracas', () async {
      final container = await readyContainer(branch: 'LAS_AMERICAS');

      await container.read(todaySalesSummaryProvider.future);

      expect(sales.lastBranchCode, 'LAS_AMERICAS');
      final from = DateFormatter.toCaracas(sales.lastDateFrom!);
      expect((from.hour, from.minute, from.second), (0, 0, 0));
    });

    test('al cambiar de tienda se vuelven a pedir los datos', () async {
      final container = await readyContainer();
      await container.read(todaySalesSummaryProvider.future);
      expect(sales.lastBranchCode, 'VILLA_LIBERTAD');

      await container.read(sessionControllerProvider.notifier).selectBranch(lasAmericas);
      await container.read(todaySalesSummaryProvider.future);

      expect(sales.lastBranchCode, 'LAS_AMERICAS');
    });
  });
}
