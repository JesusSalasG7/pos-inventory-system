import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';

/// Barra superior de las pantallas operativas: sucursal activa, tasa del día
/// y estado de la caja.
///
/// Es un widget de presentación: recibe los datos ya resueltos. El nombre de la
/// sucursal es el `name` de la API y solo se puede tocar para cambiarla cuando
/// el usuario es un MANAGER con varias sedes.
class BranchHeader extends StatelessWidget implements PreferredSizeWidget {
  const BranchHeader({
    required this.branchName,
    required this.rate,
    required this.isSessionOpen,
    this.canChangeBranch = false,
    this.onBranchTap,
    this.onSessionTap,
    super.key,
  });

  static const double height = 104;

  final String? branchName;

  /// Tasa activa (VES por 1 USD); `null` si aún no hay ninguna.
  final Decimal? rate;

  /// `null` mientras no se conoce el estado de la caja.
  final bool? isSessionOpen;
  final bool canChangeBranch;
  final VoidCallback? onBranchTap;
  final VoidCallback? onSessionTap;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final rate = this.rate;
    final isSessionOpen = this.isSessionOpen;
    final branchTap = canChangeBranch ? onBranchTap : null;

    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: branchTap != null,
                      label: branchTap == null ? null : Strings.changeBranch,
                      child: InkWell(
                        borderRadius: AppRadius.smAll,
                        onTap: branchTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: AppRadius.smAll,
                                ),
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Strings.branchLabel,
                                      style: AppTypography.label.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    Text(
                                      branchName ?? Strings.noBranch,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.title,
                                    ),
                                  ],
                                ),
                              ),
                              if (branchTap != null)
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (isSessionOpen != null)
                    _SessionChip(isOpen: isSessionOpen, onTap: onSessionTap),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(
                      Icons.currency_exchange_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${Strings.rateOfTheDay}  ',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                    Flexible(
                      child: Text(
                        rate == null
                            ? Strings.rateNotSet
                            : '${Strings.rateUnit} ${MoneyFormatter.rate(rate)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.amount(
                          15,
                          color: rate == null ? AppColors.warning : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionChip extends StatelessWidget {
  const _SessionChip({required this.isOpen, this.onTap});

  final bool isOpen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isOpen ? AppColors.success : AppColors.textSecondary;
    final background = isOpen ? AppColors.successSoft : AppColors.surfaceMuted;
    final label = isOpen ? Strings.sessionOpen : Strings.sessionClosed;
    // En pantallas estrechas el chip se acorta para no recortar el nombre de la sede.
    final isNarrow = MediaQuery.sizeOf(context).width < 360;
    final visibleLabel = isNarrow
        ? (isOpen ? Strings.sessionOpenShort : Strings.sessionClosedShort)
        : label;

    return Semantics(
      button: onTap != null,
      label: onTap == null ? label : '$label. ${Strings.goToCashSession}',
      excludeSemantics: true,
      child: Material(
        color: background,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          borderRadius: AppRadius.pillAll,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOpen ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                  size: 16,
                  color: foreground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  visibleLabel,
                  style: AppTypography.label.copyWith(fontSize: 13, color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
