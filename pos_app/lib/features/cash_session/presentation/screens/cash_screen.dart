import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/connected_branch_header.dart';
import 'package:pos_app/core/widgets/decimal_input_field.dart';
import 'package:pos_app/core/widgets/offline_banner.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/cash_session/domain/entities/cash_session.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';
import 'package:pos_app/features/cash_session/presentation/widgets/cash_summary_view.dart';
import 'package:pos_app/features/cash_session/presentation/widgets/expense_sheet.dart';
import 'package:pos_app/features/pos/presentation/providers/cart_controller.dart';

/// Pestaña Caja: abre el turno o, si ya hay uno, muestra el arqueo en curso,
/// los gastos y el acceso al cierre.
class CashScreen extends ConsumerWidget {
  const CashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);

    return Scaffold(
      appBar: const ConnectedBranchHeader(),
      body: Column(
        children: [
          OfflineBanner(onRetry: () => ref.invalidate(currentSessionProvider)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final current = ref.read(currentSessionProvider).value;
                if (current != null) {
                  ref
                    ..invalidate(sessionSummaryProvider(current.id))
                    ..invalidate(sessionExpensesProvider(current.id));
                }
                await ref.read(currentSessionProvider.notifier).refresh();
              },
              child: AsyncValueView<CashSession?>(
                value: session,
                onRetry: () => ref.invalidate(currentSessionProvider),
                data: (current) => current == null
                    ? const _OpenSessionForm()
                    : _CurrentSessionView(session: current),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenSessionForm extends ConsumerStatefulWidget {
  const _OpenSessionForm();

  @override
  ConsumerState<_OpenSessionForm> createState() => _OpenSessionFormState();
}

class _OpenSessionFormState extends ConsumerState<_OpenSessionForm> {
  final _formKey = GlobalKey<FormState>();
  Decimal? _openingFloat = Decimal.zero;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(currentSessionProvider.notifier).open(openingFloat: _openingFloat!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.cashOpenedSnack)));
      // Si se llegó aquí desde Vender, se vuelve allí con el carrito intacto.
      if (ref.read(returnToSellProvider.notifier).consume()) context.go(RouteNames.sell);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = failure.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = _errorMessage;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SectionCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.onAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(Strings.openCashTitle, style: AppTypography.title),
                const SizedBox(height: AppSpacing.xs),
                Text(Strings.openCashMessage, style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.xl),
                DecimalInputField(
                  label: Strings.openingFloat,
                  prefixText: r'$ ',
                  initialValue: _openingFloat,
                  enabled: !_isSubmitting,
                  large: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null) return Strings.amountRequired;
                    if (value < Decimal.zero) return Strings.amountNotNegative;
                    return null;
                  },
                  onChanged: (value) => _openingFloat = value,
                  onSubmitted: (_) => _submit(),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  FormErrorBanner(errorMessage),
                ],
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: Strings.openCash,
                  icon: Icons.lock_open_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton.icon(
              onPressed: () => context.push(RouteNames.cashHistory),
              icon: const Icon(Icons.history_rounded),
              label: const Text(Strings.cashHistory),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentSessionView extends ConsumerWidget {
  const _CurrentSessionView({required this.session});

  final CashSession session;

  Future<void> _addExpense(BuildContext context) async {
    final saved = await showExpenseSheet(context, sessionId: session.id);
    if (saved && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.expenseSaved)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branch = ref.watch(activeBranchProvider);
    final summary = ref.watch(sessionSummaryProvider(session.id));
    final expenses = ref.watch(sessionExpensesProvider(session.id));
    final isOtherBranch = branch != null && branch.code != session.branchCode;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (isOtherBranch) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: AppRadius.mdAll,
            ),
            child: Text(
              Strings.otherBranchSession(session.branchCode),
              style: AppTypography.body.copyWith(color: AppColors.warning),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        SectionCard(
          color: AppColors.primarySoft,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                child: const Icon(Icons.lock_open_rounded, color: AppColors.primaryDark),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Strings.currentCash, style: AppTypography.title),
                    Text(
                      Strings.openedAt(DateFormatter.dateTime(session.openedAt)),
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      '${Strings.openingFloatShort}: ${MoneyFormatter.usd(session.openingFloat)}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AsyncValueView<List<CashExpense>>(
                value: expenses,
                onRetry: () => ref.invalidate(sessionExpensesProvider(session.id)),
                loading: const SkeletonBox(height: 56),
                isEmpty: (list) => list.isEmpty,
                empty: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(Strings.noExpenses, style: AppTypography.bodySmall),
                ),
                data: (list) =>
                    Column(children: [for (final expense in list) ExpenseTile(expense: expense)]),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: Strings.registerExpense,
                icon: Icons.add_rounded,
                variant: ButtonVariant.outlined,
                onPressed: () => _addExpense(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: Strings.closeCash,
          icon: Icons.lock_rounded,
          tone: ButtonTone.danger,
          onPressed: () => context.push(RouteNames.cashClose(session.id)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: TextButton.icon(
            onPressed: () => context.push(RouteNames.cashHistory),
            icon: const Icon(Icons.history_rounded),
            label: const Text(Strings.cashHistory),
          ),
        ),
      ],
    );
  }
}
