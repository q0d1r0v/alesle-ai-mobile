// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'locale_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocaleDto {

/// Language of the email (BCP-47).
 String? get locale;
/// Create a copy of LocaleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocaleDtoCopyWith<LocaleDto> get copyWith => _$LocaleDtoCopyWithImpl<LocaleDto>(this as LocaleDto, _$identity);

  /// Serializes this LocaleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LocaleDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocaleDto&&(identical(other.locale, _this.locale) || other.locale == _this.locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LocaleDto;
  return Object.hash(runtimeType,_this.locale);
}

@override
String toString() {
  final _this = this as LocaleDto;
  return 'LocaleDto(locale: ${_this.locale})';
}


}

/// @nodoc
abstract mixin class $LocaleDtoCopyWith<$Res>  {
  factory $LocaleDtoCopyWith(LocaleDto value, $Res Function(LocaleDto) _then) = _$LocaleDtoCopyWithImpl;
@useResult
$Res call({
 String? locale
});




}
/// @nodoc
class _$LocaleDtoCopyWithImpl<$Res>
    implements $LocaleDtoCopyWith<$Res> {
  _$LocaleDtoCopyWithImpl(this._self, this._then);

  final LocaleDto _self;
  final $Res Function(LocaleDto) _then;

/// Create a copy of LocaleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = freezed,}) {
  return _then(LocaleDto(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocaleDto].
extension LocaleDtoPatterns on LocaleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocaleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocaleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocaleDto value)  $default,){
final _that = this;
switch (_that) {
case _LocaleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocaleDto value)?  $default,){
final _that = this;
switch (_that) {
case _LocaleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? locale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocaleDto() when $default != null:
return $default(_that.locale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? locale)  $default,) {final _that = this;
switch (_that) {
case _LocaleDto():
return $default(_that.locale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? locale)?  $default,) {final _that = this;
switch (_that) {
case _LocaleDto() when $default != null:
return $default(_that.locale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocaleDto implements LocaleDto {
  const _LocaleDto({this.locale});
  factory _LocaleDto.fromJson(Map<String, dynamic> json) => _$LocaleDtoFromJson(json);

/// Language of the email (BCP-47).
@override final  String? locale;

/// Create a copy of LocaleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocaleDtoCopyWith<_LocaleDto> get copyWith => __$LocaleDtoCopyWithImpl<_LocaleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocaleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocaleDto&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,locale);
}

@override
String toString() {
    return 'LocaleDto(locale: $locale)';
}


}

/// @nodoc
abstract mixin class _$LocaleDtoCopyWith<$Res> implements $LocaleDtoCopyWith<$Res> {
  factory _$LocaleDtoCopyWith(_LocaleDto value, $Res Function(_LocaleDto) _then) = __$LocaleDtoCopyWithImpl;
@override @useResult
$Res call({
 String? locale
});




}
/// @nodoc
class __$LocaleDtoCopyWithImpl<$Res>
    implements _$LocaleDtoCopyWith<$Res> {
  __$LocaleDtoCopyWithImpl(this._self, this._then);

  final _LocaleDto _self;
  final $Res Function(_LocaleDto) _then;

/// Create a copy of LocaleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = freezed,}) {
  return _then(_LocaleDto(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
