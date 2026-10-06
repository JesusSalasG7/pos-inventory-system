import 'package:decimal/decimal.dart';

/// Contrato de la tasa de cambio. El histórico, el alta y la tasa BCV se
/// añaden en la fase de tasa y caja.
abstract interface class ExchangeRateRepository {
  /// Tasa activa (VES por 1 USD), o `null` si el backend aún no tiene ninguna.
  Future<Decimal?> fetchActiveRate();
}
