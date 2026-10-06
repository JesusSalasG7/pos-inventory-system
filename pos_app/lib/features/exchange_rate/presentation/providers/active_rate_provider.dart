import 'package:decimal/decimal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_rate_provider.g.dart';

/// Tasa activa global (VES por 1 USD); `null` si el backend aún no tiene ninguna.
///
/// Toda conversión USD → VES de la UI la lee de aquí, salvo cuando se pasa una
/// tasa congelada (comprobantes e historial de ventas).
@Riverpod(keepAlive: true)
class ActiveRate extends _$ActiveRate {
  // TODO(fase-3): cargarla de `exchange-rates/current/` y refrescarla al abrir
  // la app, al volver a primer plano y tras registrar una tasa nueva.
  @override
  Future<Decimal?> build() async => null;
}
