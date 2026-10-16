// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'google_sign_in_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoogleSignInDto {

/// ID token from Android Credential Manager.
 String get idToken;/// Shown in the device list.
 String? get deviceName;/// App language (BCP-47) for emails.
 String? get locale;
/// Create a copy of GoogleSignInDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoogleSignInDtoCopyWith<GoogleSignInDto> get copyWith => _$GoogleSignInDtoCopyWithImpl<GoogleSignInDto>(this as GoogleSignInDto, _$identity);

  /// Serializes this GoogleSignInDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GoogleSignInDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoogleSignInDto&&(identical(other.idToken, _this.idToken) || other.idToken == _this.idToken)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.locale, _this.locale) || other.locale == _this.locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoogleSignInDto;
  return Object.hash(runtimeType,_this.idToken,_this.deviceName,_this.locale);
}

@override
String toString() {
  final _this = this as GoogleSignInDto;
  return 'GoogleSignInDto(idToken: ${_this.idToken}, deviceName: ${_this.deviceName}, locale: ${_this.locale})';
}


}

/// @nodoc
abstract mixin class $GoogleSignInDtoCopyWith<$Res>  {
  factory $GoogleSignInDtoCopyWith(GoogleSignInDto value, $Res Function(GoogleSignInDto) _then) = _$GoogleSignInDtoCopyWithImpl;
@useResult
$Res call({
 String idToken, String? deviceName, String? locale
});




}
/// @nodoc
class _$GoogleSignInDtoCopyWithImpl<$Res>
    implements $GoogleSignInDtoCopyWith<$Res> {
  _$GoogleSignInDtoCopyWithImpl(this._self, this._then);

  final GoogleSignInDto _self;
  final $Res Function(GoogleSignInDto) _then;

/// Create a copy of GoogleSignInDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idToken = null,Object? deviceName = freezed,Object? locale = freezed,}) {
  return _then(GoogleSignInDto(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoogleSignInDto].
extension GoogleSignInDtoPatterns on GoogleSignInDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoogleSignInDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoogleSignInDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoogleSignInDto value)  $default,){
final _that = this;
switch (_that) {
case _GoogleSignInDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoogleSignInDto value)?  $default,){
final _that = this;
switch (_that) {
case _GoogleSignInDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String idToken,  String? deviceName,  String? locale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoogleSignInDto() when $default != null:
return $default(_that.idToken,_that.deviceName,_that.locale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String idToken,  String? deviceName,  String? locale)  $default,) {final _that = this;
switch (_that) {
case _GoogleSignInDto():
return $default(_that.idToken,_that.deviceName,_that.locale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String idToken,  String? deviceName,  String? locale)?  $default,) {final _that = this;
switch (_that) {
case _GoogleSignInDto() when $default != null:
return $default(_that.idToken,_that.deviceName,_that.locale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoogleSignInDto implements GoogleSignInDto {
  const _GoogleSignInDto({required this.idToken, this.deviceName, this.locale});
  factory _GoogleSignInDto.fromJson(Map<String, dynamic> json) => _$GoogleSignInDtoFromJson(json);

/// ID token from Android Credential Manager.
@override final  String idToken;
/// Shown in the device list.
@override final  String? deviceName;
/// App language (BCP-47) for emails.
@override final  String? locale;

/// Create a copy of GoogleSignInDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoogleSignInDtoCopyWith<_GoogleSignInDto> get copyWith => __$GoogleSignInDtoCopyWithImpl<_GoogleSignInDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoogleSignInDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoogleSignInDto&&(identical(other.idToken, idToken) || other.idToken == idToken)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,idToken,deviceName,locale);
}

@override
String toString() {
    return 'GoogleSignInDto(idToken: $idToken, deviceName: $deviceName, locale: $locale)';
}


}

/// @nodoc
abstract mixin class _$GoogleSignInDtoCopyWith<$Res> implements $GoogleSignInDtoCopyWith<$Res> {
  factory _$GoogleSignInDtoCopyWith(_GoogleSignInDto value, $Res Function(_GoogleSignInDto) _then) = __$GoogleSignInDtoCopyWithImpl;
@override @useResult
$Res call({
 String idToken, String? deviceName, String? locale
});




}
/// @nodoc
class __$GoogleSignInDtoCopyWithImpl<$Res>
    implements _$GoogleSignInDtoCopyWith<$Res> {
  __$GoogleSignInDtoCopyWithImpl(this._self, this._then);

  final _GoogleSignInDto _self;
  final $Res Function(_GoogleSignInDto) _then;

/// Create a copy of GoogleSignInDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idToken = null,Object? deviceName = freezed,Object? locale = freezed,}) {
  return _then(_GoogleSignInDto(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
