import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/domain/enums.dart';

/// Turno de caja: desde la apertura hasta el arqueo y cierre.
@immutable
class CashSession {
  const CashSession({
    required this.id,
    required this.userId,
    required this.branchCode,
    required this.openedAt,
    required this.openingFloat,
    this.closedAt,
    this.countedAmountUsd,
    this.countedAmountVes,
    this.differenceUsd,
  });

  final int id;
  final int userId;
  final String branchCode;
  final DateTime openedAt;
  final DateTime? closedAt;

  /// Fondo inicial, en USD.
  final Decimal openingFloat;

  // Se completan en el arqueo de cierre.
  final Decimal? countedAmountUsd;
  final Decimal? countedAmountVes;

  /// Diferencia del arqueo en USD: positiva es sobrante, negativa faltante.
  final Decimal? differenceUsd;

  bool get isOpen => closedAt == null;
}

/// Egreso de efectivo (gasto de caja chica) registrado durante un turno.
@immutable
class CashExpense {
  const CashExpense({
    required this.id,
    required this.cashSessionId,
    required this.reason,
    required this.amount,
    required this.currency,
    required this.createdBy,
    required this.createdAt,
  });

  final int id;
  final int cashSessionId;
  final String reason;
  final Decimal amount;
  final Currency currency;
  final int createdBy;
  final DateTime createdAt;
}

/// Arqueo: efectivo que debería haber en la caja según ventas y egresos.
@immutable
class CashCountSummary {
  const CashCountSummary({
    required this.openingFloat,
    required this.cashSalesUsd,
    required this.cashSalesVes,
    required this.electronicSalesUsd,
    required this.electronicSalesVes,
    required this.expensesUsd,
    required this.expensesVes,
    required this.expectedCashUsd,
    required this.expectedCashVes,
  });

  final Decimal openingFloat;
  final Decimal cashSalesUsd;
  final Decimal cashSalesVes;

  /// Punto de venta y pago móvil: informativos, no son efectivo en gaveta.
  final Decimal electronicSalesUsd;
  final Decimal electronicSalesVes;
  final Decimal expensesUsd;
  final Decimal expensesVes;
  final Decimal expectedCashUsd;
  final Decimal expectedCashVes;
}
