/// Utilidades de dinero, cantidades y tasas.
///
/// Todo se opera con `Decimal`: `double` está prohibido para estos valores
/// porque introduce errores de representación binaria. Las precisiones y el
/// redondeo (mitad hacia arriba) replican `pos_backend/core/money.py`.
library;

import 'package:decimal/decimal.dart';

const int moneyScale = 2;
const int quantityScale = 3;
const int rateScale = 4;

/// Diferencia máxima admitida por el backend entre el total y los pagos.
final Decimal paymentToleranceUsd = Decimal.parse('0.01');

/// Convierte un string decimal de la API. Lanza `FormatException` si no es válido.
Decimal parseDecimal(String value) => Decimal.parse(value.trim());

/// Convierte texto escrito por el usuario; acepta coma o punto como separador decimal.
Decimal? tryParseUserDecimal(String? value) {
  if (value == null) return null;
  final normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return Decimal.tryParse(normalized);
}

/// Redondea un importe a 2 decimales.
Decimal quantizeMoney(Decimal amount) => amount.round(scale: moneyScale);

/// Redondea una cantidad de stock a 3 decimales.
Decimal quantizeQuantity(Decimal quantity) => quantity.round(scale: quantityScale);

/// Redondea una tasa de cambio a 4 decimales.
Decimal quantizeRate(Decimal rate) => rate.round(scale: rateScale);

/// Divide con precisión suficiente para redondear después a cualquier escala usada.
Decimal divide(Decimal dividend, Decimal divisor) {
  if (divisor == Decimal.zero) {
    throw ArgumentError.value(divisor, 'divisor', 'No se puede dividir entre cero.');
  }
  return (dividend / divisor).toDecimal(scaleOnInfinitePrecision: 12);
}

/// Formato de la API para importes: `"12.50"`.
String moneyToApi(Decimal amount) => quantizeMoney(amount).toStringAsFixed(moneyScale);

/// Formato de la API para cantidades: `"2.500"`.
String quantityToApi(Decimal quantity) => quantizeQuantity(quantity).toStringAsFixed(quantityScale);

/// Formato de la API para tasas: `"872.3927"`.
String rateToApi(Decimal rate) => quantizeRate(rate).toStringAsFixed(rateScale);

Decimal minDecimal(Decimal a, Decimal b) => a <= b ? a : b;

Decimal maxDecimal(Decimal a, Decimal b) => a >= b ? a : b;
