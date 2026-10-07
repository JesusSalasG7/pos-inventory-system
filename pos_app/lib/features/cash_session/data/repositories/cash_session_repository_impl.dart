import 'package:decimal/decimal.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/cash_session/data/datasources/cash_session_remote_datasource.dart';
import 'package:pos_app/features/cash_session/domain/entities/cash_session.dart';
import 'package:pos_app/features/cash_session/domain/entities/session_sales_report.dart';
import 'package:pos_app/features/cash_session/domain/repositories/cash_session_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cash_session_repository_impl.g.dart';

@Riverpod(keepAlive: true)
CashSessionRepository cashSessionRepository(Ref ref) {
  return CashSessionRepositoryImpl(CashSessionRemoteDataSource(ref.watch(dioProvider)));
}

class CashSessionRepositoryImpl implements CashSessionRepository {
  const CashSessionRepositoryImpl(this._remote);

  /// Código con el que el backend avisa de que el usuario no tiene caja abierta.
  static const String noOpenSessionCode = 'no_open_session';

  final CashSessionRemoteDataSource _remote;

  @override
  Future<CashSession?> fetchCurrent() async {
    try {
      return await Failure.guard(() async => (await _remote.fetchCurrent()).toEntity());
    } on Failure catch (failure) {
      if (failure.code == noOpenSessionCode) return null;
      rethrow;
    }
  }

  @override
  Future<CashSession> open({required String branchCode, required Decimal openingFloat}) {
    return Failure.guard(
      () async =>
          (await _remote.open(branchCode: branchCode, openingFloat: openingFloat)).toEntity(),
    );
  }

  @override
  Future<Paginated<CashSession>> fetchSessions({required String branchCode, required int page}) {
    return Failure.guard(
      () async => (await _remote.fetchSessions(
        branchCode: branchCode,
        page: page,
      )).map((dto) => dto.toEntity()),
    );
  }

  @override
  Future<List<CashExpense>> fetchExpenses(int sessionId) {
    return Failure.guard(() async {
      final dtos = await Paginated.fetchAll(
        (page) => _remote.fetchExpenses(sessionId: sessionId, page: page),
      );
      return [for (final dto in dtos) dto.toEntity()];
    });
  }

  @override
  Future<CashExpense> registerExpense({
    required int sessionId,
    required String reason,
    required Decimal amount,
    required Currency currency,
  }) {
    return Failure.guard(
      () async => (await _remote.registerExpense(
        sessionId: sessionId,
        reason: reason.trim(),
        amount: amount,
        currency: currency.apiValue,
      )).toEntity(),
    );
  }

  @override
  Future<CashCountSummary> fetchSummary(int sessionId) {
    return Failure.guard(() async => (await _remote.fetchSummary(sessionId)).toEntity());
  }

  @override
  Future<SessionSalesReport> fetchSalesReport(int sessionId) {
    return Failure.guard(() async => (await _remote.fetchSalesReport(sessionId)).toEntity());
  }

  @override
  Future<CashSession> close({
    required int sessionId,
    required Decimal countedAmountUsd,
    required Decimal countedAmountVes,
  }) {
    return Failure.guard(
      () async => (await _remote.close(
        sessionId: sessionId,
        countedAmountUsd: countedAmountUsd,
        countedAmountVes: countedAmountVes,
      )).toEntity(),
    );
  }
}
