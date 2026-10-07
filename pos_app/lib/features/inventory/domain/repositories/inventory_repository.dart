import 'package:decimal/decimal.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/inventory/domain/entities/inventory_movement.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';

/// Contrato de catálogo, categorías, existencias y Kardex.
abstract interface class InventoryRepository {
  /// Todas las categorías (también las inactivas), ordenadas por nombre.
  Future<List<ProductCategory>> fetchCategories();

  /// Crea una categoría activa (solo MANAGER). `icon` es su sticker (emoji);
  /// vacío deja que la app le asigne un ícono.
  Future<ProductCategory> createCategory(String name, {String icon = ''});

  /// Cambia el nombre, el sticker o el estado de una categoría (solo MANAGER).
  /// Las categorías no se borran: se desactivan.
  Future<ProductCategory> updateCategory(
    int categoryId, {
    String? name,
    String? icon,
    bool? active,
  });

  /// Cantidad de productos activos de la sucursal en o por debajo de su stock mínimo.
  Future<int> fetchLowStockCount({required String branchCode});

  /// Catálogo completo (todas las páginas), ordenado por nombre.
  Future<List<Product>> fetchProducts({bool onlyActive = false});

  /// Existencias de la sucursal (todas las páginas).
  Future<List<BranchStock>> fetchBranchStock({required String branchCode});

  /// Da de alta un producto en el catálogo global (solo MANAGER).
  Future<Product> createProduct(ProductDraft draft);

  /// Modifica un producto del catálogo global (solo MANAGER).
  Future<Product> updateProduct(int productId, ProductDraft draft);

  /// Activa o desactiva un producto (solo MANAGER). Los productos no se borran.
  Future<Product> toggleProductActive(int productId);

  /// Cambia el stock mínimo de un producto en una sucursal (solo MANAGER).
  Future<BranchStock> setMinimumStock({
    required String branchCode,
    required int productId,
    required Decimal minimumStock,
  });

  /// Página del Kardex de la sucursal, del movimiento más reciente al más antiguo.
  Future<Paginated<InventoryMovement>> fetchMovements({
    required String branchCode,
    required int page,
    int? productId,
    MovementType? type,
  });

  /// Registra una entrada, una merma o un ajuste. En un ajuste, `quantity` es
  /// el stock contado. Devuelve `null` si el ajuste coincide con el stock
  /// actual: el backend no inserta ningún movimiento.
  Future<InventoryMovement?> registerMovement({
    required String branchCode,
    required int productId,
    required MovementType type,
    required Decimal quantity,
    String notes = '',
  });
}
