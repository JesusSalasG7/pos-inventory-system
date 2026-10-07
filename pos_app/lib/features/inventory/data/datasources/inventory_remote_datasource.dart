import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/inventory/data/dtos/inventory_movement_dto.dart';
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

  Future<Paginated<CategoryDto>> fetchCategories({required int page}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'categories/',
      queryParameters: {'page': page, 'page_size': Paginated.maxPageSize},
    );
    return Paginated.fromJson(response.data!, CategoryDto.fromJson);
  }

  Future<CategoryDto> createCategory(String name, {String icon = ''}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'categories/',
      data: {'name': name, 'icon': icon},
    );
    return CategoryDto.fromJson(response.data!);
  }

  Future<CategoryDto> updateCategory(
    int categoryId, {
    String? name,
    String? icon,
    bool? active,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'categories/$categoryId/',
      data: {'name': ?name, 'icon': ?icon, 'active': ?active},
    );
    return CategoryDto.fromJson(response.data!);
  }

  Future<ProductDto> createProduct(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>('products/', data: body);
    return ProductDto.fromJson(response.data!);
  }

  Future<ProductDto> updateProduct(int productId, Map<String, dynamic> body) async {
    final response = await _dio.patch<Map<String, dynamic>>('products/$productId/', data: body);
    return ProductDto.fromJson(response.data!);
  }

  Future<ProductDto> toggleProductActive(int productId) async {
    final response = await _dio.post<Map<String, dynamic>>('products/$productId/toggle-active/');
    return ProductDto.fromJson(response.data!);
  }

  Future<BranchStockDto> setMinimumStock({
    required String branchCode,
    required int productId,
    required Decimal minimumStock,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'inventory/$productId/minimum-stock/',
      data: {'branch': branchCode, 'minimum_stock': quantityToApi(minimumStock)},
    );
    return BranchStockDto.fromJson(response.data!);
  }

  Future<Paginated<InventoryMovementDto>> fetchMovements({
    required String branchCode,
    required int page,
    int? productId,
    String? movementType,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'inventory/movements/',
      queryParameters: {
        'branch': branchCode,
        'page': page,
        'product': ?productId,
        'movement_type': ?movementType,
      },
    );
    return Paginated.fromJson(response.data!, InventoryMovementDto.fromJson);
  }

  /// Devuelve `null` con un 204: el ajuste coincidía con el stock y no hubo movimiento.
  Future<InventoryMovementDto?> registerMovement({
    required String branchCode,
    required int productId,
    required String movementType,
    required Decimal quantity,
    String notes = '',
  }) async {
    final response = await _dio.post<dynamic>(
      'inventory/movements/',
      data: {
        'branch': branchCode,
        'product_id': productId,
        'movement_type': movementType,
        'quantity': quantityToApi(quantity),
        if (notes.isNotEmpty) 'notes': notes,
      },
    );
    final data = response.data;
    return data is Map<String, dynamic> ? InventoryMovementDto.fromJson(data) : null;
  }
}
