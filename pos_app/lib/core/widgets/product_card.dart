import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'package:pos_app/core/constants/category_style.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';
import 'package:pos_app/core/widgets/quantity_input_dialog.dart';
import 'package:pos_app/core/widgets/stock_badge.dart';

/// Tarjeta de producto del POS, pensada para vender con pocas pulsaciones.
///
/// Muestra categoría (ícono y color), nombre, stock en la sede, precio en las
/// dos monedas y los controles de cantidad. Nunca deja pedir más que el stock
/// disponible y queda deshabilitada cuando el stock es cero.
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.name,
    required this.category,
    required this.unit,
    required this.priceUsd,
    required this.stock,
    required this.minimumStock,
    required this.quantity,
    required this.onQuantityChanged,
    this.rate,
    super.key,
  });

  /// Alto recomendado de la celda en una cuadrícula (`mainAxisExtent`).
  static const double gridExtent = 252;

  /// Columnas de la cuadrícula según el ancho disponible: 2 en teléfono y más
  /// en tablet. En pantallas muy estrechas los controles de 48 dp no caben a
  /// dos columnas, así que se usa una sola.
  static int columnsFor(double width) {
    if (width < 340) return 1;
    if (width < AppSpacing.tabletBreakpoint) return 2;
    if (width < 900) return 3;
    return 4;
  }

  static final Decimal _step = Decimal.one;

  final String name;
  final ProductCategory category;
  final UnitOfMeasure unit;
  final Decimal priceUsd;

  /// Stock disponible en la sucursal activa.
  final Decimal stock;
  final Decimal minimumStock;

  /// Cantidad que ya está en el carrito; cero si no se ha agregado.
  final Decimal quantity;

  /// Recibe la nueva cantidad, siempre entre cero y el stock disponible.
  final ValueChanged<Decimal> onQuantityChanged;

  /// Tasa para el precio en VES; por defecto la tasa activa.
  final Decimal? rate;

  bool get _isOutOfStock => stock <= Decimal.zero;
  bool get _canIncrease => quantity + _step <= stock;

  void _add() {
    // Si queda menos de una unidad a granel, se agrega lo que haya.
    onQuantityChanged(stock >= _step ? _step : stock);
  }

  void _increase() {
    if (_canIncrease) onQuantityChanged(quantity + _step);
  }

  void _decrease() {
    final next = quantity - _step;
    onQuantityChanged(next > Decimal.zero ? next : Decimal.zero);
  }

  Future<void> _editQuantity(BuildContext context) async {
    final result = await showQuantityInputDialog(
      context,
      initial: quantity,
      max: stock,
      unit: unit,
      productName: name,
    );
    if (result != null) onQuantityChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.of(category);
    final inCart = quantity > Decimal.zero;

    return Opacity(
      opacity: _isOutOfStock ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: inCart ? AppColors.primary : AppColors.border,
            width: inCart ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: style.softColor, borderRadius: AppRadius.smAll),
                  child: Icon(style.icon, size: 20, color: style.color),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: StockBadge(stock: stock, minimumStock: minimumStock, unit: unit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.subtitle.copyWith(fontSize: 15, height: 1.25),
            ),
            Text(
              '${CategoryStyle.labelOf(category)} · ${Strings.unit(unit)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(fontSize: 12),
            ),
            const Spacer(),
            DualCurrencyText(amountUsd: priceUsd, rate: rate, size: DualCurrencySize.small),
            const SizedBox(height: AppSpacing.sm),
            if (inCart)
              _QuantityStepper(
                quantityText: MoneyFormatter.quantity(quantity),
                unitText: Strings.unitShort(unit),
                onDecrease: _decrease,
                onIncrease: _canIncrease ? _increase : null,
                onEdit: unit.allowsDecimals ? () => _editQuantity(context) : null,
              )
            else
              SizedBox(
                width: double.infinity,
                height: AppSpacing.minTouchTarget,
                child: FilledButton.tonalIcon(
                  onPressed: _isOutOfStock ? null : _add,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primarySoft,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(Strings.add),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantityText,
    required this.unitText,
    required this.onDecrease,
    required this.onIncrease,
    required this.onEdit,
  });

  final String quantityText;
  final String unitText;
  final VoidCallback onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final quantity = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          quantityText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.amount(17),
        ),
        Text(unitText, style: AppTypography.label.copyWith(color: AppColors.textMuted, height: 1)),
      ],
    );

    return SizedBox(
      height: AppSpacing.minTouchTarget,
      child: Row(
        children: [
          _StepButton(icon: Icons.remove_rounded, tooltip: Strings.decrease, onPressed: onDecrease),
          Expanded(
            child: onEdit == null
                ? quantity
                : Semantics(
                    button: true,
                    label: Strings.editQuantity,
                    child: InkWell(borderRadius: AppRadius.smAll, onTap: onEdit, child: quantity),
                  ),
          ),
          _StepButton(icon: Icons.add_rounded, tooltip: Strings.increase, onPressed: onIncrease),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppSpacing.minTouchTarget,
      child: IconButton.filled(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceMuted,
          disabledForegroundColor: AppColors.disabled,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        ),
        icon: Icon(icon, size: 24),
      ),
    );
  }
}
