import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/cash_session/data/dtos/cash_session_dto.dart';

import '../mocks/fake_repositories.dart';

void main() {
  test('lee el resumen de ventas de una caja tal como lo envía el backend', () {
    final report = SessionSalesReportDto.fromJson({
      'sales_count': 2,
      'total_usd': '12.00',
      'total_ves': '2025.00',
      'cost_usd': '8.00',
      'cost_ves': '1350.00',
      'profit_usd': '4.00',
      'profit_ves': '675.00',
      'payments': [
        {'method': 'CASH_USD', 'currency': 'USD', 'amount': '3.00'},
        {'method': 'MOBILE_PAYMENT', 'currency': 'VES', 'amount': '1575.00'},
      ],
      'products': [
        {
          'product': 2,
          'product_name': 'Escoba',
          'quantity': '2.000',
          'sales_usd': '9.00',
          'sales_ves': '1575.00',
          'cost_usd': '6.00',
          'cost_ves': '1050.00',
          'profit_usd': '3.00',
          'profit_ves': '525.00',
        },
      ],
    }).toEntity();

    expect(report.salesCount, 2);
    expect(report.totalVes, dec('2025.00'));
    expect(report.costVes, dec('1350.00'));
    expect(report.profitUsd, dec('4.00'));
    expect(report.payments.last.method, PaymentMethod.mobilePayment);
    expect(report.payments.last.currency, Currency.ves);
    expect(report.products.single.productName, 'Escoba');
    expect(report.products.single.quantity, dec('2'));
    expect(report.products.single.profitVes, dec('525.00'));
  });
}
