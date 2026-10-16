// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterDto {

 String get email; String get password;/// Shown in the device list.
 String? get deviceName;/// App language (BCP-47) for emails.
 String? get locale; String? get displayName;
/// Create a copy of RegisterDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterDtoCopyWith<RegisterDto> get copyWith => _$RegisterDtoCopyWithImpl<RegisterDto>(this as RegisterDto, _$identity);

  /// Serializes this RegisterDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RegisterDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterDto&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RegisterDto;
  return Object.hash(runtimeType,_this.email,_this.password,_this.deviceName,_this.locale,_this.displayName);
}

@override
String toString() {
  final _this = this as RegisterDto;
  return 'RegisterDto(email: ${_this.email}, password: ${_this.password}, deviceName: ${_this.deviceName}, locale: ${_this.locale}, displayName: ${_this.displayName})';
}


}

/// @nodoc
abstract mixin class $RegisterDtoCopyWith<$Res>  {
  factory $RegisterDtoCopyWith(RegisterDto value, $Res Function(RegisterDto) _then) = _$RegisterDtoCopyWithImpl;
@useResult
$Res call({
 String email, String password, String? deviceName, String? locale, String? displayName
});




}
/// @nodoc
class _$RegisterDtoCopyWithImpl<$Res>
    implements $RegisterDtoCopyWith<$Res> {
  _$RegisterDtoCopyWithImpl(this._self, this._then);

  final RegisterDto _self;
  final $Res Function(RegisterDto) _then;

/// Create a copy of RegisterDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? deviceName = freezed,Object? locale = freezed,Object? displayName = freezed,}) {
  return _then(RegisterDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterDto].
extension RegisterDtoPatterns on RegisterDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterDto value)  $default,){
final _that = this;
switch (_that) {
case _RegisterDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterDto value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  String? deviceName,  String? locale,  String? displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterDto() when $default != null:
return $default(_that.email,_that.password,_that.deviceName,_that.locale,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  String? deviceName,  String? locale,  String? displayName)  $default,) {final _that = this;
switch (_that) {
case _RegisterDto():
return $default(_that.email,_that.password,_that.deviceName,_that.locale,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  String? deviceName,  String? locale,  String? displayName)?  $default,) {final _that = this;
switch (_that) {
case _RegisterDto() when $default != null:
return $default(_that.email,_that.password,_that.deviceName,_that.locale,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterDto implements RegisterDto {
  const _RegisterDto({required this.email, required this.password, this.deviceName, this.locale, this.displayName});
  factory _RegisterDto.fromJson(Map<String, dynamic> json) => _$RegisterDtoFromJson(json);

@override final  String email;
@override final  String password;
/// Shown in the device list.
@override final  String? deviceName;
/// App language (BCP-47) for emails.
@override final  String? locale;
@override final  String? displayName;

/// Create a copy of RegisterDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterDtoCopyWith<_RegisterDto> get copyWith => __$RegisterDtoCopyWithImpl<_RegisterDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,password,deviceName,locale,displayName);
}

@override
String toString() {
    return 'RegisterDto(email: $email, password: $password, deviceName: $deviceName, locale: $locale, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$RegisterDtoCopyWith<$Res> implements $RegisterDtoCopyWith<$Res> {
  factory _$RegisterDtoCopyWith(_RegisterDto value, $Res Function(_RegisterDto) _then) = __$RegisterDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String? deviceName, String? locale, String? displayName
});




}
/// @nodoc
class __$RegisterDtoCopyWithImpl<$Res>
    implements _$RegisterDtoCopyWith<$Res> {
  __$RegisterDtoCopyWithImpl(this._self, this._then);

  final _RegisterDto _self;
  final $Res Function(_RegisterDto) _then;

/// Create a copy of RegisterDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? deviceName = freezed,Object? locale = freezed,Object? displayName = freezed,}) {
  return _then(_RegisterDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
