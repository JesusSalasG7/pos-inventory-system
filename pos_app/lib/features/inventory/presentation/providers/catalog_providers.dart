import 'package:decimal/decimal.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_providers.g.dart';

/// Productos activos con su stock en la sucursal activa, para vender.
///
/// `inventory/` no filtra ni trae precio o categoría, así que se piden el
/// catálogo y el inventario completos en paralelo y se cruzan aquí. Un
/// producto sin fila de inventario en la sucursal cuenta como stock cero.
@riverpod
Future<List<StockedProduct>> sellableCatalog(Ref ref) async {
  final branch = ref.watch(activeBranchProvider);
  if (branch == null) return const [];
  final repository = ref.watch(inventoryRepositoryProvider);
  final (products, stock) = await (
    repository.fetchProducts(onlyActive: true),
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
