// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginDto {

 String get email; String get password;/// Shown in the device list.
 String? get deviceName;/// App language (BCP-47) for emails.
 String? get locale;
/// Create a copy of LoginDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginDtoCopyWith<LoginDto> get copyWith => _$LoginDtoCopyWithImpl<LoginDto>(this as LoginDto, _$identity);

  /// Serializes this LoginDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoginDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginDto&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.locale, _this.locale) || other.locale == _this.locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoginDto;
  return Object.hash(runtimeType,_this.email,_this.password,_this.deviceName,_this.locale);
}

@override
String toString() {
  final _this = this as LoginDto;
  return 'LoginDto(email: ${_this.email}, password: ${_this.password}, deviceName: ${_this.deviceName}, locale: ${_this.locale})';
}


}

/// @nodoc
abstract mixin class $LoginDtoCopyWith<$Res>  {
  factory $LoginDtoCopyWith(LoginDto value, $Res Function(LoginDto) _then) = _$LoginDtoCopyWithImpl;
@useResult
$Res call({
 String email, String password, String? deviceName, String? locale
});




}
/// @nodoc
class _$LoginDtoCopyWithImpl<$Res>
    implements $LoginDtoCopyWith<$Res> {
  _$LoginDtoCopyWithImpl(this._self, this._then);

  final LoginDto _self;
  final $Res Function(LoginDto) _then;

/// Create a copy of LoginDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? deviceName = freezed,Object? locale = freezed,}) {
  return _then(LoginDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginDto].
extension LoginDtoPatterns on LoginDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginDto value)  $default,){
final _that = this;
switch (_that) {
case _LoginDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginDto value)?  $default,){
final _that = this;
switch (_that) {
case _LoginDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  String? deviceName,  String? locale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginDto() when $default != null:
return $default(_that.email,_that.password,_that.deviceName,_that.locale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  String? deviceName,  String? locale)  $default,) {final _that = this;
switch (_that) {
case _LoginDto():
return $default(_that.email,_that.password,_that.deviceName,_that.locale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  String? deviceName,  String? locale)?  $default,) {final _that = this;
switch (_that) {
case _LoginDto() when $default != null:
return $default(_that.email,_that.password,_that.deviceName,_that.locale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginDto implements LoginDto {
  const _LoginDto({required this.email, required this.password, this.deviceName, this.locale});
  factory _LoginDto.fromJson(Map<String, dynamic> json) => _$LoginDtoFromJson(json);

@override final  String email;
@override final  String password;
/// Shown in the device list.
@override final  String? deviceName;
/// App language (BCP-47) for emails.
@override final  String? locale;

/// Create a copy of LoginDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginDtoCopyWith<_LoginDto> get copyWith => __$LoginDtoCopyWithImpl<_LoginDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,password,deviceName,locale);
}

@override
String toString() {
    return 'LoginDto(email: $email, password: $password, deviceName: $deviceName, locale: $locale)';
}


}

/// @nodoc
abstract mixin class _$LoginDtoCopyWith<$Res> implements $LoginDtoCopyWith<$Res> {
  factory _$LoginDtoCopyWith(_LoginDto value, $Res Function(_LoginDto) _then) = __$LoginDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String? deviceName, String? locale
});




}
/// @nodoc
class __$LoginDtoCopyWithImpl<$Res>
    implements _$LoginDtoCopyWith<$Res> {
  __$LoginDtoCopyWithImpl(this._self, this._then);

  final _LoginDto _self;
  final $Res Function(_LoginDto) _then;

/// Create a copy of LoginDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? deviceName = freezed,Object? locale = freezed,}) {
  return _then(_LoginDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
