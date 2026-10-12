// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'statistics_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PeriodDto {

 String get dateFrom; String get dateTo;
/// Create a copy of PeriodDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodDtoCopyWith<PeriodDto> get copyWith => _$PeriodDtoCopyWithImpl<PeriodDto>(this as PeriodDto, _$identity);

  /// Serializes this PeriodDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodDto&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateFrom,dateTo);

@override
String toString() {
  return 'PeriodDto(dateFrom: $dateFrom, dateTo: $dateTo)';
}


}

/// @nodoc
abstract mixin class $PeriodDtoCopyWith<$Res>  {
  factory $PeriodDtoCopyWith(PeriodDto value, $Res Function(PeriodDto) _then) = _$PeriodDtoCopyWithImpl;
@useResult
$Res call({
 String dateFrom, String dateTo
});




}
/// @nodoc
class _$PeriodDtoCopyWithImpl<$Res>
    implements $PeriodDtoCopyWith<$Res> {
  _$PeriodDtoCopyWithImpl(this._self, this._then);

  final PeriodDto _self;
  final $Res Function(PeriodDto) _then;

/// Create a copy of PeriodDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateFrom = null,Object? dateTo = null,}) {
  return _then(_self.copyWith(
dateFrom: null == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as String,dateTo: null == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PeriodDto].
extension PeriodDtoPatterns on PeriodDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodDto value)  $default,){
final _that = this;
switch (_that) {
case _PeriodDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodDto value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dateFrom,  String dateTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeriodDto() when $default != null:
return $default(_that.dateFrom,_that.dateTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dateFrom,  String dateTo)  $default,) {final _that = this;
switch (_that) {
case _PeriodDto():
return $default(_that.dateFrom,_that.dateTo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dateFrom,  String dateTo)?  $default,) {final _that = this;
switch (_that) {
case _PeriodDto() when $default != null:
return $default(_that.dateFrom,_that.dateTo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PeriodDto extends PeriodDto {
  const _PeriodDto({required this.dateFrom, required this.dateTo}): super._();
  factory _PeriodDto.fromJson(Map<String, dynamic> json) => _$PeriodDtoFromJson(json);

@override final  String dateFrom;
@override final  String dateTo;

/// Create a copy of PeriodDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodDtoCopyWith<_PeriodDto> get copyWith => __$PeriodDtoCopyWithImpl<_PeriodDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PeriodDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodDto&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateFrom,dateTo);

@override
String toString() {
  return 'PeriodDto(dateFrom: $dateFrom, dateTo: $dateTo)';
}


}

/// @nodoc
abstract mixin class _$PeriodDtoCopyWith<$Res> implements $PeriodDtoCopyWith<$Res> {
  factory _$PeriodDtoCopyWith(_PeriodDto value, $Res Function(_PeriodDto) _then) = __$PeriodDtoCopyWithImpl;
@override @useResult
$Res call({
 String dateFrom, String dateTo
});




}
/// @nodoc
class __$PeriodDtoCopyWithImpl<$Res>
    implements _$PeriodDtoCopyWith<$Res> {
  __$PeriodDtoCopyWithImpl(this._self, this._then);

  final _PeriodDto _self;
  final $Res Function(_PeriodDto) _then;

/// Create a copy of PeriodDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateFrom = null,Object? dateTo = null,}) {
  return _then(_PeriodDto(
dateFrom: null == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as String,dateTo: null == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$KpisDto {

@NumberDecimalConverter() Decimal get revenue;@NumberDecimalConverter() Decimal get profit;@NumberDecimalConverter() Decimal get margin;@NumberDecimalConverter() Decimal get units; int get salesCount;@NumberDecimalConverter() Decimal get averageTicket;
/// Create a copy of KpisDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KpisDtoCopyWith<KpisDto> get copyWith => _$KpisDtoCopyWithImpl<KpisDto>(this as KpisDto, _$identity);

  /// Serializes this KpisDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KpisDto&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin)&&(identical(other.units, units) || other.units == units)&&(identical(other.salesCount, salesCount) || other.salesCount == salesCount)&&(identical(other.averageTicket, averageTicket) || other.averageTicket == averageTicket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,revenue,profit,margin,units,salesCount,averageTicket);

@override
String toString() {
  return 'KpisDto(revenue: $revenue, profit: $profit, margin: $margin, units: $units, salesCount: $salesCount, averageTicket: $averageTicket)';
}


}

/// @nodoc
abstract mixin class $KpisDtoCopyWith<$Res>  {
  factory $KpisDtoCopyWith(KpisDto value, $Res Function(KpisDto) _then) = _$KpisDtoCopyWithImpl;
@useResult
$Res call({
@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit,@NumberDecimalConverter() Decimal margin,@NumberDecimalConverter() Decimal units, int salesCount,@NumberDecimalConverter() Decimal averageTicket
});




}
/// @nodoc
class _$KpisDtoCopyWithImpl<$Res>
    implements $KpisDtoCopyWith<$Res> {
  _$KpisDtoCopyWithImpl(this._self, this._then);

  final KpisDto _self;
  final $Res Function(KpisDto) _then;

/// Create a copy of KpisDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? revenue = null,Object? profit = null,Object? margin = null,Object? units = null,Object? salesCount = null,Object? averageTicket = null,}) {
  return _then(_self.copyWith(
revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as Decimal,salesCount: null == salesCount ? _self.salesCount : salesCount // ignore: cast_nullable_to_non_nullable
as int,averageTicket: null == averageTicket ? _self.averageTicket : averageTicket // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [KpisDto].
extension KpisDtoPatterns on KpisDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KpisDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KpisDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KpisDto value)  $default,){
final _that = this;
switch (_that) {
case _KpisDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KpisDto value)?  $default,){
final _that = this;
switch (_that) {
case _KpisDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin, @NumberDecimalConverter()  Decimal units,  int salesCount, @NumberDecimalConverter()  Decimal averageTicket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KpisDto() when $default != null:
return $default(_that.revenue,_that.profit,_that.margin,_that.units,_that.salesCount,_that.averageTicket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin, @NumberDecimalConverter()  Decimal units,  int salesCount, @NumberDecimalConverter()  Decimal averageTicket)  $default,) {final _that = this;
switch (_that) {
case _KpisDto():
return $default(_that.revenue,_that.profit,_that.margin,_that.units,_that.salesCount,_that.averageTicket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin, @NumberDecimalConverter()  Decimal units,  int salesCount, @NumberDecimalConverter()  Decimal averageTicket)?  $default,) {final _that = this;
switch (_that) {
case _KpisDto() when $default != null:
return $default(_that.revenue,_that.profit,_that.margin,_that.units,_that.salesCount,_that.averageTicket);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KpisDto extends KpisDto {
  const _KpisDto({@NumberDecimalConverter() required this.revenue, @NumberDecimalConverter() required this.profit, @NumberDecimalConverter() required this.margin, @NumberDecimalConverter() required this.units, required this.salesCount, @NumberDecimalConverter() required this.averageTicket}): super._();
  factory _KpisDto.fromJson(Map<String, dynamic> json) => _$KpisDtoFromJson(json);

@override@NumberDecimalConverter() final  Decimal revenue;
@override@NumberDecimalConverter() final  Decimal profit;
@override@NumberDecimalConverter() final  Decimal margin;
@override@NumberDecimalConverter() final  Decimal units;
@override final  int salesCount;
@override@NumberDecimalConverter() final  Decimal averageTicket;

/// Create a copy of KpisDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KpisDtoCopyWith<_KpisDto> get copyWith => __$KpisDtoCopyWithImpl<_KpisDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KpisDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KpisDto&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin)&&(identical(other.units, units) || other.units == units)&&(identical(other.salesCount, salesCount) || other.salesCount == salesCount)&&(identical(other.averageTicket, averageTicket) || other.averageTicket == averageTicket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,revenue,profit,margin,units,salesCount,averageTicket);

@override
String toString() {
  return 'KpisDto(revenue: $revenue, profit: $profit, margin: $margin, units: $units, salesCount: $salesCount, averageTicket: $averageTicket)';
}


}

/// @nodoc
abstract mixin class _$KpisDtoCopyWith<$Res> implements $KpisDtoCopyWith<$Res> {
  factory _$KpisDtoCopyWith(_KpisDto value, $Res Function(_KpisDto) _then) = __$KpisDtoCopyWithImpl;
@override @useResult
$Res call({
@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit,@NumberDecimalConverter() Decimal margin,@NumberDecimalConverter() Decimal units, int salesCount,@NumberDecimalConverter() Decimal averageTicket
});




}
/// @nodoc
class __$KpisDtoCopyWithImpl<$Res>
    implements _$KpisDtoCopyWith<$Res> {
  __$KpisDtoCopyWithImpl(this._self, this._then);

  final _KpisDto _self;
  final $Res Function(_KpisDto) _then;

/// Create a copy of KpisDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? revenue = null,Object? profit = null,Object? margin = null,Object? units = null,Object? salesCount = null,Object? averageTicket = null,}) {
  return _then(_KpisDto(
revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as Decimal,salesCount: null == salesCount ? _self.salesCount : salesCount // ignore: cast_nullable_to_non_nullable
as int,averageTicket: null == averageTicket ? _self.averageTicket : averageTicket // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$KpiChangesDto {

@NullableNumberDecimalConverter() Decimal? get revenue;@NullableNumberDecimalConverter() Decimal? get profit;@NullableNumberDecimalConverter() Decimal? get margin;@NullableNumberDecimalConverter() Decimal? get units;@NullableNumberDecimalConverter() Decimal? get salesCount;@NullableNumberDecimalConverter() Decimal? get averageTicket;
/// Create a copy of KpiChangesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KpiChangesDtoCopyWith<KpiChangesDto> get copyWith => _$KpiChangesDtoCopyWithImpl<KpiChangesDto>(this as KpiChangesDto, _$identity);

  /// Serializes this KpiChangesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KpiChangesDto&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin)&&(identical(other.units, units) || other.units == units)&&(identical(other.salesCount, salesCount) || other.salesCount == salesCount)&&(identical(other.averageTicket, averageTicket) || other.averageTicket == averageTicket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,revenue,profit,margin,units,salesCount,averageTicket);

@override
String toString() {
  return 'KpiChangesDto(revenue: $revenue, profit: $profit, margin: $margin, units: $units, salesCount: $salesCount, averageTicket: $averageTicket)';
}


}

/// @nodoc
abstract mixin class $KpiChangesDtoCopyWith<$Res>  {
  factory $KpiChangesDtoCopyWith(KpiChangesDto value, $Res Function(KpiChangesDto) _then) = _$KpiChangesDtoCopyWithImpl;
@useResult
$Res call({
@NullableNumberDecimalConverter() Decimal? revenue,@NullableNumberDecimalConverter() Decimal? profit,@NullableNumberDecimalConverter() Decimal? margin,@NullableNumberDecimalConverter() Decimal? units,@NullableNumberDecimalConverter() Decimal? salesCount,@NullableNumberDecimalConverter() Decimal? averageTicket
});




}
/// @nodoc
class _$KpiChangesDtoCopyWithImpl<$Res>
    implements $KpiChangesDtoCopyWith<$Res> {
  _$KpiChangesDtoCopyWithImpl(this._self, this._then);

  final KpiChangesDto _self;
  final $Res Function(KpiChangesDto) _then;

/// Create a copy of KpiChangesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? revenue = freezed,Object? profit = freezed,Object? margin = freezed,Object? units = freezed,Object? salesCount = freezed,Object? averageTicket = freezed,}) {
  return _then(_self.copyWith(
revenue: freezed == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal?,profit: freezed == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal?,margin: freezed == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal?,units: freezed == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as Decimal?,salesCount: freezed == salesCount ? _self.salesCount : salesCount // ignore: cast_nullable_to_non_nullable
as Decimal?,averageTicket: freezed == averageTicket ? _self.averageTicket : averageTicket // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}

}


/// Adds pattern-matching-related methods to [KpiChangesDto].
extension KpiChangesDtoPatterns on KpiChangesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KpiChangesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KpiChangesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KpiChangesDto value)  $default,){
final _that = this;
switch (_that) {
case _KpiChangesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KpiChangesDto value)?  $default,){
final _that = this;
switch (_that) {
case _KpiChangesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@NullableNumberDecimalConverter()  Decimal? revenue, @NullableNumberDecimalConverter()  Decimal? profit, @NullableNumberDecimalConverter()  Decimal? margin, @NullableNumberDecimalConverter()  Decimal? units, @NullableNumberDecimalConverter()  Decimal? salesCount, @NullableNumberDecimalConverter()  Decimal? averageTicket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KpiChangesDto() when $default != null:
return $default(_that.revenue,_that.profit,_that.margin,_that.units,_that.salesCount,_that.averageTicket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@NullableNumberDecimalConverter()  Decimal? revenue, @NullableNumberDecimalConverter()  Decimal? profit, @NullableNumberDecimalConverter()  Decimal? margin, @NullableNumberDecimalConverter()  Decimal? units, @NullableNumberDecimalConverter()  Decimal? salesCount, @NullableNumberDecimalConverter()  Decimal? averageTicket)  $default,) {final _that = this;
switch (_that) {
case _KpiChangesDto():
return $default(_that.revenue,_that.profit,_that.margin,_that.units,_that.salesCount,_that.averageTicket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@NullableNumberDecimalConverter()  Decimal? revenue, @NullableNumberDecimalConverter()  Decimal? profit, @NullableNumberDecimalConverter()  Decimal? margin, @NullableNumberDecimalConverter()  Decimal? units, @NullableNumberDecimalConverter()  Decimal? salesCount, @NullableNumberDecimalConverter()  Decimal? averageTicket)?  $default,) {final _that = this;
switch (_that) {
case _KpiChangesDto() when $default != null:
return $default(_that.revenue,_that.profit,_that.margin,_that.units,_that.salesCount,_that.averageTicket);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KpiChangesDto extends KpiChangesDto {
  const _KpiChangesDto({@NullableNumberDecimalConverter() this.revenue, @NullableNumberDecimalConverter() this.profit, @NullableNumberDecimalConverter() this.margin, @NullableNumberDecimalConverter() this.units, @NullableNumberDecimalConverter() this.salesCount, @NullableNumberDecimalConverter() this.averageTicket}): super._();
  factory _KpiChangesDto.fromJson(Map<String, dynamic> json) => _$KpiChangesDtoFromJson(json);

@override@NullableNumberDecimalConverter() final  Decimal? revenue;
@override@NullableNumberDecimalConverter() final  Decimal? profit;
@override@NullableNumberDecimalConverter() final  Decimal? margin;
@override@NullableNumberDecimalConverter() final  Decimal? units;
@override@NullableNumberDecimalConverter() final  Decimal? salesCount;
@override@NullableNumberDecimalConverter() final  Decimal? averageTicket;

/// Create a copy of KpiChangesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KpiChangesDtoCopyWith<_KpiChangesDto> get copyWith => __$KpiChangesDtoCopyWithImpl<_KpiChangesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KpiChangesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KpiChangesDto&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin)&&(identical(other.units, units) || other.units == units)&&(identical(other.salesCount, salesCount) || other.salesCount == salesCount)&&(identical(other.averageTicket, averageTicket) || other.averageTicket == averageTicket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,revenue,profit,margin,units,salesCount,averageTicket);

@override
String toString() {
  return 'KpiChangesDto(revenue: $revenue, profit: $profit, margin: $margin, units: $units, salesCount: $salesCount, averageTicket: $averageTicket)';
}


}

/// @nodoc
abstract mixin class _$KpiChangesDtoCopyWith<$Res> implements $KpiChangesDtoCopyWith<$Res> {
  factory _$KpiChangesDtoCopyWith(_KpiChangesDto value, $Res Function(_KpiChangesDto) _then) = __$KpiChangesDtoCopyWithImpl;
@override @useResult
$Res call({
@NullableNumberDecimalConverter() Decimal? revenue,@NullableNumberDecimalConverter() Decimal? profit,@NullableNumberDecimalConverter() Decimal? margin,@NullableNumberDecimalConverter() Decimal? units,@NullableNumberDecimalConverter() Decimal? salesCount,@NullableNumberDecimalConverter() Decimal? averageTicket
});




}
/// @nodoc
class __$KpiChangesDtoCopyWithImpl<$Res>
    implements _$KpiChangesDtoCopyWith<$Res> {
  __$KpiChangesDtoCopyWithImpl(this._self, this._then);

  final _KpiChangesDto _self;
  final $Res Function(_KpiChangesDto) _then;

/// Create a copy of KpiChangesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? revenue = freezed,Object? profit = freezed,Object? margin = freezed,Object? units = freezed,Object? salesCount = freezed,Object? averageTicket = freezed,}) {
  return _then(_KpiChangesDto(
revenue: freezed == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal?,profit: freezed == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal?,margin: freezed == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal?,units: freezed == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as Decimal?,salesCount: freezed == salesCount ? _self.salesCount : salesCount // ignore: cast_nullable_to_non_nullable
as Decimal?,averageTicket: freezed == averageTicket ? _self.averageTicket : averageTicket // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}


}


/// @nodoc
mixin _$SummaryDto {

 PeriodDto get period; PeriodDto get previousPeriod; KpisDto get current; KpisDto get previous; KpiChangesDto get change;
/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryDtoCopyWith<SummaryDto> get copyWith => _$SummaryDtoCopyWithImpl<SummaryDto>(this as SummaryDto, _$identity);

  /// Serializes this SummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummaryDto&&(identical(other.period, period) || other.period == period)&&(identical(other.previousPeriod, previousPeriod) || other.previousPeriod == previousPeriod)&&(identical(other.current, current) || other.current == current)&&(identical(other.previous, previous) || other.previous == previous)&&(identical(other.change, change) || other.change == change));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,previousPeriod,current,previous,change);

@override
String toString() {
  return 'SummaryDto(period: $period, previousPeriod: $previousPeriod, current: $current, previous: $previous, change: $change)';
}


}

/// @nodoc
abstract mixin class $SummaryDtoCopyWith<$Res>  {
  factory $SummaryDtoCopyWith(SummaryDto value, $Res Function(SummaryDto) _then) = _$SummaryDtoCopyWithImpl;
@useResult
$Res call({
 PeriodDto period, PeriodDto previousPeriod, KpisDto current, KpisDto previous, KpiChangesDto change
});


$PeriodDtoCopyWith<$Res> get period;$PeriodDtoCopyWith<$Res> get previousPeriod;$KpisDtoCopyWith<$Res> get current;$KpisDtoCopyWith<$Res> get previous;$KpiChangesDtoCopyWith<$Res> get change;

}
/// @nodoc
class _$SummaryDtoCopyWithImpl<$Res>
    implements $SummaryDtoCopyWith<$Res> {
  _$SummaryDtoCopyWithImpl(this._self, this._then);

  final SummaryDto _self;
  final $Res Function(SummaryDto) _then;

/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? previousPeriod = null,Object? current = null,Object? previous = null,Object? change = null,}) {
  return _then(_self.copyWith(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as PeriodDto,previousPeriod: null == previousPeriod ? _self.previousPeriod : previousPeriod // ignore: cast_nullable_to_non_nullable
as PeriodDto,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as KpisDto,previous: null == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as KpisDto,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as KpiChangesDto,
  ));
}
/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodDtoCopyWith<$Res> get period {
  
  return $PeriodDtoCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodDtoCopyWith<$Res> get previousPeriod {
  
  return $PeriodDtoCopyWith<$Res>(_self.previousPeriod, (value) {
    return _then(_self.copyWith(previousPeriod: value));
  });
}/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KpisDtoCopyWith<$Res> get current {
  
  return $KpisDtoCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KpisDtoCopyWith<$Res> get previous {
  
  return $KpisDtoCopyWith<$Res>(_self.previous, (value) {
    return _then(_self.copyWith(previous: value));
  });
}/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KpiChangesDtoCopyWith<$Res> get change {
  
  return $KpiChangesDtoCopyWith<$Res>(_self.change, (value) {
    return _then(_self.copyWith(change: value));
  });
}
}


/// Adds pattern-matching-related methods to [SummaryDto].
extension SummaryDtoPatterns on SummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _SummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _SummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PeriodDto period,  PeriodDto previousPeriod,  KpisDto current,  KpisDto previous,  KpiChangesDto change)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SummaryDto() when $default != null:
return $default(_that.period,_that.previousPeriod,_that.current,_that.previous,_that.change);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PeriodDto period,  PeriodDto previousPeriod,  KpisDto current,  KpisDto previous,  KpiChangesDto change)  $default,) {final _that = this;
switch (_that) {
case _SummaryDto():
return $default(_that.period,_that.previousPeriod,_that.current,_that.previous,_that.change);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PeriodDto period,  PeriodDto previousPeriod,  KpisDto current,  KpisDto previous,  KpiChangesDto change)?  $default,) {final _that = this;
switch (_that) {
case _SummaryDto() when $default != null:
return $default(_that.period,_that.previousPeriod,_that.current,_that.previous,_that.change);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SummaryDto extends SummaryDto {
  const _SummaryDto({required this.period, required this.previousPeriod, required this.current, required this.previous, required this.change}): super._();
  factory _SummaryDto.fromJson(Map<String, dynamic> json) => _$SummaryDtoFromJson(json);

@override final  PeriodDto period;
@override final  PeriodDto previousPeriod;
@override final  KpisDto current;
@override final  KpisDto previous;
@override final  KpiChangesDto change;

/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryDtoCopyWith<_SummaryDto> get copyWith => __$SummaryDtoCopyWithImpl<_SummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SummaryDto&&(identical(other.period, period) || other.period == period)&&(identical(other.previousPeriod, previousPeriod) || other.previousPeriod == previousPeriod)&&(identical(other.current, current) || other.current == current)&&(identical(other.previous, previous) || other.previous == previous)&&(identical(other.change, change) || other.change == change));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,previousPeriod,current,previous,change);

@override
String toString() {
  return 'SummaryDto(period: $period, previousPeriod: $previousPeriod, current: $current, previous: $previous, change: $change)';
}


}

/// @nodoc
abstract mixin class _$SummaryDtoCopyWith<$Res> implements $SummaryDtoCopyWith<$Res> {
  factory _$SummaryDtoCopyWith(_SummaryDto value, $Res Function(_SummaryDto) _then) = __$SummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 PeriodDto period, PeriodDto previousPeriod, KpisDto current, KpisDto previous, KpiChangesDto change
});


@override $PeriodDtoCopyWith<$Res> get period;@override $PeriodDtoCopyWith<$Res> get previousPeriod;@override $KpisDtoCopyWith<$Res> get current;@override $KpisDtoCopyWith<$Res> get previous;@override $KpiChangesDtoCopyWith<$Res> get change;

}
/// @nodoc
class __$SummaryDtoCopyWithImpl<$Res>
    implements _$SummaryDtoCopyWith<$Res> {
  __$SummaryDtoCopyWithImpl(this._self, this._then);

  final _SummaryDto _self;
  final $Res Function(_SummaryDto) _then;

/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? previousPeriod = null,Object? current = null,Object? previous = null,Object? change = null,}) {
  return _then(_SummaryDto(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as PeriodDto,previousPeriod: null == previousPeriod ? _self.previousPeriod : previousPeriod // ignore: cast_nullable_to_non_nullable
as PeriodDto,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as KpisDto,previous: null == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as KpisDto,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as KpiChangesDto,
  ));
}

/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodDtoCopyWith<$Res> get period {
  
  return $PeriodDtoCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodDtoCopyWith<$Res> get previousPeriod {
  
  return $PeriodDtoCopyWith<$Res>(_self.previousPeriod, (value) {
    return _then(_self.copyWith(previousPeriod: value));
  });
}/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KpisDtoCopyWith<$Res> get current {
  
  return $KpisDtoCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KpisDtoCopyWith<$Res> get previous {
  
  return $KpisDtoCopyWith<$Res>(_self.previous, (value) {
    return _then(_self.copyWith(previous: value));
  });
}/// Create a copy of SummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KpiChangesDtoCopyWith<$Res> get change {
  
  return $KpiChangesDtoCopyWith<$Res>(_self.change, (value) {
    return _then(_self.copyWith(change: value));
  });
}
}


/// @nodoc
mixin _$SplitTotalsDto {

@NumberDecimalConverter() Decimal get revenue;@NumberDecimalConverter() Decimal get profit;@NumberDecimalConverter() Decimal get margin;
/// Create a copy of SplitTotalsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SplitTotalsDtoCopyWith<SplitTotalsDto> get copyWith => _$SplitTotalsDtoCopyWithImpl<SplitTotalsDto>(this as SplitTotalsDto, _$identity);

  /// Serializes this SplitTotalsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SplitTotalsDto&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,revenue,profit,margin);

@override
String toString() {
  return 'SplitTotalsDto(revenue: $revenue, profit: $profit, margin: $margin)';
}


}

/// @nodoc
abstract mixin class $SplitTotalsDtoCopyWith<$Res>  {
  factory $SplitTotalsDtoCopyWith(SplitTotalsDto value, $Res Function(SplitTotalsDto) _then) = _$SplitTotalsDtoCopyWithImpl;
@useResult
$Res call({
@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit,@NumberDecimalConverter() Decimal margin
});




}
/// @nodoc
class _$SplitTotalsDtoCopyWithImpl<$Res>
    implements $SplitTotalsDtoCopyWith<$Res> {
  _$SplitTotalsDtoCopyWithImpl(this._self, this._then);

  final SplitTotalsDto _self;
  final $Res Function(SplitTotalsDto) _then;

/// Create a copy of SplitTotalsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? revenue = null,Object? profit = null,Object? margin = null,}) {
  return _then(_self.copyWith(
revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [SplitTotalsDto].
extension SplitTotalsDtoPatterns on SplitTotalsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SplitTotalsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SplitTotalsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SplitTotalsDto value)  $default,){
final _that = this;
switch (_that) {
case _SplitTotalsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SplitTotalsDto value)?  $default,){
final _that = this;
switch (_that) {
case _SplitTotalsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SplitTotalsDto() when $default != null:
return $default(_that.revenue,_that.profit,_that.margin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin)  $default,) {final _that = this;
switch (_that) {
case _SplitTotalsDto():
return $default(_that.revenue,_that.profit,_that.margin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin)?  $default,) {final _that = this;
switch (_that) {
case _SplitTotalsDto() when $default != null:
return $default(_that.revenue,_that.profit,_that.margin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SplitTotalsDto extends SplitTotalsDto {
  const _SplitTotalsDto({@NumberDecimalConverter() required this.revenue, @NumberDecimalConverter() required this.profit, @NumberDecimalConverter() required this.margin}): super._();
  factory _SplitTotalsDto.fromJson(Map<String, dynamic> json) => _$SplitTotalsDtoFromJson(json);

@override@NumberDecimalConverter() final  Decimal revenue;
@override@NumberDecimalConverter() final  Decimal profit;
@override@NumberDecimalConverter() final  Decimal margin;

/// Create a copy of SplitTotalsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SplitTotalsDtoCopyWith<_SplitTotalsDto> get copyWith => __$SplitTotalsDtoCopyWithImpl<_SplitTotalsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SplitTotalsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SplitTotalsDto&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,revenue,profit,margin);

@override
String toString() {
  return 'SplitTotalsDto(revenue: $revenue, profit: $profit, margin: $margin)';
}


}

/// @nodoc
abstract mixin class _$SplitTotalsDtoCopyWith<$Res> implements $SplitTotalsDtoCopyWith<$Res> {
  factory _$SplitTotalsDtoCopyWith(_SplitTotalsDto value, $Res Function(_SplitTotalsDto) _then) = __$SplitTotalsDtoCopyWithImpl;
@override @useResult
$Res call({
@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit,@NumberDecimalConverter() Decimal margin
});




}
/// @nodoc
class __$SplitTotalsDtoCopyWithImpl<$Res>
    implements _$SplitTotalsDtoCopyWith<$Res> {
  __$SplitTotalsDtoCopyWithImpl(this._self, this._then);

  final _SplitTotalsDto _self;
  final $Res Function(_SplitTotalsDto) _then;

/// Create a copy of SplitTotalsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? revenue = null,Object? profit = null,Object? margin = null,}) {
  return _then(_SplitTotalsDto(
revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$PendingTotalsDto {

@NumberDecimalConverter() Decimal get revenue;@NumberDecimalConverter() Decimal get profit;
/// Create a copy of PendingTotalsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingTotalsDtoCopyWith<PendingTotalsDto> get copyWith => _$PendingTotalsDtoCopyWithImpl<PendingTotalsDto>(this as PendingTotalsDto, _$identity);

  /// Serializes this PendingTotalsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingTotalsDto&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,revenue,profit);

@override
String toString() {
  return 'PendingTotalsDto(revenue: $revenue, profit: $profit)';
}


}

/// @nodoc
abstract mixin class $PendingTotalsDtoCopyWith<$Res>  {
  factory $PendingTotalsDtoCopyWith(PendingTotalsDto value, $Res Function(PendingTotalsDto) _then) = _$PendingTotalsDtoCopyWithImpl;
@useResult
$Res call({
@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit
});




}
/// @nodoc
class _$PendingTotalsDtoCopyWithImpl<$Res>
    implements $PendingTotalsDtoCopyWith<$Res> {
  _$PendingTotalsDtoCopyWithImpl(this._self, this._then);

  final PendingTotalsDto _self;
  final $Res Function(PendingTotalsDto) _then;

/// Create a copy of PendingTotalsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? revenue = null,Object? profit = null,}) {
  return _then(_self.copyWith(
revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingTotalsDto].
extension PendingTotalsDtoPatterns on PendingTotalsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingTotalsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingTotalsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingTotalsDto value)  $default,){
final _that = this;
switch (_that) {
case _PendingTotalsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingTotalsDto value)?  $default,){
final _that = this;
switch (_that) {
case _PendingTotalsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingTotalsDto() when $default != null:
return $default(_that.revenue,_that.profit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit)  $default,) {final _that = this;
switch (_that) {
case _PendingTotalsDto():
return $default(_that.revenue,_that.profit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit)?  $default,) {final _that = this;
switch (_that) {
case _PendingTotalsDto() when $default != null:
return $default(_that.revenue,_that.profit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingTotalsDto implements PendingTotalsDto {
  const _PendingTotalsDto({@NumberDecimalConverter() required this.revenue, @NumberDecimalConverter() required this.profit});
  factory _PendingTotalsDto.fromJson(Map<String, dynamic> json) => _$PendingTotalsDtoFromJson(json);

@override@NumberDecimalConverter() final  Decimal revenue;
@override@NumberDecimalConverter() final  Decimal profit;

/// Create a copy of PendingTotalsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingTotalsDtoCopyWith<_PendingTotalsDto> get copyWith => __$PendingTotalsDtoCopyWithImpl<_PendingTotalsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingTotalsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingTotalsDto&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,revenue,profit);

@override
String toString() {
  return 'PendingTotalsDto(revenue: $revenue, profit: $profit)';
}


}

/// @nodoc
abstract mixin class _$PendingTotalsDtoCopyWith<$Res> implements $PendingTotalsDtoCopyWith<$Res> {
  factory _$PendingTotalsDtoCopyWith(_PendingTotalsDto value, $Res Function(_PendingTotalsDto) _then) = __$PendingTotalsDtoCopyWithImpl;
@override @useResult
$Res call({
@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit
});




}
/// @nodoc
class __$PendingTotalsDtoCopyWithImpl<$Res>
    implements _$PendingTotalsDtoCopyWith<$Res> {
  __$PendingTotalsDtoCopyWithImpl(this._self, this._then);

  final _PendingTotalsDto _self;
  final $Res Function(_PendingTotalsDto) _then;

/// Create a copy of PendingTotalsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? revenue = null,Object? profit = null,}) {
  return _then(_PendingTotalsDto(
revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$CreditBreakdownDto {

 SplitTotalsDto get cash; SplitTotalsDto get credit; PendingTotalsDto get pending;@NumberDecimalConverter() Decimal get creditShare;
/// Create a copy of CreditBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditBreakdownDtoCopyWith<CreditBreakdownDto> get copyWith => _$CreditBreakdownDtoCopyWithImpl<CreditBreakdownDto>(this as CreditBreakdownDto, _$identity);

  /// Serializes this CreditBreakdownDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditBreakdownDto&&(identical(other.cash, cash) || other.cash == cash)&&(identical(other.credit, credit) || other.credit == credit)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.creditShare, creditShare) || other.creditShare == creditShare));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cash,credit,pending,creditShare);

@override
String toString() {
  return 'CreditBreakdownDto(cash: $cash, credit: $credit, pending: $pending, creditShare: $creditShare)';
}


}

/// @nodoc
abstract mixin class $CreditBreakdownDtoCopyWith<$Res>  {
  factory $CreditBreakdownDtoCopyWith(CreditBreakdownDto value, $Res Function(CreditBreakdownDto) _then) = _$CreditBreakdownDtoCopyWithImpl;
@useResult
$Res call({
 SplitTotalsDto cash, SplitTotalsDto credit, PendingTotalsDto pending,@NumberDecimalConverter() Decimal creditShare
});


$SplitTotalsDtoCopyWith<$Res> get cash;$SplitTotalsDtoCopyWith<$Res> get credit;$PendingTotalsDtoCopyWith<$Res> get pending;

}
/// @nodoc
class _$CreditBreakdownDtoCopyWithImpl<$Res>
    implements $CreditBreakdownDtoCopyWith<$Res> {
  _$CreditBreakdownDtoCopyWithImpl(this._self, this._then);

  final CreditBreakdownDto _self;
  final $Res Function(CreditBreakdownDto) _then;

/// Create a copy of CreditBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cash = null,Object? credit = null,Object? pending = null,Object? creditShare = null,}) {
  return _then(_self.copyWith(
cash: null == cash ? _self.cash : cash // ignore: cast_nullable_to_non_nullable
as SplitTotalsDto,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as SplitTotalsDto,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as PendingTotalsDto,creditShare: null == creditShare ? _self.creditShare : creditShare // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}
/// Create a copy of CreditBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SplitTotalsDtoCopyWith<$Res> get cash {
  
  return $SplitTotalsDtoCopyWith<$Res>(_self.cash, (value) {
    return _then(_self.copyWith(cash: value));
  });
}/// Create a copy of CreditBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SplitTotalsDtoCopyWith<$Res> get credit {
  
  return $SplitTotalsDtoCopyWith<$Res>(_self.credit, (value) {
    return _then(_self.copyWith(credit: value));
  });
}/// Create a copy of CreditBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PendingTotalsDtoCopyWith<$Res> get pending {
  
  return $PendingTotalsDtoCopyWith<$Res>(_self.pending, (value) {
    return _then(_self.copyWith(pending: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreditBreakdownDto].
extension CreditBreakdownDtoPatterns on CreditBreakdownDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditBreakdownDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditBreakdownDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditBreakdownDto value)  $default,){
final _that = this;
switch (_that) {
case _CreditBreakdownDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditBreakdownDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreditBreakdownDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SplitTotalsDto cash,  SplitTotalsDto credit,  PendingTotalsDto pending, @NumberDecimalConverter()  Decimal creditShare)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditBreakdownDto() when $default != null:
return $default(_that.cash,_that.credit,_that.pending,_that.creditShare);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SplitTotalsDto cash,  SplitTotalsDto credit,  PendingTotalsDto pending, @NumberDecimalConverter()  Decimal creditShare)  $default,) {final _that = this;
switch (_that) {
case _CreditBreakdownDto():
return $default(_that.cash,_that.credit,_that.pending,_that.creditShare);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SplitTotalsDto cash,  SplitTotalsDto credit,  PendingTotalsDto pending, @NumberDecimalConverter()  Decimal creditShare)?  $default,) {final _that = this;
switch (_that) {
case _CreditBreakdownDto() when $default != null:
return $default(_that.cash,_that.credit,_that.pending,_that.creditShare);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditBreakdownDto extends CreditBreakdownDto {
  const _CreditBreakdownDto({required this.cash, required this.credit, required this.pending, @NumberDecimalConverter() required this.creditShare}): super._();
  factory _CreditBreakdownDto.fromJson(Map<String, dynamic> json) => _$CreditBreakdownDtoFromJson(json);

@override final  SplitTotalsDto cash;
@override final  SplitTotalsDto credit;
@override final  PendingTotalsDto pending;
@override@NumberDecimalConverter() final  Decimal creditShare;

/// Create a copy of CreditBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditBreakdownDtoCopyWith<_CreditBreakdownDto> get copyWith => __$CreditBreakdownDtoCopyWithImpl<_CreditBreakdownDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditBreakdownDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditBreakdownDto&&(identical(other.cash, cash) || other.cash == cash)&&(identical(other.credit, credit) || other.credit == credit)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.creditShare, creditShare) || other.creditShare == creditShare));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cash,credit,pending,creditShare);

@override
String toString() {
  return 'CreditBreakdownDto(cash: $cash, credit: $credit, pending: $pending, creditShare: $creditShare)';
}


}

/// @nodoc
abstract mixin class _$CreditBreakdownDtoCopyWith<$Res> implements $CreditBreakdownDtoCopyWith<$Res> {
  factory _$CreditBreakdownDtoCopyWith(_CreditBreakdownDto value, $Res Function(_CreditBreakdownDto) _then) = __$CreditBreakdownDtoCopyWithImpl;
@override @useResult
$Res call({
 SplitTotalsDto cash, SplitTotalsDto credit, PendingTotalsDto pending,@NumberDecimalConverter() Decimal creditShare
});


@override $SplitTotalsDtoCopyWith<$Res> get cash;@override $SplitTotalsDtoCopyWith<$Res> get credit;@override $PendingTotalsDtoCopyWith<$Res> get pending;

}
/// @nodoc
class __$CreditBreakdownDtoCopyWithImpl<$Res>
    implements _$CreditBreakdownDtoCopyWith<$Res> {
  __$CreditBreakdownDtoCopyWithImpl(this._self, this._then);

  final _CreditBreakdownDto _self;
  final $Res Function(_CreditBreakdownDto) _then;

/// Create a copy of CreditBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cash = null,Object? credit = null,Object? pending = null,Object? creditShare = null,}) {
  return _then(_CreditBreakdownDto(
cash: null == cash ? _self.cash : cash // ignore: cast_nullable_to_non_nullable
as SplitTotalsDto,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as SplitTotalsDto,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as PendingTotalsDto,creditShare: null == creditShare ? _self.creditShare : creditShare // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

/// Create a copy of CreditBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SplitTotalsDtoCopyWith<$Res> get cash {
  
  return $SplitTotalsDtoCopyWith<$Res>(_self.cash, (value) {
    return _then(_self.copyWith(cash: value));
  });
}/// Create a copy of CreditBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SplitTotalsDtoCopyWith<$Res> get credit {
  
  return $SplitTotalsDtoCopyWith<$Res>(_self.credit, (value) {
    return _then(_self.copyWith(credit: value));
  });
}/// Create a copy of CreditBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PendingTotalsDtoCopyWith<$Res> get pending {
  
  return $PendingTotalsDtoCopyWith<$Res>(_self.pending, (value) {
    return _then(_self.copyWith(pending: value));
  });
}
}


/// @nodoc
mixin _$GroupPerformanceDto {

 int? get id; String get name;@NumberDecimalConverter() Decimal get units;@NumberDecimalConverter() Decimal get revenue;@NumberDecimalConverter() Decimal get profit;@NumberDecimalConverter() Decimal get margin;
/// Create a copy of GroupPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupPerformanceDtoCopyWith<GroupPerformanceDto> get copyWith => _$GroupPerformanceDtoCopyWithImpl<GroupPerformanceDto>(this as GroupPerformanceDto, _$identity);

  /// Serializes this GroupPerformanceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupPerformanceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.units, units) || other.units == units)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,units,revenue,profit,margin);

@override
String toString() {
  return 'GroupPerformanceDto(id: $id, name: $name, units: $units, revenue: $revenue, profit: $profit, margin: $margin)';
}


}

/// @nodoc
abstract mixin class $GroupPerformanceDtoCopyWith<$Res>  {
  factory $GroupPerformanceDtoCopyWith(GroupPerformanceDto value, $Res Function(GroupPerformanceDto) _then) = _$GroupPerformanceDtoCopyWithImpl;
@useResult
$Res call({
 int? id, String name,@NumberDecimalConverter() Decimal units,@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit,@NumberDecimalConverter() Decimal margin
});




}
/// @nodoc
class _$GroupPerformanceDtoCopyWithImpl<$Res>
    implements $GroupPerformanceDtoCopyWith<$Res> {
  _$GroupPerformanceDtoCopyWithImpl(this._self, this._then);

  final GroupPerformanceDto _self;
  final $Res Function(GroupPerformanceDto) _then;

/// Create a copy of GroupPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? units = null,Object? revenue = null,Object? profit = null,Object? margin = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as Decimal,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupPerformanceDto].
extension GroupPerformanceDtoPatterns on GroupPerformanceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupPerformanceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupPerformanceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupPerformanceDto value)  $default,){
final _that = this;
switch (_that) {
case _GroupPerformanceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupPerformanceDto value)?  $default,){
final _that = this;
switch (_that) {
case _GroupPerformanceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name, @NumberDecimalConverter()  Decimal units, @NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupPerformanceDto() when $default != null:
return $default(_that.id,_that.name,_that.units,_that.revenue,_that.profit,_that.margin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name, @NumberDecimalConverter()  Decimal units, @NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin)  $default,) {final _that = this;
switch (_that) {
case _GroupPerformanceDto():
return $default(_that.id,_that.name,_that.units,_that.revenue,_that.profit,_that.margin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name, @NumberDecimalConverter()  Decimal units, @NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin)?  $default,) {final _that = this;
switch (_that) {
case _GroupPerformanceDto() when $default != null:
return $default(_that.id,_that.name,_that.units,_that.revenue,_that.profit,_that.margin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupPerformanceDto extends GroupPerformanceDto {
  const _GroupPerformanceDto({this.id, required this.name, @NumberDecimalConverter() required this.units, @NumberDecimalConverter() required this.revenue, @NumberDecimalConverter() required this.profit, @NumberDecimalConverter() required this.margin}): super._();
  factory _GroupPerformanceDto.fromJson(Map<String, dynamic> json) => _$GroupPerformanceDtoFromJson(json);

@override final  int? id;
@override final  String name;
@override@NumberDecimalConverter() final  Decimal units;
@override@NumberDecimalConverter() final  Decimal revenue;
@override@NumberDecimalConverter() final  Decimal profit;
@override@NumberDecimalConverter() final  Decimal margin;

/// Create a copy of GroupPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupPerformanceDtoCopyWith<_GroupPerformanceDto> get copyWith => __$GroupPerformanceDtoCopyWithImpl<_GroupPerformanceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupPerformanceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupPerformanceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.units, units) || other.units == units)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,units,revenue,profit,margin);

@override
String toString() {
  return 'GroupPerformanceDto(id: $id, name: $name, units: $units, revenue: $revenue, profit: $profit, margin: $margin)';
}


}

/// @nodoc
abstract mixin class _$GroupPerformanceDtoCopyWith<$Res> implements $GroupPerformanceDtoCopyWith<$Res> {
  factory _$GroupPerformanceDtoCopyWith(_GroupPerformanceDto value, $Res Function(_GroupPerformanceDto) _then) = __$GroupPerformanceDtoCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name,@NumberDecimalConverter() Decimal units,@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit,@NumberDecimalConverter() Decimal margin
});




}
/// @nodoc
class __$GroupPerformanceDtoCopyWithImpl<$Res>
    implements _$GroupPerformanceDtoCopyWith<$Res> {
  __$GroupPerformanceDtoCopyWithImpl(this._self, this._then);

  final _GroupPerformanceDto _self;
  final $Res Function(_GroupPerformanceDto) _then;

/// Create a copy of GroupPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? units = null,Object? revenue = null,Object? profit = null,Object? margin = null,}) {
  return _then(_GroupPerformanceDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as Decimal,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$GroupReportDto {

 String get level; List<GroupPerformanceDto> get groups;
/// Create a copy of GroupReportDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupReportDtoCopyWith<GroupReportDto> get copyWith => _$GroupReportDtoCopyWithImpl<GroupReportDto>(this as GroupReportDto, _$identity);

  /// Serializes this GroupReportDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupReportDto&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other.groups, groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,const DeepCollectionEquality().hash(groups));

@override
String toString() {
  return 'GroupReportDto(level: $level, groups: $groups)';
}


}

/// @nodoc
abstract mixin class $GroupReportDtoCopyWith<$Res>  {
  factory $GroupReportDtoCopyWith(GroupReportDto value, $Res Function(GroupReportDto) _then) = _$GroupReportDtoCopyWithImpl;
@useResult
$Res call({
 String level, List<GroupPerformanceDto> groups
});




}
/// @nodoc
class _$GroupReportDtoCopyWithImpl<$Res>
    implements $GroupReportDtoCopyWith<$Res> {
  _$GroupReportDtoCopyWithImpl(this._self, this._then);

  final GroupReportDto _self;
  final $Res Function(GroupReportDto) _then;

/// Create a copy of GroupReportDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? groups = null,}) {
  return _then(_self.copyWith(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<GroupPerformanceDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupReportDto].
extension GroupReportDtoPatterns on GroupReportDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupReportDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupReportDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupReportDto value)  $default,){
final _that = this;
switch (_that) {
case _GroupReportDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupReportDto value)?  $default,){
final _that = this;
switch (_that) {
case _GroupReportDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String level,  List<GroupPerformanceDto> groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupReportDto() when $default != null:
return $default(_that.level,_that.groups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String level,  List<GroupPerformanceDto> groups)  $default,) {final _that = this;
switch (_that) {
case _GroupReportDto():
return $default(_that.level,_that.groups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String level,  List<GroupPerformanceDto> groups)?  $default,) {final _that = this;
switch (_that) {
case _GroupReportDto() when $default != null:
return $default(_that.level,_that.groups);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupReportDto extends GroupReportDto {
  const _GroupReportDto({required this.level, required final  List<GroupPerformanceDto> groups}): _groups = groups,super._();
  factory _GroupReportDto.fromJson(Map<String, dynamic> json) => _$GroupReportDtoFromJson(json);

@override final  String level;
 final  List<GroupPerformanceDto> _groups;
@override List<GroupPerformanceDto> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}


/// Create a copy of GroupReportDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupReportDtoCopyWith<_GroupReportDto> get copyWith => __$GroupReportDtoCopyWithImpl<_GroupReportDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupReportDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupReportDto&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other._groups, _groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,const DeepCollectionEquality().hash(_groups));

@override
String toString() {
  return 'GroupReportDto(level: $level, groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$GroupReportDtoCopyWith<$Res> implements $GroupReportDtoCopyWith<$Res> {
  factory _$GroupReportDtoCopyWith(_GroupReportDto value, $Res Function(_GroupReportDto) _then) = __$GroupReportDtoCopyWithImpl;
@override @useResult
$Res call({
 String level, List<GroupPerformanceDto> groups
});




}
/// @nodoc
class __$GroupReportDtoCopyWithImpl<$Res>
    implements _$GroupReportDtoCopyWith<$Res> {
  __$GroupReportDtoCopyWithImpl(this._self, this._then);

  final _GroupReportDto _self;
  final $Res Function(_GroupReportDto) _then;

/// Create a copy of GroupReportDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? groups = null,}) {
  return _then(_GroupReportDto(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<GroupPerformanceDto>,
  ));
}


}


/// @nodoc
mixin _$ProductPerformanceDto {

 int get productId; String get name; String get unitOfMeasure; String get categoryName; String? get subcategoryName;@NumberDecimalConverter() Decimal get units;@NumberDecimalConverter() Decimal get revenue;@NumberDecimalConverter() Decimal get profit;@NumberDecimalConverter() Decimal get margin;
/// Create a copy of ProductPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductPerformanceDtoCopyWith<ProductPerformanceDto> get copyWith => _$ProductPerformanceDtoCopyWithImpl<ProductPerformanceDto>(this as ProductPerformanceDto, _$identity);

  /// Serializes this ProductPerformanceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductPerformanceDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitOfMeasure, unitOfMeasure) || other.unitOfMeasure == unitOfMeasure)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.subcategoryName, subcategoryName) || other.subcategoryName == subcategoryName)&&(identical(other.units, units) || other.units == units)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unitOfMeasure,categoryName,subcategoryName,units,revenue,profit,margin);

@override
String toString() {
  return 'ProductPerformanceDto(productId: $productId, name: $name, unitOfMeasure: $unitOfMeasure, categoryName: $categoryName, subcategoryName: $subcategoryName, units: $units, revenue: $revenue, profit: $profit, margin: $margin)';
}


}

/// @nodoc
abstract mixin class $ProductPerformanceDtoCopyWith<$Res>  {
  factory $ProductPerformanceDtoCopyWith(ProductPerformanceDto value, $Res Function(ProductPerformanceDto) _then) = _$ProductPerformanceDtoCopyWithImpl;
@useResult
$Res call({
 int productId, String name, String unitOfMeasure, String categoryName, String? subcategoryName,@NumberDecimalConverter() Decimal units,@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit,@NumberDecimalConverter() Decimal margin
});




}
/// @nodoc
class _$ProductPerformanceDtoCopyWithImpl<$Res>
    implements $ProductPerformanceDtoCopyWith<$Res> {
  _$ProductPerformanceDtoCopyWithImpl(this._self, this._then);

  final ProductPerformanceDto _self;
  final $Res Function(ProductPerformanceDto) _then;

/// Create a copy of ProductPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? name = null,Object? unitOfMeasure = null,Object? categoryName = null,Object? subcategoryName = freezed,Object? units = null,Object? revenue = null,Object? profit = null,Object? margin = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasure: null == unitOfMeasure ? _self.unitOfMeasure : unitOfMeasure // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,subcategoryName: freezed == subcategoryName ? _self.subcategoryName : subcategoryName // ignore: cast_nullable_to_non_nullable
as String?,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as Decimal,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductPerformanceDto].
extension ProductPerformanceDtoPatterns on ProductPerformanceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductPerformanceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductPerformanceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductPerformanceDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductPerformanceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductPerformanceDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductPerformanceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String name,  String unitOfMeasure,  String categoryName,  String? subcategoryName, @NumberDecimalConverter()  Decimal units, @NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductPerformanceDto() when $default != null:
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.categoryName,_that.subcategoryName,_that.units,_that.revenue,_that.profit,_that.margin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String name,  String unitOfMeasure,  String categoryName,  String? subcategoryName, @NumberDecimalConverter()  Decimal units, @NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin)  $default,) {final _that = this;
switch (_that) {
case _ProductPerformanceDto():
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.categoryName,_that.subcategoryName,_that.units,_that.revenue,_that.profit,_that.margin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String name,  String unitOfMeasure,  String categoryName,  String? subcategoryName, @NumberDecimalConverter()  Decimal units, @NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin)?  $default,) {final _that = this;
switch (_that) {
case _ProductPerformanceDto() when $default != null:
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.categoryName,_that.subcategoryName,_that.units,_that.revenue,_that.profit,_that.margin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductPerformanceDto extends ProductPerformanceDto {
  const _ProductPerformanceDto({required this.productId, required this.name, required this.unitOfMeasure, required this.categoryName, this.subcategoryName, @NumberDecimalConverter() required this.units, @NumberDecimalConverter() required this.revenue, @NumberDecimalConverter() required this.profit, @NumberDecimalConverter() required this.margin}): super._();
  factory _ProductPerformanceDto.fromJson(Map<String, dynamic> json) => _$ProductPerformanceDtoFromJson(json);

@override final  int productId;
@override final  String name;
@override final  String unitOfMeasure;
@override final  String categoryName;
@override final  String? subcategoryName;
@override@NumberDecimalConverter() final  Decimal units;
@override@NumberDecimalConverter() final  Decimal revenue;
@override@NumberDecimalConverter() final  Decimal profit;
@override@NumberDecimalConverter() final  Decimal margin;

/// Create a copy of ProductPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductPerformanceDtoCopyWith<_ProductPerformanceDto> get copyWith => __$ProductPerformanceDtoCopyWithImpl<_ProductPerformanceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductPerformanceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductPerformanceDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitOfMeasure, unitOfMeasure) || other.unitOfMeasure == unitOfMeasure)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.subcategoryName, subcategoryName) || other.subcategoryName == subcategoryName)&&(identical(other.units, units) || other.units == units)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unitOfMeasure,categoryName,subcategoryName,units,revenue,profit,margin);

@override
String toString() {
  return 'ProductPerformanceDto(productId: $productId, name: $name, unitOfMeasure: $unitOfMeasure, categoryName: $categoryName, subcategoryName: $subcategoryName, units: $units, revenue: $revenue, profit: $profit, margin: $margin)';
}


}

/// @nodoc
abstract mixin class _$ProductPerformanceDtoCopyWith<$Res> implements $ProductPerformanceDtoCopyWith<$Res> {
  factory _$ProductPerformanceDtoCopyWith(_ProductPerformanceDto value, $Res Function(_ProductPerformanceDto) _then) = __$ProductPerformanceDtoCopyWithImpl;
@override @useResult
$Res call({
 int productId, String name, String unitOfMeasure, String categoryName, String? subcategoryName,@NumberDecimalConverter() Decimal units,@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit,@NumberDecimalConverter() Decimal margin
});




}
/// @nodoc
class __$ProductPerformanceDtoCopyWithImpl<$Res>
    implements _$ProductPerformanceDtoCopyWith<$Res> {
  __$ProductPerformanceDtoCopyWithImpl(this._self, this._then);

  final _ProductPerformanceDto _self;
  final $Res Function(_ProductPerformanceDto) _then;

/// Create a copy of ProductPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? name = null,Object? unitOfMeasure = null,Object? categoryName = null,Object? subcategoryName = freezed,Object? units = null,Object? revenue = null,Object? profit = null,Object? margin = null,}) {
  return _then(_ProductPerformanceDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasure: null == unitOfMeasure ? _self.unitOfMeasure : unitOfMeasure // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,subcategoryName: freezed == subcategoryName ? _self.subcategoryName : subcategoryName // ignore: cast_nullable_to_non_nullable
as String?,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as Decimal,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$MatrixPointDto {

 int get productId; String get name; String get unitOfMeasure;@NumberDecimalConverter() Decimal get units;@NumberDecimalConverter() Decimal get revenue;@NumberDecimalConverter() Decimal get profit;@NumberDecimalConverter() Decimal get margin; String get quadrant;
/// Create a copy of MatrixPointDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatrixPointDtoCopyWith<MatrixPointDto> get copyWith => _$MatrixPointDtoCopyWithImpl<MatrixPointDto>(this as MatrixPointDto, _$identity);

  /// Serializes this MatrixPointDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatrixPointDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitOfMeasure, unitOfMeasure) || other.unitOfMeasure == unitOfMeasure)&&(identical(other.units, units) || other.units == units)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin)&&(identical(other.quadrant, quadrant) || other.quadrant == quadrant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unitOfMeasure,units,revenue,profit,margin,quadrant);

@override
String toString() {
  return 'MatrixPointDto(productId: $productId, name: $name, unitOfMeasure: $unitOfMeasure, units: $units, revenue: $revenue, profit: $profit, margin: $margin, quadrant: $quadrant)';
}


}

/// @nodoc
abstract mixin class $MatrixPointDtoCopyWith<$Res>  {
  factory $MatrixPointDtoCopyWith(MatrixPointDto value, $Res Function(MatrixPointDto) _then) = _$MatrixPointDtoCopyWithImpl;
@useResult
$Res call({
 int productId, String name, String unitOfMeasure,@NumberDecimalConverter() Decimal units,@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit,@NumberDecimalConverter() Decimal margin, String quadrant
});




}
/// @nodoc
class _$MatrixPointDtoCopyWithImpl<$Res>
    implements $MatrixPointDtoCopyWith<$Res> {
  _$MatrixPointDtoCopyWithImpl(this._self, this._then);

  final MatrixPointDto _self;
  final $Res Function(MatrixPointDto) _then;

/// Create a copy of MatrixPointDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? name = null,Object? unitOfMeasure = null,Object? units = null,Object? revenue = null,Object? profit = null,Object? margin = null,Object? quadrant = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasure: null == unitOfMeasure ? _self.unitOfMeasure : unitOfMeasure // ignore: cast_nullable_to_non_nullable
as String,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as Decimal,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal,quadrant: null == quadrant ? _self.quadrant : quadrant // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MatrixPointDto].
extension MatrixPointDtoPatterns on MatrixPointDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatrixPointDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatrixPointDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatrixPointDto value)  $default,){
final _that = this;
switch (_that) {
case _MatrixPointDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatrixPointDto value)?  $default,){
final _that = this;
switch (_that) {
case _MatrixPointDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String name,  String unitOfMeasure, @NumberDecimalConverter()  Decimal units, @NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin,  String quadrant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatrixPointDto() when $default != null:
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.units,_that.revenue,_that.profit,_that.margin,_that.quadrant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String name,  String unitOfMeasure, @NumberDecimalConverter()  Decimal units, @NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin,  String quadrant)  $default,) {final _that = this;
switch (_that) {
case _MatrixPointDto():
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.units,_that.revenue,_that.profit,_that.margin,_that.quadrant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String name,  String unitOfMeasure, @NumberDecimalConverter()  Decimal units, @NumberDecimalConverter()  Decimal revenue, @NumberDecimalConverter()  Decimal profit, @NumberDecimalConverter()  Decimal margin,  String quadrant)?  $default,) {final _that = this;
switch (_that) {
case _MatrixPointDto() when $default != null:
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.units,_that.revenue,_that.profit,_that.margin,_that.quadrant);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatrixPointDto extends MatrixPointDto {
  const _MatrixPointDto({required this.productId, required this.name, required this.unitOfMeasure, @NumberDecimalConverter() required this.units, @NumberDecimalConverter() required this.revenue, @NumberDecimalConverter() required this.profit, @NumberDecimalConverter() required this.margin, required this.quadrant}): super._();
  factory _MatrixPointDto.fromJson(Map<String, dynamic> json) => _$MatrixPointDtoFromJson(json);

@override final  int productId;
@override final  String name;
@override final  String unitOfMeasure;
@override@NumberDecimalConverter() final  Decimal units;
@override@NumberDecimalConverter() final  Decimal revenue;
@override@NumberDecimalConverter() final  Decimal profit;
@override@NumberDecimalConverter() final  Decimal margin;
@override final  String quadrant;

/// Create a copy of MatrixPointDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatrixPointDtoCopyWith<_MatrixPointDto> get copyWith => __$MatrixPointDtoCopyWithImpl<_MatrixPointDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatrixPointDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatrixPointDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitOfMeasure, unitOfMeasure) || other.unitOfMeasure == unitOfMeasure)&&(identical(other.units, units) || other.units == units)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.margin, margin) || other.margin == margin)&&(identical(other.quadrant, quadrant) || other.quadrant == quadrant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unitOfMeasure,units,revenue,profit,margin,quadrant);

@override
String toString() {
  return 'MatrixPointDto(productId: $productId, name: $name, unitOfMeasure: $unitOfMeasure, units: $units, revenue: $revenue, profit: $profit, margin: $margin, quadrant: $quadrant)';
}


}

/// @nodoc
abstract mixin class _$MatrixPointDtoCopyWith<$Res> implements $MatrixPointDtoCopyWith<$Res> {
  factory _$MatrixPointDtoCopyWith(_MatrixPointDto value, $Res Function(_MatrixPointDto) _then) = __$MatrixPointDtoCopyWithImpl;
@override @useResult
$Res call({
 int productId, String name, String unitOfMeasure,@NumberDecimalConverter() Decimal units,@NumberDecimalConverter() Decimal revenue,@NumberDecimalConverter() Decimal profit,@NumberDecimalConverter() Decimal margin, String quadrant
});




}
/// @nodoc
class __$MatrixPointDtoCopyWithImpl<$Res>
    implements _$MatrixPointDtoCopyWith<$Res> {
  __$MatrixPointDtoCopyWithImpl(this._self, this._then);

  final _MatrixPointDto _self;
  final $Res Function(_MatrixPointDto) _then;

/// Create a copy of MatrixPointDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? name = null,Object? unitOfMeasure = null,Object? units = null,Object? revenue = null,Object? profit = null,Object? margin = null,Object? quadrant = null,}) {
  return _then(_MatrixPointDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasure: null == unitOfMeasure ? _self.unitOfMeasure : unitOfMeasure // ignore: cast_nullable_to_non_nullable
as String,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as Decimal,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Decimal,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as Decimal,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as Decimal,quadrant: null == quadrant ? _self.quadrant : quadrant // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MatrixDto {

@NumberDecimalConverter() Decimal get medianUnits;@NumberDecimalConverter() Decimal get medianMargin; List<MatrixPointDto> get products;
/// Create a copy of MatrixDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatrixDtoCopyWith<MatrixDto> get copyWith => _$MatrixDtoCopyWithImpl<MatrixDto>(this as MatrixDto, _$identity);

  /// Serializes this MatrixDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatrixDto&&(identical(other.medianUnits, medianUnits) || other.medianUnits == medianUnits)&&(identical(other.medianMargin, medianMargin) || other.medianMargin == medianMargin)&&const DeepCollectionEquality().equals(other.products, products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,medianUnits,medianMargin,const DeepCollectionEquality().hash(products));

@override
String toString() {
  return 'MatrixDto(medianUnits: $medianUnits, medianMargin: $medianMargin, products: $products)';
}


}

/// @nodoc
abstract mixin class $MatrixDtoCopyWith<$Res>  {
  factory $MatrixDtoCopyWith(MatrixDto value, $Res Function(MatrixDto) _then) = _$MatrixDtoCopyWithImpl;
@useResult
$Res call({
@NumberDecimalConverter() Decimal medianUnits,@NumberDecimalConverter() Decimal medianMargin, List<MatrixPointDto> products
});




}
/// @nodoc
class _$MatrixDtoCopyWithImpl<$Res>
    implements $MatrixDtoCopyWith<$Res> {
  _$MatrixDtoCopyWithImpl(this._self, this._then);

  final MatrixDto _self;
  final $Res Function(MatrixDto) _then;

/// Create a copy of MatrixDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? medianUnits = null,Object? medianMargin = null,Object? products = null,}) {
  return _then(_self.copyWith(
medianUnits: null == medianUnits ? _self.medianUnits : medianUnits // ignore: cast_nullable_to_non_nullable
as Decimal,medianMargin: null == medianMargin ? _self.medianMargin : medianMargin // ignore: cast_nullable_to_non_nullable
as Decimal,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<MatrixPointDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [MatrixDto].
extension MatrixDtoPatterns on MatrixDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatrixDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatrixDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatrixDto value)  $default,){
final _that = this;
switch (_that) {
case _MatrixDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatrixDto value)?  $default,){
final _that = this;
switch (_that) {
case _MatrixDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@NumberDecimalConverter()  Decimal medianUnits, @NumberDecimalConverter()  Decimal medianMargin,  List<MatrixPointDto> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatrixDto() when $default != null:
return $default(_that.medianUnits,_that.medianMargin,_that.products);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@NumberDecimalConverter()  Decimal medianUnits, @NumberDecimalConverter()  Decimal medianMargin,  List<MatrixPointDto> products)  $default,) {final _that = this;
switch (_that) {
case _MatrixDto():
return $default(_that.medianUnits,_that.medianMargin,_that.products);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@NumberDecimalConverter()  Decimal medianUnits, @NumberDecimalConverter()  Decimal medianMargin,  List<MatrixPointDto> products)?  $default,) {final _that = this;
switch (_that) {
case _MatrixDto() when $default != null:
return $default(_that.medianUnits,_that.medianMargin,_that.products);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatrixDto extends MatrixDto {
  const _MatrixDto({@NumberDecimalConverter() required this.medianUnits, @NumberDecimalConverter() required this.medianMargin, required final  List<MatrixPointDto> products}): _products = products,super._();
  factory _MatrixDto.fromJson(Map<String, dynamic> json) => _$MatrixDtoFromJson(json);

@override@NumberDecimalConverter() final  Decimal medianUnits;
@override@NumberDecimalConverter() final  Decimal medianMargin;
 final  List<MatrixPointDto> _products;
@override List<MatrixPointDto> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of MatrixDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatrixDtoCopyWith<_MatrixDto> get copyWith => __$MatrixDtoCopyWithImpl<_MatrixDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatrixDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatrixDto&&(identical(other.medianUnits, medianUnits) || other.medianUnits == medianUnits)&&(identical(other.medianMargin, medianMargin) || other.medianMargin == medianMargin)&&const DeepCollectionEquality().equals(other._products, _products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,medianUnits,medianMargin,const DeepCollectionEquality().hash(_products));

@override
String toString() {
  return 'MatrixDto(medianUnits: $medianUnits, medianMargin: $medianMargin, products: $products)';
}


}

/// @nodoc
abstract mixin class _$MatrixDtoCopyWith<$Res> implements $MatrixDtoCopyWith<$Res> {
  factory _$MatrixDtoCopyWith(_MatrixDto value, $Res Function(_MatrixDto) _then) = __$MatrixDtoCopyWithImpl;
@override @useResult
$Res call({
@NumberDecimalConverter() Decimal medianUnits,@NumberDecimalConverter() Decimal medianMargin, List<MatrixPointDto> products
});




}
/// @nodoc
class __$MatrixDtoCopyWithImpl<$Res>
    implements _$MatrixDtoCopyWith<$Res> {
  __$MatrixDtoCopyWithImpl(this._self, this._then);

  final _MatrixDto _self;
  final $Res Function(_MatrixDto) _then;

/// Create a copy of MatrixDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? medianUnits = null,Object? medianMargin = null,Object? products = null,}) {
  return _then(_MatrixDto(
medianUnits: null == medianUnits ? _self.medianUnits : medianUnits // ignore: cast_nullable_to_non_nullable
as Decimal,medianMargin: null == medianMargin ? _self.medianMargin : medianMargin // ignore: cast_nullable_to_non_nullable
as Decimal,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<MatrixPointDto>,
  ));
}


}


/// @nodoc
mixin _$NoMovementItemDto {

 int get productId; String get name; String get unitOfMeasure;@NumberDecimalConverter() Decimal get stock; String? get lastSaleDate;@NumberDecimalConverter() Decimal get immobilizedCapital;
/// Create a copy of NoMovementItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoMovementItemDtoCopyWith<NoMovementItemDto> get copyWith => _$NoMovementItemDtoCopyWithImpl<NoMovementItemDto>(this as NoMovementItemDto, _$identity);

  /// Serializes this NoMovementItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoMovementItemDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitOfMeasure, unitOfMeasure) || other.unitOfMeasure == unitOfMeasure)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.lastSaleDate, lastSaleDate) || other.lastSaleDate == lastSaleDate)&&(identical(other.immobilizedCapital, immobilizedCapital) || other.immobilizedCapital == immobilizedCapital));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unitOfMeasure,stock,lastSaleDate,immobilizedCapital);

@override
String toString() {
  return 'NoMovementItemDto(productId: $productId, name: $name, unitOfMeasure: $unitOfMeasure, stock: $stock, lastSaleDate: $lastSaleDate, immobilizedCapital: $immobilizedCapital)';
}


}

/// @nodoc
abstract mixin class $NoMovementItemDtoCopyWith<$Res>  {
  factory $NoMovementItemDtoCopyWith(NoMovementItemDto value, $Res Function(NoMovementItemDto) _then) = _$NoMovementItemDtoCopyWithImpl;
@useResult
$Res call({
 int productId, String name, String unitOfMeasure,@NumberDecimalConverter() Decimal stock, String? lastSaleDate,@NumberDecimalConverter() Decimal immobilizedCapital
});




}
/// @nodoc
class _$NoMovementItemDtoCopyWithImpl<$Res>
    implements $NoMovementItemDtoCopyWith<$Res> {
  _$NoMovementItemDtoCopyWithImpl(this._self, this._then);

  final NoMovementItemDto _self;
  final $Res Function(NoMovementItemDto) _then;

/// Create a copy of NoMovementItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? name = null,Object? unitOfMeasure = null,Object? stock = null,Object? lastSaleDate = freezed,Object? immobilizedCapital = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasure: null == unitOfMeasure ? _self.unitOfMeasure : unitOfMeasure // ignore: cast_nullable_to_non_nullable
as String,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as Decimal,lastSaleDate: freezed == lastSaleDate ? _self.lastSaleDate : lastSaleDate // ignore: cast_nullable_to_non_nullable
as String?,immobilizedCapital: null == immobilizedCapital ? _self.immobilizedCapital : immobilizedCapital // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [NoMovementItemDto].
extension NoMovementItemDtoPatterns on NoMovementItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoMovementItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoMovementItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoMovementItemDto value)  $default,){
final _that = this;
switch (_that) {
case _NoMovementItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoMovementItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _NoMovementItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String name,  String unitOfMeasure, @NumberDecimalConverter()  Decimal stock,  String? lastSaleDate, @NumberDecimalConverter()  Decimal immobilizedCapital)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoMovementItemDto() when $default != null:
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.stock,_that.lastSaleDate,_that.immobilizedCapital);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String name,  String unitOfMeasure, @NumberDecimalConverter()  Decimal stock,  String? lastSaleDate, @NumberDecimalConverter()  Decimal immobilizedCapital)  $default,) {final _that = this;
switch (_that) {
case _NoMovementItemDto():
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.stock,_that.lastSaleDate,_that.immobilizedCapital);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String name,  String unitOfMeasure, @NumberDecimalConverter()  Decimal stock,  String? lastSaleDate, @NumberDecimalConverter()  Decimal immobilizedCapital)?  $default,) {final _that = this;
switch (_that) {
case _NoMovementItemDto() when $default != null:
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.stock,_that.lastSaleDate,_that.immobilizedCapital);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NoMovementItemDto extends NoMovementItemDto {
  const _NoMovementItemDto({required this.productId, required this.name, required this.unitOfMeasure, @NumberDecimalConverter() required this.stock, this.lastSaleDate, @NumberDecimalConverter() required this.immobilizedCapital}): super._();
  factory _NoMovementItemDto.fromJson(Map<String, dynamic> json) => _$NoMovementItemDtoFromJson(json);

@override final  int productId;
@override final  String name;
@override final  String unitOfMeasure;
@override@NumberDecimalConverter() final  Decimal stock;
@override final  String? lastSaleDate;
@override@NumberDecimalConverter() final  Decimal immobilizedCapital;

/// Create a copy of NoMovementItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoMovementItemDtoCopyWith<_NoMovementItemDto> get copyWith => __$NoMovementItemDtoCopyWithImpl<_NoMovementItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoMovementItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoMovementItemDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitOfMeasure, unitOfMeasure) || other.unitOfMeasure == unitOfMeasure)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.lastSaleDate, lastSaleDate) || other.lastSaleDate == lastSaleDate)&&(identical(other.immobilizedCapital, immobilizedCapital) || other.immobilizedCapital == immobilizedCapital));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unitOfMeasure,stock,lastSaleDate,immobilizedCapital);

@override
String toString() {
  return 'NoMovementItemDto(productId: $productId, name: $name, unitOfMeasure: $unitOfMeasure, stock: $stock, lastSaleDate: $lastSaleDate, immobilizedCapital: $immobilizedCapital)';
}


}

/// @nodoc
abstract mixin class _$NoMovementItemDtoCopyWith<$Res> implements $NoMovementItemDtoCopyWith<$Res> {
  factory _$NoMovementItemDtoCopyWith(_NoMovementItemDto value, $Res Function(_NoMovementItemDto) _then) = __$NoMovementItemDtoCopyWithImpl;
@override @useResult
$Res call({
 int productId, String name, String unitOfMeasure,@NumberDecimalConverter() Decimal stock, String? lastSaleDate,@NumberDecimalConverter() Decimal immobilizedCapital
});




}
/// @nodoc
class __$NoMovementItemDtoCopyWithImpl<$Res>
    implements _$NoMovementItemDtoCopyWith<$Res> {
  __$NoMovementItemDtoCopyWithImpl(this._self, this._then);

  final _NoMovementItemDto _self;
  final $Res Function(_NoMovementItemDto) _then;

/// Create a copy of NoMovementItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? name = null,Object? unitOfMeasure = null,Object? stock = null,Object? lastSaleDate = freezed,Object? immobilizedCapital = null,}) {
  return _then(_NoMovementItemDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasure: null == unitOfMeasure ? _self.unitOfMeasure : unitOfMeasure // ignore: cast_nullable_to_non_nullable
as String,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as Decimal,lastSaleDate: freezed == lastSaleDate ? _self.lastSaleDate : lastSaleDate // ignore: cast_nullable_to_non_nullable
as String?,immobilizedCapital: null == immobilizedCapital ? _self.immobilizedCapital : immobilizedCapital // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$RunningOutItemDto {

 int get productId; String get name; String get unitOfMeasure;@NumberDecimalConverter() Decimal get stock;@NumberDecimalConverter() Decimal get daysLeft;
/// Create a copy of RunningOutItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunningOutItemDtoCopyWith<RunningOutItemDto> get copyWith => _$RunningOutItemDtoCopyWithImpl<RunningOutItemDto>(this as RunningOutItemDto, _$identity);

  /// Serializes this RunningOutItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunningOutItemDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitOfMeasure, unitOfMeasure) || other.unitOfMeasure == unitOfMeasure)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unitOfMeasure,stock,daysLeft);

@override
String toString() {
  return 'RunningOutItemDto(productId: $productId, name: $name, unitOfMeasure: $unitOfMeasure, stock: $stock, daysLeft: $daysLeft)';
}


}

/// @nodoc
abstract mixin class $RunningOutItemDtoCopyWith<$Res>  {
  factory $RunningOutItemDtoCopyWith(RunningOutItemDto value, $Res Function(RunningOutItemDto) _then) = _$RunningOutItemDtoCopyWithImpl;
@useResult
$Res call({
 int productId, String name, String unitOfMeasure,@NumberDecimalConverter() Decimal stock,@NumberDecimalConverter() Decimal daysLeft
});




}
/// @nodoc
class _$RunningOutItemDtoCopyWithImpl<$Res>
    implements $RunningOutItemDtoCopyWith<$Res> {
  _$RunningOutItemDtoCopyWithImpl(this._self, this._then);

  final RunningOutItemDto _self;
  final $Res Function(RunningOutItemDto) _then;

/// Create a copy of RunningOutItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? name = null,Object? unitOfMeasure = null,Object? stock = null,Object? daysLeft = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasure: null == unitOfMeasure ? _self.unitOfMeasure : unitOfMeasure // ignore: cast_nullable_to_non_nullable
as String,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as Decimal,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [RunningOutItemDto].
extension RunningOutItemDtoPatterns on RunningOutItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunningOutItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunningOutItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunningOutItemDto value)  $default,){
final _that = this;
switch (_that) {
case _RunningOutItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunningOutItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _RunningOutItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String name,  String unitOfMeasure, @NumberDecimalConverter()  Decimal stock, @NumberDecimalConverter()  Decimal daysLeft)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunningOutItemDto() when $default != null:
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.stock,_that.daysLeft);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String name,  String unitOfMeasure, @NumberDecimalConverter()  Decimal stock, @NumberDecimalConverter()  Decimal daysLeft)  $default,) {final _that = this;
switch (_that) {
case _RunningOutItemDto():
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.stock,_that.daysLeft);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String name,  String unitOfMeasure, @NumberDecimalConverter()  Decimal stock, @NumberDecimalConverter()  Decimal daysLeft)?  $default,) {final _that = this;
switch (_that) {
case _RunningOutItemDto() when $default != null:
return $default(_that.productId,_that.name,_that.unitOfMeasure,_that.stock,_that.daysLeft);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RunningOutItemDto extends RunningOutItemDto {
  const _RunningOutItemDto({required this.productId, required this.name, required this.unitOfMeasure, @NumberDecimalConverter() required this.stock, @NumberDecimalConverter() required this.daysLeft}): super._();
  factory _RunningOutItemDto.fromJson(Map<String, dynamic> json) => _$RunningOutItemDtoFromJson(json);

@override final  int productId;
@override final  String name;
@override final  String unitOfMeasure;
@override@NumberDecimalConverter() final  Decimal stock;
@override@NumberDecimalConverter() final  Decimal daysLeft;

/// Create a copy of RunningOutItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunningOutItemDtoCopyWith<_RunningOutItemDto> get copyWith => __$RunningOutItemDtoCopyWithImpl<_RunningOutItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunningOutItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunningOutItemDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitOfMeasure, unitOfMeasure) || other.unitOfMeasure == unitOfMeasure)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unitOfMeasure,stock,daysLeft);

@override
String toString() {
  return 'RunningOutItemDto(productId: $productId, name: $name, unitOfMeasure: $unitOfMeasure, stock: $stock, daysLeft: $daysLeft)';
}


}

/// @nodoc
abstract mixin class _$RunningOutItemDtoCopyWith<$Res> implements $RunningOutItemDtoCopyWith<$Res> {
  factory _$RunningOutItemDtoCopyWith(_RunningOutItemDto value, $Res Function(_RunningOutItemDto) _then) = __$RunningOutItemDtoCopyWithImpl;
@override @useResult
$Res call({
 int productId, String name, String unitOfMeasure,@NumberDecimalConverter() Decimal stock,@NumberDecimalConverter() Decimal daysLeft
});




}
/// @nodoc
class __$RunningOutItemDtoCopyWithImpl<$Res>
    implements _$RunningOutItemDtoCopyWith<$Res> {
  __$RunningOutItemDtoCopyWithImpl(this._self, this._then);

  final _RunningOutItemDto _self;
  final $Res Function(_RunningOutItemDto) _then;

/// Create a copy of RunningOutItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? name = null,Object? unitOfMeasure = null,Object? stock = null,Object? daysLeft = null,}) {
  return _then(_RunningOutItemDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasure: null == unitOfMeasure ? _self.unitOfMeasure : unitOfMeasure // ignore: cast_nullable_to_non_nullable
as String,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as Decimal,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$InventoryHealthDto {

@NumberDecimalConverter() Decimal get immobilizedCapitalTotal; List<NoMovementItemDto> get noMovement; List<RunningOutItemDto> get runningOut;
/// Create a copy of InventoryHealthDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryHealthDtoCopyWith<InventoryHealthDto> get copyWith => _$InventoryHealthDtoCopyWithImpl<InventoryHealthDto>(this as InventoryHealthDto, _$identity);

  /// Serializes this InventoryHealthDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryHealthDto&&(identical(other.immobilizedCapitalTotal, immobilizedCapitalTotal) || other.immobilizedCapitalTotal == immobilizedCapitalTotal)&&const DeepCollectionEquality().equals(other.noMovement, noMovement)&&const DeepCollectionEquality().equals(other.runningOut, runningOut));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,immobilizedCapitalTotal,const DeepCollectionEquality().hash(noMovement),const DeepCollectionEquality().hash(runningOut));

@override
String toString() {
  return 'InventoryHealthDto(immobilizedCapitalTotal: $immobilizedCapitalTotal, noMovement: $noMovement, runningOut: $runningOut)';
}


}

/// @nodoc
abstract mixin class $InventoryHealthDtoCopyWith<$Res>  {
  factory $InventoryHealthDtoCopyWith(InventoryHealthDto value, $Res Function(InventoryHealthDto) _then) = _$InventoryHealthDtoCopyWithImpl;
@useResult
$Res call({
@NumberDecimalConverter() Decimal immobilizedCapitalTotal, List<NoMovementItemDto> noMovement, List<RunningOutItemDto> runningOut
});




}
/// @nodoc
class _$InventoryHealthDtoCopyWithImpl<$Res>
    implements $InventoryHealthDtoCopyWith<$Res> {
  _$InventoryHealthDtoCopyWithImpl(this._self, this._then);

  final InventoryHealthDto _self;
  final $Res Function(InventoryHealthDto) _then;

/// Create a copy of InventoryHealthDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? immobilizedCapitalTotal = null,Object? noMovement = null,Object? runningOut = null,}) {
  return _then(_self.copyWith(
immobilizedCapitalTotal: null == immobilizedCapitalTotal ? _self.immobilizedCapitalTotal : immobilizedCapitalTotal // ignore: cast_nullable_to_non_nullable
as Decimal,noMovement: null == noMovement ? _self.noMovement : noMovement // ignore: cast_nullable_to_non_nullable
as List<NoMovementItemDto>,runningOut: null == runningOut ? _self.runningOut : runningOut // ignore: cast_nullable_to_non_nullable
as List<RunningOutItemDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryHealthDto].
extension InventoryHealthDtoPatterns on InventoryHealthDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryHealthDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryHealthDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryHealthDto value)  $default,){
final _that = this;
switch (_that) {
case _InventoryHealthDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryHealthDto value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryHealthDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@NumberDecimalConverter()  Decimal immobilizedCapitalTotal,  List<NoMovementItemDto> noMovement,  List<RunningOutItemDto> runningOut)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryHealthDto() when $default != null:
return $default(_that.immobilizedCapitalTotal,_that.noMovement,_that.runningOut);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@NumberDecimalConverter()  Decimal immobilizedCapitalTotal,  List<NoMovementItemDto> noMovement,  List<RunningOutItemDto> runningOut)  $default,) {final _that = this;
switch (_that) {
case _InventoryHealthDto():
return $default(_that.immobilizedCapitalTotal,_that.noMovement,_that.runningOut);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@NumberDecimalConverter()  Decimal immobilizedCapitalTotal,  List<NoMovementItemDto> noMovement,  List<RunningOutItemDto> runningOut)?  $default,) {final _that = this;
switch (_that) {
case _InventoryHealthDto() when $default != null:
return $default(_that.immobilizedCapitalTotal,_that.noMovement,_that.runningOut);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryHealthDto extends InventoryHealthDto {
  const _InventoryHealthDto({@NumberDecimalConverter() required this.immobilizedCapitalTotal, required final  List<NoMovementItemDto> noMovement, required final  List<RunningOutItemDto> runningOut}): _noMovement = noMovement,_runningOut = runningOut,super._();
  factory _InventoryHealthDto.fromJson(Map<String, dynamic> json) => _$InventoryHealthDtoFromJson(json);

@override@NumberDecimalConverter() final  Decimal immobilizedCapitalTotal;
 final  List<NoMovementItemDto> _noMovement;
@override List<NoMovementItemDto> get noMovement {
  if (_noMovement is EqualUnmodifiableListView) return _noMovement;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_noMovement);
}

 final  List<RunningOutItemDto> _runningOut;
@override List<RunningOutItemDto> get runningOut {
  if (_runningOut is EqualUnmodifiableListView) return _runningOut;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_runningOut);
}


/// Create a copy of InventoryHealthDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryHealthDtoCopyWith<_InventoryHealthDto> get copyWith => __$InventoryHealthDtoCopyWithImpl<_InventoryHealthDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryHealthDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryHealthDto&&(identical(other.immobilizedCapitalTotal, immobilizedCapitalTotal) || other.immobilizedCapitalTotal == immobilizedCapitalTotal)&&const DeepCollectionEquality().equals(other._noMovement, _noMovement)&&const DeepCollectionEquality().equals(other._runningOut, _runningOut));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,immobilizedCapitalTotal,const DeepCollectionEquality().hash(_noMovement),const DeepCollectionEquality().hash(_runningOut));

@override
String toString() {
  return 'InventoryHealthDto(immobilizedCapitalTotal: $immobilizedCapitalTotal, noMovement: $noMovement, runningOut: $runningOut)';
}


}

/// @nodoc
abstract mixin class _$InventoryHealthDtoCopyWith<$Res> implements $InventoryHealthDtoCopyWith<$Res> {
  factory _$InventoryHealthDtoCopyWith(_InventoryHealthDto value, $Res Function(_InventoryHealthDto) _then) = __$InventoryHealthDtoCopyWithImpl;
@override @useResult
$Res call({
@NumberDecimalConverter() Decimal immobilizedCapitalTotal, List<NoMovementItemDto> noMovement, List<RunningOutItemDto> runningOut
});




}
/// @nodoc
class __$InventoryHealthDtoCopyWithImpl<$Res>
    implements _$InventoryHealthDtoCopyWith<$Res> {
  __$InventoryHealthDtoCopyWithImpl(this._self, this._then);

  final _InventoryHealthDto _self;
  final $Res Function(_InventoryHealthDto) _then;

/// Create a copy of InventoryHealthDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? immobilizedCapitalTotal = null,Object? noMovement = null,Object? runningOut = null,}) {
  return _then(_InventoryHealthDto(
immobilizedCapitalTotal: null == immobilizedCapitalTotal ? _self.immobilizedCapitalTotal : immobilizedCapitalTotal // ignore: cast_nullable_to_non_nullable
as Decimal,noMovement: null == noMovement ? _self._noMovement : noMovement // ignore: cast_nullable_to_non_nullable
as List<NoMovementItemDto>,runningOut: null == runningOut ? _self._runningOut : runningOut // ignore: cast_nullable_to_non_nullable
as List<RunningOutItemDto>,
  ));
}


}

// dart format on
