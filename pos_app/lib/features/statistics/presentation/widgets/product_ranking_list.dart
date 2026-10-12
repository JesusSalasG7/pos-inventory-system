import 'package:flutter/material.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_format.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_section.dart';

/// Chips para elegir por qué métrica se ordena el ranking.
class RankingOrderChips extends StatelessWidget {
  const RankingOrderChips({required this.selected, required this.onSelected, super.key});

  final RankingOrder selected;
  final ValueChanged<RankingOrder> onSelected;

  static String label(RankingOrder order) => switch (order) {
    RankingOrder.units => Strings.statsOrderUnits,
    RankingOrder.revenue => Strings.statsOrderRevenue,
    RankingOrder.profit => Strings.statsOrderProfit,
    RankingOrder.margin => Strings.statsOrderMargin,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final order in RankingOrder.values) ...[
            ChoiceChip(
              key: ValueKey('stats-order-${order.name}'),
              label: Text(label(order)),
              showCheckmark: false,
              selected: order == selected,
              onSelected: (_) => onSelected(order),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// Los mejores productos según `order`: posición, nombre, clasificación, la
/// métrica elegida destacada y una secundaria más pequeña.
class ProductRankingList extends StatelessWidget {
  const ProductRankingList({required this.products, required this.order, super.key});

  final List<ProductPerformance> products;
  final RankingOrder order;

  static String _metric(ProductPerformance product, RankingOrder order) => switch (order) {
    RankingOrder.units => StatsFormat.quantity(product.units, product.unit),
    RankingOrder.revenue => MoneyFormatter.usd(product.revenue),
    RankingOrder.profit => MoneyFormatter.usd(product.profit),
    RankingOrder.margin => StatsFormat.percent(product.margin),
  };

  /// Métrica de apoyo que acompaña a la elegida.
  static RankingOrder _secondary(RankingOrder order) => switch (order) {
    RankingOrder.units => RankingOrder.revenue,
    RankingOrder.revenue => RankingOrder.profit,
    RankingOrder.profit => RankingOrder.margin,
    RankingOrder.margin => RankingOrder.profit,
  };

  static String _secondaryLabel(RankingOrder order) => switch (order) {
    RankingOrder.units => Strings.statsUnits,
    RankingOrder.revenue => Strings.statsRevenue,
    RankingOrder.profit => Strings.statsProfit,
    RankingOrder.margin => Strings.statsMargin,
  };

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const StatsEmptyNote();
    final secondary = _secondary(order);

    return Column(
      children: [
        for (final (index, product) in products.indexed)
          Padding(
            key: ValueKey('stats-rank-${product.productId}'),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: AppTypography.label.copyWith(color: AppColors.primaryDark),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subtitle,
                      ),
                      Text(
                        Strings.statsCategoryPath(product.categoryName, product.subcategoryName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_metric(product, order), style: AppTypography.amount(16)),
                    Text(
                      '${_secondaryLabel(secondary)} ${_metric(product, secondary)}',
                      style: AppTypography.amountSecondary(12),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
