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
