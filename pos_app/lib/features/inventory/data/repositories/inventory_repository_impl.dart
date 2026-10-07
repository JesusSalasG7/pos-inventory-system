import 'package:decimal/decimal.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:pos_app/features/inventory/domain/entities/inventory_movement.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_repository_impl.g.dart';

@Riverpod(keepAlive: true)
InventoryRepository inventoryRepository(Ref ref) {
  return InventoryRepositoryImpl(InventoryRemoteDataSource(ref.watch(dioProvider)));
}

class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl(this._remote);

  final InventoryRemoteDataSource _remote;

  @override
  Future<int> fetchLowStockCount({required String branchCode}) {
    return Failure.guard(() => _remote.fetchLowStockCount(branchCode: branchCode));
  }

  @override
  Future<List<Product>> fetchProducts({bool onlyActive = false}) {
    return Failure.guard(() async {
      final dtos = await Paginated.fetchAll(
        (page) => _remote.fetchProducts(page: page, onlyActive: onlyActive),
      );
      return [for (final dto in dtos) dto.toEntity()];
    });
  }

  @override
  Future<List<BranchStock>> fetchBranchStock({required String branchCode}) {
    return Failure.guard(() async {
      final dtos = await Paginated.fetchAll(
        (page) => _remote.fetchBranchStock(branchCode: branchCode, page: page),
      );
      return [for (final dto in dtos) dto.toEntity()];
    });
  }

  @override
  Future<List<ProductCategory>> fetchCategories() {
    return Failure.guard(() async {
      final dtos = await Paginated.fetchAll((page) => _remote.fetchCategories(page: page));
      return [for (final dto in dtos) dto.toEntity()];
    });
  }

  @override
  Future<ProductCategory> createCategory(String name, {String icon = ''}) {
    return Failure.guard(
      () async => (await _remote.createCategory(name.trim(), icon: icon)).toEntity(),
    );
  }

  @override
  Future<ProductCategory> updateCategory(
    int categoryId, {
    String? name,
    String? icon,
    bool? active,
  }) {
    return Failure.guard(() async {
      final dto = await _remote.updateCategory(
        categoryId,
        name: name?.trim(),
        icon: icon,
        active: active,
      );
      return dto.toEntity();
    });
  }

  static Map<String, dynamic> _productBody(ProductDraft draft) => {
    'name': draft.name,
    'category': draft.categoryId,
    'unit_of_measure': draft.unit.apiValue,
    'cost_price_usd': moneyToApi(draft.costPriceUsd),
    'sale_price_usd': moneyToApi(draft.salePriceUsd),
  };

  @override
  Future<Product> createProduct(ProductDraft draft) {
    return Failure.guard(() async => (await _remote.createProduct(_productBody(draft))).toEntity());
  }

  @override
  Future<Product> updateProduct(int productId, ProductDraft draft) {
    return Failure.guard(
      () async => (await _remote.updateProduct(productId, _productBody(draft))).toEntity(),
    );
  }

  @override
  Future<Product> toggleProductActive(int productId) {
    return Failure.guard(() async => (await _remote.toggleProductActive(productId)).toEntity());
  }

  @override
  Future<BranchStock> setMinimumStock({
    required String branchCode,
    required int productId,
    required Decimal minimumStock,
  }) {
    return Failure.guard(() async {
      final dto = await _remote.setMinimumStock(
        branchCode: branchCode,
        productId: productId,
        minimumStock: minimumStock,
      );
      return dto.toEntity();
    });
  }

  @override
  Future<Paginated<InventoryMovement>> fetchMovements({
    required String branchCode,
    required int page,
    int? productId,
    MovementType? type,
  }) {
    return Failure.guard(() async {
      final dtos = await _remote.fetchMovements(
        branchCode: branchCode,
        page: page,
        productId: productId,
        movementType: type?.apiValue,
      );
      return dtos.map((dto) => dto.toEntity());
    });
  }

  @override
  Future<InventoryMovement?> registerMovement({
    required String branchCode,
    required int productId,
    required MovementType type,
    required Decimal quantity,
    String notes = '',
  }) {
    return Failure.guard(() async {
      final dto = await _remote.registerMovement(
        branchCode: branchCode,
        productId: productId,
        movementType: type.apiValue,
        quantity: quantity,
        notes: notes.trim(),
      );
      return dto?.toEntity();
    });
  }
}
