import 'package:decimal/decimal.dart';
import 'package:pos_app/core/currency/currency_converter.dart';
import 'package:pos_app/core/currency/money.dart';

/// Diferencia del arqueo, calculada igual que `cash_count_service` en el backend.
///
/// Es una estimación para mostrar en vivo mientras se cuenta: la definitiva es
/// la que devuelve el backend al cerrar la caja.
abstract final class CashCount {
  /// (contado USD − esperado USD) + (contado VES − esperado VES) convertido a
  /// USD con la tasa activa. Positiva significa sobrante; negativa, faltante.
  static Decimal differenceUsd({
    required Decimal countedUsd,
    required Decimal countedVes,
    required Decimal expectedUsd,
    required Decimal expectedVes,
    required Decimal usdToVesRate,
  }) {
    final differenceUsd = countedUsd - expectedUsd;
    final differenceVes = countedVes - expectedVes;
    return quantizeMoney(differenceUsd + CurrencyConverter.vesToUsd(differenceVes, usdToVesRate));
  }
}
