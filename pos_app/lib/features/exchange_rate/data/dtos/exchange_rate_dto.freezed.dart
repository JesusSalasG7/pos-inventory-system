// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_rate_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExchangeRateDto {

 int get id;@DecimalConverter() Decimal get usdToVesRate; int get createdBy; DateTime get createdAt;
/// Create a copy of ExchangeRateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExchangeRateDtoCopyWith<ExchangeRateDto> get copyWith => _$ExchangeRateDtoCopyWithImpl<ExchangeRateDto>(this as ExchangeRateDto, _$identity);

  /// Serializes this ExchangeRateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExchangeRateDto&&(identical(other.id, id) || other.id == id)&&(identical(other.usdToVesRate, usdToVesRate) || other.usdToVesRate == usdToVesRate)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,usdToVesRate,createdBy,createdAt);

@override
String toString() {
  return 'ExchangeRateDto(id: $id, usdToVesRate: $usdToVesRate, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ExchangeRateDtoCopyWith<$Res>  {
  factory $ExchangeRateDtoCopyWith(ExchangeRateDto value, $Res Function(ExchangeRateDto) _then) = _$ExchangeRateDtoCopyWithImpl;
@useResult
$Res call({
 int id,@DecimalConverter() Decimal usdToVesRate, int createdBy, DateTime createdAt
});




}
/// @nodoc
class _$ExchangeRateDtoCopyWithImpl<$Res>
    implements $ExchangeRateDtoCopyWith<$Res> {
  _$ExchangeRateDtoCopyWithImpl(this._self, this._then);

  final ExchangeRateDto _self;
  final $Res Function(ExchangeRateDto) _then;

/// Create a copy of ExchangeRateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? usdToVesRate = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,usdToVesRate: null == usdToVesRate ? _self.usdToVesRate : usdToVesRate // ignore: cast_nullable_to_non_nullable
as Decimal,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ExchangeRateDto].
extension ExchangeRateDtoPatterns on ExchangeRateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExchangeRateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExchangeRateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExchangeRateDto value)  $default,){
final _that = this;
switch (_that) {
case _ExchangeRateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExchangeRateDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExchangeRateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @DecimalConverter()  Decimal usdToVesRate,  int createdBy,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExchangeRateDto() when $default != null:
return $default(_that.id,_that.usdToVesRate,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @DecimalConverter()  Decimal usdToVesRate,  int createdBy,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ExchangeRateDto():
return $default(_that.id,_that.usdToVesRate,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @DecimalConverter()  Decimal usdToVesRate,  int createdBy,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ExchangeRateDto() when $default != null:
return $default(_that.id,_that.usdToVesRate,_that.createdBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExchangeRateDto extends ExchangeRateDto {
  const _ExchangeRateDto({required this.id, @DecimalConverter() required this.usdToVesRate, required this.createdBy, required this.createdAt}): super._();
  factory _ExchangeRateDto.fromJson(Map<String, dynamic> json) => _$ExchangeRateDtoFromJson(json);

@override final  int id;
@override@DecimalConverter() final  Decimal usdToVesRate;
@override final  int createdBy;
@override final  DateTime createdAt;

/// Create a copy of ExchangeRateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExchangeRateDtoCopyWith<_ExchangeRateDto> get copyWith => __$ExchangeRateDtoCopyWithImpl<_ExchangeRateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExchangeRateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExchangeRateDto&&(identical(other.id, id) || other.id == id)&&(identical(other.usdToVesRate, usdToVesRate) || other.usdToVesRate == usdToVesRate)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,usdToVesRate,createdBy,createdAt);

@override
String toString() {
  return 'ExchangeRateDto(id: $id, usdToVesRate: $usdToVesRate, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ExchangeRateDtoCopyWith<$Res> implements $ExchangeRateDtoCopyWith<$Res> {
  factory _$ExchangeRateDtoCopyWith(_ExchangeRateDto value, $Res Function(_ExchangeRateDto) _then) = __$ExchangeRateDtoCopyWithImpl;
@override @useResult
$Res call({
 int id,@DecimalConverter() Decimal usdToVesRate, int createdBy, DateTime createdAt
});




}
/// @nodoc
class __$ExchangeRateDtoCopyWithImpl<$Res>
    implements _$ExchangeRateDtoCopyWith<$Res> {
  __$ExchangeRateDtoCopyWithImpl(this._self, this._then);

  final _ExchangeRateDto _self;
  final $Res Function(_ExchangeRateDto) _then;

/// Create a copy of ExchangeRateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? usdToVesRate = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_ExchangeRateDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,usdToVesRate: null == usdToVesRate ? _self.usdToVesRate : usdToVesRate // ignore: cast_nullable_to_non_nullable
as Decimal,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$BcvRateDto {

@DecimalConverter() Decimal get rate; DateTime get updatedAt;
/// Create a copy of BcvRateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BcvRateDtoCopyWith<BcvRateDto> get copyWith => _$BcvRateDtoCopyWithImpl<BcvRateDto>(this as BcvRateDto, _$identity);

  /// Serializes this BcvRateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BcvRateDto&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rate,updatedAt);

@override
String toString() {
  return 'BcvRateDto(rate: $rate, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BcvRateDtoCopyWith<$Res>  {
  factory $BcvRateDtoCopyWith(BcvRateDto value, $Res Function(BcvRateDto) _then) = _$BcvRateDtoCopyWithImpl;
@useResult
$Res call({
@DecimalConverter() Decimal rate, DateTime updatedAt
});




}
/// @nodoc
class _$BcvRateDtoCopyWithImpl<$Res>
    implements $BcvRateDtoCopyWith<$Res> {
  _$BcvRateDtoCopyWithImpl(this._self, this._then);

  final BcvRateDto _self;
  final $Res Function(BcvRateDto) _then;

/// Create a copy of BcvRateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rate = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as Decimal,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BcvRateDto].
extension BcvRateDtoPatterns on BcvRateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BcvRateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BcvRateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BcvRateDto value)  $default,){
final _that = this;
switch (_that) {
case _BcvRateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BcvRateDto value)?  $default,){
final _that = this;
switch (_that) {
case _BcvRateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DecimalConverter()  Decimal rate,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BcvRateDto() when $default != null:
return $default(_that.rate,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DecimalConverter()  Decimal rate,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BcvRateDto():
return $default(_that.rate,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DecimalConverter()  Decimal rate,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BcvRateDto() when $default != null:
return $default(_that.rate,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BcvRateDto extends BcvRateDto {
  const _BcvRateDto({@DecimalConverter() required this.rate, required this.updatedAt}): super._();
  factory _BcvRateDto.fromJson(Map<String, dynamic> json) => _$BcvRateDtoFromJson(json);

@override@DecimalConverter() final  Decimal rate;
@override final  DateTime updatedAt;

/// Create a copy of BcvRateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BcvRateDtoCopyWith<_BcvRateDto> get copyWith => __$BcvRateDtoCopyWithImpl<_BcvRateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BcvRateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BcvRateDto&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rate,updatedAt);

@override
String toString() {
  return 'BcvRateDto(rate: $rate, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BcvRateDtoCopyWith<$Res> implements $BcvRateDtoCopyWith<$Res> {
  factory _$BcvRateDtoCopyWith(_BcvRateDto value, $Res Function(_BcvRateDto) _then) = __$BcvRateDtoCopyWithImpl;
@override @useResult
$Res call({
@DecimalConverter() Decimal rate, DateTime updatedAt
});




}
/// @nodoc
class __$BcvRateDtoCopyWithImpl<$Res>
    implements _$BcvRateDtoCopyWith<$Res> {
  __$BcvRateDtoCopyWithImpl(this._self, this._then);

  final _BcvRateDto _self;
  final $Res Function(_BcvRateDto) _then;

/// Create a copy of BcvRateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rate = null,Object? updatedAt = null,}) {
  return _then(_BcvRateDto(
rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as Decimal,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
