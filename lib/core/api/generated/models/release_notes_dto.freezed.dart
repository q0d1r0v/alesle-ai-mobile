// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_notes_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleaseNotesDto {

 String get en; String get uz; String get ru;
/// Create a copy of ReleaseNotesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseNotesDtoCopyWith<ReleaseNotesDto> get copyWith => _$ReleaseNotesDtoCopyWithImpl<ReleaseNotesDto>(this as ReleaseNotesDto, _$identity);

  /// Serializes this ReleaseNotesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReleaseNotesDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseNotesDto&&(identical(other.en, _this.en) || other.en == _this.en)&&(identical(other.uz, _this.uz) || other.uz == _this.uz)&&(identical(other.ru, _this.ru) || other.ru == _this.ru));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReleaseNotesDto;
  return Object.hash(runtimeType,_this.en,_this.uz,_this.ru);
}

@override
String toString() {
  final _this = this as ReleaseNotesDto;
  return 'ReleaseNotesDto(en: ${_this.en}, uz: ${_this.uz}, ru: ${_this.ru})';
}


}

/// @nodoc
abstract mixin class $ReleaseNotesDtoCopyWith<$Res>  {
  factory $ReleaseNotesDtoCopyWith(ReleaseNotesDto value, $Res Function(ReleaseNotesDto) _then) = _$ReleaseNotesDtoCopyWithImpl;
@useResult
$Res call({
 String en, String uz, String ru
});




}
/// @nodoc
class _$ReleaseNotesDtoCopyWithImpl<$Res>
    implements $ReleaseNotesDtoCopyWith<$Res> {
  _$ReleaseNotesDtoCopyWithImpl(this._self, this._then);

  final ReleaseNotesDto _self;
  final $Res Function(ReleaseNotesDto) _then;

/// Create a copy of ReleaseNotesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? en = null,Object? uz = null,Object? ru = null,}) {
  return _then(ReleaseNotesDto(
en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,uz: null == uz ? _self.uz : uz // ignore: cast_nullable_to_non_nullable
as String,ru: null == ru ? _self.ru : ru // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseNotesDto].
extension ReleaseNotesDtoPatterns on ReleaseNotesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseNotesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseNotesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseNotesDto value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseNotesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseNotesDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseNotesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String en,  String uz,  String ru)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseNotesDto() when $default != null:
return $default(_that.en,_that.uz,_that.ru);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String en,  String uz,  String ru)  $default,) {final _that = this;
switch (_that) {
case _ReleaseNotesDto():
return $default(_that.en,_that.uz,_that.ru);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String en,  String uz,  String ru)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseNotesDto() when $default != null:
return $default(_that.en,_that.uz,_that.ru);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReleaseNotesDto implements ReleaseNotesDto {
  const _ReleaseNotesDto({required this.en, required this.uz, required this.ru});
  factory _ReleaseNotesDto.fromJson(Map<String, dynamic> json) => _$ReleaseNotesDtoFromJson(json);

@override final  String en;
@override final  String uz;
@override final  String ru;

/// Create a copy of ReleaseNotesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseNotesDtoCopyWith<_ReleaseNotesDto> get copyWith => __$ReleaseNotesDtoCopyWithImpl<_ReleaseNotesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseNotesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseNotesDto&&(identical(other.en, en) || other.en == en)&&(identical(other.uz, uz) || other.uz == uz)&&(identical(other.ru, ru) || other.ru == ru));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,en,uz,ru);
}

@override
String toString() {
    return 'ReleaseNotesDto(en: $en, uz: $uz, ru: $ru)';
}


}

/// @nodoc
abstract mixin class _$ReleaseNotesDtoCopyWith<$Res> implements $ReleaseNotesDtoCopyWith<$Res> {
  factory _$ReleaseNotesDtoCopyWith(_ReleaseNotesDto value, $Res Function(_ReleaseNotesDto) _then) = __$ReleaseNotesDtoCopyWithImpl;
@override @useResult
$Res call({
 String en, String uz, String ru
});




}
/// @nodoc
class __$ReleaseNotesDtoCopyWithImpl<$Res>
    implements _$ReleaseNotesDtoCopyWith<$Res> {
  __$ReleaseNotesDtoCopyWithImpl(this._self, this._then);

  final _ReleaseNotesDto _self;
  final $Res Function(_ReleaseNotesDto) _then;

/// Create a copy of ReleaseNotesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? en = null,Object? uz = null,Object? ru = null,}) {
  return _then(_ReleaseNotesDto(
en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,uz: null == uz ? _self.uz : uz // ignore: cast_nullable_to_non_nullable
as String,ru: null == ru ? _self.ru : ru // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
