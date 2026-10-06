import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
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
