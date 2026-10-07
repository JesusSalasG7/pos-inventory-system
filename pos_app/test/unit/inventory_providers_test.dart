import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/features/inventory/data/dtos/inventory_movement_dto.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/providers/catalog_providers.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';

import '../mocks/fake_repositories.dart';

void main() {
  final chlorine = product(1, 'Cloro', price: '1.20', unit: UnitOfMeasure.liter);
  final broom = product(2, 'Escoba', price: '4.50');
  final oldSoap = product(3, 'Jabón viejo', active: false);

  late FakeInventoryRepository inventory;

  Future<ProviderContainer> readyContainer() async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: manager(), hasSession: true),
        branches: FakeBranchRepository([villaLibertad, lasAmericas]),
        preference: InMemoryBranchPreferenceStorage('VILLA_LIBERTAD'),
        rate: dec('150'),
        inventory: inventory,
      ),
    );
    addTearDown(container.dispose);
    container
      ..listen(inventoryCatalogProvider, (_, _) {})
      ..listen(sellableCatalogProvider, (_, _) {});
    await settledSession(container);
    return container;
  }

  StockedProduct find(List<StockedProduct> catalog, int productId) =>
      catalog.firstWhere((item) => item.product.id == productId);

  setUp(() {
    inventory = FakeInventoryRepository()
      ..seed('VILLA_LIBERTAD', [
        stocked(chlorine, '48.5', minimum: '10'),
        stocked(broom, '3'),
        stocked(oldSoap, '2'),
      ])
      ..seedStock('LAS_AMERICAS', {1: '7.25'});
  });

  group('catálogo de inventario', () {
    test('incluye los productos inactivos, a diferencia del catálogo para vender', () async {
      final container = await readyContainer();

      final all = await container.read(inventoryCatalogProvider.future);
      final sellable = await container.read(sellableCatalogProvider.future);

      expect(all.map((item) => item.product.name), ['Cloro', 'Escoba', 'Jabón viejo']);
      expect(sellable.map((item) => item.product.name), ['Cloro', 'Escoba']);
      expect(find(all, 1).currentStock, dec('48.5'));
    });

    test('desactivar un producto lo saca del catálogo para vender', () async {
      final container = await readyContainer();
      await container.read(sellableCatalogProvider.future);

      final product = await container.read(inventoryCatalogProvider.notifier).toggleActive(2);

      expect(product.active, isFalse);
      final sellable = await container.read(sellableCatalogProvider.future);
      expect(sellable.map((item) => item.product.name), ['Cloro']);
    });

    test('crear y editar un producto refresca el catálogo', () async {
      final container = await readyContainer();
      final notifier = container.read(inventoryCatalogProvider.notifier);
      final draft = ProductDraft(
        name: 'Suavizante',
        categoryId: liquids.id,
        unit: UnitOfMeasure.liter,
        costPriceUsd: dec('1.10'),
        salePriceUsd: dec('2.00'),
      );

      final created = await notifier.saveProduct(draft);
      await notifier.saveProduct(
        ProductDraft(
          name: 'Suavizante azul',
          categoryId: draft.categoryId,
          unit: draft.unit,
          costPriceUsd: draft.costPriceUsd,
          salePriceUsd: dec('2.40'),
        ),
        productId: created.id,
      );

      final catalog = await container.read(inventoryCatalogProvider.future);
      final saved = find(catalog, created.id);
      expect(saved.product.name, 'Suavizante azul');
      expect(saved.product.salePriceUsd, dec('2.40'));
      // Recién creado no tiene fila de inventario: stock cero.
      expect(saved.currentStock, dec('0'));
    });
  });

  group('movimientos manuales', () {
    test('una entrada suma al stock de la tienda activa y queda en el Kardex', () async {
      final container = await readyContainer();
      await container.read(inventoryCatalogProvider.future);

      final movement = await container
          .read(inventoryCatalogProvider.notifier)
          .registerMovement(
            productId: 1,
            type: MovementType.entry,
            quantity: dec('11.5'),
            notes: 'Factura 88',
          );

      expect(movement!.stockAfter, dec('60'));
      expect(movement.delta, dec('11.5'));
      final catalog = await container.read(inventoryCatalogProvider.future);
      expect(find(catalog, 1).currentStock, dec('60'));
      final sellable = await container.read(sellableCatalogProvider.future);
      expect(find(sellable, 1).currentStock, dec('60'));
      // La otra tienda no se toca.
      expect(inventory.stockOf('LAS_AMERICAS', 1)!.currentStock, dec('7.25'));

      final history = await container.read(movementHistoryProvider(productId: 1).future);
      expect(history.items.single.notes, 'Factura 88');
    });

    test('en un ajuste la cantidad es el stock contado', () async {
      final container = await readyContainer();

      final movement = await container
          .read(inventoryCatalogProvider.notifier)
          .registerMovement(productId: 2, type: MovementType.adjustment, quantity: dec('1'));

      expect(movement!.stockBefore, dec('3'));
      expect(movement.stockAfter, dec('1'));
      expect(movement.delta, dec('-2'));
    });

    test('un ajuste igual al stock no registra nada', () async {
      final container = await readyContainer();

      final movement = await container
          .read(inventoryCatalogProvider.notifier)
          .registerMovement(productId: 2, type: MovementType.adjustment, quantity: dec('3'));

      expect(movement, isNull);
      expect(inventory.movements, isEmpty);
    });

    test('una merma mayor que el stock falla y no cambia nada', () async {
      final container = await readyContainer();

      await expectLater(
        container
            .read(inventoryCatalogProvider.notifier)
            .registerMovement(productId: 2, type: MovementType.waste, quantity: dec('5')),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'insufficient_stock')),
      );
      expect(inventory.stockOf('VILLA_LIBERTAD', 2)!.currentStock, dec('3'));
    });

    test('cambiar el stock mínimo se refleja en el catálogo', () async {
      final container = await readyContainer();

      await container
          .read(inventoryCatalogProvider.notifier)
          .setMinimumStock(productId: 2, minimumStock: dec('5'));

      final catalog = await container.read(inventoryCatalogProvider.future);
      expect(find(catalog, 2).minimumStock, dec('5'));
    });
  });

  group('Kardex', () {
    test('carga página a página y filtra por tipo', () async {
      inventory.pageSize = 2;
      final container = await readyContainer();
      final notifier = container.read(inventoryCatalogProvider.notifier);
      for (final quantity in ['1', '2', '3']) {
        await notifier.registerMovement(
          productId: 1,
          type: MovementType.entry,
          quantity: dec(quantity),
        );
      }
      await notifier.registerMovement(productId: 2, type: MovementType.waste, quantity: dec('1'));

      final all = movementHistoryProvider();
      container.listen(all, (_, _) {});
      final firstPage = await container.read(all.future);
      expect(firstPage.items, hasLength(2));
      expect(firstPage.totalCount, 4);
      // El más reciente va primero.
      expect(firstPage.items.first.type, MovementType.waste);

      await container.read(all.notifier).loadMore();
      final loaded = container.read(all).requireValue;
      expect(loaded.items, hasLength(4));
      expect(loaded.hasMore, isFalse);

      final wastes = await container.read(movementHistoryProvider(type: MovementType.waste).future);
      expect(wastes.items.single.productId, 2);
    });

    test('el DTO lee un movimiento de venta y uno manual sin nota', () {
      final sale = InventoryMovementDto.fromJson({
        'id': 9,
        'product': 1,
        'branch': 'VILLA_LIBERTAD',
        'movement_type': 'SALE',
        'quantity': '2.500',
        'stock_before': '48.500',
        'stock_after': '46.000',
        'user': 2,
        'sale': 31,
        'notes': '',
        'created_at': '2026-10-06T10:15:00-04:00',
      }).toEntity();
      final manual = InventoryMovementDto.fromJson({
        'id': 10,
        'product': 1,
        'branch': 'VILLA_LIBERTAD',
        'movement_type': 'ENTRY',
        'quantity': '5.000',
        'stock_before': '46.000',
        'stock_after': '51.000',
        'user': 1,
        'sale': null,
        'created_at': '2026-10-06T11:00:00-04:00',
      }).toEntity();

      expect(sale.type, MovementType.sale);
      expect(sale.saleId, 31);
      expect(sale.delta, dec('-2.5'));
      expect(manual.saleId, isNull);
      expect(manual.notes, isEmpty);
      expect(manual.createdAt.toUtc(), DateTime.utc(2026, 10, 6, 15));
    });
  });

  test('el stock de las demás tiendas excluye a la tienda activa', () async {
    final container = await readyContainer();

    final stock = await container.read(otherBranchesStockProvider.future);

    expect(stock.keys, [lasAmericas]);
    expect(stock[lasAmericas]![1], dec('7.25'));
    expect(stock[lasAmericas]![2], isNull);
  });
}
