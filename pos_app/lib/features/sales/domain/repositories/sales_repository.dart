import 'package:pos_app/features/sales/domain/entities/sale.dart';
import 'package:pos_app/features/sales/domain/entities/sales_summary.dart';

/// Contrato de ventas. El historial y el detalle se añaden en la fase de
/// administración.
abstract interface class SalesRepository {
  /// Número de ventas y totales de la sucursal en el periodo indicado.
  Future<SalesSummary> fetchSummary({
    required String branchCode,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  /// Registra una venta. Devuelve la venta con los totales y la tasa del backend.
  ///
  /// Lanza `Failure` con el `code` del backend: `no_open_session`,
  /// `insufficient_stock`, `payment_mismatch`, `inactive_product`…
  Future<Sale> createSale(NewSale sale);
}
