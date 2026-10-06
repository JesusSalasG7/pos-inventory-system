import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/inventory/data/datasources/inventory_remote_datasource.dart';
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
}
