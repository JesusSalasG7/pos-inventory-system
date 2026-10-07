import 'package:decimal/decimal.dart';

import 'package:pos_app/core/currency/currency_converter.dart';
import 'package:pos_app/core/currency/money.dart';

/// Precios en bolívares, con el redondeo hacia arriba opcional del negocio.
///
/// Replica `sale_calculator` del backend: con el redondeo activo, el precio
/// unitario en VES se sube al bolívar entero y el subtotal de cada línea
/// también. Los importes en USD nunca cambian.
abstract final class VesPricing {
  /// Redondea hacia arriba al bolívar entero: `180,37` → `181`.
  static Decimal ceilVes(Decimal amountVes) => amountVes.ceil();

  /// Precio de una unidad en VES.
  static Decimal unitPrice(Decimal priceUsd, Decimal rate, {required bool roundUp}) =>
      roundUp ? ceilVes(priceUsd * rate) : CurrencyConverter.usdToVes(priceUsd, rate);

  /// Subtotal en VES de una línea (cantidad × precio).
  static Decimal lineSubtotal(
    Decimal quantity,
    Decimal priceUsd,
    Decimal rate, {
    required bool roundUp,
  }) {
    if (!roundUp) return CurrencyConverter.usdToVes(quantizeMoney(quantity * priceUsd), rate);
    return ceilVes(quantity * unitPrice(priceUsd, rate, roundUp: true));
  }

  /// VES que equivalen a 1 USD al cobrar una venta.
  ///
  /// Normalmente es la tasa. Si el total en VES se redondeó, quien paga en
  /// bolívares paga ese total: los pagos en VES se convierten con la
  /// proporción real de la venta para que pagar el total cuadre exactamente.
  static Decimal paymentRate({
    required Decimal totalUsd,
    required Decimal totalVes,
    required Decimal rate,
  }) {
    if (totalUsd <= Decimal.zero || totalVes == CurrencyConverter.usdToVes(totalUsd, rate)) {
      return rate;
    }
    return divide(totalVes, totalUsd);
  }
}
