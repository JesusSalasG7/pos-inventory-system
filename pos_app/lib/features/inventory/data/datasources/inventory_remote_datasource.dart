import 'package:dio/dio.dart';

class InventoryRemoteDataSource {
  const InventoryRemoteDataSource(this._dio);

  final Dio _dio;

  /// Solo interesa el `count` de la paginación: se pide una página de un elemento.
  Future<int> fetchLowStockCount({required String branchCode}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'inventory/low-stock/',
      queryParameters: {'branch': branchCode, 'page_size': 1},
    );
    return response.data!['count'] as int;
  }
}
