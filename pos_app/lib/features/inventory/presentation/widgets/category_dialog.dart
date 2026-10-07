import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/constants/category_stickers.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';

/// Pide el nombre y, opcionalmente, el sticker de una categoría, y la crea o,
/// con `category`, la modifica.
/// Devuelve la categoría guardada, o `null` si se cancela.
Future<ProductCategory?> showCategoryDialog(BuildContext context, {ProductCategory? category}) {
  return showDialog<ProductCategory>(
    context: context,
    builder: (_) => _CategoryDialog(category: category),
  );
}

class _CategoryDialog extends ConsumerStatefulWidget {
  const _CategoryDialog({this.category});

  final ProductCategory? category;

  @override
  ConsumerState<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.category?.name ?? '');

  /// Sticker elegido; vacío es "automático": la app asigna el ícono.
  late String _icon = widget.category?.icon ?? '';
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
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
      final notifier = ref.read(categoriesProvider.notifier);
      final existing = widget.category;
      final saved = existing == null
          ? await notifier.create(_controller.text, icon: _icon)
          : await notifier.save(existing.id, name: _controller.text, icon: _icon);
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
    return AlertDialog(
      title: Text(widget.category == null ? Strings.newCategory : Strings.editCategory),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _controller,
                enabled: !_isSubmitting,
                autofocus: true,
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: Strings.categoryName,
                  hintText: Strings.categoryNameHint,
                  counterText: '',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? Strings.categoryNameRequired : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(Strings.categorySticker, style: AppTypography.subtitle),
              Text(Strings.categoryStickerHint, style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _StickerOption(
                    isSelected: _icon.isEmpty,
                    semanticLabel: Strings.automaticSticker,
                    onTap: _isSubmitting ? null : () => setState(() => _icon = ''),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryDark),
                  ),
                  for (final sticker in {
                    // El sticker actual se ofrece aunque ya no esté en la lista.
                    if (_icon.isNotEmpty) _icon,
                    ...categoryStickers,
                  })
                    _StickerOption(
                      isSelected: _icon == sticker,
                      semanticLabel: sticker,
                      onTap: _isSubmitting ? null : () => setState(() => _icon = sticker),
                      child: Text(sticker, style: const TextStyle(fontSize: 24, height: 1.1)),
                    ),
                ],
              ),
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
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text(Strings.cancel),
        ),
        FilledButton(onPressed: _isSubmitting ? null : _submit, child: const Text(Strings.save)),
      ],
    );
  }
}

/// Casilla de un sticker en el selector: 48 dp, resaltada si es la elegida.
class _StickerOption extends StatelessWidget {
  const _StickerOption({
    required this.isSelected,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final bool isSelected;
  final String semanticLabel;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: onTap,
        child: Container(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySoft : AppColors.surfaceMuted,
            borderRadius: AppRadius.smAll,
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : Colors.transparent,
              width: 2,
            ),
          ),
          child: ExcludeSemantics(child: child),
        ),
      ),
    );
  }
}
