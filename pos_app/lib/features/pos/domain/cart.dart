import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/currency/currency_converter.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/currency/ves_pricing.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';

/// Línea del carrito: un producto, la cantidad pedida y el stock que había
/// en la sucursal cuando se agregó (o el que informó el backend al rechazar la venta).
@immutable
class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    required this.availableStock,
    required this.minimumStock,
  });

  final Product product;
  final Decimal quantity;
  final Decimal availableStock;
  final Decimal minimumStock;

  /// Mismo cálculo que el backend: cantidad × precio, redondeado a 2 decimales.
  Decimal get subtotalUsd => quantizeMoney(quantity * product.salePriceUsd);

  /// Subtotal en VES, con el redondeo hacia arriba si el negocio lo usa.
  Decimal subtotalVes(Decimal rate, {required bool roundUp}) =>
      VesPricing.lineSubtotal(quantity, product.salePriceUsd, rate, roundUp: roundUp);

  /// La cantidad pedida ya no cabe en el stock disponible.
  bool get exceedsStock => quantity > availableStock;

  CartItem copyWith({Decimal? quantity, Decimal? availableStock}) => CartItem(
    product: product,
    quantity: quantity ?? this.quantity,
    availableStock: availableStock ?? this.availableStock,
    minimumStock: minimumStock,
  );
}

/// Carrito de la venta en curso. Sus totales son informativos: los
/// definitivos son los que devuelve el backend al registrar la venta.
@immutable
class Cart {
  const Cart({this.items = const [], this.customerTaxId = '', this.customerName = ''});

  /// Líneas en el orden en que se agregaron.
  final List<CartItem> items;
  final String customerTaxId;
  final String customerName;

  bool get isEmpty => items.isEmpty;

  /// Número de productos distintos.
  int get itemCount => items.length;

  /// Suma de los subtotales ya redondeados, igual que el backend.
  Decimal get totalUsd =>
      quantizeMoney(items.fold(Decimal.zero, (sum, item) => sum + item.subtotalUsd));

  /// Total en VES. Con el redondeo activo es la suma de los subtotales ya
  /// redondeados, igual que el backend; sin él, el total en USD convertido.
  Decimal totalVes(Decimal rate, {required bool roundUp}) => roundUp
      ? items.fold(Decimal.zero, (sum, item) => sum + item.subtotalVes(rate, roundUp: true))
      : CurrencyConverter.usdToVes(totalUsd, rate);

  bool get hasStockIssues => items.any((item) => item.exceedsStock);

  Decimal quantityOf(int productId) {
    for (final item in items) {
      if (item.product.id == productId) return item.quantity;
    }
    return Decimal.zero;
  }

  Cart copyWith({List<CartItem>? items, String? customerTaxId, String? customerName}) => Cart(
    items: items ?? this.items,
    customerTaxId: customerTaxId ?? this.customerTaxId,
    customerName: customerName ?? this.customerName,
  );
}
