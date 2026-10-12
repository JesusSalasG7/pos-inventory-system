import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/core/widgets/skeleton.dart';

/// Tarjeta de una sección de estadísticas con sus propios estados: cargando,
/// error con reintento y datos. Un fallo aquí no afecta a las demás secciones.
class StatsSection<T> extends StatelessWidget {
  const StatsSection({
    required this.title,
    required this.value,
    required this.onRetry,
    required this.builder,
    this.loadingHeight = 160,
    super.key,
  });

  final String title;
  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;
  final double loadingHeight;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (value.hasValue) {
      // Mientras se recarga se conservan los datos anteriores, algo atenuados.
      content = AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: value.isLoading ? 0.5 : 1,
        child: builder(value.requireValue),
      );
    } else if (value.hasError) {
      content = StatsSectionError(message: Failure.from(value.error!).message, onRetry: onRetry);
    } else {
      content = SkeletonBox(height: loadingHeight);
    }
    return SectionCard(title: title, child: content);
  }
}

/// Error compacto de una sección, con su botón de reintentar.
class StatsSectionError extends StatelessWidget {
  const StatsSectionError({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message, style: AppTypography.body)),
          ],
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text(Strings.retry),
        ),
      ],
    );
  }
}

/// Aviso de que no hay ventas en el período.
class StatsEmptyNote extends StatelessWidget {
  const StatsEmptyNote({this.message = Strings.statsNoSales, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.insights_outlined, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: AppTypography.body)),
        ],
      ),
    );
  }
}

/// Cuadradito de color de una leyenda.
class StatsSwatch extends StatelessWidget {
  const StatsSwatch({required this.color, this.round = false, super.key});

  final Color color;
  final bool round;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(round ? 6 : 3)),
    );
  }
}
