import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/currency/currency_converter.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/decimal_input_field.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/credits/domain/entities/credit_payment.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';
import 'package:pos_app/features/credits/presentation/providers/credits_providers.dart';

/// Abre la hoja para cobrar un abono. Devuelve el abono registrado, o `null`.
Future<CreditPayment?> showCreditPaymentSheet(BuildContext context, {required Customer customer}) {
  return showModalBottomSheet<CreditPayment>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => CreditPaymentSheet(customer: customer),
  );
}

/// Cobro de un abono. Se propone el saldo completo en la moneda elegida: en
/// bolívares, el saldo en USD por la tasa del BCV del día (lo calcula el backend).
class CreditPaymentSheet extends ConsumerStatefulWidget {
  const CreditPaymentSheet({required this.customer, super.key});

  final Customer customer;

  @override
  ConsumerState<CreditPaymentSheet> createState() => _CreditPaymentSheetState();
}

class _CreditPaymentSheetState extends ConsumerState<CreditPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cashUsd;
  late Decimal? _amount = widget.customer.balanceUsd;

  /// Cambia con cada "Paga todo" o cambio de método para reiniciar el campo.
  int _amountVersion = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  Customer get _customer => widget.customer;
  Decimal? get _rate => _customer.paymentRate;
  bool get _canReceiveBs => _rate != null && _customer.balanceVes != null;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  /// Saldo completo en la moneda del método.
  Decimal? _fullAmount(PaymentMethod method) =>
      method.currency == Currency.usd ? _customer.balanceUsd : _customer.balanceVes;

  void _selectMethod(PaymentMethod method) {
    setState(() {
      _method = method;
      _amount = _fullAmount(method);
      _amountVersion++;
      _errorMessage = null;
    });
  }

  void _payAll() {
    setState(() {
      _amount = _fullAmount(_method);
      _amountVersion++;
    });
  }

  /// Lo que descontaría el abono, en USD, con la misma conversión del backend.
  Decimal? _amountUsd(Decimal? amount) {
    if (amount == null) return null;
    if (_method.currency == Currency.usd) return amount;
    final rate = _rate;
    return rate == null ? null : CurrencyConverter.vesToUsd(amount, rate);
  }

  String? _validateAmount(Decimal? value) {
    if (value == null) return Strings.amountRequired;
    if (value <= Decimal.zero) return Strings.mustBePositive;
    final usd = _amountUsd(value);
    if (usd != null && usd - _customer.balanceUsd > paymentToleranceUsd) {
      return Strings.paymentExceeds(
        _method.currency == Currency.usd
            ? MoneyFormatter.usd(_customer.balanceUsd)
            : MoneyFormatter.ves(_customer.balanceVes!),
      );
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final payment = await ref
          .read(creditsControllerProvider.notifier)
          .registerPayment(
            _customer.id,
            NewCreditPayment(
              method: _method,
              amount: _amount!,
              approvalReference: _referenceController.text,
            ),
          );
      if (mounted) Navigator.of(context).pop(payment);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = failure.code == 'no_open_session'
            ? Strings.paymentNeedsOpenCash
            : failure.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = _errorMessage;
    final rate = _rate;
    final isVes = _method.currency == Currency.ves;
    final equivalentUsd = isVes ? _amountUsd(_amount) : null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Strings.paymentTitle, style: AppTypography.title),
              Text(_customer.name, style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Strings.owes} ${MoneyFormatter.usd(_customer.balanceUsd)}',
                      style: AppTypography.amount(20, color: AppColors.warning),
                    ),
                    if (_customer.balanceVes != null)
                      Text(
                        Strings.balanceInBs(MoneyFormatter.ves(_customer.balanceVes!)),
                        style: AppTypography.bodySmall,
                      ),
                    if (rate != null)
                      Text(
                        Strings.bcvRateToday(MoneyFormatter.rate(rate)),
                        style: AppTypography.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(Strings.paymentMethodLabel, style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final method in PaymentMethod.money)
                    ChoiceChip(
                      label: Text(Strings.paymentMethod(method)),
                      selected: _method == method,
                      onSelected:
                          _isSubmitting || (method.currency == Currency.ves && !_canReceiveBs)
                          ? null
                          : (_) => _selectMethod(method),
                    ),
                ],
              ),
              if (!_canReceiveBs) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(Strings.noBcvRateForBs, style: AppTypography.bodySmall),
              ],
              const SizedBox(height: AppSpacing.lg),
              DecimalInputField(
                key: ValueKey('amount-$_amountVersion'),
                label: Strings.paymentAmount,
                prefixText: isVes ? 'Bs ' : r'$ ',
                initialValue: _amount,
                enabled: !_isSubmitting,
                large: true,
                textInputAction: _method.acceptsReference
                    ? TextInputAction.next
                    : TextInputAction.done,
                validator: _validateAmount,
                onChanged: (value) => setState(() => _amount = value),
              ),
              Row(
                children: [
                  if (equivalentUsd != null)
                    Expanded(
                      child: Text(
                        '≈ ${MoneyFormatter.usd(equivalentUsd)}',
                        style: AppTypography.bodySmall,
                      ),
                    )
                  else
                    const Spacer(),
                  TextButton(
                    onPressed: _isSubmitting ? null : _payAll,
                    child: const Text(Strings.payAll),
                  ),
                ],
              ),
              if (_method.acceptsReference) ...[
                TextFormField(
                  controller: _referenceController,
                  enabled: !_isSubmitting,
                  maxLength: 50,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: Strings.paymentReference,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Text(Strings.balanceBsNote, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FormErrorBanner(errorMessage),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: Strings.registerPayment,
                icon: Icons.check_rounded,
                tone: ButtonTone.success,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
