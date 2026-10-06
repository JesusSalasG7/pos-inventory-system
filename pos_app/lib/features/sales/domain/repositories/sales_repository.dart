import 'package:pos_app/features/sales/domain/entities/sales_summary.dart';

/// Contrato de ventas. El alta, el historial y el detalle se añaden en las
/// fases de POS y de administración.
abstract interface class SalesRepository {
  /// Número de ventas y totales de la sucursal en el periodo indicado.
  Future<SalesSummary> fetchSummary({
    required String branchCode,
    DateTime? dateFrom,
    DateTime? dateTo,
  });
}
