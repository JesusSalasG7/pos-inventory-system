import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/category_avatar.dart';
import 'package:pos_app/core/widgets/decimal_input_field.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:pos_app/features/inventory/presentation/widgets/category_dialog.dart';

/// Alta o edición de un producto del catálogo global (solo MANAGER). Con
/// `product` edita; sin él, crea. Al guardar vuelve atrás con `true`.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({this.product, super.key});

  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.product?.name ?? '');
  late int? _categoryId = widget.product?.category.id;
  late UnitOfMeasure _unit = widget.product?.unit ?? UnitOfMeasure.unit;
  late Decimal? _costPrice = widget.product?.costPriceUsd;
  late Decimal? _salePrice = widget.product?.salePriceUsd;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.product != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  static String? _validatePrice(Decimal? value) {
    if (value == null) return Strings.priceRequired;
    if (value < Decimal.zero) return Strings.amountNotNegative;
    return null;
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
          .read(inventoryCatalogProvider.notifier)
          .saveProduct(
            ProductDraft(
              name: _nameController.text.trim(),
              categoryId: _categoryId!,
              unit: _unit,
              costPriceUsd: quantizeMoney(_costPrice!),
              salePriceUsd: quantizeMoney(_salePrice!),
            ),
            productId: widget.product?.id,
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
    final cost = _costPrice;
    final sale = _salePrice;
    final isBelowCost = cost != null && sale != null && sale < cost;
    final errorMessage = _errorMessage;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? Strings.editProduct : Strings.newProduct)),
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
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: Strings.productName,
                  hintText: Strings.productNameHint,
                  counterText: '',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? Strings.productNameRequired : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              _CategoryField(
                selectedId: _categoryId,
                current: widget.product?.category,
                enabled: !_isSubmitting,
                onChanged: (categoryId) => setState(() => _categoryId = categoryId),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(Strings.unitLabel, style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<UnitOfMeasure>(
                  showSelectedIcon: false,
                  segments: [
                    for (final unit in UnitOfMeasure.values)
                      ButtonSegment(value: unit, label: Text(Strings.unit(unit))),
                  ],
                  selected: {_unit},
                  onSelectionChanged: _isSubmitting
                      ? null
                      : (selection) => setState(() => _unit = selection.first),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              DecimalInputField(
                initialValue: _costPrice,
                label: Strings.costPriceLabel,
                prefixText: r'$ ',
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.next,
                validator: _validatePrice,
                onChanged: (value) => setState(() => _costPrice = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              DecimalInputField(
                initialValue: _salePrice,
                label: Strings.salePriceLabel,
                prefixText: r'$ ',
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.done,
                validator: _validatePrice,
                onChanged: (value) => setState(() => _salePrice = value),
                onSubmitted: (_) => _submit(),
              ),
              if (isBelowCost) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  Strings.saleBelowCost,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(Strings.catalogSharedNote, style: AppTypography.bodySmall),
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FormErrorBanner(errorMessage),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: _isEditing ? Strings.saveChanges : Strings.createProduct,
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

/// Selector de categoría con las categorías activas del negocio y un acceso
/// directo para crear una nueva sin salir del formulario.
class _CategoryField extends ConsumerWidget {
  const _CategoryField({
    required this.selectedId,
    required this.current,
    required this.enabled,
    required this.onChanged,
  });

  final int? selectedId;

  /// Categoría actual del producto que se edita; se ofrece aunque esté inactiva.
  final ProductCategory? current;
  final bool enabled;
  final ValueChanged<int?> onChanged;

  Future<void> _create(BuildContext context) async {
    final created = await showCategoryDialog(context);
    if (created != null) onChanged(created.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    if (categories.hasError && !categories.hasValue) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormErrorBanner(Failure.from(categories.error!).message),
          TextButton(
            onPressed: () => ref.invalidate(categoriesProvider),
            child: const Text(Strings.retry),
          ),
        ],
      );
    }
    final loaded = categories.value;
    if (loaded == null) return const SkeletonBox(height: 56);

    final current = this.current;
    final options = [
      for (final category in loaded)
        if (category.active || category.id == current?.id) category,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (options.isEmpty)
          Text(Strings.noCategoriesYet, style: AppTypography.bodySmall)
        else
          DropdownButtonFormField<int>(
            // La clave fuerza a releer el valor cuando se crea una categoría aquí mismo.
            key: ValueKey('category-$selectedId-${options.length}'),
            initialValue: options.any((category) => category.id == selectedId) ? selectedId : null,
            // Ocupa todo el ancho para que un nombre largo se recorte en vez de desbordar.
            isExpanded: true,
            decoration: const InputDecoration(labelText: Strings.categoryLabel),
            items: [
              for (final category in options)
                DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      CategoryGlyph(category: category, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(child: Text(category.name, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
            ],
            onChanged: enabled ? onChanged : null,
            validator: (value) => value == null ? Strings.categoryRequired : null,
          ),
        TextButton.icon(
          onPressed: enabled ? () => _create(context) : null,
          icon: const Icon(Icons.add_rounded),
          label: const Text(Strings.newCategory),
        ),
      ],
    );
  }
}
