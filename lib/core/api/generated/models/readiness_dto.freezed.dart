// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'readiness_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadinessDto {

 ReadinessDtoStatus get status; Map<String, String> get dependencies;
/// Create a copy of ReadinessDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadinessDtoCopyWith<ReadinessDto> get copyWith => _$ReadinessDtoCopyWithImpl<ReadinessDto>(this as ReadinessDto, _$identity);

  /// Serializes this ReadinessDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReadinessDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadinessDto&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.dependencies, _this.dependencies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReadinessDto;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.dependencies));
}

@override
String toString() {
  final _this = this as ReadinessDto;
  return 'ReadinessDto(status: ${_this.status}, dependencies: ${_this.dependencies})';
}


}

/// @nodoc
abstract mixin class $ReadinessDtoCopyWith<$Res>  {
  factory $ReadinessDtoCopyWith(ReadinessDto value, $Res Function(ReadinessDto) _then) = _$ReadinessDtoCopyWithImpl;
@useResult
$Res call({
 ReadinessDtoStatus status, Map<String, String> dependencies
});




}
/// @nodoc
class _$ReadinessDtoCopyWithImpl<$Res>
    implements $ReadinessDtoCopyWith<$Res> {
  _$ReadinessDtoCopyWithImpl(this._self, this._then);

  final ReadinessDto _self;
  final $Res Function(ReadinessDto) _then;

/// Create a copy of ReadinessDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? dependencies = null,}) {
  return _then(ReadinessDto(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReadinessDtoStatus,dependencies: null == dependencies ? _self.dependencies : dependencies // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadinessDto].
extension ReadinessDtoPatterns on ReadinessDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadinessDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadinessDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadinessDto value)  $default,){
final _that = this;
switch (_that) {
case _ReadinessDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadinessDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReadinessDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReadinessDtoStatus status,  Map<String, String> dependencies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadinessDto() when $default != null:
return $default(_that.status,_that.dependencies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReadinessDtoStatus status,  Map<String, String> dependencies)  $default,) {final _that = this;
switch (_that) {
case _ReadinessDto():
return $default(_that.status,_that.dependencies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReadinessDtoStatus status,  Map<String, String> dependencies)?  $default,) {final _that = this;
switch (_that) {
case _ReadinessDto() when $default != null:
return $default(_that.status,_that.dependencies);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadinessDto implements ReadinessDto {
  const _ReadinessDto({required this.status, required  Map<String, String> dependencies}): _dependencies = dependencies;
  factory _ReadinessDto.fromJson(Map<String, dynamic> json) => _$ReadinessDtoFromJson(json);

@override final  ReadinessDtoStatus status;
 final  Map<String, String> _dependencies;
@override Map<String, String> get dependencies {
  if (_dependencies is EqualUnmodifiableMapView) return _dependencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dependencies);
}


/// Create a copy of ReadinessDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadinessDtoCopyWith<_ReadinessDto> get copyWith => __$ReadinessDtoCopyWithImpl<_ReadinessDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadinessDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadinessDto&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.dependencies, _dependencies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_dependencies));
}

@override
String toString() {
    return 'ReadinessDto(status: $status, dependencies: $dependencies)';
}


}

/// @nodoc
abstract mixin class _$ReadinessDtoCopyWith<$Res> implements $ReadinessDtoCopyWith<$Res> {
  factory _$ReadinessDtoCopyWith(_ReadinessDto value, $Res Function(_ReadinessDto) _then) = __$ReadinessDtoCopyWithImpl;
@override @useResult
$Res call({
 ReadinessDtoStatus status, Map<String, String> dependencies
});




}
/// @nodoc
class __$ReadinessDtoCopyWithImpl<$Res>
    implements _$ReadinessDtoCopyWith<$Res> {
  __$ReadinessDtoCopyWithImpl(this._self, this._then);

  final _ReadinessDto _self;
  final $Res Function(_ReadinessDto) _then;

/// Create a copy of ReadinessDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? dependencies = null,}) {
  return _then(_ReadinessDto(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReadinessDtoStatus,dependencies: null == dependencies ? _self._dependencies : dependencies // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
