import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// Deuda que abrió una venta a crédito. Se lleva y se descuenta en USD.
@immutable
class Credit {
  const Credit({
    required this.id,
    required this.saleId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.branchCode,
    required this.amountUsd,
    required this.balanceUsd,
    required this.dueDate,
    required this.isOverdue,
    required this.createdAt,
    this.paidAt,
  });

  final int id;
  final int saleId;
  final int customerId;
  final String customerName;
  final String customerPhone;
  final String branchCode;

  /// Lo que quedó a crédito al vender.
  final Decimal amountUsd;

  /// Lo que falta por cobrar.
  final Decimal balanceUsd;

  /// Último día del plazo (fecha de calendario, sin hora).
  final DateTime dueDate;

  /// Según el backend: tiene saldo y el plazo ya pasó.
  final bool isOverdue;
  final DateTime createdAt;
  final DateTime? paidAt;

  bool get isPaid => balanceUsd <= Decimal.zero;
}
