import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/domain/branch.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/network/paged_list.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/home/presentation/providers/dashboard_providers.dart';
import 'package:pos_app/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:pos_app/features/inventory/domain/entities/inventory_movement.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/providers/catalog_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_providers.g.dart';

/// Todas las categorías del catálogo, también las inactivas, por nombre.
/// Concentra las operaciones de un MANAGER sobre ellas.
@riverpod
class Categories extends _$Categories {
  @override
  Future<List<ProductCategory>> build() => ref.watch(inventoryRepositoryProvider).fetchCategories();

  /// Los productos llevan el nombre de su categoría: hay que volver a pedirlos.
  void _refreshDependents() {
    ref
      ..invalidateSelf()
      ..invalidate(inventoryCatalogProvider)
      ..invalidate(sellableCatalogProvider);
  }

  /// Crea una categoría; `icon` es su sticker, o vacío para el automático.
  /// Lanza `Failure`.
  Future<ProductCategory> create(String name, {String icon = ''}) async {
    final category = await ref.read(inventoryRepositoryProvider).createCategory(name, icon: icon);
    _refreshDependents();
    return category;
  }

  /// Cambia el nombre y el sticker de una categoría. Lanza `Failure`.
  Future<ProductCategory> save(int categoryId, {required String name, required String icon}) async {
    final category = await ref
        .read(inventoryRepositoryProvider)
        .updateCategory(categoryId, name: name, icon: icon);
    _refreshDependents();
    return category;
  }

  /// Activa o desactiva una categoría. Lanza `Failure`.
  Future<ProductCategory> setActive(int categoryId, {required bool active}) async {
    final category = await ref
        .read(inventoryRepositoryProvider)
        .updateCategory(categoryId, active: active);
    _refreshDependents();
    return category;
  }
}

/// Catálogo completo (también los productos inactivos) con su stock en la
/// sucursal activa. Es la fuente de la pestaña Inventario y concentra las
/// operaciones que lo modifican.
@riverpod
class InventoryCatalog extends _$InventoryCatalog {
  @override
  Future<List<StockedProduct>> build() async {
    final branch = ref.watch(activeBranchProvider);
    if (branch == null) return const [];
    final repository = ref.watch(inventoryRepositoryProvider);
    final (products, stock) = await (
      repository.fetchProducts(),
      repository.fetchBranchStock(branchCode: branch.code),
    ).wait;

    final stockByProduct = {for (final row in stock) row.productId: row};
    return [
      for (final product in products)
        StockedProduct(
          product: product,
          currentStock: stockByProduct[product.id]?.currentStock ?? Decimal.zero,
          minimumStock: stockByProduct[product.id]?.minimumStock ?? Decimal.zero,
        ),
    ];
  }

  /// Vuelve a pedir todo lo que depende del catálogo o del stock.
  void _refreshDependents() {
    ref
      ..invalidateSelf()
      ..invalidate(sellableCatalogProvider)
      ..invalidate(lowStockCountProvider)
      ..invalidate(movementHistoryProvider)
      ..invalidate(otherBranchesStockProvider);
  }

  /// Registra una entrada, una merma o un ajuste en la sucursal activa. En un
  /// ajuste, `quantity` es el stock contado. Devuelve `null` si el ajuste
  /// coincidía con el stock y no generó movimiento. Lanza `Failure`.
  Future<InventoryMovement?> registerMovement({
    required int productId,
    required MovementType type,
    required Decimal quantity,
    String notes = '',
  }) async {
    final branch = ref.read(activeBranchProvider)!;
    final movement = await ref
        .read(inventoryRepositoryProvider)
        .registerMovement(
          branchCode: branch.code,
          productId: productId,
          type: type,
          quantity: quantity,
          notes: notes,
        );
    _refreshDependents();
    return movement;
  }

  /// Cambia el stock mínimo en la sucursal activa (solo MANAGER). Lanza `Failure`.
  Future<void> setMinimumStock({required int productId, required Decimal minimumStock}) async {
    final branch = ref.read(activeBranchProvider)!;
    await ref
        .read(inventoryRepositoryProvider)
        .setMinimumStock(branchCode: branch.code, productId: productId, minimumStock: minimumStock);
    _refreshDependents();
  }

  /// Crea un producto o, con `productId`, modifica uno existente (solo MANAGER).
  /// Lanza `Failure`.
  Future<Product> saveProduct(ProductDraft draft, {int? productId}) async {
    final repository = ref.read(inventoryRepositoryProvider);
    final saved = productId == null
        ? await repository.createProduct(draft)
        : await repository.updateProduct(productId, draft);
    _refreshDependents();
    return saved;
  }

  /// Activa o desactiva un producto (solo MANAGER). Lanza `Failure`.
  Future<Product> toggleActive(int productId) async {
    final product = await ref.read(inventoryRepositoryProvider).toggleProductActive(productId);
    _refreshDependents();
    return product;
  }
}

/// Kardex de la sucursal activa, cargado página a página. Se puede acotar a
/// un producto y a un tipo de movimiento.
@riverpod
class MovementHistory extends _$MovementHistory {
  bool _loadingMore = false;
  int? _productId;
  MovementType? _type;

  @override
  Future<PagedList<InventoryMovement>> build({int? productId, MovementType? type}) async {
    _productId = productId;
    _type = type;
    final branch = ref.watch(activeBranchProvider);
    if (branch == null) return const PagedList(items: [], totalCount: 0, nextPage: null);
    final page = await ref
        .watch(inventoryRepositoryProvider)
        .fetchMovements(branchCode: branch.code, page: 1, productId: productId, type: type);
    return PagedList.first(page);
  }

  Future<void> loadMore() async {
    final current = state.value;
    final nextPage = current?.nextPage;
    final branch = ref.read(activeBranchProvider);
    if (current == null || nextPage == null || branch == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await ref
          .read(inventoryRepositoryProvider)
          .fetchMovements(
            branchCode: branch.code,
            page: nextPage,
            productId: _productId,
            type: _type,
          );
      state = AsyncData(current.append(page));
    } finally {
      _loadingMore = false;
    }
  }
}

/// Stock de cada producto en las demás tiendas activas, por código de tienda.
///
/// El backend no tiene un endpoint para comparar tiendas: se pide el
/// inventario de cada una en paralelo. Solo sirve a quien tiene acceso a
/// todas (un MANAGER sin tienda asignada); al resto el backend se lo niega.
@riverpod
Future<Map<Branch, Map<int, Decimal>>> otherBranchesStock(Ref ref) async {
  final active = ref.watch(activeBranchProvider);
  final branches = ref.watch(sessionControllerProvider.select((session) => session.branches));
  final others = [
    for (final branch in branches)
      if (branch.code != active?.code) branch,
  ];
  final repository = ref.watch(inventoryRepositoryProvider);
  final stocks = await Future.wait([
    for (final branch in others) repository.fetchBranchStock(branchCode: branch.code),
  ]);
  return {
    for (final (index, branch) in others.indexed)
      branch: {for (final row in stocks[index]) row.productId: row.currentStock},
  };
}
