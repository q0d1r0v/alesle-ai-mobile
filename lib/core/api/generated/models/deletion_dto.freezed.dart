// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deletion_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeletionDto {

 DateTime get deletionScheduledAt;
/// Create a copy of DeletionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeletionDtoCopyWith<DeletionDto> get copyWith => _$DeletionDtoCopyWithImpl<DeletionDto>(this as DeletionDto, _$identity);

  /// Serializes this DeletionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeletionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeletionDto&&(identical(other.deletionScheduledAt, _this.deletionScheduledAt) || other.deletionScheduledAt == _this.deletionScheduledAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeletionDto;
  return Object.hash(runtimeType,_this.deletionScheduledAt);
}

@override
String toString() {
  final _this = this as DeletionDto;
  return 'DeletionDto(deletionScheduledAt: ${_this.deletionScheduledAt})';
}


}

/// @nodoc
abstract mixin class $DeletionDtoCopyWith<$Res>  {
  factory $DeletionDtoCopyWith(DeletionDto value, $Res Function(DeletionDto) _then) = _$DeletionDtoCopyWithImpl;
@useResult
$Res call({
 DateTime deletionScheduledAt
});




}
/// @nodoc
class _$DeletionDtoCopyWithImpl<$Res>
    implements $DeletionDtoCopyWith<$Res> {
  _$DeletionDtoCopyWithImpl(this._self, this._then);

  final DeletionDto _self;
  final $Res Function(DeletionDto) _then;

/// Create a copy of DeletionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deletionScheduledAt = null,}) {
  return _then(DeletionDto(
deletionScheduledAt: null == deletionScheduledAt ? _self.deletionScheduledAt : deletionScheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DeletionDto].
extension DeletionDtoPatterns on DeletionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeletionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeletionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeletionDto value)  $default,){
final _that = this;
switch (_that) {
case _DeletionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeletionDto value)?  $default,){
final _that = this;
switch (_that) {
case _DeletionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime deletionScheduledAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeletionDto() when $default != null:
return $default(_that.deletionScheduledAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime deletionScheduledAt)  $default,) {final _that = this;
switch (_that) {
case _DeletionDto():
return $default(_that.deletionScheduledAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime deletionScheduledAt)?  $default,) {final _that = this;
switch (_that) {
case _DeletionDto() when $default != null:
return $default(_that.deletionScheduledAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeletionDto implements DeletionDto {
  const _DeletionDto({required this.deletionScheduledAt});
  factory _DeletionDto.fromJson(Map<String, dynamic> json) => _$DeletionDtoFromJson(json);

@override final  DateTime deletionScheduledAt;

/// Create a copy of DeletionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeletionDtoCopyWith<_DeletionDto> get copyWith => __$DeletionDtoCopyWithImpl<_DeletionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeletionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeletionDto&&(identical(other.deletionScheduledAt, deletionScheduledAt) || other.deletionScheduledAt == deletionScheduledAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,deletionScheduledAt);
}

@override
String toString() {
    return 'DeletionDto(deletionScheduledAt: $deletionScheduledAt)';
}


}

/// @nodoc
abstract mixin class _$DeletionDtoCopyWith<$Res> implements $DeletionDtoCopyWith<$Res> {
  factory _$DeletionDtoCopyWith(_DeletionDto value, $Res Function(_DeletionDto) _then) = __$DeletionDtoCopyWithImpl;
@override @useResult
$Res call({
 DateTime deletionScheduledAt
});




}
/// @nodoc
class __$DeletionDtoCopyWithImpl<$Res>
    implements _$DeletionDtoCopyWith<$Res> {
  __$DeletionDtoCopyWithImpl(this._self, this._then);

  final _DeletionDto _self;
  final $Res Function(_DeletionDto) _then;

/// Create a copy of DeletionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deletionScheduledAt = null,}) {
  return _then(_DeletionDto(
deletionScheduledAt: null == deletionScheduledAt ? _self.deletionScheduledAt : deletionScheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
