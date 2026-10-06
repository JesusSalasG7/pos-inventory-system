import 'package:flutter/foundation.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';

/// Venta recién registrada, lista para mostrar como comprobante.
///
/// El backend no devuelve el nombre de los productos, solo su id, así que se
/// guardan aquí los nombres que había en el carrito.
@immutable
class SaleReceipt {
  const SaleReceipt({required this.sale, required this.productNames, this.branchName});

  final Sale sale;
  final Map<int, String> productNames;
  final String? branchName;

  String productName(int productId) => productNames[productId] ?? '#$productId';
}
