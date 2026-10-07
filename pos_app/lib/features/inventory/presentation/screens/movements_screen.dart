import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/network/paged_list.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/features/inventory/domain/entities/inventory_movement.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:pos_app/features/inventory/presentation/widgets/movement_tile.dart';

/// Kardex de la tienda activa: todos los movimientos de stock, del más
/// reciente al más antiguo, con filtro por tipo.
class MovementsScreen extends ConsumerStatefulWidget {
  const MovementsScreen({super.key});

  @override
  ConsumerState<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends ConsumerState<MovementsScreen> {
  MovementType? _type;

  @override
  Widget build(BuildContext context) {
    final provider = movementHistoryProvider(type: _type);
    final history = ref.watch(provider);
    final userId = ref.watch(currentUserProvider)?.id;
    // El movimiento solo trae el id del producto: el nombre sale del catálogo.
    final products = {
      for (final item in ref.watch(inventoryCatalogProvider).value ?? const <StockedProduct>[])
        item.product.id: item.product,
    };

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.movementsTitle)),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: AppSpacing.minTouchTarget,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: MovementType.values.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final type = index == 0 ? null : MovementType.values[index - 1];
                final isSelected = type == _type;
                return ChoiceChip(
                  selected: isSelected,
                  onSelected: (_) => setState(() => _type = type),
                  label: Text(type == null ? Strings.all : Strings.movementType(type)),
                  labelStyle: AppTypography.label.copyWith(
                    fontSize: 14,
                    color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(provider.future),
              child: AsyncValueView<PagedList<InventoryMovement>>(
                value: history,
                onRetry: () => ref.invalidate(provider),
                isEmpty: (list) => list.items.isEmpty,
                empty: const ScrollableEmptyState(
                  icon: Icons.history_rounded,
                  title: Strings.emptyMovementsTitle,
                  message: Strings.emptyMovementsMessage,
                ),
                data: (list) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  itemCount: list.items.length + (list.hasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    if (index == list.items.length) {
                      return LoadMoreButton(
                        label: Strings.loadMore,
                        onLoadMore: ref.read(provider.notifier).loadMore,
                      );
                    }
                    final movement = list.items[index];
                    final product = products[movement.productId];
                    return SectionCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: MovementTile(
                        movement: movement,
                        isMine: movement.userId == userId,
                        unit: product?.unit,
                        productName: product?.name ?? Strings.productNumber(movement.productId),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
