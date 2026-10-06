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
    this.rate,
    super.key,
  });

  static const Color _secondaryOnPrimary = Color(0xFFD5E6EE);

  final int itemCount;
  final Decimal totalUsd;
  final VoidCallback onTap;
  final Decimal? rate;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();

    return Material(
      color: AppColors.primary,
      elevation: 6,
      shadowColor: AppColors.primaryDark,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: AppRadius.smAll,
                ),
                child: const Icon(Icons.shopping_bag_rounded, color: AppColors.onPrimary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.viewCart,
                      style: AppTypography.subtitle.copyWith(color: AppColors.onPrimary),
                    ),
                    Text(
                      Strings.cartItems(itemCount),
                      style: AppTypography.bodySmall.copyWith(color: _secondaryOnPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DualCurrencyText(
                amountUsd: totalUsd,
                rate: rate,
                crossAxisAlignment: CrossAxisAlignment.end,
                usdColor: AppColors.onPrimary,
                vesColor: _secondaryOnPrimary,
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.chevron_right_rounded, color: AppColors.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
