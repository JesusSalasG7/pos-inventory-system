import 'package:pos_app/features/statistics/domain/entities/statistics.dart';

/// Contrato de las estadísticas de una tienda (solo MANAGER). Todo lo calcula
/// el backend; los importes van en USD.
abstract interface class StatisticsRepository {
  /// KPIs del período y del anterior, con la variación de cada uno.
  Future<StatsSummary> fetchSummary({required String branchCode, required StatsFilter filter});

  /// Ingresos y ganancia repartidos entre contado y crédito, con lo que
  /// sigue sin cobrarse.
  Future<CreditBreakdown> fetchCreditBreakdown({
    required String branchCode,
    required StatsFilter filter,
  });

  /// Rendimiento por categoría o, con una categoría en el filtro, por sus
  /// subcategorías.
  Future<GroupReport> fetchGroups({required String branchCode, required StatsFilter filter});

  /// Los `limit` mejores productos según `order`.
  Future<List<ProductPerformance>> fetchRanking({
    required String branchCode,
    required StatsFilter filter,
    required RankingOrder order,
    int limit = 10,
  });

  /// Matriz volumen vs. margen de los productos con ventas.
  Future<StatsMatrix> fetchMatrix({required String branchCode, required StatsFilter filter});

  /// Productos sin movimiento y por agotarse, a la fecha de hoy. No depende
  /// del período, solo de la categoría.
  Future<InventoryHealth> fetchInventoryHealth({required String branchCode, int? categoryId});
}
