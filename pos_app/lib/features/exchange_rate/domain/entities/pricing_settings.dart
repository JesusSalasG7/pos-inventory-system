import 'package:flutter/foundation.dart';
import 'package:pos_app/core/domain/enums.dart';

/// Cómo obtiene el negocio sus precios en bolívares.
@immutable
class PricingSettings {
  const PricingSettings({this.rateMode = RateMode.bcv, this.roundVesUp = false});

  /// Con qué tasa se vende: la del BCV (automática) o la propia del gerente.
  final RateMode rateMode;

  /// Los precios en VES se redondean hacia arriba al bolívar entero.
  final bool roundVesUp;

  @override
  bool operator ==(Object other) =>
      other is PricingSettings && other.rateMode == rateMode && other.roundVesUp == roundVesUp;

  @override
  int get hashCode => Object.hash(rateMode, roundVesUp);
}
