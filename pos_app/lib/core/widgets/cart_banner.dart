import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';

/// Banner flotante inferior del POS: número de ítems y total en las dos monedas.
/// Solo se muestra si el carrito tiene algo.
class CartBanner extends StatelessWidget {
  const CartBanner({
    required this.itemCount,
    required this.totalUsd,
    required this.onTap,
    this.totalVes,
    this.rate,
    super.key,
  });

  /// Total en VES ya calculado (con el redondeo del negocio, si aplica).
  final Decimal? totalVes;
  final int itemCount;
  final Decimal totalUsd;
  final VoidCallback onTap;
  final Decimal? rate;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();

    return Material(
      color: AppColors.ink,
      elevation: 8,
      shadowColor: AppColors.ink,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        borderRadius: AppRadius.pillAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: const Icon(Icons.shopping_bag_rounded, color: AppColors.onAccent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.viewCart,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subtitle.copyWith(color: AppColors.white),
                    ),
                    Text(
                      Strings.cartItems(itemCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.onInkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DualCurrencyText(
                amountUsd: totalUsd,
                amountVes: totalVes,
                rate: rate,
                crossAxisAlignment: CrossAxisAlignment.end,
                usdColor: AppColors.accent,
                vesColor: AppColors.onInkMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.chevron_right_rounded, color: AppColors.white),
            ],
          ),
        ),
      ),
    );
  }
}
