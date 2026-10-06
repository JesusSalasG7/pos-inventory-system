import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_app/core/currency/decimal_converter.dart';

part 'exchange_rate_dto.freezed.dart';
part 'exchange_rate_dto.g.dart';

/// Tasa tal como la devuelven `exchange-rates/` y `exchange-rates/current/`.
@freezed
abstract class ExchangeRateDto with _$ExchangeRateDto {
  const factory ExchangeRateDto({
    required int id,
    @DecimalConverter() required Decimal usdToVesRate,
    required int createdBy,
    required DateTime createdAt,
  }) = _ExchangeRateDto;

  factory ExchangeRateDto.fromJson(Map<String, dynamic> json) => _$ExchangeRateDtoFromJson(json);
}
