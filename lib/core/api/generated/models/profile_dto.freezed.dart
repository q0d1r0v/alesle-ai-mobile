// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileDto {

 String get id; String get email;/// Confirmed by a link (EC-AU-3).
 bool get emailVerified; String? get displayName; ProfileLanguage get language; String get timeZone;/// "Confirm every sensitive action" (D11).
 bool get confirmSensitiveActions;/// The account can sign in with a password.
 bool get hasPassword;/// A Google account is linked.
 bool get googleLinked;/// Deletion requested: the account is erased at this time unless cancelled.
 DateTime? get deletionScheduledAt;
/// Create a copy of ProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileDtoCopyWith<ProfileDto> get copyWith => _$ProfileDtoCopyWithImpl<ProfileDto>(this as ProfileDto, _$identity);

  /// Serializes this ProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProfileDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.emailVerified, _this.emailVerified) || other.emailVerified == _this.emailVerified)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.timeZone, _this.timeZone) || other.timeZone == _this.timeZone)&&(identical(other.confirmSensitiveActions, _this.confirmSensitiveActions) || other.confirmSensitiveActions == _this.confirmSensitiveActions)&&(identical(other.hasPassword, _this.hasPassword) || other.hasPassword == _this.hasPassword)&&(identical(other.googleLinked, _this.googleLinked) || other.googleLinked == _this.googleLinked)&&(identical(other.deletionScheduledAt, _this.deletionScheduledAt) || other.deletionScheduledAt == _this.deletionScheduledAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProfileDto;
  return Object.hash(runtimeType,_this.id,_this.email,_this.emailVerified,_this.displayName,_this.language,_this.timeZone,_this.confirmSensitiveActions,_this.hasPassword,_this.googleLinked,_this.deletionScheduledAt);
}

@override
String toString() {
  final _this = this as ProfileDto;
  return 'ProfileDto(id: ${_this.id}, email: ${_this.email}, emailVerified: ${_this.emailVerified}, displayName: ${_this.displayName}, language: ${_this.language}, timeZone: ${_this.timeZone}, confirmSensitiveActions: ${_this.confirmSensitiveActions}, hasPassword: ${_this.hasPassword}, googleLinked: ${_this.googleLinked}, deletionScheduledAt: ${_this.deletionScheduledAt})';
}


}

/// @nodoc
abstract mixin class $ProfileDtoCopyWith<$Res>  {
  factory $ProfileDtoCopyWith(ProfileDto value, $Res Function(ProfileDto) _then) = _$ProfileDtoCopyWithImpl;
@useResult
$Res call({
 String id, String email, bool emailVerified, String? displayName, ProfileLanguage language, String timeZone, bool confirmSensitiveActions, bool hasPassword, bool googleLinked, DateTime? deletionScheduledAt
});




}
/// @nodoc
class _$ProfileDtoCopyWithImpl<$Res>
    implements $ProfileDtoCopyWith<$Res> {
  _$ProfileDtoCopyWithImpl(this._self, this._then);

  final ProfileDto _self;
  final $Res Function(ProfileDto) _then;

/// Create a copy of ProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? emailVerified = null,Object? displayName = freezed,Object? language = null,Object? timeZone = null,Object? confirmSensitiveActions = null,Object? hasPassword = null,Object? googleLinked = null,Object? deletionScheduledAt = freezed,}) {
  return _then(ProfileDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as ProfileLanguage,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,confirmSensitiveActions: null == confirmSensitiveActions ? _self.confirmSensitiveActions : confirmSensitiveActions // ignore: cast_nullable_to_non_nullable
as bool,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,googleLinked: null == googleLinked ? _self.googleLinked : googleLinked // ignore: cast_nullable_to_non_nullable
as bool,deletionScheduledAt: freezed == deletionScheduledAt ? _self.deletionScheduledAt : deletionScheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileDto].
extension ProfileDtoPatterns on ProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _ProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  bool emailVerified,  String? displayName,  ProfileLanguage language,  String timeZone,  bool confirmSensitiveActions,  bool hasPassword,  bool googleLinked,  DateTime? deletionScheduledAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileDto() when $default != null:
return $default(_that.id,_that.email,_that.emailVerified,_that.displayName,_that.language,_that.timeZone,_that.confirmSensitiveActions,_that.hasPassword,_that.googleLinked,_that.deletionScheduledAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  bool emailVerified,  String? displayName,  ProfileLanguage language,  String timeZone,  bool confirmSensitiveActions,  bool hasPassword,  bool googleLinked,  DateTime? deletionScheduledAt)  $default,) {final _that = this;
switch (_that) {
case _ProfileDto():
return $default(_that.id,_that.email,_that.emailVerified,_that.displayName,_that.language,_that.timeZone,_that.confirmSensitiveActions,_that.hasPassword,_that.googleLinked,_that.deletionScheduledAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  bool emailVerified,  String? displayName,  ProfileLanguage language,  String timeZone,  bool confirmSensitiveActions,  bool hasPassword,  bool googleLinked,  DateTime? deletionScheduledAt)?  $default,) {final _that = this;
switch (_that) {
case _ProfileDto() when $default != null:
return $default(_that.id,_that.email,_that.emailVerified,_that.displayName,_that.language,_that.timeZone,_that.confirmSensitiveActions,_that.hasPassword,_that.googleLinked,_that.deletionScheduledAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileDto implements ProfileDto {
  const _ProfileDto({required this.id, required this.email, required this.emailVerified, required this.displayName, required this.language, required this.timeZone, required this.confirmSensitiveActions, required this.hasPassword, required this.googleLinked, required this.deletionScheduledAt});
  factory _ProfileDto.fromJson(Map<String, dynamic> json) => _$ProfileDtoFromJson(json);

@override final  String id;
@override final  String email;
/// Confirmed by a link (EC-AU-3).
@override final  bool emailVerified;
@override final  String? displayName;
@override final  ProfileLanguage language;
@override final  String timeZone;
/// "Confirm every sensitive action" (D11).
@override final  bool confirmSensitiveActions;
/// The account can sign in with a password.
@override final  bool hasPassword;
/// A Google account is linked.
@override final  bool googleLinked;
/// Deletion requested: the account is erased at this time unless cancelled.
@override final  DateTime? deletionScheduledAt;

/// Create a copy of ProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileDtoCopyWith<_ProfileDto> get copyWith => __$ProfileDtoCopyWithImpl<_ProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileDto&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.language, language) || other.language == language)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.confirmSensitiveActions, confirmSensitiveActions) || other.confirmSensitiveActions == confirmSensitiveActions)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.googleLinked, googleLinked) || other.googleLinked == googleLinked)&&(identical(other.deletionScheduledAt, deletionScheduledAt) || other.deletionScheduledAt == deletionScheduledAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,email,emailVerified,displayName,language,timeZone,confirmSensitiveActions,hasPassword,googleLinked,deletionScheduledAt);
}

@override
String toString() {
    return 'ProfileDto(id: $id, email: $email, emailVerified: $emailVerified, displayName: $displayName, language: $language, timeZone: $timeZone, confirmSensitiveActions: $confirmSensitiveActions, hasPassword: $hasPassword, googleLinked: $googleLinked, deletionScheduledAt: $deletionScheduledAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileDtoCopyWith<$Res> implements $ProfileDtoCopyWith<$Res> {
  factory _$ProfileDtoCopyWith(_ProfileDto value, $Res Function(_ProfileDto) _then) = __$ProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, bool emailVerified, String? displayName, ProfileLanguage language, String timeZone, bool confirmSensitiveActions, bool hasPassword, bool googleLinked, DateTime? deletionScheduledAt
});




}
/// @nodoc
class __$ProfileDtoCopyWithImpl<$Res>
    implements _$ProfileDtoCopyWith<$Res> {
  __$ProfileDtoCopyWithImpl(this._self, this._then);

  final _ProfileDto _self;
  final $Res Function(_ProfileDto) _then;

/// Create a copy of ProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? emailVerified = null,Object? displayName = freezed,Object? language = null,Object? timeZone = null,Object? confirmSensitiveActions = null,Object? hasPassword = null,Object? googleLinked = null,Object? deletionScheduledAt = freezed,}) {
  return _then(_ProfileDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as ProfileLanguage,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,confirmSensitiveActions: null == confirmSensitiveActions ? _self.confirmSensitiveActions : confirmSensitiveActions // ignore: cast_nullable_to_non_nullable
as bool,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,googleLinked: null == googleLinked ? _self.googleLinked : googleLinked // ignore: cast_nullable_to_non_nullable
as bool,deletionScheduledAt: freezed == deletionScheduledAt ? _self.deletionScheduledAt : deletionScheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
