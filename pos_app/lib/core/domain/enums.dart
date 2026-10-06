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

enum ProductCategory {
  liquids('LIQUIDS'),
  powders('POWDERS'),
  accessories('ACCESSORIES'),
  other('OTHER');

  const ProductCategory(this.apiValue);
  final String apiValue;

  /// Categorías que el backend acepta hoy (sin el comodín `other`).
  static const List<ProductCategory> known = [liquids, powders, accessories];

  static ProductCategory fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value, orElse: () => other);
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
  posCard('POS_CARD', Currency.ves, requiresReference: true);

  const PaymentMethod(this.apiValue, this.currency, {required this.requiresReference});
  final String apiValue;

  /// Moneda en la que el backend liquida el método.
  final Currency currency;

  /// El backend exige `approval_reference` para los métodos electrónicos.
  final bool requiresReference;

  bool get isCash => this == cashUsd || this == cashVes;

  static PaymentMethod fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value, orElse: () => cashVes);
}
