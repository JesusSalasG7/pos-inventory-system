import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/features/cash_session/domain/entities/cash_session.dart';

/// Fila con un concepto y sus montos reales en dólares y en bolívares.
///
/// A diferencia de `DualCurrencyText`, aquí no se convierte nada: la caja
/// lleva las dos monedas por separado.
class MoneyLine extends StatelessWidget {
  const MoneyLine({
    required this.label,
    required this.usd,
    required this.ves,
    this.emphasized = false,
    this.muted = false,
    super.key,
  });

  final String label;
  final Decimal usd;
  final Decimal ves;
  final bool emphasized;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.textMuted : AppColors.textPrimary;
    final amountStyle = emphasized
        ? AppTypography.amount(18, color: color)
        : AppTypography.amountSecondary(15, color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: (emphasized ? AppTypography.subtitle : AppTypography.body).copyWith(
                color: color,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(MoneyFormatter.usd(usd), style: amountStyle),
              Text(MoneyFormatter.ves(ves), style: amountStyle),
            ],
          ),
        ],
      ),
    );
  }
}

/// Desglose del arqueo: fondo, ventas en efectivo, gastos, esperado y,
/// aparte, los pagos electrónicos como información.
class CashSummaryView extends StatelessWidget {
  const CashSummaryView({required this.summary, super.key});

  final CashCountSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MoneyLine(label: Strings.openingFloatShort, usd: summary.openingFloat, ves: Decimal.zero),
        MoneyLine(label: Strings.cashSales, usd: summary.cashSalesUsd, ves: summary.cashSalesVes),
        MoneyLine(
          label: '− ${Strings.expenses}',
          usd: summary.expensesUsd,
          ves: summary.expensesVes,
        ),
        const Divider(height: AppSpacing.xl),
        MoneyLine(
          label: Strings.expectedCash,
          usd: summary.expectedCashUsd,
          ves: summary.expectedCashVes,
          emphasized: true,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadius.mdAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MoneyLine(
                label: Strings.electronicSales,
                usd: summary.electronicSalesUsd,
                ves: summary.electronicSalesVes,
                muted: true,
              ),
              Text(Strings.electronicNote, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fila de un gasto de caja.
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({required this.expense, super.key});

  final CashExpense expense;

  @override
  Widget build(BuildContext context) {
    final amount = expense.currency == Currency.usd
        ? MoneyFormatter.usd(expense.amount)
        : MoneyFormatter.ves(expense.amount);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.warningSoft, shape: BoxShape.circle),
            child: const Icon(Icons.payments_outlined, color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.reason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body,
                ),
                Text(
                  DateFormatter.dateTime(expense.createdAt),
                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('− $amount', style: AppTypography.amountSecondary(15, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

/// Diferencia del arqueo con color y palabra: verde sobrante o cuadre, rojo faltante.
class DifferenceBadge extends StatelessWidget {
  const DifferenceBadge({required this.differenceUsd, this.large = false, super.key});

  final Decimal differenceUsd;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final isShortage = differenceUsd < Decimal.zero;
    final isBalanced = differenceUsd == Decimal.zero;
    final color = isShortage ? AppColors.error : AppColors.success;
    final background = isShortage ? AppColors.errorSoft : AppColors.successSoft;
    final word = isBalanced
        ? Strings.balanced
        : isShortage
        ? Strings.shortage
        : Strings.surplus;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? AppSpacing.lg : AppSpacing.md,
        vertical: large ? AppSpacing.md : AppSpacing.xs,
      ),
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.pillAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isShortage ? Icons.trending_down_rounded : Icons.check_circle_outline_rounded,
            size: large ? 22 : 16,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$word  ${MoneyFormatter.usd(differenceUsd.abs())}',
            style: AppTypography.amount(large ? 18 : 13, color: color),
          ),
        ],
      ),
    );
  }
}
