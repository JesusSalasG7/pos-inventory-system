import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// Tasa registrada en el backend (VES por 1 USD). La activa es la más reciente.
@immutable
class ExchangeRate {
  const ExchangeRate({
    required this.id,
    required this.rate,
    required this.createdBy,
    required this.createdAt,
  });

  final int id;
  final Decimal rate;

  /// Id del usuario que la registró.
  final int createdBy;
  final DateTime createdAt;
}

/// Tasa oficial del BCV. Es solo una referencia: no es la tasa con la que se factura.
@immutable
class BcvRate {
  const BcvRate({required this.rate, required this.updatedAt});

  final Decimal rate;
  final DateTime updatedAt;
}
