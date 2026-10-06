// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExchangeRateDto _$ExchangeRateDtoFromJson(Map<String, dynamic> json) => _ExchangeRateDto(
  id: (json['id'] as num).toInt(),
  usdToVesRate: const DecimalConverter().fromJson(json['usd_to_ves_rate'] as String),
  createdBy: (json['created_by'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ExchangeRateDtoToJson(_ExchangeRateDto instance) => <String, dynamic>{
  'id': instance.id,
  'usd_to_ves_rate': const DecimalConverter().toJson(instance.usdToVesRate),
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
};
