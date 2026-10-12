import 'package:dio/dio.dart';
import 'package:pos_app/features/statistics/data/dtos/statistics_dtos.dart';

/// Endpoints de `statistics/`. `query` lleva los filtros globales ya armados.
class StatisticsRemoteDataSource {
  const StatisticsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> _get(String path, Map<String, dynamic> query) async {
    final response = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
    return response.data!;
  }

  Future<SummaryDto> fetchSummary(Map<String, dynamic> query) async =>
      SummaryDto.fromJson(await _get('statistics/summary/', query));

  Future<CreditBreakdownDto> fetchCreditBreakdown(Map<String, dynamic> query) async =>
      CreditBreakdownDto.fromJson(await _get('statistics/credit-breakdown/', query));

  Future<GroupReportDto> fetchGroups(Map<String, dynamic> query) async =>
      GroupReportDto.fromJson(await _get('statistics/groups/', query));

  Future<List<ProductPerformanceDto>> fetchRanking(
    Map<String, dynamic> query, {
    required String orderBy,
    required int limit,
  }) async {
    final data = await _get('statistics/products/ranking/', {
      ...query,
      'order_by': orderBy,
      'limit': limit,
    });
    return [
      for (final item in data['results'] as List<dynamic>)
        ProductPerformanceDto.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<MatrixDto> fetchMatrix(Map<String, dynamic> query) async =>
      MatrixDto.fromJson(await _get('statistics/matrix/', query));

  Future<InventoryHealthDto> fetchInventoryHealth(Map<String, dynamic> query) async =>
      InventoryHealthDto.fromJson(await _get('statistics/inventory-health/', query));
}
