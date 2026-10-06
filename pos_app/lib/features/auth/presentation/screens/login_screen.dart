import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/config/env.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';

/// Ingreso con usuario y contraseña. El rol y la sucursal vienen de la cuenta:
/// aquí no se eligen.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Aviso heredado, p. ej. "Tu sesión venció", al llegar desde otra pantalla.
    _errorMessage = ref.read(sessionControllerProvider).failure?.message;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
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
          .login(username: _usernameController.text, password: _passwordController.text);
      // Si entra bien, el router cambia de pantalla por su cuenta.
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
      title: Strings.loginGreeting,
      subtitle: Strings.loginSubtitle,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            TextFormField(
              controller: _usernameController,
              enabled: !_isSubmitting,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              decoration: const InputDecoration(
                labelText: Strings.username,
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? Strings.usernameRequired : null,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              enabled: !_isSubmitting,
              obscureText: _obscurePassword,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: Strings.password,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? Strings.showPassword : Strings.hidePassword,
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  ),
                ),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? Strings.passwordRequired : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FormErrorBanner(errorMessage),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: Strings.signIn,
              icon: Icons.login_rounded,
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
            if (kDebugMode) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                Strings.serverAddress(Env.apiBaseUrl),
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              TextButton(
                onPressed: () => context.push(RouteNames.designPreview),
                child: const Text(Strings.designPreviewEntry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
