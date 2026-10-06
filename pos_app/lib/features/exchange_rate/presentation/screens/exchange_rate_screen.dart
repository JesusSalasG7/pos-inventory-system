import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/network/paged_list.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/decimal_input_field.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/rate_history_provider.dart';

/// Tasa de cambio: la activa, la del BCV como referencia y el histórico.
/// Un MANAGER puede registrar una tasa nueva.
class ExchangeRateScreen extends ConsumerWidget {
  const ExchangeRateScreen({super.key});

  Future<void> _register(BuildContext context) async {
    final saved = await showDialog<bool>(context: context, builder: (_) => const _NewRateDialog());
    if ((saved ?? false) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(Strings.rateSaved)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeRateProvider);
    final bcv = ref.watch(bcvRateProvider);
    final history = ref.watch(rateHistoryProvider);
    final isManager = ref.watch(currentUserProvider)?.isManager ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.exchangeRateTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(bcvRateProvider)
            ..invalidate(rateHistoryProvider);
          await ref.read(activeRateProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            SectionCard(
              color: AppColors.primarySoft,
              title: Strings.activeRate.toUpperCase(),
              child: AsyncValueView<Decimal?>(
                value: active,
                onRetry: () => ref.invalidate(activeRateProvider),
                loading: const SkeletonBox(height: 44),
                data: (rate) => rate == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Strings.rateNotSet, style: AppTypography.amount(28)),
                          const SizedBox(height: AppSpacing.xs),
                          Text(Strings.rateNotSetHint, style: AppTypography.bodySmall),
                        ],
                      )
                    : Text(
                        '${Strings.rateUnit} ${MoneyFormatter.rate(rate)}',
                        style: AppTypography.amount(34),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              title: Strings.bcvRate.toUpperCase(),
              child: _BcvContent(bcv: bcv, activeRate: active.value),
            ),
            if (isManager) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: Strings.registerRate,
                icon: Icons.add_rounded,
                onPressed: () => _register(context),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text(Strings.rateHistory, style: AppTypography.title),
            const SizedBox(height: AppSpacing.md),
            AsyncValueView<PagedList<ExchangeRate>>(
              value: history,
              onRetry: () => ref.invalidate(rateHistoryProvider),
              loading: const SkeletonBox(height: 120),
              isEmpty: (list) => list.items.isEmpty,
              empty: const EmptyState(
                icon: Icons.currency_exchange_rounded,
                title: Strings.emptyRatesTitle,
                message: Strings.emptyRatesMessage,
              ),
              data: (list) => SectionCard(
                child: Column(
                  children: [
                    for (final (index, rate) in list.items.indexed) ...[
                      if (index > 0) const Divider(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormatter.dateTime(rate.createdAt),
                              style: AppTypography.body,
                            ),
                          ),
                          Text(MoneyFormatter.rate(rate.rate), style: AppTypography.amount(16)),
                        ],
                      ),
                    ],
                    if (list.hasMore) ...[
                      const SizedBox(height: AppSpacing.sm),
                      LoadMoreButton(
                        label: Strings.loadMore,
                        onLoadMore: ref.read(rateHistoryProvider.notifier).loadMore,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BcvContent extends ConsumerWidget {
  const _BcvContent({required this.bcv, required this.activeRate});

  final AsyncValue<BcvRate> bcv;
  final Decimal? activeRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bcv.hasValue) {
      final value = bcv.requireValue;
      final active = activeRate;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${Strings.rateUnit} ${MoneyFormatter.rate(value.rate)}',
            style: AppTypography.amount(24),
          ),
          Text(
            Strings.bcvUpdatedAt(DateFormatter.date(value.updatedAt)),
            style: AppTypography.bodySmall,
          ),
          if (active != null)
            Text(
              Strings.rateDifference(
                MoneyFormatter.number(active - value.rate, minDecimals: 2, maxDecimals: 4),
              ),
              style: AppTypography.bodySmall,
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(Strings.bcvReferenceNote, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
        ],
      );
    }
    if (bcv.hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Failure.from(bcv.error!).message, style: AppTypography.body),
          TextButton(
            onPressed: () => ref.invalidate(bcvRateProvider),
            child: const Text(Strings.retry),
          ),
        ],
      );
    }
    return const SkeletonBox(height: 44);
  }
}

class _NewRateDialog extends ConsumerStatefulWidget {
  const _NewRateDialog();

  @override
  ConsumerState<_NewRateDialog> createState() => _NewRateDialogState();
}

class _NewRateDialogState extends ConsumerState<_NewRateDialog> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  Decimal? get _rate => tryParseUserDecimal(_controller.text);
  bool get _isValid => (_rate ?? Decimal.zero) > Decimal.zero;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_isValid) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(activeRateProvider.notifier).register(quantizeRate(_rate!));
      if (mounted) Navigator.of(context).pop(true);
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
    final bcv = ref.watch(bcvRateProvider).value;
    final errorMessage = _errorMessage;
    return AlertDialog(
      title: const Text(Strings.newRateTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecimalInputField(
              controller: _controller,
              label: Strings.newRateLabel,
              maxDecimals: rateScale,
              autofocus: true,
              large: true,
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.done,
              validator: (value) =>
                  (value ?? Decimal.zero) > Decimal.zero ? null : Strings.rateMustBePositive,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
            ),
            if (bcv != null)
              TextButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() => _controller.text = DecimalInputField.textOf(bcv.rate)),
                icon: const Icon(Icons.account_balance_rounded),
                label: Text('${Strings.useBcvRate} (${MoneyFormatter.rate(bcv.rate)})'),
              ),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              FormErrorBanner(errorMessage),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text(Strings.cancel),
        ),
        FilledButton(
          onPressed: _isValid && !_isSubmitting ? _submit : null,
          child: const Text(Strings.save),
        ),
      ],
    );
  }
}
