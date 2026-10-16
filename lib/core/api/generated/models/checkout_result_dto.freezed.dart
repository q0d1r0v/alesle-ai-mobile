// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_result_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckoutResultDto {

 String get paymentId;/// The provider’s page, to open in Custom Tabs.
 String get url;
/// Create a copy of CheckoutResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutResultDtoCopyWith<CheckoutResultDto> get copyWith => _$CheckoutResultDtoCopyWithImpl<CheckoutResultDto>(this as CheckoutResultDto, _$identity);

  /// Serializes this CheckoutResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckoutResultDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutResultDto&&(identical(other.paymentId, _this.paymentId) || other.paymentId == _this.paymentId)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckoutResultDto;
  return Object.hash(runtimeType,_this.paymentId,_this.url);
}

@override
String toString() {
  final _this = this as CheckoutResultDto;
  return 'CheckoutResultDto(paymentId: ${_this.paymentId}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $CheckoutResultDtoCopyWith<$Res>  {
  factory $CheckoutResultDtoCopyWith(CheckoutResultDto value, $Res Function(CheckoutResultDto) _then) = _$CheckoutResultDtoCopyWithImpl;
@useResult
$Res call({
 String paymentId, String url
});




}
/// @nodoc
class _$CheckoutResultDtoCopyWithImpl<$Res>
    implements $CheckoutResultDtoCopyWith<$Res> {
  _$CheckoutResultDtoCopyWithImpl(this._self, this._then);

  final CheckoutResultDto _self;
  final $Res Function(CheckoutResultDto) _then;

/// Create a copy of CheckoutResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentId = null,Object? url = null,}) {
  return _then(CheckoutResultDto(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutResultDto].
extension CheckoutResultDtoPatterns on CheckoutResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutResultDto value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String paymentId,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutResultDto() when $default != null:
return $default(_that.paymentId,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String paymentId,  String url)  $default,) {final _that = this;
switch (_that) {
case _CheckoutResultDto():
return $default(_that.paymentId,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String paymentId,  String url)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutResultDto() when $default != null:
return $default(_that.paymentId,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutResultDto implements CheckoutResultDto {
  const _CheckoutResultDto({required this.paymentId, required this.url});
  factory _CheckoutResultDto.fromJson(Map<String, dynamic> json) => _$CheckoutResultDtoFromJson(json);

@override final  String paymentId;
/// The provider’s page, to open in Custom Tabs.
@override final  String url;

/// Create a copy of CheckoutResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutResultDtoCopyWith<_CheckoutResultDto> get copyWith => __$CheckoutResultDtoCopyWithImpl<_CheckoutResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutResultDto&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,paymentId,url);
}

@override
String toString() {
    return 'CheckoutResultDto(paymentId: $paymentId, url: $url)';
}


}

/// @nodoc
abstract mixin class _$CheckoutResultDtoCopyWith<$Res> implements $CheckoutResultDtoCopyWith<$Res> {
  factory _$CheckoutResultDtoCopyWith(_CheckoutResultDto value, $Res Function(_CheckoutResultDto) _then) = __$CheckoutResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String paymentId, String url
});




}
/// @nodoc
class __$CheckoutResultDtoCopyWithImpl<$Res>
    implements _$CheckoutResultDtoCopyWith<$Res> {
  __$CheckoutResultDtoCopyWithImpl(this._self, this._then);

  final _CheckoutResultDto _self;
  final $Res Function(_CheckoutResultDto) _then;

/// Create a copy of CheckoutResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentId = null,Object? url = null,}) {
  return _then(_CheckoutResultDto(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
