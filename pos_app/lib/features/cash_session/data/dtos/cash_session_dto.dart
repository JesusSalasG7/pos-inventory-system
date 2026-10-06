import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_app/core/currency/decimal_converter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/cash_session/domain/entities/cash_session.dart';

part 'cash_session_dto.freezed.dart';
part 'cash_session_dto.g.dart';

@freezed
abstract class CashSessionDto with _$CashSessionDto {
  const factory CashSessionDto({
    required int id,
    required int user,
    required String branch,
    required DateTime openedAt,
    @DecimalConverter() required Decimal openingFloat,
    DateTime? closedAt,
    @NullableDecimalConverter() Decimal? countedAmountUsd,
    @NullableDecimalConverter() Decimal? countedAmountVes,
    @NullableDecimalConverter() Decimal? differenceUsd,
  }) = _CashSessionDto;

  const CashSessionDto._();

  factory CashSessionDto.fromJson(Map<String, dynamic> json) => _$CashSessionDtoFromJson(json);

  CashSession toEntity() => CashSession(
    id: id,
    userId: user,
    branchCode: branch,
    openedAt: openedAt,
    closedAt: closedAt,
    openingFloat: openingFloat,
    countedAmountUsd: countedAmountUsd,
    countedAmountVes: countedAmountVes,
    differenceUsd: differenceUsd,
  );
}

@freezed
abstract class CashExpenseDto with _$CashExpenseDto {
  const factory CashExpenseDto({
    required int id,
    required int cashSession,
    required String reason,
    @DecimalConverter() required Decimal amount,
    required String currency,
    required int createdBy,
    required DateTime createdAt,
  }) = _CashExpenseDto;

  const CashExpenseDto._();

  factory CashExpenseDto.fromJson(Map<String, dynamic> json) => _$CashExpenseDtoFromJson(json);

  CashExpense toEntity() => CashExpense(
    id: id,
    cashSessionId: cashSession,
    reason: reason,
    amount: amount,
    currency: Currency.fromApi(currency),
    createdBy: createdBy,
    createdAt: createdAt,
  );
}

@freezed
abstract class CashCountSummaryDto with _$CashCountSummaryDto {
  const factory CashCountSummaryDto({
    @DecimalConverter() required Decimal openingFloat,
    @DecimalConverter() required Decimal cashSalesUsd,
    @DecimalConverter() required Decimal cashSalesVes,
    @DecimalConverter() required Decimal electronicSalesUsd,
    @DecimalConverter() required Decimal electronicSalesVes,
    @DecimalConverter() required Decimal expensesUsd,
    @DecimalConverter() required Decimal expensesVes,
    @DecimalConverter() required Decimal expectedCashUsd,
    @DecimalConverter() required Decimal expectedCashVes,
  }) = _CashCountSummaryDto;

  const CashCountSummaryDto._();

  factory CashCountSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$CashCountSummaryDtoFromJson(json);

  CashCountSummary toEntity() => CashCountSummary(
    openingFloat: openingFloat,
    cashSalesUsd: cashSalesUsd,
    cashSalesVes: cashSalesVes,
    electronicSalesUsd: electronicSalesUsd,
    electronicSalesVes: electronicSalesVes,
    expensesUsd: expensesUsd,
    expensesVes: expensesVes,
    expectedCashUsd: expectedCashUsd,
    expectedCashVes: expectedCashVes,
  );
}
