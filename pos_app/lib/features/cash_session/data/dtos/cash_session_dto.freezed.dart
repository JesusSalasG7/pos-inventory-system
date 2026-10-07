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


/// @nodoc
mixin _$PaymentTotalDto {

 String get method; String get currency;@DecimalConverter() Decimal get amount;
/// Create a copy of PaymentTotalDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentTotalDtoCopyWith<PaymentTotalDto> get copyWith => _$PaymentTotalDtoCopyWithImpl<PaymentTotalDto>(this as PaymentTotalDto, _$identity);

  /// Serializes this PaymentTotalDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentTotalDto&&(identical(other.method, method) || other.method == method)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,currency,amount);

@override
String toString() {
  return 'PaymentTotalDto(method: $method, currency: $currency, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $PaymentTotalDtoCopyWith<$Res>  {
  factory $PaymentTotalDtoCopyWith(PaymentTotalDto value, $Res Function(PaymentTotalDto) _then) = _$PaymentTotalDtoCopyWithImpl;
@useResult
$Res call({
 String method, String currency,@DecimalConverter() Decimal amount
});




}
/// @nodoc
class _$PaymentTotalDtoCopyWithImpl<$Res>
    implements $PaymentTotalDtoCopyWith<$Res> {
  _$PaymentTotalDtoCopyWithImpl(this._self, this._then);

  final PaymentTotalDto _self;
  final $Res Function(PaymentTotalDto) _then;

/// Create a copy of PaymentTotalDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? currency = null,Object? amount = null,}) {
  return _then(_self.copyWith(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentTotalDto].
extension PaymentTotalDtoPatterns on PaymentTotalDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentTotalDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentTotalDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentTotalDto value)  $default,){
final _that = this;
switch (_that) {
case _PaymentTotalDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentTotalDto value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentTotalDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String method,  String currency, @DecimalConverter()  Decimal amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentTotalDto() when $default != null:
return $default(_that.method,_that.currency,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String method,  String currency, @DecimalConverter()  Decimal amount)  $default,) {final _that = this;
switch (_that) {
case _PaymentTotalDto():
return $default(_that.method,_that.currency,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String method,  String currency, @DecimalConverter()  Decimal amount)?  $default,) {final _that = this;
switch (_that) {
case _PaymentTotalDto() when $default != null:
return $default(_that.method,_that.currency,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentTotalDto extends PaymentTotalDto {
  const _PaymentTotalDto({required this.method, required this.currency, @DecimalConverter() required this.amount}): super._();
  factory _PaymentTotalDto.fromJson(Map<String, dynamic> json) => _$PaymentTotalDtoFromJson(json);

@override final  String method;
@override final  String currency;
@override@DecimalConverter() final  Decimal amount;

/// Create a copy of PaymentTotalDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentTotalDtoCopyWith<_PaymentTotalDto> get copyWith => __$PaymentTotalDtoCopyWithImpl<_PaymentTotalDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentTotalDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentTotalDto&&(identical(other.method, method) || other.method == method)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,currency,amount);

@override
String toString() {
  return 'PaymentTotalDto(method: $method, currency: $currency, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$PaymentTotalDtoCopyWith<$Res> implements $PaymentTotalDtoCopyWith<$Res> {
  factory _$PaymentTotalDtoCopyWith(_PaymentTotalDto value, $Res Function(_PaymentTotalDto) _then) = __$PaymentTotalDtoCopyWithImpl;
@override @useResult
$Res call({
 String method, String currency,@DecimalConverter() Decimal amount
});




}
/// @nodoc
class __$PaymentTotalDtoCopyWithImpl<$Res>
    implements _$PaymentTotalDtoCopyWith<$Res> {
  __$PaymentTotalDtoCopyWithImpl(this._self, this._then);

  final _PaymentTotalDto _self;
  final $Res Function(_PaymentTotalDto) _then;

/// Create a copy of PaymentTotalDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? currency = null,Object? amount = null,}) {
  return _then(_PaymentTotalDto(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$ProductSalesDto {

 int get product; String get productName;@DecimalConverter() Decimal get quantity;@DecimalConverter() Decimal get salesUsd;@DecimalConverter() Decimal get salesVes;@DecimalConverter() Decimal get costUsd;@DecimalConverter() Decimal get costVes;@DecimalConverter() Decimal get profitUsd;@DecimalConverter() Decimal get profitVes;
/// Create a copy of ProductSalesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductSalesDtoCopyWith<ProductSalesDto> get copyWith => _$ProductSalesDtoCopyWithImpl<ProductSalesDto>(this as ProductSalesDto, _$identity);

  /// Serializes this ProductSalesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductSalesDto&&(identical(other.product, product) || other.product == product)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.salesUsd, salesUsd) || other.salesUsd == salesUsd)&&(identical(other.salesVes, salesVes) || other.salesVes == salesVes)&&(identical(other.costUsd, costUsd) || other.costUsd == costUsd)&&(identical(other.costVes, costVes) || other.costVes == costVes)&&(identical(other.profitUsd, profitUsd) || other.profitUsd == profitUsd)&&(identical(other.profitVes, profitVes) || other.profitVes == profitVes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,product,productName,quantity,salesUsd,salesVes,costUsd,costVes,profitUsd,profitVes);

@override
String toString() {
  return 'ProductSalesDto(product: $product, productName: $productName, quantity: $quantity, salesUsd: $salesUsd, salesVes: $salesVes, costUsd: $costUsd, costVes: $costVes, profitUsd: $profitUsd, profitVes: $profitVes)';
}


}

/// @nodoc
abstract mixin class $ProductSalesDtoCopyWith<$Res>  {
  factory $ProductSalesDtoCopyWith(ProductSalesDto value, $Res Function(ProductSalesDto) _then) = _$ProductSalesDtoCopyWithImpl;
@useResult
$Res call({
 int product, String productName,@DecimalConverter() Decimal quantity,@DecimalConverter() Decimal salesUsd,@DecimalConverter() Decimal salesVes,@DecimalConverter() Decimal costUsd,@DecimalConverter() Decimal costVes,@DecimalConverter() Decimal profitUsd,@DecimalConverter() Decimal profitVes
});




}
/// @nodoc
class _$ProductSalesDtoCopyWithImpl<$Res>
    implements $ProductSalesDtoCopyWith<$Res> {
  _$ProductSalesDtoCopyWithImpl(this._self, this._then);

  final ProductSalesDto _self;
  final $Res Function(ProductSalesDto) _then;

/// Create a copy of ProductSalesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = null,Object? productName = null,Object? quantity = null,Object? salesUsd = null,Object? salesVes = null,Object? costUsd = null,Object? costVes = null,Object? profitUsd = null,Object? profitVes = null,}) {
  return _then(_self.copyWith(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,salesUsd: null == salesUsd ? _self.salesUsd : salesUsd // ignore: cast_nullable_to_non_nullable
as Decimal,salesVes: null == salesVes ? _self.salesVes : salesVes // ignore: cast_nullable_to_non_nullable
as Decimal,costUsd: null == costUsd ? _self.costUsd : costUsd // ignore: cast_nullable_to_non_nullable
as Decimal,costVes: null == costVes ? _self.costVes : costVes // ignore: cast_nullable_to_non_nullable
as Decimal,profitUsd: null == profitUsd ? _self.profitUsd : profitUsd // ignore: cast_nullable_to_non_nullable
as Decimal,profitVes: null == profitVes ? _self.profitVes : profitVes // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductSalesDto].
extension ProductSalesDtoPatterns on ProductSalesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductSalesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductSalesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductSalesDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductSalesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductSalesDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductSalesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int product,  String productName, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal salesUsd, @DecimalConverter()  Decimal salesVes, @DecimalConverter()  Decimal costUsd, @DecimalConverter()  Decimal costVes, @DecimalConverter()  Decimal profitUsd, @DecimalConverter()  Decimal profitVes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductSalesDto() when $default != null:
return $default(_that.product,_that.productName,_that.quantity,_that.salesUsd,_that.salesVes,_that.costUsd,_that.costVes,_that.profitUsd,_that.profitVes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int product,  String productName, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal salesUsd, @DecimalConverter()  Decimal salesVes, @DecimalConverter()  Decimal costUsd, @DecimalConverter()  Decimal costVes, @DecimalConverter()  Decimal profitUsd, @DecimalConverter()  Decimal profitVes)  $default,) {final _that = this;
switch (_that) {
case _ProductSalesDto():
return $default(_that.product,_that.productName,_that.quantity,_that.salesUsd,_that.salesVes,_that.costUsd,_that.costVes,_that.profitUsd,_that.profitVes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int product,  String productName, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal salesUsd, @DecimalConverter()  Decimal salesVes, @DecimalConverter()  Decimal costUsd, @DecimalConverter()  Decimal costVes, @DecimalConverter()  Decimal profitUsd, @DecimalConverter()  Decimal profitVes)?  $default,) {final _that = this;
switch (_that) {
case _ProductSalesDto() when $default != null:
return $default(_that.product,_that.productName,_that.quantity,_that.salesUsd,_that.salesVes,_that.costUsd,_that.costVes,_that.profitUsd,_that.profitVes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductSalesDto extends ProductSalesDto {
  const _ProductSalesDto({required this.product, required this.productName, @DecimalConverter() required this.quantity, @DecimalConverter() required this.salesUsd, @DecimalConverter() required this.salesVes, @DecimalConverter() required this.costUsd, @DecimalConverter() required this.costVes, @DecimalConverter() required this.profitUsd, @DecimalConverter() required this.profitVes}): super._();
  factory _ProductSalesDto.fromJson(Map<String, dynamic> json) => _$ProductSalesDtoFromJson(json);

@override final  int product;
@override final  String productName;
@override@DecimalConverter() final  Decimal quantity;
@override@DecimalConverter() final  Decimal salesUsd;
@override@DecimalConverter() final  Decimal salesVes;
@override@DecimalConverter() final  Decimal costUsd;
@override@DecimalConverter() final  Decimal costVes;
@override@DecimalConverter() final  Decimal profitUsd;
@override@DecimalConverter() final  Decimal profitVes;

/// Create a copy of ProductSalesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductSalesDtoCopyWith<_ProductSalesDto> get copyWith => __$ProductSalesDtoCopyWithImpl<_ProductSalesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductSalesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductSalesDto&&(identical(other.product, product) || other.product == product)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.salesUsd, salesUsd) || other.salesUsd == salesUsd)&&(identical(other.salesVes, salesVes) || other.salesVes == salesVes)&&(identical(other.costUsd, costUsd) || other.costUsd == costUsd)&&(identical(other.costVes, costVes) || other.costVes == costVes)&&(identical(other.profitUsd, profitUsd) || other.profitUsd == profitUsd)&&(identical(other.profitVes, profitVes) || other.profitVes == profitVes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,product,productName,quantity,salesUsd,salesVes,costUsd,costVes,profitUsd,profitVes);

@override
String toString() {
  return 'ProductSalesDto(product: $product, productName: $productName, quantity: $quantity, salesUsd: $salesUsd, salesVes: $salesVes, costUsd: $costUsd, costVes: $costVes, profitUsd: $profitUsd, profitVes: $profitVes)';
}


}

/// @nodoc
abstract mixin class _$ProductSalesDtoCopyWith<$Res> implements $ProductSalesDtoCopyWith<$Res> {
  factory _$ProductSalesDtoCopyWith(_ProductSalesDto value, $Res Function(_ProductSalesDto) _then) = __$ProductSalesDtoCopyWithImpl;
@override @useResult
$Res call({
 int product, String productName,@DecimalConverter() Decimal quantity,@DecimalConverter() Decimal salesUsd,@DecimalConverter() Decimal salesVes,@DecimalConverter() Decimal costUsd,@DecimalConverter() Decimal costVes,@DecimalConverter() Decimal profitUsd,@DecimalConverter() Decimal profitVes
});




}
/// @nodoc
class __$ProductSalesDtoCopyWithImpl<$Res>
    implements _$ProductSalesDtoCopyWith<$Res> {
  __$ProductSalesDtoCopyWithImpl(this._self, this._then);

  final _ProductSalesDto _self;
  final $Res Function(_ProductSalesDto) _then;

/// Create a copy of ProductSalesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = null,Object? productName = null,Object? quantity = null,Object? salesUsd = null,Object? salesVes = null,Object? costUsd = null,Object? costVes = null,Object? profitUsd = null,Object? profitVes = null,}) {
  return _then(_ProductSalesDto(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,salesUsd: null == salesUsd ? _self.salesUsd : salesUsd // ignore: cast_nullable_to_non_nullable
as Decimal,salesVes: null == salesVes ? _self.salesVes : salesVes // ignore: cast_nullable_to_non_nullable
as Decimal,costUsd: null == costUsd ? _self.costUsd : costUsd // ignore: cast_nullable_to_non_nullable
as Decimal,costVes: null == costVes ? _self.costVes : costVes // ignore: cast_nullable_to_non_nullable
as Decimal,profitUsd: null == profitUsd ? _self.profitUsd : profitUsd // ignore: cast_nullable_to_non_nullable
as Decimal,profitVes: null == profitVes ? _self.profitVes : profitVes // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$SessionSalesReportDto {

 int get salesCount;@DecimalConverter() Decimal get totalUsd;@DecimalConverter() Decimal get totalVes;@DecimalConverter() Decimal get costUsd;@DecimalConverter() Decimal get costVes;@DecimalConverter() Decimal get profitUsd;@DecimalConverter() Decimal get profitVes; List<PaymentTotalDto> get payments; List<ProductSalesDto> get products;
/// Create a copy of SessionSalesReportDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionSalesReportDtoCopyWith<SessionSalesReportDto> get copyWith => _$SessionSalesReportDtoCopyWithImpl<SessionSalesReportDto>(this as SessionSalesReportDto, _$identity);

  /// Serializes this SessionSalesReportDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionSalesReportDto&&(identical(other.salesCount, salesCount) || other.salesCount == salesCount)&&(identical(other.totalUsd, totalUsd) || other.totalUsd == totalUsd)&&(identical(other.totalVes, totalVes) || other.totalVes == totalVes)&&(identical(other.costUsd, costUsd) || other.costUsd == costUsd)&&(identical(other.costVes, costVes) || other.costVes == costVes)&&(identical(other.profitUsd, profitUsd) || other.profitUsd == profitUsd)&&(identical(other.profitVes, profitVes) || other.profitVes == profitVes)&&const DeepCollectionEquality().equals(other.payments, payments)&&const DeepCollectionEquality().equals(other.products, products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salesCount,totalUsd,totalVes,costUsd,costVes,profitUsd,profitVes,const DeepCollectionEquality().hash(payments),const DeepCollectionEquality().hash(products));

@override
String toString() {
  return 'SessionSalesReportDto(salesCount: $salesCount, totalUsd: $totalUsd, totalVes: $totalVes, costUsd: $costUsd, costVes: $costVes, profitUsd: $profitUsd, profitVes: $profitVes, payments: $payments, products: $products)';
}


}

/// @nodoc
abstract mixin class $SessionSalesReportDtoCopyWith<$Res>  {
  factory $SessionSalesReportDtoCopyWith(SessionSalesReportDto value, $Res Function(SessionSalesReportDto) _then) = _$SessionSalesReportDtoCopyWithImpl;
@useResult
$Res call({
 int salesCount,@DecimalConverter() Decimal totalUsd,@DecimalConverter() Decimal totalVes,@DecimalConverter() Decimal costUsd,@DecimalConverter() Decimal costVes,@DecimalConverter() Decimal profitUsd,@DecimalConverter() Decimal profitVes, List<PaymentTotalDto> payments, List<ProductSalesDto> products
});




}
/// @nodoc
class _$SessionSalesReportDtoCopyWithImpl<$Res>
    implements $SessionSalesReportDtoCopyWith<$Res> {
  _$SessionSalesReportDtoCopyWithImpl(this._self, this._then);

  final SessionSalesReportDto _self;
  final $Res Function(SessionSalesReportDto) _then;

/// Create a copy of SessionSalesReportDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? salesCount = null,Object? totalUsd = null,Object? totalVes = null,Object? costUsd = null,Object? costVes = null,Object? profitUsd = null,Object? profitVes = null,Object? payments = null,Object? products = null,}) {
  return _then(_self.copyWith(
salesCount: null == salesCount ? _self.salesCount : salesCount // ignore: cast_nullable_to_non_nullable
as int,totalUsd: null == totalUsd ? _self.totalUsd : totalUsd // ignore: cast_nullable_to_non_nullable
as Decimal,totalVes: null == totalVes ? _self.totalVes : totalVes // ignore: cast_nullable_to_non_nullable
as Decimal,costUsd: null == costUsd ? _self.costUsd : costUsd // ignore: cast_nullable_to_non_nullable
as Decimal,costVes: null == costVes ? _self.costVes : costVes // ignore: cast_nullable_to_non_nullable
as Decimal,profitUsd: null == profitUsd ? _self.profitUsd : profitUsd // ignore: cast_nullable_to_non_nullable
as Decimal,profitVes: null == profitVes ? _self.profitVes : profitVes // ignore: cast_nullable_to_non_nullable
as Decimal,payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<PaymentTotalDto>,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<ProductSalesDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionSalesReportDto].
extension SessionSalesReportDtoPatterns on SessionSalesReportDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionSalesReportDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionSalesReportDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionSalesReportDto value)  $default,){
final _that = this;
switch (_that) {
case _SessionSalesReportDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionSalesReportDto value)?  $default,){
final _that = this;
switch (_that) {
case _SessionSalesReportDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int salesCount, @DecimalConverter()  Decimal totalUsd, @DecimalConverter()  Decimal totalVes, @DecimalConverter()  Decimal costUsd, @DecimalConverter()  Decimal costVes, @DecimalConverter()  Decimal profitUsd, @DecimalConverter()  Decimal profitVes,  List<PaymentTotalDto> payments,  List<ProductSalesDto> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionSalesReportDto() when $default != null:
return $default(_that.salesCount,_that.totalUsd,_that.totalVes,_that.costUsd,_that.costVes,_that.profitUsd,_that.profitVes,_that.payments,_that.products);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int salesCount, @DecimalConverter()  Decimal totalUsd, @DecimalConverter()  Decimal totalVes, @DecimalConverter()  Decimal costUsd, @DecimalConverter()  Decimal costVes, @DecimalConverter()  Decimal profitUsd, @DecimalConverter()  Decimal profitVes,  List<PaymentTotalDto> payments,  List<ProductSalesDto> products)  $default,) {final _that = this;
switch (_that) {
case _SessionSalesReportDto():
return $default(_that.salesCount,_that.totalUsd,_that.totalVes,_that.costUsd,_that.costVes,_that.profitUsd,_that.profitVes,_that.payments,_that.products);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int salesCount, @DecimalConverter()  Decimal totalUsd, @DecimalConverter()  Decimal totalVes, @DecimalConverter()  Decimal costUsd, @DecimalConverter()  Decimal costVes, @DecimalConverter()  Decimal profitUsd, @DecimalConverter()  Decimal profitVes,  List<PaymentTotalDto> payments,  List<ProductSalesDto> products)?  $default,) {final _that = this;
switch (_that) {
case _SessionSalesReportDto() when $default != null:
return $default(_that.salesCount,_that.totalUsd,_that.totalVes,_that.costUsd,_that.costVes,_that.profitUsd,_that.profitVes,_that.payments,_that.products);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionSalesReportDto extends SessionSalesReportDto {
  const _SessionSalesReportDto({required this.salesCount, @DecimalConverter() required this.totalUsd, @DecimalConverter() required this.totalVes, @DecimalConverter() required this.costUsd, @DecimalConverter() required this.costVes, @DecimalConverter() required this.profitUsd, @DecimalConverter() required this.profitVes, required final  List<PaymentTotalDto> payments, required final  List<ProductSalesDto> products}): _payments = payments,_products = products,super._();
  factory _SessionSalesReportDto.fromJson(Map<String, dynamic> json) => _$SessionSalesReportDtoFromJson(json);

@override final  int salesCount;
@override@DecimalConverter() final  Decimal totalUsd;
@override@DecimalConverter() final  Decimal totalVes;
@override@DecimalConverter() final  Decimal costUsd;
@override@DecimalConverter() final  Decimal costVes;
@override@DecimalConverter() final  Decimal profitUsd;
@override@DecimalConverter() final  Decimal profitVes;
 final  List<PaymentTotalDto> _payments;
@override List<PaymentTotalDto> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}

 final  List<ProductSalesDto> _products;
@override List<ProductSalesDto> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of SessionSalesReportDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionSalesReportDtoCopyWith<_SessionSalesReportDto> get copyWith => __$SessionSalesReportDtoCopyWithImpl<_SessionSalesReportDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionSalesReportDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionSalesReportDto&&(identical(other.salesCount, salesCount) || other.salesCount == salesCount)&&(identical(other.totalUsd, totalUsd) || other.totalUsd == totalUsd)&&(identical(other.totalVes, totalVes) || other.totalVes == totalVes)&&(identical(other.costUsd, costUsd) || other.costUsd == costUsd)&&(identical(other.costVes, costVes) || other.costVes == costVes)&&(identical(other.profitUsd, profitUsd) || other.profitUsd == profitUsd)&&(identical(other.profitVes, profitVes) || other.profitVes == profitVes)&&const DeepCollectionEquality().equals(other._payments, _payments)&&const DeepCollectionEquality().equals(other._products, _products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salesCount,totalUsd,totalVes,costUsd,costVes,profitUsd,profitVes,const DeepCollectionEquality().hash(_payments),const DeepCollectionEquality().hash(_products));

@override
String toString() {
  return 'SessionSalesReportDto(salesCount: $salesCount, totalUsd: $totalUsd, totalVes: $totalVes, costUsd: $costUsd, costVes: $costVes, profitUsd: $profitUsd, profitVes: $profitVes, payments: $payments, products: $products)';
}


}

/// @nodoc
abstract mixin class _$SessionSalesReportDtoCopyWith<$Res> implements $SessionSalesReportDtoCopyWith<$Res> {
  factory _$SessionSalesReportDtoCopyWith(_SessionSalesReportDto value, $Res Function(_SessionSalesReportDto) _then) = __$SessionSalesReportDtoCopyWithImpl;
@override @useResult
$Res call({
 int salesCount,@DecimalConverter() Decimal totalUsd,@DecimalConverter() Decimal totalVes,@DecimalConverter() Decimal costUsd,@DecimalConverter() Decimal costVes,@DecimalConverter() Decimal profitUsd,@DecimalConverter() Decimal profitVes, List<PaymentTotalDto> payments, List<ProductSalesDto> products
});




}
/// @nodoc
class __$SessionSalesReportDtoCopyWithImpl<$Res>
    implements _$SessionSalesReportDtoCopyWith<$Res> {
  __$SessionSalesReportDtoCopyWithImpl(this._self, this._then);

  final _SessionSalesReportDto _self;
  final $Res Function(_SessionSalesReportDto) _then;

/// Create a copy of SessionSalesReportDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? salesCount = null,Object? totalUsd = null,Object? totalVes = null,Object? costUsd = null,Object? costVes = null,Object? profitUsd = null,Object? profitVes = null,Object? payments = null,Object? products = null,}) {
  return _then(_SessionSalesReportDto(
salesCount: null == salesCount ? _self.salesCount : salesCount // ignore: cast_nullable_to_non_nullable
as int,totalUsd: null == totalUsd ? _self.totalUsd : totalUsd // ignore: cast_nullable_to_non_nullable
as Decimal,totalVes: null == totalVes ? _self.totalVes : totalVes // ignore: cast_nullable_to_non_nullable
as Decimal,costUsd: null == costUsd ? _self.costUsd : costUsd // ignore: cast_nullable_to_non_nullable
as Decimal,costVes: null == costVes ? _self.costVes : costVes // ignore: cast_nullable_to_non_nullable
as Decimal,profitUsd: null == profitUsd ? _self.profitUsd : profitUsd // ignore: cast_nullable_to_non_nullable
as Decimal,profitVes: null == profitVes ? _self.profitVes : profitVes // ignore: cast_nullable_to_non_nullable
as Decimal,payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<PaymentTotalDto>,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<ProductSalesDto>,
  ));
}


}

// dart format on
