import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/network/paged_list.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';
import 'package:pos_app/features/sales/domain/entities/sales_summary.dart';
import 'package:pos_app/features/sales/presentation/providers/sales_history_providers.dart';

/// Ventas de la tienda activa, día por día. Abre en hoy; se puede retroceder
/// o elegir otra fecha. Cada venta se muestra con su tasa congelada.
class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
  late DateTime _day = _today;

  /// Fecha de calendario de hoy en Caracas.
  DateTime get _today => DateFormatter.caracasDay(DateTime.now());

  bool get _isToday => _day == _today;

  void _shift(int days) => setState(() => _day = DateTime(_day.year, _day.month, _day.day + days));

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2020),
      lastDate: _today,
    );
    if (picked != null) setState(() => _day = DateTime(picked.year, picked.month, picked.day));
  }

  String get _dayLabel {
    final date = DateFormatter.calendarLongDate(_day);
    if (_isToday) return '${Strings.today} · $date';
    final yesterday = DateTime(_today.year, _today.month, _today.day - 1);
    return _day == yesterday ? '${Strings.yesterday} · $date' : date;
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = salesHistoryProvider(_day);
    final summaryProvider = daySalesSummaryProvider(_day);
    final history = ref.watch(historyProvider);
    final summary = ref.watch(summaryProvider);
    final userId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.salesHistoryTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                IconButton(
                  tooltip: Strings.previousDay,
                  onPressed: () => _shift(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _pickDay,
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: Text(
                      _dayLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      semanticsLabel: '${Strings.pickDay}: $_dayLabel',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: Strings.nextDay,
                  onPressed: _isToday ? null : () => _shift(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            child: SectionCard(
              color: AppColors.primarySoft,
              title: Strings.dayTotal.toUpperCase(),
              child: AsyncValueView<SalesSummary>(
                value: summary,
                onRetry: () => ref.invalidate(summaryProvider),
                loading: const SkeletonBox(height: 56),
                data: (loaded) => Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      // Bolívares facturados con la tasa de cada venta, no convertidos hoy.
                      child: DualCurrencyText(
                        amountUsd: loaded.totalUsd,
                        amountVes: loaded.totalVes,
                        size: DualCurrencySize.large,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadius.pillAll,
                      ),
                      child: Text(
                        Strings.salesCount(loaded.salesCount),
                        style: AppTypography.label.copyWith(
                          fontSize: 13,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                ref.invalidate(summaryProvider);
                return ref.refresh(historyProvider.future);
              },
              child: AsyncValueView<PagedList<Sale>>(
                value: history,
                onRetry: () => ref.invalidate(historyProvider),
                isEmpty: (list) => list.items.isEmpty,
                empty: const ScrollableEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: Strings.emptySalesTitle,
                  message: Strings.emptySalesMessage,
                ),
                data: (list) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  itemCount: list.items.length + (list.hasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    if (index == list.items.length) {
                      return LoadMoreButton(
                        label: Strings.loadMore,
                        onLoadMore: ref.read(historyProvider.notifier).loadMore,
                      );
                    }
                    final sale = list.items[index];
                    return _SaleCard(
                      sale: sale,
                      isMine: sale.userId == userId,
                      onTap: () => context.push(RouteNames.saleDetail, extra: sale),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale, required this.isMine, required this.onTap});

  final Sale sale;
  final bool isMine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final methods = {
      for (final payment in sale.payments) Strings.paymentMethod(payment.method),
    }.join(' + ');
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.saleLine(sale.id, DateFormatter.time(sale.createdAt)),
                  style: AppTypography.subtitle,
                ),
                Text(
                  methods,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall,
                ),
                Text(
                  [
                    isMine ? Strings.you : Strings.sessionUser(sale.userId),
                    Strings.cartItems(sale.details.length),
                    if (sale.customerName.isNotEmpty) sale.customerName,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Tasa congelada: los bolívares son los que se facturaron.
          DualCurrencyText(
            amountUsd: sale.totalUsd,
            amountVes: sale.totalVes,
            size: DualCurrencySize.small,
            crossAxisAlignment: CrossAxisAlignment.end,
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
