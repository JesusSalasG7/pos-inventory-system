import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';

/// Abre la hoja con las subcategorías de una categoría (solo MANAGER): crear,
/// cambiar el nombre y activar o desactivar. No se borran.
Future<void> showSubcategoriesSheet(BuildContext context, {required ProductCategory category}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => _SubcategoriesSheet(category: category),
  );
}

/// Pide el nombre de una subcategoría y la crea o, con `subcategory`, la
/// renombra. Devuelve la subcategoría guardada, o `null` si se cancela.
Future<ProductSubcategory?> showSubcategoryDialog(
  BuildContext context, {
  required int categoryId,
  ProductSubcategory? subcategory,
}) {
  return showDialog<ProductSubcategory>(
    context: context,
    builder: (_) => _SubcategoryDialog(categoryId: categoryId, subcategory: subcategory),
  );
}

class _SubcategoriesSheet extends ConsumerWidget {
  const _SubcategoriesSheet({required this.category});

  final ProductCategory category;

  Future<void> _setActive(
    BuildContext context,
    WidgetRef ref,
    ProductSubcategory subcategory, {
    required bool active,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(subcategoriesProvider.notifier).setActive(subcategory.id, active: active);
    } on Failure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subcategories = ref.watch(subcategoriesProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Strings.subcategoriesOf(category.name), style: AppTypography.title),
            const SizedBox(height: AppSpacing.xs),
            Text(Strings.subcategoriesHint, style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: AsyncValueView<List<ProductSubcategory>>(
                value: subcategories,
                onRetry: () => ref.invalidate(subcategoriesProvider),
                loading: const SkeletonBox(height: 56),
                data: (all) {
                  final items = [
                    for (final subcategory in all)
                      if (subcategory.categoryId == category.id) subcategory,
                  ];
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(Strings.emptySubcategories, style: AppTypography.body),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final subcategory = items[index];
                      return ListTile(
                        key: ValueKey(subcategory.id),
                        contentPadding: EdgeInsets.zero,
                        minTileHeight: AppSpacing.minTouchTarget,
                        title: Text(
                          subcategory.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.subtitle,
                        ),
                        subtitle: subcategory.active
                            ? null
                            : Text(Strings.inactiveCategory, style: AppTypography.bodySmall),
                        trailing: Switch(
                          value: subcategory.active,
                          onChanged: (active) =>
                              _setActive(context, ref, subcategory, active: active),
                        ),
                        onTap: () => showSubcategoryDialog(
                          context,
                          categoryId: category.id,
                          subcategory: subcategory,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: category.active
                    ? () => showSubcategoryDialog(context, categoryId: category.id)
                    : null,
                icon: const Icon(Icons.add_rounded),
                label: const Text(Strings.newSubcategory),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubcategoryDialog extends ConsumerStatefulWidget {
  const _SubcategoryDialog({required this.categoryId, this.subcategory});

  final int categoryId;
  final ProductSubcategory? subcategory;

  @override
  ConsumerState<_SubcategoryDialog> createState() => _SubcategoryDialogState();
}

class _SubcategoryDialogState extends ConsumerState<_SubcategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.subcategory?.name ?? '');
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
      final notifier = ref.read(subcategoriesProvider.notifier);
      final existing = widget.subcategory;
      final saved = existing == null
          ? await notifier.create(categoryId: widget.categoryId, name: _controller.text)
          : await notifier.rename(existing.id, name: _controller.text);
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
      title: Text(widget.subcategory == null ? Strings.newSubcategory : Strings.editSubcategory),
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
                  labelText: Strings.subcategoryName,
                  hintText: Strings.subcategoryNameHint,
                  counterText: '',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? Strings.subcategoryNameRequired
                    : null,
                onFieldSubmitted: (_) => _submit(),
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
