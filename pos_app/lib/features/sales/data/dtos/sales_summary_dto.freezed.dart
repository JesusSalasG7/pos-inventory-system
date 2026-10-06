// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_summary_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SalesSummaryDto {

 int get salesCount;@DecimalConverter() Decimal get totalUsd;@DecimalConverter() Decimal get totalVes;
/// Create a copy of SalesSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesSummaryDtoCopyWith<SalesSummaryDto> get copyWith => _$SalesSummaryDtoCopyWithImpl<SalesSummaryDto>(this as SalesSummaryDto, _$identity);

  /// Serializes this SalesSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesSummaryDto&&(identical(other.salesCount, salesCount) || other.salesCount == salesCount)&&(identical(other.totalUsd, totalUsd) || other.totalUsd == totalUsd)&&(identical(other.totalVes, totalVes) || other.totalVes == totalVes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salesCount,totalUsd,totalVes);

@override
String toString() {
  return 'SalesSummaryDto(salesCount: $salesCount, totalUsd: $totalUsd, totalVes: $totalVes)';
}


}

/// @nodoc
abstract mixin class $SalesSummaryDtoCopyWith<$Res>  {
  factory $SalesSummaryDtoCopyWith(SalesSummaryDto value, $Res Function(SalesSummaryDto) _then) = _$SalesSummaryDtoCopyWithImpl;
@useResult
$Res call({
 int salesCount,@DecimalConverter() Decimal totalUsd,@DecimalConverter() Decimal totalVes
});




}
/// @nodoc
class _$SalesSummaryDtoCopyWithImpl<$Res>
    implements $SalesSummaryDtoCopyWith<$Res> {
  _$SalesSummaryDtoCopyWithImpl(this._self, this._then);

  final SalesSummaryDto _self;
  final $Res Function(SalesSummaryDto) _then;

/// Create a copy of SalesSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? salesCount = null,Object? totalUsd = null,Object? totalVes = null,}) {
  return _then(_self.copyWith(
salesCount: null == salesCount ? _self.salesCount : salesCount // ignore: cast_nullable_to_non_nullable
as int,totalUsd: null == totalUsd ? _self.totalUsd : totalUsd // ignore: cast_nullable_to_non_nullable
as Decimal,totalVes: null == totalVes ? _self.totalVes : totalVes // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesSummaryDto].
extension SalesSummaryDtoPatterns on SalesSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _SalesSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _SalesSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int salesCount, @DecimalConverter()  Decimal totalUsd, @DecimalConverter()  Decimal totalVes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesSummaryDto() when $default != null:
return $default(_that.salesCount,_that.totalUsd,_that.totalVes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int salesCount, @DecimalConverter()  Decimal totalUsd, @DecimalConverter()  Decimal totalVes)  $default,) {final _that = this;
switch (_that) {
case _SalesSummaryDto():
return $default(_that.salesCount,_that.totalUsd,_that.totalVes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int salesCount, @DecimalConverter()  Decimal totalUsd, @DecimalConverter()  Decimal totalVes)?  $default,) {final _that = this;
switch (_that) {
case _SalesSummaryDto() when $default != null:
return $default(_that.salesCount,_that.totalUsd,_that.totalVes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesSummaryDto extends SalesSummaryDto {
  const _SalesSummaryDto({required this.salesCount, @DecimalConverter() required this.totalUsd, @DecimalConverter() required this.totalVes}): super._();
  factory _SalesSummaryDto.fromJson(Map<String, dynamic> json) => _$SalesSummaryDtoFromJson(json);

@override final  int salesCount;
@override@DecimalConverter() final  Decimal totalUsd;
@override@DecimalConverter() final  Decimal totalVes;

/// Create a copy of SalesSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesSummaryDtoCopyWith<_SalesSummaryDto> get copyWith => __$SalesSummaryDtoCopyWithImpl<_SalesSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesSummaryDto&&(identical(other.salesCount, salesCount) || other.salesCount == salesCount)&&(identical(other.totalUsd, totalUsd) || other.totalUsd == totalUsd)&&(identical(other.totalVes, totalVes) || other.totalVes == totalVes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salesCount,totalUsd,totalVes);

@override
String toString() {
  return 'SalesSummaryDto(salesCount: $salesCount, totalUsd: $totalUsd, totalVes: $totalVes)';
}


}

/// @nodoc
abstract mixin class _$SalesSummaryDtoCopyWith<$Res> implements $SalesSummaryDtoCopyWith<$Res> {
  factory _$SalesSummaryDtoCopyWith(_SalesSummaryDto value, $Res Function(_SalesSummaryDto) _then) = __$SalesSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 int salesCount,@DecimalConverter() Decimal totalUsd,@DecimalConverter() Decimal totalVes
});




}
/// @nodoc
class __$SalesSummaryDtoCopyWithImpl<$Res>
    implements _$SalesSummaryDtoCopyWith<$Res> {
  __$SalesSummaryDtoCopyWithImpl(this._self, this._then);

  final _SalesSummaryDto _self;
  final $Res Function(_SalesSummaryDto) _then;

/// Create a copy of SalesSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? salesCount = null,Object? totalUsd = null,Object? totalVes = null,}) {
  return _then(_SalesSummaryDto(
salesCount: null == salesCount ? _self.salesCount : salesCount // ignore: cast_nullable_to_non_nullable
as int,totalUsd: null == totalUsd ? _self.totalUsd : totalUsd // ignore: cast_nullable_to_non_nullable
as Decimal,totalVes: null == totalVes ? _self.totalVes : totalVes // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

// dart format on
