import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_app/core/currency/decimal_converter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';

part 'statistics_dtos.freezed.dart';
part 'statistics_dtos.g.dart';

/// Fecha de calendario `yyyy-MM-dd`, sin hora ni zona.
DateTime _parseDay(String value) => DateTime.parse(value);

@freezed
abstract class PeriodDto with _$PeriodDto {
  const factory PeriodDto({required String dateFrom, required String dateTo}) = _PeriodDto;

  const PeriodDto._();

  factory PeriodDto.fromJson(Map<String, dynamic> json) => _$PeriodDtoFromJson(json);

  StatsPeriod toEntity() => StatsPeriod(from: _parseDay(dateFrom), to: _parseDay(dateTo));
}

@freezed
abstract class KpisDto with _$KpisDto {
  const factory KpisDto({
    @NumberDecimalConverter() required Decimal revenue,
    @NumberDecimalConverter() required Decimal profit,
    @NumberDecimalConverter() required Decimal margin,
    @NumberDecimalConverter() required Decimal units,
    required int salesCount,
    @NumberDecimalConverter() required Decimal averageTicket,
  }) = _KpisDto;

  const KpisDto._();

  factory KpisDto.fromJson(Map<String, dynamic> json) => _$KpisDtoFromJson(json);

  StatsKpis toEntity() => StatsKpis(
    revenue: revenue,
    profit: profit,
    margin: margin,
    units: units,
    salesCount: salesCount,
    averageTicket: averageTicket,
  );
}

@freezed
abstract class KpiChangesDto with _$KpiChangesDto {
  const factory KpiChangesDto({
    @NullableNumberDecimalConverter() Decimal? revenue,
    @NullableNumberDecimalConverter() Decimal? profit,
    @NullableNumberDecimalConverter() Decimal? margin,
    @NullableNumberDecimalConverter() Decimal? units,
    @NullableNumberDecimalConverter() Decimal? salesCount,
    @NullableNumberDecimalConverter() Decimal? averageTicket,
  }) = _KpiChangesDto;

  const KpiChangesDto._();

  factory KpiChangesDto.fromJson(Map<String, dynamic> json) => _$KpiChangesDtoFromJson(json);

  StatsKpiChanges toEntity() => StatsKpiChanges(
    revenue: revenue,
    profit: profit,
    margin: margin,
    units: units,
    salesCount: salesCount,
    averageTicket: averageTicket,
  );
}

/// Respuesta de `statistics/summary/`.
@freezed
abstract class SummaryDto with _$SummaryDto {
  const factory SummaryDto({
    required PeriodDto period,
    required PeriodDto previousPeriod,
    required KpisDto current,
    required KpisDto previous,
    required KpiChangesDto change,
  }) = _SummaryDto;

  const SummaryDto._();

  factory SummaryDto.fromJson(Map<String, dynamic> json) => _$SummaryDtoFromJson(json);

  StatsSummary toEntity() => StatsSummary(
    period: period.toEntity(),
    previousPeriod: previousPeriod.toEntity(),
    current: current.toEntity(),
    previous: previous.toEntity(),
    change: change.toEntity(),
  );
}

@freezed
abstract class SplitTotalsDto with _$SplitTotalsDto {
  const factory SplitTotalsDto({
    @NumberDecimalConverter() required Decimal revenue,
    @NumberDecimalConverter() required Decimal profit,
    @NumberDecimalConverter() required Decimal margin,
  }) = _SplitTotalsDto;

  const SplitTotalsDto._();

  factory SplitTotalsDto.fromJson(Map<String, dynamic> json) => _$SplitTotalsDtoFromJson(json);

  SplitTotals toEntity() => SplitTotals(revenue: revenue, profit: profit, margin: margin);
}

@freezed
abstract class PendingTotalsDto with _$PendingTotalsDto {
  const factory PendingTotalsDto({
    @NumberDecimalConverter() required Decimal revenue,
    @NumberDecimalConverter() required Decimal profit,
  }) = _PendingTotalsDto;

  factory PendingTotalsDto.fromJson(Map<String, dynamic> json) => _$PendingTotalsDtoFromJson(json);
}

/// Respuesta de `statistics/credit-breakdown/`.
@freezed
abstract class CreditBreakdownDto with _$CreditBreakdownDto {
  const factory CreditBreakdownDto({
    required SplitTotalsDto cash,
    required SplitTotalsDto credit,
    required PendingTotalsDto pending,
    @NumberDecimalConverter() required Decimal creditShare,
  }) = _CreditBreakdownDto;

  const CreditBreakdownDto._();

  factory CreditBreakdownDto.fromJson(Map<String, dynamic> json) =>
      _$CreditBreakdownDtoFromJson(json);

  CreditBreakdown toEntity() => CreditBreakdown(
    cash: cash.toEntity(),
    credit: credit.toEntity(),
    pendingRevenue: pending.revenue,
    pendingProfit: pending.profit,
    creditShare: creditShare,
  );
}

@freezed
abstract class GroupPerformanceDto with _$GroupPerformanceDto {
  const factory GroupPerformanceDto({
    int? id,
    required String name,
    @NumberDecimalConverter() required Decimal units,
    @NumberDecimalConverter() required Decimal revenue,
    @NumberDecimalConverter() required Decimal profit,
    @NumberDecimalConverter() required Decimal margin,
  }) = _GroupPerformanceDto;

  const GroupPerformanceDto._();

  factory GroupPerformanceDto.fromJson(Map<String, dynamic> json) =>
      _$GroupPerformanceDtoFromJson(json);

  GroupPerformance toEntity() => GroupPerformance(
    id: id,
    name: name,
    units: units,
    revenue: revenue,
    profit: profit,
    margin: margin,
  );
}

/// Respuesta de `statistics/groups/`.
@freezed
abstract class GroupReportDto with _$GroupReportDto {
  const factory GroupReportDto({required String level, required List<GroupPerformanceDto> groups}) =
      _GroupReportDto;

  const GroupReportDto._();

  factory GroupReportDto.fromJson(Map<String, dynamic> json) => _$GroupReportDtoFromJson(json);

  GroupReport toEntity() => GroupReport(
    level: GroupLevel.fromApi(level),
    groups: [for (final group in groups) group.toEntity()],
  );
}

/// Fila de `statistics/products/ranking/`.
@freezed
abstract class ProductPerformanceDto with _$ProductPerformanceDto {
  const factory ProductPerformanceDto({
    required int productId,
    required String name,
    required String unitOfMeasure,
    required String categoryName,
    String? subcategoryName,
    @NumberDecimalConverter() required Decimal units,
    @NumberDecimalConverter() required Decimal revenue,
    @NumberDecimalConverter() required Decimal profit,
    @NumberDecimalConverter() required Decimal margin,
  }) = _ProductPerformanceDto;

  const ProductPerformanceDto._();

  factory ProductPerformanceDto.fromJson(Map<String, dynamic> json) =>
      _$ProductPerformanceDtoFromJson(json);

  ProductPerformance toEntity() => ProductPerformance(
    productId: productId,
    name: name,
    unit: UnitOfMeasure.fromApi(unitOfMeasure),
    categoryName: categoryName,
    subcategoryName: subcategoryName,
    units: units,
    revenue: revenue,
    profit: profit,
    margin: margin,
  );
}

@freezed
abstract class MatrixPointDto with _$MatrixPointDto {
  const factory MatrixPointDto({
    required int productId,
    required String name,
    required String unitOfMeasure,
    @NumberDecimalConverter() required Decimal units,
    @NumberDecimalConverter() required Decimal revenue,
    @NumberDecimalConverter() required Decimal profit,
    @NumberDecimalConverter() required Decimal margin,
    required String quadrant,
  }) = _MatrixPointDto;

  const MatrixPointDto._();

  factory MatrixPointDto.fromJson(Map<String, dynamic> json) => _$MatrixPointDtoFromJson(json);

  MatrixPoint toEntity() => MatrixPoint(
    productId: productId,
    name: name,
    unit: UnitOfMeasure.fromApi(unitOfMeasure),
    units: units,
    revenue: revenue,
    profit: profit,
    margin: margin,
    quadrant: Quadrant.fromApi(quadrant),
  );
}

/// Respuesta de `statistics/matrix/`.
@freezed
abstract class MatrixDto with _$MatrixDto {
  const factory MatrixDto({
    @NumberDecimalConverter() required Decimal medianUnits,
    @NumberDecimalConverter() required Decimal medianMargin,
    required List<MatrixPointDto> products,
  }) = _MatrixDto;

  const MatrixDto._();

  factory MatrixDto.fromJson(Map<String, dynamic> json) => _$MatrixDtoFromJson(json);

  StatsMatrix toEntity() => StatsMatrix(
    medianUnits: medianUnits,
    medianMargin: medianMargin,
    products: [for (final point in products) point.toEntity()],
  );
}

@freezed
abstract class NoMovementItemDto with _$NoMovementItemDto {
  const factory NoMovementItemDto({
    required int productId,
    required String name,
    required String unitOfMeasure,
    @NumberDecimalConverter() required Decimal stock,
    String? lastSaleDate,
    @NumberDecimalConverter() required Decimal immobilizedCapital,
  }) = _NoMovementItemDto;

  const NoMovementItemDto._();

  factory NoMovementItemDto.fromJson(Map<String, dynamic> json) =>
      _$NoMovementItemDtoFromJson(json);

  NoMovementItem toEntity() {
    final lastSale = lastSaleDate;
    return NoMovementItem(
      productId: productId,
      name: name,
      unit: UnitOfMeasure.fromApi(unitOfMeasure),
      stock: stock,
      lastSaleDate: lastSale == null ? null : _parseDay(lastSale),
      immobilizedCapital: immobilizedCapital,
    );
  }
}

@freezed
abstract class RunningOutItemDto with _$RunningOutItemDto {
  const factory RunningOutItemDto({
    required int productId,
    required String name,
    required String unitOfMeasure,
    @NumberDecimalConverter() required Decimal stock,
    @NumberDecimalConverter() required Decimal daysLeft,
  }) = _RunningOutItemDto;

  const RunningOutItemDto._();

  factory RunningOutItemDto.fromJson(Map<String, dynamic> json) =>
      _$RunningOutItemDtoFromJson(json);

  RunningOutItem toEntity() => RunningOutItem(
    productId: productId,
    name: name,
    unit: UnitOfMeasure.fromApi(unitOfMeasure),
    stock: stock,
    daysLeft: daysLeft,
  );
}

/// Respuesta de `statistics/inventory-health/`.
@freezed
abstract class InventoryHealthDto with _$InventoryHealthDto {
  const factory InventoryHealthDto({
    @NumberDecimalConverter() required Decimal immobilizedCapitalTotal,
    required List<NoMovementItemDto> noMovement,
    required List<RunningOutItemDto> runningOut,
  }) = _InventoryHealthDto;

  const InventoryHealthDto._();

  factory InventoryHealthDto.fromJson(Map<String, dynamic> json) =>
      _$InventoryHealthDtoFromJson(json);

  InventoryHealth toEntity() => InventoryHealth(
    immobilizedCapitalTotal: immobilizedCapitalTotal,
    noMovement: [for (final item in noMovement) item.toEntity()],
    runningOut: [for (final item in runningOut) item.toEntity()],
  );
}
