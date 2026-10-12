import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_format.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_section.dart';

/// Reparto de los ingresos y la ganancia del período entre contado y crédito,
/// y lo que sigue sin cobrarse de lo vendido a crédito.
class CreditBreakdownView extends StatelessWidget {
  const CreditBreakdownView({required this.breakdown, super.key});

  final CreditBreakdown breakdown;

  static const Color cashColor = AppColors.primary;
  static const Color creditColor = Color(0xFFF79009);

  @override
  Widget build(BuildContext context) {
    final cash = breakdown.cash;
    final credit = breakdown.credit;
    final hasPending = breakdown.pendingRevenue > Decimal.zero;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShareBar(cash: cash.revenue, credit: credit.revenue),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SplitColumn(
                key: const ValueKey('stats-split-cash'),
                label: Strings.statsCash,
                color: cashColor,
                totals: cash,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _SplitColumn(
                key: const ValueKey('stats-split-credit'),
                label: Strings.statsCredit,
                color: creditColor,
                totals: credit,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (!breakdown.hasCreditSales)
          Text(Strings.statsNoCreditSales, style: AppTypography.bodySmall)
        else ...[
          Text(
            Strings.statsCreditShare(StatsFormat.percent(breakdown.creditShare)),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            key: const ValueKey('stats-pending'),
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: hasPending ? AppColors.warningSoft : AppColors.successSoft,
              borderRadius: AppRadius.smAll,
            ),
            child: hasPending
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Strings.statsPending, style: AppTypography.bodySmall),
                      Text(
                        MoneyFormatter.usd(breakdown.pendingRevenue),
                        style: AppTypography.amount(22, color: AppColors.warning),
                      ),
                      Text(
                        Strings.statsPendingProfit(MoneyFormatter.usd(breakdown.pendingProfit)),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  )
                : Text(Strings.statsAllCollected, style: AppTypography.body),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(Strings.statsCreditNote, style: AppTypography.bodySmall),
        ],
      ],
    );
  }
}

/// Barra que reparte los ingresos entre contado y crédito.
class _ShareBar extends StatelessWidget {
  const _ShareBar({required this.cash, required this.credit});

  final Decimal cash;
  final Decimal credit;

  @override
  Widget build(BuildContext context) {
    // Proporción entera para `flex`; una parte negativa o nula no se pinta.
    int weight(Decimal amount) => amount > Decimal.zero ? (amount.toDouble() * 100).round() : 0;
    final cashWeight = weight(cash);
    final creditWeight = weight(credit);
    if (cashWeight + creditWeight == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            if (cashWeight > 0)
              Expanded(
                flex: cashWeight,
                child: const ColoredBox(color: CreditBreakdownView.cashColor),
              ),
            // Separación del color del fondo entre los dos tramos.
            if (cashWeight > 0 && creditWeight > 0) const SizedBox(width: 2),
            if (creditWeight > 0)
              Expanded(
                flex: creditWeight,
                child: const ColoredBox(color: CreditBreakdownView.creditColor),
              ),
          ],
        ),
      ),
    );
  }
}

class _SplitColumn extends StatelessWidget {
  const _SplitColumn({required this.label, required this.color, required this.totals, super.key});

  final String label;
  final Color color;
  final SplitTotals totals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StatsSwatch(color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTypography.label.copyWith(fontSize: 13)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(MoneyFormatter.usd(totals.revenue), style: AppTypography.amount(20)),
        ),
        Text(
          '${Strings.statsProfit} ${MoneyFormatter.usd(totals.profit)}',
          style: AppTypography.bodySmall,
        ),
        Text(
          '${Strings.statsMargin} ${StatsFormat.percent(totals.margin)}',
          style: AppTypography.bodySmall,
        ),
      ],
    );
  }
}
