import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/confirm_dialog.dart';
import 'package:pos_app/core/widgets/decimal_input_field.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/cash_session/domain/cash_count.dart';
import 'package:pos_app/features/cash_session/domain/entities/cash_session.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';
import 'package:pos_app/features/cash_session/presentation/widgets/cash_summary_view.dart';
import 'package:pos_app/features/cash_session/presentation/widgets/sales_report_view.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';

/// Arqueo y cierre: se compara lo esperado con lo contado en cada moneda y se
/// muestra en vivo la diferencia estimada. La definitiva la calcula el backend.
/// Al cerrar, la misma pantalla muestra el resultado: la diferencia del
/// arqueo y el resumen de lo vendido en el turno.
class CloseSessionScreen extends ConsumerStatefulWidget {
  const CloseSessionScreen({required this.sessionId, super.key});

  final int sessionId;

  @override
  ConsumerState<CloseSessionScreen> createState() => _CloseSessionScreenState();
}

class _CloseSessionScreenState extends ConsumerState<CloseSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  Decimal? _countedUsd;
  Decimal? _countedVes;
  bool _isSubmitting = false;
  String? _errorMessage;

  /// Caja ya cerrada: la pantalla pasa a mostrar el resultado del cierre.
  CashSession? _closed;

  String? _validate(Decimal? value) {
    if (value == null) return Strings.amountRequired;
    if (value < Decimal.zero) return Strings.amountNotNegative;
    return null;
  }

  Decimal? _estimate(CashCountSummary summary, Decimal? rate) {
    final countedUsd = _countedUsd;
    final countedVes = _countedVes;
    if (countedUsd == null || countedVes == null || rate == null) return null;
    return CashCount.differenceUsd(
      countedUsd: countedUsd,
      countedVes: countedVes,
      expectedUsd: summary.expectedCashUsd,
      expectedVes: summary.expectedCashVes,
      usdToVesRate: rate,
    );
  }

  Future<void> _submit(Decimal? estimate) async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final confirmed = await showConfirmDialog(
      context,
      title: Strings.closeCashConfirmTitle,
      message: Strings.closeCashConfirmMessage,
      confirmLabel: Strings.closeCash,
      isDestructive: true,
      content: estimate == null ? null : DifferenceBadge(differenceUsd: estimate),
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final closed = await ref
          .read(currentSessionProvider.notifier)
          .close(
            sessionId: widget.sessionId,
            countedAmountUsd: _countedUsd!,
            countedAmountVes: _countedVes!,
          );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _closed = closed;
      });
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
    final summary = ref.watch(sessionSummaryProvider(widget.sessionId));
    final rate = ref.watch(activeRateProvider).value;
    final errorMessage = _errorMessage;
    final closed = _closed;
    if (closed != null) return _ClosedResult(session: closed);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.cashCountTitle)),
      body: AsyncValueView<CashCountSummary>(
        value: summary,
        onRetry: () => ref.invalidate(sessionSummaryProvider(widget.sessionId)),
        data: (loaded) {
          final estimate = _estimate(loaded, rate);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                SectionCard(
                  title: Strings.expected.toUpperCase(),
                  child: CashSummaryView(summary: loaded),
                ),
                const SizedBox(height: AppSpacing.md),
                SectionCard(
                  title: Strings.counted.toUpperCase(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Strings.cashCountMessage, style: AppTypography.bodySmall),
                      const SizedBox(height: AppSpacing.lg),
                      DecimalInputField(
                        label: Strings.countedUsd,
                        prefixText: r'$ ',
                        enabled: !_isSubmitting,
                        large: true,
                        textInputAction: TextInputAction.next,
                        validator: _validate,
                        onChanged: (value) => setState(() => _countedUsd = value),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      DecimalInputField(
                        label: Strings.countedVes,
                        prefixText: 'Bs ',
                        enabled: !_isSubmitting,
                        large: true,
                        textInputAction: TextInputAction.done,
                        validator: _validate,
                        onChanged: (value) => setState(() => _countedVes = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (rate == null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: const BoxDecoration(
                      color: AppColors.warningSoft,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Text(
                      Strings.noRateForCount,
                      style: AppTypography.body.copyWith(color: AppColors.warning),
                    ),
                  )
                else
                  SectionCard(
                    title: Strings.estimatedDifference.toUpperCase(),
                    child: estimate == null
                        ? Text(Strings.cashCountMessage, style: AppTypography.bodySmall)
                        : DifferenceBadge(differenceUsd: estimate, large: true),
                  ),
                if (errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  FormErrorBanner(errorMessage),
                ],
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: Strings.closeCash,
                  icon: Icons.lock_rounded,
                  tone: ButtonTone.danger,
                  isLoading: _isSubmitting,
                  onPressed: rate == null ? null : () => _submit(estimate),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Resultado del cierre: diferencia definitiva (la que devolvió el backend) y
/// resumen de lo vendido, con inversión y ganancia.
class _ClosedResult extends StatelessWidget {
  const _ClosedResult({required this.session});

  final CashSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.cashClosedTitle)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: PrimaryButton(
          label: Strings.done,
          icon: Icons.check_rounded,
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SectionCard(
            title: Strings.finalDifference.toUpperCase(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Strings.cashClosedMessage, style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.md),
                DifferenceBadge(differenceUsd: session.differenceUsd ?? Decimal.zero, large: true),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(Strings.salesReportTitle, style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          SessionSalesReportSection(sessionId: session.id),
        ],
      ),
    );
  }
}
