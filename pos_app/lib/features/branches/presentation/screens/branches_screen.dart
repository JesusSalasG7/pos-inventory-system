import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/domain/branch.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/branches/domain/branch_code.dart';
import 'package:pos_app/features/branches/presentation/providers/branches_provider.dart';

/// Administración de tiendas (solo MANAGER): crear, renombrar y activar o
/// desactivar. No se borran y su código nunca cambia.
class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  Future<void> _edit(BuildContext context, {Branch? branch}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _BranchDialog(branch: branch),
    );
    if (!(saved ?? false) || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(branch == null ? Strings.branchCreated : Strings.branchRenamed)),
    );
  }

  Future<void> _setActive(
    BuildContext context,
    WidgetRef ref,
    Branch branch, {
    required bool active,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(allBranchesProvider.notifier).setActive(branch.code, active: active);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(active ? Strings.branchActivated : Strings.branchDeactivated)),
        );
    } on Failure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(allBranchesProvider);
    final activeCode = ref.watch(activeBranchProvider)?.code;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.branchesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text(Strings.newBranch),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(allBranchesProvider.future),
        child: AsyncValueView<List<Branch>>(
          value: branches,
          onRetry: () => ref.invalidate(allBranchesProvider),
          data: (items) => ListView.separated(
            // Deja sitio al botón flotante.
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index == 0) return Text(Strings.branchesHint, style: AppTypography.bodySmall);
              final branch = items[index - 1];
              final isInUse = branch.code == activeCode;
              return SectionCard(
                key: ValueKey(branch.code),
                onTap: () => _edit(context, branch: branch),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      color: branch.active ? AppColors.primaryDark : AppColors.disabled,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.subtitle,
                          ),
                          Text(
                            [
                              branch.code,
                              if (!branch.active) Strings.inactiveBranch,
                              if (isInUse) Strings.branchInUse,
                            ].join(' · '),
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: branch.active,
                      // La tienda en la que se está trabajando no se desactiva desde aquí.
                      onChanged: isInUse
                          ? null
                          : (active) => _setActive(context, ref, branch, active: active),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Crea una tienda (nombre y código) o, con `branch`, le cambia el nombre.
class _BranchDialog extends ConsumerStatefulWidget {
  const _BranchDialog({this.branch});

  final Branch? branch;

  @override
  ConsumerState<_BranchDialog> createState() => _BranchDialogState();
}

class _BranchDialogState extends ConsumerState<_BranchDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.branch?.name ?? '');
  final _codeController = TextEditingController();

  /// Mientras el usuario no toque el código, se propone a partir del nombre.
  bool _codeEdited = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.branch != null;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
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
      final notifier = ref.read(allBranchesProvider.notifier);
      final branch = widget.branch;
      if (branch == null) {
        await notifier.create(code: _codeController.text, name: _nameController.text);
      } else {
        await notifier.rename(branch.code, _nameController.text);
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
    final errorMessage = _errorMessage;
    return AlertDialog(
      title: Text(_isEditing ? Strings.renameBranch : Strings.newBranch),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_isSubmitting,
                autofocus: true,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                textInputAction: _isEditing ? TextInputAction.done : TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: Strings.branchName,
                  hintText: Strings.branchNameHint,
                  counterText: '',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? Strings.branchNameRequired : null,
                onChanged: (name) {
                  if (!_isEditing && !_codeEdited) _codeController.text = BranchCode.suggest(name);
                },
                onFieldSubmitted: _isEditing ? (_) => _submit() : null,
              ),
              if (!_isEditing) ...[
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _codeController,
                  enabled: !_isSubmitting,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  maxLength: BranchCode.maxLength,
                  inputFormatters: [
                    TextInputFormatter.withFunction(
                      (_, value) => value.copyWith(text: value.text.toUpperCase()),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: Strings.branchCode,
                    helperText: Strings.branchCodeHelper,
                    helperMaxLines: 2,
                    errorMaxLines: 2,
                  ),
                  validator: (value) =>
                      BranchCode.isValid(value ?? '') ? null : Strings.branchCodeInvalid,
                  onChanged: (_) => _codeEdited = true,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                FormErrorBanner(errorMessage),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text(Strings.cancel),
        ),
        FilledButton(onPressed: _isSubmitting ? null : _submit, child: const Text(Strings.save)),
      ],
    );
  }
}
