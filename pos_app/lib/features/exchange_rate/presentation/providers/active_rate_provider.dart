import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/rate_history_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_rate_provider.g.dart';

/// Tasa activa global (VES por 1 USD); `null` si el backend aún no tiene ninguna.
///
/// Toda conversión USD → VES de la UI la lee de aquí, salvo cuando se pasa una
/// tasa congelada (comprobantes e historial de ventas). Se carga al quedar
/// lista la sesión y se refresca al volver la app a primer plano y tras
/// registrar una tasa nueva.
@Riverpod(keepAlive: true)
class ActiveRate extends _$ActiveRate {
  @override
  Future<Decimal?> build() async {
    final status = ref.watch(sessionControllerProvider.select((session) => session.status));
    if (status != SessionStatus.ready) return null;
    return ref.watch(exchangeRateRepositoryProvider).fetchActiveRate();
  }

  /// Vuelve a consultar la tasa al backend.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Registra una tasa nueva (solo MANAGER) y la deja como activa. Lanza `Failure`.
  Future<void> register(Decimal rate) async {
    final created = await ref.read(exchangeRateRepositoryProvider).registerRate(rate);
    state = AsyncData(created.rate);
    ref.invalidate(rateHistoryProvider);
  }
}
