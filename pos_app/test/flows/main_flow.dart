import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/app/app.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';

import '../mocks/fake_repositories.dart';

/// Recorrido principal de la app, de punta a punta y sin servidor: los
/// repositorios son los falsos de `test/mocks`.
///
/// Lo comparten el test de widgets (corre en el PC) y el de integración
/// (corre en el teléfono), para que ambos comprueben exactamente lo mismo:
/// ingresar, abrir caja, vender, cobrar, ver la venta del día y crear una
/// categoría.
/// Los avisos emergentes tapan unos segundos lo que hay al pie de la pantalla
/// (p. ej. el banner del carrito): se espera a que se cierren solos.
Future<void> _waitForSnackBars(WidgetTester tester) async {
  for (var i = 0; i < 30 && find.byType(SnackBar).evaluate().isNotEmpty; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
  await tester.pumpAndSettle();
}

Future<void> runMainFlow(WidgetTester tester) async {
  final inventory = FakeInventoryRepository()
    ..seed('VILLA_LIBERTAD', [
      stocked(product(1, 'Cloro concentrado', price: '1.20', unit: UnitOfMeasure.liter), '48.5'),
      stocked(product(2, 'Escoba', price: '4.50', category: accessories), '3'),
    ]);
  final sales = FakeSalesRepository()..prices.addAll({1: dec('1.20'), 2: dec('4.50')});

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: manager()),
        branches: FakeBranchRepository([villaLibertad]),
        rate: dec('150'),
        inventory: inventory,
        sales: sales,
        users: FakeUsersRepository([manager()]),
      ),
      child: const PosApp(),
    ),
  );
  await tester.pumpAndSettle();

  // 1. Ingreso: el rol y la tienda salen de la cuenta.
  await tester.enterText(find.widgetWithText(TextFormField, Strings.username), 'jefe');
  await tester.enterText(find.widgetWithText(TextFormField, Strings.password), 'secreta');
  await tester.tap(find.text(Strings.signIn));
  await tester.pumpAndSettle();
  expect(find.text(Strings.salesToday.toUpperCase()), findsOneWidget);

  // 2. Vender sin caja abierta lleva a abrirla y después vuelve a Vender.
  await tester.tap(find.text(Strings.navSell));
  await tester.pumpAndSettle();
  expect(find.text(Strings.openCashTitle), findsOneWidget);
  await tester.enterText(find.widgetWithText(TextFormField, Strings.openingFloat), '20');
  await tester.tap(find.widgetWithText(FilledButton, Strings.openCash));
  await tester.pumpAndSettle();
  expect(find.text('Cloro concentrado'), findsOneWidget);
  await _waitForSnackBars(tester);

  // 3. Venta de una escoba, pagada en efectivo.
  await tester.tap(find.widgetWithText(FilledButton, Strings.add).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(Strings.viewCart));
  await tester.pumpAndSettle();
  await tester.tap(find.text(Strings.paymentMethod(PaymentMethod.cashUsd)));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, Strings.confirmSale));
  await tester.pumpAndSettle();
  expect(find.text(Strings.receiptTitle), findsOneWidget);
  expect(find.text(r'$ 4,50'), findsWidgets);
  expect(sales.createdSales.single.items.single.productId, 2);
  await tester.tap(find.widgetWithText(FilledButton, Strings.newSale));
  await tester.pumpAndSettle();

  // 4. La venta aparece en las ventas del día y se puede abrir.
  await tester.tap(find.text(Strings.navMore));
  await tester.pumpAndSettle();
  await tester.tap(find.text(Strings.salesHistoryTitle));
  await tester.pumpAndSettle();
  expect(find.textContaining(Strings.saleNumber(1)), findsOneWidget);
  await tester.tap(find.textContaining(Strings.saleNumber(1)));
  await tester.pumpAndSettle();
  expect(find.text(Strings.saleDetailTitle), findsOneWidget);
  expect(find.text('Escoba'), findsOneWidget);
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();

  // 5. El gerente crea una categoría.
  await tester.tap(find.text(Strings.categoriesTitle));
  await tester.pumpAndSettle();
  await tester.tap(find.text(Strings.newCategory));
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextFormField, Strings.categoryName), 'Aromatizantes');
  await tester.tap(find.widgetWithText(FilledButton, Strings.save));
  await tester.pumpAndSettle();
  expect(find.text('Aromatizantes'), findsOneWidget);
  expect(inventory.categories.map((category) => category.name), contains('Aromatizantes'));

  // Desmonta la app para que se cancele su temporizador de la tasa.
  await tester.pumpWidget(const SizedBox.shrink());
}
