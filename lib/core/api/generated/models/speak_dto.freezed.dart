// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'speak_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SpeakDto {

/// The reply to read aloud.
 String get text;
/// Create a copy of SpeakDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpeakDtoCopyWith<SpeakDto> get copyWith => _$SpeakDtoCopyWithImpl<SpeakDto>(this as SpeakDto, _$identity);

  /// Serializes this SpeakDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SpeakDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeakDto&&(identical(other.text, _this.text) || other.text == _this.text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SpeakDto;
  return Object.hash(runtimeType,_this.text);
}

@override
String toString() {
  final _this = this as SpeakDto;
  return 'SpeakDto(text: ${_this.text})';
}


}

/// @nodoc
abstract mixin class $SpeakDtoCopyWith<$Res>  {
  factory $SpeakDtoCopyWith(SpeakDto value, $Res Function(SpeakDto) _then) = _$SpeakDtoCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$SpeakDtoCopyWithImpl<$Res>
    implements $SpeakDtoCopyWith<$Res> {
  _$SpeakDtoCopyWithImpl(this._self, this._then);

  final SpeakDto _self;
  final $Res Function(SpeakDto) _then;

/// Create a copy of SpeakDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,}) {
  return _then(SpeakDto(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SpeakDto].
extension SpeakDtoPatterns on SpeakDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpeakDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpeakDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpeakDto value)  $default,){
final _that = this;
switch (_that) {
case _SpeakDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpeakDto value)?  $default,){
final _that = this;
switch (_that) {
case _SpeakDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpeakDto() when $default != null:
return $default(_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text)  $default,) {final _that = this;
switch (_that) {
case _SpeakDto():
return $default(_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text)?  $default,) {final _that = this;
switch (_that) {
case _SpeakDto() when $default != null:
return $default(_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpeakDto implements SpeakDto {
  const _SpeakDto({required this.text});
  factory _SpeakDto.fromJson(Map<String, dynamic> json) => _$SpeakDtoFromJson(json);

/// The reply to read aloud.
@override final  String text;

/// Create a copy of SpeakDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpeakDtoCopyWith<_SpeakDto> get copyWith => __$SpeakDtoCopyWithImpl<_SpeakDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpeakDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpeakDto&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text);
}

@override
String toString() {
    return 'SpeakDto(text: $text)';
}


}

/// @nodoc
abstract mixin class _$SpeakDtoCopyWith<$Res> implements $SpeakDtoCopyWith<$Res> {
  factory _$SpeakDtoCopyWith(_SpeakDto value, $Res Function(_SpeakDto) _then) = __$SpeakDtoCopyWithImpl;
@override @useResult
$Res call({
 String text
});




}
/// @nodoc
class __$SpeakDtoCopyWithImpl<$Res>
    implements _$SpeakDtoCopyWith<$Res> {
  __$SpeakDtoCopyWithImpl(this._self, this._then);

  final _SpeakDto _self;
  final $Res Function(_SpeakDto) _then;

/// Create a copy of SpeakDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(_SpeakDto(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
