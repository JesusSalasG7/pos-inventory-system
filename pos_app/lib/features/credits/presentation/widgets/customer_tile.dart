import 'package:flutter/material.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';

/// Círculo con la inicial del cliente; en rojo si tiene deudas vencidas.
class CustomerAvatar extends StatelessWidget {
  const CustomerAvatar({required this.customer, this.size = 44, super.key});

  final Customer customer;
  final double size;

  @override
  Widget build(BuildContext context) {
    final name = customer.name.trim();
    final (background, foreground) = customer.hasOverdue
        ? (AppColors.errorSoft, AppColors.error)
        : customer.hasDebt
        ? (AppColors.warningSoft, AppColors.warning)
        : (AppColors.primarySoft, AppColors.primaryDark);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: AppTypography.amount(size * 0.42, color: foreground),
      ),
    );
  }
}

/// Fila de un cliente: nombre, documento y lo que debe en la tienda.
class CustomerTile extends StatelessWidget {
  const CustomerTile({required this.customer, required this.onTap, super.key});

  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = [
      customer.taxId,
      customer.phone,
      if (!customer.active) Strings.inactiveCustomer,
    ].where((value) => value.isNotEmpty).join(' · ');
    final nextDue = customer.nextDueDate;

    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Opacity(
        opacity: customer.active ? 1 : 0.6,
        child: Row(
          children: [
            CustomerAvatar(customer: customer),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle,
                  ),
                  if (details.isNotEmpty)
                    Text(
                      details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall,
                    ),
                  if (customer.hasOverdue)
                    Text(
                      Strings.overdueAmount(MoneyFormatter.usd(customer.overdueUsd)),
                      style: AppTypography.label.copyWith(fontSize: 13, color: AppColors.error),
                    )
                  else if (customer.hasDebt && nextDue != null)
                    Text(
                      Strings.nextDue(DateFormatter.calendarDate(nextDue)),
                      style: AppTypography.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (customer.hasDebt) ...[
                  Text(Strings.owes, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
                  Text(
                    MoneyFormatter.usd(customer.balanceUsd),
                    style: AppTypography.amount(
                      17,
                      color: customer.hasOverdue ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                ] else
                  Text(
                    Strings.noDebt,
                    style: AppTypography.label.copyWith(fontSize: 13, color: AppColors.success),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
