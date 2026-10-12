/// Enumeraciones del backend (`pos_backend/core/enums.py`).
///
/// `apiValue` es el valor exacto que viaja por la API. Los enums ampliables
/// del backend tienen un valor `other` para no romper la app si aparece uno nuevo.
library;

enum UserRole {
  manager('MANAGER'),
  supervisor('SUPERVISOR');

  const UserRole(this.apiValue);
  final String apiValue;

  static UserRole fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value, orElse: () => supervisor);
}

enum UnitOfMeasure {
  liter('LITER'),
  kilogram('KILOGRAM'),
  unit('UNIT');

  const UnitOfMeasure(this.apiValue);
  final String apiValue;

  /// Las unidades a granel admiten cantidades con decimales.
  bool get allowsDecimals => this != unit;

  static UnitOfMeasure fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value, orElse: () => unit);
}

enum MovementType {
  entry('ENTRY'),
  sale('SALE'),
  waste('WASTE'),
  adjustment('ADJUSTMENT');

  const MovementType(this.apiValue);
  final String apiValue;

  static MovementType fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value, orElse: () => adjustment);
}

/// Origen de una tasa de cambio registrada en el backend.
enum RateSource {
  /// La registró un MANAGER a mano.
  manual('MANUAL'),

  /// La registró la sincronización automática con el BCV.
  bcv('BCV');

  const RateSource(this.apiValue);
  final String apiValue;

  static RateSource fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value, orElse: () => manual);
}

/// Con qué tasa calcula el negocio sus bolívares.
enum RateMode {
  /// La tasa activa sigue sola a la del BCV.
  bcv('BCV'),

  /// Manda la tasa que fija el gerente; el BCV no la reemplaza.
  manual('MANUAL');

  const RateMode(this.apiValue);
  final String apiValue;

  static RateMode fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value, orElse: () => bcv);
}

enum Currency {
  usd('USD'),
  ves('VES');

  const Currency(this.apiValue);
  final String apiValue;

  static Currency fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value, orElse: () => ves);
}

enum PaymentMethod {
  cashUsd('CASH_USD', Currency.usd, requiresReference: false),
  cashVes('CASH_VES', Currency.ves, requiresReference: false),
  mobilePayment('MOBILE_PAYMENT', Currency.ves, requiresReference: true),
  posCard('POS_CARD', Currency.ves, requiresReference: true),

  /// El cliente se lleva los productos sin pagar: abre una deuda en USD.
  /// No es dinero en caja y no sirve para abonar una deuda.
  credit('CREDIT', Currency.usd, requiresReference: false);

  const PaymentMethod(this.apiValue, this.currency, {required this.requiresReference});
  final String apiValue;

  /// Moneda en la que el backend liquida el método.
  final Currency currency;

  /// El backend exige `approval_reference` para los métodos electrónicos.
  final bool requiresReference;

  bool get isCash => this == cashUsd || this == cashVes;

  /// Métodos con los que entra dinero: todos menos el crédito.
  static const List<PaymentMethod> money = [cashUsd, cashVes, mobilePayment, posCard];

  static PaymentMethod fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value, orElse: () => cashVes);
}
