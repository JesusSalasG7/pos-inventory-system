import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
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
import 'package:pos_app/features/exchange_rate/domain/entities/pricing_settings.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/pricing_settings_provider.dart';
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

  Future<void> _syncBcv(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final changed = await ref.read(activeExchangeRateProvider.notifier).syncWithBcv();
      messenger.showSnackBar(
        SnackBar(content: Text(changed ? Strings.syncBcvChanged : Strings.syncBcvUnchanged)),
      );
    } on Failure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeExchangeRateProvider);
    final bcv = ref.watch(bcvRateProvider);
    final history = ref.watch(rateHistoryProvider);
    final isManager = ref.watch(currentUserProvider)?.isManager ?? false;
    final settings = ref.watch(pricingSettingsControllerProvider).value ?? const PricingSettings();
    final usesOwnRate = settings.rateMode == RateMode.manual;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.exchangeRateTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(bcvRateProvider)
            ..invalidate(rateHistoryProvider)
            ..invalidate(pricingSettingsControllerProvider);
          await ref.read(activeExchangeRateProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            SectionCard(
              color: AppColors.primarySoft,
              title: Strings.activeRate.toUpperCase(),
              child: AsyncValueView<ExchangeRate?>(
                value: active,
                onRetry: () => ref.invalidate(activeExchangeRateProvider),
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
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${Strings.rateUnit} ${MoneyFormatter.rate(rate.rate)}',
                            style: AppTypography.amount(34),
                          ),
                          Text(
                            Strings.rateDayLine(rate.source, DateFormatter.calendarDate(rate.day)),
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            usesOwnRate ? Strings.ownRateNote : Strings.autoRateNote,
                            style: AppTypography.bodySmall.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              title: Strings.bcvRate.toUpperCase(),
              child: _BcvContent(bcv: bcv, activeRate: active.value?.rate),
            ),
            if (isManager) ...[
              const SizedBox(height: AppSpacing.md),
              _PricingSettingsCard(settings: settings),
              const SizedBox(height: AppSpacing.lg),
              // Con tasa propia el BCV no reemplaza la activa: no hay nada que sincronizar.
              if (!usesOwnRate) ...[
                _SyncBcvButton(onSync: () => _syncBcv(context, ref)),
                const SizedBox(height: AppSpacing.sm),
              ],
              PrimaryButton(
                label: Strings.registerRate,
                icon: Icons.add_rounded,
                variant: usesOwnRate ? ButtonVariant.filled : ButtonVariant.outlined,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${Strings.rateSource(rate.source)} · '
                                  '${DateFormatter.calendarDate(rate.day)}',
                                  style: AppTypography.body,
                                ),
                                Text(
                                  DateFormatter.dateTime(rate.createdAt),
                                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                                ),
                              ],
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

/// Ajustes del gerente: con qué tasa se vende (BCV o la propia) y si los
/// precios en bolívares se redondean hacia arriba.
class _PricingSettingsCard extends ConsumerStatefulWidget {
  const _PricingSettingsCard({required this.settings});

  final PricingSettings settings;

  @override
  ConsumerState<_PricingSettingsCard> createState() => _PricingSettingsCardState();
}

class _PricingSettingsCardState extends ConsumerState<_PricingSettingsCard> {
  bool _isSaving = false;

  /// Guarda un cambio y avisa del resultado; un rechazo del backend se muestra tal cual.
  Future<void> _save(Future<void> Function() change, String successMessage) async {
    if (_isSaving) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);
    try {
      await change();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successMessage)));
    } on Failure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final controller = ref.read(pricingSettingsControllerProvider.notifier);
    return SectionCard(
      title: Strings.pricingSettingsTitle.toUpperCase(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<RateMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: RateMode.bcv, label: Text(Strings.rateModeBcv)),
                ButtonSegment(value: RateMode.manual, label: Text(Strings.rateModeManual)),
              ],
              selected: {settings.rateMode},
              onSelectionChanged: _isSaving
                  ? null
                  : (selection) => _save(
                      () => controller.setRateMode(selection.first),
                      selection.first == RateMode.bcv
                          ? Strings.rateModeBcvSaved
                          : Strings.rateModeManualSaved,
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            settings.rateMode == RateMode.bcv
                ? Strings.rateModeBcvHint
                : Strings.rateModeManualHint,
            style: AppTypography.bodySmall,
          ),
          const Divider(height: AppSpacing.xl),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(Strings.roundVesUp, style: AppTypography.subtitle),
            subtitle: Text(Strings.roundVesUpHint, style: AppTypography.bodySmall),
            value: settings.roundVesUp,
            onChanged: _isSaving
                ? null
                : (enabled) => _save(
                    () => controller.setRoundVesUp(enabled: enabled),
                    enabled ? Strings.roundVesUpOn : Strings.roundVesUpOff,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Botón de sincronización con el BCV, con su propio estado de carga.
class _SyncBcvButton extends StatefulWidget {
  const _SyncBcvButton({required this.onSync});

  final Future<void> Function() onSync;

  @override
  State<_SyncBcvButton> createState() => _SyncBcvButtonState();
}

class _SyncBcvButtonState extends State<_SyncBcvButton> {
  bool _isSyncing = false;

  Future<void> _sync() async {
    setState(() => _isSyncing = true);
    try {
      await widget.onSync();
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: Strings.syncBcv,
      icon: Icons.sync_rounded,
      isLoading: _isSyncing,
      onPressed: _sync,
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
      await ref.read(activeExchangeRateProvider.notifier).register(quantizeRate(_rate!));
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
