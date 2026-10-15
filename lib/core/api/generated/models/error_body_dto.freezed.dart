// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'error_body_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ErrorBodyDto {

 ErrorCode get code;/// Human-readable, English, for logs. Never branch on it.
 String get message;/// Echoed from X-Request-Id, or generated.
 String get requestId; DateTime get timestamp;/// Field issues for VALIDATION_FAILED, or string parameters for other codes.
 dynamic get details;
/// Create a copy of ErrorBodyDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorBodyDtoCopyWith<ErrorBodyDto> get copyWith => _$ErrorBodyDtoCopyWithImpl<ErrorBodyDto>(this as ErrorBodyDto, _$identity);

  /// Serializes this ErrorBodyDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ErrorBodyDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ErrorBodyDto&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp)&&const DeepCollectionEquality().equals(other.details, _this.details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ErrorBodyDto;
  return Object.hash(runtimeType,_this.code,_this.message,_this.requestId,_this.timestamp,const DeepCollectionEquality().hash(_this.details));
}

@override
String toString() {
  final _this = this as ErrorBodyDto;
  return 'ErrorBodyDto(code: ${_this.code}, message: ${_this.message}, requestId: ${_this.requestId}, timestamp: ${_this.timestamp}, details: ${_this.details})';
}


}

/// @nodoc
abstract mixin class $ErrorBodyDtoCopyWith<$Res>  {
  factory $ErrorBodyDtoCopyWith(ErrorBodyDto value, $Res Function(ErrorBodyDto) _then) = _$ErrorBodyDtoCopyWithImpl;
@useResult
$Res call({
 ErrorCode code, String message, String requestId, DateTime timestamp, dynamic details
});




}
/// @nodoc
class _$ErrorBodyDtoCopyWithImpl<$Res>
    implements $ErrorBodyDtoCopyWith<$Res> {
  _$ErrorBodyDtoCopyWithImpl(this._self, this._then);

  final ErrorBodyDto _self;
  final $Res Function(ErrorBodyDto) _then;

/// Create a copy of ErrorBodyDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,Object? requestId = null,Object? timestamp = null,Object? details = freezed,}) {
  return _then(ErrorBodyDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as ErrorCode,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [ErrorBodyDto].
extension ErrorBodyDtoPatterns on ErrorBodyDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ErrorBodyDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ErrorBodyDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ErrorBodyDto value)  $default,){
final _that = this;
switch (_that) {
case _ErrorBodyDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ErrorBodyDto value)?  $default,){
final _that = this;
switch (_that) {
case _ErrorBodyDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ErrorCode code,  String message,  String requestId,  DateTime timestamp,  dynamic details)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ErrorBodyDto() when $default != null:
return $default(_that.code,_that.message,_that.requestId,_that.timestamp,_that.details);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ErrorCode code,  String message,  String requestId,  DateTime timestamp,  dynamic details)  $default,) {final _that = this;
switch (_that) {
case _ErrorBodyDto():
return $default(_that.code,_that.message,_that.requestId,_that.timestamp,_that.details);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ErrorCode code,  String message,  String requestId,  DateTime timestamp,  dynamic details)?  $default,) {final _that = this;
switch (_that) {
case _ErrorBodyDto() when $default != null:
return $default(_that.code,_that.message,_that.requestId,_that.timestamp,_that.details);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ErrorBodyDto implements ErrorBodyDto {
  const _ErrorBodyDto({required this.code, required this.message, required this.requestId, required this.timestamp, this.details});
  factory _ErrorBodyDto.fromJson(Map<String, dynamic> json) => _$ErrorBodyDtoFromJson(json);

@override final  ErrorCode code;
/// Human-readable, English, for logs. Never branch on it.
@override final  String message;
/// Echoed from X-Request-Id, or generated.
@override final  String requestId;
@override final  DateTime timestamp;
/// Field issues for VALIDATION_FAILED, or string parameters for other codes.
@override final  dynamic details;

/// Create a copy of ErrorBodyDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorBodyDtoCopyWith<_ErrorBodyDto> get copyWith => __$ErrorBodyDtoCopyWithImpl<_ErrorBodyDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ErrorBodyDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ErrorBodyDto&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.details, details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,message,requestId,timestamp,const DeepCollectionEquality().hash(details));
}

@override
String toString() {
    return 'ErrorBodyDto(code: $code, message: $message, requestId: $requestId, timestamp: $timestamp, details: $details)';
}


}

/// @nodoc
abstract mixin class _$ErrorBodyDtoCopyWith<$Res> implements $ErrorBodyDtoCopyWith<$Res> {
  factory _$ErrorBodyDtoCopyWith(_ErrorBodyDto value, $Res Function(_ErrorBodyDto) _then) = __$ErrorBodyDtoCopyWithImpl;
@override @useResult
$Res call({
 ErrorCode code, String message, String requestId, DateTime timestamp, dynamic details
});




}
/// @nodoc
class __$ErrorBodyDtoCopyWithImpl<$Res>
    implements _$ErrorBodyDtoCopyWith<$Res> {
  __$ErrorBodyDtoCopyWithImpl(this._self, this._then);

  final _ErrorBodyDto _self;
  final $Res Function(_ErrorBodyDto) _then;

/// Create a copy of ErrorBodyDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? requestId = null,Object? timestamp = null,Object? details = freezed,}) {
  return _then(_ErrorBodyDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as ErrorCode,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
