// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateProfileDto {

 String? get displayName; ProfileLanguage? get language; String? get timeZone; bool? get confirmSensitiveActions;
/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateProfileDtoCopyWith<UpdateProfileDto> get copyWith => _$UpdateProfileDtoCopyWithImpl<UpdateProfileDto>(this as UpdateProfileDto, _$identity);

  /// Serializes this UpdateProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateProfileDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateProfileDto&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.timeZone, _this.timeZone) || other.timeZone == _this.timeZone)&&(identical(other.confirmSensitiveActions, _this.confirmSensitiveActions) || other.confirmSensitiveActions == _this.confirmSensitiveActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateProfileDto;
  return Object.hash(runtimeType,_this.displayName,_this.language,_this.timeZone,_this.confirmSensitiveActions);
}

@override
String toString() {
  final _this = this as UpdateProfileDto;
  return 'UpdateProfileDto(displayName: ${_this.displayName}, language: ${_this.language}, timeZone: ${_this.timeZone}, confirmSensitiveActions: ${_this.confirmSensitiveActions})';
}


}

/// @nodoc
abstract mixin class $UpdateProfileDtoCopyWith<$Res>  {
  factory $UpdateProfileDtoCopyWith(UpdateProfileDto value, $Res Function(UpdateProfileDto) _then) = _$UpdateProfileDtoCopyWithImpl;
@useResult
$Res call({
 String? displayName, ProfileLanguage? language, String? timeZone, bool? confirmSensitiveActions
});




}
/// @nodoc
class _$UpdateProfileDtoCopyWithImpl<$Res>
    implements $UpdateProfileDtoCopyWith<$Res> {
  _$UpdateProfileDtoCopyWithImpl(this._self, this._then);

  final UpdateProfileDto _self;
  final $Res Function(UpdateProfileDto) _then;

/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = freezed,Object? language = freezed,Object? timeZone = freezed,Object? confirmSensitiveActions = freezed,}) {
  return _then(UpdateProfileDto(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as ProfileLanguage?,timeZone: freezed == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String?,confirmSensitiveActions: freezed == confirmSensitiveActions ? _self.confirmSensitiveActions : confirmSensitiveActions // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateProfileDto].
extension UpdateProfileDtoPatterns on UpdateProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? displayName,  ProfileLanguage? language,  String? timeZone,  bool? confirmSensitiveActions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
return $default(_that.displayName,_that.language,_that.timeZone,_that.confirmSensitiveActions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? displayName,  ProfileLanguage? language,  String? timeZone,  bool? confirmSensitiveActions)  $default,) {final _that = this;
switch (_that) {
case _UpdateProfileDto():
return $default(_that.displayName,_that.language,_that.timeZone,_that.confirmSensitiveActions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? displayName,  ProfileLanguage? language,  String? timeZone,  bool? confirmSensitiveActions)?  $default,) {final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
return $default(_that.displayName,_that.language,_that.timeZone,_that.confirmSensitiveActions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateProfileDto implements UpdateProfileDto {
  const _UpdateProfileDto({required this.displayName, required this.language, required this.timeZone, required this.confirmSensitiveActions});
  factory _UpdateProfileDto.fromJson(Map<String, dynamic> json) => _$UpdateProfileDtoFromJson(json);

@override final  String? displayName;
@override final  ProfileLanguage? language;
@override final  String? timeZone;
@override final  bool? confirmSensitiveActions;

/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateProfileDtoCopyWith<_UpdateProfileDto> get copyWith => __$UpdateProfileDtoCopyWithImpl<_UpdateProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateProfileDto&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.language, language) || other.language == language)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.confirmSensitiveActions, confirmSensitiveActions) || other.confirmSensitiveActions == confirmSensitiveActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,displayName,language,timeZone,confirmSensitiveActions);
}

@override
String toString() {
    return 'UpdateProfileDto(displayName: $displayName, language: $language, timeZone: $timeZone, confirmSensitiveActions: $confirmSensitiveActions)';
}


}

/// @nodoc
abstract mixin class _$UpdateProfileDtoCopyWith<$Res> implements $UpdateProfileDtoCopyWith<$Res> {
  factory _$UpdateProfileDtoCopyWith(_UpdateProfileDto value, $Res Function(_UpdateProfileDto) _then) = __$UpdateProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 String? displayName, ProfileLanguage? language, String? timeZone, bool? confirmSensitiveActions
});




}
/// @nodoc
class __$UpdateProfileDtoCopyWithImpl<$Res>
    implements _$UpdateProfileDtoCopyWith<$Res> {
  __$UpdateProfileDtoCopyWithImpl(this._self, this._then);

  final _UpdateProfileDto _self;
  final $Res Function(_UpdateProfileDto) _then;

/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = freezed,Object? language = freezed,Object? timeZone = freezed,Object? confirmSensitiveActions = freezed,}) {
  return _then(_UpdateProfileDto(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as ProfileLanguage?,timeZone: freezed == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String?,confirmSensitiveActions: freezed == confirmSensitiveActions ? _self.confirmSensitiveActions : confirmSensitiveActions // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
