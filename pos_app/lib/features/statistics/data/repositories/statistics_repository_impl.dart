import 'package:intl/intl.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/features/statistics/data/datasources/statistics_remote_datasource.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_repository_impl.g.dart';

@Riverpod(keepAlive: true)
StatisticsRepository statisticsRepository(Ref ref) {
  return StatisticsRepositoryImpl(StatisticsRemoteDataSource(ref.watch(dioProvider)));
}

class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl(this._remote);

  final StatisticsRemoteDataSource _remote;

  static final DateFormat _day = DateFormat('yyyy-MM-dd');

  /// Filtros globales como los espera la API. Las fechas son de calendario:
  /// el backend las interpreta en la zona horaria de la tienda.
  static Map<String, dynamic> queryOf(String branchCode, StatsFilter filter) => {
    'branch': branchCode,
    'date_from': _day.format(filter.period.from),
    'date_to': _day.format(filter.period.to),
    'category': ?filter.category?.id,
  };

  @override
  Future<StatsSummary> fetchSummary({required String branchCode, required StatsFilter filter}) {
    return Failure.guard(
      () async => (await _remote.fetchSummary(queryOf(branchCode, filter))).toEntity(),
    );
  }

  @override
  Future<CreditBreakdown> fetchCreditBreakdown({
    required String branchCode,
    required StatsFilter filter,
  }) {
    return Failure.guard(
      () async => (await _remote.fetchCreditBreakdown(queryOf(branchCode, filter))).toEntity(),
    );
  }

  @override
  Future<GroupReport> fetchGroups({required String branchCode, required StatsFilter filter}) {
    return Failure.guard(
      () async => (await _remote.fetchGroups(queryOf(branchCode, filter))).toEntity(),
    );
  }

  @override
  Future<List<ProductPerformance>> fetchRanking({
    required String branchCode,
    required StatsFilter filter,
    required RankingOrder order,
    int limit = 10,
  }) {
    return Failure.guard(() async {
      final dtos = await _remote.fetchRanking(
        queryOf(branchCode, filter),
        orderBy: order.apiValue,
        limit: limit,
      );
      return [for (final dto in dtos) dto.toEntity()];
    });
  }

  @override
  Future<StatsMatrix> fetchMatrix({required String branchCode, required StatsFilter filter}) {
    return Failure.guard(
      () async => (await _remote.fetchMatrix(queryOf(branchCode, filter))).toEntity(),
    );
  }

  @override
  Future<InventoryHealth> fetchInventoryHealth({required String branchCode, int? categoryId}) {
    return Failure.guard(() async {
      final dto = await _remote.fetchInventoryHealth({
        'branch': branchCode,
        'category': ?categoryId,
      });
      return dto.toEntity();
    });
  }
}
