import 'package:dio/dio.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/inventory/data/dtos/product_dto.dart';

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

  Future<Paginated<ProductDto>> fetchProducts({required int page, bool onlyActive = false}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'products/',
      queryParameters: {
        'page': page,
        'page_size': Paginated.maxPageSize,
        if (onlyActive) 'active': 'true',
      },
    );
    return Paginated.fromJson(response.data!, ProductDto.fromJson);
  }

  Future<Paginated<BranchStockDto>> fetchBranchStock({
    required String branchCode,
    required int page,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'inventory/',
      queryParameters: {'branch': branchCode, 'page': page, 'page_size': Paginated.maxPageSize},
    );
    return Paginated.fromJson(response.data!, BranchStockDto.fromJson);
  }
}
