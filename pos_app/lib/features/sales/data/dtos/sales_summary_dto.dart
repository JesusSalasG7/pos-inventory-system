import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_app/core/currency/decimal_converter.dart';
import 'package:pos_app/features/sales/domain/entities/sales_summary.dart';

part 'sales_summary_dto.freezed.dart';
part 'sales_summary_dto.g.dart';

/// Respuesta de `sales/reports/summary/`. `sales_count` es el único entero.
@freezed
abstract class SalesSummaryDto with _$SalesSummaryDto {
  const factory SalesSummaryDto({
    required int salesCount,
    @DecimalConverter() required Decimal totalUsd,
    @DecimalConverter() required Decimal totalVes,
  }) = _SalesSummaryDto;

  const SalesSummaryDto._();

  factory SalesSummaryDto.fromJson(Map<String, dynamic> json) => _$SalesSummaryDtoFromJson(json);

  SalesSummary toEntity() =>
      SalesSummary(salesCount: salesCount, totalUsd: totalUsd, totalVes: totalVes);
}
