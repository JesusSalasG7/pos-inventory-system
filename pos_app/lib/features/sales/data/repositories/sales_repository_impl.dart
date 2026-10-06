import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';
import 'package:pos_app/features/sales/domain/entities/sales_summary.dart';
import 'package:pos_app/features/sales/domain/repositories/sales_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sales_repository_impl.g.dart';

@Riverpod(keepAlive: true)
SalesRepository salesRepository(Ref ref) {
  return SalesRepositoryImpl(SalesRemoteDataSource(ref.watch(dioProvider)));
}

class SalesRepositoryImpl implements SalesRepository {
  const SalesRepositoryImpl(this._remote);

  final SalesRemoteDataSource _remote;

  @override
  Future<SalesSummary> fetchSummary({
    required String branchCode,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return Failure.guard(
      () async => (await _remote.fetchSummary(
        branchCode: branchCode,
        dateFrom: dateFrom,
        dateTo: dateTo,
      )).toEntity(),
    );
  }

  @override
  Future<Sale> createSale(NewSale sale) {
    return Failure.guard(() async => (await _remote.createSale(sale)).toEntity());
  }
}
