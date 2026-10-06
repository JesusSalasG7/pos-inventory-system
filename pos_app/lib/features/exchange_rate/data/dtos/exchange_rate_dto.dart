import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_app/core/currency/decimal_converter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';

part 'exchange_rate_dto.freezed.dart';
part 'exchange_rate_dto.g.dart';

/// Tasa tal como la devuelven `exchange-rates/` y `exchange-rates/current/`.
@freezed
abstract class ExchangeRateDto with _$ExchangeRateDto {
  const factory ExchangeRateDto({
    required int id,
    @DecimalConverter() required Decimal usdToVesRate,
    required String source,
    required DateTime createdAt,

    /// Fecha de calendario `YYYY-MM-DD`; `null` en las tasas manuales.
    String? effectiveDate,
    int? createdBy,
  }) = _ExchangeRateDto;

  const ExchangeRateDto._();

  factory ExchangeRateDto.fromJson(Map<String, dynamic> json) => _$ExchangeRateDtoFromJson(json);

  ExchangeRate toEntity() {
    final date = effectiveDate;
    return ExchangeRate(
      id: id,
      rate: usdToVesRate,
      source: RateSource.fromApi(source),
      effectiveDate: date == null ? null : DateTime.parse(date),
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}

/// Respuesta de `exchange-rates/bcv/`.
@freezed
abstract class BcvRateDto with _$BcvRateDto {
  const factory BcvRateDto({
    @DecimalConverter() required Decimal rate,
    required DateTime updatedAt,
  }) = _BcvRateDto;

  const BcvRateDto._();

  factory BcvRateDto.fromJson(Map<String, dynamic> json) => _$BcvRateDtoFromJson(json);

  BcvRate toEntity() => BcvRate(rate: rate, updatedAt: updatedAt);
}
