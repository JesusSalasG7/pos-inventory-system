import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/features/inventory/data/datasources/inventory_remote_datasource.dart';
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
}
