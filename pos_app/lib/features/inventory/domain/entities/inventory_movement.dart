import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/domain/enums.dart';

/// Renglón del Kardex: un cambio de stock de un producto en una sucursal.
///
/// El Kardex es de solo inserción: un error se corrige con un ajuste, nunca
/// editando ni borrando un movimiento.
@immutable
class InventoryMovement {
  const InventoryMovement({
    required this.id,
    required this.productId,
    required this.branchCode,
    required this.type,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.userId,
    required this.notes,
    required this.createdAt,
    this.saleId,
  });

  final int id;
  final int productId;
  final String branchCode;
  final MovementType type;

  /// Siempre positiva; el sentido lo dan el tipo y el stock antes y después.
  final Decimal quantity;
  final Decimal stockBefore;
  final Decimal stockAfter;
  final int userId;

  /// Venta que originó el movimiento; `null` en los movimientos manuales.
  final int? saleId;
  final String notes;
  final DateTime createdAt;

  /// Variación del stock con signo: positiva si entró, negativa si salió.
  Decimal get delta => stockAfter - stockBefore;
}
