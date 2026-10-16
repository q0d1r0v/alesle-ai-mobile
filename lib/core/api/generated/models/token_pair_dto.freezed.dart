// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_pair_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TokenPairDto {

/// Bearer token for the API and the agent socket.
 String get accessToken;/// Seconds until accessToken expires.
 num get expiresIn;/// Single use: each refresh returns a new one.
 String get refreshToken; AuthUserDto get user;
/// Create a copy of TokenPairDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenPairDtoCopyWith<TokenPairDto> get copyWith => _$TokenPairDtoCopyWithImpl<TokenPairDto>(this as TokenPairDto, _$identity);

  /// Serializes this TokenPairDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TokenPairDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenPairDto&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.expiresIn, _this.expiresIn) || other.expiresIn == _this.expiresIn)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.user, _this.user) || other.user == _this.user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TokenPairDto;
  return Object.hash(runtimeType,_this.accessToken,_this.expiresIn,_this.refreshToken,_this.user);
}

@override
String toString() {
  final _this = this as TokenPairDto;
  return 'TokenPairDto(accessToken: ${_this.accessToken}, expiresIn: ${_this.expiresIn}, refreshToken: ${_this.refreshToken}, user: ${_this.user})';
}


}

/// @nodoc
abstract mixin class $TokenPairDtoCopyWith<$Res>  {
  factory $TokenPairDtoCopyWith(TokenPairDto value, $Res Function(TokenPairDto) _then) = _$TokenPairDtoCopyWithImpl;
@useResult
$Res call({
 String accessToken, num expiresIn, String refreshToken, AuthUserDto user
});


$AuthUserDtoCopyWith<$Res> get user;

}
/// @nodoc
class _$TokenPairDtoCopyWithImpl<$Res>
    implements $TokenPairDtoCopyWith<$Res> {
  _$TokenPairDtoCopyWithImpl(this._self, this._then);

  final TokenPairDto _self;
  final $Res Function(TokenPairDto) _then;

/// Create a copy of TokenPairDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? expiresIn = null,Object? refreshToken = null,Object? user = null,}) {
  return _then(TokenPairDto(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as num,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUserDto,
  ));
}
/// Create a copy of TokenPairDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserDtoCopyWith<$Res> get user {
  
  return $AuthUserDtoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [TokenPairDto].
extension TokenPairDtoPatterns on TokenPairDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TokenPairDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TokenPairDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TokenPairDto value)  $default,){
final _that = this;
switch (_that) {
case _TokenPairDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TokenPairDto value)?  $default,){
final _that = this;
switch (_that) {
case _TokenPairDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  num expiresIn,  String refreshToken,  AuthUserDto user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TokenPairDto() when $default != null:
return $default(_that.accessToken,_that.expiresIn,_that.refreshToken,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  num expiresIn,  String refreshToken,  AuthUserDto user)  $default,) {final _that = this;
switch (_that) {
case _TokenPairDto():
return $default(_that.accessToken,_that.expiresIn,_that.refreshToken,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  num expiresIn,  String refreshToken,  AuthUserDto user)?  $default,) {final _that = this;
switch (_that) {
case _TokenPairDto() when $default != null:
return $default(_that.accessToken,_that.expiresIn,_that.refreshToken,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TokenPairDto implements TokenPairDto {
  const _TokenPairDto({required this.accessToken, required this.expiresIn, required this.refreshToken, required this.user});
  factory _TokenPairDto.fromJson(Map<String, dynamic> json) => _$TokenPairDtoFromJson(json);

/// Bearer token for the API and the agent socket.
@override final  String accessToken;
/// Seconds until accessToken expires.
@override final  num expiresIn;
/// Single use: each refresh returns a new one.
@override final  String refreshToken;
@override final  AuthUserDto user;

/// Create a copy of TokenPairDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenPairDtoCopyWith<_TokenPairDto> get copyWith => __$TokenPairDtoCopyWithImpl<_TokenPairDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenPairDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenPairDto&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,accessToken,expiresIn,refreshToken,user);
}

@override
String toString() {
    return 'TokenPairDto(accessToken: $accessToken, expiresIn: $expiresIn, refreshToken: $refreshToken, user: $user)';
}


}

/// @nodoc
abstract mixin class _$TokenPairDtoCopyWith<$Res> implements $TokenPairDtoCopyWith<$Res> {
  factory _$TokenPairDtoCopyWith(_TokenPairDto value, $Res Function(_TokenPairDto) _then) = __$TokenPairDtoCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, num expiresIn, String refreshToken, AuthUserDto user
});


@override $AuthUserDtoCopyWith<$Res> get user;

}
/// @nodoc
class __$TokenPairDtoCopyWithImpl<$Res>
    implements _$TokenPairDtoCopyWith<$Res> {
  __$TokenPairDtoCopyWithImpl(this._self, this._then);

  final _TokenPairDto _self;
  final $Res Function(_TokenPairDto) _then;

/// Create a copy of TokenPairDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? expiresIn = null,Object? refreshToken = null,Object? user = null,}) {
  return _then(_TokenPairDto(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as num,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUserDto,
  ));
}

/// Create a copy of TokenPairDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserDtoCopyWith<$Res> get user {
  
  return $AuthUserDtoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
