import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/rate_history_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_rate_provider.g.dart';

/// Tasa activa del backend con su origen y el día al que corresponde; `null`
/// si todavía no hay ninguna.
///
/// La tasa cambia sola cuando el servidor sincroniza con el BCV, así que se
/// vuelve a consultar al abrir la app, al volver a primer plano y cada pocos
/// minutos mientras está abierta (ver `PosApp`).
@Riverpod(keepAlive: true)
class ActiveExchangeRate extends _$ActiveExchangeRate {
  @override
  Future<ExchangeRate?> build() async {
    final status = ref.watch(sessionControllerProvider.select((session) => session.status));
    if (status != SessionStatus.ready) return null;
    return ref.watch(exchangeRateRepositoryProvider).fetchActive();
  }

  /// Vuelve a consultar la tasa al backend.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Registra una tasa manual (solo MANAGER) y la deja como activa. Lanza `Failure`.
  Future<void> register(Decimal rate) async {
    final created = await ref.read(exchangeRateRepositoryProvider).registerRate(rate);
    state = AsyncData(created);
    ref.invalidate(rateHistoryProvider);
  }

  /// Pide al backend que sincronice ahora con el BCV (solo MANAGER). Devuelve
  /// `true` si la tasa cambió. Lanza `Failure` si el BCV no responde.
  Future<bool> syncWithBcv() async {
    final result = await ref.read(exchangeRateRepositoryProvider).syncWithBcv();
    state = AsyncData(result.rate);
    if (result.changed) ref.invalidate(rateHistoryProvider);
    ref.invalidate(bcvRateProvider);
    return result.changed;
  }
}

/// Valor de la tasa activa (VES por 1 USD); `null` si no hay ninguna.
///
/// Toda conversión USD → VES de la UI la lee de aquí, salvo cuando se pasa una
/// tasa congelada (comprobantes e historial de ventas).
@Riverpod(keepAlive: true)
class ActiveRate extends _$ActiveRate {
  @override
  Future<Decimal?> build() async {
    final active = await ref.watch(activeExchangeRateProvider.future);
    return active?.rate;
  }

  Future<void> refresh() => ref.read(activeExchangeRateProvider.notifier).refresh();
}
