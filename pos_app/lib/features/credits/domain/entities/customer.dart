import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// Cliente al que se le vende a crédito, con lo que debe en la tienda activa.
@immutable
class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.taxId,
    required this.phone,
    required this.creditDays,
    required this.active,
    required this.balanceUsd,
    required this.overdueUsd,
    required this.openCredits,
    this.nextDueDate,
    this.balanceVes,
    this.paymentRate,
  });

  final int id;
  final String name;

  /// Cédula o RIF; vacío si no se registró.
  final String taxId;
  final String phone;

  /// Plazo en días que se propone al venderle a crédito.
  final int creditDays;
  final bool active;

  /// Saldo pendiente en USD. La deuda siempre se lleva en dólares.
  final Decimal balanceUsd;

  /// Parte del saldo con el plazo vencido.
  final Decimal overdueUsd;

  /// Compras a crédito con saldo pendiente.
  final int openCredits;

  /// Vencimiento más próximo de las compras pendientes (fecha de calendario).
  final DateTime? nextDueDate;

  /// Saldo en bolívares a la tasa del BCV de hoy: lo que pagaría hoy en Bs.
  /// `null` si el backend no tiene tasa del BCV.
  final Decimal? balanceVes;

  /// Tasa del BCV con la que se cobran hoy los abonos en bolívares.
  final Decimal? paymentRate;

  bool get hasDebt => balanceUsd > Decimal.zero;
  bool get hasOverdue => overdueUsd > Decimal.zero;
}

/// Datos editables de un cliente.
@immutable
class CustomerDraft {
  const CustomerDraft({
    required this.name,
    this.taxId = '',
    this.phone = '',
    this.creditDays = 7,
    this.active = true,
  });

  final String name;
  final String taxId;
  final String phone;
  final int creditDays;
  final bool active;
}
