import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/connected_branch_header.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';
import 'package:pos_app/core/widgets/offline_banner.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/features/cash_session/domain/entities/cash_session.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';
import 'package:pos_app/features/cash_session/presentation/widgets/expense_sheet.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/rate_history_provider.dart';
import 'package:pos_app/features/home/presentation/providers/dashboard_providers.dart';
import 'package:pos_app/features/sales/domain/entities/sales_summary.dart';

/// Inicio: saludo, ventas del día, estado de la caja, stock mínimo y tasa.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(todaySalesSummaryProvider)
      ..invalidate(lowStockCountProvider)
      ..invalidate(bcvRateProvider)
      ..invalidate(currentSessionProvider);
    await ref.read(activeRateProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final firstName = (user?.fullName ?? '').trim().split(RegExp(r'\s+')).first;

    return Scaffold(
      appBar: const ConnectedBranchHeader(),
      body: Column(
        children: [
          OfflineBanner(onRetry: () => _refresh(ref)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Strings.greeting(firstName.isEmpty ? (user?.username ?? '') : firstName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headline,
                        ),
                      ),
                      if (user != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: AppRadius.pillAll,
                          ),
                          child: Text(
                            Strings.role(user.role),
                            style: AppTypography.label.copyWith(
                              fontSize: 13,
                              color: AppColors.onAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SalesTodayCard(),
                  const SizedBox(height: AppSpacing.md),
                  const _CashCard(),
                  const SizedBox(height: AppSpacing.md),
                  const _LowStockCard(),
                  const SizedBox(height: AppSpacing.md),
                  const _RateCard(),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: Strings.priceListTitle,
                    icon: Icons.sell_rounded,
                    variant: ButtonVariant.outlined,
                    onPressed: () => context.push(RouteNames.priceList),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesTodayCard extends ConsumerWidget {
  const _SalesTodayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(todaySalesSummaryProvider);
    return SectionCard(
      title: Strings.salesToday.toUpperCase(),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: () => context.push(RouteNames.salesHistory),
      child: AsyncValueView<SalesSummary>(
        value: summary,
        onRetry: () => ref.invalidate(todaySalesSummaryProvider),
        loading: const SkeletonBox(height: 64),
        data: (loaded) => Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              // Los bolívares son los facturados (tasa de cada venta), no una conversión de hoy.
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
                color: AppColors.primarySoft,
                borderRadius: AppRadius.pillAll,
              ),
              child: Text(
                Strings.salesCount(loaded.salesCount),
                style: AppTypography.label.copyWith(fontSize: 13, color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashCard extends ConsumerWidget {
  const _CashCard();

  Future<void> _addExpense(BuildContext context, int sessionId) async {
    final saved = await showExpenseSheet(context, sessionId: sessionId);
    if (saved && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.expenseSaved)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final branch = ref.watch(activeBranchProvider);

    return SectionCard(
      title: Strings.cashTitle.toUpperCase(),
      child: AsyncValueView<CashSession?>(
        value: session,
        onRetry: () => ref.invalidate(currentSessionProvider),
        loading: const SkeletonBox(height: 120),
        data: (current) {
          final isOtherBranch = current != null && current.branchCode != branch?.code;
          final title = current == null
              ? Strings.cashCardClosed
              : isOtherBranch
              ? Strings.cashCardOtherBranch
              : Strings.cashCardOpen;
          final detail = current == null
              ? Strings.cashCardClosedHint
              : Strings.openedAt(DateFormatter.dateTime(current.openedAt));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.title),
              Text(detail, style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.lg),
              if (current == null)
                PrimaryButton(
                  label: Strings.openCash,
                  icon: Icons.lock_open_rounded,
                  onPressed: () => context.go(RouteNames.cash),
                )
              else
                PrimaryButton(
                  label: Strings.closeCash,
                  icon: Icons.lock_rounded,
                  tone: ButtonTone.danger,
                  onPressed: () => context.push(RouteNames.cashClose(current.id)),
                ),
              const SizedBox(height: AppSpacing.sm),
              // Sin caja abierta no hay dónde registrar el gasto.
              PrimaryButton(
                label: Strings.registerExpense,
                icon: Icons.payments_outlined,
                variant: ButtonVariant.outlined,
                onPressed: current == null ? null : () => _addExpense(context, current.id),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LowStockCard extends ConsumerWidget {
  const _LowStockCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(lowStockCountProvider);
    return SectionCard(
      title: Strings.lowStockTitle.toUpperCase(),
      onTap: () => context.go(RouteNames.inventory),
      child: AsyncValueView<int>(
        value: count,
        onRetry: () => ref.invalidate(lowStockCountProvider),
        loading: const SkeletonBox(height: 44),
        data: (loaded) {
          final hasAlerts = loaded > 0;
          return Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasAlerts ? AppColors.warningSoft : AppColors.successSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasAlerts ? Icons.warning_amber_rounded : Icons.check_rounded,
                  color: hasAlerts ? AppColors.warning : AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  hasAlerts ? Strings.lowStockCount(loaded) : Strings.lowStockNone,
                  style: AppTypography.subtitle,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          );
        },
      ),
    );
  }
}

class _RateCard extends ConsumerWidget {
  const _RateCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeRateProvider);
    final bcv = ref.watch(bcvRateProvider);
    final activeRate = active.value;
    final bcvText = bcv.hasValue
        ? MoneyFormatter.rate(bcv.requireValue.rate)
        : bcv.hasError
        ? Strings.bcvUnavailable
        : Strings.loading;

    return SectionCard(
      title: Strings.rateCardTitle.toUpperCase(),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: () => context.push(RouteNames.exchangeRate),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _RateValue(
                  label: Strings.activeRate,
                  value: active.isLoading && !active.hasValue
                      ? Strings.loading
                      : activeRate == null
                      ? Strings.rateNotSet
                      : MoneyFormatter.rate(activeRate),
                  highlighted: true,
                ),
              ),
              Expanded(
                child: _RateValue(label: Strings.bcvRate, value: bcvText),
              ),
            ],
          ),
          if (!active.isLoading && activeRate == null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              Strings.rateNotSetHint,
              style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
            ),
          ],
        ],
      ),
    );
  }
}

class _RateValue extends StatelessWidget {
  const _RateValue({required this.label, required this.value, this.highlighted = false});

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: highlighted
              ? AppTypography.amount(20)
              : AppTypography.amountSecondary(18, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
