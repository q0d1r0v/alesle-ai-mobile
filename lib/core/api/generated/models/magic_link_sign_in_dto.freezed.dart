// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'magic_link_sign_in_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MagicLinkSignInDto {

/// The token from the emailed link.
 String get token;/// The nonce sent with the magic-link request.
 String get nonce;/// Shown in the device list.
 String? get deviceName;/// App language (BCP-47) for emails.
 String? get locale;
/// Create a copy of MagicLinkSignInDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MagicLinkSignInDtoCopyWith<MagicLinkSignInDto> get copyWith => _$MagicLinkSignInDtoCopyWithImpl<MagicLinkSignInDto>(this as MagicLinkSignInDto, _$identity);

  /// Serializes this MagicLinkSignInDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MagicLinkSignInDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MagicLinkSignInDto&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.nonce, _this.nonce) || other.nonce == _this.nonce)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.locale, _this.locale) || other.locale == _this.locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MagicLinkSignInDto;
  return Object.hash(runtimeType,_this.token,_this.nonce,_this.deviceName,_this.locale);
}

@override
String toString() {
  final _this = this as MagicLinkSignInDto;
  return 'MagicLinkSignInDto(token: ${_this.token}, nonce: ${_this.nonce}, deviceName: ${_this.deviceName}, locale: ${_this.locale})';
}


}

/// @nodoc
abstract mixin class $MagicLinkSignInDtoCopyWith<$Res>  {
  factory $MagicLinkSignInDtoCopyWith(MagicLinkSignInDto value, $Res Function(MagicLinkSignInDto) _then) = _$MagicLinkSignInDtoCopyWithImpl;
@useResult
$Res call({
 String token, String nonce, String? deviceName, String? locale
});




}
/// @nodoc
class _$MagicLinkSignInDtoCopyWithImpl<$Res>
    implements $MagicLinkSignInDtoCopyWith<$Res> {
  _$MagicLinkSignInDtoCopyWithImpl(this._self, this._then);

  final MagicLinkSignInDto _self;
  final $Res Function(MagicLinkSignInDto) _then;

/// Create a copy of MagicLinkSignInDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? nonce = null,Object? deviceName = freezed,Object? locale = freezed,}) {
  return _then(MagicLinkSignInDto(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,nonce: null == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MagicLinkSignInDto].
extension MagicLinkSignInDtoPatterns on MagicLinkSignInDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MagicLinkSignInDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MagicLinkSignInDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MagicLinkSignInDto value)  $default,){
final _that = this;
switch (_that) {
case _MagicLinkSignInDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MagicLinkSignInDto value)?  $default,){
final _that = this;
switch (_that) {
case _MagicLinkSignInDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String nonce,  String? deviceName,  String? locale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MagicLinkSignInDto() when $default != null:
return $default(_that.token,_that.nonce,_that.deviceName,_that.locale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String nonce,  String? deviceName,  String? locale)  $default,) {final _that = this;
switch (_that) {
case _MagicLinkSignInDto():
return $default(_that.token,_that.nonce,_that.deviceName,_that.locale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String nonce,  String? deviceName,  String? locale)?  $default,) {final _that = this;
switch (_that) {
case _MagicLinkSignInDto() when $default != null:
return $default(_that.token,_that.nonce,_that.deviceName,_that.locale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MagicLinkSignInDto implements MagicLinkSignInDto {
  const _MagicLinkSignInDto({required this.token, required this.nonce, this.deviceName, this.locale});
  factory _MagicLinkSignInDto.fromJson(Map<String, dynamic> json) => _$MagicLinkSignInDtoFromJson(json);

/// The token from the emailed link.
@override final  String token;
/// The nonce sent with the magic-link request.
@override final  String nonce;
/// Shown in the device list.
@override final  String? deviceName;
/// App language (BCP-47) for emails.
@override final  String? locale;

/// Create a copy of MagicLinkSignInDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MagicLinkSignInDtoCopyWith<_MagicLinkSignInDto> get copyWith => __$MagicLinkSignInDtoCopyWithImpl<_MagicLinkSignInDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MagicLinkSignInDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MagicLinkSignInDto&&(identical(other.token, token) || other.token == token)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,token,nonce,deviceName,locale);
}

@override
String toString() {
    return 'MagicLinkSignInDto(token: $token, nonce: $nonce, deviceName: $deviceName, locale: $locale)';
}


}

/// @nodoc
abstract mixin class _$MagicLinkSignInDtoCopyWith<$Res> implements $MagicLinkSignInDtoCopyWith<$Res> {
  factory _$MagicLinkSignInDtoCopyWith(_MagicLinkSignInDto value, $Res Function(_MagicLinkSignInDto) _then) = __$MagicLinkSignInDtoCopyWithImpl;
@override @useResult
$Res call({
 String token, String nonce, String? deviceName, String? locale
});




}
/// @nodoc
class __$MagicLinkSignInDtoCopyWithImpl<$Res>
    implements _$MagicLinkSignInDtoCopyWith<$Res> {
  __$MagicLinkSignInDtoCopyWithImpl(this._self, this._then);

  final _MagicLinkSignInDto _self;
  final $Res Function(_MagicLinkSignInDto) _then;

/// Create a copy of MagicLinkSignInDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? nonce = null,Object? deviceName = freezed,Object? locale = freezed,}) {
  return _then(_MagicLinkSignInDto(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,nonce: null == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
