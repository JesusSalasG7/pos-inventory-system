/// Escala de espacios de la app, en dp.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Área táctil mínima de cualquier control.
  static const double minTouchTarget = 48;

  /// Alto de los botones de acción principal.
  static const double primaryButtonHeight = 56;

  /// Ancho a partir del cual el dispositivo se trata como tablet.
  static const double tabletBreakpoint = 600;
}
