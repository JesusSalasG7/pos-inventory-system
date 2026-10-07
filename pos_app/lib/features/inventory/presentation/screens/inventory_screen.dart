import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/category_avatar.dart';
import 'package:pos_app/core/widgets/category_filter_chips.dart';
import 'package:pos_app/core/widgets/connected_branch_header.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/offline_banner.dart';
import 'package:pos_app/core/widgets/search_field.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/core/widgets/stock_badge.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';

/// Un producto activo está por reponer con stock en o bajo su mínimo: la
/// misma regla que `inventory/low-stock/`.
bool needsRestock(StockedProduct item) =>
    item.product.active && StockLevel.of(item.currentStock, item.minimumStock) != StockLevel.ok;

/// Pestaña Inventario: todo el catálogo con su stock en la tienda activa.
/// Desde aquí se entra al detalle de cada producto y al Kardex; un MANAGER
/// puede además dar de alta productos.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _query = '';
  ProductCategory? _category;
  bool _onlyLowStock = false;

  List<StockedProduct> _filter(List<StockedProduct> catalog) {
    final query = _query.toLowerCase();
    return [
      for (final item in catalog)
        if ((_category == null || item.product.category.id == _category!.id) &&
            (!_onlyLowStock || needsRestock(item)) &&
            item.product.name.toLowerCase().contains(query))
          item,
    ];
  }

  Future<void> _createProduct() async {
    final created = await context.push<bool>(RouteNames.productForm);
    if ((created ?? false) && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.productCreated)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(inventoryCatalogProvider);
    final isManager = ref.watch(currentUserProvider)?.isManager ?? false;
    final lowStockCount = catalog.value?.where(needsRestock).length ?? 0;

    return Scaffold(
      appBar: const ConnectedBranchHeader(),
      floatingActionButton: isManager
          ? FloatingActionButton.extended(
              onPressed: _createProduct,
              icon: const Icon(Icons.add_rounded),
              label: const Text(Strings.newProduct),
            )
          : null,
      body: Column(
        children: [
          OfflineBanner(onRetry: () => ref.invalidate(inventoryCatalogProvider)),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: Strings.searchProducts,
                    onChanged: (query) => setState(() => _query = query),
                  ),
                ),
                IconButton(
                  tooltip: Strings.viewMovements,
                  onPressed: () => context.push(RouteNames.inventoryMovements),
                  icon: const Icon(Icons.history_rounded),
                ),
              ],
            ),
          ),
          CategoryFilterChips(
            categories: categoriesOf(catalog.value ?? const []),
            selected: _category,
            onSelected: (category) => setState(() => _category = category),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                selected: _onlyLowStock,
                onSelected: (selected) => setState(() => _onlyLowStock = selected),
                avatar: _onlyLowStock
                    ? null
                    : const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
                label: Text(
                  lowStockCount > 0
                      ? Strings.onlyLowStockCount(lowStockCount)
                      : Strings.onlyLowStock,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(inventoryCatalogProvider.future),
              child: AsyncValueView<List<StockedProduct>>(
                value: catalog,
                onRetry: () => ref.invalidate(inventoryCatalogProvider),
                isEmpty: (items) => items.isEmpty,
                empty: const ScrollableEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: Strings.emptyCatalogTitle,
                  message: Strings.emptyInventoryMessage,
                ),
                data: (items) {
                  final visible = _filter(items);
                  if (visible.isEmpty) {
                    final onlyFilterIsLowStock =
                        _onlyLowStock && _query.isEmpty && _category == null;
                    return ScrollableEmptyState(
                      icon: onlyFilterIsLowStock
                          ? Icons.check_circle_outline_rounded
                          : Icons.search_off_rounded,
                      title: onlyFilterIsLowStock
                          ? Strings.noLowStockTitle
                          : Strings.noResultsTitle,
                      message: onlyFilterIsLowStock
                          ? Strings.lowStockNone
                          : Strings.noFilterResultsMessage,
                    );
                  }
                  return ListView.separated(
                    // Deja sitio al botón flotante.
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 96),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = visible[index];
                      return _InventoryRow(
                        key: ValueKey(item.product.id),
                        item: item,
                        onTap: () => context.push(RouteNames.productDetail(item.product.id)),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta gris de producto desactivado.
class InactivePill extends StatelessWidget {
  const InactivePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        Strings.inactiveProduct,
        style: AppTypography.label.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.item, required this.onTap, super.key});

  final StockedProduct item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Opacity(
        opacity: product.active ? 1 : 0.6,
        child: Row(
          children: [
            CategoryAvatar(category: product.category),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      StockBadge(
                        stock: item.currentStock,
                        minimumStock: item.minimumStock,
                        unit: product.unit,
                      ),
                      if (!product.active) const InactivePill(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DualCurrencyText(
              amountUsd: product.salePriceUsd,
              isUnitPrice: true,
              size: DualCurrencySize.small,
              crossAxisAlignment: CrossAxisAlignment.end,
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
