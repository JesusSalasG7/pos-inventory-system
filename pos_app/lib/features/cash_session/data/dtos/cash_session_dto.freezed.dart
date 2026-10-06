// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_session_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CashSessionDto {

 int get id; int get user; String get branch; DateTime get openedAt;@DecimalConverter() Decimal get openingFloat; DateTime? get closedAt;@NullableDecimalConverter() Decimal? get countedAmountUsd;@NullableDecimalConverter() Decimal? get countedAmountVes;@NullableDecimalConverter() Decimal? get differenceUsd;
/// Create a copy of CashSessionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashSessionDtoCopyWith<CashSessionDto> get copyWith => _$CashSessionDtoCopyWithImpl<CashSessionDto>(this as CashSessionDto, _$identity);

  /// Serializes this CashSessionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashSessionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.user, user) || other.user == user)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.openingFloat, openingFloat) || other.openingFloat == openingFloat)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.countedAmountUsd, countedAmountUsd) || other.countedAmountUsd == countedAmountUsd)&&(identical(other.countedAmountVes, countedAmountVes) || other.countedAmountVes == countedAmountVes)&&(identical(other.differenceUsd, differenceUsd) || other.differenceUsd == differenceUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user,branch,openedAt,openingFloat,closedAt,countedAmountUsd,countedAmountVes,differenceUsd);

@override
String toString() {
  return 'CashSessionDto(id: $id, user: $user, branch: $branch, openedAt: $openedAt, openingFloat: $openingFloat, closedAt: $closedAt, countedAmountUsd: $countedAmountUsd, countedAmountVes: $countedAmountVes, differenceUsd: $differenceUsd)';
}


}

/// @nodoc
abstract mixin class $CashSessionDtoCopyWith<$Res>  {
  factory $CashSessionDtoCopyWith(CashSessionDto value, $Res Function(CashSessionDto) _then) = _$CashSessionDtoCopyWithImpl;
@useResult
$Res call({
 int id, int user, String branch, DateTime openedAt,@DecimalConverter() Decimal openingFloat, DateTime? closedAt,@NullableDecimalConverter() Decimal? countedAmountUsd,@NullableDecimalConverter() Decimal? countedAmountVes,@NullableDecimalConverter() Decimal? differenceUsd
});




}
/// @nodoc
class _$CashSessionDtoCopyWithImpl<$Res>
    implements $CashSessionDtoCopyWith<$Res> {
  _$CashSessionDtoCopyWithImpl(this._self, this._then);

  final CashSessionDto _self;
  final $Res Function(CashSessionDto) _then;

/// Create a copy of CashSessionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? user = null,Object? branch = null,Object? openedAt = null,Object? openingFloat = null,Object? closedAt = freezed,Object? countedAmountUsd = freezed,Object? countedAmountVes = freezed,Object? differenceUsd = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as int,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,openingFloat: null == openingFloat ? _self.openingFloat : openingFloat // ignore: cast_nullable_to_non_nullable
as Decimal,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,countedAmountUsd: freezed == countedAmountUsd ? _self.countedAmountUsd : countedAmountUsd // ignore: cast_nullable_to_non_nullable
as Decimal?,countedAmountVes: freezed == countedAmountVes ? _self.countedAmountVes : countedAmountVes // ignore: cast_nullable_to_non_nullable
as Decimal?,differenceUsd: freezed == differenceUsd ? _self.differenceUsd : differenceUsd // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}

}


/// Adds pattern-matching-related methods to [CashSessionDto].
extension CashSessionDtoPatterns on CashSessionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashSessionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashSessionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashSessionDto value)  $default,){
final _that = this;
switch (_that) {
case _CashSessionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashSessionDto value)?  $default,){
final _that = this;
switch (_that) {
case _CashSessionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int user,  String branch,  DateTime openedAt, @DecimalConverter()  Decimal openingFloat,  DateTime? closedAt, @NullableDecimalConverter()  Decimal? countedAmountUsd, @NullableDecimalConverter()  Decimal? countedAmountVes, @NullableDecimalConverter()  Decimal? differenceUsd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashSessionDto() when $default != null:
return $default(_that.id,_that.user,_that.branch,_that.openedAt,_that.openingFloat,_that.closedAt,_that.countedAmountUsd,_that.countedAmountVes,_that.differenceUsd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int user,  String branch,  DateTime openedAt, @DecimalConverter()  Decimal openingFloat,  DateTime? closedAt, @NullableDecimalConverter()  Decimal? countedAmountUsd, @NullableDecimalConverter()  Decimal? countedAmountVes, @NullableDecimalConverter()  Decimal? differenceUsd)  $default,) {final _that = this;
switch (_that) {
case _CashSessionDto():
return $default(_that.id,_that.user,_that.branch,_that.openedAt,_that.openingFloat,_that.closedAt,_that.countedAmountUsd,_that.countedAmountVes,_that.differenceUsd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int user,  String branch,  DateTime openedAt, @DecimalConverter()  Decimal openingFloat,  DateTime? closedAt, @NullableDecimalConverter()  Decimal? countedAmountUsd, @NullableDecimalConverter()  Decimal? countedAmountVes, @NullableDecimalConverter()  Decimal? differenceUsd)?  $default,) {final _that = this;
switch (_that) {
case _CashSessionDto() when $default != null:
return $default(_that.id,_that.user,_that.branch,_that.openedAt,_that.openingFloat,_that.closedAt,_that.countedAmountUsd,_that.countedAmountVes,_that.differenceUsd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CashSessionDto extends CashSessionDto {
  const _CashSessionDto({required this.id, required this.user, required this.branch, required this.openedAt, @DecimalConverter() required this.openingFloat, this.closedAt, @NullableDecimalConverter() this.countedAmountUsd, @NullableDecimalConverter() this.countedAmountVes, @NullableDecimalConverter() this.differenceUsd}): super._();
  factory _CashSessionDto.fromJson(Map<String, dynamic> json) => _$CashSessionDtoFromJson(json);

@override final  int id;
@override final  int user;
@override final  String branch;
@override final  DateTime openedAt;
@override@DecimalConverter() final  Decimal openingFloat;
@override final  DateTime? closedAt;
@override@NullableDecimalConverter() final  Decimal? countedAmountUsd;
@override@NullableDecimalConverter() final  Decimal? countedAmountVes;
@override@NullableDecimalConverter() final  Decimal? differenceUsd;

/// Create a copy of CashSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashSessionDtoCopyWith<_CashSessionDto> get copyWith => __$CashSessionDtoCopyWithImpl<_CashSessionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashSessionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashSessionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.user, user) || other.user == user)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.openingFloat, openingFloat) || other.openingFloat == openingFloat)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.countedAmountUsd, countedAmountUsd) || other.countedAmountUsd == countedAmountUsd)&&(identical(other.countedAmountVes, countedAmountVes) || other.countedAmountVes == countedAmountVes)&&(identical(other.differenceUsd, differenceUsd) || other.differenceUsd == differenceUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user,branch,openedAt,openingFloat,closedAt,countedAmountUsd,countedAmountVes,differenceUsd);

@override
String toString() {
  return 'CashSessionDto(id: $id, user: $user, branch: $branch, openedAt: $openedAt, openingFloat: $openingFloat, closedAt: $closedAt, countedAmountUsd: $countedAmountUsd, countedAmountVes: $countedAmountVes, differenceUsd: $differenceUsd)';
}


}

/// @nodoc
abstract mixin class _$CashSessionDtoCopyWith<$Res> implements $CashSessionDtoCopyWith<$Res> {
  factory _$CashSessionDtoCopyWith(_CashSessionDto value, $Res Function(_CashSessionDto) _then) = __$CashSessionDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int user, String branch, DateTime openedAt,@DecimalConverter() Decimal openingFloat, DateTime? closedAt,@NullableDecimalConverter() Decimal? countedAmountUsd,@NullableDecimalConverter() Decimal? countedAmountVes,@NullableDecimalConverter() Decimal? differenceUsd
});




}
/// @nodoc
class __$CashSessionDtoCopyWithImpl<$Res>
    implements _$CashSessionDtoCopyWith<$Res> {
  __$CashSessionDtoCopyWithImpl(this._self, this._then);

  final _CashSessionDto _self;
  final $Res Function(_CashSessionDto) _then;

/// Create a copy of CashSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? user = null,Object? branch = null,Object? openedAt = null,Object? openingFloat = null,Object? closedAt = freezed,Object? countedAmountUsd = freezed,Object? countedAmountVes = freezed,Object? differenceUsd = freezed,}) {
  return _then(_CashSessionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as int,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,openingFloat: null == openingFloat ? _self.openingFloat : openingFloat // ignore: cast_nullable_to_non_nullable
as Decimal,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,countedAmountUsd: freezed == countedAmountUsd ? _self.countedAmountUsd : countedAmountUsd // ignore: cast_nullable_to_non_nullable
as Decimal?,countedAmountVes: freezed == countedAmountVes ? _self.countedAmountVes : countedAmountVes // ignore: cast_nullable_to_non_nullable
as Decimal?,differenceUsd: freezed == differenceUsd ? _self.differenceUsd : differenceUsd // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}


}


/// @nodoc
mixin _$CashExpenseDto {

 int get id; int get cashSession; String get reason;@DecimalConverter() Decimal get amount; String get currency; int get createdBy; DateTime get createdAt;
/// Create a copy of CashExpenseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashExpenseDtoCopyWith<CashExpenseDto> get copyWith => _$CashExpenseDtoCopyWithImpl<CashExpenseDto>(this as CashExpenseDto, _$identity);

  /// Serializes this CashExpenseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashExpenseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.cashSession, cashSession) || other.cashSession == cashSession)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cashSession,reason,amount,currency,createdBy,createdAt);

@override
String toString() {
  return 'CashExpenseDto(id: $id, cashSession: $cashSession, reason: $reason, amount: $amount, currency: $currency, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CashExpenseDtoCopyWith<$Res>  {
  factory $CashExpenseDtoCopyWith(CashExpenseDto value, $Res Function(CashExpenseDto) _then) = _$CashExpenseDtoCopyWithImpl;
@useResult
$Res call({
 int id, int cashSession, String reason,@DecimalConverter() Decimal amount, String currency, int createdBy, DateTime createdAt
});




}
/// @nodoc
class _$CashExpenseDtoCopyWithImpl<$Res>
    implements $CashExpenseDtoCopyWith<$Res> {
  _$CashExpenseDtoCopyWithImpl(this._self, this._then);

  final CashExpenseDto _self;
  final $Res Function(CashExpenseDto) _then;

/// Create a copy of CashExpenseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cashSession = null,Object? reason = null,Object? amount = null,Object? currency = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cashSession: null == cashSession ? _self.cashSession : cashSession // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CashExpenseDto].
extension CashExpenseDtoPatterns on CashExpenseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashExpenseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashExpenseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashExpenseDto value)  $default,){
final _that = this;
switch (_that) {
case _CashExpenseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashExpenseDto value)?  $default,){
final _that = this;
switch (_that) {
case _CashExpenseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int cashSession,  String reason, @DecimalConverter()  Decimal amount,  String currency,  int createdBy,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashExpenseDto() when $default != null:
return $default(_that.id,_that.cashSession,_that.reason,_that.amount,_that.currency,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int cashSession,  String reason, @DecimalConverter()  Decimal amount,  String currency,  int createdBy,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CashExpenseDto():
return $default(_that.id,_that.cashSession,_that.reason,_that.amount,_that.currency,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int cashSession,  String reason, @DecimalConverter()  Decimal amount,  String currency,  int createdBy,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CashExpenseDto() when $default != null:
return $default(_that.id,_that.cashSession,_that.reason,_that.amount,_that.currency,_that.createdBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CashExpenseDto extends CashExpenseDto {
  const _CashExpenseDto({required this.id, required this.cashSession, required this.reason, @DecimalConverter() required this.amount, required this.currency, required this.createdBy, required this.createdAt}): super._();
  factory _CashExpenseDto.fromJson(Map<String, dynamic> json) => _$CashExpenseDtoFromJson(json);

@override final  int id;
@override final  int cashSession;
@override final  String reason;
@override@DecimalConverter() final  Decimal amount;
@override final  String currency;
@override final  int createdBy;
@override final  DateTime createdAt;

/// Create a copy of CashExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashExpenseDtoCopyWith<_CashExpenseDto> get copyWith => __$CashExpenseDtoCopyWithImpl<_CashExpenseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashExpenseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashExpenseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.cashSession, cashSession) || other.cashSession == cashSession)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cashSession,reason,amount,currency,createdBy,createdAt);

@override
String toString() {
  return 'CashExpenseDto(id: $id, cashSession: $cashSession, reason: $reason, amount: $amount, currency: $currency, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CashExpenseDtoCopyWith<$Res> implements $CashExpenseDtoCopyWith<$Res> {
  factory _$CashExpenseDtoCopyWith(_CashExpenseDto value, $Res Function(_CashExpenseDto) _then) = __$CashExpenseDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int cashSession, String reason,@DecimalConverter() Decimal amount, String currency, int createdBy, DateTime createdAt
});




}
/// @nodoc
class __$CashExpenseDtoCopyWithImpl<$Res>
    implements _$CashExpenseDtoCopyWith<$Res> {
  __$CashExpenseDtoCopyWithImpl(this._self, this._then);

  final _CashExpenseDto _self;
  final $Res Function(_CashExpenseDto) _then;

/// Create a copy of CashExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cashSession = null,Object? reason = null,Object? amount = null,Object? currency = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_CashExpenseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cashSession: null == cashSession ? _self.cashSession : cashSession // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$CashCountSummaryDto {

@DecimalConverter() Decimal get openingFloat;@DecimalConverter() Decimal get cashSalesUsd;@DecimalConverter() Decimal get cashSalesVes;@DecimalConverter() Decimal get electronicSalesUsd;@DecimalConverter() Decimal get electronicSalesVes;@DecimalConverter() Decimal get expensesUsd;@DecimalConverter() Decimal get expensesVes;@DecimalConverter() Decimal get expectedCashUsd;@DecimalConverter() Decimal get expectedCashVes;
/// Create a copy of CashCountSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashCountSummaryDtoCopyWith<CashCountSummaryDto> get copyWith => _$CashCountSummaryDtoCopyWithImpl<CashCountSummaryDto>(this as CashCountSummaryDto, _$identity);

  /// Serializes this CashCountSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashCountSummaryDto&&(identical(other.openingFloat, openingFloat) || other.openingFloat == openingFloat)&&(identical(other.cashSalesUsd, cashSalesUsd) || other.cashSalesUsd == cashSalesUsd)&&(identical(other.cashSalesVes, cashSalesVes) || other.cashSalesVes == cashSalesVes)&&(identical(other.electronicSalesUsd, electronicSalesUsd) || other.electronicSalesUsd == electronicSalesUsd)&&(identical(other.electronicSalesVes, electronicSalesVes) || other.electronicSalesVes == electronicSalesVes)&&(identical(other.expensesUsd, expensesUsd) || other.expensesUsd == expensesUsd)&&(identical(other.expensesVes, expensesVes) || other.expensesVes == expensesVes)&&(identical(other.expectedCashUsd, expectedCashUsd) || other.expectedCashUsd == expectedCashUsd)&&(identical(other.expectedCashVes, expectedCashVes) || other.expectedCashVes == expectedCashVes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,openingFloat,cashSalesUsd,cashSalesVes,electronicSalesUsd,electronicSalesVes,expensesUsd,expensesVes,expectedCashUsd,expectedCashVes);

@override
String toString() {
  return 'CashCountSummaryDto(openingFloat: $openingFloat, cashSalesUsd: $cashSalesUsd, cashSalesVes: $cashSalesVes, electronicSalesUsd: $electronicSalesUsd, electronicSalesVes: $electronicSalesVes, expensesUsd: $expensesUsd, expensesVes: $expensesVes, expectedCashUsd: $expectedCashUsd, expectedCashVes: $expectedCashVes)';
}


}

/// @nodoc
abstract mixin class $CashCountSummaryDtoCopyWith<$Res>  {
  factory $CashCountSummaryDtoCopyWith(CashCountSummaryDto value, $Res Function(CashCountSummaryDto) _then) = _$CashCountSummaryDtoCopyWithImpl;
@useResult
$Res call({
@DecimalConverter() Decimal openingFloat,@DecimalConverter() Decimal cashSalesUsd,@DecimalConverter() Decimal cashSalesVes,@DecimalConverter() Decimal electronicSalesUsd,@DecimalConverter() Decimal electronicSalesVes,@DecimalConverter() Decimal expensesUsd,@DecimalConverter() Decimal expensesVes,@DecimalConverter() Decimal expectedCashUsd,@DecimalConverter() Decimal expectedCashVes
});




}
/// @nodoc
class _$CashCountSummaryDtoCopyWithImpl<$Res>
    implements $CashCountSummaryDtoCopyWith<$Res> {
  _$CashCountSummaryDtoCopyWithImpl(this._self, this._then);

  final CashCountSummaryDto _self;
  final $Res Function(CashCountSummaryDto) _then;

/// Create a copy of CashCountSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? openingFloat = null,Object? cashSalesUsd = null,Object? cashSalesVes = null,Object? electronicSalesUsd = null,Object? electronicSalesVes = null,Object? expensesUsd = null,Object? expensesVes = null,Object? expectedCashUsd = null,Object? expectedCashVes = null,}) {
  return _then(_self.copyWith(
openingFloat: null == openingFloat ? _self.openingFloat : openingFloat // ignore: cast_nullable_to_non_nullable
as Decimal,cashSalesUsd: null == cashSalesUsd ? _self.cashSalesUsd : cashSalesUsd // ignore: cast_nullable_to_non_nullable
as Decimal,cashSalesVes: null == cashSalesVes ? _self.cashSalesVes : cashSalesVes // ignore: cast_nullable_to_non_nullable
as Decimal,electronicSalesUsd: null == electronicSalesUsd ? _self.electronicSalesUsd : electronicSalesUsd // ignore: cast_nullable_to_non_nullable
as Decimal,electronicSalesVes: null == electronicSalesVes ? _self.electronicSalesVes : electronicSalesVes // ignore: cast_nullable_to_non_nullable
as Decimal,expensesUsd: null == expensesUsd ? _self.expensesUsd : expensesUsd // ignore: cast_nullable_to_non_nullable
as Decimal,expensesVes: null == expensesVes ? _self.expensesVes : expensesVes // ignore: cast_nullable_to_non_nullable
as Decimal,expectedCashUsd: null == expectedCashUsd ? _self.expectedCashUsd : expectedCashUsd // ignore: cast_nullable_to_non_nullable
as Decimal,expectedCashVes: null == expectedCashVes ? _self.expectedCashVes : expectedCashVes // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [CashCountSummaryDto].
extension CashCountSummaryDtoPatterns on CashCountSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashCountSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashCountSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashCountSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _CashCountSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashCountSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _CashCountSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DecimalConverter()  Decimal openingFloat, @DecimalConverter()  Decimal cashSalesUsd, @DecimalConverter()  Decimal cashSalesVes, @DecimalConverter()  Decimal electronicSalesUsd, @DecimalConverter()  Decimal electronicSalesVes, @DecimalConverter()  Decimal expensesUsd, @DecimalConverter()  Decimal expensesVes, @DecimalConverter()  Decimal expectedCashUsd, @DecimalConverter()  Decimal expectedCashVes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashCountSummaryDto() when $default != null:
return $default(_that.openingFloat,_that.cashSalesUsd,_that.cashSalesVes,_that.electronicSalesUsd,_that.electronicSalesVes,_that.expensesUsd,_that.expensesVes,_that.expectedCashUsd,_that.expectedCashVes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DecimalConverter()  Decimal openingFloat, @DecimalConverter()  Decimal cashSalesUsd, @DecimalConverter()  Decimal cashSalesVes, @DecimalConverter()  Decimal electronicSalesUsd, @DecimalConverter()  Decimal electronicSalesVes, @DecimalConverter()  Decimal expensesUsd, @DecimalConverter()  Decimal expensesVes, @DecimalConverter()  Decimal expectedCashUsd, @DecimalConverter()  Decimal expectedCashVes)  $default,) {final _that = this;
switch (_that) {
case _CashCountSummaryDto():
return $default(_that.openingFloat,_that.cashSalesUsd,_that.cashSalesVes,_that.electronicSalesUsd,_that.electronicSalesVes,_that.expensesUsd,_that.expensesVes,_that.expectedCashUsd,_that.expectedCashVes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DecimalConverter()  Decimal openingFloat, @DecimalConverter()  Decimal cashSalesUsd, @DecimalConverter()  Decimal cashSalesVes, @DecimalConverter()  Decimal electronicSalesUsd, @DecimalConverter()  Decimal electronicSalesVes, @DecimalConverter()  Decimal expensesUsd, @DecimalConverter()  Decimal expensesVes, @DecimalConverter()  Decimal expectedCashUsd, @DecimalConverter()  Decimal expectedCashVes)?  $default,) {final _that = this;
switch (_that) {
case _CashCountSummaryDto() when $default != null:
return $default(_that.openingFloat,_that.cashSalesUsd,_that.cashSalesVes,_that.electronicSalesUsd,_that.electronicSalesVes,_that.expensesUsd,_that.expensesVes,_that.expectedCashUsd,_that.expectedCashVes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CashCountSummaryDto extends CashCountSummaryDto {
  const _CashCountSummaryDto({@DecimalConverter() required this.openingFloat, @DecimalConverter() required this.cashSalesUsd, @DecimalConverter() required this.cashSalesVes, @DecimalConverter() required this.electronicSalesUsd, @DecimalConverter() required this.electronicSalesVes, @DecimalConverter() required this.expensesUsd, @DecimalConverter() required this.expensesVes, @DecimalConverter() required this.expectedCashUsd, @DecimalConverter() required this.expectedCashVes}): super._();
  factory _CashCountSummaryDto.fromJson(Map<String, dynamic> json) => _$CashCountSummaryDtoFromJson(json);

@override@DecimalConverter() final  Decimal openingFloat;
@override@DecimalConverter() final  Decimal cashSalesUsd;
@override@DecimalConverter() final  Decimal cashSalesVes;
@override@DecimalConverter() final  Decimal electronicSalesUsd;
@override@DecimalConverter() final  Decimal electronicSalesVes;
@override@DecimalConverter() final  Decimal expensesUsd;
@override@DecimalConverter() final  Decimal expensesVes;
@override@DecimalConverter() final  Decimal expectedCashUsd;
@override@DecimalConverter() final  Decimal expectedCashVes;

/// Create a copy of CashCountSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashCountSummaryDtoCopyWith<_CashCountSummaryDto> get copyWith => __$CashCountSummaryDtoCopyWithImpl<_CashCountSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashCountSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashCountSummaryDto&&(identical(other.openingFloat, openingFloat) || other.openingFloat == openingFloat)&&(identical(other.cashSalesUsd, cashSalesUsd) || other.cashSalesUsd == cashSalesUsd)&&(identical(other.cashSalesVes, cashSalesVes) || other.cashSalesVes == cashSalesVes)&&(identical(other.electronicSalesUsd, electronicSalesUsd) || other.electronicSalesUsd == electronicSalesUsd)&&(identical(other.electronicSalesVes, electronicSalesVes) || other.electronicSalesVes == electronicSalesVes)&&(identical(other.expensesUsd, expensesUsd) || other.expensesUsd == expensesUsd)&&(identical(other.expensesVes, expensesVes) || other.expensesVes == expensesVes)&&(identical(other.expectedCashUsd, expectedCashUsd) || other.expectedCashUsd == expectedCashUsd)&&(identical(other.expectedCashVes, expectedCashVes) || other.expectedCashVes == expectedCashVes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,openingFloat,cashSalesUsd,cashSalesVes,electronicSalesUsd,electronicSalesVes,expensesUsd,expensesVes,expectedCashUsd,expectedCashVes);

@override
String toString() {
  return 'CashCountSummaryDto(openingFloat: $openingFloat, cashSalesUsd: $cashSalesUsd, cashSalesVes: $cashSalesVes, electronicSalesUsd: $electronicSalesUsd, electronicSalesVes: $electronicSalesVes, expensesUsd: $expensesUsd, expensesVes: $expensesVes, expectedCashUsd: $expectedCashUsd, expectedCashVes: $expectedCashVes)';
}


}

/// @nodoc
abstract mixin class _$CashCountSummaryDtoCopyWith<$Res> implements $CashCountSummaryDtoCopyWith<$Res> {
  factory _$CashCountSummaryDtoCopyWith(_CashCountSummaryDto value, $Res Function(_CashCountSummaryDto) _then) = __$CashCountSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
@DecimalConverter() Decimal openingFloat,@DecimalConverter() Decimal cashSalesUsd,@DecimalConverter() Decimal cashSalesVes,@DecimalConverter() Decimal electronicSalesUsd,@DecimalConverter() Decimal electronicSalesVes,@DecimalConverter() Decimal expensesUsd,@DecimalConverter() Decimal expensesVes,@DecimalConverter() Decimal expectedCashUsd,@DecimalConverter() Decimal expectedCashVes
});




}
/// @nodoc
class __$CashCountSummaryDtoCopyWithImpl<$Res>
    implements _$CashCountSummaryDtoCopyWith<$Res> {
  __$CashCountSummaryDtoCopyWithImpl(this._self, this._then);

  final _CashCountSummaryDto _self;
  final $Res Function(_CashCountSummaryDto) _then;

/// Create a copy of CashCountSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? openingFloat = null,Object? cashSalesUsd = null,Object? cashSalesVes = null,Object? electronicSalesUsd = null,Object? electronicSalesVes = null,Object? expensesUsd = null,Object? expensesVes = null,Object? expectedCashUsd = null,Object? expectedCashVes = null,}) {
  return _then(_CashCountSummaryDto(
openingFloat: null == openingFloat ? _self.openingFloat : openingFloat // ignore: cast_nullable_to_non_nullable
as Decimal,cashSalesUsd: null == cashSalesUsd ? _self.cashSalesUsd : cashSalesUsd // ignore: cast_nullable_to_non_nullable
as Decimal,cashSalesVes: null == cashSalesVes ? _self.cashSalesVes : cashSalesVes // ignore: cast_nullable_to_non_nullable
as Decimal,electronicSalesUsd: null == electronicSalesUsd ? _self.electronicSalesUsd : electronicSalesUsd // ignore: cast_nullable_to_non_nullable
as Decimal,electronicSalesVes: null == electronicSalesVes ? _self.electronicSalesVes : electronicSalesVes // ignore: cast_nullable_to_non_nullable
as Decimal,expensesUsd: null == expensesUsd ? _self.expensesUsd : expensesUsd // ignore: cast_nullable_to_non_nullable
as Decimal,expensesVes: null == expensesVes ? _self.expensesVes : expensesVes // ignore: cast_nullable_to_non_nullable
as Decimal,expectedCashUsd: null == expectedCashUsd ? _self.expectedCashUsd : expectedCashUsd // ignore: cast_nullable_to_non_nullable
as Decimal,expectedCashVes: null == expectedCashVes ? _self.expectedCashVes : expectedCashVes // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

// dart format on
