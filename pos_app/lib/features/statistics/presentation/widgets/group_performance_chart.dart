import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_format.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_section.dart';

/// Barras agrupadas de ingresos y ganancia por categoría o subcategoría, con
/// la misma información en una lista debajo.
///
/// En el nivel de categorías, tocar una barra, su nombre o su fila entra en
/// esa categoría (`onEnter`).
class GroupPerformanceChart extends StatelessWidget {
  const GroupPerformanceChart({required this.report, required this.onEnter, super.key});

  final GroupReport report;
  final ValueChanged<GroupPerformance> onEnter;

  static const Color revenueColor = AppColors.categoryLiquids;
  static const Color profitColor = AppColors.primary;
  static const double _groupWidth = 76;
  static const double _chartHeight = 240;

  bool get _canEnter => report.level == GroupLevel.category;

  @override
  Widget build(BuildContext context) {
    final groups = report.groups;
    if (groups.isEmpty) return const StatsEmptyNote();

    final values = [
      for (final group in groups) ...[group.revenue.toDouble(), group.profit.toDouble()],
    ];
    final highest = math.max(values.reduce(math.max), 0).toDouble();
    final lowest = math.min(values.reduce(math.min), 0).toDouble();
    // Aire por encima (y por debajo si hay pérdidas) para que nada toque el borde.
    final span = highest - lowest == 0 ? 1.0 : highest - lowest;
    final maxY = highest + span * 0.12;
    final minY = lowest < 0 ? lowest - span * 0.12 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            StatsSwatch(color: revenueColor),
            SizedBox(width: AppSpacing.xs),
            Text(Strings.statsRevenue),
            SizedBox(width: AppSpacing.lg),
            StatsSwatch(color: profitColor),
            SizedBox(width: AppSpacing.xs),
            Text(Strings.statsProfit),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = math.max(constraints.maxWidth, groups.length * _groupWidth + 48);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                height: _chartHeight,
                child: BarChart(_data(groups, minY: minY, maxY: maxY)),
              ),
            );
          },
        ),
        if (_canEnter) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(Strings.statsGroupsHint, style: AppTypography.bodySmall),
        ],
        const SizedBox(height: AppSpacing.sm),
        for (final group in groups) _GroupRow(group: group, onTap: _onTapOf(group)),
      ],
    );
  }

  VoidCallback? _onTapOf(GroupPerformance group) =>
      _canEnter && group.id != null ? () => onEnter(group) : null;

  BarChartData _data(List<GroupPerformance> groups, {required double minY, required double maxY}) {
    return BarChartData(
      minY: minY,
      maxY: maxY,
      alignment: BarChartAlignment.spaceAround,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: value == 0 ? AppColors.textMuted : AppColors.border, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            getTitlesWidget: (value, meta) {
              // Los extremos del eje no caen en un valor redondo: se omiten.
              if (value == meta.min || value == meta.max) return const SizedBox.shrink();
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  StatsFormat.compact(value),
                  style: AppTypography.label.copyWith(color: AppColors.textMuted),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= groups.length) return const SizedBox.shrink();
              final group = groups[index];
              return SideTitleWidget(
                meta: meta,
                space: 4,
                child: InkWell(
                  onTap: _onTapOf(group),
                  child: SizedBox(
                    width: _groupWidth - 8,
                    child: Text(
                      group.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: [
        for (final (index, group) in groups.indexed)
          BarChartGroupData(
            x: index,
            barsSpace: 2,
            barRods: [
              _rod(group.revenue.toDouble(), revenueColor),
              _rod(group.profit.toDouble(), profitColor),
            ],
          ),
      ],
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => AppColors.ink,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final item = groups[groupIndex];
            final (label, amount) = rodIndex == 0
                ? (Strings.statsRevenue, item.revenue)
                : (Strings.statsProfit, item.profit);
            return BarTooltipItem(
              '${item.name}\n',
              AppTypography.label.copyWith(color: AppColors.onInkMuted),
              children: [
                TextSpan(
                  text: '$label: ${MoneyFormatter.usd(amount)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (event, response) {
          final index = response?.spot?.touchedBarGroupIndex;
          if (event is! FlTapUpEvent || index == null) return;
          _onTapOf(groups[index])?.call();
        },
      ),
    );
  }

  static BarChartRodData _rod(double value, Color color) => BarChartRodData(
    toY: value,
    color: color,
    width: 18,
    // Redondeado solo en el extremo del dato; la base queda anclada al cero.
    borderRadius: value >= 0
        ? const BorderRadius.vertical(top: Radius.circular(4))
        : const BorderRadius.vertical(bottom: Radius.circular(4)),
  );
}

/// Fila de un grupo bajo el gráfico: sus cifras exactas y, si se puede entrar
/// en él, el acceso.
class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group, required this.onTap});

  final GroupPerformance group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('stats-group-${group.id}'),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subtitle,
                    ),
                    Text(
                      '${Strings.statsRevenue} ${MoneyFormatter.usd(group.revenue)} · '
                      '${Strings.statsMargin} ${StatsFormat.percent(group.margin)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(MoneyFormatter.usd(group.profit), style: AppTypography.amount(15)),
              if (onTap != null)
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
