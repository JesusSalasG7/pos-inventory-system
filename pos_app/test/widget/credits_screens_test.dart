import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';
import 'package:pos_app/features/credits/presentation/screens/customer_detail_screen.dart';
import 'package:pos_app/features/credits/presentation/screens/customer_form_screen.dart';
import 'package:pos_app/features/credits/presentation/screens/customers_screen.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';

import '../mocks/fake_repositories.dart';
import '../mocks/test_fonts.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting();
  });

  late FakeCreditsRepository credits;

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(393, 1800) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: supervisor(), hasSession: true),
        branches: FakeBranchRepository([villaLibertad]),
        preference: InMemoryBranchPreferenceStorage('VILLA_LIBERTAD'),
        rate: dec('200'),
        credits: credits,
      ),
    );
    addTearDown(container.dispose);
    await tester.runAsync(() async {
      await settledSession(container);
      await container.read(activeRateProvider.future);
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    credits = FakeCreditsRepository()
      ..customers.addAll([
        customer(1, 'Ana Pérez', balance: '10', overdue: '4', rate: '875.65'),
        customer(2, 'Luis Gómez'),
      ]);
  });

  testWidgets('la lista marca a quién le venció la deuda y filtra a los que deben', (tester) async {
    await pump(tester, const CustomersScreen());

    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text(r'$ 10,00'), findsOneWidget);
    expect(find.text(Strings.overdueAmount(r'$ 4,00')), findsOneWidget);
    expect(find.text(Strings.noDebt), findsOneWidget);

    await tester.tap(find.text(Strings.onlyDebtors));
    await tester.pumpAndSettle();

    expect(find.text('Luis Gómez'), findsNothing);
    expect(find.text('Ana Pérez'), findsOneWidget);
  });

  testWidgets('el abono en bolívares se propone con el saldo a la tasa del BCV', (tester) async {
    await pump(tester, const CustomerDetailScreen(customerId: 1));

    // 10 USD × 875,65 = 8.756,50 Bs: la tasa del BCV, no la activa (200).
    expect(find.text(Strings.balanceInBs('Bs 8.756,50')), findsOneWidget);
    expect(find.text(Strings.bcvRateToday('875,65')), findsOneWidget);

    await tester.tap(find.text(Strings.registerPayment));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.paymentMethod(PaymentMethod.cashVes)));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '8756,5'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, Strings.registerPayment).last);
    await tester.pumpAndSettle();

    final (customerId, payment) = credits.registeredPayments.single;
    expect(customerId, 1);
    expect(payment.method, PaymentMethod.cashVes);
    expect(payment.amount, dec('8756.5'));
    expect(find.text(Strings.debtSettled), findsOneWidget);
  });

  testWidgets('no deja abonar más de lo que debe', (tester) async {
    await pump(tester, const CustomerDetailScreen(customerId: 1));

    await tester.tap(find.text(Strings.registerPayment));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '10'), '12');
    await tester.tap(find.widgetWithText(FilledButton, Strings.registerPayment).last);
    await tester.pumpAndSettle();

    expect(find.text(Strings.paymentExceeds(r'$ 10,00')), findsOneWidget);
    expect(credits.registeredPayments, isEmpty);
  });

  testWidgets('al crear un cliente la pantalla se cierra y devuelve el cliente', (tester) async {
    // El servidor tarda en responder, como en la red real.
    credits.delay = const Duration(milliseconds: 300);
    Customer? created;
    await pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => created = await Navigator.of(
            context,
          ).push<Customer>(MaterialPageRoute(builder: (_) => const CustomerFormScreen())),
          child: const Text('abrir'),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, Strings.customerNameLabel), 'Rosa');
    await tester.tap(find.widgetWithText(FilledButton, Strings.createCustomer));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pumpAndSettle();

    expect(created?.name, 'Rosa');
    expect(find.byType(CustomerFormScreen), findsNothing);
  });
}
