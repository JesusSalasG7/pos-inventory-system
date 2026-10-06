import 'package:flutter/material.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';

/// Tarjeta blanca redondeada con sombra suave: el contenedor estándar de la app.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.title,
    this.trailing,
    this.onTap,
    this.color = AppColors.surface,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  final Widget child;
  final String? title;

  /// Widget a la derecha del título (un ícono, un enlace…).
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: AppTypography.label.copyWith(fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          child,
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.lgAll,
        boxShadow: AppColors.cardShadow,
      ),
      child: onTap == null
          ? content
          : Material(
              type: MaterialType.transparency,
              child: InkWell(borderRadius: AppRadius.lgAll, onTap: onTap, child: content),
            ),
    );
  }
}

/// Botón "Cargar más" al final de un historial paginado.
class LoadMoreButton extends StatefulWidget {
  const LoadMoreButton({required this.onLoadMore, required this.label, super.key});

  final Future<void> Function() onLoadMore;
  final String label;

  @override
  State<LoadMoreButton> createState() => _LoadMoreButtonState();
}

class _LoadMoreButtonState extends State<LoadMoreButton> {
  bool _loading = false;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await widget.onLoadMore();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _loading
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          : TextButton(onPressed: _load, child: Text(widget.label)),
    );
  }
}
