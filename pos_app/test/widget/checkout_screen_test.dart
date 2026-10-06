import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/pos/presentation/providers/cart_controller.dart';
import 'package:pos_app/features/pos/presentation/screens/checkout_screen.dart';

import '../mocks/fake_repositories.dart';
import '../mocks/test_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  final chlorine = product(1, 'Cloro concentrado', price: '1.20', unit: UnitOfMeasure.liter);
  final broom = product(2, 'Escoba', price: '4.50');
  late ProviderContainer container;

  Future<void> pumpCheckout(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 2600) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: supervisor(), hasSession: true),
        branches: FakeBranchRepository([villaLibertad]),
        rate: dec('150'),
      ),
    );
    addTearDown(container.dispose);
    container.listen(cartControllerProvider, (_, _) {});
    await tester.runAsync(() async {
      await settledSession(container);
      await container.read(activeRateProvider.future);
    });
    // Total: 2,5 × 1,20 + 1 × 4,50 = 7,50 $ = 1.125,00 Bs.
    container.read(cartControllerProvider.notifier)
      ..setQuantity(stocked(chlorine, '48.5'), dec('2.5'))
      ..setQuantity(stocked(broom, '3'), dec('1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const CheckoutScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool confirmEnabled(WidgetTester tester) =>
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, Strings.confirmSale))
          .onPressed !=
      null;

  Finder amountField() => find.widgetWithText(TextFormField, Strings.paymentAmount);

  testWidgets('muestra los ítems, el total en las dos monedas y la tasa usada', (tester) async {
    await pumpCheckout(tester);

    expect(find.text('Cloro concentrado'), findsOneWidget);
    expect(find.text('Escoba'), findsOneWidget);
    expect(find.text(r'$ 7,50'), findsWidgets);
    expect(find.text('Bs 1.125,00'), findsWidgets);
    expect(find.text(Strings.rateUsed('150,00')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sin pagos, Confirmar está deshabilitado y falta todo el total', (tester) async {
    await pumpCheckout(tester);

    expect(confirmEnabled(tester), isFalse);
    expect(find.text(Strings.remaining.toUpperCase()), findsOneWidget);
  });

  testWidgets('Confirmar solo se habilita cuando los pagos cuadran', (tester) async {
    await pumpCheckout(tester);

    // La línea se prellena con el restante: cuadra de inmediato.
    await tester.tap(find.text(Strings.paymentMethod(PaymentMethod.cashUsd)));
    await tester.pumpAndSettle();
    expect(find.text(Strings.paidExact.toUpperCase()), findsOneWidget);
    expect(confirmEnabled(tester), isTrue);

    // Si paga menos, falta dinero.
    await tester.enterText(amountField(), '5');
    await tester.pumpAndSettle();
    expect(find.text(Strings.remaining.toUpperCase()), findsOneWidget);
    expect(find.text(r'$ 2,50'), findsOneWidget);
    expect(find.text('Bs 375,00'), findsOneWidget);
    expect(confirmEnabled(tester), isFalse);

    // Si paga de más en efectivo, hay vuelto y se puede confirmar.
    await tester.enterText(amountField(), '10');
    await tester.pumpAndSettle();
    expect(find.text(Strings.change.toUpperCase()), findsOneWidget);
    expect(find.text(r'$ 2,50'), findsOneWidget);
    expect(confirmEnabled(tester), isTrue);
  });

  testWidgets('pago móvil exige la referencia para poder confirmar', (tester) async {
    await pumpCheckout(tester);

    await tester.tap(find.text(Strings.paymentMethod(PaymentMethod.mobilePayment)));
    await tester.pumpAndSettle();

    expect(find.text(Strings.referenceRequired), findsOneWidget);
    expect(find.text(Strings.incompletePayments), findsOneWidget);
    expect(confirmEnabled(tester), isFalse);

    await tester.enterText(find.widgetWithText(TextFormField, Strings.paymentReference), '004512');
    await tester.pumpAndSettle();

    expect(find.text(Strings.referenceRequired), findsNothing);
    expect(confirmEnabled(tester), isTrue);
  });

  testWidgets('pago mixto: la segunda línea se prellena con lo que falta', (tester) async {
    await pumpCheckout(tester);

    await tester.tap(find.text(Strings.paymentMethod(PaymentMethod.cashUsd)));
    await tester.pumpAndSettle();
    await tester.enterText(amountField(), '5');
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.paymentMethod(PaymentMethod.cashVes)).first);
    await tester.pumpAndSettle();

    // Faltaban 2,50 $ = 375 Bs.
    expect(find.widgetWithText(TextFormField, '375'), findsOneWidget);
    expect(confirmEnabled(tester), isTrue);
  });

  testWidgets('sobrar dinero sin efectivo impide confirmar', (tester) async {
    await pumpCheckout(tester);

    await tester.tap(find.text(Strings.paymentMethod(PaymentMethod.posCard)));
    await tester.pumpAndSettle();
    await tester.enterText(amountField(), '5000');
    await tester.enterText(find.widgetWithText(TextFormField, Strings.paymentReference), 'R1');
    await tester.pumpAndSettle();

    expect(find.text(Strings.overpaidWithoutCash), findsOneWidget);
    expect(confirmEnabled(tester), isFalse);
  });

  testWidgets('una línea que supera el stock disponible bloquea la venta', (tester) async {
    await pumpCheckout(tester);
    await tester.tap(find.text(Strings.paymentMethod(PaymentMethod.cashUsd)));
    await tester.pumpAndSettle();
    expect(confirmEnabled(tester), isTrue);

    // El backend informó que solo queda 1 litro.
    container.read(cartControllerProvider.notifier).applyAvailableStock({1: dec('1')});
    await tester.pumpAndSettle();

    expect(find.text(Strings.availableOnly('1 L')), findsOneWidget);
    expect(find.text(Strings.stockIssues), findsOneWidget);
    expect(confirmEnabled(tester), isFalse);
  });

  testWidgets('quitar todos los ítems deja el carrito vacío', (tester) async {
    await pumpCheckout(tester);

    await tester.tap(find.byTooltip(Strings.removeItem).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(Strings.removeItem).first);
    await tester.pumpAndSettle();

    expect(find.text(Strings.emptyCartTitle), findsOneWidget);
  });
}
