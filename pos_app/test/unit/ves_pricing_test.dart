import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/currency/ves_pricing.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/pricing_settings.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/pricing_settings_provider.dart';
import 'package:pos_app/features/inventory/data/dtos/product_dto.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/screens/price_list_screen.dart';
import 'package:pos_app/features/pos/domain/cart.dart';
import 'package:pos_app/features/pos/domain/checkout_math.dart';

import '../mocks/fake_repositories.dart';

void main() {
  // Tasa que deja céntimos en los precios: 1,20 $ = 180,36 Bs; 4,50 $ = 676,35 Bs.
  final rate = dec('150.30');
  final chlorine = product(1, 'Cloro', price: '1.20', unit: UnitOfMeasure.liter);
  final broom = product(2, 'Escoba', price: '4.50', category: accessories);

  CartItem item(Product product, String quantity) => CartItem(
    product: product,
    quantity: dec(quantity),
    availableStock: dec('100'),
    minimumStock: dec('0'),
  );

  group('precios en bolívares', () {
    test('sin redondeo conservan los céntimos', () {
      expect(VesPricing.unitPrice(dec('1.20'), rate, roundUp: false), dec('180.36'));
      expect(VesPricing.lineSubtotal(dec('2.5'), dec('1.20'), rate, roundUp: false), dec('450.9'));
    });

    test('con redondeo suben al bolívar entero, precio y subtotal', () {
      expect(VesPricing.unitPrice(dec('1.20'), rate, roundUp: true), dec('181'));
      // 2,5 × 181 = 452,5 → 453.
      expect(VesPricing.lineSubtotal(dec('2.5'), dec('1.20'), rate, roundUp: true), dec('453'));
    });

    test('un precio que ya es entero no sube', () {
      expect(VesPricing.unitPrice(dec('1.00'), dec('150'), roundUp: true), dec('150'));
    });

    test('el total del carrito redondeado es la suma de sus líneas, como en el backend', () {
      final cart = Cart(items: [item(chlorine, '2.5'), item(broom, '1')]);

      expect(cart.totalUsd, dec('7.50'));
      expect(cart.totalVes(rate, roundUp: false), dec('1127.25'));
      expect(cart.totalVes(rate, roundUp: true), dec('1130'));
    });
  });

  group('cobro con los bolívares redondeados', () {
    const mobile = PaymentMethod.mobilePayment;
    final totalUsd = dec('4.50');
    final totalVes = dec('677');

    CheckoutSummary compute(List<PaymentLine> lines) =>
        CheckoutMath.compute(totalUsd: totalUsd, totalVes: totalVes, rate: rate, lines: lines);

    test('sin pagos falta el total redondeado', () {
      final summary = compute(const []);

      expect(summary.status, CheckoutStatus.noPayments);
      expect(summary.remainingVes, totalVes);
    });

    test('una línea en bolívares se prellena con el total redondeado y cuadra', () {
      final prefill = CheckoutMath.prefillFor(
        method: mobile,
        totalUsd: totalUsd,
        totalVes: totalVes,
        rate: rate,
        lines: const [],
      );

      expect(prefill, totalVes);
      final summary = compute([
        PaymentLine(id: 1, method: mobile, amount: prefill, reference: '0045'),
      ]);
      expect(summary.status, CheckoutStatus.exact);
      expect(summary.payments.single.amount, totalVes);
    });

    test('pagar los bolívares sin redondear deja un restante', () {
      final summary = compute([
        PaymentLine(id: 1, method: mobile, amount: dec('670'), reference: '0045'),
      ]);

      expect(summary.status, CheckoutStatus.remaining);
      expect(summary.remainingVes, dec('7.52'));
    });

    test('pago mixto: los dólares cubren su parte y el resto va en bolívares redondeados', () {
      const cash = PaymentLine(id: 1, method: PaymentMethod.cashUsd);
      final usdLine = cash.copyWith(amount: () => dec('2.25'));

      final rest = CheckoutMath.prefillFor(
        method: mobile,
        totalUsd: totalUsd,
        totalVes: totalVes,
        rate: rate,
        lines: [usdLine],
      );

      expect(rest, dec('338.5'));
      final summary = compute([
        usdLine,
        PaymentLine(id: 2, method: mobile, amount: rest, reference: '0045'),
      ]);
      expect(summary.status, CheckoutStatus.exact);
    });
  });

  group('configuración de precios', () {
    late FakeExchangeRateRepository rates;

    Future<ProviderContainer> readyContainer() async {
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: sessionOverrides(
          auth: FakeAuthRepository(user: manager(), hasSession: true),
          branches: FakeBranchRepository([villaLibertad]),
          rates: rates,
        ),
      );
      addTearDown(container.dispose);
      await settledSession(container);
      await container.read(activeRateProvider.future);
      await container.read(pricingSettingsControllerProvider.future);
      return container;
    }

    setUp(() => rates = FakeExchangeRateRepository(dec('900')));

    test('por defecto se vende con el BCV y sin redondeo', () async {
      final container = await readyContainer();

      final settings = container.read(pricingSettingsControllerProvider).requireValue;
      expect(settings.rateMode, RateMode.bcv);
      expect(container.read(roundVesUpProvider), isFalse);
    });

    test('activar el redondeo lo aplica de inmediato en toda la app', () async {
      final container = await readyContainer();

      await container.read(pricingSettingsControllerProvider.notifier).setRoundVesUp(enabled: true);

      expect(container.read(roundVesUpProvider), isTrue);
      expect(rates.settings.roundVesUp, isTrue);
    });

    test('volver a la tasa del BCV trae su tasa como activa', () async {
      rates
        ..settings = const PricingSettings(rateMode: RateMode.manual)
        ..bcv = BcvRate(rate: dec('872.3927'), updatedAt: DateTime.utc(2026, 10, 6, 4));
      final container = await readyContainer();
      expect(container.read(activeRateProvider).value, dec('900'));

      await container.read(pricingSettingsControllerProvider.notifier).setRateMode(RateMode.bcv);

      expect(container.read(pricingSettingsControllerProvider).requireValue.rateMode, RateMode.bcv);
      expect(await container.read(activeRateProvider.future), dec('872.3927'));
    });

    test('si el backend rechaza el cambio, la configuración no se toca', () async {
      final container = await readyContainer();
      rates.settingsFailure = const Failure(
        code: 'bcv_rate_unavailable',
        message: 'No se pudo consultar la tasa del BCV.',
      );

      await expectLater(
        container.read(pricingSettingsControllerProvider.notifier).setRateMode(RateMode.manual),
        throwsA(isA<Failure>()),
      );
      expect(container.read(pricingSettingsControllerProvider).requireValue.rateMode, RateMode.bcv);
    });
  });

  group('lista de precios', () {
    test('agrupa por categoría y usa los bolívares que cobra la app', () {
      final groups = groupByCategory([stocked(chlorine, '5'), stocked(broom, '2')]);

      final text = buildPriceListText(
        branchName: 'Villa Libertad',
        groups: groups,
        rate: rate,
        roundUp: true,
      );

      expect(groups.map((g) => g.category.name), ['Accesorios', 'Líquidos']);
      expect(text, contains('Lista de precios — Villa Libertad'));
      expect(text, contains('ACCESORIOS\n• Escoba (und): \$ 4,50 / Bs 677,00'));
      expect(text, contains('LÍQUIDOS\n• Cloro (L): \$ 1,20 / Bs 181,00'));
    });
  });

  group('sticker de categoría', () {
    test('el producto trae el sticker de su categoría; vacío es automático', () {
      Map<String, dynamic> json(String? icon) => {
        'id': 1,
        'name': 'Cloro',
        'category': 7,
        'category_name': 'Limpieza',
        'category_icon': ?icon,
        'unit_of_measure': 'LITER',
        'cost_price_usd': '0.80',
        'sale_price_usd': '1.20',
        'active': true,
      };

      final chosen = ProductDto.fromJson(json('🧽')).toEntity().category;
      final automatic = ProductDto.fromJson(json(null)).toEntity().category;

      expect(chosen, const ProductCategory(id: 7, name: 'Limpieza', icon: '🧽'));
      expect(chosen.hasSticker, isTrue);
      expect(automatic.hasSticker, isFalse);
    });

    test('la categoría se lee con su sticker', () {
      final category = CategoryDto.fromJson({
        'id': 3,
        'name': 'Aromas',
        'icon': '🌸',
        'active': true,
      }).toEntity();

      expect((category.icon, category.active), ('🌸', true));
    });
  });
}
