import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/domain/enums.dart';

/// Abono de un cliente a sus deudas, cobrado en una caja.
@immutable
class CreditPayment {
  const CreditPayment({
    required this.id,
    required this.customerId,
    required this.method,
    required this.currency,
    required this.amount,
    required this.approvalReference,
    required this.usdToVesRate,
    required this.amountUsd,
    required this.createdAt,
  });

  final int id;
  final int customerId;
  final PaymentMethod method;
  final Currency currency;

  /// Lo recibido, en la moneda del método.
  final Decimal amount;
  final String approvalReference;

  /// Tasa del BCV del día del abono, con la que se pasaron a USD los bolívares.
  final Decimal usdToVesRate;

  /// Lo que el abono descontó de la deuda.
  final Decimal amountUsd;
  final DateTime createdAt;
}

/// Abono que la app envía. El backend lo convierte a USD con la tasa del BCV.
@immutable
class NewCreditPayment {
  const NewCreditPayment({required this.method, required this.amount, this.approvalReference = ''});

  final PaymentMethod method;

  /// Monto en la moneda del método (`method.currency`).
  final Decimal amount;
  final String approvalReference;
}
