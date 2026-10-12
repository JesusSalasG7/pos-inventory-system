import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';

/// Convierte los strings decimales de la API a `Decimal` en los DTOs.
///
/// El backend siempre envía montos, cantidades y tasas como string.
class DecimalConverter implements JsonConverter<Decimal, String> {
  const DecimalConverter();

  @override
  Decimal fromJson(String json) => Decimal.parse(json);

  @override
  String toJson(Decimal object) => object.toString();
}

/// Variante para campos que pueden llegar en `null`.
class NullableDecimalConverter implements JsonConverter<Decimal?, String?> {
  const NullableDecimalConverter();

  @override
  Decimal? fromJson(String? json) => json == null ? null : Decimal.parse(json);

  @override
  String? toJson(Decimal? object) => object?.toString();
}

/// Convierte a `Decimal` los números de JSON de las estadísticas, el único
/// módulo del backend que no envía los decimales como string.
///
/// Pasa por el texto del número, así `26.92` sigue siendo exactamente `26.92`.
class NumberDecimalConverter implements JsonConverter<Decimal, num> {
  const NumberDecimalConverter();

  @override
  Decimal fromJson(num json) => Decimal.parse(json.toString());

  @override
  num toJson(Decimal object) => object.toDouble();
}

/// Variante para campos que pueden llegar en `null`.
class NullableNumberDecimalConverter implements JsonConverter<Decimal?, num?> {
  const NullableNumberDecimalConverter();

  @override
  Decimal? fromJson(num? json) => json == null ? null : Decimal.parse(json.toString());

  @override
  num? toJson(Decimal? object) => object?.toDouble();
}
