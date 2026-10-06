import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';

enum StockLevel {
  /// Sin existencias: no se puede vender.
  out,

  /// En o por debajo del mínimo (misma regla que `inventory/low-stock/`).
  low,
  ok;

  static StockLevel of(Decimal stock, Decimal minimumStock) {
    if (stock <= Decimal.zero) return StockLevel.out;
    if (stock <= minimumStock) return StockLevel.low;
    return StockLevel.ok;
  }
}

/// Etiqueta con el stock de un producto y su estado: disponible, mínimo o agotado.
///
/// El estado no depende solo del color: cada nivel tiene su ícono y su texto.
class StockBadge extends StatelessWidget {
  const StockBadge({
    required this.stock,
    required this.minimumStock,
    required this.unit,
    super.key,
  });

  final Decimal stock;
  final Decimal minimumStock;
  final UnitOfMeasure unit;

  @override
  Widget build(BuildContext context) {
    final level = StockLevel.of(stock, minimumStock);
    final amount = Strings.stockOf(MoneyFormatter.quantity(stock), Strings.unitShort(unit));
    final (icon, foreground, background, text, semantics) = switch (level) {
      StockLevel.out => (
        Icons.block_rounded,
        AppColors.error,
        AppColors.errorSoft,
        Strings.outOfStock,
        Strings.outOfStock,
      ),
      StockLevel.low => (
        Icons.warning_amber_rounded,
        AppColors.warning,
        AppColors.warningSoft,
        amount,
        '${Strings.lowStock}: $amount',
      ),
      StockLevel.ok => (
        Icons.check_circle_outline_rounded,
        AppColors.success,
        AppColors.successSoft,
        amount,
        '${Strings.inStock}: $amount',
      ),
    };

    return Semantics(
      label: semantics,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(color: background, borderRadius: AppRadius.pillAll),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label.copyWith(
                  color: foreground,
                  fontFeatures: AppTypography.tabular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
