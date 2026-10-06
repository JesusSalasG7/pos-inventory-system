import 'package:decimal/decimal.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:pos_app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:pos_app/features/sales/domain/entities/sales_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_providers.g.dart';

/// Ventas de hoy (día de Caracas) en la sucursal activa.
@riverpod
Future<SalesSummary> todaySalesSummary(Ref ref) async {
  final branch = ref.watch(activeBranchProvider);
  if (branch == null) {
    return SalesSummary(salesCount: 0, totalUsd: Decimal.zero, totalVes: Decimal.zero);
  }
  return ref
      .watch(salesRepositoryProvider)
      .fetchSummary(
        branchCode: branch.code,
        dateFrom: DateFormatter.startOfCaracasDay(DateTime.now()),
      );
}

/// Productos de la sucursal activa en o bajo su stock mínimo.
@riverpod
Future<int> lowStockCount(Ref ref) async {
  final branch = ref.watch(activeBranchProvider);
  if (branch == null) return 0;
  return ref.watch(inventoryRepositoryProvider).fetchLowStockCount(branchCode: branch.code);
}
