/// Contrato de inventario. El catálogo, el stock por sede, los movimientos y
/// el Kardex se añaden en las fases de POS e inventario.
abstract interface class InventoryRepository {
  /// Cantidad de productos activos de la sucursal en o por debajo de su stock mínimo.
  Future<int> fetchLowStockCount({required String branchCode});
}
