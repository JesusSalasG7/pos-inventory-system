import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_app/core/currency/currency_converter.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';

enum DualCurrencySize { small, medium, large }

enum DualCurrencyLayout { column, row }

/// Muestra un monto en USD destacado y su equivalente en VES como dato secundario.
///
/// Por defecto convierte con la tasa activa global. En comprobantes e historial
/// de ventas es OBLIGATORIO pasar `rate` con la tasa congelada de la venta
/// (`exchange_rate_at_invoice`): una venta pasada no cambia con la tasa de hoy.
class DualCurrencyText extends ConsumerWidget {
  const DualCurrencyText({
    required this.amountUsd,
    this.rate,
    this.amountVes,
    this.size = DualCurrencySize.medium,
    this.layout = DualCurrencyLayout.column,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.usdColor = AppColors.textPrimary,
    this.vesColor = AppColors.textMuted,
    super.key,
  });

  final Decimal amountUsd;

  /// Tasa congelada (VES por 1 USD). Si es `null` se usa la tasa activa.
  final Decimal? rate;

  /// Monto en VES ya calculado por el backend (p. ej. totales de ventas, que
  /// suman lo facturado con la tasa de cada venta). Si se indica, no se convierte.
  final Decimal? amountVes;
  final DualCurrencySize size;
  final DualCurrencyLayout layout;
  final CrossAxisAlignment crossAxisAlignment;
  final Color usdColor;
  final Color vesColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedVes = amountVes;
    final effectiveRate = fixedVes != null ? null : rate ?? ref.watch(activeRateProvider).value;
    final usdText = MoneyFormatter.usd(amountUsd);
    final vesText = fixedVes != null
        ? MoneyFormatter.ves(fixedVes)
        : effectiveRate == null
        ? Strings.vesUnavailable
        : MoneyFormatter.ves(CurrencyConverter.usdToVes(amountUsd, effectiveRate));

    final (usdSize, vesSize) = switch (size) {
      DualCurrencySize.small => (16.0, 12.0),
      DualCurrencySize.medium => (22.0, 14.0),
      DualCurrencySize.large => (36.0, 18.0),
    };
    final usd = Text(
      usdText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.amount(usdSize, color: usdColor),
    );
    final ves = Text(
      vesText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.amountSecondary(vesSize, color: vesColor),
    );

    return Semantics(
      label: '$usdText, $vesText',
      excludeSemantics: true,
      child: switch (layout) {
        DualCurrencyLayout.column => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [usd, ves],
        ),
        DualCurrencyLayout.row => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(child: usd),
            const SizedBox(width: AppSpacing.sm),
            Flexible(child: ves),
          ],
        ),
      },
    );
  }
}
