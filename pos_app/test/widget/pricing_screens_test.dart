import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/pricing_settings.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/pricing_settings_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/screens/exchange_rate_screen.dart';
import 'package:pos_app/features/inventory/presentation/screens/categories_screen.dart';
import 'package:pos_app/features/inventory/presentation/screens/price_list_screen.dart';
import 'package:pos_app/features/pos/presentation/providers/cart_controller.dart';
import 'package:pos_app/features/pos/presentation/screens/checkout_screen.dart';

import '../mocks/fake_repositories.dart';
import '../mocks/test_fonts.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting();
  });

  // Tasa que deja céntimos: 1,20 $ = 180,36 Bs; 4,50 $ = 676,35 Bs.
  final chlorine = product(1, 'Cloro', price: '1.20', unit: UnitOfMeasure.liter);
  final broom = product(2, 'Escoba', price: '4.50', category: accessories);

  late FakeExchangeRateRepository rates;
  late FakeInventoryRepository inventory;
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester, Widget screen, {AppUser? user}) async {
    tester.view.physicalSize = const Size(393, 2400) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: user ?? manager(), hasSession: true),
        branches: FakeBranchRepository([villaLibertad]),
        rates: rates,
        inventory: inventory,
      ),
    );
    addTearDown(container.dispose);
    container.listen(cartControllerProvider, (_, _) {});
    await tester.runAsync(() async {
      await settledSession(container);
      await container.read(activeRateProvider.future);
      await container.read(pricingSettingsControllerProvider.future);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// La sesión se preparó con el reloj real (`runAsync`): las recargas tras
  /// guardar necesitan que corra de nuevo antes de volver a pintar.
  Future<void> settleReload(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  setUp(() {
    rates = FakeExchangeRateRepository(dec('150.30'));
    inventory = FakeInventoryRepository()
      ..seed('VILLA_LIBERTAD', [stocked(chlorine, '48.5'), stocked(broom, '3')]);
  });

  group('lista de precios', () {
    testWidgets('muestra todos los productos con su precio en las dos monedas', (tester) async {
      await pump(tester, const PriceListScreen());

      expect(find.text('Cloro'), findsOneWidget);
      expect(find.text(r'$ 1,20'), findsOneWidget);
      expect(find.text('Bs 180,36'), findsOneWidget);
      expect(find.text('Escoba'), findsOneWidget);
      expect(find.text('Bs 676,35'), findsOneWidget);
      // Agrupados por categoría.
      expect(find.text('Accesorios'), findsOneWidget);
      expect(find.text('Líquidos'), findsOneWidget);
    });

    testWidgets('con el redondeo activo los bolívares suben al entero', (tester) async {
      rates.settings = const PricingSettings(roundVesUp: true);
      await pump(tester, const PriceListScreen());

      expect(find.text('Bs 181,00'), findsOneWidget);
      expect(find.text('Bs 677,00'), findsOneWidget);
      // Los dólares no cambian.
      expect(find.text(r'$ 1,20'), findsOneWidget);
    });

    testWidgets('la búsqueda filtra por nombre', (tester) async {
      await pump(tester, const PriceListScreen());

      await tester.enterText(find.byType(TextField), 'esco');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Escoba'), findsOneWidget);
      expect(find.text('Cloro'), findsNothing);
    });
  });

  group('cobro con redondeo', () {
    testWidgets('el total y el pago en bolívares usan el precio unitario redondeado', (
      tester,
    ) async {
      rates.settings = const PricingSettings(roundVesUp: true);
      await pump(tester, const SizedBox.shrink());
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

      // 2,5 × 181 = 452,50 y 677: total 1.129,50 Bs (sin redondeo serían 1.127,25).
      expect(find.text(r'$ 7,50'), findsWidgets);
      expect(find.text('Bs 1.129,50'), findsWidgets);
      expect(find.text('Bs 1.127,25'), findsNothing);

      await tester.tap(find.text(Strings.paymentMethod(PaymentMethod.cashVes)));
      await tester.pumpAndSettle();

      expect(find.text(Strings.paidExact.toUpperCase()), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, Strings.confirmSale))
            .onPressed,
        isNotNull,
      );
    });
  });

  group('ajustes de tasa', () {
    testWidgets('el gerente pasa a vender con su tasa y deja de sincronizar con el BCV', (
      tester,
    ) async {
      await pump(tester, const ExchangeRateScreen());
      expect(find.text(Strings.syncBcv), findsOneWidget);

      await tester.tap(find.text(Strings.rateModeManual));
      await tester.pumpAndSettle();
      await settleReload(tester);

      expect(rates.settings.rateMode, RateMode.manual);
      expect(find.text(Strings.rateModeManualHint), findsOneWidget);
      expect(find.text(Strings.ownRateNote), findsOneWidget);
      expect(find.text(Strings.syncBcv), findsNothing);
      expect(find.text(Strings.registerRate), findsOneWidget);
    });

    testWidgets('el gerente activa el redondeo de los bolívares', (tester) async {
      await pump(tester, const ExchangeRateScreen());

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(rates.settings.roundVesUp, isTrue);
      expect(container.read(roundVesUpProvider), isTrue);
      expect(find.text(Strings.roundVesUpOn), findsOneWidget);
    });

    testWidgets('un supervisor no ve los ajustes', (tester) async {
      await pump(tester, const ExchangeRateScreen(), user: supervisor());

      expect(find.text(Strings.pricingSettingsTitle.toUpperCase()), findsNothing);
      expect(find.byType(Switch), findsNothing);
    });
  });

  group('sticker de categoría', () {
    testWidgets('al crear una categoría se puede elegir un sticker', (tester) async {
      await pump(tester, const CategoriesScreen());

      await tester.tap(find.text(Strings.newCategory));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, Strings.categoryName),
        'Aromatizantes',
      );
      await tester.tap(find.bySemanticsLabel('🌸'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, Strings.save));
      await tester.pumpAndSettle();

      final created = inventory.categories.last;
      expect((created.name, created.icon), ('Aromatizantes', '🌸'));
    });

    testWidgets('sin elegir nada la categoría queda con el ícono automático', (tester) async {
      await pump(tester, const CategoriesScreen());

      await tester.tap(find.text(Strings.newCategory));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, Strings.categoryName), 'Varios');
      await tester.tap(find.widgetWithText(FilledButton, Strings.save));
      await tester.pumpAndSettle();

      expect(inventory.categories.last.hasSticker, isFalse);
    });

    testWidgets('al editar se puede quitar el sticker y volver al automático', (tester) async {
      inventory.categories = [const ProductCategory(id: 1, name: 'Aromas', icon: '🌸')];
      await pump(tester, const CategoriesScreen());

      await tester.tap(find.text('Aromas'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(Strings.automaticSticker));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, Strings.save));
      await tester.pumpAndSettle();

      expect(inventory.categories.single.icon, isEmpty);
    });
  });
}
