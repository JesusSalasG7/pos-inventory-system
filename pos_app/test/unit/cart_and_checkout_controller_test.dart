import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/inventory/presentation/providers/catalog_providers.dart';
import 'package:pos_app/features/pos/domain/checkout_math.dart';
import 'package:pos_app/features/pos/presentation/providers/cart_controller.dart';
import 'package:pos_app/features/pos/presentation/providers/checkout_controller.dart';

import '../mocks/fake_repositories.dart';

void main() {
  final chlorine = product(1, 'Cloro', price: '1.20', unit: UnitOfMeasure.liter);
  final broom = product(2, 'Escoba', price: '4.50');
  final detergent = product(3, 'Detergente', price: '2.75', unit: UnitOfMeasure.kilogram);

  late FakeSalesRepository sales;
  late FakeInventoryRepository inventory;

  Future<ProviderContainer> readyContainer() async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: manager(), hasSession: true),
        branches: FakeBranchRepository([villaLibertad, lasAmericas]),
        preference: InMemoryBranchPreferenceStorage('VILLA_LIBERTAD'),
        rate: dec('150'),
        sales: sales,
        inventory: inventory,
      ),
    );
    addTearDown(container.dispose);
    container
      ..listen(cartControllerProvider, (_, _) {})
      ..listen(checkoutControllerProvider, (_, _) {});
    await settledSession(container);
    await container.read(activeRateProvider.future);
    return container;
  }

  setUp(() {
    sales = FakeSalesRepository()..prices.addAll({1: dec('1.20'), 2: dec('4.50'), 3: dec('2.75')});
    inventory = FakeInventoryRepository()
      ..seed('VILLA_LIBERTAD', [
        stocked(chlorine, '48.5', minimum: '10'),
        stocked(broom, '3'),
        stocked(detergent, '0'),
      ]);
  });

  group('catálogo para vender', () {
    test('cruza productos activos con el stock de la tienda', () async {
      final container = await readyContainer();

      final catalog = await container.read(sellableCatalogProvider.future);

      expect(catalog.map((item) => item.product.name), ['Cloro', 'Escoba', 'Detergente']);
      expect(catalog.first.currentStock, dec('48.5'));
      expect(catalog.first.minimumStock, dec('10'));
    });

    test('un producto sin fila de inventario en la tienda cuenta como stock cero', () async {
      inventory.stock.removeWhere((row) => row.productId == 2);
      final container = await readyContainer();

      final catalog = await container.read(sellableCatalogProvider.future);

      expect(catalog.firstWhere((item) => item.product.id == 2).currentStock, dec('0'));
    });
  });

  group('carrito', () {
    test('acepta cantidades decimales y calcula los totales como el backend', () async {
      final container = await readyContainer();
      final cart = container.read(cartControllerProvider.notifier)
        ..setQuantity(stocked(chlorine, '48.5'), dec('2.5'))
        ..setQuantity(stocked(broom, '3'), dec('1'));

      final state = container.read(cartControllerProvider);
      expect(state.itemCount, 2);
      expect(state.items.first.subtotalUsd, dec('3.00'));
      expect(state.totalUsd, dec('7.50'));

      // Cada subtotal se redondea antes de sumar: 0,333 × 1,20 = 0,3996 → 0,40.
      cart.setQuantity(stocked(chlorine, '48.5'), dec('0.333'));
      expect(container.read(cartControllerProvider).totalUsd, dec('4.90'));
    });

    test('no deja superar el stock disponible', () async {
      final container = await readyContainer();
      container.read(cartControllerProvider.notifier).setQuantity(stocked(broom, '3'), dec('10'));

      expect(container.read(cartControllerProvider).quantityOf(2), dec('3'));
    });

    test('un producto sin stock no entra, y cero lo quita', () async {
      final container = await readyContainer();
      final cart = container.read(cartControllerProvider.notifier)
        ..setQuantity(stocked(detergent, '0'), dec('1'));
      expect(container.read(cartControllerProvider).isEmpty, isTrue);

      cart
        ..setQuantity(stocked(broom, '3'), dec('2'))
        ..setQuantity(stocked(broom, '3'), dec('0'));
      expect(container.read(cartControllerProvider).isEmpty, isTrue);
    });

    test('conserva el orden al cambiar una cantidad', () async {
      final container = await readyContainer();
      container.read(cartControllerProvider.notifier)
        ..setQuantity(stocked(chlorine, '48.5'), dec('1'))
        ..setQuantity(stocked(broom, '3'), dec('1'))
        ..setItemQuantity(1, dec('4'));

      final names = container.read(cartControllerProvider).items.map((i) => i.product.name);
      expect(names, ['Cloro', 'Escoba']);
      expect(container.read(cartControllerProvider).quantityOf(1), dec('4'));
    });

    test('se vacía al cambiar de tienda', () async {
      final container = await readyContainer();
      container.read(cartControllerProvider.notifier).setQuantity(stocked(broom, '3'), dec('1'));

      await container.read(sessionControllerProvider.notifier).selectBranch(lasAmericas);

      expect(container.read(cartControllerProvider).isEmpty, isTrue);
    });
  });

  group('cobro', () {
    Future<ProviderContainer> containerWithCart() async {
      final container = await readyContainer();
      container.read(cartControllerProvider.notifier)
        ..setQuantity(stocked(chlorine, '48.5'), dec('2.5'))
        ..setQuantity(stocked(broom, '3'), dec('1'))
        ..setCustomer(taxId: 'V12345678', name: 'Ana Pérez');
      return container;
    }

    test('cada línea nueva se prellena con lo que falta, en su moneda', () async {
      final container = await containerWithCart();
      final checkout = container.read(checkoutControllerProvider.notifier)
        ..addLine(PaymentMethod.cashUsd);
      final first = container.read(checkoutControllerProvider).lines.single;
      expect(first.amount, dec('7.50'));

      checkout
        ..updateAmount(first.id, dec('5'))
        ..addLine(PaymentMethod.mobilePayment);
      expect(container.read(checkoutControllerProvider).lines.last.amount, dec('375.00'));
      expect(checkout.summary()!.status, CheckoutStatus.incomplete);
    });

    test('venta con pago mixto: envía la venta y vacía el carrito', () async {
      final container = await containerWithCart();
      final checkout = container.read(checkoutControllerProvider.notifier)
        ..addLine(PaymentMethod.cashUsd);
      final usdLine = container.read(checkoutControllerProvider).lines.single;
      checkout
        ..updateAmount(usdLine.id, dec('5'))
        ..addLine(PaymentMethod.mobilePayment);
      checkout.updateReference(container.read(checkoutControllerProvider).lines.last.id, '004512');

      final receipt = await checkout.submit();

      final sent = sales.createdSales.single;
      expect(sent.branchCode, 'VILLA_LIBERTAD');
      expect(sent.customerTaxId, 'V12345678');
      expect(sent.items.map((i) => (i.productId, i.quantity)), [(1, dec('2.5')), (2, dec('1'))]);
      expect(sent.payments.map((p) => (p.method, p.amount, p.approvalReference)), [
        (PaymentMethod.cashUsd, dec('5.00'), ''),
        (PaymentMethod.mobilePayment, dec('375.00'), '004512'),
      ]);
      // El comprobante usa los datos del backend y recuerda los nombres.
      expect(receipt.sale.totalUsd, dec('7.50'));
      expect(receipt.sale.exchangeRateAtInvoice, dec('150'));
      expect(receipt.productName(1), 'Cloro');
      expect(container.read(cartControllerProvider).isEmpty, isTrue);
      expect(container.read(checkoutControllerProvider).lines, isEmpty);
    });

    test('con vuelto, a la API va el monto exacto', () async {
      final container = await containerWithCart();
      final checkout = container.read(checkoutControllerProvider.notifier)
        ..addLine(PaymentMethod.cashUsd);
      checkout.updateAmount(container.read(checkoutControllerProvider).lines.single.id, dec('10'));

      expect(checkout.summary()!.changeAmount, dec('2.50'));
      await checkout.submit();

      expect(sales.createdSales.single.payments.single.amount, dec('7.50'));
    });

    test('tras vender se vuelve a pedir el catálogo (el stock cambió)', () async {
      final container = await containerWithCart();
      container.listen(sellableCatalogProvider, (_, _) {});
      await container.read(sellableCatalogProvider.future);
      final callsBefore = inventory.catalogCalls;

      final checkout = container.read(checkoutControllerProvider.notifier)
        ..addLine(PaymentMethod.cashUsd);
      await checkout.submit();
      await container.read(sellableCatalogProvider.future);

      expect(inventory.catalogCalls, callsBefore + 1);
    });

    test('no envía si los pagos no cuadran', () async {
      final container = await containerWithCart();
      final checkout = container.read(checkoutControllerProvider.notifier)
        ..addLine(PaymentMethod.cashUsd);
      checkout.updateAmount(container.read(checkoutControllerProvider).lines.single.id, dec('3'));

      expect(checkout.submit, throwsStateError);
      expect(sales.createdSales, isEmpty);
    });

    test('stock insuficiente: marca las líneas con el disponible del backend', () async {
      final container = await containerWithCart();
      sales.saleFailure = const Failure(
        code: 'insufficient_stock',
        message: 'No hay stock suficiente.',
        meta: {
          'items': [
            {'product_id': 1, 'requested': '2.500', 'available': '1.000'},
          ],
        },
      );
      final checkout = container.read(checkoutControllerProvider.notifier)
        ..addLine(PaymentMethod.cashUsd);

      await expectLater(checkout.submit(), throwsA(isA<Failure>()));

      final cart = container.read(cartControllerProvider);
      expect(cart.items.first.availableStock, dec('1.000'));
      expect(cart.items.first.exceedsStock, isTrue);
      expect(cart.items.last.exceedsStock, isFalse);
      expect(cart.hasStockIssues, isTrue);
      expect(container.read(checkoutControllerProvider).isSubmitting, isFalse);
    });

    test('producto inactivo: quita la línea del carrito', () async {
      final container = await containerWithCart();
      sales.saleFailure = const Failure(
        code: 'inactive_product',
        message: 'El producto no existe o está inactivo.',
        meta: {
          'product_ids': [2],
        },
      );
      final checkout = container.read(checkoutControllerProvider.notifier)
        ..addLine(PaymentMethod.cashUsd);

      await expectLater(checkout.submit(), throwsA(isA<Failure>()));

      final cart = container.read(cartControllerProvider);
      expect(cart.items.map((i) => i.product.name), ['Cloro']);
    });

    test('sin caja abierta: el carrito se conserva', () async {
      final container = await containerWithCart();
      sales.saleFailure = const Failure(code: 'no_open_session', message: 'Sin caja.');
      final checkout = container.read(checkoutControllerProvider.notifier)
        ..addLine(PaymentMethod.cashUsd);

      await expectLater(
        checkout.submit(),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'no_open_session')),
      );

      expect(container.read(cartControllerProvider).itemCount, 2);
      expect(container.read(checkoutControllerProvider).lines, hasLength(1));
    });
  });
}
