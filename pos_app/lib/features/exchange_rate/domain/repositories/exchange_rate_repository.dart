import 'package:decimal/decimal.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/pricing_settings.dart';

abstract interface class ExchangeRateRepository {
  /// Tasa activa, o `null` si el backend aún no tiene ninguna.
  Future<ExchangeRate?> fetchActive();

  /// Histórico de tasas, de la más reciente a la más antigua.
  Future<Paginated<ExchangeRate>> fetchHistory({required int page});

  /// Registra una tasa manual, que pasa a ser la activa. Solo MANAGER.
  Future<ExchangeRate> registerRate(Decimal rate);

  /// Tasa oficial del BCV. Lanza `Failure` `bcv_rate_unavailable` si no se pudo consultar.
  Future<BcvRate> fetchBcvRate();

  /// Modo de tasa y redondeo en bolívares vigentes.
  Future<PricingSettings> fetchPricingSettings();

  /// Cambia el modo de tasa o el redondeo. Solo MANAGER. Al volver al BCV,
  /// lanza `Failure` `bcv_rate_unavailable` si no se pudo consultar.
  Future<PricingSettings> updatePricingSettings({RateMode? rateMode, bool? roundVesUp});

  /// Pide al backend que sincronice ahora la tasa activa con el BCV. Solo MANAGER.
  Future<BcvSyncResult> syncWithBcv();
}
