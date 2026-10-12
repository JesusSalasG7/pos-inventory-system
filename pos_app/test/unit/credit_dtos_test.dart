import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/credits/data/datasources/credits_remote_datasource.dart';
import 'package:pos_app/features/credits/data/dtos/credit_dtos.dart';
import 'package:pos_app/features/credits/domain/entities/credit_payment.dart';
import 'package:pos_app/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:pos_app/features/sales/data/dtos/sale_dto.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';

import '../mocks/fake_repositories.dart';

void main() {
  test('el cliente trae su saldo en USD y en Bs a la tasa del BCV', () {
    final customer = CustomerDto.fromJson({
      'id': 4,
      'name': 'Ana Pérez',
      'tax_id': 'V-123',
      'phone': '0414',
      'credit_days': 7,
      'active': true,
      'balance_usd': '10.00',
      'overdue_usd': '4.00',
      'open_credits': 2,
      'next_due_date': '2026-10-09',
      'balance_ves': '8756.50',
      'payment_rate': '875.6500',
      'created_at': '2026-10-01T12:00:00Z',
    }).toEntity();

    expect(customer.balanceUsd, dec('10.00'));
    expect(customer.balanceVes, dec('8756.50'));
    expect(customer.paymentRate, dec('875.65'));
    expect(customer.nextDueDate, DateTime(2026, 10, 9));
    expect(customer.hasOverdue, isTrue);
  });

  test('sin tasa del BCV el saldo en Bs llega vacío', () {
    final customer = CustomerDto.fromJson({
      'id': 4,
      'name': 'Ana',
      'credit_days': 7,
      'active': true,
      'balance_usd': '0.00',
      'overdue_usd': '0.00',
      'open_credits': 0,
      'next_due_date': null,
      'balance_ves': null,
      'payment_rate': null,
    }).toEntity();

    expect(customer.balanceVes, isNull);
    expect(customer.hasDebt, isFalse);
  });

  test('la venta a crédito trae el cliente y el vencimiento', () {
    final sale = SaleDto.fromJson({
      'id': 9,
      'cash_session': 1,
      'user': 1,
      'branch': 'VILLA_LIBERTAD',
      'customer': 4,
      'credit_due_date': '2026-10-19',
      'exchange_rate_at_invoice': '150.0000',
      'total_usd': '10.00',
      'total_ves': '1500.00',
      'created_at': '2026-10-12T15:00:00Z',
      'details': <Map<String, dynamic>>[],
      'payments': [
        {'id': 1, 'method': 'CASH_USD', 'currency': 'USD', 'amount': '4.00'},
        {'id': 2, 'method': 'CREDIT', 'currency': 'USD', 'amount': '6.00'},
      ],
    }).toEntity();

    expect(sale.customerId, 4);
    expect(sale.creditDueDate, DateTime(2026, 10, 19));
    expect(sale.creditUsd, dec('6.00'));
    expect(sale.payments.last.method, PaymentMethod.credit);
  });

  test('el cuerpo de la venta lleva el cliente y el plazo del crédito', () {
    final body = SalesRemoteDataSource.saleBody(
      NewSale(
        branchCode: 'VILLA_LIBERTAD',
        items: [NewSaleItem(productId: 1, quantity: dec('1'))],
        payments: [NewSalePayment(method: PaymentMethod.credit, amount: dec('5'))],
        customerId: 4,
        creditDays: 0,
      ),
    );

    expect(body['customer_id'], 4);
    expect(body['credit_days'], 0);
    expect(body['payments'], [
      {'method': 'CREDIT', 'currency': 'USD', 'amount': '5.00'},
    ]);
  });

  test('el abono en bolívares viaja en su moneda, como string decimal', () {
    final body = CreditsRemoteDataSource.paymentBody(
      NewCreditPayment(
        method: PaymentMethod.mobilePayment,
        amount: dec('1500'),
        approvalReference: ' 0045 ',
      ),
    );

    expect(body, {
      'method': 'MOBILE_PAYMENT',
      'currency': 'VES',
      'amount': '1500.00',
      'approval_reference': '0045',
    });
  });
}
