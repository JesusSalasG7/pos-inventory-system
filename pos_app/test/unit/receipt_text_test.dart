import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/pos/domain/receipt_text.dart';
import 'package:pos_app/features/pos/domain/sale_receipt.dart';
import 'package:pos_app/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:pos_app/features/sales/data/dtos/sale_dto.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';

import '../mocks/fake_repositories.dart';

/// Respuesta de `POST sales/` tal como figura en docs/api_contracts.md.
const saleJson = <String, dynamic>{
  'id': 41,
  'cash_session': 7,
  'user': 2,
  'branch': 'PRINCIPAL',
  'customer_tax_id': 'V12345678',
  'customer_name': 'Ana Pérez',
  'exchange_rate_at_invoice': '150.0000',
  'total_usd': '15.00',
  'total_ves': '2250.00',
  'created_at': '2026-10-06T10:15:00-04:00',
  'details': [
    {
      'id': 90,
      'product': 3,
      'quantity': '2.500',
      'unit_price_usd': '6.00',
      'subtotal_usd': '15.00',
    },
  ],
  'payments': [
    {'id': 77, 'method': 'CASH_USD', 'currency': 'USD', 'amount': '5.00', 'approval_reference': ''},
    {
      'id': 78,
      'method': 'MOBILE_PAYMENT',
      'currency': 'VES',
      'amount': '1500.00',
      'approval_reference': '004512',
    },
  ],
};

void main() {
  setUpAll(initializeDateFormatting);

  test('la venta del backend se lee con Decimal, sin perder precisión', () {
    final sale = SaleDto.fromJson(saleJson).toEntity();

    expect(sale.id, 41);
    expect(sale.branchCode, 'PRINCIPAL');
    expect(sale.exchangeRateAtInvoice, dec('150'));
    expect(sale.totalVes, dec('2250.00'));
    expect(sale.details.single.quantity, dec('2.5'));
    expect(sale.payments.last.method, PaymentMethod.mobilePayment);
    expect(sale.payments.last.approvalReference, '004512');
    expect(sale.createdAt.toUtc(), DateTime.utc(2026, 10, 6, 14, 15));
  });

  test('el cuerpo de la venta envía strings decimales y nunca el precio', () {
    final body = SalesRemoteDataSource.saleBody(
      NewSale(
        branchCode: 'PRINCIPAL',
        customerName: ' Ana Pérez ',
        items: [NewSaleItem(productId: 3, quantity: dec('2.5'))],
        payments: [
          NewSalePayment(method: PaymentMethod.cashUsd, amount: dec('5')),
          NewSalePayment(
            method: PaymentMethod.mobilePayment,
            amount: dec('1500'),
            approvalReference: '004512',
          ),
        ],
      ),
    );

    expect(body, {
      'branch': 'PRINCIPAL',
      'customer_name': 'Ana Pérez',
      'items': [
        {'product_id': 3, 'quantity': '2.500'},
      ],
      'payments': [
        {'method': 'CASH_USD', 'currency': 'USD', 'amount': '5.00'},
        {
          'method': 'MOBILE_PAYMENT',
          'currency': 'VES',
          'amount': '1500.00',
          'approval_reference': '004512',
        },
      ],
    });
  });

  test('el comprobante compartido usa la tasa congelada y los datos del backend', () {
    final receipt = SaleReceipt(
      sale: SaleDto.fromJson(saleJson).toEntity(),
      productNames: const {3: 'Cloro concentrado'},
      branchName: 'Local principal',
    );

    final text = buildReceiptText(receipt);

    expect(text, contains('Local principal'));
    expect(text, contains('Venta #41'));
    expect(text, contains('06/10/2026'));
    expect(text, contains('Cliente: Ana Pérez · V12345678'));
    expect(text, contains(r'2,5 × Cloro concentrado  $ 15,00'));
    expect(text, contains(r'Total: $ 15,00  /  Bs 2.250,00'));
    expect(text, contains(r'Tasa: Bs/$ 150,00'));
    expect(text, contains(r'$ Efectivo: $ 5,00'));
    expect(text, contains('Pago Móvil: Bs 1.500,00 (Ref. 004512)'));
  });
}
