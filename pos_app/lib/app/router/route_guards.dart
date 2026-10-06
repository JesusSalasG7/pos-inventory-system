import 'package:flutter/foundation.dart';

import 'package:pos_app/app/router/route_names.dart';

/// Reglas de redirección del router.
abstract final class RouteGuards {
  /// La vista previa de diseño solo existe en compilaciones de depuración.
  static String? debugOnly() => kDebugMode ? null : RouteNames.root;

  // TODO(fase-2): redirigir al login sin sesión y al selector de sucursal
  // cuando un MANAGER con varias sedes todavía no ha elegido una.
}
