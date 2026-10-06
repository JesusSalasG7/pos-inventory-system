import 'package:flutter/material.dart';

/// Paleta propia, viva y amigable, de alto contraste para mostrador. Solo tema claro.
///
/// El color de marca es un verde fresco y brillante. Sobre él el texto va en
/// tinta oscura ([onPrimary]), no en blanco: así se mantiene el contraste
/// WCAG AA (≥ 4,5:1) sin apagar el color. Para texto e íconos verdes sobre
/// fondos claros se usa [primaryDark].
abstract final class AppColors {
  // Marca.
  static const Color primary = Color(0xFF1DBF73);
  static const Color primaryDark = Color(0xFF067647);
  static const Color primarySoft = Color(0xFFDDF7EA);
  static const Color onPrimary = Color(0xFF062B1B);

  // Acento cálido para destacar (carrito, avisos amables).
  static const Color accent = Color(0xFFFFC533);
  static const Color accentSoft = Color(0xFFFFF3CC);
  static const Color onAccent = Color(0xFF3A2A00);

  // Éxito / montos en USD.
  static const Color success = Color(0xFF067647);
  static const Color successSoft = Color(0xFFDDF7EA);

  // Alerta: stock en o bajo el mínimo.
  static const Color warning = Color(0xFFB54708);
  static const Color warningSoft = Color(0xFFFFEFD9);

  // Error: sin stock, faltantes, fallos.
  static const Color error = Color(0xFFB42318);
  static const Color errorSoft = Color(0xFFFFE4E0);

  // Superficies y texto.
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF3F7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFE9EFEB);
  static const Color border = Color(0xFFDCE5DF);
  static const Color ink = Color(0xFF0E1F17);
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF3D4A43);
  static const Color textMuted = Color(0xFF5C6B63);
  static const Color disabled = Color(0xFF98A69E);

  /// Texto secundario sobre superficies oscuras ([ink]).
  static const Color onInkMuted = Color(0xFFC7D6CD);

  // Acentos de categoría (el backend no tiene imágenes de producto).
  static const Color categoryLiquids = Color(0xFF1570EF);
  static const Color categoryLiquidsSoft = Color(0xFFE0EDFF);
  static const Color categoryPowders = Color(0xFF7A3FD1);
  static const Color categoryPowdersSoft = Color(0xFFEFE5FF);
  static const Color categoryAccessories = Color(0xFFC2410C);
  static const Color categoryAccessoriesSoft = Color(0xFFFFE8D9);

  /// Sombra suave de las tarjetas.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x140E1F17), blurRadius: 16, offset: Offset(0, 4)),
  ];
}
