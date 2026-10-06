import 'package:pos_app/core/network/paged_list.dart';
import 'package:pos_app/features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rate_history_provider.g.dart';

/// Tasa oficial del BCV, solo como referencia.
@riverpod
Future<BcvRate> bcvRate(Ref ref) => ref.watch(exchangeRateRepositoryProvider).fetchBcvRate();

/// Histórico de tasas, cargado página a página.
@riverpod
class RateHistory extends _$RateHistory {
  bool _loadingMore = false;

  @override
  Future<PagedList<ExchangeRate>> build() async {
    final page = await ref.watch(exchangeRateRepositoryProvider).fetchHistory(page: 1);
    return PagedList.first(page);
  }

  Future<void> loadMore() async {
    final current = state.value;
    final nextPage = current?.nextPage;
    if (current == null || nextPage == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await ref.read(exchangeRateRepositoryProvider).fetchHistory(page: nextPage);
      state = AsyncData(current.append(page));
    } finally {
      _loadingMore = false;
    }
  }
}
