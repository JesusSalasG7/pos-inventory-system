// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductDto _$ProductDtoFromJson(Map<String, dynamic> json) => _ProductDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  category: json['category'] as String,
  unitOfMeasure: json['unit_of_measure'] as String,
  costPriceUsd: const DecimalConverter().fromJson(json['cost_price_usd'] as String),
  salePriceUsd: const DecimalConverter().fromJson(json['sale_price_usd'] as String),
  active: json['active'] as bool,
);

Map<String, dynamic> _$ProductDtoToJson(_ProductDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'unit_of_measure': instance.unitOfMeasure,
  'cost_price_usd': const DecimalConverter().toJson(instance.costPriceUsd),
  'sale_price_usd': const DecimalConverter().toJson(instance.salePriceUsd),
  'active': instance.active,
};

_BranchStockDto _$BranchStockDtoFromJson(Map<String, dynamic> json) => _BranchStockDto(
  id: (json['id'] as num).toInt(),
  product: (json['product'] as num).toInt(),
  productName: json['product_name'] as String,
  branch: json['branch'] as String,
  currentStock: const DecimalConverter().fromJson(json['current_stock'] as String),
  minimumStock: const DecimalConverter().fromJson(json['minimum_stock'] as String),
);

Map<String, dynamic> _$BranchStockDtoToJson(_BranchStockDto instance) => <String, dynamic>{
  'id': instance.id,
  'product': instance.product,
  'product_name': instance.productName,
  'branch': instance.branch,
  'current_stock': const DecimalConverter().toJson(instance.currentStock),
  'minimum_stock': const DecimalConverter().toJson(instance.minimumStock),
};
