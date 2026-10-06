import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/cash_session/data/dtos/cash_session_dto.dart';

class CashSessionRemoteDataSource {
  const CashSessionRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CashSessionDto> fetchCurrent() async {
    final response = await _dio.get<Map<String, dynamic>>('cash-sessions/current/');
    return CashSessionDto.fromJson(response.data!);
  }

  Future<CashSessionDto> open({required String branchCode, required Decimal openingFloat}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'cash-sessions/',
      data: {'branch': branchCode, 'opening_float': moneyToApi(openingFloat)},
    );
    return CashSessionDto.fromJson(response.data!);
  }

  Future<Paginated<CashSessionDto>> fetchSessions({
    required String branchCode,
    required int page,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'cash-sessions/',
      queryParameters: {'branch': branchCode, 'page': page},
    );
    return Paginated.fromJson(response.data!, CashSessionDto.fromJson);
  }

  Future<Paginated<CashExpenseDto>> fetchExpenses({
    required int sessionId,
    required int page,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'cash-sessions/$sessionId/expenses/',
      queryParameters: {'page': page, 'page_size': Paginated.maxPageSize},
    );
    return Paginated.fromJson(response.data!, CashExpenseDto.fromJson);
  }

  Future<CashExpenseDto> registerExpense({
    required int sessionId,
    required String reason,
    required Decimal amount,
    required String currency,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'cash-sessions/$sessionId/expenses/',
      data: {'reason': reason, 'amount': moneyToApi(amount), 'currency': currency},
    );
    return CashExpenseDto.fromJson(response.data!);
  }

  Future<CashCountSummaryDto> fetchSummary(int sessionId) async {
    final response = await _dio.get<Map<String, dynamic>>('cash-sessions/$sessionId/summary/');
    return CashCountSummaryDto.fromJson(response.data!);
  }

  Future<CashSessionDto> close({
    required int sessionId,
    required Decimal countedAmountUsd,
    required Decimal countedAmountVes,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'cash-sessions/$sessionId/close/',
      data: {
        'counted_amount_usd': moneyToApi(countedAmountUsd),
        'counted_amount_ves': moneyToApi(countedAmountVes),
      },
    );
    return CashSessionDto.fromJson(response.data!);
  }
}
