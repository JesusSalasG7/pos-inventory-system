import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/pricing_settings.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/rate_history_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pricing_settings_provider.g.dart';

/// Configuración de precios del negocio: modo de tasa y redondeo en bolívares.
/// La cambia un MANAGER; la app la relee al iniciar sesión y al refrescar la tasa.
@Riverpod(keepAlive: true)
class PricingSettingsController extends _$PricingSettingsController {
  @override
  Future<PricingSettings> build() async {
    final status = ref.watch(sessionControllerProvider.select((session) => session.status));
    if (status != SessionStatus.ready) return const PricingSettings();
    return ref.watch(exchangeRateRepositoryProvider).fetchPricingSettings();
  }

  /// Elige con qué tasa se vende. Al volver al BCV el backend activa su tasa
  /// de inmediato, así que se relee la tasa activa. Lanza `Failure`.
  Future<void> setRateMode(RateMode mode) async {
    final saved = await ref
        .read(exchangeRateRepositoryProvider)
        .updatePricingSettings(rateMode: mode);
    state = AsyncData(saved);
    ref.invalidate(rateHistoryProvider);
    await ref.read(activeExchangeRateProvider.notifier).refresh();
  }

  /// Activa o desactiva el redondeo de los bolívares hacia arriba. Lanza `Failure`.
  Future<void> setRoundVesUp({required bool enabled}) async {
    final saved = await ref
        .read(exchangeRateRepositoryProvider)
        .updatePricingSettings(roundVesUp: enabled);
    state = AsyncData(saved);
  }
}

/// `true` si los precios en bolívares se redondean hacia arriba. Mientras la
/// configuración carga, o si falla, se asume que no.
@Riverpod(keepAlive: true)
bool roundVesUp(Ref ref) => ref.watch(pricingSettingsControllerProvider).value?.roundVesUp ?? false;
