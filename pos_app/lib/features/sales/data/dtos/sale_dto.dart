import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_app/core/currency/decimal_converter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';

part 'sale_dto.freezed.dart';
part 'sale_dto.g.dart';

@freezed
abstract class SaleDetailDto with _$SaleDetailDto {
  const factory SaleDetailDto({
    required int id,
    required int product,
    @DecimalConverter() required Decimal quantity,
    @DecimalConverter() required Decimal unitPriceUsd,
    @DecimalConverter() required Decimal subtotalUsd,
    @DecimalConverter() required Decimal subtotalVes,
  }) = _SaleDetailDto;

  const SaleDetailDto._();

  factory SaleDetailDto.fromJson(Map<String, dynamic> json) => _$SaleDetailDtoFromJson(json);

  SaleDetail toEntity() => SaleDetail(
    id: id,
    productId: product,
    quantity: quantity,
    unitPriceUsd: unitPriceUsd,
    subtotalUsd: subtotalUsd,
    subtotalVes: subtotalVes,
  );
}

@freezed
abstract class SalePaymentDto with _$SalePaymentDto {
  const factory SalePaymentDto({
    required int id,
    required String method,
    required String currency,
    @DecimalConverter() required Decimal amount,
    @Default('') String approvalReference,
  }) = _SalePaymentDto;

  const SalePaymentDto._();

  factory SalePaymentDto.fromJson(Map<String, dynamic> json) => _$SalePaymentDtoFromJson(json);

  SalePayment toEntity() => SalePayment(
    id: id,
    method: PaymentMethod.fromApi(method),
    currency: Currency.fromApi(currency),
    amount: amount,
    approvalReference: approvalReference,
  );
}

/// Venta tal como la devuelven `POST sales/`, `sales/` y `sales/<id>/`.
@freezed
abstract class SaleDto with _$SaleDto {
  const factory SaleDto({
    required int id,
    required int cashSession,
    required int user,
    required String branch,
    @DecimalConverter() required Decimal exchangeRateAtInvoice,
    @DecimalConverter() required Decimal totalUsd,
    @DecimalConverter() required Decimal totalVes,
    required DateTime createdAt,
    required List<SaleDetailDto> details,
    required List<SalePaymentDto> payments,
    @Default('') String customerTaxId,
    @Default('') String customerName,
  }) = _SaleDto;

  const SaleDto._();

  factory SaleDto.fromJson(Map<String, dynamic> json) => _$SaleDtoFromJson(json);

  Sale toEntity() => Sale(
    id: id,
    cashSessionId: cashSession,
    userId: user,
    branchCode: branch,
    customerTaxId: customerTaxId,
    customerName: customerName,
    exchangeRateAtInvoice: exchangeRateAtInvoice,
    totalUsd: totalUsd,
    totalVes: totalVes,
    createdAt: createdAt,
    details: [for (final detail in details) detail.toEntity()],
    payments: [for (final payment in payments) payment.toEntity()],
  );
}
