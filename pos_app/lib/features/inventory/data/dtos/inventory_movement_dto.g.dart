// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_movement_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryMovementDto _$InventoryMovementDtoFromJson(Map<String, dynamic> json) =>
    _InventoryMovementDto(
      id: (json['id'] as num).toInt(),
      product: (json['product'] as num).toInt(),
      branch: json['branch'] as String,
      movementType: json['movement_type'] as String,
      quantity: const DecimalConverter().fromJson(json['quantity'] as String),
      stockBefore: const DecimalConverter().fromJson(json['stock_before'] as String),
      stockAfter: const DecimalConverter().fromJson(json['stock_after'] as String),
      user: (json['user'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      sale: (json['sale'] as num?)?.toInt(),
      notes: json['notes'] as String? ?? '',
    );

Map<String, dynamic> _$InventoryMovementDtoToJson(_InventoryMovementDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'branch': instance.branch,
      'movement_type': instance.movementType,
      'quantity': const DecimalConverter().toJson(instance.quantity),
      'stock_before': const DecimalConverter().toJson(instance.stockBefore),
      'stock_after': const DecimalConverter().toJson(instance.stockAfter),
      'user': instance.user,
      'created_at': instance.createdAt.toIso8601String(),
      'sale': instance.sale,
      'notes': instance.notes,
    };
