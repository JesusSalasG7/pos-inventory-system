import 'package:flutter/material.dart';

/// Paleta propia de alto contraste para mostrador. Solo tema claro.
///
/// Todos los pares texto/fondo usados en la app cumplen WCAG AA (≥ 4,5:1).
abstract final class AppColors {
  // Marca: azul petróleo sobrio.
  static const Color primary = Color(0xFF0B4F6C);
  static const Color primaryDark = Color(0xFF083B51);
  static const Color primarySoft = Color(0xFFE3EEF3);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Éxito / montos en USD.
  static const Color success = Color(0xFF146C43);
  static const Color successSoft = Color(0xFFDFF3E7);

  // Alerta: stock en o bajo el mínimo.
  static const Color warning = Color(0xFF9A4B00);
  static const Color warningSoft = Color(0xFFFFEFD6);

  // Error: sin stock, faltantes, fallos.
  static const Color error = Color(0xFFB42318);
  static const Color errorSoft = Color(0xFFFDE7E4);

  // Superficies y texto.
  static const Color background = Color(0xFFF5F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF1F4);
  static const Color border = Color(0xFFDDE2E8);
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF3F4A5A);
  static const Color textMuted = Color(0xFF5B6676);
  static const Color disabled = Color(0xFF98A2B3);

  // Acentos de categoría (el backend no tiene imágenes de producto).
  static const Color categoryLiquids = Color(0xFF1565A8);
  static const Color categoryLiquidsSoft = Color(0xFFE1EEFA);
  static const Color categoryPowders = Color(0xFF6B3FA0);
  static const Color categoryPowdersSoft = Color(0xFFEFE7F8);
  static const Color categoryAccessories = Color(0xFF8A5A00);
  static const Color categoryAccessoriesSoft = Color(0xFFFBF0D9);
}
