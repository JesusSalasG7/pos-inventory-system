// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SaleDetailDto {

 int get id; int get product;@DecimalConverter() Decimal get quantity;@DecimalConverter() Decimal get unitPriceUsd;@DecimalConverter() Decimal get subtotalUsd;@DecimalConverter() Decimal get subtotalVes;
/// Create a copy of SaleDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleDetailDtoCopyWith<SaleDetailDto> get copyWith => _$SaleDetailDtoCopyWithImpl<SaleDetailDto>(this as SaleDetailDto, _$identity);

  /// Serializes this SaleDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPriceUsd, unitPriceUsd) || other.unitPriceUsd == unitPriceUsd)&&(identical(other.subtotalUsd, subtotalUsd) || other.subtotalUsd == subtotalUsd)&&(identical(other.subtotalVes, subtotalVes) || other.subtotalVes == subtotalVes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,product,quantity,unitPriceUsd,subtotalUsd,subtotalVes);

@override
String toString() {
  return 'SaleDetailDto(id: $id, product: $product, quantity: $quantity, unitPriceUsd: $unitPriceUsd, subtotalUsd: $subtotalUsd, subtotalVes: $subtotalVes)';
}


}

/// @nodoc
abstract mixin class $SaleDetailDtoCopyWith<$Res>  {
  factory $SaleDetailDtoCopyWith(SaleDetailDto value, $Res Function(SaleDetailDto) _then) = _$SaleDetailDtoCopyWithImpl;
@useResult
$Res call({
 int id, int product,@DecimalConverter() Decimal quantity,@DecimalConverter() Decimal unitPriceUsd,@DecimalConverter() Decimal subtotalUsd,@DecimalConverter() Decimal subtotalVes
});




}
/// @nodoc
class _$SaleDetailDtoCopyWithImpl<$Res>
    implements $SaleDetailDtoCopyWith<$Res> {
  _$SaleDetailDtoCopyWithImpl(this._self, this._then);

  final SaleDetailDto _self;
  final $Res Function(SaleDetailDto) _then;

/// Create a copy of SaleDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? product = null,Object? quantity = null,Object? unitPriceUsd = null,Object? subtotalUsd = null,Object? subtotalVes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,unitPriceUsd: null == unitPriceUsd ? _self.unitPriceUsd : unitPriceUsd // ignore: cast_nullable_to_non_nullable
as Decimal,subtotalUsd: null == subtotalUsd ? _self.subtotalUsd : subtotalUsd // ignore: cast_nullable_to_non_nullable
as Decimal,subtotalVes: null == subtotalVes ? _self.subtotalVes : subtotalVes // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleDetailDto].
extension SaleDetailDtoPatterns on SaleDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _SaleDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _SaleDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int product, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal unitPriceUsd, @DecimalConverter()  Decimal subtotalUsd, @DecimalConverter()  Decimal subtotalVes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleDetailDto() when $default != null:
return $default(_that.id,_that.product,_that.quantity,_that.unitPriceUsd,_that.subtotalUsd,_that.subtotalVes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int product, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal unitPriceUsd, @DecimalConverter()  Decimal subtotalUsd, @DecimalConverter()  Decimal subtotalVes)  $default,) {final _that = this;
switch (_that) {
case _SaleDetailDto():
return $default(_that.id,_that.product,_that.quantity,_that.unitPriceUsd,_that.subtotalUsd,_that.subtotalVes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int product, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal unitPriceUsd, @DecimalConverter()  Decimal subtotalUsd, @DecimalConverter()  Decimal subtotalVes)?  $default,) {final _that = this;
switch (_that) {
case _SaleDetailDto() when $default != null:
return $default(_that.id,_that.product,_that.quantity,_that.unitPriceUsd,_that.subtotalUsd,_that.subtotalVes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaleDetailDto extends SaleDetailDto {
  const _SaleDetailDto({required this.id, required this.product, @DecimalConverter() required this.quantity, @DecimalConverter() required this.unitPriceUsd, @DecimalConverter() required this.subtotalUsd, @DecimalConverter() required this.subtotalVes}): super._();
  factory _SaleDetailDto.fromJson(Map<String, dynamic> json) => _$SaleDetailDtoFromJson(json);

@override final  int id;
@override final  int product;
@override@DecimalConverter() final  Decimal quantity;
@override@DecimalConverter() final  Decimal unitPriceUsd;
@override@DecimalConverter() final  Decimal subtotalUsd;
@override@DecimalConverter() final  Decimal subtotalVes;

/// Create a copy of SaleDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleDetailDtoCopyWith<_SaleDetailDto> get copyWith => __$SaleDetailDtoCopyWithImpl<_SaleDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaleDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPriceUsd, unitPriceUsd) || other.unitPriceUsd == unitPriceUsd)&&(identical(other.subtotalUsd, subtotalUsd) || other.subtotalUsd == subtotalUsd)&&(identical(other.subtotalVes, subtotalVes) || other.subtotalVes == subtotalVes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,product,quantity,unitPriceUsd,subtotalUsd,subtotalVes);

@override
String toString() {
  return 'SaleDetailDto(id: $id, product: $product, quantity: $quantity, unitPriceUsd: $unitPriceUsd, subtotalUsd: $subtotalUsd, subtotalVes: $subtotalVes)';
}


}

/// @nodoc
abstract mixin class _$SaleDetailDtoCopyWith<$Res> implements $SaleDetailDtoCopyWith<$Res> {
  factory _$SaleDetailDtoCopyWith(_SaleDetailDto value, $Res Function(_SaleDetailDto) _then) = __$SaleDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int product,@DecimalConverter() Decimal quantity,@DecimalConverter() Decimal unitPriceUsd,@DecimalConverter() Decimal subtotalUsd,@DecimalConverter() Decimal subtotalVes
});




}
/// @nodoc
class __$SaleDetailDtoCopyWithImpl<$Res>
    implements _$SaleDetailDtoCopyWith<$Res> {
  __$SaleDetailDtoCopyWithImpl(this._self, this._then);

  final _SaleDetailDto _self;
  final $Res Function(_SaleDetailDto) _then;

/// Create a copy of SaleDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? product = null,Object? quantity = null,Object? unitPriceUsd = null,Object? subtotalUsd = null,Object? subtotalVes = null,}) {
  return _then(_SaleDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,unitPriceUsd: null == unitPriceUsd ? _self.unitPriceUsd : unitPriceUsd // ignore: cast_nullable_to_non_nullable
as Decimal,subtotalUsd: null == subtotalUsd ? _self.subtotalUsd : subtotalUsd // ignore: cast_nullable_to_non_nullable
as Decimal,subtotalVes: null == subtotalVes ? _self.subtotalVes : subtotalVes // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$SalePaymentDto {

 int get id; String get method; String get currency;@DecimalConverter() Decimal get amount; String get approvalReference;
/// Create a copy of SalePaymentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalePaymentDtoCopyWith<SalePaymentDto> get copyWith => _$SalePaymentDtoCopyWithImpl<SalePaymentDto>(this as SalePaymentDto, _$identity);

  /// Serializes this SalePaymentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalePaymentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.method, method) || other.method == method)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.approvalReference, approvalReference) || other.approvalReference == approvalReference));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,method,currency,amount,approvalReference);

@override
String toString() {
  return 'SalePaymentDto(id: $id, method: $method, currency: $currency, amount: $amount, approvalReference: $approvalReference)';
}


}

/// @nodoc
abstract mixin class $SalePaymentDtoCopyWith<$Res>  {
  factory $SalePaymentDtoCopyWith(SalePaymentDto value, $Res Function(SalePaymentDto) _then) = _$SalePaymentDtoCopyWithImpl;
@useResult
$Res call({
 int id, String method, String currency,@DecimalConverter() Decimal amount, String approvalReference
});




}
/// @nodoc
class _$SalePaymentDtoCopyWithImpl<$Res>
    implements $SalePaymentDtoCopyWith<$Res> {
  _$SalePaymentDtoCopyWithImpl(this._self, this._then);

  final SalePaymentDto _self;
  final $Res Function(SalePaymentDto) _then;

/// Create a copy of SalePaymentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? method = null,Object? currency = null,Object? amount = null,Object? approvalReference = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,approvalReference: null == approvalReference ? _self.approvalReference : approvalReference // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SalePaymentDto].
extension SalePaymentDtoPatterns on SalePaymentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalePaymentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalePaymentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalePaymentDto value)  $default,){
final _that = this;
switch (_that) {
case _SalePaymentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalePaymentDto value)?  $default,){
final _that = this;
switch (_that) {
case _SalePaymentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String method,  String currency, @DecimalConverter()  Decimal amount,  String approvalReference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalePaymentDto() when $default != null:
return $default(_that.id,_that.method,_that.currency,_that.amount,_that.approvalReference);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String method,  String currency, @DecimalConverter()  Decimal amount,  String approvalReference)  $default,) {final _that = this;
switch (_that) {
case _SalePaymentDto():
return $default(_that.id,_that.method,_that.currency,_that.amount,_that.approvalReference);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String method,  String currency, @DecimalConverter()  Decimal amount,  String approvalReference)?  $default,) {final _that = this;
switch (_that) {
case _SalePaymentDto() when $default != null:
return $default(_that.id,_that.method,_that.currency,_that.amount,_that.approvalReference);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalePaymentDto extends SalePaymentDto {
  const _SalePaymentDto({required this.id, required this.method, required this.currency, @DecimalConverter() required this.amount, this.approvalReference = ''}): super._();
  factory _SalePaymentDto.fromJson(Map<String, dynamic> json) => _$SalePaymentDtoFromJson(json);

@override final  int id;
@override final  String method;
@override final  String currency;
@override@DecimalConverter() final  Decimal amount;
@override@JsonKey() final  String approvalReference;

/// Create a copy of SalePaymentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalePaymentDtoCopyWith<_SalePaymentDto> get copyWith => __$SalePaymentDtoCopyWithImpl<_SalePaymentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalePaymentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalePaymentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.method, method) || other.method == method)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.approvalReference, approvalReference) || other.approvalReference == approvalReference));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,method,currency,amount,approvalReference);

@override
String toString() {
  return 'SalePaymentDto(id: $id, method: $method, currency: $currency, amount: $amount, approvalReference: $approvalReference)';
}


}

/// @nodoc
abstract mixin class _$SalePaymentDtoCopyWith<$Res> implements $SalePaymentDtoCopyWith<$Res> {
  factory _$SalePaymentDtoCopyWith(_SalePaymentDto value, $Res Function(_SalePaymentDto) _then) = __$SalePaymentDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String method, String currency,@DecimalConverter() Decimal amount, String approvalReference
});




}
/// @nodoc
class __$SalePaymentDtoCopyWithImpl<$Res>
    implements _$SalePaymentDtoCopyWith<$Res> {
  __$SalePaymentDtoCopyWithImpl(this._self, this._then);

  final _SalePaymentDto _self;
  final $Res Function(_SalePaymentDto) _then;

/// Create a copy of SalePaymentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? method = null,Object? currency = null,Object? amount = null,Object? approvalReference = null,}) {
  return _then(_SalePaymentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,approvalReference: null == approvalReference ? _self.approvalReference : approvalReference // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SaleDto {

 int get id; int get cashSession; int get user; String get branch;@DecimalConverter() Decimal get exchangeRateAtInvoice;@DecimalConverter() Decimal get totalUsd;@DecimalConverter() Decimal get totalVes; DateTime get createdAt; List<SaleDetailDto> get details; List<SalePaymentDto> get payments; String get customerTaxId; String get customerName;
/// Create a copy of SaleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleDtoCopyWith<SaleDto> get copyWith => _$SaleDtoCopyWithImpl<SaleDto>(this as SaleDto, _$identity);

  /// Serializes this SaleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.cashSession, cashSession) || other.cashSession == cashSession)&&(identical(other.user, user) || other.user == user)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.exchangeRateAtInvoice, exchangeRateAtInvoice) || other.exchangeRateAtInvoice == exchangeRateAtInvoice)&&(identical(other.totalUsd, totalUsd) || other.totalUsd == totalUsd)&&(identical(other.totalVes, totalVes) || other.totalVes == totalVes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.details, details)&&const DeepCollectionEquality().equals(other.payments, payments)&&(identical(other.customerTaxId, customerTaxId) || other.customerTaxId == customerTaxId)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cashSession,user,branch,exchangeRateAtInvoice,totalUsd,totalVes,createdAt,const DeepCollectionEquality().hash(details),const DeepCollectionEquality().hash(payments),customerTaxId,customerName);

@override
String toString() {
  return 'SaleDto(id: $id, cashSession: $cashSession, user: $user, branch: $branch, exchangeRateAtInvoice: $exchangeRateAtInvoice, totalUsd: $totalUsd, totalVes: $totalVes, createdAt: $createdAt, details: $details, payments: $payments, customerTaxId: $customerTaxId, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class $SaleDtoCopyWith<$Res>  {
  factory $SaleDtoCopyWith(SaleDto value, $Res Function(SaleDto) _then) = _$SaleDtoCopyWithImpl;
@useResult
$Res call({
 int id, int cashSession, int user, String branch,@DecimalConverter() Decimal exchangeRateAtInvoice,@DecimalConverter() Decimal totalUsd,@DecimalConverter() Decimal totalVes, DateTime createdAt, List<SaleDetailDto> details, List<SalePaymentDto> payments, String customerTaxId, String customerName
});




}
/// @nodoc
class _$SaleDtoCopyWithImpl<$Res>
    implements $SaleDtoCopyWith<$Res> {
  _$SaleDtoCopyWithImpl(this._self, this._then);

  final SaleDto _self;
  final $Res Function(SaleDto) _then;

/// Create a copy of SaleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cashSession = null,Object? user = null,Object? branch = null,Object? exchangeRateAtInvoice = null,Object? totalUsd = null,Object? totalVes = null,Object? createdAt = null,Object? details = null,Object? payments = null,Object? customerTaxId = null,Object? customerName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cashSession: null == cashSession ? _self.cashSession : cashSession // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as int,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,exchangeRateAtInvoice: null == exchangeRateAtInvoice ? _self.exchangeRateAtInvoice : exchangeRateAtInvoice // ignore: cast_nullable_to_non_nullable
as Decimal,totalUsd: null == totalUsd ? _self.totalUsd : totalUsd // ignore: cast_nullable_to_non_nullable
as Decimal,totalVes: null == totalVes ? _self.totalVes : totalVes // ignore: cast_nullable_to_non_nullable
as Decimal,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as List<SaleDetailDto>,payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<SalePaymentDto>,customerTaxId: null == customerTaxId ? _self.customerTaxId : customerTaxId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleDto].
extension SaleDtoPatterns on SaleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleDto value)  $default,){
final _that = this;
switch (_that) {
case _SaleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleDto value)?  $default,){
final _that = this;
switch (_that) {
case _SaleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int cashSession,  int user,  String branch, @DecimalConverter()  Decimal exchangeRateAtInvoice, @DecimalConverter()  Decimal totalUsd, @DecimalConverter()  Decimal totalVes,  DateTime createdAt,  List<SaleDetailDto> details,  List<SalePaymentDto> payments,  String customerTaxId,  String customerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleDto() when $default != null:
return $default(_that.id,_that.cashSession,_that.user,_that.branch,_that.exchangeRateAtInvoice,_that.totalUsd,_that.totalVes,_that.createdAt,_that.details,_that.payments,_that.customerTaxId,_that.customerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int cashSession,  int user,  String branch, @DecimalConverter()  Decimal exchangeRateAtInvoice, @DecimalConverter()  Decimal totalUsd, @DecimalConverter()  Decimal totalVes,  DateTime createdAt,  List<SaleDetailDto> details,  List<SalePaymentDto> payments,  String customerTaxId,  String customerName)  $default,) {final _that = this;
switch (_that) {
case _SaleDto():
return $default(_that.id,_that.cashSession,_that.user,_that.branch,_that.exchangeRateAtInvoice,_that.totalUsd,_that.totalVes,_that.createdAt,_that.details,_that.payments,_that.customerTaxId,_that.customerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int cashSession,  int user,  String branch, @DecimalConverter()  Decimal exchangeRateAtInvoice, @DecimalConverter()  Decimal totalUsd, @DecimalConverter()  Decimal totalVes,  DateTime createdAt,  List<SaleDetailDto> details,  List<SalePaymentDto> payments,  String customerTaxId,  String customerName)?  $default,) {final _that = this;
switch (_that) {
case _SaleDto() when $default != null:
return $default(_that.id,_that.cashSession,_that.user,_that.branch,_that.exchangeRateAtInvoice,_that.totalUsd,_that.totalVes,_that.createdAt,_that.details,_that.payments,_that.customerTaxId,_that.customerName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaleDto extends SaleDto {
  const _SaleDto({required this.id, required this.cashSession, required this.user, required this.branch, @DecimalConverter() required this.exchangeRateAtInvoice, @DecimalConverter() required this.totalUsd, @DecimalConverter() required this.totalVes, required this.createdAt, required final  List<SaleDetailDto> details, required final  List<SalePaymentDto> payments, this.customerTaxId = '', this.customerName = ''}): _details = details,_payments = payments,super._();
  factory _SaleDto.fromJson(Map<String, dynamic> json) => _$SaleDtoFromJson(json);

@override final  int id;
@override final  int cashSession;
@override final  int user;
@override final  String branch;
@override@DecimalConverter() final  Decimal exchangeRateAtInvoice;
@override@DecimalConverter() final  Decimal totalUsd;
@override@DecimalConverter() final  Decimal totalVes;
@override final  DateTime createdAt;
 final  List<SaleDetailDto> _details;
@override List<SaleDetailDto> get details {
  if (_details is EqualUnmodifiableListView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_details);
}

 final  List<SalePaymentDto> _payments;
@override List<SalePaymentDto> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}

@override@JsonKey() final  String customerTaxId;
@override@JsonKey() final  String customerName;

/// Create a copy of SaleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleDtoCopyWith<_SaleDto> get copyWith => __$SaleDtoCopyWithImpl<_SaleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.cashSession, cashSession) || other.cashSession == cashSession)&&(identical(other.user, user) || other.user == user)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.exchangeRateAtInvoice, exchangeRateAtInvoice) || other.exchangeRateAtInvoice == exchangeRateAtInvoice)&&(identical(other.totalUsd, totalUsd) || other.totalUsd == totalUsd)&&(identical(other.totalVes, totalVes) || other.totalVes == totalVes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._details, _details)&&const DeepCollectionEquality().equals(other._payments, _payments)&&(identical(other.customerTaxId, customerTaxId) || other.customerTaxId == customerTaxId)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cashSession,user,branch,exchangeRateAtInvoice,totalUsd,totalVes,createdAt,const DeepCollectionEquality().hash(_details),const DeepCollectionEquality().hash(_payments),customerTaxId,customerName);

@override
String toString() {
  return 'SaleDto(id: $id, cashSession: $cashSession, user: $user, branch: $branch, exchangeRateAtInvoice: $exchangeRateAtInvoice, totalUsd: $totalUsd, totalVes: $totalVes, createdAt: $createdAt, details: $details, payments: $payments, customerTaxId: $customerTaxId, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class _$SaleDtoCopyWith<$Res> implements $SaleDtoCopyWith<$Res> {
  factory _$SaleDtoCopyWith(_SaleDto value, $Res Function(_SaleDto) _then) = __$SaleDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int cashSession, int user, String branch,@DecimalConverter() Decimal exchangeRateAtInvoice,@DecimalConverter() Decimal totalUsd,@DecimalConverter() Decimal totalVes, DateTime createdAt, List<SaleDetailDto> details, List<SalePaymentDto> payments, String customerTaxId, String customerName
});




}
/// @nodoc
class __$SaleDtoCopyWithImpl<$Res>
    implements _$SaleDtoCopyWith<$Res> {
  __$SaleDtoCopyWithImpl(this._self, this._then);

  final _SaleDto _self;
  final $Res Function(_SaleDto) _then;

/// Create a copy of SaleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cashSession = null,Object? user = null,Object? branch = null,Object? exchangeRateAtInvoice = null,Object? totalUsd = null,Object? totalVes = null,Object? createdAt = null,Object? details = null,Object? payments = null,Object? customerTaxId = null,Object? customerName = null,}) {
  return _then(_SaleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cashSession: null == cashSession ? _self.cashSession : cashSession // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as int,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,exchangeRateAtInvoice: null == exchangeRateAtInvoice ? _self.exchangeRateAtInvoice : exchangeRateAtInvoice // ignore: cast_nullable_to_non_nullable
as Decimal,totalUsd: null == totalUsd ? _self.totalUsd : totalUsd // ignore: cast_nullable_to_non_nullable
as Decimal,totalVes: null == totalVes ? _self.totalVes : totalVes // ignore: cast_nullable_to_non_nullable
as Decimal,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,details: null == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as List<SaleDetailDto>,payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<SalePaymentDto>,customerTaxId: null == customerTaxId ? _self.customerTaxId : customerTaxId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
