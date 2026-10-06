import 'package:decimal/decimal.dart';

import 'package:pos_app/core/currency/money.dart';

/// Conversión USD ↔ VES con una tasa dada (VES por 1 USD).
///
/// Replica `usd_to_ves` y `ves_to_usd` del backend para que los totales
/// informativos de la app coincidan con los que calcula el servidor.
abstract final class CurrencyConverter {
  static Decimal usdToVes(Decimal amountUsd, Decimal usdToVesRate) {
    return quantizeMoney(amountUsd * _positiveRate(usdToVesRate));
  }

  static Decimal vesToUsd(Decimal amountVes, Decimal usdToVesRate) {
    return quantizeMoney(divide(amountVes, _positiveRate(usdToVesRate)));
  }

  static Decimal _positiveRate(Decimal rate) {
    if (rate <= Decimal.zero) {
      throw ArgumentError.value(rate, 'rate', 'La tasa de cambio debe ser mayor que cero.');
    }
    return rate;
  }
}
