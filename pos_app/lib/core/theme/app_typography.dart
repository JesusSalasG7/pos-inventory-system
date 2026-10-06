import 'package:flutter/material.dart';

import 'package:pos_app/core/theme/app_colors.dart';

/// Tipografía de la app: Manrope empaquetada como asset.
abstract final class AppTypography {
  static const String fontFamily = 'Manrope';

  /// Cifras de ancho fijo: los montos no "bailan" al cambiar.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static const TextStyle _base = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static final TextStyle headline = _base.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
  );
  static final TextStyle title = _base.copyWith(fontSize: 19, fontWeight: FontWeight.w800);
  static final TextStyle subtitle = _base.copyWith(fontSize: 16, fontWeight: FontWeight.w700);
  static final TextStyle body = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w500);
  static final TextStyle bodySmall = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static final TextStyle label = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );
  static final TextStyle button = _base.copyWith(fontSize: 17, fontWeight: FontWeight.w800);

  /// Monto destacado (USD). Negrita y cifras tabulares.
  static TextStyle amount(double fontSize, {Color color = AppColors.textPrimary}) {
    return _base.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: color,
      height: 1.15,
      letterSpacing: -0.2,
      fontFeatures: tabular,
    );
  }

  /// Monto secundario (VES): más pequeño y tenue, también tabular.
  static TextStyle amountSecondary(double fontSize, {Color color = AppColors.textMuted}) {
    return _base.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.2,
      fontFeatures: tabular,
    );
  }

  static TextTheme get textTheme => TextTheme(
    displaySmall: headline.copyWith(fontSize: 32),
    headlineMedium: headline.copyWith(fontSize: 28),
    headlineSmall: headline,
    titleLarge: title.copyWith(fontSize: 20),
    titleMedium: title,
    titleSmall: subtitle,
    bodyLarge: body.copyWith(fontSize: 16),
    bodyMedium: body,
    bodySmall: bodySmall,
    labelLarge: button,
    labelMedium: label.copyWith(fontSize: 13),
    labelSmall: label,
  );
}
