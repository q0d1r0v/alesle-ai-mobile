// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'liveness_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LivenessDto {

 LivenessDtoStatus get status;/// Short git SHA of the running build, or "unknown".
 String get commit;/// Process uptime in whole seconds.
 num get uptimeSeconds;
/// Create a copy of LivenessDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivenessDtoCopyWith<LivenessDto> get copyWith => _$LivenessDtoCopyWithImpl<LivenessDto>(this as LivenessDto, _$identity);

  /// Serializes this LivenessDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LivenessDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessDto&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.commit, _this.commit) || other.commit == _this.commit)&&(identical(other.uptimeSeconds, _this.uptimeSeconds) || other.uptimeSeconds == _this.uptimeSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LivenessDto;
  return Object.hash(runtimeType,_this.status,_this.commit,_this.uptimeSeconds);
}

@override
String toString() {
  final _this = this as LivenessDto;
  return 'LivenessDto(status: ${_this.status}, commit: ${_this.commit}, uptimeSeconds: ${_this.uptimeSeconds})';
}


}

/// @nodoc
abstract mixin class $LivenessDtoCopyWith<$Res>  {
  factory $LivenessDtoCopyWith(LivenessDto value, $Res Function(LivenessDto) _then) = _$LivenessDtoCopyWithImpl;
@useResult
$Res call({
 LivenessDtoStatus status, String commit, num uptimeSeconds
});




}
/// @nodoc
class _$LivenessDtoCopyWithImpl<$Res>
    implements $LivenessDtoCopyWith<$Res> {
  _$LivenessDtoCopyWithImpl(this._self, this._then);

  final LivenessDto _self;
  final $Res Function(LivenessDto) _then;

/// Create a copy of LivenessDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? commit = null,Object? uptimeSeconds = null,}) {
  return _then(LivenessDto(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LivenessDtoStatus,commit: null == commit ? _self.commit : commit // ignore: cast_nullable_to_non_nullable
as String,uptimeSeconds: null == uptimeSeconds ? _self.uptimeSeconds : uptimeSeconds // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [LivenessDto].
extension LivenessDtoPatterns on LivenessDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivenessDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivenessDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivenessDto value)  $default,){
final _that = this;
switch (_that) {
case _LivenessDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivenessDto value)?  $default,){
final _that = this;
switch (_that) {
case _LivenessDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LivenessDtoStatus status,  String commit,  num uptimeSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivenessDto() when $default != null:
return $default(_that.status,_that.commit,_that.uptimeSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LivenessDtoStatus status,  String commit,  num uptimeSeconds)  $default,) {final _that = this;
switch (_that) {
case _LivenessDto():
return $default(_that.status,_that.commit,_that.uptimeSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LivenessDtoStatus status,  String commit,  num uptimeSeconds)?  $default,) {final _that = this;
switch (_that) {
case _LivenessDto() when $default != null:
return $default(_that.status,_that.commit,_that.uptimeSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LivenessDto implements LivenessDto {
  const _LivenessDto({required this.status, required this.commit, required this.uptimeSeconds});
  factory _LivenessDto.fromJson(Map<String, dynamic> json) => _$LivenessDtoFromJson(json);

@override final  LivenessDtoStatus status;
/// Short git SHA of the running build, or "unknown".
@override final  String commit;
/// Process uptime in whole seconds.
@override final  num uptimeSeconds;

/// Create a copy of LivenessDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivenessDtoCopyWith<_LivenessDto> get copyWith => __$LivenessDtoCopyWithImpl<_LivenessDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LivenessDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivenessDto&&(identical(other.status, status) || other.status == status)&&(identical(other.commit, commit) || other.commit == commit)&&(identical(other.uptimeSeconds, uptimeSeconds) || other.uptimeSeconds == uptimeSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,commit,uptimeSeconds);
}

@override
String toString() {
    return 'LivenessDto(status: $status, commit: $commit, uptimeSeconds: $uptimeSeconds)';
}


}

/// @nodoc
abstract mixin class _$LivenessDtoCopyWith<$Res> implements $LivenessDtoCopyWith<$Res> {
  factory _$LivenessDtoCopyWith(_LivenessDto value, $Res Function(_LivenessDto) _then) = __$LivenessDtoCopyWithImpl;
@override @useResult
$Res call({
 LivenessDtoStatus status, String commit, num uptimeSeconds
});




}
/// @nodoc
class __$LivenessDtoCopyWithImpl<$Res>
    implements _$LivenessDtoCopyWith<$Res> {
  __$LivenessDtoCopyWithImpl(this._self, this._then);

  final _LivenessDto _self;
  final $Res Function(_LivenessDto) _then;

/// Create a copy of LivenessDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? commit = null,Object? uptimeSeconds = null,}) {
  return _then(_LivenessDto(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LivenessDtoStatus,commit: null == commit ? _self.commit : commit // ignore: cast_nullable_to_non_nullable
as String,uptimeSeconds: null == uptimeSeconds ? _self.uptimeSeconds : uptimeSeconds // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
