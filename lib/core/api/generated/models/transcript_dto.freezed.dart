// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transcript_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TranscriptDto {

/// What was said, in the language and script it was said in; "" when nothing was understood.
 String get text; SpeechLanguage get language; num get confidence;
/// Create a copy of TranscriptDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscriptDtoCopyWith<TranscriptDto> get copyWith => _$TranscriptDtoCopyWithImpl<TranscriptDto>(this as TranscriptDto, _$identity);

  /// Serializes this TranscriptDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TranscriptDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranscriptDto&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TranscriptDto;
  return Object.hash(runtimeType,_this.text,_this.language,_this.confidence);
}

@override
String toString() {
  final _this = this as TranscriptDto;
  return 'TranscriptDto(text: ${_this.text}, language: ${_this.language}, confidence: ${_this.confidence})';
}


}

/// @nodoc
abstract mixin class $TranscriptDtoCopyWith<$Res>  {
  factory $TranscriptDtoCopyWith(TranscriptDto value, $Res Function(TranscriptDto) _then) = _$TranscriptDtoCopyWithImpl;
@useResult
$Res call({
 String text, SpeechLanguage language, num confidence
});




}
/// @nodoc
class _$TranscriptDtoCopyWithImpl<$Res>
    implements $TranscriptDtoCopyWith<$Res> {
  _$TranscriptDtoCopyWithImpl(this._self, this._then);

  final TranscriptDto _self;
  final $Res Function(TranscriptDto) _then;

/// Create a copy of TranscriptDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? language = null,Object? confidence = null,}) {
  return _then(TranscriptDto(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as SpeechLanguage,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [TranscriptDto].
extension TranscriptDtoPatterns on TranscriptDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranscriptDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranscriptDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranscriptDto value)  $default,){
final _that = this;
switch (_that) {
case _TranscriptDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranscriptDto value)?  $default,){
final _that = this;
switch (_that) {
case _TranscriptDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  SpeechLanguage language,  num confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranscriptDto() when $default != null:
return $default(_that.text,_that.language,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  SpeechLanguage language,  num confidence)  $default,) {final _that = this;
switch (_that) {
case _TranscriptDto():
return $default(_that.text,_that.language,_that.confidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  SpeechLanguage language,  num confidence)?  $default,) {final _that = this;
switch (_that) {
case _TranscriptDto() when $default != null:
return $default(_that.text,_that.language,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranscriptDto implements TranscriptDto {
  const _TranscriptDto({required this.text, required this.language, required this.confidence});
  factory _TranscriptDto.fromJson(Map<String, dynamic> json) => _$TranscriptDtoFromJson(json);

/// What was said, in the language and script it was said in; "" when nothing was understood.
@override final  String text;
@override final  SpeechLanguage language;
@override final  num confidence;

/// Create a copy of TranscriptDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscriptDtoCopyWith<_TranscriptDto> get copyWith => __$TranscriptDtoCopyWithImpl<_TranscriptDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranscriptDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranscriptDto&&(identical(other.text, text) || other.text == text)&&(identical(other.language, language) || other.language == language)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,language,confidence);
}

@override
String toString() {
    return 'TranscriptDto(text: $text, language: $language, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$TranscriptDtoCopyWith<$Res> implements $TranscriptDtoCopyWith<$Res> {
  factory _$TranscriptDtoCopyWith(_TranscriptDto value, $Res Function(_TranscriptDto) _then) = __$TranscriptDtoCopyWithImpl;
@override @useResult
$Res call({
 String text, SpeechLanguage language, num confidence
});




}
/// @nodoc
class __$TranscriptDtoCopyWithImpl<$Res>
    implements _$TranscriptDtoCopyWith<$Res> {
  __$TranscriptDtoCopyWithImpl(this._self, this._then);

  final _TranscriptDto _self;
  final $Res Function(_TranscriptDto) _then;

/// Create a copy of TranscriptDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? language = null,Object? confidence = null,}) {
  return _then(_TranscriptDto(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as SpeechLanguage,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
