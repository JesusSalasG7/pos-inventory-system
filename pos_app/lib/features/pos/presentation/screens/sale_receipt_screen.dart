import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/features/pos/domain/receipt_text.dart';
import 'package:pos_app/features/pos/domain/sale_receipt.dart';
import 'package:share_plus/share_plus.dart';

/// Comprobante de la venta recién registrada, con los datos que devolvió el
/// backend y su tasa congelada.
class SaleReceiptScreen extends StatelessWidget {
  const SaleReceiptScreen({required this.receipt, super.key});

  final SaleReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final sale = receipt.sale;
    final hasCustomer = sale.customerName.isNotEmpty || sale.customerTaxId.isNotEmpty;

    return PopScope(
      // Atrás no vuelve al cobro (la venta ya está hecha): va a Vender.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(RouteNames.sell);
      },
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false, title: const Text(Strings.receiptTitle)),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: Strings.newSale,
                icon: Icons.add_rounded,
                onPressed: () => context.go(RouteNames.sell),
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: Strings.share,
                icon: Icons.share_rounded,
                variant: ButtonVariant.outlined,
                onPressed: () =>
                    SharePlus.instance.share(ShareParams(text: buildReceiptText(receipt))),
              ),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            SectionCard(
              color: AppColors.primarySoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Strings.saleNumber(sale.id), style: AppTypography.title),
                            Text(
                              DateFormatter.dateTime(sale.createdAt),
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Tasa congelada de la venta, no la activa.
                  DualCurrencyText(
                    amountUsd: sale.totalUsd,
                    rate: sale.exchangeRateAtInvoice,
                    amountVes: sale.totalVes,
                    size: DualCurrencySize.large,
                  ),
                  Text(
                    Strings.rateUsed(MoneyFormatter.rate(sale.exchangeRateAtInvoice)),
                    style: AppTypography.bodySmall,
                  ),
                  if (hasCustomer) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${Strings.customer}: '
                      '${[sale.customerName, sale.customerTaxId].where((v) => v.isNotEmpty).join(' · ')}',
                      style: AppTypography.body,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              title: Strings.cartItemsTitle.toUpperCase(),
              child: Column(
                children: [
                  for (final (index, detail) in sale.details.indexed) ...[
                    if (index > 0) const Divider(height: AppSpacing.xl),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                receipt.productName(detail.productId),
                                style: AppTypography.subtitle,
                              ),
                              Text(
                                '${MoneyFormatter.quantity(detail.quantity)} × '
                                '${MoneyFormatter.usd(detail.unitPriceUsd)}',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DualCurrencyText(
                          amountUsd: detail.subtotalUsd,
                          rate: sale.exchangeRateAtInvoice,
                          size: DualCurrencySize.small,
                          crossAxisAlignment: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              title: Strings.payments.toUpperCase(),
              child: Column(
                children: [
                  for (final payment in sale.payments)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Strings.paymentMethod(payment.method),
                                  style: AppTypography.body,
                                ),
                                if (payment.approvalReference.isNotEmpty)
                                  Text(
                                    Strings.referenceLabel(payment.approvalReference),
                                    style: AppTypography.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            payment.currency == Currency.usd
                                ? MoneyFormatter.usd(payment.amount)
                                : MoneyFormatter.ves(payment.amount),
                            style: AppTypography.amount(16),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
