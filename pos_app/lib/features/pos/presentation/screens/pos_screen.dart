import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/cart_banner.dart';
import 'package:pos_app/core/widgets/category_filter_chips.dart';
import 'package:pos_app/core/widgets/connected_branch_header.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/offline_banner.dart';
import 'package:pos_app/core/widgets/product_card.dart';
import 'package:pos_app/core/widgets/search_field.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/pricing_settings_provider.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/providers/catalog_providers.dart';
import 'package:pos_app/features/pos/presentation/providers/cart_controller.dart';

/// Pestaña Vender: búsqueda rápida, filtro por categoría, cuadrícula de
/// productos y el banner del carrito. Sin caja abierta manda a abrirla y
/// vuelve aquí al terminar, sin perder el carrito.
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  String _query = '';
  ProductCategory? _category;
  bool _redirecting = false;

  /// Si no hay caja abierta en esta tienda, lleva a la pestaña Caja.
  void _redirectIfNoSession() {
    final session = ref.read(currentSessionProvider);
    final branch = ref.read(activeBranchProvider);
    if (_redirecting || !session.hasValue || branch == null) return;
    final current = session.value;
    if (current != null && current.branchCode == branch.code) return;

    _redirecting = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirecting = false;
      if (!mounted) return;
      // Solo redirige si esta pestaña es la que está a la vista.
      if (GoRouterState.of(context).matchedLocation != RouteNames.sell) return;
      ref.read(returnToSellProvider.notifier).request();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text(Strings.needOpenCashSnack)));
      context.go(RouteNames.cash);
    });
  }

  List<StockedProduct> _filter(List<StockedProduct> catalog) {
    final query = _query.toLowerCase();
    return [
      for (final item in catalog)
        if ((_category == null || item.product.category.id == _category!.id) &&
            item.product.name.toLowerCase().contains(query))
          item,
    ];
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentSessionProvider, (_, _) => _redirectIfNoSession());
    _redirectIfNoSession();

    final catalog = ref.watch(sellableCatalogProvider);
    final cart = ref.watch(cartControllerProvider);
    final rate = ref.watch(activeRateProvider);
    final hasNoRate = rate.hasValue && rate.value == null;

    return Scaffold(
      appBar: const ConnectedBranchHeader(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: CartBanner(
          itemCount: cart.itemCount,
          totalUsd: cart.totalUsd,
          totalVes: rate.value == null
              ? null
              : cart.totalVes(rate.value!, roundUp: ref.watch(roundVesUpProvider)),
          onTap: () => context.push(RouteNames.checkout),
        ),
      ),
      body: Column(
        children: [
          OfflineBanner(onRetry: () => ref.invalidate(sellableCatalogProvider)),
          if (hasNoRate)
            const Expanded(
              child: EmptyState(
                icon: Icons.currency_exchange_rounded,
                title: Strings.noRateToSellTitle,
                message: Strings.noRateToSellMessage,
                iconColor: AppColors.warning,
                iconBackground: AppColors.warningSoft,
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: SearchField(
                hint: Strings.searchProducts,
                onChanged: (query) => setState(() => _query = query),
              ),
            ),
            CategoryFilterChips(
              categories: categoriesOf(catalog.value ?? const []),
              selected: _category,
              onSelected: (category) => setState(() => _category = category),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(sellableCatalogProvider.future),
                child: AsyncValueView<List<StockedProduct>>(
                  value: catalog,
                  onRetry: () => ref.invalidate(sellableCatalogProvider),
                  loading: const _CatalogSkeleton(),
                  isEmpty: (items) => items.isEmpty,
                  empty: const ScrollableEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: Strings.emptyCatalogTitle,
                    message: Strings.emptyCatalogMessage,
                  ),
                  data: (items) {
                    final visible = _filter(items);
                    if (visible.isEmpty) {
                      return const ScrollableEmptyState(
                        icon: Icons.search_off_rounded,
                        title: Strings.noResultsTitle,
                        message: Strings.noResultsMessage,
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) => GridView.builder(
                        // Deja sitio al banner del carrito, que flota encima.
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 120),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ProductCard.columnsFor(constraints.maxWidth),
                          mainAxisExtent: ProductCard.gridExtent,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          return ProductCard(
                            key: ValueKey(item.product.id),
                            name: item.product.name,
                            category: item.product.category,
                            unit: item.product.unit,
                            priceUsd: item.product.salePriceUsd,
                            stock: item.currentStock,
                            minimumStock: item.minimumStock,
                            quantity: cart.quantityOf(item.product.id),
                            onQuantityChanged: (quantity) => ref
                                .read(cartControllerProvider.notifier)
                                .setQuantity(item, quantity),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CatalogSkeleton extends StatelessWidget {
  const _CatalogSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ProductCard.columnsFor(constraints.maxWidth),
          mainAxisExtent: ProductCard.gridExtent,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => const SkeletonBox(height: ProductCard.gridExtent),
      ),
    );
  }
}
