import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/decimal_input_field.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';

/// Abre la hoja para registrar un gasto de caja chica. Devuelve `true` si se guardó.
Future<bool> showExpenseSheet(BuildContext context, {required int sessionId}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => _ExpenseSheet(sessionId: sessionId),
  );
  return saved ?? false;
}

class _ExpenseSheet extends ConsumerStatefulWidget {
  const _ExpenseSheet({required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<_ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends ConsumerState<_ExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  Currency _currency = Currency.usd;
  Decimal? _amount;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(currentSessionProvider.notifier)
          .registerExpense(
            sessionId: widget.sessionId,
            reason: _reasonController.text,
            amount: _amount!,
            currency: _currency,
          );
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
    final errorMessage = _errorMessage;
    return Padding(
      // La hoja sube con el teclado.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Strings.registerExpense, style: AppTypography.title),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _reasonController,
                enabled: !_isSubmitting,
                autofocus: true,
                maxLength: 255,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: Strings.expenseReason,
                  hintText: Strings.expenseReasonHint,
                  counterText: '',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? Strings.expenseReasonRequired : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<Currency>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: Currency.usd, label: Text('\$ ${Strings.dollars}')),
                    ButtonSegment(value: Currency.ves, label: Text('Bs ${Strings.bolivars}')),
                  ],
                  selected: {_currency},
                  onSelectionChanged: _isSubmitting
                      ? null
                      : (selection) => setState(() => _currency = selection.first),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              DecimalInputField(
                label: Strings.expenseAmount,
                prefixText: _currency == Currency.usd ? r'$ ' : 'Bs ',
                enabled: !_isSubmitting,
                large: true,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null) return Strings.amountRequired;
                  if (value <= Decimal.zero) return Strings.mustBePositive;
                  return null;
                },
                onChanged: (value) => _amount = value,
                onSubmitted: (_) => _submit(),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FormErrorBanner(errorMessage),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: Strings.registerExpense,
                icon: Icons.check_rounded,
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
