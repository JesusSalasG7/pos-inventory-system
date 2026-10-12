// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerDto _$CustomerDtoFromJson(Map<String, dynamic> json) => _CustomerDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  creditDays: (json['credit_days'] as num).toInt(),
  active: json['active'] as bool,
  balanceUsd: const DecimalConverter().fromJson(json['balance_usd'] as String),
  overdueUsd: const DecimalConverter().fromJson(json['overdue_usd'] as String),
  openCredits: (json['open_credits'] as num).toInt(),
  taxId: json['tax_id'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  nextDueDate: json['next_due_date'] as String?,
  balanceVes: const NullableDecimalConverter().fromJson(json['balance_ves'] as String?),
  paymentRate: const NullableDecimalConverter().fromJson(json['payment_rate'] as String?),
);

Map<String, dynamic> _$CustomerDtoToJson(_CustomerDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'credit_days': instance.creditDays,
  'active': instance.active,
  'balance_usd': const DecimalConverter().toJson(instance.balanceUsd),
  'overdue_usd': const DecimalConverter().toJson(instance.overdueUsd),
  'open_credits': instance.openCredits,
  'tax_id': instance.taxId,
  'phone': instance.phone,
  'next_due_date': instance.nextDueDate,
  'balance_ves': const NullableDecimalConverter().toJson(instance.balanceVes),
  'payment_rate': const NullableDecimalConverter().toJson(instance.paymentRate),
};

_CreditDto _$CreditDtoFromJson(Map<String, dynamic> json) => _CreditDto(
  id: (json['id'] as num).toInt(),
  sale: (json['sale'] as num).toInt(),
  customer: (json['customer'] as num).toInt(),
  customerName: json['customer_name'] as String,
  branch: json['branch'] as String,
  amountUsd: const DecimalConverter().fromJson(json['amount_usd'] as String),
  balanceUsd: const DecimalConverter().fromJson(json['balance_usd'] as String),
  dueDate: json['due_date'] as String,
  isOverdue: json['is_overdue'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  customerPhone: json['customer_phone'] as String? ?? '',
  paidAt: json['paid_at'] == null ? null : DateTime.parse(json['paid_at'] as String),
);

Map<String, dynamic> _$CreditDtoToJson(_CreditDto instance) => <String, dynamic>{
  'id': instance.id,
  'sale': instance.sale,
  'customer': instance.customer,
  'customer_name': instance.customerName,
  'branch': instance.branch,
  'amount_usd': const DecimalConverter().toJson(instance.amountUsd),
  'balance_usd': const DecimalConverter().toJson(instance.balanceUsd),
  'due_date': instance.dueDate,
  'is_overdue': instance.isOverdue,
  'created_at': instance.createdAt.toIso8601String(),
  'customer_phone': instance.customerPhone,
  'paid_at': instance.paidAt?.toIso8601String(),
};

_CreditPaymentDto _$CreditPaymentDtoFromJson(Map<String, dynamic> json) => _CreditPaymentDto(
  id: (json['id'] as num).toInt(),
  customer: (json['customer'] as num).toInt(),
  method: json['method'] as String,
  currency: json['currency'] as String,
  amount: const DecimalConverter().fromJson(json['amount'] as String),
  usdToVesRate: const DecimalConverter().fromJson(json['usd_to_ves_rate'] as String),
  amountUsd: const DecimalConverter().fromJson(json['amount_usd'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  approvalReference: json['approval_reference'] as String? ?? '',
);

Map<String, dynamic> _$CreditPaymentDtoToJson(_CreditPaymentDto instance) => <String, dynamic>{
  'id': instance.id,
  'customer': instance.customer,
  'method': instance.method,
  'currency': instance.currency,
  'amount': const DecimalConverter().toJson(instance.amount),
  'usd_to_ves_rate': const DecimalConverter().toJson(instance.usdToVesRate),
  'amount_usd': const DecimalConverter().toJson(instance.amountUsd),
  'created_at': instance.createdAt.toIso8601String(),
  'approval_reference': instance.approvalReference,
};
