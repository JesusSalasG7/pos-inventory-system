import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/network/paged_list.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/features/cash_session/domain/entities/cash_session.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';
import 'package:pos_app/features/cash_session/presentation/widgets/cash_summary_view.dart';

/// Historial de cajas de la tienda activa, de la más reciente a la más antigua.
class CashHistoryScreen extends ConsumerWidget {
  const CashHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(cashHistoryProvider);
    final userId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.cashHistory)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(cashHistoryProvider.future),
        child: AsyncValueView<PagedList<CashSession>>(
          value: history,
          onRetry: () => ref.invalidate(cashHistoryProvider),
          isEmpty: (list) => list.items.isEmpty,
          empty: const EmptyState(
            icon: Icons.history_rounded,
            title: Strings.emptyCashHistoryTitle,
            message: Strings.emptyCashHistoryMessage,
          ),
          data: (list) => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: list.items.length + (list.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index == list.items.length) {
                return LoadMoreButton(
                  label: Strings.loadMore,
                  onLoadMore: ref.read(cashHistoryProvider.notifier).loadMore,
                );
              }
              final session = list.items[index];
              return _SessionCard(
                session: session,
                isMine: session.userId == userId,
                onTap: () => context.push(RouteNames.cashSessionDetail, extra: session),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.isMine, required this.onTap});

  final CashSession session;
  final bool isMine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final closedAt = session.closedAt;
    final difference = session.differenceUsd;
    return SectionCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Strings.sessionNumber(session.id), style: AppTypography.subtitle),
                Text(
                  Strings.sessionOpenedOn(DateFormatter.dateTime(session.openedAt)),
                  style: AppTypography.bodySmall,
                ),
                if (closedAt != null)
                  Text(
                    Strings.sessionClosedOn(DateFormatter.dateTime(closedAt)),
                    style: AppTypography.bodySmall,
                  ),
                Text(
                  isMine ? Strings.mySession : Strings.sessionUser(session.userId),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (session.isOpen)
                  const _StatusPill(label: Strings.openSession, isOpen: true)
                else if (difference != null)
                  DifferenceBadge(differenceUsd: difference)
                else
                  const _StatusPill(label: Strings.closedSession, isOpen: false),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.isOpen});

  final String label;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.successSoft : AppColors.surfaceMuted,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          fontSize: 13,
          color: isOpen ? AppColors.success : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Detalle de una caja del historial: datos del turno, arqueo y gastos.
///
/// El backend no tiene un endpoint para leer una caja por id, así que la caja
/// llega desde la lista.
class CashSessionDetailScreen extends ConsumerWidget {
  const CashSessionDetailScreen({required this.session, super.key});

  final CashSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(sessionSummaryProvider(session.id));
    final expenses = ref.watch(sessionExpensesProvider(session.id));
    final closedAt = session.closedAt;
    final difference = session.differenceUsd;
    final countedUsd = session.countedAmountUsd;
    final countedVes = session.countedAmountVes;

    return Scaffold(
      appBar: AppBar(title: Text(Strings.sessionNumber(session.id))),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SectionCard(
            title: Strings.sessionDetail.toUpperCase(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.sessionOpenedOn(DateFormatter.dateTime(session.openedAt)),
                  style: AppTypography.body,
                ),
                if (closedAt != null)
                  Text(
                    Strings.sessionClosedOn(DateFormatter.dateTime(closedAt)),
                    style: AppTypography.body,
                  ),
                Text(
                  '${Strings.openingFloatShort}: ${MoneyFormatter.usd(session.openingFloat)}',
                  style: AppTypography.body,
                ),
                if (countedUsd != null && countedVes != null) ...[
                  const Divider(height: AppSpacing.xl),
                  MoneyLine(label: Strings.counted, usd: countedUsd, ves: countedVes),
                ],
                if (difference != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  DifferenceBadge(differenceUsd: difference, large: true),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: Strings.expectedCash.toUpperCase(),
            child: AsyncValueView<CashCountSummary>(
              value: summary,
              onRetry: () => ref.invalidate(sessionSummaryProvider(session.id)),
              loading: const SkeletonBox(height: 160),
              data: (loaded) => CashSummaryView(summary: loaded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: Strings.expenses.toUpperCase(),
            child: AsyncValueView<List<CashExpense>>(
              value: expenses,
              onRetry: () => ref.invalidate(sessionExpensesProvider(session.id)),
              loading: const SkeletonBox(height: 56),
              isEmpty: (list) => list.isEmpty,
              empty: Text(Strings.noExpenses, style: AppTypography.bodySmall),
              data: (list) =>
                  Column(children: [for (final expense in list) ExpenseTile(expense: expense)]),
            ),
          ),
        ],
      ),
    );
  }
}
