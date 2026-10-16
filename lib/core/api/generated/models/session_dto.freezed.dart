// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionDto {

 String get id; String? get deviceName; DateTime get createdAt; DateTime get lastUsedAt;/// The device this request came from.
 bool get current;
/// Create a copy of SessionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionDtoCopyWith<SessionDto> get copyWith => _$SessionDtoCopyWithImpl<SessionDto>(this as SessionDto, _$identity);

  /// Serializes this SessionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.lastUsedAt, _this.lastUsedAt) || other.lastUsedAt == _this.lastUsedAt)&&(identical(other.current, _this.current) || other.current == _this.current));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionDto;
  return Object.hash(runtimeType,_this.id,_this.deviceName,_this.createdAt,_this.lastUsedAt,_this.current);
}

@override
String toString() {
  final _this = this as SessionDto;
  return 'SessionDto(id: ${_this.id}, deviceName: ${_this.deviceName}, createdAt: ${_this.createdAt}, lastUsedAt: ${_this.lastUsedAt}, current: ${_this.current})';
}


}

/// @nodoc
abstract mixin class $SessionDtoCopyWith<$Res>  {
  factory $SessionDtoCopyWith(SessionDto value, $Res Function(SessionDto) _then) = _$SessionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? deviceName, DateTime createdAt, DateTime lastUsedAt, bool current
});




}
/// @nodoc
class _$SessionDtoCopyWithImpl<$Res>
    implements $SessionDtoCopyWith<$Res> {
  _$SessionDtoCopyWithImpl(this._self, this._then);

  final SessionDto _self;
  final $Res Function(SessionDto) _then;

/// Create a copy of SessionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceName = freezed,Object? createdAt = null,Object? lastUsedAt = null,Object? current = null,}) {
  return _then(SessionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: null == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionDto].
extension SessionDtoPatterns on SessionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionDto value)  $default,){
final _that = this;
switch (_that) {
case _SessionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionDto value)?  $default,){
final _that = this;
switch (_that) {
case _SessionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? deviceName,  DateTime createdAt,  DateTime lastUsedAt,  bool current)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionDto() when $default != null:
return $default(_that.id,_that.deviceName,_that.createdAt,_that.lastUsedAt,_that.current);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? deviceName,  DateTime createdAt,  DateTime lastUsedAt,  bool current)  $default,) {final _that = this;
switch (_that) {
case _SessionDto():
return $default(_that.id,_that.deviceName,_that.createdAt,_that.lastUsedAt,_that.current);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? deviceName,  DateTime createdAt,  DateTime lastUsedAt,  bool current)?  $default,) {final _that = this;
switch (_that) {
case _SessionDto() when $default != null:
return $default(_that.id,_that.deviceName,_that.createdAt,_that.lastUsedAt,_that.current);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionDto implements SessionDto {
  const _SessionDto({required this.id, required this.deviceName, required this.createdAt, required this.lastUsedAt, required this.current});
  factory _SessionDto.fromJson(Map<String, dynamic> json) => _$SessionDtoFromJson(json);

@override final  String id;
@override final  String? deviceName;
@override final  DateTime createdAt;
@override final  DateTime lastUsedAt;
/// The device this request came from.
@override final  bool current;

/// Create a copy of SessionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionDtoCopyWith<_SessionDto> get copyWith => __$SessionDtoCopyWithImpl<_SessionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.current, current) || other.current == current));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,deviceName,createdAt,lastUsedAt,current);
}

@override
String toString() {
    return 'SessionDto(id: $id, deviceName: $deviceName, createdAt: $createdAt, lastUsedAt: $lastUsedAt, current: $current)';
}


}

/// @nodoc
abstract mixin class _$SessionDtoCopyWith<$Res> implements $SessionDtoCopyWith<$Res> {
  factory _$SessionDtoCopyWith(_SessionDto value, $Res Function(_SessionDto) _then) = __$SessionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? deviceName, DateTime createdAt, DateTime lastUsedAt, bool current
});




}
/// @nodoc
class __$SessionDtoCopyWithImpl<$Res>
    implements _$SessionDtoCopyWith<$Res> {
  __$SessionDtoCopyWithImpl(this._self, this._then);

  final _SessionDto _self;
  final $Res Function(_SessionDto) _then;

/// Create a copy of SessionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceName = freezed,Object? createdAt = null,Object? lastUsedAt = null,Object? current = null,}) {
  return _then(_SessionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: null == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
