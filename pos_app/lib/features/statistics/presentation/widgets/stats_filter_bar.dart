import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/presentation/providers/statistics_providers.dart';

/// Filtros globales: el período y, si se entró en una categoría, un chip para
/// volver a la vista general.
class StatsFilterBar extends ConsumerWidget {
  const StatsFilterBar({super.key});

  static String _label(StatsRange range, StatsPeriod period) => switch (range) {
    StatsRange.days7 => Strings.statsRange7,
    StatsRange.days30 => Strings.statsRange30,
    StatsRange.days90 => Strings.statsRange90,
    StatsRange.custom => Strings.statsRangeCustom,
  };

  Future<void> _pickPeriod(BuildContext context, WidgetRef ref, StatsFilter filter) async {
    final today = DateFormatter.caracasDay(DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
      initialDateRange: DateTimeRange(start: filter.period.from, end: filter.period.to),
      helpText: Strings.statsPickPeriod,
    );
    if (picked == null) return;
    ref.read(statsFilterControllerProvider.notifier).selectCustomPeriod(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(statsFilterControllerProvider);
    final controller = ref.read(statsFilterControllerProvider.notifier);
    final category = filter.category;
    final isCustom = filter.range == StatsRange.custom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final range in StatsRange.values) ...[
                ChoiceChip(
                  key: ValueKey('stats-range-${range.name}'),
                  label: Text(
                    range == StatsRange.custom && isCustom
                        ? '${DateFormatter.calendarDayMonth(filter.period.from)} – '
                              '${DateFormatter.calendarDayMonth(filter.period.to)}'
                        : _label(range, filter.period),
                  ),
                  avatar: range == StatsRange.custom
                      ? const Icon(Icons.date_range_rounded, size: 18)
                      : null,
                  showCheckmark: false,
                  selected: filter.range == range,
                  onSelected: (_) => range == StatsRange.custom
                      ? _pickPeriod(context, ref, filter)
                      : controller.selectRange(range),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
        if (category != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: InputChip(
              key: const ValueKey('stats-category-chip'),
              avatar: const Icon(Icons.category_rounded, size: 18),
              label: Text(category.name),
              deleteButtonTooltipMessage: Strings.statsBackToOverview,
              onDeleted: controller.clearCategory,
            ),
          ),
      ],
    );
  }
}
