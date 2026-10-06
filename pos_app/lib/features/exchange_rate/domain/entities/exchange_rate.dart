import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';

/// Tasa registrada en el backend (VES por 1 USD). La activa es la más reciente.
@immutable
class ExchangeRate {
  const ExchangeRate({
    required this.id,
    required this.rate,
    required this.createdAt,
    this.source = RateSource.manual,
    this.effectiveDate,
    this.createdBy,
  });

  final int id;
  final Decimal rate;
  final RateSource source;

  /// Día al que corresponde la tasa según el BCV; `null` en las manuales.
  final DateTime? effectiveDate;

  /// Id del usuario que la registró; `null` en las automáticas.
  final int? createdBy;
  final DateTime createdAt;

  /// Día al que corresponde la tasa: el que publica el BCV o, en una manual,
  /// el día en que se registró.
  DateTime get day => effectiveDate ?? DateFormatter.caracasDay(createdAt);

  @override
  bool operator ==(Object other) =>
      other is ExchangeRate &&
      other.id == id &&
      other.rate == rate &&
      other.source == source &&
      other.effectiveDate == effectiveDate &&
      other.createdBy == createdBy &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, rate, source, effectiveDate, createdBy, createdAt);
}

/// Tasa oficial del BCV tal como la publica la fuente externa.
@immutable
class BcvRate {
  const BcvRate({required this.rate, required this.updatedAt});

  final Decimal rate;
  final DateTime updatedAt;
}

/// Resultado de pedir al backend que sincronice la tasa activa con el BCV.
@immutable
class BcvSyncResult {
  const BcvSyncResult({required this.rate, required this.changed});

  /// Tasa activa tras la sincronización.
  final ExchangeRate rate;

  /// `true` si el BCV había publicado una tasa nueva y se registró.
  final bool changed;
}
