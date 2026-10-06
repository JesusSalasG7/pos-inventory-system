import 'package:decimal/decimal.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/exchange_rate/data/datasources/exchange_rate_remote_datasource.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';
import 'package:pos_app/features/exchange_rate/domain/repositories/exchange_rate_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exchange_rate_repository_impl.g.dart';

@Riverpod(keepAlive: true)
ExchangeRateRepository exchangeRateRepository(Ref ref) {
  return ExchangeRateRepositoryImpl(ExchangeRateRemoteDataSource(ref.watch(dioProvider)));
}

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  const ExchangeRateRepositoryImpl(this._remote);

  /// Código con el que el backend avisa de que todavía no hay tasa.
  static const String notSetCode = 'exchange_rate_not_set';

  final ExchangeRateRemoteDataSource _remote;

  @override
  Future<ExchangeRate?> fetchActive() async {
    try {
      return await Failure.guard(() async => (await _remote.fetchCurrent()).toEntity());
    } on Failure catch (failure) {
      if (failure.code == notSetCode) return null;
      rethrow;
    }
  }

  @override
  Future<Paginated<ExchangeRate>> fetchHistory({required int page}) {
    return Failure.guard(
      () async => (await _remote.fetchHistory(page: page)).map((dto) => dto.toEntity()),
    );
  }

  @override
  Future<ExchangeRate> registerRate(Decimal rate) {
    return Failure.guard(() async => (await _remote.register(rate)).toEntity());
  }

  @override
  Future<BcvSyncResult> syncWithBcv() {
    return Failure.guard(() async {
      final (dto, changed) = await _remote.syncBcv();
      return BcvSyncResult(rate: dto.toEntity(), changed: changed);
    });
  }

  @override
  Future<BcvRate> fetchBcvRate() {
    return Failure.guard(() async => (await _remote.fetchBcv()).toEntity());
  }
}
