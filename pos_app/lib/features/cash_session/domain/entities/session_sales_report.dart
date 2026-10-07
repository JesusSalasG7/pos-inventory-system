import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/domain/enums.dart';

/// Resumen de lo vendido en una caja: totales, cobros por forma de pago,
/// inversión (costo de lo vendido) y ganancia.
///
/// Todo lo calcula el backend. Los bolívares usan la tasa congelada de cada
/// venta y el costo es el que tenía el producto al facturar.
@immutable
class SessionSalesReport {
  const SessionSalesReport({
    required this.salesCount,
    required this.totalUsd,
    required this.totalVes,
    required this.costUsd,
    required this.costVes,
    required this.profitUsd,
    required this.profitVes,
    required this.payments,
    required this.products,
  });

  final int salesCount;
  final Decimal totalUsd;
  final Decimal totalVes;

  /// Inversión: lo que costaron los productos vendidos.
  final Decimal costUsd;
  final Decimal costVes;

  /// Ganancia: total vendido menos inversión. Negativa si se vendió bajo el costo.
  final Decimal profitUsd;
  final Decimal profitVes;
  final List<PaymentTotal> payments;

  /// Productos vendidos, del que más vendió al que menos.
  final List<ProductSales> products;
}

/// Total cobrado con una forma de pago, en la moneda de esa forma de pago.
@immutable
class PaymentTotal {
  const PaymentTotal({required this.method, required this.currency, required this.amount});

  final PaymentMethod method;
  final Currency currency;
  final Decimal amount;
}

/// Lo vendido de un producto en la caja.
@immutable
class ProductSales {
  const ProductSales({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.salesUsd,
    required this.salesVes,
    required this.costUsd,
    required this.costVes,
    required this.profitUsd,
    required this.profitVes,
  });

  final int productId;
  final String productName;
  final Decimal quantity;
  final Decimal salesUsd;
  final Decimal salesVes;
  final Decimal costUsd;
  final Decimal costVes;
  final Decimal profitUsd;
  final Decimal profitVes;
}
