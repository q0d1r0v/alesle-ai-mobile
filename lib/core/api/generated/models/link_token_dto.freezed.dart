// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_token_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LinkTokenDto {

/// The token from the emailed link.
 String get token;/// Shown in the device list.
 String? get deviceName;/// App language (BCP-47) for emails.
 String? get locale;
/// Create a copy of LinkTokenDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkTokenDtoCopyWith<LinkTokenDto> get copyWith => _$LinkTokenDtoCopyWithImpl<LinkTokenDto>(this as LinkTokenDto, _$identity);

  /// Serializes this LinkTokenDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LinkTokenDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkTokenDto&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.locale, _this.locale) || other.locale == _this.locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LinkTokenDto;
  return Object.hash(runtimeType,_this.token,_this.deviceName,_this.locale);
}

@override
String toString() {
  final _this = this as LinkTokenDto;
  return 'LinkTokenDto(token: ${_this.token}, deviceName: ${_this.deviceName}, locale: ${_this.locale})';
}


}

/// @nodoc
abstract mixin class $LinkTokenDtoCopyWith<$Res>  {
  factory $LinkTokenDtoCopyWith(LinkTokenDto value, $Res Function(LinkTokenDto) _then) = _$LinkTokenDtoCopyWithImpl;
@useResult
$Res call({
 String token, String? deviceName, String? locale
});




}
/// @nodoc
class _$LinkTokenDtoCopyWithImpl<$Res>
    implements $LinkTokenDtoCopyWith<$Res> {
  _$LinkTokenDtoCopyWithImpl(this._self, this._then);

  final LinkTokenDto _self;
  final $Res Function(LinkTokenDto) _then;

/// Create a copy of LinkTokenDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? deviceName = freezed,Object? locale = freezed,}) {
  return _then(LinkTokenDto(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkTokenDto].
extension LinkTokenDtoPatterns on LinkTokenDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkTokenDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkTokenDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkTokenDto value)  $default,){
final _that = this;
switch (_that) {
case _LinkTokenDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkTokenDto value)?  $default,){
final _that = this;
switch (_that) {
case _LinkTokenDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String? deviceName,  String? locale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkTokenDto() when $default != null:
return $default(_that.token,_that.deviceName,_that.locale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String? deviceName,  String? locale)  $default,) {final _that = this;
switch (_that) {
case _LinkTokenDto():
return $default(_that.token,_that.deviceName,_that.locale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String? deviceName,  String? locale)?  $default,) {final _that = this;
switch (_that) {
case _LinkTokenDto() when $default != null:
return $default(_that.token,_that.deviceName,_that.locale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LinkTokenDto implements LinkTokenDto {
  const _LinkTokenDto({required this.token, this.deviceName, this.locale});
  factory _LinkTokenDto.fromJson(Map<String, dynamic> json) => _$LinkTokenDtoFromJson(json);

/// The token from the emailed link.
@override final  String token;
/// Shown in the device list.
@override final  String? deviceName;
/// App language (BCP-47) for emails.
@override final  String? locale;

/// Create a copy of LinkTokenDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkTokenDtoCopyWith<_LinkTokenDto> get copyWith => __$LinkTokenDtoCopyWithImpl<_LinkTokenDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinkTokenDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkTokenDto&&(identical(other.token, token) || other.token == token)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,token,deviceName,locale);
}

@override
String toString() {
    return 'LinkTokenDto(token: $token, deviceName: $deviceName, locale: $locale)';
}


}

/// @nodoc
abstract mixin class _$LinkTokenDtoCopyWith<$Res> implements $LinkTokenDtoCopyWith<$Res> {
  factory _$LinkTokenDtoCopyWith(_LinkTokenDto value, $Res Function(_LinkTokenDto) _then) = __$LinkTokenDtoCopyWithImpl;
@override @useResult
$Res call({
 String token, String? deviceName, String? locale
});




}
/// @nodoc
class __$LinkTokenDtoCopyWithImpl<$Res>
    implements _$LinkTokenDtoCopyWith<$Res> {
  __$LinkTokenDtoCopyWithImpl(this._self, this._then);

  final _LinkTokenDto _self;
  final $Res Function(_LinkTokenDto) _then;

/// Create a copy of LinkTokenDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? deviceName = freezed,Object? locale = freezed,}) {
  return _then(_LinkTokenDto(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
