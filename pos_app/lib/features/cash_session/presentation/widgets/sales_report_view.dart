import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/core/widgets/skeleton.dart';
import 'package:pos_app/features/cash_session/domain/entities/session_sales_report.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';
import 'package:pos_app/features/cash_session/presentation/widgets/cash_summary_view.dart';

/// Resumen de lo vendido en una caja: ventas totales en las dos monedas,
/// cobros por forma de pago, inversión, ganancia y desglose por producto.
///
/// Es una columna de tarjetas pensada para ir dentro de una lista. Los montos
/// vienen calculados del backend: aquí no se convierte nada.
class SessionSalesReportSection extends ConsumerWidget {
  const SessionSalesReportSection({required this.sessionId, super.key});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = sessionSalesReportProvider(sessionId);
    return AsyncValueView<SessionSalesReport>(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      loading: const SkeletonBox(height: 220),
      data: (report) => SalesReportView(report: report),
    );
  }
}

class SalesReportView extends StatelessWidget {
  const SalesReportView({required this.report, super.key});

  final SessionSalesReport report;

  @override
  Widget build(BuildContext context) {
    final isLoss = report.profitUsd < Decimal.zero;
    final profitColor = isLoss ? AppColors.error : AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          color: AppColors.primarySoft,
          title: Strings.totalSales.toUpperCase(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                // Bolívares facturados con la tasa de cada venta, no convertidos hoy.
                child: DualCurrencyText(
                  amountUsd: report.totalUsd,
                  amountVes: report.totalVes,
                  size: DualCurrencySize.large,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  Strings.salesCount(report.salesCount),
                  style: AppTypography.label.copyWith(fontSize: 13, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
        if (report.salesCount == 0) ...[
          const SizedBox(height: AppSpacing.md),
          Text(Strings.noSalesInSession, style: AppTypography.bodySmall),
        ] else ...[
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: Strings.paymentBreakdown.toUpperCase(),
            child: Column(
              children: [
                for (final payment in report.payments)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            Strings.paymentMethod(payment.method),
                            style: AppTypography.body,
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
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: Strings.investmentAndProfit.toUpperCase(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MoneyLine(label: Strings.totalSales, usd: report.totalUsd, ves: report.totalVes),
                MoneyLine(
                  label: '− ${Strings.investment}',
                  usd: report.costUsd,
                  ves: report.costVes,
                ),
                const Divider(height: AppSpacing.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        isLoss ? Strings.loss : Strings.profit,
                        style: AppTypography.subtitle.copyWith(color: profitColor),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          MoneyFormatter.usd(report.profitUsd),
                          style: AppTypography.amount(22, color: profitColor),
                        ),
                        Text(
                          MoneyFormatter.ves(report.profitVes),
                          style: AppTypography.amount(16, color: profitColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(Strings.investmentNote, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: Strings.soldByProduct.toUpperCase(),
            child: Column(
              children: [
                for (final (index, product) in report.products.indexed) ...[
                  if (index > 0) const Divider(height: AppSpacing.xl),
                  _ProductRow(product: product),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Un producto vendido: cantidad, venta y costo en bolívares, y su ganancia.
class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final ProductSales product;

  @override
  Widget build(BuildContext context) {
    final profitColor = product.profitUsd < Decimal.zero ? AppColors.error : AppColors.success;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.subtitle,
              ),
              Text(
                Strings.soldQuantity(MoneyFormatter.quantity(product.quantity)),
                style: AppTypography.bodySmall,
              ),
              Text(
                Strings.soldAmount(MoneyFormatter.ves(product.salesVes)),
                style: AppTypography.bodySmall.copyWith(fontFeatures: AppTypography.tabular),
              ),
              Text(
                Strings.costAmount(MoneyFormatter.ves(product.costVes)),
                style: AppTypography.bodySmall.copyWith(fontFeatures: AppTypography.tabular),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(Strings.profit, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
            Text(
              MoneyFormatter.ves(product.profitVes),
              style: AppTypography.amount(16, color: profitColor),
            ),
            Text(
              MoneyFormatter.usd(product.profitUsd),
              style: AppTypography.amountSecondary(13, color: profitColor),
            ),
          ],
        ),
      ],
    );
  }
}
