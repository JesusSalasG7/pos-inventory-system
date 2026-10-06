import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/features/pos/domain/sale_receipt.dart';

/// Texto plano del comprobante, para compartirlo por WhatsApp u otra app.
///
/// Usa solo datos de la venta registrada: los bolívares salen de la tasa
/// congelada (`exchange_rate_at_invoice`), no de la tasa de hoy.
String buildReceiptText(SaleReceipt receipt) {
  final sale = receipt.sale;
  final lines = <String>[
    if (receipt.branchName != null) receipt.branchName!,
    Strings.saleNumber(sale.id),
    DateFormatter.dateTime(sale.createdAt),
    if (sale.customerName.isNotEmpty || sale.customerTaxId.isNotEmpty)
      '${Strings.customer}: ${[sale.customerName, sale.customerTaxId].where((v) => v.isNotEmpty).join(' · ')}',
    '',
    for (final detail in sale.details)
      '${MoneyFormatter.quantity(detail.quantity)} × ${receipt.productName(detail.productId)}'
          '  ${MoneyFormatter.usd(detail.subtotalUsd)}',
    '',
    '${Strings.total}: ${MoneyFormatter.usd(sale.totalUsd)}  /  ${MoneyFormatter.ves(sale.totalVes)}',
    Strings.rateUsed(MoneyFormatter.rate(sale.exchangeRateAtInvoice)),
    '',
    for (final payment in sale.payments)
      '${Strings.paymentMethod(payment.method)}: '
          '${payment.currency == Currency.usd ? MoneyFormatter.usd(payment.amount) : MoneyFormatter.ves(payment.amount)}'
          '${payment.approvalReference.isEmpty ? '' : ' (${Strings.referenceLabel(payment.approvalReference)})'}',
  ];
  return lines.join('\n');
}
