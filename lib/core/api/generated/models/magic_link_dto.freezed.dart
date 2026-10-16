// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'magic_link_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MagicLinkDto {

 String get email; String? get locale;
/// Create a copy of MagicLinkDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MagicLinkDtoCopyWith<MagicLinkDto> get copyWith => _$MagicLinkDtoCopyWithImpl<MagicLinkDto>(this as MagicLinkDto, _$identity);

  /// Serializes this MagicLinkDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MagicLinkDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MagicLinkDto&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.locale, _this.locale) || other.locale == _this.locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MagicLinkDto;
  return Object.hash(runtimeType,_this.email,_this.locale);
}

@override
String toString() {
  final _this = this as MagicLinkDto;
  return 'MagicLinkDto(email: ${_this.email}, locale: ${_this.locale})';
}


}

/// @nodoc
abstract mixin class $MagicLinkDtoCopyWith<$Res>  {
  factory $MagicLinkDtoCopyWith(MagicLinkDto value, $Res Function(MagicLinkDto) _then) = _$MagicLinkDtoCopyWithImpl;
@useResult
$Res call({
 String email, String? locale
});




}
/// @nodoc
class _$MagicLinkDtoCopyWithImpl<$Res>
    implements $MagicLinkDtoCopyWith<$Res> {
  _$MagicLinkDtoCopyWithImpl(this._self, this._then);

  final MagicLinkDto _self;
  final $Res Function(MagicLinkDto) _then;

/// Create a copy of MagicLinkDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? locale = freezed,}) {
  return _then(MagicLinkDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MagicLinkDto].
extension MagicLinkDtoPatterns on MagicLinkDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MagicLinkDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MagicLinkDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MagicLinkDto value)  $default,){
final _that = this;
switch (_that) {
case _MagicLinkDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MagicLinkDto value)?  $default,){
final _that = this;
switch (_that) {
case _MagicLinkDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String? locale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MagicLinkDto() when $default != null:
return $default(_that.email,_that.locale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String? locale)  $default,) {final _that = this;
switch (_that) {
case _MagicLinkDto():
return $default(_that.email,_that.locale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String? locale)?  $default,) {final _that = this;
switch (_that) {
case _MagicLinkDto() when $default != null:
return $default(_that.email,_that.locale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MagicLinkDto implements MagicLinkDto {
  const _MagicLinkDto({required this.email, this.locale});
  factory _MagicLinkDto.fromJson(Map<String, dynamic> json) => _$MagicLinkDtoFromJson(json);

@override final  String email;
@override final  String? locale;

/// Create a copy of MagicLinkDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MagicLinkDtoCopyWith<_MagicLinkDto> get copyWith => __$MagicLinkDtoCopyWithImpl<_MagicLinkDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MagicLinkDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MagicLinkDto&&(identical(other.email, email) || other.email == email)&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,locale);
}

@override
String toString() {
    return 'MagicLinkDto(email: $email, locale: $locale)';
}


}

/// @nodoc
abstract mixin class _$MagicLinkDtoCopyWith<$Res> implements $MagicLinkDtoCopyWith<$Res> {
  factory _$MagicLinkDtoCopyWith(_MagicLinkDto value, $Res Function(_MagicLinkDto) _then) = __$MagicLinkDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, String? locale
});




}
/// @nodoc
class __$MagicLinkDtoCopyWithImpl<$Res>
    implements _$MagicLinkDtoCopyWith<$Res> {
  __$MagicLinkDtoCopyWithImpl(this._self, this._then);

  final _MagicLinkDto _self;
  final $Res Function(_MagicLinkDto) _then;

/// Create a copy of MagicLinkDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? locale = freezed,}) {
  return _then(_MagicLinkDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
