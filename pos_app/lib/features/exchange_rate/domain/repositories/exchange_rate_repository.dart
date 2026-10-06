import 'package:decimal/decimal.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';

abstract interface class ExchangeRateRepository {
  /// Tasa activa (VES por 1 USD), o `null` si el backend aún no tiene ninguna.
  Future<Decimal?> fetchActiveRate();

  /// Histórico de tasas, de la más reciente a la más antigua.
  Future<Paginated<ExchangeRate>> fetchHistory({required int page});

  /// Registra una tasa nueva, que pasa a ser la activa. Solo MANAGER.
  Future<ExchangeRate> registerRate(Decimal rate);

  /// Tasa oficial del BCV. Lanza `Failure` `bcv_rate_unavailable` si no se pudo consultar.
  Future<BcvRate> fetchBcvRate();
}
