import 'package:decimal/decimal.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/network/paged_list.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';
import 'package:pos_app/features/sales/domain/entities/sales_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sales_history_providers.g.dart';

/// Número de ventas y totales de la tienda activa en un día de Caracas.
/// `day` es una fecha de calendario (sin hora).
@riverpod
Future<SalesSummary> daySalesSummary(Ref ref, DateTime day) async {
  final branch = ref.watch(activeBranchProvider);
  if (branch == null) {
    return SalesSummary(salesCount: 0, totalUsd: Decimal.zero, totalVes: Decimal.zero);
  }
  return ref
      .watch(salesRepositoryProvider)
      .fetchSummary(
        branchCode: branch.code,
        dateFrom: DateFormatter.startOfCalendarDay(day),
        dateTo: DateFormatter.endOfCalendarDay(day),
      );
}

/// Ventas de la tienda activa en un día de Caracas, de la más reciente a la
/// más antigua, cargadas página a página.
@riverpod
class SalesHistory extends _$SalesHistory {
  bool _loadingMore = false;
  late DateTime _day;

  @override
  Future<PagedList<Sale>> build(DateTime day) async {
    _day = day;
    final branch = ref.watch(activeBranchProvider);
    if (branch == null) return const PagedList(items: [], totalCount: 0, nextPage: null);
    final page = await _fetch(branch.code, 1);
    return PagedList.first(page);
  }

  Future<Paginated<Sale>> _fetch(String branchCode, int page) => ref
      .read(salesRepositoryProvider)
      .fetchSales(
        branchCode: branchCode,
        page: page,
        dateFrom: DateFormatter.startOfCalendarDay(_day),
        dateTo: DateFormatter.endOfCalendarDay(_day),
      );

  Future<void> loadMore() async {
    final current = state.value;
    final nextPage = current?.nextPage;
    final branch = ref.read(activeBranchProvider);
    if (current == null || nextPage == null || branch == null || _loadingMore) return;
    _loadingMore = true;
    try {
      state = AsyncData(current.append(await _fetch(branch.code, nextPage)));
    } finally {
      _loadingMore = false;
    }
  }
}
