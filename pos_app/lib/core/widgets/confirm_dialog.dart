import 'package:flutter/material.dart';

import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';

/// Diálogo de confirmación con dos botones grandes.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    this.confirmLabel = Strings.confirm,
    this.cancelLabel = Strings.cancel,
    this.isDestructive = false,
    this.content,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// Pinta el botón de confirmar en rojo (cerrar caja, desactivar, vaciar carrito).
  final bool isDestructive;

  /// Contenido extra bajo el mensaje, p. ej. la diferencia del arqueo.
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (content != null) ...[const SizedBox(height: AppSpacing.lg), content!],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                ),
                child: Text(cancelLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                  foregroundColor: isDestructive ? AppColors.white : AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                ),
                child: Text(confirmLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Muestra un [ConfirmDialog] y devuelve `true` solo si el usuario confirma.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = Strings.confirm,
  String cancelLabel = Strings.cancel,
  bool isDestructive = false,
  Widget? content,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
      content: content,
    ),
  );
  return confirmed ?? false;
}
