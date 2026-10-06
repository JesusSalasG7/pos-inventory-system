import 'package:dio/dio.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/features/sales/data/dtos/sales_summary_dto.dart';

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
}
