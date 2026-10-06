import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// Resumen de ventas de un periodo. Los totales en VES son la suma de lo
/// facturado con la tasa congelada de cada venta, no una conversión de hoy.
@immutable
class SalesSummary {
  const SalesSummary({required this.salesCount, required this.totalUsd, required this.totalVes});

  final int salesCount;
  final Decimal totalUsd;
  final Decimal totalVes;
}
