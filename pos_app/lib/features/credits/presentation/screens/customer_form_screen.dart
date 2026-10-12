import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';
import 'package:pos_app/features/credits/presentation/providers/credits_providers.dart';

/// Alta o edición de un cliente a crédito. Con `customer` edita; sin él, crea.
/// Al guardar vuelve atrás con el cliente guardado.
class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({this.customer, super.key});

  final Customer? customer;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  /// Plazo máximo que acepta el backend.
  static const int _maxCreditDays = 365;

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.customer?.name ?? '');
  late final _taxIdController = TextEditingController(text: widget.customer?.taxId ?? '');
  late final _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
  late final _daysController = TextEditingController(text: '${widget.customer?.creditDays ?? 7}');
  late bool _active = widget.customer?.active ?? true;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.customer != null;

  @override
  void dispose() {
    _nameController.dispose();
    _taxIdController.dispose();
    _phoneController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  String? _validateDays(String? value) {
    final days = int.tryParse(value ?? '');
    if (days == null) return Strings.creditDaysRequired;
    if (days > _maxCreditDays) return Strings.creditDaysTooLong(_maxCreditDays);
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
    final draft = CustomerDraft(
      name: _nameController.text,
      taxId: _taxIdController.text,
      phone: _phoneController.text,
      creditDays: int.parse(_daysController.text),
      active: _active,
    );
    try {
      final controller = ref.read(creditsControllerProvider.notifier);
      final customer = widget.customer;
      final saved = customer == null
          ? await controller.createCustomer(draft)
          : await controller.updateCustomer(customer.id, draft);
      if (mounted) Navigator.of(context).pop(saved);
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
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? Strings.editCustomer : Strings.newCustomer)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_isSubmitting,
                autofocus: !_isEditing,
                maxLength: 150,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: Strings.customerNameLabel,
                  counterText: '',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? Strings.customerNameRequired : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _taxIdController,
                enabled: !_isSubmitting,
                maxLength: 20,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: Strings.customerTaxIdOptional,
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _phoneController,
                enabled: !_isSubmitting,
                maxLength: 30,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: Strings.customerPhone,
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _daysController,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: Strings.creditDaysLabel,
                  helperText: Strings.creditDaysHelper,
                  helperMaxLines: 2,
                ),
                validator: _validateDays,
                onFieldSubmitted: (_) => _submit(),
              ),
              if (_isEditing) ...[
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(Strings.activeCustomer, style: AppTypography.subtitle),
                  subtitle: Text(Strings.activeCustomerHint, style: AppTypography.bodySmall),
                  value: _active,
                  onChanged: _isSubmitting ? null : (value) => setState(() => _active = value),
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FormErrorBanner(errorMessage),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: _isEditing ? Strings.saveChanges : Strings.createCustomer,
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
