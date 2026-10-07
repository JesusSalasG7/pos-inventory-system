import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/branch.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/network/paged_list.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/category_avatar.dart';
import 'package:pos_app/core/widgets/confirm_dialog.dart';
import 'package:pos_app/core/widgets/decimal_input_field.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/core/widgets/stock_badge.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';
import 'package:pos_app/features/inventory/domain/entities/inventory_movement.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:pos_app/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:pos_app/features/inventory/presentation/widgets/movement_sheet.dart';
import 'package:pos_app/features/inventory/presentation/widgets/movement_tile.dart';

/// Detalle de un producto en la tienda activa: precio, stock, movimientos
/// manuales (entrada, merma y ajuste) y su Kardex. Un MANAGER puede además
/// editarlo, cambiar su stock mínimo y activarlo o desactivarlo.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final int productId;

  Future<void> _edit(BuildContext context, Product product) async {
    final saved = await context.push<bool>(RouteNames.productForm, extra: product);
    if ((saved ?? false) && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.productSaved)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inventoryCatalogProvider);
    final isManager = ref.watch(currentUserProvider)?.isManager ?? false;
    final item = catalog.value?.where((item) => item.product.id == productId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.productDetail),
        actions: [
          if (isManager && item != null)
            IconButton(
              tooltip: Strings.editProduct,
              onPressed: () => _edit(context, item.product),
              icon: const Icon(Icons.edit_rounded),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          ref.invalidate(movementHistoryProvider(productId: productId));
          return ref.refresh(inventoryCatalogProvider.future);
        },
        child: AsyncValueView<List<StockedProduct>>(
          value: catalog,
          onRetry: () => ref.invalidate(inventoryCatalogProvider),
          data: (_) => item == null
              ? const ScrollableEmptyState(
                  icon: Icons.search_off_rounded,
                  title: Strings.productNotFoundTitle,
                  message: Strings.productNotFoundMessage,
                )
              : _ProductDetail(item: item, isManager: isManager),
        ),
      ),
    );
  }
}

class _ProductDetail extends ConsumerWidget {
  const _ProductDetail({required this.item, required this.isManager});

  final StockedProduct item;
  final bool isManager;

  String _amount(Decimal value) =>
      Strings.stockOf(MoneyFormatter.quantity(value), Strings.unitShort(item.product.unit));

  Future<void> _move(BuildContext context, MovementType type) async {
    final outcome = await showMovementSheet(context, item: item, type: type);
    if (outcome == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(switch (outcome) {
          MovementOutcome.saved => Strings.movementSaved,
          MovementOutcome.unchanged => Strings.adjustmentUnchanged,
        }),
      ),
    );
  }

  Future<void> _changeMinimum(BuildContext context) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _MinimumStockDialog(item: item),
    );
    if ((saved ?? false) && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.minimumSaved)));
    }
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    if (item.product.active) {
      final confirmed = await showConfirmDialog(
        context,
        title: Strings.deactivateProductTitle,
        message: Strings.deactivateProductMessage,
        confirmLabel: Strings.deactivate,
        isDestructive: true,
      );
      if (!confirmed) return;
    }
    try {
      final product = await ref
          .read(inventoryCatalogProvider.notifier)
          .toggleActive(item.product.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text(product.active ? Strings.productActivated : Strings.productDeactivated),
        ),
      );
    } on Failure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = item.product;
    final branch = ref.watch(activeBranchProvider);
    final user = ref.watch(currentUserProvider);
    final branchCount = ref.watch(
      sessionControllerProvider.select((session) => session.branches.length),
    );
    final canCompareBranches = (user?.hasAllBranchesAccess ?? false) && branchCount > 1;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryAvatar(category: product.category, size: 52),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: AppTypography.title),
                        Text(
                          '${product.category.name} · '
                          '${Strings.perUnit(Strings.unit(product.unit).toLowerCase())}',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (!product.active) const InactivePill(),
                ],
              ),
              const Divider(height: AppSpacing.xxl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Strings.salePrice, style: AppTypography.bodySmall),
                        DualCurrencyText(amountUsd: product.salePriceUsd, isUnitPrice: true),
                      ],
                    ),
                  ),
                  // El costo es un dato del negocio: solo lo ve el gerente.
                  if (isManager)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Strings.costPrice, style: AppTypography.bodySmall),
                        Text(
                          MoneyFormatter.usd(product.costPriceUsd),
                          style: AppTypography.amount(18, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: Strings.stockInBranch(branch?.name ?? '').toUpperCase(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(_amount(item.currentStock), style: AppTypography.amount(34)),
                  ),
                  StockBadge(
                    stock: item.currentStock,
                    minimumStock: item.minimumStock,
                    unit: product.unit,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      Strings.minimumStockOf(_amount(item.minimumStock)),
                      style: AppTypography.bodySmall,
                    ),
                  ),
                  if (isManager)
                    TextButton(
                      onPressed: () => _changeMinimum(context),
                      child: const Text(Strings.changeMinimum),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: Strings.registerEntry,
          icon: Icons.add_rounded,
          tone: ButtonTone.success,
          // El backend rechaza la entrada de un producto inactivo.
          onPressed: product.active ? () => _move(context, MovementType.entry) : null,
        ),
        if (!product.active) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(Strings.inactiveEntryNote, style: AppTypography.bodySmall),
        ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: Strings.movementType(MovementType.waste),
                icon: Icons.delete_outline_rounded,
                tone: ButtonTone.danger,
                variant: ButtonVariant.outlined,
                onPressed: item.currentStock > Decimal.zero
                    ? () => _move(context, MovementType.waste)
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: PrimaryButton(
                label: Strings.movementType(MovementType.adjustment),
                icon: Icons.tune_rounded,
                variant: ButtonVariant.outlined,
                onPressed: () => _move(context, MovementType.adjustment),
              ),
            ),
          ],
        ),
        if (canCompareBranches) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: Strings.otherBranchesStock.toUpperCase(),
            child: _OtherBranchesStock(productId: product.id, amount: _amount),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(Strings.movementsTitle, style: AppTypography.title),
        const SizedBox(height: AppSpacing.md),
        _ProductMovements(productId: product.id, unit: product.unit),
        if (isManager) ...[
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: product.active ? Strings.deactivateProduct : Strings.activateProduct,
            icon: product.active ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            tone: product.active ? ButtonTone.danger : ButtonTone.primary,
            variant: ButtonVariant.outlined,
            onPressed: () => _toggleActive(context, ref),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _OtherBranchesStock extends ConsumerWidget {
  const _OtherBranchesStock({required this.productId, required this.amount});

  final int productId;
  final String Function(Decimal value) amount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView<Map<Branch, Map<int, Decimal>>>(
      value: ref.watch(otherBranchesStockProvider),
      onRetry: () => ref.invalidate(otherBranchesStockProvider),
      loading: const SkeletonBox(height: 44),
      data: (stockByBranch) => Column(
        children: [
          for (final MapEntry(key: branch, value: stock) in stockByBranch.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(child: Text(branch.name, style: AppTypography.body)),
                  // Sin fila de inventario en esa tienda cuenta como cero.
                  Text(amount(stock[productId] ?? Decimal.zero), style: AppTypography.amount(16)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductMovements extends ConsumerWidget {
  const _ProductMovements({required this.productId, required this.unit});

  final int productId;
  final UnitOfMeasure unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = movementHistoryProvider(productId: productId);
    final userId = ref.watch(currentUserProvider)?.id;
    return AsyncValueView<PagedList<InventoryMovement>>(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      loading: const SkeletonBox(height: 120),
      isEmpty: (list) => list.items.isEmpty,
      empty: const EmptyState(
        icon: Icons.history_rounded,
        title: Strings.emptyMovementsTitle,
        message: Strings.emptyMovementsMessage,
      ),
      data: (list) => SectionCard(
        child: Column(
          children: [
            for (final (index, movement) in list.items.indexed) ...[
              if (index > 0) const Divider(height: AppSpacing.xl),
              MovementTile(movement: movement, isMine: movement.userId == userId, unit: unit),
            ],
            if (list.hasMore) ...[
              const SizedBox(height: AppSpacing.sm),
              LoadMoreButton(
                label: Strings.loadMore,
                onLoadMore: ref.read(provider.notifier).loadMore,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MinimumStockDialog extends ConsumerStatefulWidget {
  const _MinimumStockDialog({required this.item});

  final StockedProduct item;

  @override
  ConsumerState<_MinimumStockDialog> createState() => _MinimumStockDialogState();
}

class _MinimumStockDialogState extends ConsumerState<_MinimumStockDialog> {
  late Decimal? _value = widget.item.minimumStock;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isValid => (_value ?? -Decimal.one) >= Decimal.zero;

  Future<void> _submit() async {
    if (_isSubmitting || !_isValid) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(inventoryCatalogProvider.notifier)
          .setMinimumStock(
            productId: widget.item.product.id,
            minimumStock: quantizeQuantity(_value!),
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
    final unit = widget.item.product.unit;
    final errorMessage = _errorMessage;
    return AlertDialog(
      title: const Text(Strings.minimumStock),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.product.name, style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.md),
            DecimalInputField(
              initialValue: widget.item.minimumStock,
              label: Strings.minimumStock,
              suffixText: Strings.unitShort(unit),
              maxDecimals: unit.allowsDecimals ? quantityScale : 0,
              autofocus: true,
              large: true,
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.done,
              validator: (value) => value == null ? Strings.quantityRequired : null,
              onChanged: (value) => setState(() => _value = value),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(Strings.minimumStockHint, style: AppTypography.bodySmall),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              FormErrorBanner(errorMessage),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text(Strings.cancel),
        ),
        FilledButton(
          onPressed: _isValid && !_isSubmitting ? _submit : null,
          child: const Text(Strings.save),
        ),
      ],
    );
  }
}
