import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_app/core/currency/decimal_converter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/inventory/domain/entities/inventory_movement.dart';

part 'inventory_movement_dto.freezed.dart';
part 'inventory_movement_dto.g.dart';

/// Renglón de `inventory/movements/`. Producto, usuario y venta llegan como id.
@freezed
abstract class InventoryMovementDto with _$InventoryMovementDto {
  const factory InventoryMovementDto({
    required int id,
    required int product,
    required String branch,
    required String movementType,
    @DecimalConverter() required Decimal quantity,
    @DecimalConverter() required Decimal stockBefore,
    @DecimalConverter() required Decimal stockAfter,
    required int user,
    required DateTime createdAt,
    int? sale,
    @Default('') String notes,
  }) = _InventoryMovementDto;

  const InventoryMovementDto._();

  factory InventoryMovementDto.fromJson(Map<String, dynamic> json) =>
      _$InventoryMovementDtoFromJson(json);

  InventoryMovement toEntity() => InventoryMovement(
    id: id,
    productId: product,
    branchCode: branch,
    type: MovementType.fromApi(movementType),
    quantity: quantity,
    stockBefore: stockBefore,
    stockAfter: stockAfter,
    userId: user,
    saleId: sale,
    notes: notes,
    createdAt: createdAt,
  );
}
