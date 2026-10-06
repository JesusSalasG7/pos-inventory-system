import 'package:flutter/material.dart';

import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';

enum ButtonTone { primary, success, danger }

enum ButtonVariant { filled, outlined }

/// Botón de acción principal: 56 dp de alto y ancho completo por defecto.
///
/// Con `isLoading` muestra un indicador y se deshabilita, lo que bloquea el
/// doble envío mientras una operación está en curso.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.tone = ButtonTone.primary,
    this.variant = ButtonVariant.filled,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final ButtonTone tone;
  final ButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    // Fondo, texto sobre el fondo y color del borde/texto en la variante delineada.
    final (color, onColor, outlineColor) = switch (tone) {
      ButtonTone.primary => (AppColors.primary, AppColors.onPrimary, AppColors.primaryDark),
      ButtonTone.success => (AppColors.success, AppColors.white, AppColors.success),
      ButtonTone.danger => (AppColors.error, AppColors.white, AppColors.error),
    };
    final minimumSize = Size(expand ? double.infinity : 0, AppSpacing.primaryButtonHeight);
    final effectiveOnPressed = isLoading ? null : onPressed;
    final isFilled = variant == ButtonVariant.filled;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isFilled ? AppColors.textSecondary : outlineColor,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 22),
        if (isLoading || icon != null) const SizedBox(width: AppSpacing.sm),
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );

    return switch (variant) {
      ButtonVariant.filled => FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: onColor,
          minimumSize: minimumSize,
        ),
        child: child,
      ),
      ButtonVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: outlineColor,
          side: BorderSide(
            color: effectiveOnPressed == null ? AppColors.border : outlineColor,
            width: 2,
          ),
          minimumSize: minimumSize,
        ),
        child: child,
      ),
    };
  }
}
