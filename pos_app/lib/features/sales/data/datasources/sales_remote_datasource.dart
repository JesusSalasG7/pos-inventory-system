import 'package:dio/dio.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/features/sales/data/dtos/sale_dto.dart';
import 'package:pos_app/features/sales/data/dtos/sales_summary_dto.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';

class SalesRemoteDataSource {
  const SalesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<SalesSummaryDto> fetchSummary({
    required String branchCode,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'sales/reports/summary/',
      queryParameters: {
        'branch': branchCode,
        if (dateFrom != null) 'date_from': DateFormatter.toApi(dateFrom),
        if (dateTo != null) 'date_to': DateFormatter.toApi(dateTo),
      },
    );
    return SalesSummaryDto.fromJson(response.data!);
  }

  /// Cuerpo de `POST sales/`. Montos y cantidades van como string decimal; el
  /// precio nunca se envía.
  static Map<String, dynamic> saleBody(NewSale sale) => {
    'branch': sale.branchCode,
    if (sale.customerTaxId.trim().isNotEmpty) 'customer_tax_id': sale.customerTaxId.trim(),
    if (sale.customerName.trim().isNotEmpty) 'customer_name': sale.customerName.trim(),
    'items': [
      for (final item in sale.items)
        {'product_id': item.productId, 'quantity': quantityToApi(item.quantity)},
    ],
    'payments': [
      for (final payment in sale.payments)
        {
          'method': payment.method.apiValue,
          'currency': payment.method.currency.apiValue,
          'amount': moneyToApi(payment.amount),
          if (payment.approvalReference.trim().isNotEmpty)
            'approval_reference': payment.approvalReference.trim(),
        },
    ],
  };

  Future<SaleDto> createSale(NewSale sale) async {
    final response = await _dio.post<Map<String, dynamic>>('sales/', data: saleBody(sale));
    return SaleDto.fromJson(response.data!);
  }
}
