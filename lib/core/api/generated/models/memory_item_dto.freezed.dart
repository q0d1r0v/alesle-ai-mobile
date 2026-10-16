// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemoryItemDto {

 String get id; MemoryKind get kind; String get content; DateTime get updatedAt;
/// Create a copy of MemoryItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemoryItemDtoCopyWith<MemoryItemDto> get copyWith => _$MemoryItemDtoCopyWithImpl<MemoryItemDto>(this as MemoryItemDto, _$identity);

  /// Serializes this MemoryItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MemoryItemDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemoryItemDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MemoryItemDto;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.content,_this.updatedAt);
}

@override
String toString() {
  final _this = this as MemoryItemDto;
  return 'MemoryItemDto(id: ${_this.id}, kind: ${_this.kind}, content: ${_this.content}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $MemoryItemDtoCopyWith<$Res>  {
  factory $MemoryItemDtoCopyWith(MemoryItemDto value, $Res Function(MemoryItemDto) _then) = _$MemoryItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, MemoryKind kind, String content, DateTime updatedAt
});




}
/// @nodoc
class _$MemoryItemDtoCopyWithImpl<$Res>
    implements $MemoryItemDtoCopyWith<$Res> {
  _$MemoryItemDtoCopyWithImpl(this._self, this._then);

  final MemoryItemDto _self;
  final $Res Function(MemoryItemDto) _then;

/// Create a copy of MemoryItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? content = null,Object? updatedAt = null,}) {
  return _then(MemoryItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MemoryKind,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MemoryItemDto].
extension MemoryItemDtoPatterns on MemoryItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemoryItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemoryItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemoryItemDto value)  $default,){
final _that = this;
switch (_that) {
case _MemoryItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemoryItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _MemoryItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MemoryKind kind,  String content,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemoryItemDto() when $default != null:
return $default(_that.id,_that.kind,_that.content,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MemoryKind kind,  String content,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MemoryItemDto():
return $default(_that.id,_that.kind,_that.content,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MemoryKind kind,  String content,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MemoryItemDto() when $default != null:
return $default(_that.id,_that.kind,_that.content,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemoryItemDto implements MemoryItemDto {
  const _MemoryItemDto({required this.id, required this.kind, required this.content, required this.updatedAt});
  factory _MemoryItemDto.fromJson(Map<String, dynamic> json) => _$MemoryItemDtoFromJson(json);

@override final  String id;
@override final  MemoryKind kind;
@override final  String content;
@override final  DateTime updatedAt;

/// Create a copy of MemoryItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemoryItemDtoCopyWith<_MemoryItemDto> get copyWith => __$MemoryItemDtoCopyWithImpl<_MemoryItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemoryItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemoryItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.content, content) || other.content == content)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,content,updatedAt);
}

@override
String toString() {
    return 'MemoryItemDto(id: $id, kind: $kind, content: $content, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MemoryItemDtoCopyWith<$Res> implements $MemoryItemDtoCopyWith<$Res> {
  factory _$MemoryItemDtoCopyWith(_MemoryItemDto value, $Res Function(_MemoryItemDto) _then) = __$MemoryItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, MemoryKind kind, String content, DateTime updatedAt
});




}
/// @nodoc
class __$MemoryItemDtoCopyWithImpl<$Res>
    implements _$MemoryItemDtoCopyWith<$Res> {
  __$MemoryItemDtoCopyWithImpl(this._self, this._then);

  final _MemoryItemDto _self;
  final $Res Function(_MemoryItemDto) _then;

/// Create a copy of MemoryItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? content = null,Object? updatedAt = null,}) {
  return _then(_MemoryItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MemoryKind,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
