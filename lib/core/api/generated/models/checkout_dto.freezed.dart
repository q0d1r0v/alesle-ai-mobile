// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckoutDto {

 String get product; PaymentProviderName get provider; String get language;
/// Create a copy of CheckoutDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutDtoCopyWith<CheckoutDto> get copyWith => _$CheckoutDtoCopyWithImpl<CheckoutDto>(this as CheckoutDto, _$identity);

  /// Serializes this CheckoutDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckoutDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutDto&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.language, _this.language) || other.language == _this.language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckoutDto;
  return Object.hash(runtimeType,_this.product,_this.provider,_this.language);
}

@override
String toString() {
  final _this = this as CheckoutDto;
  return 'CheckoutDto(product: ${_this.product}, provider: ${_this.provider}, language: ${_this.language})';
}


}

/// @nodoc
abstract mixin class $CheckoutDtoCopyWith<$Res>  {
  factory $CheckoutDtoCopyWith(CheckoutDto value, $Res Function(CheckoutDto) _then) = _$CheckoutDtoCopyWithImpl;
@useResult
$Res call({
 String product, PaymentProviderName provider, String language
});




}
/// @nodoc
class _$CheckoutDtoCopyWithImpl<$Res>
    implements $CheckoutDtoCopyWith<$Res> {
  _$CheckoutDtoCopyWithImpl(this._self, this._then);

  final CheckoutDto _self;
  final $Res Function(CheckoutDto) _then;

/// Create a copy of CheckoutDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = null,Object? provider = null,Object? language = null,}) {
  return _then(CheckoutDto(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as PaymentProviderName,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutDto].
extension CheckoutDtoPatterns on CheckoutDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutDto value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutDto value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String product,  PaymentProviderName provider,  String language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutDto() when $default != null:
return $default(_that.product,_that.provider,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String product,  PaymentProviderName provider,  String language)  $default,) {final _that = this;
switch (_that) {
case _CheckoutDto():
return $default(_that.product,_that.provider,_that.language);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String product,  PaymentProviderName provider,  String language)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutDto() when $default != null:
return $default(_that.product,_that.provider,_that.language);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutDto implements CheckoutDto {
  const _CheckoutDto({required this.product, required this.provider, required this.language});
  factory _CheckoutDto.fromJson(Map<String, dynamic> json) => _$CheckoutDtoFromJson(json);

@override final  String product;
@override final  PaymentProviderName provider;
@override final  String language;

/// Create a copy of CheckoutDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutDtoCopyWith<_CheckoutDto> get copyWith => __$CheckoutDtoCopyWithImpl<_CheckoutDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutDto&&(identical(other.product, product) || other.product == product)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,product,provider,language);
}

@override
String toString() {
    return 'CheckoutDto(product: $product, provider: $provider, language: $language)';
}


}

/// @nodoc
abstract mixin class _$CheckoutDtoCopyWith<$Res> implements $CheckoutDtoCopyWith<$Res> {
  factory _$CheckoutDtoCopyWith(_CheckoutDto value, $Res Function(_CheckoutDto) _then) = __$CheckoutDtoCopyWithImpl;
@override @useResult
$Res call({
 String product, PaymentProviderName provider, String language
});




}
/// @nodoc
class __$CheckoutDtoCopyWithImpl<$Res>
    implements _$CheckoutDtoCopyWith<$Res> {
  __$CheckoutDtoCopyWithImpl(this._self, this._then);

  final _CheckoutDto _self;
  final $Res Function(_CheckoutDto) _then;

/// Create a copy of CheckoutDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = null,Object? provider = null,Object? language = null,}) {
  return _then(_CheckoutDto(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as PaymentProviderName,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
