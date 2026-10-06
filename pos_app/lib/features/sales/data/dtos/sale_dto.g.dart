// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SaleDetailDto _$SaleDetailDtoFromJson(Map<String, dynamic> json) => _SaleDetailDto(
  id: (json['id'] as num).toInt(),
  product: (json['product'] as num).toInt(),
  quantity: const DecimalConverter().fromJson(json['quantity'] as String),
  unitPriceUsd: const DecimalConverter().fromJson(json['unit_price_usd'] as String),
  subtotalUsd: const DecimalConverter().fromJson(json['subtotal_usd'] as String),
);

Map<String, dynamic> _$SaleDetailDtoToJson(_SaleDetailDto instance) => <String, dynamic>{
  'id': instance.id,
  'product': instance.product,
  'quantity': const DecimalConverter().toJson(instance.quantity),
  'unit_price_usd': const DecimalConverter().toJson(instance.unitPriceUsd),
  'subtotal_usd': const DecimalConverter().toJson(instance.subtotalUsd),
};

_SalePaymentDto _$SalePaymentDtoFromJson(Map<String, dynamic> json) => _SalePaymentDto(
  id: (json['id'] as num).toInt(),
  method: json['method'] as String,
  currency: json['currency'] as String,
  amount: const DecimalConverter().fromJson(json['amount'] as String),
  approvalReference: json['approval_reference'] as String? ?? '',
);

Map<String, dynamic> _$SalePaymentDtoToJson(_SalePaymentDto instance) => <String, dynamic>{
  'id': instance.id,
  'method': instance.method,
  'currency': instance.currency,
  'amount': const DecimalConverter().toJson(instance.amount),
  'approval_reference': instance.approvalReference,
};

_SaleDto _$SaleDtoFromJson(Map<String, dynamic> json) => _SaleDto(
  id: (json['id'] as num).toInt(),
  cashSession: (json['cash_session'] as num).toInt(),
  user: (json['user'] as num).toInt(),
  branch: json['branch'] as String,
  exchangeRateAtInvoice: const DecimalConverter().fromJson(
    json['exchange_rate_at_invoice'] as String,
  ),
  totalUsd: const DecimalConverter().fromJson(json['total_usd'] as String),
  totalVes: const DecimalConverter().fromJson(json['total_ves'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  details: (json['details'] as List<dynamic>)
      .map((e) => SaleDetailDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  payments: (json['payments'] as List<dynamic>)
      .map((e) => SalePaymentDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  customerTaxId: json['customer_tax_id'] as String? ?? '',
  customerName: json['customer_name'] as String? ?? '',
);

Map<String, dynamic> _$SaleDtoToJson(_SaleDto instance) => <String, dynamic>{
  'id': instance.id,
  'cash_session': instance.cashSession,
  'user': instance.user,
  'branch': instance.branch,
  'exchange_rate_at_invoice': const DecimalConverter().toJson(instance.exchangeRateAtInvoice),
  'total_usd': const DecimalConverter().toJson(instance.totalUsd),
  'total_ves': const DecimalConverter().toJson(instance.totalVes),
  'created_at': instance.createdAt.toIso8601String(),
  'details': instance.details.map((e) => e.toJson()).toList(),
  'payments': instance.payments.map((e) => e.toJson()).toList(),
  'customer_tax_id': instance.customerTaxId,
  'customer_name': instance.customerName,
};
