import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';

/// Reglas de redirección del router. Función pura: fácil de probar.
abstract final class RouteGuards {
  /// Pantallas de entrada: solo tienen sentido antes de que la sesión esté lista.
  static const Set<String> _gateRoutes = {
    '/',
    RouteNames.splash,
    RouteNames.login,
    RouteNames.firstBranch,
    RouteNames.branchPicker,
    RouteNames.branchUnavailable,
  };

  /// Devuelve la ruta a la que hay que ir, o `null` si `location` es válida.
  ///
  /// El estado de la sesión manda: sin sesión se va al login, un MANAGER sin
  /// sucursales va a crear la primera, y así sucesivamente.
  static String? redirect({
    required SessionStatus status,
    required String location,
    required bool isDebug,
  }) {
    if (location == RouteNames.designPreview) {
      // La vista previa de diseño solo existe en compilaciones de depuración.
      return isDebug ? null : RouteNames.splash;
    }
    final required = switch (status) {
      SessionStatus.loading || SessionStatus.error => RouteNames.splash,
      SessionStatus.unauthenticated => RouteNames.login,
      SessionStatus.needsFirstBranch => RouteNames.firstBranch,
      SessionStatus.needsBranchSelection => RouteNames.branchPicker,
      SessionStatus.branchUnavailable => RouteNames.branchUnavailable,
      SessionStatus.ready => null,
    };
    if (required != null) return location == required ? null : required;
    return _gateRoutes.contains(location) ? RouteNames.home : null;
  }
}
