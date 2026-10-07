import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/features/inventory/domain/entities/inventory_movement.dart';

/// Ícono y colores de cada tipo de movimiento del Kardex.
(IconData, Color, Color) movementStyle(MovementType type) => switch (type) {
  MovementType.entry => (
    Icons.add_circle_outline_rounded,
    AppColors.success,
    AppColors.successSoft,
  ),
  MovementType.sale => (
    Icons.point_of_sale_rounded,
    AppColors.textSecondary,
    AppColors.surfaceMuted,
  ),
  MovementType.waste => (Icons.delete_outline_rounded, AppColors.error, AppColors.errorSoft),
  MovementType.adjustment => (Icons.tune_rounded, AppColors.warning, AppColors.warningSoft),
};

/// Renglón del Kardex: tipo, variación con signo, stock antes y después,
/// quién lo hizo y cuándo.
class MovementTile extends StatelessWidget {
  const MovementTile({
    required this.movement,
    required this.isMine,
    this.unit,
    this.productName,
    super.key,
  });

  final InventoryMovement movement;

  /// El movimiento lo registró el usuario de la sesión.
  final bool isMine;

  /// Unidad del producto; `null` si ya no está en el catálogo cargado.
  final UnitOfMeasure? unit;

  /// Nombre del producto, cuando la lista mezcla varios.
  final String? productName;

  String _amount(Decimal value) {
    final unit = this.unit;
    final text = MoneyFormatter.quantity(value);
    return unit == null ? text : Strings.stockOf(text, Strings.unitShort(unit));
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, softColor) = movementStyle(movement.type);
    final delta = movement.delta;
    final signedDelta = delta > Decimal.zero ? '+${_amount(delta)}' : _amount(delta);
    final saleId = movement.saleId;
    final author = isMine ? Strings.you : Strings.sessionUser(movement.userId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: softColor, shape: BoxShape.circle),
          child: Icon(icon, size: 22, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (productName != null)
                Text(
                  productName!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle,
                ),
              Text(
                saleId == null
                    ? Strings.movementType(movement.type)
                    : '${Strings.movementType(movement.type)} · ${Strings.saleNumber(saleId)}',
                style: productName == null ? AppTypography.subtitle : AppTypography.body,
              ),
              Text(
                Strings.stockChange(_amount(movement.stockBefore), _amount(movement.stockAfter)),
                style: AppTypography.bodySmall.copyWith(fontFeatures: AppTypography.tabular),
              ),
              Text(
                '${DateFormatter.dateTime(movement.createdAt)} · $author',
                style: AppTypography.bodySmall.copyWith(fontSize: 12),
              ),
              if (movement.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(movement.notes, style: AppTypography.bodySmall),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(signedDelta, style: AppTypography.amount(16, color: color)),
      ],
    );
  }
}
