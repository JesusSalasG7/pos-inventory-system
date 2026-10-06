// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductDto {

 int get id; String get name; String get category; String get unitOfMeasure;@DecimalConverter() Decimal get costPriceUsd;@DecimalConverter() Decimal get salePriceUsd; bool get active;
/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductDtoCopyWith<ProductDto> get copyWith => _$ProductDtoCopyWithImpl<ProductDto>(this as ProductDto, _$identity);

  /// Serializes this ProductDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.unitOfMeasure, unitOfMeasure) || other.unitOfMeasure == unitOfMeasure)&&(identical(other.costPriceUsd, costPriceUsd) || other.costPriceUsd == costPriceUsd)&&(identical(other.salePriceUsd, salePriceUsd) || other.salePriceUsd == salePriceUsd)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,unitOfMeasure,costPriceUsd,salePriceUsd,active);

@override
String toString() {
  return 'ProductDto(id: $id, name: $name, category: $category, unitOfMeasure: $unitOfMeasure, costPriceUsd: $costPriceUsd, salePriceUsd: $salePriceUsd, active: $active)';
}


}

/// @nodoc
abstract mixin class $ProductDtoCopyWith<$Res>  {
  factory $ProductDtoCopyWith(ProductDto value, $Res Function(ProductDto) _then) = _$ProductDtoCopyWithImpl;
@useResult
$Res call({
 int id, String name, String category, String unitOfMeasure,@DecimalConverter() Decimal costPriceUsd,@DecimalConverter() Decimal salePriceUsd, bool active
});




}
/// @nodoc
class _$ProductDtoCopyWithImpl<$Res>
    implements $ProductDtoCopyWith<$Res> {
  _$ProductDtoCopyWithImpl(this._self, this._then);

  final ProductDto _self;
  final $Res Function(ProductDto) _then;

/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? unitOfMeasure = null,Object? costPriceUsd = null,Object? salePriceUsd = null,Object? active = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasure: null == unitOfMeasure ? _self.unitOfMeasure : unitOfMeasure // ignore: cast_nullable_to_non_nullable
as String,costPriceUsd: null == costPriceUsd ? _self.costPriceUsd : costPriceUsd // ignore: cast_nullable_to_non_nullable
as Decimal,salePriceUsd: null == salePriceUsd ? _self.salePriceUsd : salePriceUsd // ignore: cast_nullable_to_non_nullable
as Decimal,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductDto].
extension ProductDtoPatterns on ProductDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String category,  String unitOfMeasure, @DecimalConverter()  Decimal costPriceUsd, @DecimalConverter()  Decimal salePriceUsd,  bool active)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.unitOfMeasure,_that.costPriceUsd,_that.salePriceUsd,_that.active);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String category,  String unitOfMeasure, @DecimalConverter()  Decimal costPriceUsd, @DecimalConverter()  Decimal salePriceUsd,  bool active)  $default,) {final _that = this;
switch (_that) {
case _ProductDto():
return $default(_that.id,_that.name,_that.category,_that.unitOfMeasure,_that.costPriceUsd,_that.salePriceUsd,_that.active);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String category,  String unitOfMeasure, @DecimalConverter()  Decimal costPriceUsd, @DecimalConverter()  Decimal salePriceUsd,  bool active)?  $default,) {final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.unitOfMeasure,_that.costPriceUsd,_that.salePriceUsd,_that.active);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductDto extends ProductDto {
  const _ProductDto({required this.id, required this.name, required this.category, required this.unitOfMeasure, @DecimalConverter() required this.costPriceUsd, @DecimalConverter() required this.salePriceUsd, required this.active}): super._();
  factory _ProductDto.fromJson(Map<String, dynamic> json) => _$ProductDtoFromJson(json);

@override final  int id;
@override final  String name;
@override final  String category;
@override final  String unitOfMeasure;
@override@DecimalConverter() final  Decimal costPriceUsd;
@override@DecimalConverter() final  Decimal salePriceUsd;
@override final  bool active;

/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductDtoCopyWith<_ProductDto> get copyWith => __$ProductDtoCopyWithImpl<_ProductDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.unitOfMeasure, unitOfMeasure) || other.unitOfMeasure == unitOfMeasure)&&(identical(other.costPriceUsd, costPriceUsd) || other.costPriceUsd == costPriceUsd)&&(identical(other.salePriceUsd, salePriceUsd) || other.salePriceUsd == salePriceUsd)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,unitOfMeasure,costPriceUsd,salePriceUsd,active);

@override
String toString() {
  return 'ProductDto(id: $id, name: $name, category: $category, unitOfMeasure: $unitOfMeasure, costPriceUsd: $costPriceUsd, salePriceUsd: $salePriceUsd, active: $active)';
}


}

/// @nodoc
abstract mixin class _$ProductDtoCopyWith<$Res> implements $ProductDtoCopyWith<$Res> {
  factory _$ProductDtoCopyWith(_ProductDto value, $Res Function(_ProductDto) _then) = __$ProductDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String category, String unitOfMeasure,@DecimalConverter() Decimal costPriceUsd,@DecimalConverter() Decimal salePriceUsd, bool active
});




}
/// @nodoc
class __$ProductDtoCopyWithImpl<$Res>
    implements _$ProductDtoCopyWith<$Res> {
  __$ProductDtoCopyWithImpl(this._self, this._then);

  final _ProductDto _self;
  final $Res Function(_ProductDto) _then;

/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? unitOfMeasure = null,Object? costPriceUsd = null,Object? salePriceUsd = null,Object? active = null,}) {
  return _then(_ProductDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasure: null == unitOfMeasure ? _self.unitOfMeasure : unitOfMeasure // ignore: cast_nullable_to_non_nullable
as String,costPriceUsd: null == costPriceUsd ? _self.costPriceUsd : costPriceUsd // ignore: cast_nullable_to_non_nullable
as Decimal,salePriceUsd: null == salePriceUsd ? _self.salePriceUsd : salePriceUsd // ignore: cast_nullable_to_non_nullable
as Decimal,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$BranchStockDto {

 int get id; int get product; String get productName; String get branch;@DecimalConverter() Decimal get currentStock;@DecimalConverter() Decimal get minimumStock;
/// Create a copy of BranchStockDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchStockDtoCopyWith<BranchStockDto> get copyWith => _$BranchStockDtoCopyWithImpl<BranchStockDto>(this as BranchStockDto, _$identity);

  /// Serializes this BranchStockDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchStockDto&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.currentStock, currentStock) || other.currentStock == currentStock)&&(identical(other.minimumStock, minimumStock) || other.minimumStock == minimumStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,product,productName,branch,currentStock,minimumStock);

@override
String toString() {
  return 'BranchStockDto(id: $id, product: $product, productName: $productName, branch: $branch, currentStock: $currentStock, minimumStock: $minimumStock)';
}


}

/// @nodoc
abstract mixin class $BranchStockDtoCopyWith<$Res>  {
  factory $BranchStockDtoCopyWith(BranchStockDto value, $Res Function(BranchStockDto) _then) = _$BranchStockDtoCopyWithImpl;
@useResult
$Res call({
 int id, int product, String productName, String branch,@DecimalConverter() Decimal currentStock,@DecimalConverter() Decimal minimumStock
});




}
/// @nodoc
class _$BranchStockDtoCopyWithImpl<$Res>
    implements $BranchStockDtoCopyWith<$Res> {
  _$BranchStockDtoCopyWithImpl(this._self, this._then);

  final BranchStockDto _self;
  final $Res Function(BranchStockDto) _then;

/// Create a copy of BranchStockDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? product = null,Object? productName = null,Object? branch = null,Object? currentStock = null,Object? minimumStock = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,currentStock: null == currentStock ? _self.currentStock : currentStock // ignore: cast_nullable_to_non_nullable
as Decimal,minimumStock: null == minimumStock ? _self.minimumStock : minimumStock // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [BranchStockDto].
extension BranchStockDtoPatterns on BranchStockDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BranchStockDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BranchStockDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BranchStockDto value)  $default,){
final _that = this;
switch (_that) {
case _BranchStockDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BranchStockDto value)?  $default,){
final _that = this;
switch (_that) {
case _BranchStockDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int product,  String productName,  String branch, @DecimalConverter()  Decimal currentStock, @DecimalConverter()  Decimal minimumStock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BranchStockDto() when $default != null:
return $default(_that.id,_that.product,_that.productName,_that.branch,_that.currentStock,_that.minimumStock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int product,  String productName,  String branch, @DecimalConverter()  Decimal currentStock, @DecimalConverter()  Decimal minimumStock)  $default,) {final _that = this;
switch (_that) {
case _BranchStockDto():
return $default(_that.id,_that.product,_that.productName,_that.branch,_that.currentStock,_that.minimumStock);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int product,  String productName,  String branch, @DecimalConverter()  Decimal currentStock, @DecimalConverter()  Decimal minimumStock)?  $default,) {final _that = this;
switch (_that) {
case _BranchStockDto() when $default != null:
return $default(_that.id,_that.product,_that.productName,_that.branch,_that.currentStock,_that.minimumStock);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BranchStockDto extends BranchStockDto {
  const _BranchStockDto({required this.id, required this.product, required this.productName, required this.branch, @DecimalConverter() required this.currentStock, @DecimalConverter() required this.minimumStock}): super._();
  factory _BranchStockDto.fromJson(Map<String, dynamic> json) => _$BranchStockDtoFromJson(json);

@override final  int id;
@override final  int product;
@override final  String productName;
@override final  String branch;
@override@DecimalConverter() final  Decimal currentStock;
@override@DecimalConverter() final  Decimal minimumStock;

/// Create a copy of BranchStockDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchStockDtoCopyWith<_BranchStockDto> get copyWith => __$BranchStockDtoCopyWithImpl<_BranchStockDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BranchStockDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BranchStockDto&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.currentStock, currentStock) || other.currentStock == currentStock)&&(identical(other.minimumStock, minimumStock) || other.minimumStock == minimumStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,product,productName,branch,currentStock,minimumStock);

@override
String toString() {
  return 'BranchStockDto(id: $id, product: $product, productName: $productName, branch: $branch, currentStock: $currentStock, minimumStock: $minimumStock)';
}


}

/// @nodoc
abstract mixin class _$BranchStockDtoCopyWith<$Res> implements $BranchStockDtoCopyWith<$Res> {
  factory _$BranchStockDtoCopyWith(_BranchStockDto value, $Res Function(_BranchStockDto) _then) = __$BranchStockDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int product, String productName, String branch,@DecimalConverter() Decimal currentStock,@DecimalConverter() Decimal minimumStock
});




}
/// @nodoc
class __$BranchStockDtoCopyWithImpl<$Res>
    implements _$BranchStockDtoCopyWith<$Res> {
  __$BranchStockDtoCopyWithImpl(this._self, this._then);

  final _BranchStockDto _self;
  final $Res Function(_BranchStockDto) _then;

/// Create a copy of BranchStockDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? product = null,Object? productName = null,Object? branch = null,Object? currentStock = null,Object? minimumStock = null,}) {
  return _then(_BranchStockDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,currentStock: null == currentStock ? _self.currentStock : currentStock // ignore: cast_nullable_to_non_nullable
as Decimal,minimumStock: null == minimumStock ? _self.minimumStock : minimumStock // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

// dart format on
