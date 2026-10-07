// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CashSessionDto _$CashSessionDtoFromJson(Map<String, dynamic> json) => _CashSessionDto(
  id: (json['id'] as num).toInt(),
  user: (json['user'] as num).toInt(),
  branch: json['branch'] as String,
  openedAt: DateTime.parse(json['opened_at'] as String),
  openingFloat: const DecimalConverter().fromJson(json['opening_float'] as String),
  closedAt: json['closed_at'] == null ? null : DateTime.parse(json['closed_at'] as String),
  countedAmountUsd: const NullableDecimalConverter().fromJson(
    json['counted_amount_usd'] as String?,
  ),
  countedAmountVes: const NullableDecimalConverter().fromJson(
    json['counted_amount_ves'] as String?,
  ),
  differenceUsd: const NullableDecimalConverter().fromJson(json['difference_usd'] as String?),
);

Map<String, dynamic> _$CashSessionDtoToJson(_CashSessionDto instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'branch': instance.branch,
  'opened_at': instance.openedAt.toIso8601String(),
  'opening_float': const DecimalConverter().toJson(instance.openingFloat),
  'closed_at': instance.closedAt?.toIso8601String(),
  'counted_amount_usd': const NullableDecimalConverter().toJson(instance.countedAmountUsd),
  'counted_amount_ves': const NullableDecimalConverter().toJson(instance.countedAmountVes),
  'difference_usd': const NullableDecimalConverter().toJson(instance.differenceUsd),
};

_CashExpenseDto _$CashExpenseDtoFromJson(Map<String, dynamic> json) => _CashExpenseDto(
  id: (json['id'] as num).toInt(),
  cashSession: (json['cash_session'] as num).toInt(),
  reason: json['reason'] as String,
  amount: const DecimalConverter().fromJson(json['amount'] as String),
  currency: json['currency'] as String,
  createdBy: (json['created_by'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CashExpenseDtoToJson(_CashExpenseDto instance) => <String, dynamic>{
  'id': instance.id,
  'cash_session': instance.cashSession,
  'reason': instance.reason,
  'amount': const DecimalConverter().toJson(instance.amount),
  'currency': instance.currency,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
};

_CashCountSummaryDto _$CashCountSummaryDtoFromJson(Map<String, dynamic> json) =>
    _CashCountSummaryDto(
      openingFloat: const DecimalConverter().fromJson(json['opening_float'] as String),
      cashSalesUsd: const DecimalConverter().fromJson(json['cash_sales_usd'] as String),
      cashSalesVes: const DecimalConverter().fromJson(json['cash_sales_ves'] as String),
      electronicSalesUsd: const DecimalConverter().fromJson(json['electronic_sales_usd'] as String),
      electronicSalesVes: const DecimalConverter().fromJson(json['electronic_sales_ves'] as String),
      expensesUsd: const DecimalConverter().fromJson(json['expenses_usd'] as String),
      expensesVes: const DecimalConverter().fromJson(json['expenses_ves'] as String),
      expectedCashUsd: const DecimalConverter().fromJson(json['expected_cash_usd'] as String),
      expectedCashVes: const DecimalConverter().fromJson(json['expected_cash_ves'] as String),
    );

Map<String, dynamic> _$CashCountSummaryDtoToJson(_CashCountSummaryDto instance) =>
    <String, dynamic>{
      'opening_float': const DecimalConverter().toJson(instance.openingFloat),
      'cash_sales_usd': const DecimalConverter().toJson(instance.cashSalesUsd),
      'cash_sales_ves': const DecimalConverter().toJson(instance.cashSalesVes),
      'electronic_sales_usd': const DecimalConverter().toJson(instance.electronicSalesUsd),
      'electronic_sales_ves': const DecimalConverter().toJson(instance.electronicSalesVes),
      'expenses_usd': const DecimalConverter().toJson(instance.expensesUsd),
      'expenses_ves': const DecimalConverter().toJson(instance.expensesVes),
      'expected_cash_usd': const DecimalConverter().toJson(instance.expectedCashUsd),
      'expected_cash_ves': const DecimalConverter().toJson(instance.expectedCashVes),
    };

_PaymentTotalDto _$PaymentTotalDtoFromJson(Map<String, dynamic> json) => _PaymentTotalDto(
  method: json['method'] as String,
  currency: json['currency'] as String,
  amount: const DecimalConverter().fromJson(json['amount'] as String),
);

Map<String, dynamic> _$PaymentTotalDtoToJson(_PaymentTotalDto instance) => <String, dynamic>{
  'method': instance.method,
  'currency': instance.currency,
  'amount': const DecimalConverter().toJson(instance.amount),
};

_ProductSalesDto _$ProductSalesDtoFromJson(Map<String, dynamic> json) => _ProductSalesDto(
  product: (json['product'] as num).toInt(),
  productName: json['product_name'] as String,
  quantity: const DecimalConverter().fromJson(json['quantity'] as String),
  salesUsd: const DecimalConverter().fromJson(json['sales_usd'] as String),
  salesVes: const DecimalConverter().fromJson(json['sales_ves'] as String),
  costUsd: const DecimalConverter().fromJson(json['cost_usd'] as String),
  costVes: const DecimalConverter().fromJson(json['cost_ves'] as String),
  profitUsd: const DecimalConverter().fromJson(json['profit_usd'] as String),
  profitVes: const DecimalConverter().fromJson(json['profit_ves'] as String),
);

Map<String, dynamic> _$ProductSalesDtoToJson(_ProductSalesDto instance) => <String, dynamic>{
  'product': instance.product,
  'product_name': instance.productName,
  'quantity': const DecimalConverter().toJson(instance.quantity),
  'sales_usd': const DecimalConverter().toJson(instance.salesUsd),
  'sales_ves': const DecimalConverter().toJson(instance.salesVes),
  'cost_usd': const DecimalConverter().toJson(instance.costUsd),
  'cost_ves': const DecimalConverter().toJson(instance.costVes),
  'profit_usd': const DecimalConverter().toJson(instance.profitUsd),
  'profit_ves': const DecimalConverter().toJson(instance.profitVes),
};

_SessionSalesReportDto _$SessionSalesReportDtoFromJson(Map<String, dynamic> json) =>
    _SessionSalesReportDto(
      salesCount: (json['sales_count'] as num).toInt(),
      totalUsd: const DecimalConverter().fromJson(json['total_usd'] as String),
      totalVes: const DecimalConverter().fromJson(json['total_ves'] as String),
      costUsd: const DecimalConverter().fromJson(json['cost_usd'] as String),
      costVes: const DecimalConverter().fromJson(json['cost_ves'] as String),
      profitUsd: const DecimalConverter().fromJson(json['profit_usd'] as String),
      profitVes: const DecimalConverter().fromJson(json['profit_ves'] as String),
      payments: (json['payments'] as List<dynamic>)
          .map((e) => PaymentTotalDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      products: (json['products'] as List<dynamic>)
          .map((e) => ProductSalesDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SessionSalesReportDtoToJson(_SessionSalesReportDto instance) =>
    <String, dynamic>{
      'sales_count': instance.salesCount,
      'total_usd': const DecimalConverter().toJson(instance.totalUsd),
      'total_ves': const DecimalConverter().toJson(instance.totalVes),
      'cost_usd': const DecimalConverter().toJson(instance.costUsd),
      'cost_ves': const DecimalConverter().toJson(instance.costVes),
      'profit_usd': const DecimalConverter().toJson(instance.profitUsd),
      'profit_ves': const DecimalConverter().toJson(instance.profitVes),
      'payments': instance.payments.map((e) => e.toJson()).toList(),
      'products': instance.products.map((e) => e.toJson()).toList(),
    };
