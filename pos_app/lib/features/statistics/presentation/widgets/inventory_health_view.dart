import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_format.dart';

/// Capital inmovilizado y las dos listas desplegables: por agotarse y sin movimiento.
class InventoryHealthView extends StatelessWidget {
  const InventoryHealthView({required this.health, super.key});

  final InventoryHealth health;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Strings.statsImmobilizedCapital, style: AppTypography.bodySmall),
        Text(
          MoneyFormatter.usd(health.immobilizedCapitalTotal),
          style: AppTypography.amount(28, color: AppColors.warning),
        ),
        const SizedBox(height: AppSpacing.sm),
        _Expandable(
          key: const ValueKey('stats-running-out'),
          title: Strings.statsRunningOut(health.runningOut.length),
          emptyMessage: Strings.statsNothingRunningOut,
          children: [
            for (final item in health.runningOut)
              _HealthRow(
                name: item.name,
                detail: Strings.statsStock(StatsFormat.quantity(item.stock, item.unit)),
                trailing: item.stock == Decimal.zero
                    ? Strings.statsOutOfStock
                    : Strings.statsDaysLeft(MoneyFormatter.number(item.daysLeft, maxDecimals: 0)),
                trailingColor: AppColors.error,
              ),
          ],
        ),
        _Expandable(
          key: const ValueKey('stats-no-movement'),
          title: Strings.statsNoMovement(health.noMovement.length),
          emptyMessage: Strings.statsNothingStale,
          children: [
            for (final item in health.noMovement)
              _HealthRow(
                name: item.name,
                detail: switch (item.lastSaleDate) {
                  final date? => Strings.statsNoSalesSince(DateFormatter.calendarDate(date)),
                  null => Strings.statsNeverSold,
                },
                trailing: MoneyFormatter.usd(item.immobilizedCapital),
                trailingColor: AppColors.textPrimary,
              ),
          ],
        ),
      ],
    );
  }
}

class _Expandable extends StatelessWidget {
  const _Expandable({
    required this.title,
    required this.emptyMessage,
    required this.children,
    super.key,
  });

  final String title;
  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Sin las líneas divisorias que el ExpansionTile pinta al abrirse.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(title, style: AppTypography.subtitle),
        children: children.isEmpty
            ? [Text(emptyMessage, style: AppTypography.bodySmall)]
            : children,
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.name,
    required this.detail,
    required this.trailing,
    required this.trailingColor,
  });

  final String name;
  final String detail;
  final String trailing;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(detail, style: AppTypography.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(trailing, style: AppTypography.amount(14, color: trailingColor)),
        ],
      ),
    );
  }
}
