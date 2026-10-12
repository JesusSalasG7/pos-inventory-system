// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PeriodDto _$PeriodDtoFromJson(Map<String, dynamic> json) =>
    _PeriodDto(dateFrom: json['date_from'] as String, dateTo: json['date_to'] as String);

Map<String, dynamic> _$PeriodDtoToJson(_PeriodDto instance) => <String, dynamic>{
  'date_from': instance.dateFrom,
  'date_to': instance.dateTo,
};

_KpisDto _$KpisDtoFromJson(Map<String, dynamic> json) => _KpisDto(
  revenue: const NumberDecimalConverter().fromJson(json['revenue'] as num),
  profit: const NumberDecimalConverter().fromJson(json['profit'] as num),
  margin: const NumberDecimalConverter().fromJson(json['margin'] as num),
  units: const NumberDecimalConverter().fromJson(json['units'] as num),
  salesCount: (json['sales_count'] as num).toInt(),
  averageTicket: const NumberDecimalConverter().fromJson(json['average_ticket'] as num),
);

Map<String, dynamic> _$KpisDtoToJson(_KpisDto instance) => <String, dynamic>{
  'revenue': const NumberDecimalConverter().toJson(instance.revenue),
  'profit': const NumberDecimalConverter().toJson(instance.profit),
  'margin': const NumberDecimalConverter().toJson(instance.margin),
  'units': const NumberDecimalConverter().toJson(instance.units),
  'sales_count': instance.salesCount,
  'average_ticket': const NumberDecimalConverter().toJson(instance.averageTicket),
};

_KpiChangesDto _$KpiChangesDtoFromJson(Map<String, dynamic> json) => _KpiChangesDto(
  revenue: const NullableNumberDecimalConverter().fromJson(json['revenue'] as num?),
  profit: const NullableNumberDecimalConverter().fromJson(json['profit'] as num?),
  margin: const NullableNumberDecimalConverter().fromJson(json['margin'] as num?),
  units: const NullableNumberDecimalConverter().fromJson(json['units'] as num?),
  salesCount: const NullableNumberDecimalConverter().fromJson(json['sales_count'] as num?),
  averageTicket: const NullableNumberDecimalConverter().fromJson(json['average_ticket'] as num?),
);

Map<String, dynamic> _$KpiChangesDtoToJson(_KpiChangesDto instance) => <String, dynamic>{
  'revenue': const NullableNumberDecimalConverter().toJson(instance.revenue),
  'profit': const NullableNumberDecimalConverter().toJson(instance.profit),
  'margin': const NullableNumberDecimalConverter().toJson(instance.margin),
  'units': const NullableNumberDecimalConverter().toJson(instance.units),
  'sales_count': const NullableNumberDecimalConverter().toJson(instance.salesCount),
  'average_ticket': const NullableNumberDecimalConverter().toJson(instance.averageTicket),
};

_SummaryDto _$SummaryDtoFromJson(Map<String, dynamic> json) => _SummaryDto(
  period: PeriodDto.fromJson(json['period'] as Map<String, dynamic>),
  previousPeriod: PeriodDto.fromJson(json['previous_period'] as Map<String, dynamic>),
  current: KpisDto.fromJson(json['current'] as Map<String, dynamic>),
  previous: KpisDto.fromJson(json['previous'] as Map<String, dynamic>),
  change: KpiChangesDto.fromJson(json['change'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SummaryDtoToJson(_SummaryDto instance) => <String, dynamic>{
  'period': instance.period.toJson(),
  'previous_period': instance.previousPeriod.toJson(),
  'current': instance.current.toJson(),
  'previous': instance.previous.toJson(),
  'change': instance.change.toJson(),
};

_SplitTotalsDto _$SplitTotalsDtoFromJson(Map<String, dynamic> json) => _SplitTotalsDto(
  revenue: const NumberDecimalConverter().fromJson(json['revenue'] as num),
  profit: const NumberDecimalConverter().fromJson(json['profit'] as num),
  margin: const NumberDecimalConverter().fromJson(json['margin'] as num),
);

Map<String, dynamic> _$SplitTotalsDtoToJson(_SplitTotalsDto instance) => <String, dynamic>{
  'revenue': const NumberDecimalConverter().toJson(instance.revenue),
  'profit': const NumberDecimalConverter().toJson(instance.profit),
  'margin': const NumberDecimalConverter().toJson(instance.margin),
};

_PendingTotalsDto _$PendingTotalsDtoFromJson(Map<String, dynamic> json) => _PendingTotalsDto(
  revenue: const NumberDecimalConverter().fromJson(json['revenue'] as num),
  profit: const NumberDecimalConverter().fromJson(json['profit'] as num),
);

Map<String, dynamic> _$PendingTotalsDtoToJson(_PendingTotalsDto instance) => <String, dynamic>{
  'revenue': const NumberDecimalConverter().toJson(instance.revenue),
  'profit': const NumberDecimalConverter().toJson(instance.profit),
};

_CreditBreakdownDto _$CreditBreakdownDtoFromJson(Map<String, dynamic> json) => _CreditBreakdownDto(
  cash: SplitTotalsDto.fromJson(json['cash'] as Map<String, dynamic>),
  credit: SplitTotalsDto.fromJson(json['credit'] as Map<String, dynamic>),
  pending: PendingTotalsDto.fromJson(json['pending'] as Map<String, dynamic>),
  creditShare: const NumberDecimalConverter().fromJson(json['credit_share'] as num),
);

Map<String, dynamic> _$CreditBreakdownDtoToJson(_CreditBreakdownDto instance) => <String, dynamic>{
  'cash': instance.cash.toJson(),
  'credit': instance.credit.toJson(),
  'pending': instance.pending.toJson(),
  'credit_share': const NumberDecimalConverter().toJson(instance.creditShare),
};

_GroupPerformanceDto _$GroupPerformanceDtoFromJson(Map<String, dynamic> json) =>
    _GroupPerformanceDto(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      units: const NumberDecimalConverter().fromJson(json['units'] as num),
      revenue: const NumberDecimalConverter().fromJson(json['revenue'] as num),
      profit: const NumberDecimalConverter().fromJson(json['profit'] as num),
      margin: const NumberDecimalConverter().fromJson(json['margin'] as num),
    );

Map<String, dynamic> _$GroupPerformanceDtoToJson(_GroupPerformanceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'units': const NumberDecimalConverter().toJson(instance.units),
      'revenue': const NumberDecimalConverter().toJson(instance.revenue),
      'profit': const NumberDecimalConverter().toJson(instance.profit),
      'margin': const NumberDecimalConverter().toJson(instance.margin),
    };

_GroupReportDto _$GroupReportDtoFromJson(Map<String, dynamic> json) => _GroupReportDto(
  level: json['level'] as String,
  groups: (json['groups'] as List<dynamic>)
      .map((e) => GroupPerformanceDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GroupReportDtoToJson(_GroupReportDto instance) => <String, dynamic>{
  'level': instance.level,
  'groups': instance.groups.map((e) => e.toJson()).toList(),
};

_ProductPerformanceDto _$ProductPerformanceDtoFromJson(Map<String, dynamic> json) =>
    _ProductPerformanceDto(
      productId: (json['product_id'] as num).toInt(),
      name: json['name'] as String,
      unitOfMeasure: json['unit_of_measure'] as String,
      categoryName: json['category_name'] as String,
      subcategoryName: json['subcategory_name'] as String?,
      units: const NumberDecimalConverter().fromJson(json['units'] as num),
      revenue: const NumberDecimalConverter().fromJson(json['revenue'] as num),
      profit: const NumberDecimalConverter().fromJson(json['profit'] as num),
      margin: const NumberDecimalConverter().fromJson(json['margin'] as num),
    );

Map<String, dynamic> _$ProductPerformanceDtoToJson(_ProductPerformanceDto instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'name': instance.name,
      'unit_of_measure': instance.unitOfMeasure,
      'category_name': instance.categoryName,
      'subcategory_name': instance.subcategoryName,
      'units': const NumberDecimalConverter().toJson(instance.units),
      'revenue': const NumberDecimalConverter().toJson(instance.revenue),
      'profit': const NumberDecimalConverter().toJson(instance.profit),
      'margin': const NumberDecimalConverter().toJson(instance.margin),
    };

_MatrixPointDto _$MatrixPointDtoFromJson(Map<String, dynamic> json) => _MatrixPointDto(
  productId: (json['product_id'] as num).toInt(),
  name: json['name'] as String,
  unitOfMeasure: json['unit_of_measure'] as String,
  units: const NumberDecimalConverter().fromJson(json['units'] as num),
  revenue: const NumberDecimalConverter().fromJson(json['revenue'] as num),
  profit: const NumberDecimalConverter().fromJson(json['profit'] as num),
  margin: const NumberDecimalConverter().fromJson(json['margin'] as num),
  quadrant: json['quadrant'] as String,
);

Map<String, dynamic> _$MatrixPointDtoToJson(_MatrixPointDto instance) => <String, dynamic>{
  'product_id': instance.productId,
  'name': instance.name,
  'unit_of_measure': instance.unitOfMeasure,
  'units': const NumberDecimalConverter().toJson(instance.units),
  'revenue': const NumberDecimalConverter().toJson(instance.revenue),
  'profit': const NumberDecimalConverter().toJson(instance.profit),
  'margin': const NumberDecimalConverter().toJson(instance.margin),
  'quadrant': instance.quadrant,
};

_MatrixDto _$MatrixDtoFromJson(Map<String, dynamic> json) => _MatrixDto(
  medianUnits: const NumberDecimalConverter().fromJson(json['median_units'] as num),
  medianMargin: const NumberDecimalConverter().fromJson(json['median_margin'] as num),
  products: (json['products'] as List<dynamic>)
      .map((e) => MatrixPointDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MatrixDtoToJson(_MatrixDto instance) => <String, dynamic>{
  'median_units': const NumberDecimalConverter().toJson(instance.medianUnits),
  'median_margin': const NumberDecimalConverter().toJson(instance.medianMargin),
  'products': instance.products.map((e) => e.toJson()).toList(),
};

_NoMovementItemDto _$NoMovementItemDtoFromJson(Map<String, dynamic> json) => _NoMovementItemDto(
  productId: (json['product_id'] as num).toInt(),
  name: json['name'] as String,
  unitOfMeasure: json['unit_of_measure'] as String,
  stock: const NumberDecimalConverter().fromJson(json['stock'] as num),
  lastSaleDate: json['last_sale_date'] as String?,
  immobilizedCapital: const NumberDecimalConverter().fromJson(json['immobilized_capital'] as num),
);

Map<String, dynamic> _$NoMovementItemDtoToJson(_NoMovementItemDto instance) => <String, dynamic>{
  'product_id': instance.productId,
  'name': instance.name,
  'unit_of_measure': instance.unitOfMeasure,
  'stock': const NumberDecimalConverter().toJson(instance.stock),
  'last_sale_date': instance.lastSaleDate,
  'immobilized_capital': const NumberDecimalConverter().toJson(instance.immobilizedCapital),
};

_RunningOutItemDto _$RunningOutItemDtoFromJson(Map<String, dynamic> json) => _RunningOutItemDto(
  productId: (json['product_id'] as num).toInt(),
  name: json['name'] as String,
  unitOfMeasure: json['unit_of_measure'] as String,
  stock: const NumberDecimalConverter().fromJson(json['stock'] as num),
  daysLeft: const NumberDecimalConverter().fromJson(json['days_left'] as num),
);

Map<String, dynamic> _$RunningOutItemDtoToJson(_RunningOutItemDto instance) => <String, dynamic>{
  'product_id': instance.productId,
  'name': instance.name,
  'unit_of_measure': instance.unitOfMeasure,
  'stock': const NumberDecimalConverter().toJson(instance.stock),
  'days_left': const NumberDecimalConverter().toJson(instance.daysLeft),
};

_InventoryHealthDto _$InventoryHealthDtoFromJson(Map<String, dynamic> json) => _InventoryHealthDto(
  immobilizedCapitalTotal: const NumberDecimalConverter().fromJson(
    json['immobilized_capital_total'] as num,
  ),
  noMovement: (json['no_movement'] as List<dynamic>)
      .map((e) => NoMovementItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  runningOut: (json['running_out'] as List<dynamic>)
      .map((e) => RunningOutItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$InventoryHealthDtoToJson(_InventoryHealthDto instance) => <String, dynamic>{
  'immobilized_capital_total': const NumberDecimalConverter().toJson(
    instance.immobilizedCapitalTotal,
  ),
  'no_movement': instance.noMovement.map((e) => e.toJson()).toList(),
  'running_out': instance.runningOut.map((e) => e.toJson()).toList(),
};
