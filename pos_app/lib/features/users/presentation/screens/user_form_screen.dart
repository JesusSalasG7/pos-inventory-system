import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/users/presentation/providers/users_provider.dart';

/// Alta o edición de un usuario (solo MANAGER). Con `user` edita; sin él,
/// crea. Al guardar vuelve atrás con `true`.
class UserFormScreen extends ConsumerStatefulWidget {
  const UserFormScreen({this.user, super.key});

  final AppUser? user;

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  /// Longitud mínima de contraseña que exige el backend.
  static const int _minPasswordLength = 8;

  /// Valor del desplegable para "todas las tiendas" (`assigned_branch` nulo).
  static const String _allBranches = '';

  final _formKey = GlobalKey<FormState>();
  late final _usernameController = TextEditingController(text: widget.user?.username ?? '');
  late final _fullNameController = TextEditingController(text: widget.user?.fullName ?? '');
  final _passwordController = TextEditingController();
  late UserRole _role = widget.user?.role ?? UserRole.supervisor;
  late String? _branch = widget.user == null ? null : widget.user!.assignedBranch ?? _allBranches;
  late bool _isActive = widget.user?.isActive ?? true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.user != null;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _role = role;
      // Solo un gerente puede tener acceso a todas las tiendas.
      if (role == UserRole.supervisor && _branch == _allBranches) _branch = null;
    });
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return _isEditing ? null : Strings.passwordRequired;
    if (password.length < _minPasswordLength) return Strings.passwordTooShort(_minPasswordLength);
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
    final assignedBranch = _branch == _allBranches ? null : _branch;
    final password = _passwordController.text;
    try {
      final notifier = ref.read(usersProvider.notifier);
      final user = widget.user;
      if (user == null) {
        await notifier.create(
          username: _usernameController.text,
          password: password,
          fullName: _fullNameController.text,
          role: _role,
          assignedBranch: assignedBranch,
        );
      } else {
        await notifier.save(
          user.id,
          fullName: _fullNameController.text,
          role: _role,
          assignedBranch: assignedBranch,
          isActive: _isActive,
          password: password.isEmpty ? null : password,
        );
      }
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
    final branches = ref.watch(sessionControllerProvider.select((session) => session.branches));
    final isSelf = _isEditing && ref.watch(currentUserProvider)?.id == widget.user!.id;
    final assigned = widget.user?.assignedBranch;
    final errorMessage = _errorMessage;
    final branchOptions = <(String, String)>[
      if (_role == UserRole.manager) (_allBranches, Strings.allBranches),
      for (final branch in branches) (branch.code, branch.name),
      // La tienda actual del usuario se conserva aunque ya esté inactiva.
      if (assigned != null && !branches.any((branch) => branch.code == assigned))
        (assigned, assigned),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? Strings.editUser : Strings.newUser)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              TextFormField(
                controller: _fullNameController,
                enabled: !_isSubmitting,
                autofocus: !_isEditing,
                maxLength: 150,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: Strings.fullName, counterText: ''),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? Strings.fullNameRequired : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _usernameController,
                // El nombre de usuario no se puede cambiar después.
                enabled: !_isEditing && !_isSubmitting,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: 150,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: Strings.username,
                  helperText: _isEditing ? null : Strings.usernameHelper,
                  counterText: '',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? Strings.usernameRequired : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(Strings.roleLabel, style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<UserRole>(
                  showSelectedIcon: false,
                  segments: [
                    for (final role in UserRole.values)
                      ButtonSegment(value: role, label: Text(Strings.role(role))),
                  ],
                  selected: {_role},
                  // Nadie puede quitarse a sí mismo el rol de gerente.
                  onSelectionChanged: _isSubmitting || isSelf
                      ? null
                      : (selection) => _onRoleChanged(selection.first),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _role == UserRole.manager ? Strings.managerRoleHint : Strings.supervisorRoleHint,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                // La clave fuerza a releer el valor cuando el rol cambia las opciones.
                key: ValueKey('branch-$_role-$_branch'),
                isExpanded: true,
                initialValue: branchOptions.any((option) => option.$1 == _branch) ? _branch : null,
                decoration: const InputDecoration(labelText: Strings.userBranch),
                items: [
                  for (final (code, name) in branchOptions)
                    DropdownMenuItem(
                      value: code,
                      child: Text(name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: _isSubmitting ? null : (value) => setState(() => _branch = value),
                validator: (value) => value == null ? Strings.userBranchRequired : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _passwordController,
                enabled: !_isSubmitting,
                obscureText: _obscurePassword,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: _isEditing ? Strings.newPassword : Strings.password,
                  helperText: _isEditing
                      ? Strings.newPasswordHelper
                      : Strings.passwordTooShort(_minPasswordLength),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? Strings.showPassword : Strings.hidePassword,
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                validator: _validatePassword,
                onFieldSubmitted: (_) => _submit(),
              ),
              if (_isEditing) ...[
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(Strings.activeUser, style: AppTypography.subtitle),
                  subtitle: Text(
                    isSelf ? Strings.cannotDeactivateSelf : Strings.activeUserHint,
                    style: AppTypography.bodySmall,
                  ),
                  value: _isActive,
                  onChanged: _isSubmitting || isSelf
                      ? null
                      : (value) => setState(() => _isActive = value),
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FormErrorBanner(errorMessage),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: _isEditing ? Strings.saveChanges : Strings.createUser,
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
