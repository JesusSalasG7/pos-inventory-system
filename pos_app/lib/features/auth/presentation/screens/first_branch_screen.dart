import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/branches/domain/branch_code.dart';

/// Primer uso: un MANAGER entra a un negocio sin sucursales y crea la primera.
class FirstBranchScreen extends ConsumerStatefulWidget {
  const FirstBranchScreen({super.key});

  @override
  ConsumerState<FirstBranchScreen> createState() => _FirstBranchScreenState();
}

class _FirstBranchScreenState extends ConsumerState<FirstBranchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  /// Mientras el usuario no toque el código, se propone a partir del nombre.
  bool _codeEdited = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onNameChanged(String name) {
    if (!_codeEdited) _codeController.text = BranchCode.suggest(name);
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
      await ref
          .read(sessionControllerProvider.notifier)
          .createFirstBranch(code: _codeController.text, name: _nameController.text);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _errorMessage = failure.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = _errorMessage;
    return AuthScaffold(
      title: Strings.firstBranchTitle,
      subtitle: Strings.firstBranchSubtitle,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !_isSubmitting,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: Strings.branchName,
                hintText: Strings.branchNameHint,
                prefixIcon: Icon(Icons.storefront_outlined),
                counterText: '',
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? Strings.branchNameRequired : null,
              onChanged: _onNameChanged,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _codeController,
              enabled: !_isSubmitting,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              maxLength: BranchCode.maxLength,
              inputFormatters: [_UpperCaseFormatter()],
              decoration: const InputDecoration(
                labelText: Strings.branchCode,
                helperText: Strings.branchCodeHelper,
                helperMaxLines: 2,
                errorMaxLines: 2,
                prefixIcon: Icon(Icons.tag_rounded),
              ),
              validator: (value) =>
                  BranchCode.isValid(value ?? '') ? null : Strings.branchCodeInvalid,
              onChanged: (_) => _codeEdited = true,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FormErrorBanner(errorMessage),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: Strings.createBranch,
              icon: Icons.add_business_rounded,
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: _isSubmitting
                    ? null
                    : ref.read(sessionControllerProvider.notifier).logout,
                child: const Text(Strings.signOut),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// El backend guarda el código en mayúsculas; se muestra así desde el principio.
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
