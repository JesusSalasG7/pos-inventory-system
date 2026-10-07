import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:pos_app/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:pos_app/features/inventory/presentation/screens/product_detail_screen.dart';

import '../mocks/fake_repositories.dart';
import '../mocks/test_fonts.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting();
  });

  final chlorine = product(1, 'Cloro concentrado', price: '1.20', unit: UnitOfMeasure.liter);
  final broom = product(2, 'Escoba', price: '4.50', category: accessories);
  final oldSoap = product(3, 'Jabón viejo', active: false);

  late FakeInventoryRepository inventory;
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester, Widget screen, {required AppUser user}) async {
    tester.view.physicalSize = const Size(393, 2200) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    inventory = FakeInventoryRepository()
      ..seed('VILLA_LIBERTAD', [
        stocked(chlorine, '48.5', minimum: '10'),
        stocked(broom, '3', minimum: '5'),
        stocked(oldSoap, '0'),
      ]);
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: user, hasSession: true),
        branches: FakeBranchRepository([villaLibertad]),
        rate: dec('150'),
        inventory: inventory,
      ),
    );
    addTearDown(container.dispose);
    container.listen(inventoryCatalogProvider, (_, _) {});
    await tester.runAsync(() async {
      await settledSession(container);
      await container.read(activeRateProvider.future);
      await container.read(inventoryCatalogProvider.future);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// El catálogo se recarga tras guardar. La sesión se preparó con el reloj
  /// real (`runAsync`), así que esa recarga necesita que corra de nuevo antes
  /// de volver a pintar.
  Future<void> settleReload(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  group('pestaña Inventario', () {
    testWidgets('lista todo el catálogo, también lo inactivo y lo agotado', (tester) async {
      await pump(tester, const InventoryScreen(), user: supervisor());

      expect(find.text('Cloro concentrado'), findsOneWidget);
      expect(find.text('48,5 L'), findsOneWidget);
      expect(find.text('Jabón viejo'), findsOneWidget);
      expect(find.text(Strings.inactiveProduct), findsOneWidget);
      expect(find.text(Strings.outOfStock), findsOneWidget);
    });

    testWidgets('el filtro "Por reponer" deja solo los activos en o bajo el mínimo', (
      tester,
    ) async {
      await pump(tester, const InventoryScreen(), user: supervisor());

      // La escoba (3 ≤ 5) cuenta; el jabón agotado no, porque está inactivo.
      await tester.tap(find.text(Strings.onlyLowStockCount(1)));
      await tester.pumpAndSettle();

      expect(find.text('Escoba'), findsOneWidget);
      expect(find.text('Cloro concentrado'), findsNothing);
      expect(find.text('Jabón viejo'), findsNothing);
    });

    testWidgets('la búsqueda filtra por nombre', (tester) async {
      await pump(tester, const InventoryScreen(), user: supervisor());

      await tester.enterText(find.byType(TextField), 'esco');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Escoba'), findsOneWidget);
      expect(find.text('Cloro concentrado'), findsNothing);
    });

    testWidgets('solo un gerente puede crear productos', (tester) async {
      await pump(tester, const InventoryScreen(), user: supervisor());
      expect(find.text(Strings.newProduct), findsNothing);

      await pump(tester, const InventoryScreen(), user: manager(assignedBranch: 'VILLA_LIBERTAD'));
      expect(find.text(Strings.newProduct), findsOneWidget);
    });
  });

  group('detalle de producto', () {
    testWidgets('un supervisor no ve el costo ni puede cambiar el mínimo', (tester) async {
      await pump(tester, const ProductDetailScreen(productId: 1), user: supervisor());

      expect(find.text(r'$ 1,20'), findsOneWidget);
      expect(find.text('Bs 180,00'), findsOneWidget);
      expect(find.text(Strings.minimumStockOf('10 L')), findsOneWidget);
      expect(find.text(Strings.costPrice), findsNothing);
      expect(find.text(Strings.changeMinimum), findsNothing);
      expect(find.text(Strings.deactivateProduct), findsNothing);
    });

    testWidgets('un gerente ve el costo y las acciones de administración', (tester) async {
      await pump(
        tester,
        const ProductDetailScreen(productId: 1),
        user: manager(assignedBranch: 'VILLA_LIBERTAD'),
      );

      expect(find.text(r'$ 0,50'), findsOneWidget);
      expect(find.text(Strings.changeMinimum), findsOneWidget);
      expect(find.text(Strings.deactivateProduct), findsOneWidget);
    });

    testWidgets('registrar una entrada actualiza el stock y el Kardex', (tester) async {
      await pump(tester, const ProductDetailScreen(productId: 1), user: supervisor());

      await tester.tap(find.widgetWithText(FilledButton, Strings.registerEntry));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, Strings.entryQuantity), '11,5');
      await tester.pump();
      expect(find.text(Strings.resultingStock('60 L')), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, Strings.registerEntry).last);
      await tester.pumpAndSettle();

      expect(find.text(Strings.movementSaved), findsOneWidget);
      await settleReload(tester);

      expect(find.text('60 L'), findsWidgets);
      expect(find.text('+11,5 L'), findsOneWidget);
      expect(find.text(Strings.stockChange('48,5 L', '60 L')), findsOneWidget);
    });

    testWidgets('la merma no deja pasar más de lo que hay', (tester) async {
      await pump(tester, const ProductDetailScreen(productId: 2), user: supervisor());

      await tester.tap(find.text(Strings.movementType(MovementType.waste)));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, Strings.wasteQuantity), '4');
      await tester.tap(find.widgetWithText(FilledButton, Strings.registerWaste));
      await tester.pumpAndSettle();

      expect(find.text(Strings.maxAvailable('3 und')), findsOneWidget);
      expect(inventory.movements, isEmpty);
    });

    testWidgets('un ajuste igual al stock avisa de que no cambió nada', (tester) async {
      await pump(tester, const ProductDetailScreen(productId: 2), user: supervisor());

      await tester.tap(find.text(Strings.movementType(MovementType.adjustment)));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, Strings.countedStock), '3');
      await tester.tap(find.widgetWithText(FilledButton, Strings.adjustStock));
      await tester.pumpAndSettle();

      expect(find.text(Strings.adjustmentUnchanged), findsOneWidget);
      expect(inventory.movements, isEmpty);
    });

    testWidgets('un producto inactivo no admite entradas', (tester) async {
      await pump(tester, const ProductDetailScreen(productId: 3), user: supervisor());

      expect(find.text(Strings.inactiveEntryNote), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, Strings.registerEntry))
            .onPressed,
        isNull,
      );
    });
  });
}
