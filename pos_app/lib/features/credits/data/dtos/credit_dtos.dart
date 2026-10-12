import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_app/core/currency/decimal_converter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/credits/domain/entities/credit.dart';
import 'package:pos_app/features/credits/domain/entities/credit_payment.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';

part 'credit_dtos.freezed.dart';
part 'credit_dtos.g.dart';

/// Cliente tal como lo devuelven `customers/` y `customers/<id>/`.
@freezed
abstract class CustomerDto with _$CustomerDto {
  const factory CustomerDto({
    required int id,
    required String name,
    required int creditDays,
    required bool active,
    @DecimalConverter() required Decimal balanceUsd,
    @DecimalConverter() required Decimal overdueUsd,
    required int openCredits,
    @Default('') String taxId,
    @Default('') String phone,

    /// Fecha de calendario `YYYY-MM-DD`; `null` si no debe nada.
    String? nextDueDate,
    @NullableDecimalConverter() Decimal? balanceVes,
    @NullableDecimalConverter() Decimal? paymentRate,
  }) = _CustomerDto;

  const CustomerDto._();

  factory CustomerDto.fromJson(Map<String, dynamic> json) => _$CustomerDtoFromJson(json);

  Customer toEntity() {
    final due = nextDueDate;
    return Customer(
      id: id,
      name: name,
      taxId: taxId,
      phone: phone,
      creditDays: creditDays,
      active: active,
      balanceUsd: balanceUsd,
      overdueUsd: overdueUsd,
      openCredits: openCredits,
      nextDueDate: due == null ? null : DateTime.parse(due),
      balanceVes: balanceVes,
      paymentRate: paymentRate,
    );
  }
}

/// Deuda tal como la devuelve `credits/`.
@freezed
abstract class CreditDto with _$CreditDto {
  const factory CreditDto({
    required int id,
    required int sale,
    required int customer,
    required String customerName,
    required String branch,
    @DecimalConverter() required Decimal amountUsd,
    @DecimalConverter() required Decimal balanceUsd,

    /// Fecha de calendario `YYYY-MM-DD`.
    required String dueDate,
    required bool isOverdue,
    required DateTime createdAt,
    @Default('') String customerPhone,
    DateTime? paidAt,
  }) = _CreditDto;

  const CreditDto._();

  factory CreditDto.fromJson(Map<String, dynamic> json) => _$CreditDtoFromJson(json);

  Credit toEntity() => Credit(
    id: id,
    saleId: sale,
    customerId: customer,
    customerName: customerName,
    customerPhone: customerPhone,
    branchCode: branch,
    amountUsd: amountUsd,
    balanceUsd: balanceUsd,
    dueDate: DateTime.parse(dueDate),
    isOverdue: isOverdue,
    createdAt: createdAt,
    paidAt: paidAt,
  );
}

/// Abono tal como lo devuelven `customers/<id>/payments/`.
@freezed
abstract class CreditPaymentDto with _$CreditPaymentDto {
  const factory CreditPaymentDto({
    required int id,
    required int customer,
    required String method,
    required String currency,
    @DecimalConverter() required Decimal amount,
    @DecimalConverter() required Decimal usdToVesRate,
    @DecimalConverter() required Decimal amountUsd,
    required DateTime createdAt,
    @Default('') String approvalReference,
  }) = _CreditPaymentDto;

  const CreditPaymentDto._();

  factory CreditPaymentDto.fromJson(Map<String, dynamic> json) => _$CreditPaymentDtoFromJson(json);

  CreditPayment toEntity() => CreditPayment(
    id: id,
    customerId: customer,
    method: PaymentMethod.fromApi(method),
    currency: Currency.fromApi(currency),
    amount: amount,
    approvalReference: approvalReference,
    usdToVesRate: usdToVesRate,
    amountUsd: amountUsd,
    createdAt: createdAt,
  );
}
