import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_app/core/currency/decimal_converter.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';

part 'product_dto.freezed.dart';
part 'product_dto.g.dart';

/// Producto tal como lo devuelve `products/`: la categoría llega como su id
/// más su nombre. No trae stock ni imagen.
@freezed
abstract class ProductDto with _$ProductDto {
  const factory ProductDto({
    required int id,
    required String name,
    required int category,
    required String categoryName,
    @Default('') String categoryIcon,
    required String unitOfMeasure,
    @DecimalConverter() required Decimal costPriceUsd,
    @DecimalConverter() required Decimal salePriceUsd,
    required bool active,
  }) = _ProductDto;

  const ProductDto._();

  factory ProductDto.fromJson(Map<String, dynamic> json) => _$ProductDtoFromJson(json);

  Product toEntity() => Product(
    id: id,
    name: name,
    category: ProductCategory(id: category, name: categoryName, icon: categoryIcon),
    unit: UnitOfMeasure.fromApi(unitOfMeasure),
    costPriceUsd: costPriceUsd,
    salePriceUsd: salePriceUsd,
    active: active,
  );
}

/// Fila de `inventory/`: stock de un producto en una sucursal.
@freezed
abstract class BranchStockDto with _$BranchStockDto {
  const factory BranchStockDto({
    required int id,
    required int product,
    required String productName,
    required String branch,
    @DecimalConverter() required Decimal currentStock,
    @DecimalConverter() required Decimal minimumStock,
  }) = _BranchStockDto;

  const BranchStockDto._();

  factory BranchStockDto.fromJson(Map<String, dynamic> json) => _$BranchStockDtoFromJson(json);

  BranchStock toEntity() => BranchStock(
    productId: product,
    productName: productName,
    branchCode: branch,
    currentStock: currentStock,
    minimumStock: minimumStock,
  );
}

/// Categoría tal como la devuelve `categories/`.
@freezed
abstract class CategoryDto with _$CategoryDto {
  const factory CategoryDto({
    required int id,
    required String name,
    required bool active,
    @Default('') String icon,
  }) = _CategoryDto;

  const CategoryDto._();

  factory CategoryDto.fromJson(Map<String, dynamic> json) => _$CategoryDtoFromJson(json);

  ProductCategory toEntity() => ProductCategory(id: id, name: name, icon: icon, active: active);
}
