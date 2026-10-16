// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_page_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HistoryPageDto {

 List<HistoryItemDto> get items;/// Pass as `before` for the next page; null on the last page.
 DateTime? get next;
/// Create a copy of HistoryPageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryPageDtoCopyWith<HistoryPageDto> get copyWith => _$HistoryPageDtoCopyWithImpl<HistoryPageDto>(this as HistoryPageDto, _$identity);

  /// Serializes this HistoryPageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HistoryPageDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryPageDto&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.next, _this.next) || other.next == _this.next));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HistoryPageDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.next);
}

@override
String toString() {
  final _this = this as HistoryPageDto;
  return 'HistoryPageDto(items: ${_this.items}, next: ${_this.next})';
}


}

/// @nodoc
abstract mixin class $HistoryPageDtoCopyWith<$Res>  {
  factory $HistoryPageDtoCopyWith(HistoryPageDto value, $Res Function(HistoryPageDto) _then) = _$HistoryPageDtoCopyWithImpl;
@useResult
$Res call({
 List<HistoryItemDto> items, DateTime? next
});




}
/// @nodoc
class _$HistoryPageDtoCopyWithImpl<$Res>
    implements $HistoryPageDtoCopyWith<$Res> {
  _$HistoryPageDtoCopyWithImpl(this._self, this._then);

  final HistoryPageDto _self;
  final $Res Function(HistoryPageDto) _then;

/// Create a copy of HistoryPageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? next = freezed,}) {
  return _then(HistoryPageDto(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<HistoryItemDto>,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryPageDto].
extension HistoryPageDtoPatterns on HistoryPageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryPageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryPageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryPageDto value)  $default,){
final _that = this;
switch (_that) {
case _HistoryPageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryPageDto value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryPageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HistoryItemDto> items,  DateTime? next)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryPageDto() when $default != null:
return $default(_that.items,_that.next);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HistoryItemDto> items,  DateTime? next)  $default,) {final _that = this;
switch (_that) {
case _HistoryPageDto():
return $default(_that.items,_that.next);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HistoryItemDto> items,  DateTime? next)?  $default,) {final _that = this;
switch (_that) {
case _HistoryPageDto() when $default != null:
return $default(_that.items,_that.next);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistoryPageDto implements HistoryPageDto {
  const _HistoryPageDto({required  List<HistoryItemDto> items, required this.next}): _items = items;
  factory _HistoryPageDto.fromJson(Map<String, dynamic> json) => _$HistoryPageDtoFromJson(json);

 final  List<HistoryItemDto> _items;
@override List<HistoryItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// Pass as `before` for the next page; null on the last page.
@override final  DateTime? next;

/// Create a copy of HistoryPageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryPageDtoCopyWith<_HistoryPageDto> get copyWith => __$HistoryPageDtoCopyWithImpl<_HistoryPageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryPageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryPageDto&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.next, next) || other.next == next));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),next);
}

@override
String toString() {
    return 'HistoryPageDto(items: $items, next: $next)';
}


}

/// @nodoc
abstract mixin class _$HistoryPageDtoCopyWith<$Res> implements $HistoryPageDtoCopyWith<$Res> {
  factory _$HistoryPageDtoCopyWith(_HistoryPageDto value, $Res Function(_HistoryPageDto) _then) = __$HistoryPageDtoCopyWithImpl;
@override @useResult
$Res call({
 List<HistoryItemDto> items, DateTime? next
});




}
/// @nodoc
class __$HistoryPageDtoCopyWithImpl<$Res>
    implements _$HistoryPageDtoCopyWith<$Res> {
  __$HistoryPageDtoCopyWithImpl(this._self, this._then);

  final _HistoryPageDto _self;
  final $Res Function(_HistoryPageDto) _then;

/// Create a copy of HistoryPageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? next = freezed,}) {
  return _then(_HistoryPageDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<HistoryItemDto>,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
