import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_format.dart';

/// Tarjetas de los seis KPIs: dos columnas en teléfono y cuatro en pantallas anchas.
class KpiGrid extends StatelessWidget {
  const KpiGrid({required this.summary, super.key});

  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final current = summary.current;
    final change = summary.change;
    final cards = [
      _KpiCard(
        title: Strings.statsRevenue,
        value: MoneyFormatter.usd(current.revenue),
        change: change.revenue,
      ),
      _KpiCard(
        title: Strings.statsProfit,
        value: MoneyFormatter.usd(current.profit),
        change: change.profit,
      ),
      _KpiCard(
        title: Strings.statsMargin,
        value: StatsFormat.percent(current.margin),
        change: change.margin,
        inPoints: true,
      ),
      _KpiCard(
        title: Strings.statsUnits,
        value: MoneyFormatter.quantity(current.units),
        change: change.units,
      ),
      _KpiCard(
        title: Strings.statsSalesCount,
        value: '${current.salesCount}',
        change: change.salesCount,
      ),
      _KpiCard(
        title: Strings.statsAverageTicket,
        value: MoneyFormatter.usd(current.averageTicket),
        change: change.averageTicket,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppSpacing.tabletBreakpoint ? 4 : 2;
        final width = (constraints.maxWidth - AppSpacing.md * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [for (final card in cards) SizedBox(width: width, child: card)],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.change,
    this.inPoints = false,
  });

  final String title;
  final String value;

  /// Variación contra el período anterior; `null` si no hay con qué comparar.
  final Decimal? change;

  /// El margen varía en puntos porcentuales, no en porcentaje.
  final bool inPoints;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTypography.amount(22)),
          ),
          const SizedBox(height: AppSpacing.xs),
          _ChangeLabel(change: change, inPoints: inPoints),
        ],
      ),
    );
  }
}

/// Variación con flecha: verde si mejora, roja si empeora, guion si no hay
/// período anterior.
class _ChangeLabel extends StatelessWidget {
  const _ChangeLabel({required this.change, required this.inPoints});

  final Decimal? change;
  final bool inPoints;

  @override
  Widget build(BuildContext context) {
    final change = this.change;
    if (change == null) {
      return Text(
        Strings.statsNoPrevious,
        semanticsLabel: Strings.statsVsPrevious,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      );
    }
    final (color, icon) = switch (change.compareTo(Decimal.zero)) {
      > 0 => (AppColors.success, Icons.arrow_upward_rounded),
      < 0 => (AppColors.error, Icons.arrow_downward_rounded),
      _ => (AppColors.textMuted, Icons.remove_rounded),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            StatsFormat.change(change, inPoints: inPoints),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
