// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerDto {

 int get id; String get name; int get creditDays; bool get active;@DecimalConverter() Decimal get balanceUsd;@DecimalConverter() Decimal get overdueUsd; int get openCredits; String get taxId; String get phone;/// Fecha de calendario `YYYY-MM-DD`; `null` si no debe nada.
 String? get nextDueDate;@NullableDecimalConverter() Decimal? get balanceVes;@NullableDecimalConverter() Decimal? get paymentRate;
/// Create a copy of CustomerDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerDtoCopyWith<CustomerDto> get copyWith => _$CustomerDtoCopyWithImpl<CustomerDto>(this as CustomerDto, _$identity);

  /// Serializes this CustomerDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.creditDays, creditDays) || other.creditDays == creditDays)&&(identical(other.active, active) || other.active == active)&&(identical(other.balanceUsd, balanceUsd) || other.balanceUsd == balanceUsd)&&(identical(other.overdueUsd, overdueUsd) || other.overdueUsd == overdueUsd)&&(identical(other.openCredits, openCredits) || other.openCredits == openCredits)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.nextDueDate, nextDueDate) || other.nextDueDate == nextDueDate)&&(identical(other.balanceVes, balanceVes) || other.balanceVes == balanceVes)&&(identical(other.paymentRate, paymentRate) || other.paymentRate == paymentRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,creditDays,active,balanceUsd,overdueUsd,openCredits,taxId,phone,nextDueDate,balanceVes,paymentRate);

@override
String toString() {
  return 'CustomerDto(id: $id, name: $name, creditDays: $creditDays, active: $active, balanceUsd: $balanceUsd, overdueUsd: $overdueUsd, openCredits: $openCredits, taxId: $taxId, phone: $phone, nextDueDate: $nextDueDate, balanceVes: $balanceVes, paymentRate: $paymentRate)';
}


}

/// @nodoc
abstract mixin class $CustomerDtoCopyWith<$Res>  {
  factory $CustomerDtoCopyWith(CustomerDto value, $Res Function(CustomerDto) _then) = _$CustomerDtoCopyWithImpl;
@useResult
$Res call({
 int id, String name, int creditDays, bool active,@DecimalConverter() Decimal balanceUsd,@DecimalConverter() Decimal overdueUsd, int openCredits, String taxId, String phone, String? nextDueDate,@NullableDecimalConverter() Decimal? balanceVes,@NullableDecimalConverter() Decimal? paymentRate
});




}
/// @nodoc
class _$CustomerDtoCopyWithImpl<$Res>
    implements $CustomerDtoCopyWith<$Res> {
  _$CustomerDtoCopyWithImpl(this._self, this._then);

  final CustomerDto _self;
  final $Res Function(CustomerDto) _then;

/// Create a copy of CustomerDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? creditDays = null,Object? active = null,Object? balanceUsd = null,Object? overdueUsd = null,Object? openCredits = null,Object? taxId = null,Object? phone = null,Object? nextDueDate = freezed,Object? balanceVes = freezed,Object? paymentRate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,balanceUsd: null == balanceUsd ? _self.balanceUsd : balanceUsd // ignore: cast_nullable_to_non_nullable
as Decimal,overdueUsd: null == overdueUsd ? _self.overdueUsd : overdueUsd // ignore: cast_nullable_to_non_nullable
as Decimal,openCredits: null == openCredits ? _self.openCredits : openCredits // ignore: cast_nullable_to_non_nullable
as int,taxId: null == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,nextDueDate: freezed == nextDueDate ? _self.nextDueDate : nextDueDate // ignore: cast_nullable_to_non_nullable
as String?,balanceVes: freezed == balanceVes ? _self.balanceVes : balanceVes // ignore: cast_nullable_to_non_nullable
as Decimal?,paymentRate: freezed == paymentRate ? _self.paymentRate : paymentRate // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerDto].
extension CustomerDtoPatterns on CustomerDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerDto value)  $default,){
final _that = this;
switch (_that) {
case _CustomerDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerDto value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int creditDays,  bool active, @DecimalConverter()  Decimal balanceUsd, @DecimalConverter()  Decimal overdueUsd,  int openCredits,  String taxId,  String phone,  String? nextDueDate, @NullableDecimalConverter()  Decimal? balanceVes, @NullableDecimalConverter()  Decimal? paymentRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerDto() when $default != null:
return $default(_that.id,_that.name,_that.creditDays,_that.active,_that.balanceUsd,_that.overdueUsd,_that.openCredits,_that.taxId,_that.phone,_that.nextDueDate,_that.balanceVes,_that.paymentRate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int creditDays,  bool active, @DecimalConverter()  Decimal balanceUsd, @DecimalConverter()  Decimal overdueUsd,  int openCredits,  String taxId,  String phone,  String? nextDueDate, @NullableDecimalConverter()  Decimal? balanceVes, @NullableDecimalConverter()  Decimal? paymentRate)  $default,) {final _that = this;
switch (_that) {
case _CustomerDto():
return $default(_that.id,_that.name,_that.creditDays,_that.active,_that.balanceUsd,_that.overdueUsd,_that.openCredits,_that.taxId,_that.phone,_that.nextDueDate,_that.balanceVes,_that.paymentRate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int creditDays,  bool active, @DecimalConverter()  Decimal balanceUsd, @DecimalConverter()  Decimal overdueUsd,  int openCredits,  String taxId,  String phone,  String? nextDueDate, @NullableDecimalConverter()  Decimal? balanceVes, @NullableDecimalConverter()  Decimal? paymentRate)?  $default,) {final _that = this;
switch (_that) {
case _CustomerDto() when $default != null:
return $default(_that.id,_that.name,_that.creditDays,_that.active,_that.balanceUsd,_that.overdueUsd,_that.openCredits,_that.taxId,_that.phone,_that.nextDueDate,_that.balanceVes,_that.paymentRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerDto extends CustomerDto {
  const _CustomerDto({required this.id, required this.name, required this.creditDays, required this.active, @DecimalConverter() required this.balanceUsd, @DecimalConverter() required this.overdueUsd, required this.openCredits, this.taxId = '', this.phone = '', this.nextDueDate, @NullableDecimalConverter() this.balanceVes, @NullableDecimalConverter() this.paymentRate}): super._();
  factory _CustomerDto.fromJson(Map<String, dynamic> json) => _$CustomerDtoFromJson(json);

@override final  int id;
@override final  String name;
@override final  int creditDays;
@override final  bool active;
@override@DecimalConverter() final  Decimal balanceUsd;
@override@DecimalConverter() final  Decimal overdueUsd;
@override final  int openCredits;
@override@JsonKey() final  String taxId;
@override@JsonKey() final  String phone;
/// Fecha de calendario `YYYY-MM-DD`; `null` si no debe nada.
@override final  String? nextDueDate;
@override@NullableDecimalConverter() final  Decimal? balanceVes;
@override@NullableDecimalConverter() final  Decimal? paymentRate;

/// Create a copy of CustomerDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerDtoCopyWith<_CustomerDto> get copyWith => __$CustomerDtoCopyWithImpl<_CustomerDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.creditDays, creditDays) || other.creditDays == creditDays)&&(identical(other.active, active) || other.active == active)&&(identical(other.balanceUsd, balanceUsd) || other.balanceUsd == balanceUsd)&&(identical(other.overdueUsd, overdueUsd) || other.overdueUsd == overdueUsd)&&(identical(other.openCredits, openCredits) || other.openCredits == openCredits)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.nextDueDate, nextDueDate) || other.nextDueDate == nextDueDate)&&(identical(other.balanceVes, balanceVes) || other.balanceVes == balanceVes)&&(identical(other.paymentRate, paymentRate) || other.paymentRate == paymentRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,creditDays,active,balanceUsd,overdueUsd,openCredits,taxId,phone,nextDueDate,balanceVes,paymentRate);

@override
String toString() {
  return 'CustomerDto(id: $id, name: $name, creditDays: $creditDays, active: $active, balanceUsd: $balanceUsd, overdueUsd: $overdueUsd, openCredits: $openCredits, taxId: $taxId, phone: $phone, nextDueDate: $nextDueDate, balanceVes: $balanceVes, paymentRate: $paymentRate)';
}


}

/// @nodoc
abstract mixin class _$CustomerDtoCopyWith<$Res> implements $CustomerDtoCopyWith<$Res> {
  factory _$CustomerDtoCopyWith(_CustomerDto value, $Res Function(_CustomerDto) _then) = __$CustomerDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int creditDays, bool active,@DecimalConverter() Decimal balanceUsd,@DecimalConverter() Decimal overdueUsd, int openCredits, String taxId, String phone, String? nextDueDate,@NullableDecimalConverter() Decimal? balanceVes,@NullableDecimalConverter() Decimal? paymentRate
});




}
/// @nodoc
class __$CustomerDtoCopyWithImpl<$Res>
    implements _$CustomerDtoCopyWith<$Res> {
  __$CustomerDtoCopyWithImpl(this._self, this._then);

  final _CustomerDto _self;
  final $Res Function(_CustomerDto) _then;

/// Create a copy of CustomerDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? creditDays = null,Object? active = null,Object? balanceUsd = null,Object? overdueUsd = null,Object? openCredits = null,Object? taxId = null,Object? phone = null,Object? nextDueDate = freezed,Object? balanceVes = freezed,Object? paymentRate = freezed,}) {
  return _then(_CustomerDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,balanceUsd: null == balanceUsd ? _self.balanceUsd : balanceUsd // ignore: cast_nullable_to_non_nullable
as Decimal,overdueUsd: null == overdueUsd ? _self.overdueUsd : overdueUsd // ignore: cast_nullable_to_non_nullable
as Decimal,openCredits: null == openCredits ? _self.openCredits : openCredits // ignore: cast_nullable_to_non_nullable
as int,taxId: null == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,nextDueDate: freezed == nextDueDate ? _self.nextDueDate : nextDueDate // ignore: cast_nullable_to_non_nullable
as String?,balanceVes: freezed == balanceVes ? _self.balanceVes : balanceVes // ignore: cast_nullable_to_non_nullable
as Decimal?,paymentRate: freezed == paymentRate ? _self.paymentRate : paymentRate // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}


}


/// @nodoc
mixin _$CreditDto {

 int get id; int get sale; int get customer; String get customerName; String get branch;@DecimalConverter() Decimal get amountUsd;@DecimalConverter() Decimal get balanceUsd;/// Fecha de calendario `YYYY-MM-DD`.
 String get dueDate; bool get isOverdue; DateTime get createdAt; String get customerPhone; DateTime? get paidAt;
/// Create a copy of CreditDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditDtoCopyWith<CreditDto> get copyWith => _$CreditDtoCopyWithImpl<CreditDto>(this as CreditDto, _$identity);

  /// Serializes this CreditDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sale, sale) || other.sale == sale)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.amountUsd, amountUsd) || other.amountUsd == amountUsd)&&(identical(other.balanceUsd, balanceUsd) || other.balanceUsd == balanceUsd)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sale,customer,customerName,branch,amountUsd,balanceUsd,dueDate,isOverdue,createdAt,customerPhone,paidAt);

@override
String toString() {
  return 'CreditDto(id: $id, sale: $sale, customer: $customer, customerName: $customerName, branch: $branch, amountUsd: $amountUsd, balanceUsd: $balanceUsd, dueDate: $dueDate, isOverdue: $isOverdue, createdAt: $createdAt, customerPhone: $customerPhone, paidAt: $paidAt)';
}


}

/// @nodoc
abstract mixin class $CreditDtoCopyWith<$Res>  {
  factory $CreditDtoCopyWith(CreditDto value, $Res Function(CreditDto) _then) = _$CreditDtoCopyWithImpl;
@useResult
$Res call({
 int id, int sale, int customer, String customerName, String branch,@DecimalConverter() Decimal amountUsd,@DecimalConverter() Decimal balanceUsd, String dueDate, bool isOverdue, DateTime createdAt, String customerPhone, DateTime? paidAt
});




}
/// @nodoc
class _$CreditDtoCopyWithImpl<$Res>
    implements $CreditDtoCopyWith<$Res> {
  _$CreditDtoCopyWithImpl(this._self, this._then);

  final CreditDto _self;
  final $Res Function(CreditDto) _then;

/// Create a copy of CreditDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sale = null,Object? customer = null,Object? customerName = null,Object? branch = null,Object? amountUsd = null,Object? balanceUsd = null,Object? dueDate = null,Object? isOverdue = null,Object? createdAt = null,Object? customerPhone = null,Object? paidAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sale: null == sale ? _self.sale : sale // ignore: cast_nullable_to_non_nullable
as int,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,amountUsd: null == amountUsd ? _self.amountUsd : amountUsd // ignore: cast_nullable_to_non_nullable
as Decimal,balanceUsd: null == balanceUsd ? _self.balanceUsd : balanceUsd // ignore: cast_nullable_to_non_nullable
as Decimal,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditDto].
extension CreditDtoPatterns on CreditDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditDto value)  $default,){
final _that = this;
switch (_that) {
case _CreditDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreditDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int sale,  int customer,  String customerName,  String branch, @DecimalConverter()  Decimal amountUsd, @DecimalConverter()  Decimal balanceUsd,  String dueDate,  bool isOverdue,  DateTime createdAt,  String customerPhone,  DateTime? paidAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditDto() when $default != null:
return $default(_that.id,_that.sale,_that.customer,_that.customerName,_that.branch,_that.amountUsd,_that.balanceUsd,_that.dueDate,_that.isOverdue,_that.createdAt,_that.customerPhone,_that.paidAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int sale,  int customer,  String customerName,  String branch, @DecimalConverter()  Decimal amountUsd, @DecimalConverter()  Decimal balanceUsd,  String dueDate,  bool isOverdue,  DateTime createdAt,  String customerPhone,  DateTime? paidAt)  $default,) {final _that = this;
switch (_that) {
case _CreditDto():
return $default(_that.id,_that.sale,_that.customer,_that.customerName,_that.branch,_that.amountUsd,_that.balanceUsd,_that.dueDate,_that.isOverdue,_that.createdAt,_that.customerPhone,_that.paidAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int sale,  int customer,  String customerName,  String branch, @DecimalConverter()  Decimal amountUsd, @DecimalConverter()  Decimal balanceUsd,  String dueDate,  bool isOverdue,  DateTime createdAt,  String customerPhone,  DateTime? paidAt)?  $default,) {final _that = this;
switch (_that) {
case _CreditDto() when $default != null:
return $default(_that.id,_that.sale,_that.customer,_that.customerName,_that.branch,_that.amountUsd,_that.balanceUsd,_that.dueDate,_that.isOverdue,_that.createdAt,_that.customerPhone,_that.paidAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditDto extends CreditDto {
  const _CreditDto({required this.id, required this.sale, required this.customer, required this.customerName, required this.branch, @DecimalConverter() required this.amountUsd, @DecimalConverter() required this.balanceUsd, required this.dueDate, required this.isOverdue, required this.createdAt, this.customerPhone = '', this.paidAt}): super._();
  factory _CreditDto.fromJson(Map<String, dynamic> json) => _$CreditDtoFromJson(json);

@override final  int id;
@override final  int sale;
@override final  int customer;
@override final  String customerName;
@override final  String branch;
@override@DecimalConverter() final  Decimal amountUsd;
@override@DecimalConverter() final  Decimal balanceUsd;
/// Fecha de calendario `YYYY-MM-DD`.
@override final  String dueDate;
@override final  bool isOverdue;
@override final  DateTime createdAt;
@override@JsonKey() final  String customerPhone;
@override final  DateTime? paidAt;

/// Create a copy of CreditDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditDtoCopyWith<_CreditDto> get copyWith => __$CreditDtoCopyWithImpl<_CreditDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sale, sale) || other.sale == sale)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.amountUsd, amountUsd) || other.amountUsd == amountUsd)&&(identical(other.balanceUsd, balanceUsd) || other.balanceUsd == balanceUsd)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sale,customer,customerName,branch,amountUsd,balanceUsd,dueDate,isOverdue,createdAt,customerPhone,paidAt);

@override
String toString() {
  return 'CreditDto(id: $id, sale: $sale, customer: $customer, customerName: $customerName, branch: $branch, amountUsd: $amountUsd, balanceUsd: $balanceUsd, dueDate: $dueDate, isOverdue: $isOverdue, createdAt: $createdAt, customerPhone: $customerPhone, paidAt: $paidAt)';
}


}

/// @nodoc
abstract mixin class _$CreditDtoCopyWith<$Res> implements $CreditDtoCopyWith<$Res> {
  factory _$CreditDtoCopyWith(_CreditDto value, $Res Function(_CreditDto) _then) = __$CreditDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int sale, int customer, String customerName, String branch,@DecimalConverter() Decimal amountUsd,@DecimalConverter() Decimal balanceUsd, String dueDate, bool isOverdue, DateTime createdAt, String customerPhone, DateTime? paidAt
});




}
/// @nodoc
class __$CreditDtoCopyWithImpl<$Res>
    implements _$CreditDtoCopyWith<$Res> {
  __$CreditDtoCopyWithImpl(this._self, this._then);

  final _CreditDto _self;
  final $Res Function(_CreditDto) _then;

/// Create a copy of CreditDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sale = null,Object? customer = null,Object? customerName = null,Object? branch = null,Object? amountUsd = null,Object? balanceUsd = null,Object? dueDate = null,Object? isOverdue = null,Object? createdAt = null,Object? customerPhone = null,Object? paidAt = freezed,}) {
  return _then(_CreditDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sale: null == sale ? _self.sale : sale // ignore: cast_nullable_to_non_nullable
as int,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,amountUsd: null == amountUsd ? _self.amountUsd : amountUsd // ignore: cast_nullable_to_non_nullable
as Decimal,balanceUsd: null == balanceUsd ? _self.balanceUsd : balanceUsd // ignore: cast_nullable_to_non_nullable
as Decimal,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CreditPaymentDto {

 int get id; int get customer; String get method; String get currency;@DecimalConverter() Decimal get amount;@DecimalConverter() Decimal get usdToVesRate;@DecimalConverter() Decimal get amountUsd; DateTime get createdAt; String get approvalReference;
/// Create a copy of CreditPaymentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditPaymentDtoCopyWith<CreditPaymentDto> get copyWith => _$CreditPaymentDtoCopyWithImpl<CreditPaymentDto>(this as CreditPaymentDto, _$identity);

  /// Serializes this CreditPaymentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditPaymentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.method, method) || other.method == method)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.usdToVesRate, usdToVesRate) || other.usdToVesRate == usdToVesRate)&&(identical(other.amountUsd, amountUsd) || other.amountUsd == amountUsd)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.approvalReference, approvalReference) || other.approvalReference == approvalReference));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customer,method,currency,amount,usdToVesRate,amountUsd,createdAt,approvalReference);

@override
String toString() {
  return 'CreditPaymentDto(id: $id, customer: $customer, method: $method, currency: $currency, amount: $amount, usdToVesRate: $usdToVesRate, amountUsd: $amountUsd, createdAt: $createdAt, approvalReference: $approvalReference)';
}


}

/// @nodoc
abstract mixin class $CreditPaymentDtoCopyWith<$Res>  {
  factory $CreditPaymentDtoCopyWith(CreditPaymentDto value, $Res Function(CreditPaymentDto) _then) = _$CreditPaymentDtoCopyWithImpl;
@useResult
$Res call({
 int id, int customer, String method, String currency,@DecimalConverter() Decimal amount,@DecimalConverter() Decimal usdToVesRate,@DecimalConverter() Decimal amountUsd, DateTime createdAt, String approvalReference
});




}
/// @nodoc
class _$CreditPaymentDtoCopyWithImpl<$Res>
    implements $CreditPaymentDtoCopyWith<$Res> {
  _$CreditPaymentDtoCopyWithImpl(this._self, this._then);

  final CreditPaymentDto _self;
  final $Res Function(CreditPaymentDto) _then;

/// Create a copy of CreditPaymentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customer = null,Object? method = null,Object? currency = null,Object? amount = null,Object? usdToVesRate = null,Object? amountUsd = null,Object? createdAt = null,Object? approvalReference = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,usdToVesRate: null == usdToVesRate ? _self.usdToVesRate : usdToVesRate // ignore: cast_nullable_to_non_nullable
as Decimal,amountUsd: null == amountUsd ? _self.amountUsd : amountUsd // ignore: cast_nullable_to_non_nullable
as Decimal,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,approvalReference: null == approvalReference ? _self.approvalReference : approvalReference // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditPaymentDto].
extension CreditPaymentDtoPatterns on CreditPaymentDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditPaymentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditPaymentDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditPaymentDto value)  $default,){
final _that = this;
switch (_that) {
case _CreditPaymentDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditPaymentDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreditPaymentDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int customer,  String method,  String currency, @DecimalConverter()  Decimal amount, @DecimalConverter()  Decimal usdToVesRate, @DecimalConverter()  Decimal amountUsd,  DateTime createdAt,  String approvalReference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditPaymentDto() when $default != null:
return $default(_that.id,_that.customer,_that.method,_that.currency,_that.amount,_that.usdToVesRate,_that.amountUsd,_that.createdAt,_that.approvalReference);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int customer,  String method,  String currency, @DecimalConverter()  Decimal amount, @DecimalConverter()  Decimal usdToVesRate, @DecimalConverter()  Decimal amountUsd,  DateTime createdAt,  String approvalReference)  $default,) {final _that = this;
switch (_that) {
case _CreditPaymentDto():
return $default(_that.id,_that.customer,_that.method,_that.currency,_that.amount,_that.usdToVesRate,_that.amountUsd,_that.createdAt,_that.approvalReference);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int customer,  String method,  String currency, @DecimalConverter()  Decimal amount, @DecimalConverter()  Decimal usdToVesRate, @DecimalConverter()  Decimal amountUsd,  DateTime createdAt,  String approvalReference)?  $default,) {final _that = this;
switch (_that) {
case _CreditPaymentDto() when $default != null:
return $default(_that.id,_that.customer,_that.method,_that.currency,_that.amount,_that.usdToVesRate,_that.amountUsd,_that.createdAt,_that.approvalReference);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditPaymentDto extends CreditPaymentDto {
  const _CreditPaymentDto({required this.id, required this.customer, required this.method, required this.currency, @DecimalConverter() required this.amount, @DecimalConverter() required this.usdToVesRate, @DecimalConverter() required this.amountUsd, required this.createdAt, this.approvalReference = ''}): super._();
  factory _CreditPaymentDto.fromJson(Map<String, dynamic> json) => _$CreditPaymentDtoFromJson(json);

@override final  int id;
@override final  int customer;
@override final  String method;
@override final  String currency;
@override@DecimalConverter() final  Decimal amount;
@override@DecimalConverter() final  Decimal usdToVesRate;
@override@DecimalConverter() final  Decimal amountUsd;
@override final  DateTime createdAt;
@override@JsonKey() final  String approvalReference;

/// Create a copy of CreditPaymentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditPaymentDtoCopyWith<_CreditPaymentDto> get copyWith => __$CreditPaymentDtoCopyWithImpl<_CreditPaymentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditPaymentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditPaymentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.method, method) || other.method == method)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.usdToVesRate, usdToVesRate) || other.usdToVesRate == usdToVesRate)&&(identical(other.amountUsd, amountUsd) || other.amountUsd == amountUsd)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.approvalReference, approvalReference) || other.approvalReference == approvalReference));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customer,method,currency,amount,usdToVesRate,amountUsd,createdAt,approvalReference);

@override
String toString() {
  return 'CreditPaymentDto(id: $id, customer: $customer, method: $method, currency: $currency, amount: $amount, usdToVesRate: $usdToVesRate, amountUsd: $amountUsd, createdAt: $createdAt, approvalReference: $approvalReference)';
}


}

/// @nodoc
abstract mixin class _$CreditPaymentDtoCopyWith<$Res> implements $CreditPaymentDtoCopyWith<$Res> {
  factory _$CreditPaymentDtoCopyWith(_CreditPaymentDto value, $Res Function(_CreditPaymentDto) _then) = __$CreditPaymentDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int customer, String method, String currency,@DecimalConverter() Decimal amount,@DecimalConverter() Decimal usdToVesRate,@DecimalConverter() Decimal amountUsd, DateTime createdAt, String approvalReference
});




}
/// @nodoc
class __$CreditPaymentDtoCopyWithImpl<$Res>
    implements _$CreditPaymentDtoCopyWith<$Res> {
  __$CreditPaymentDtoCopyWithImpl(this._self, this._then);

  final _CreditPaymentDto _self;
  final $Res Function(_CreditPaymentDto) _then;

/// Create a copy of CreditPaymentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customer = null,Object? method = null,Object? currency = null,Object? amount = null,Object? usdToVesRate = null,Object? amountUsd = null,Object? createdAt = null,Object? approvalReference = null,}) {
  return _then(_CreditPaymentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,usdToVesRate: null == usdToVesRate ? _self.usdToVesRate : usdToVesRate // ignore: cast_nullable_to_non_nullable
as Decimal,amountUsd: null == amountUsd ? _self.amountUsd : amountUsd // ignore: cast_nullable_to_non_nullable
as Decimal,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,approvalReference: null == approvalReference ? _self.approvalReference : approvalReference // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
