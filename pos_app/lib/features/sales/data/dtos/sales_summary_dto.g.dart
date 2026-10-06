// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SalesSummaryDto _$SalesSummaryDtoFromJson(Map<String, dynamic> json) => _SalesSummaryDto(
  salesCount: (json['sales_count'] as num).toInt(),
  totalUsd: const DecimalConverter().fromJson(json['total_usd'] as String),
  totalVes: const DecimalConverter().fromJson(json['total_ves'] as String),
);

Map<String, dynamic> _$SalesSummaryDtoToJson(_SalesSummaryDto instance) => <String, dynamic>{
  'sales_count': instance.salesCount,
  'total_usd': const DecimalConverter().toJson(instance.totalUsd),
  'total_ves': const DecimalConverter().toJson(instance.totalVes),
};
