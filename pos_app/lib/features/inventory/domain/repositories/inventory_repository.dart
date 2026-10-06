import 'package:pos_app/features/inventory/domain/entities/product.dart';

/// Contrato de catálogo e inventario. Los movimientos y el Kardex se añaden
/// en la fase de inventario.
abstract interface class InventoryRepository {
  /// Cantidad de productos activos de la sucursal en o por debajo de su stock mínimo.
  Future<int> fetchLowStockCount({required String branchCode});

  /// Catálogo completo (todas las páginas), ordenado por nombre.
  Future<List<Product>> fetchProducts({bool onlyActive = false});

  /// Existencias de la sucursal (todas las páginas).
  Future<List<BranchStock>> fetchBranchStock({required String branchCode});
}
