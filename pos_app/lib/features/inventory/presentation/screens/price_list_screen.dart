import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/currency/ves_pricing.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/category_avatar.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/search_field.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/pricing_settings_provider.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/providers/catalog_providers.dart';
import 'package:share_plus/share_plus.dart';

/// Productos activos de una categoría, para la lista de precios.
typedef PriceGroup = ({ProductCategory category, List<Product> products});

/// Agrupa los productos por categoría (por nombre) y, dentro, por nombre.
List<PriceGroup> groupByCategory(Iterable<StockedProduct> items) => [
  for (final category in categoriesOf(items))
    (
      category: category,
      products: [
        for (final item in items)
          if (item.product.category.id == category.id) item.product,
      ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
    ),
];

/// Texto plano de la lista de precios, para compartirla por WhatsApp u otra
/// app. Los bolívares son los que cobra la app: con la tasa activa y, si el
/// negocio lo usa, redondeados hacia arriba.
String buildPriceListText({
  required String branchName,
  required List<PriceGroup> groups,
  required Decimal? rate,
  required bool roundUp,
}) {
  final lines = <String>[
    Strings.priceListHeader(branchName),
    if (rate != null) Strings.rateUsed(MoneyFormatter.rate(rate)),
  ];
  for (final group in groups) {
    lines
      ..add('')
      ..add(group.category.name.toUpperCase());
    for (final product in group.products) {
      lines.add(
        Strings.priceListLine(
          product.name,
          Strings.unitShort(product.unit),
          MoneyFormatter.usd(product.salePriceUsd),
          rate == null
              ? Strings.vesUnavailable
              : MoneyFormatter.ves(
                  VesPricing.unitPrice(product.salePriceUsd, rate, roundUp: roundUp),
                ),
        ),
      );
    }
  }
  return lines.join('\n');
}

/// Lista de precios: todos los productos activos con su precio en dólares y
/// en bolívares, agrupados por categoría. Se puede buscar y compartir.
class PriceListScreen extends ConsumerStatefulWidget {
  const PriceListScreen({super.key});

  @override
  ConsumerState<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends ConsumerState<PriceListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(sellableCatalogProvider);
    final rate = ref.watch(activeRateProvider).value;
    final roundUp = ref.watch(roundVesUpProvider);
    final branch = ref.watch(activeBranchProvider);
    final all = catalog.value ?? const <StockedProduct>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.priceListTitle),
        actions: [
          IconButton(
            tooltip: Strings.sharePriceList,
            onPressed: all.isEmpty
                ? null
                : () => SharePlus.instance.share(
                    ShareParams(
                      text: buildPriceListText(
                        branchName: branch?.name ?? Strings.appName,
                        groups: groupByCategory(all),
                        rate: rate,
                        roundUp: roundUp,
                      ),
                    ),
                  ),
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: SearchField(
              hint: Strings.searchProducts,
              onChanged: (query) => setState(() => _query = query),
            ),
          ),
          if (rate != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  Strings.rateUsed(MoneyFormatter.rate(rate)),
                  style: AppTypography.bodySmall,
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(sellableCatalogProvider.future),
              child: AsyncValueView<List<StockedProduct>>(
                value: catalog,
                onRetry: () => ref.invalidate(sellableCatalogProvider),
                isEmpty: (items) => items.isEmpty,
                empty: const ScrollableEmptyState(
                  icon: Icons.sell_outlined,
                  title: Strings.emptyCatalogTitle,
                  message: Strings.emptyPriceListMessage,
                ),
                data: (items) {
                  final query = _query.toLowerCase();
                  final groups = groupByCategory(
                    items.where((item) => item.product.name.toLowerCase().contains(query)),
                  );
                  if (groups.isEmpty) {
                    return const ScrollableEmptyState(
                      icon: Icons.search_off_rounded,
                      title: Strings.noResultsTitle,
                      message: Strings.noResultsMessage,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    itemCount: groups.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) => _CategoryPrices(group: groups[index]),
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

class _CategoryPrices extends StatelessWidget {
  const _CategoryPrices({required this.group});

  final PriceGroup group;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryAvatar(category: group.category, size: 36),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  group.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title,
                ),
              ),
            ],
          ),
          for (final product in group.products) ...[
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
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
                      Text(
                        Strings.perUnit(Strings.unit(product.unit).toLowerCase()),
                        style: AppTypography.bodySmall,
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
              ],
            ),
          ],
        ],
      ),
    );
  }
}
