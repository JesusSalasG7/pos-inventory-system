// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_movement_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryMovementDto {

 int get id; int get product; String get branch; String get movementType;@DecimalConverter() Decimal get quantity;@DecimalConverter() Decimal get stockBefore;@DecimalConverter() Decimal get stockAfter; int get user; DateTime get createdAt; int? get sale; String get notes;
/// Create a copy of InventoryMovementDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryMovementDtoCopyWith<InventoryMovementDto> get copyWith => _$InventoryMovementDtoCopyWithImpl<InventoryMovementDto>(this as InventoryMovementDto, _$identity);

  /// Serializes this InventoryMovementDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryMovementDto&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.movementType, movementType) || other.movementType == movementType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.stockBefore, stockBefore) || other.stockBefore == stockBefore)&&(identical(other.stockAfter, stockAfter) || other.stockAfter == stockAfter)&&(identical(other.user, user) || other.user == user)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sale, sale) || other.sale == sale)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,product,branch,movementType,quantity,stockBefore,stockAfter,user,createdAt,sale,notes);

@override
String toString() {
  return 'InventoryMovementDto(id: $id, product: $product, branch: $branch, movementType: $movementType, quantity: $quantity, stockBefore: $stockBefore, stockAfter: $stockAfter, user: $user, createdAt: $createdAt, sale: $sale, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $InventoryMovementDtoCopyWith<$Res>  {
  factory $InventoryMovementDtoCopyWith(InventoryMovementDto value, $Res Function(InventoryMovementDto) _then) = _$InventoryMovementDtoCopyWithImpl;
@useResult
$Res call({
 int id, int product, String branch, String movementType,@DecimalConverter() Decimal quantity,@DecimalConverter() Decimal stockBefore,@DecimalConverter() Decimal stockAfter, int user, DateTime createdAt, int? sale, String notes
});




}
/// @nodoc
class _$InventoryMovementDtoCopyWithImpl<$Res>
    implements $InventoryMovementDtoCopyWith<$Res> {
  _$InventoryMovementDtoCopyWithImpl(this._self, this._then);

  final InventoryMovementDto _self;
  final $Res Function(InventoryMovementDto) _then;

/// Create a copy of InventoryMovementDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? product = null,Object? branch = null,Object? movementType = null,Object? quantity = null,Object? stockBefore = null,Object? stockAfter = null,Object? user = null,Object? createdAt = null,Object? sale = freezed,Object? notes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,movementType: null == movementType ? _self.movementType : movementType // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,stockBefore: null == stockBefore ? _self.stockBefore : stockBefore // ignore: cast_nullable_to_non_nullable
as Decimal,stockAfter: null == stockAfter ? _self.stockAfter : stockAfter // ignore: cast_nullable_to_non_nullable
as Decimal,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sale: freezed == sale ? _self.sale : sale // ignore: cast_nullable_to_non_nullable
as int?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryMovementDto].
extension InventoryMovementDtoPatterns on InventoryMovementDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryMovementDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryMovementDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryMovementDto value)  $default,){
final _that = this;
switch (_that) {
case _InventoryMovementDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryMovementDto value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryMovementDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int product,  String branch,  String movementType, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal stockBefore, @DecimalConverter()  Decimal stockAfter,  int user,  DateTime createdAt,  int? sale,  String notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryMovementDto() when $default != null:
return $default(_that.id,_that.product,_that.branch,_that.movementType,_that.quantity,_that.stockBefore,_that.stockAfter,_that.user,_that.createdAt,_that.sale,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int product,  String branch,  String movementType, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal stockBefore, @DecimalConverter()  Decimal stockAfter,  int user,  DateTime createdAt,  int? sale,  String notes)  $default,) {final _that = this;
switch (_that) {
case _InventoryMovementDto():
return $default(_that.id,_that.product,_that.branch,_that.movementType,_that.quantity,_that.stockBefore,_that.stockAfter,_that.user,_that.createdAt,_that.sale,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int product,  String branch,  String movementType, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal stockBefore, @DecimalConverter()  Decimal stockAfter,  int user,  DateTime createdAt,  int? sale,  String notes)?  $default,) {final _that = this;
switch (_that) {
case _InventoryMovementDto() when $default != null:
return $default(_that.id,_that.product,_that.branch,_that.movementType,_that.quantity,_that.stockBefore,_that.stockAfter,_that.user,_that.createdAt,_that.sale,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryMovementDto extends InventoryMovementDto {
  const _InventoryMovementDto({required this.id, required this.product, required this.branch, required this.movementType, @DecimalConverter() required this.quantity, @DecimalConverter() required this.stockBefore, @DecimalConverter() required this.stockAfter, required this.user, required this.createdAt, this.sale, this.notes = ''}): super._();
  factory _InventoryMovementDto.fromJson(Map<String, dynamic> json) => _$InventoryMovementDtoFromJson(json);

@override final  int id;
@override final  int product;
@override final  String branch;
@override final  String movementType;
@override@DecimalConverter() final  Decimal quantity;
@override@DecimalConverter() final  Decimal stockBefore;
@override@DecimalConverter() final  Decimal stockAfter;
@override final  int user;
@override final  DateTime createdAt;
@override final  int? sale;
@override@JsonKey() final  String notes;

/// Create a copy of InventoryMovementDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryMovementDtoCopyWith<_InventoryMovementDto> get copyWith => __$InventoryMovementDtoCopyWithImpl<_InventoryMovementDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryMovementDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryMovementDto&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.movementType, movementType) || other.movementType == movementType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.stockBefore, stockBefore) || other.stockBefore == stockBefore)&&(identical(other.stockAfter, stockAfter) || other.stockAfter == stockAfter)&&(identical(other.user, user) || other.user == user)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sale, sale) || other.sale == sale)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,product,branch,movementType,quantity,stockBefore,stockAfter,user,createdAt,sale,notes);

@override
String toString() {
  return 'InventoryMovementDto(id: $id, product: $product, branch: $branch, movementType: $movementType, quantity: $quantity, stockBefore: $stockBefore, stockAfter: $stockAfter, user: $user, createdAt: $createdAt, sale: $sale, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$InventoryMovementDtoCopyWith<$Res> implements $InventoryMovementDtoCopyWith<$Res> {
  factory _$InventoryMovementDtoCopyWith(_InventoryMovementDto value, $Res Function(_InventoryMovementDto) _then) = __$InventoryMovementDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int product, String branch, String movementType,@DecimalConverter() Decimal quantity,@DecimalConverter() Decimal stockBefore,@DecimalConverter() Decimal stockAfter, int user, DateTime createdAt, int? sale, String notes
});




}
/// @nodoc
class __$InventoryMovementDtoCopyWithImpl<$Res>
    implements _$InventoryMovementDtoCopyWith<$Res> {
  __$InventoryMovementDtoCopyWithImpl(this._self, this._then);

  final _InventoryMovementDto _self;
  final $Res Function(_InventoryMovementDto) _then;

/// Create a copy of InventoryMovementDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? product = null,Object? branch = null,Object? movementType = null,Object? quantity = null,Object? stockBefore = null,Object? stockAfter = null,Object? user = null,Object? createdAt = null,Object? sale = freezed,Object? notes = null,}) {
  return _then(_InventoryMovementDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,movementType: null == movementType ? _self.movementType : movementType // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,stockBefore: null == stockBefore ? _self.stockBefore : stockBefore // ignore: cast_nullable_to_non_nullable
as Decimal,stockAfter: null == stockAfter ? _self.stockAfter : stockAfter // ignore: cast_nullable_to_non_nullable
as Decimal,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sale: freezed == sale ? _self.sale : sale // ignore: cast_nullable_to_non_nullable
as int?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
