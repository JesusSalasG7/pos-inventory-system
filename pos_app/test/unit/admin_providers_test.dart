import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/branches/presentation/providers/branches_provider.dart';
import 'package:pos_app/features/inventory/presentation/providers/catalog_providers.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';
import 'package:pos_app/features/sales/presentation/providers/sales_history_providers.dart';
import 'package:pos_app/features/users/presentation/providers/users_provider.dart';

import '../mocks/fake_repositories.dart';

void main() {
  late FakeInventoryRepository inventory;
  late FakeSalesRepository sales;
  late FakeBranchRepository branches;
  late FakeUsersRepository users;

  Future<ProviderContainer> readyContainer() async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: manager(), hasSession: true),
        branches: branches,
        preference: InMemoryBranchPreferenceStorage('VILLA_LIBERTAD'),
        rate: dec('150'),
        inventory: inventory,
        sales: sales,
        users: users,
      ),
    );
    addTearDown(container.dispose);
    container
      ..listen(categoriesProvider, (_, _) {})
      ..listen(inventoryCatalogProvider, (_, _) {})
      ..listen(sellableCatalogProvider, (_, _) {})
      ..listen(allBranchesProvider, (_, _) {})
      ..listen(usersProvider, (_, _) {});
    await settledSession(container);
    return container;
  }

  Sale saleAt(int id, DateTime createdAt, {String branchCode = 'VILLA_LIBERTAD'}) => Sale(
    id: id,
    cashSessionId: 1,
    userId: 1,
    branchCode: branchCode,
    customerTaxId: '',
    customerName: '',
    exchangeRateAtInvoice: dec('150'),
    totalUsd: dec('2.00'),
    totalVes: dec('300.00'),
    createdAt: createdAt,
    details: const [],
    payments: const [],
  );

  setUp(() {
    inventory = FakeInventoryRepository()
      ..seed('VILLA_LIBERTAD', [stocked(product(1, 'Cloro'), '5')]);
    sales = FakeSalesRepository();
    branches = FakeBranchRepository([villaLibertad, lasAmericas]);
    users = FakeUsersRepository([manager(), supervisor()]);
  });

  group('categorías', () {
    test('se listan por nombre, también las inactivas', () async {
      inventory.categories.add(const ProductCategory(id: 4, name: 'Descontinuados', active: false));
      final container = await readyContainer();

      final categories = await container.read(categoriesProvider.future);

      expect(categories.map((c) => c.name), ['Accesorios', 'Descontinuados', 'Líquidos', 'Polvos']);
      expect(categories[1].active, isFalse);
    });

    test('crear una categoría la deja disponible y no admite nombres repetidos', () async {
      final container = await readyContainer();
      final notifier = container.read(categoriesProvider.notifier);

      final created = await notifier.create('  Aromatizantes ');

      expect(created.name, 'Aromatizantes');
      expect(await container.read(categoriesProvider.future), contains(created));
      await expectLater(
        notifier.create('aromatizantes'),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'category_name_taken')),
      );
    });

    test('cambiar nombre y sticker de una categoría actualiza sus productos', () async {
      final container = await readyContainer();
      await container.read(sellableCatalogProvider.future);

      await container
          .read(categoriesProvider.notifier)
          .save(liquids.id, name: 'Desinfectantes', icon: '🧴');

      final catalog = await container.read(inventoryCatalogProvider.future);
      final sellable = await container.read(sellableCatalogProvider.future);
      expect(catalog.single.product.category.name, 'Desinfectantes');
      expect(sellable.single.product.category.name, 'Desinfectantes');
      expect(sellable.single.product.category.icon, '🧴');
    });

    test('desactivar una categoría no toca sus productos', () async {
      final container = await readyContainer();

      final category = await container
          .read(categoriesProvider.notifier)
          .setActive(liquids.id, active: false);

      expect(category.active, isFalse);
      final catalog = await container.read(inventoryCatalogProvider.future);
      expect(catalog.single.product.category.id, liquids.id);
    });
  });

  group('ventas por día', () {
    // 6 de octubre de 2026 en Caracas (UTC−4): de las 04:00 UTC a las 03:59 UTC del día 7.
    final day = DateTime(2026, 10, 6);

    test('el día de Caracas va de medianoche a medianoche, extremos incluidos', () {
      expect(DateFormatter.startOfCalendarDay(day), DateTime.utc(2026, 10, 6, 4));
      expect(
        DateFormatter.endOfCalendarDay(day),
        DateTime.utc(2026, 10, 7, 4).subtract(const Duration(microseconds: 1)),
      );
    });

    test('solo trae las ventas de ese día y de la tienda activa', () async {
      sales.sales.addAll([
        saleAt(4, DateTime.utc(2026, 10, 7, 4, 30)), // ya es día 7 en Caracas
        saleAt(3, DateTime.utc(2026, 10, 7, 3, 30)), // 23:30 del día 6
        saleAt(2, DateTime.utc(2026, 10, 6, 15), branchCode: 'LAS_AMERICAS'),
        saleAt(1, DateTime.utc(2026, 10, 6, 4)), // medianoche exacta del día 6
        saleAt(0, DateTime.utc(2026, 10, 6, 3, 59)), // todavía día 5
      ]);
      final container = await readyContainer();

      final history = await container.read(salesHistoryProvider(day).future);
      await container.read(daySalesSummaryProvider(day).future);

      expect(history.items.map((sale) => sale.id), [3, 1]);
      expect(sales.lastBranchCode, 'VILLA_LIBERTAD');
      expect(sales.lastDateFrom, DateTime.utc(2026, 10, 6, 4));
    });

    test('carga más ventas página a página', () async {
      sales
        ..pageSize = 2
        ..sales.addAll([
          for (var id = 5; id >= 1; id--) saleAt(id, DateTime.utc(2026, 10, 6, 12, id)),
        ]);
      final container = await readyContainer();
      final provider = salesHistoryProvider(day);
      container.listen(provider, (_, _) {});

      expect((await container.read(provider.future)).items, hasLength(2));
      await container.read(provider.notifier).loadMore();
      await container.read(provider.notifier).loadMore();

      final loaded = container.read(provider).requireValue;
      expect(loaded.items.map((sale) => sale.id), [5, 4, 3, 2, 1]);
      expect(loaded.hasMore, isFalse);
    });
  });

  group('tiendas', () {
    test('crear una tienda la suma a la lista de la sesión', () async {
      final container = await readyContainer();

      await container.read(allBranchesProvider.notifier).create(code: 'CENTRO', name: 'Centro');

      final session = container.read(sessionControllerProvider);
      expect(session.status, SessionStatus.ready);
      expect(session.branches.map((b) => b.code), contains('CENTRO'));
      expect(await container.read(allBranchesProvider.future), hasLength(3));
    });

    test('renombrar la tienda de trabajo actualiza la cabecera', () async {
      final container = await readyContainer();

      await container.read(allBranchesProvider.notifier).rename('VILLA_LIBERTAD', 'Villa Nueva');

      expect(container.read(activeBranchProvider)!.name, 'Villa Nueva');
    });

    test('una tienda desactivada sale de la sesión pero sigue en la administración', () async {
      final container = await readyContainer();

      await container.read(allBranchesProvider.notifier).setActive('LAS_AMERICAS', active: false);

      expect(container.read(sessionControllerProvider).branches.map((b) => b.code), [
        'VILLA_LIBERTAD',
      ]);
      final all = await container.read(allBranchesProvider.future);
      expect(all.firstWhere((b) => b.code == 'LAS_AMERICAS').active, isFalse);
    });

    test('si el backend rechaza el cambio, la sesión no se toca', () async {
      final container = await readyContainer();
      branches.updateFailure = const Failure(
        code: 'branch_has_open_sessions',
        message: 'La tienda tiene cajas abiertas.',
      );

      await expectLater(
        container.read(allBranchesProvider.notifier).setActive('LAS_AMERICAS', active: false),
        throwsA(isA<Failure>()),
      );
      expect(container.read(sessionControllerProvider).branches, hasLength(2));
    });
  });

  group('usuarios', () {
    test('se listan por nombre', () async {
      final container = await readyContainer();

      final list = await container.read(usersProvider.future);

      expect(list.map((u) => u.fullName), ['Ana Gerente', 'Luis Supervisor']);
    });

    test('crear un supervisor lo asigna a su tienda', () async {
      final container = await readyContainer();

      final created = await container
          .read(usersProvider.notifier)
          .create(
            username: 'caja2',
            password: 'clave-segura',
            fullName: 'Marta Caja',
            role: UserRole.supervisor,
            assignedBranch: 'LAS_AMERICAS',
          );

      expect(created.assignedBranch, 'LAS_AMERICAS');
      expect(users.passwords[created.id], 'clave-segura');
      expect(await container.read(usersProvider.future), hasLength(3));
    });

    test('editarse a sí mismo actualiza el usuario de la sesión', () async {
      final container = await readyContainer();
      final me = container.read(currentUserProvider)!;

      await container
          .read(usersProvider.notifier)
          .save(
            me.id,
            fullName: 'Ana María Gerente',
            role: me.role,
            assignedBranch: me.assignedBranch,
            isActive: true,
          );

      expect(container.read(currentUserProvider)!.fullName, 'Ana María Gerente');
      // Sin contraseña nueva, la anterior se conserva.
      expect(users.passwords, isEmpty);
    });
  });
}
