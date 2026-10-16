// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HistoryItemDto {

 String get id; String? get title; TaskStatus get status;/// What the user said.
 String? get command;/// What the agent answered.
 String? get reply; DateTime get createdAt;
/// Create a copy of HistoryItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryItemDtoCopyWith<HistoryItemDto> get copyWith => _$HistoryItemDtoCopyWithImpl<HistoryItemDto>(this as HistoryItemDto, _$identity);

  /// Serializes this HistoryItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HistoryItemDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryItemDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.command, _this.command) || other.command == _this.command)&&(identical(other.reply, _this.reply) || other.reply == _this.reply)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HistoryItemDto;
  return Object.hash(runtimeType,_this.id,_this.title,_this.status,_this.command,_this.reply,_this.createdAt);
}

@override
String toString() {
  final _this = this as HistoryItemDto;
  return 'HistoryItemDto(id: ${_this.id}, title: ${_this.title}, status: ${_this.status}, command: ${_this.command}, reply: ${_this.reply}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $HistoryItemDtoCopyWith<$Res>  {
  factory $HistoryItemDtoCopyWith(HistoryItemDto value, $Res Function(HistoryItemDto) _then) = _$HistoryItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? title, TaskStatus status, String? command, String? reply, DateTime createdAt
});




}
/// @nodoc
class _$HistoryItemDtoCopyWithImpl<$Res>
    implements $HistoryItemDtoCopyWith<$Res> {
  _$HistoryItemDtoCopyWithImpl(this._self, this._then);

  final HistoryItemDto _self;
  final $Res Function(HistoryItemDto) _then;

/// Create a copy of HistoryItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? status = null,Object? command = freezed,Object? reply = freezed,Object? createdAt = null,}) {
  return _then(HistoryItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,command: freezed == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String?,reply: freezed == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryItemDto].
extension HistoryItemDtoPatterns on HistoryItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryItemDto value)  $default,){
final _that = this;
switch (_that) {
case _HistoryItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  TaskStatus status,  String? command,  String? reply,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryItemDto() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.command,_that.reply,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  TaskStatus status,  String? command,  String? reply,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _HistoryItemDto():
return $default(_that.id,_that.title,_that.status,_that.command,_that.reply,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  TaskStatus status,  String? command,  String? reply,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _HistoryItemDto() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.command,_that.reply,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistoryItemDto implements HistoryItemDto {
  const _HistoryItemDto({required this.id, required this.title, required this.status, required this.command, required this.reply, required this.createdAt});
  factory _HistoryItemDto.fromJson(Map<String, dynamic> json) => _$HistoryItemDtoFromJson(json);

@override final  String id;
@override final  String? title;
@override final  TaskStatus status;
/// What the user said.
@override final  String? command;
/// What the agent answered.
@override final  String? reply;
@override final  DateTime createdAt;

/// Create a copy of HistoryItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryItemDtoCopyWith<_HistoryItemDto> get copyWith => __$HistoryItemDtoCopyWithImpl<_HistoryItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.command, command) || other.command == command)&&(identical(other.reply, reply) || other.reply == reply)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,status,command,reply,createdAt);
}

@override
String toString() {
    return 'HistoryItemDto(id: $id, title: $title, status: $status, command: $command, reply: $reply, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$HistoryItemDtoCopyWith<$Res> implements $HistoryItemDtoCopyWith<$Res> {
  factory _$HistoryItemDtoCopyWith(_HistoryItemDto value, $Res Function(_HistoryItemDto) _then) = __$HistoryItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, TaskStatus status, String? command, String? reply, DateTime createdAt
});




}
/// @nodoc
class __$HistoryItemDtoCopyWithImpl<$Res>
    implements _$HistoryItemDtoCopyWith<$Res> {
  __$HistoryItemDtoCopyWithImpl(this._self, this._then);

  final _HistoryItemDto _self;
  final $Res Function(_HistoryItemDto) _then;

/// Create a copy of HistoryItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? status = null,Object? command = freezed,Object? reply = freezed,Object? createdAt = null,}) {
  return _then(_HistoryItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,command: freezed == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String?,reply: freezed == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
