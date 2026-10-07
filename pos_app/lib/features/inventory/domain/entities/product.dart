import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';

/// Producto del catálogo global, compartido por todas las sucursales.
@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.costPriceUsd,
    required this.salePriceUsd,
    required this.active,
  });

  final int id;
  final String name;
  final ProductCategory category;
  final UnitOfMeasure unit;
  final Decimal costPriceUsd;
  final Decimal salePriceUsd;
  final bool active;

  @override
  bool operator ==(Object other) =>
      other is Product &&
      other.id == id &&
      other.name == name &&
      other.category == category &&
      other.unit == unit &&
      other.costPriceUsd == costPriceUsd &&
      other.salePriceUsd == salePriceUsd &&
      other.active == active;

  @override
  int get hashCode => Object.hash(id, name, category, unit, costPriceUsd, salePriceUsd, active);
}

/// Existencias de un producto en una sucursal.
@immutable
class BranchStock {
  const BranchStock({
    required this.productId,
    required this.productName,
    required this.branchCode,
    required this.currentStock,
    required this.minimumStock,
  });

  final int productId;
  final String productName;
  final String branchCode;
  final Decimal currentStock;
  final Decimal minimumStock;
}

/// Producto con su stock en la sucursal activa. El backend los sirve por
/// separado (`products/` e `inventory/`); la app los cruza por `product`.
@immutable
class StockedProduct {
  const StockedProduct({
    required this.product,
    required this.currentStock,
    required this.minimumStock,
  });

  final Product product;

  /// Cero si el producto no tiene fila de inventario en la sucursal.
  final Decimal currentStock;
  final Decimal minimumStock;
}

/// Categorías de los productos de una lista, sin repetir y por nombre: las
/// opciones del filtro por categoría.
List<ProductCategory> categoriesOf(Iterable<StockedProduct> items) {
  final byId = {for (final item in items) item.product.category.id: item.product.category};
  return byId.values.toList()..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

/// Datos editables de un producto, para darlo de alta o modificarlo.
@immutable
class ProductDraft {
  const ProductDraft({
    required this.name,
    required this.categoryId,
    required this.unit,
    required this.costPriceUsd,
    required this.salePriceUsd,
  });

  final String name;
  final int categoryId;
  final UnitOfMeasure unit;
  final Decimal costPriceUsd;
  final Decimal salePriceUsd;
}
