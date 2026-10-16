// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refresh_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RefreshDto {

 String get refreshToken;
/// Create a copy of RefreshDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefreshDtoCopyWith<RefreshDto> get copyWith => _$RefreshDtoCopyWithImpl<RefreshDto>(this as RefreshDto, _$identity);

  /// Serializes this RefreshDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RefreshDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshDto&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RefreshDto;
  return Object.hash(runtimeType,_this.refreshToken);
}

@override
String toString() {
  final _this = this as RefreshDto;
  return 'RefreshDto(refreshToken: ${_this.refreshToken})';
}


}

/// @nodoc
abstract mixin class $RefreshDtoCopyWith<$Res>  {
  factory $RefreshDtoCopyWith(RefreshDto value, $Res Function(RefreshDto) _then) = _$RefreshDtoCopyWithImpl;
@useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class _$RefreshDtoCopyWithImpl<$Res>
    implements $RefreshDtoCopyWith<$Res> {
  _$RefreshDtoCopyWithImpl(this._self, this._then);

  final RefreshDto _self;
  final $Res Function(RefreshDto) _then;

/// Create a copy of RefreshDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshToken = null,}) {
  return _then(RefreshDto(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RefreshDto].
extension RefreshDtoPatterns on RefreshDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefreshDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefreshDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefreshDto value)  $default,){
final _that = this;
switch (_that) {
case _RefreshDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefreshDto value)?  $default,){
final _that = this;
switch (_that) {
case _RefreshDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefreshDto() when $default != null:
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _RefreshDto():
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _RefreshDto() when $default != null:
return $default(_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RefreshDto implements RefreshDto {
  const _RefreshDto({required this.refreshToken});
  factory _RefreshDto.fromJson(Map<String, dynamic> json) => _$RefreshDtoFromJson(json);

@override final  String refreshToken;

/// Create a copy of RefreshDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshDtoCopyWith<_RefreshDto> get copyWith => __$RefreshDtoCopyWithImpl<_RefreshDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RefreshDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,refreshToken);
}

@override
String toString() {
    return 'RefreshDto(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$RefreshDtoCopyWith<$Res> implements $RefreshDtoCopyWith<$Res> {
  factory _$RefreshDtoCopyWith(_RefreshDto value, $Res Function(_RefreshDto) _then) = __$RefreshDtoCopyWithImpl;
@override @useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class __$RefreshDtoCopyWithImpl<$Res>
    implements _$RefreshDtoCopyWith<$Res> {
  __$RefreshDtoCopyWithImpl(this._self, this._then);

  final _RefreshDto _self;
  final $Res Function(_RefreshDto) _then;

/// Create a copy of RefreshDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshToken = null,}) {
  return _then(_RefreshDto(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
