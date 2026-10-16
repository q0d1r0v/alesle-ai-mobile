// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleaseDto {

 num get versionCode; String get versionName; String get apkUrl;/// Lowercase hex SHA-256 of the APK file.
 String get sha256;/// Lowercase hex SHA-256 of the signing certificate.
 String get certSha256; num get sizeBytes;/// Older version codes must update before using the app (EC-15).
 num get minSupportedVersionCode; ReleaseNotesDto get notes; DateTime get publishedAt;
/// Create a copy of ReleaseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseDtoCopyWith<ReleaseDto> get copyWith => _$ReleaseDtoCopyWithImpl<ReleaseDto>(this as ReleaseDto, _$identity);

  /// Serializes this ReleaseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReleaseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseDto&&(identical(other.versionCode, _this.versionCode) || other.versionCode == _this.versionCode)&&(identical(other.versionName, _this.versionName) || other.versionName == _this.versionName)&&(identical(other.apkUrl, _this.apkUrl) || other.apkUrl == _this.apkUrl)&&(identical(other.sha256, _this.sha256) || other.sha256 == _this.sha256)&&(identical(other.certSha256, _this.certSha256) || other.certSha256 == _this.certSha256)&&(identical(other.sizeBytes, _this.sizeBytes) || other.sizeBytes == _this.sizeBytes)&&(identical(other.minSupportedVersionCode, _this.minSupportedVersionCode) || other.minSupportedVersionCode == _this.minSupportedVersionCode)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.publishedAt, _this.publishedAt) || other.publishedAt == _this.publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReleaseDto;
  return Object.hash(runtimeType,_this.versionCode,_this.versionName,_this.apkUrl,_this.sha256,_this.certSha256,_this.sizeBytes,_this.minSupportedVersionCode,_this.notes,_this.publishedAt);
}

@override
String toString() {
  final _this = this as ReleaseDto;
  return 'ReleaseDto(versionCode: ${_this.versionCode}, versionName: ${_this.versionName}, apkUrl: ${_this.apkUrl}, sha256: ${_this.sha256}, certSha256: ${_this.certSha256}, sizeBytes: ${_this.sizeBytes}, minSupportedVersionCode: ${_this.minSupportedVersionCode}, notes: ${_this.notes}, publishedAt: ${_this.publishedAt})';
}


}

/// @nodoc
abstract mixin class $ReleaseDtoCopyWith<$Res>  {
  factory $ReleaseDtoCopyWith(ReleaseDto value, $Res Function(ReleaseDto) _then) = _$ReleaseDtoCopyWithImpl;
@useResult
$Res call({
 num versionCode, String versionName, String apkUrl, String sha256, String certSha256, num sizeBytes, num minSupportedVersionCode, ReleaseNotesDto notes, DateTime publishedAt
});


$ReleaseNotesDtoCopyWith<$Res> get notes;

}
/// @nodoc
class _$ReleaseDtoCopyWithImpl<$Res>
    implements $ReleaseDtoCopyWith<$Res> {
  _$ReleaseDtoCopyWithImpl(this._self, this._then);

  final ReleaseDto _self;
  final $Res Function(ReleaseDto) _then;

/// Create a copy of ReleaseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? versionCode = null,Object? versionName = null,Object? apkUrl = null,Object? sha256 = null,Object? certSha256 = null,Object? sizeBytes = null,Object? minSupportedVersionCode = null,Object? notes = null,Object? publishedAt = null,}) {
  return _then(ReleaseDto(
versionCode: null == versionCode ? _self.versionCode : versionCode // ignore: cast_nullable_to_non_nullable
as num,versionName: null == versionName ? _self.versionName : versionName // ignore: cast_nullable_to_non_nullable
as String,apkUrl: null == apkUrl ? _self.apkUrl : apkUrl // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,certSha256: null == certSha256 ? _self.certSha256 : certSha256 // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as num,minSupportedVersionCode: null == minSupportedVersionCode ? _self.minSupportedVersionCode : minSupportedVersionCode // ignore: cast_nullable_to_non_nullable
as num,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as ReleaseNotesDto,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ReleaseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseNotesDtoCopyWith<$Res> get notes {
  
  return $ReleaseNotesDtoCopyWith<$Res>(_self.notes, (value) {
    return _then(_self.copyWith(notes: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReleaseDto].
extension ReleaseDtoPatterns on ReleaseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseDto value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num versionCode,  String versionName,  String apkUrl,  String sha256,  String certSha256,  num sizeBytes,  num minSupportedVersionCode,  ReleaseNotesDto notes,  DateTime publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseDto() when $default != null:
return $default(_that.versionCode,_that.versionName,_that.apkUrl,_that.sha256,_that.certSha256,_that.sizeBytes,_that.minSupportedVersionCode,_that.notes,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num versionCode,  String versionName,  String apkUrl,  String sha256,  String certSha256,  num sizeBytes,  num minSupportedVersionCode,  ReleaseNotesDto notes,  DateTime publishedAt)  $default,) {final _that = this;
switch (_that) {
case _ReleaseDto():
return $default(_that.versionCode,_that.versionName,_that.apkUrl,_that.sha256,_that.certSha256,_that.sizeBytes,_that.minSupportedVersionCode,_that.notes,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num versionCode,  String versionName,  String apkUrl,  String sha256,  String certSha256,  num sizeBytes,  num minSupportedVersionCode,  ReleaseNotesDto notes,  DateTime publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseDto() when $default != null:
return $default(_that.versionCode,_that.versionName,_that.apkUrl,_that.sha256,_that.certSha256,_that.sizeBytes,_that.minSupportedVersionCode,_that.notes,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReleaseDto implements ReleaseDto {
  const _ReleaseDto({required this.versionCode, required this.versionName, required this.apkUrl, required this.sha256, required this.certSha256, required this.sizeBytes, required this.minSupportedVersionCode, required this.notes, required this.publishedAt});
  factory _ReleaseDto.fromJson(Map<String, dynamic> json) => _$ReleaseDtoFromJson(json);

@override final  num versionCode;
@override final  String versionName;
@override final  String apkUrl;
/// Lowercase hex SHA-256 of the APK file.
@override final  String sha256;
/// Lowercase hex SHA-256 of the signing certificate.
@override final  String certSha256;
@override final  num sizeBytes;
/// Older version codes must update before using the app (EC-15).
@override final  num minSupportedVersionCode;
@override final  ReleaseNotesDto notes;
@override final  DateTime publishedAt;

/// Create a copy of ReleaseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseDtoCopyWith<_ReleaseDto> get copyWith => __$ReleaseDtoCopyWithImpl<_ReleaseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseDto&&(identical(other.versionCode, versionCode) || other.versionCode == versionCode)&&(identical(other.versionName, versionName) || other.versionName == versionName)&&(identical(other.apkUrl, apkUrl) || other.apkUrl == apkUrl)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.certSha256, certSha256) || other.certSha256 == certSha256)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.minSupportedVersionCode, minSupportedVersionCode) || other.minSupportedVersionCode == minSupportedVersionCode)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,versionCode,versionName,apkUrl,sha256,certSha256,sizeBytes,minSupportedVersionCode,notes,publishedAt);
}

@override
String toString() {
    return 'ReleaseDto(versionCode: $versionCode, versionName: $versionName, apkUrl: $apkUrl, sha256: $sha256, certSha256: $certSha256, sizeBytes: $sizeBytes, minSupportedVersionCode: $minSupportedVersionCode, notes: $notes, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$ReleaseDtoCopyWith<$Res> implements $ReleaseDtoCopyWith<$Res> {
  factory _$ReleaseDtoCopyWith(_ReleaseDto value, $Res Function(_ReleaseDto) _then) = __$ReleaseDtoCopyWithImpl;
@override @useResult
$Res call({
 num versionCode, String versionName, String apkUrl, String sha256, String certSha256, num sizeBytes, num minSupportedVersionCode, ReleaseNotesDto notes, DateTime publishedAt
});


@override $ReleaseNotesDtoCopyWith<$Res> get notes;

}
/// @nodoc
class __$ReleaseDtoCopyWithImpl<$Res>
    implements _$ReleaseDtoCopyWith<$Res> {
  __$ReleaseDtoCopyWithImpl(this._self, this._then);

  final _ReleaseDto _self;
  final $Res Function(_ReleaseDto) _then;

/// Create a copy of ReleaseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? versionCode = null,Object? versionName = null,Object? apkUrl = null,Object? sha256 = null,Object? certSha256 = null,Object? sizeBytes = null,Object? minSupportedVersionCode = null,Object? notes = null,Object? publishedAt = null,}) {
  return _then(_ReleaseDto(
versionCode: null == versionCode ? _self.versionCode : versionCode // ignore: cast_nullable_to_non_nullable
as num,versionName: null == versionName ? _self.versionName : versionName // ignore: cast_nullable_to_non_nullable
as String,apkUrl: null == apkUrl ? _self.apkUrl : apkUrl // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,certSha256: null == certSha256 ? _self.certSha256 : certSha256 // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as num,minSupportedVersionCode: null == minSupportedVersionCode ? _self.minSupportedVersionCode : minSupportedVersionCode // ignore: cast_nullable_to_non_nullable
as num,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as ReleaseNotesDto,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ReleaseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseNotesDtoCopyWith<$Res> get notes {
  
  return $ReleaseNotesDtoCopyWith<$Res>(_self.notes, (value) {
    return _then(_self.copyWith(notes: value));
  });
}
}

// dart format on
