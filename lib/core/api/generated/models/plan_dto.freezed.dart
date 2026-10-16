// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlanDto {

 String get code; ProductKind get kind;/// UZS, as a decimal string.
 String get priceUzs;/// USD for display, as a decimal string.
 String get priceUsd;/// Commands per day; null: no cap.
 num? get dailyCommands;/// Screen tasks per day; null: no cap.
 num? get dailyScreenTasks; bool get vision; bool get strongModel;
/// Create a copy of PlanDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanDtoCopyWith<PlanDto> get copyWith => _$PlanDtoCopyWithImpl<PlanDto>(this as PlanDto, _$identity);

  /// Serializes this PlanDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlanDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanDto&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.priceUzs, _this.priceUzs) || other.priceUzs == _this.priceUzs)&&(identical(other.priceUsd, _this.priceUsd) || other.priceUsd == _this.priceUsd)&&(identical(other.dailyCommands, _this.dailyCommands) || other.dailyCommands == _this.dailyCommands)&&(identical(other.dailyScreenTasks, _this.dailyScreenTasks) || other.dailyScreenTasks == _this.dailyScreenTasks)&&(identical(other.vision, _this.vision) || other.vision == _this.vision)&&(identical(other.strongModel, _this.strongModel) || other.strongModel == _this.strongModel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlanDto;
  return Object.hash(runtimeType,_this.code,_this.kind,_this.priceUzs,_this.priceUsd,_this.dailyCommands,_this.dailyScreenTasks,_this.vision,_this.strongModel);
}

@override
String toString() {
  final _this = this as PlanDto;
  return 'PlanDto(code: ${_this.code}, kind: ${_this.kind}, priceUzs: ${_this.priceUzs}, priceUsd: ${_this.priceUsd}, dailyCommands: ${_this.dailyCommands}, dailyScreenTasks: ${_this.dailyScreenTasks}, vision: ${_this.vision}, strongModel: ${_this.strongModel})';
}


}

/// @nodoc
abstract mixin class $PlanDtoCopyWith<$Res>  {
  factory $PlanDtoCopyWith(PlanDto value, $Res Function(PlanDto) _then) = _$PlanDtoCopyWithImpl;
@useResult
$Res call({
 String code, ProductKind kind, String priceUzs, String priceUsd, num? dailyCommands, num? dailyScreenTasks, bool vision, bool strongModel
});




}
/// @nodoc
class _$PlanDtoCopyWithImpl<$Res>
    implements $PlanDtoCopyWith<$Res> {
  _$PlanDtoCopyWithImpl(this._self, this._then);

  final PlanDto _self;
  final $Res Function(PlanDto) _then;

/// Create a copy of PlanDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? kind = null,Object? priceUzs = null,Object? priceUsd = null,Object? dailyCommands = freezed,Object? dailyScreenTasks = freezed,Object? vision = null,Object? strongModel = null,}) {
  return _then(PlanDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ProductKind,priceUzs: null == priceUzs ? _self.priceUzs : priceUzs // ignore: cast_nullable_to_non_nullable
as String,priceUsd: null == priceUsd ? _self.priceUsd : priceUsd // ignore: cast_nullable_to_non_nullable
as String,dailyCommands: freezed == dailyCommands ? _self.dailyCommands : dailyCommands // ignore: cast_nullable_to_non_nullable
as num?,dailyScreenTasks: freezed == dailyScreenTasks ? _self.dailyScreenTasks : dailyScreenTasks // ignore: cast_nullable_to_non_nullable
as num?,vision: null == vision ? _self.vision : vision // ignore: cast_nullable_to_non_nullable
as bool,strongModel: null == strongModel ? _self.strongModel : strongModel // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanDto].
extension PlanDtoPatterns on PlanDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanDto value)  $default,){
final _that = this;
switch (_that) {
case _PlanDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlanDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  ProductKind kind,  String priceUzs,  String priceUsd,  num? dailyCommands,  num? dailyScreenTasks,  bool vision,  bool strongModel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanDto() when $default != null:
return $default(_that.code,_that.kind,_that.priceUzs,_that.priceUsd,_that.dailyCommands,_that.dailyScreenTasks,_that.vision,_that.strongModel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  ProductKind kind,  String priceUzs,  String priceUsd,  num? dailyCommands,  num? dailyScreenTasks,  bool vision,  bool strongModel)  $default,) {final _that = this;
switch (_that) {
case _PlanDto():
return $default(_that.code,_that.kind,_that.priceUzs,_that.priceUsd,_that.dailyCommands,_that.dailyScreenTasks,_that.vision,_that.strongModel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  ProductKind kind,  String priceUzs,  String priceUsd,  num? dailyCommands,  num? dailyScreenTasks,  bool vision,  bool strongModel)?  $default,) {final _that = this;
switch (_that) {
case _PlanDto() when $default != null:
return $default(_that.code,_that.kind,_that.priceUzs,_that.priceUsd,_that.dailyCommands,_that.dailyScreenTasks,_that.vision,_that.strongModel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanDto implements PlanDto {
  const _PlanDto({required this.code, required this.kind, required this.priceUzs, required this.priceUsd, required this.dailyCommands, required this.dailyScreenTasks, required this.vision, required this.strongModel});
  factory _PlanDto.fromJson(Map<String, dynamic> json) => _$PlanDtoFromJson(json);

@override final  String code;
@override final  ProductKind kind;
/// UZS, as a decimal string.
@override final  String priceUzs;
/// USD for display, as a decimal string.
@override final  String priceUsd;
/// Commands per day; null: no cap.
@override final  num? dailyCommands;
/// Screen tasks per day; null: no cap.
@override final  num? dailyScreenTasks;
@override final  bool vision;
@override final  bool strongModel;

/// Create a copy of PlanDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanDtoCopyWith<_PlanDto> get copyWith => __$PlanDtoCopyWithImpl<_PlanDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanDto&&(identical(other.code, code) || other.code == code)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.priceUzs, priceUzs) || other.priceUzs == priceUzs)&&(identical(other.priceUsd, priceUsd) || other.priceUsd == priceUsd)&&(identical(other.dailyCommands, dailyCommands) || other.dailyCommands == dailyCommands)&&(identical(other.dailyScreenTasks, dailyScreenTasks) || other.dailyScreenTasks == dailyScreenTasks)&&(identical(other.vision, vision) || other.vision == vision)&&(identical(other.strongModel, strongModel) || other.strongModel == strongModel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,kind,priceUzs,priceUsd,dailyCommands,dailyScreenTasks,vision,strongModel);
}

@override
String toString() {
    return 'PlanDto(code: $code, kind: $kind, priceUzs: $priceUzs, priceUsd: $priceUsd, dailyCommands: $dailyCommands, dailyScreenTasks: $dailyScreenTasks, vision: $vision, strongModel: $strongModel)';
}


}

/// @nodoc
abstract mixin class _$PlanDtoCopyWith<$Res> implements $PlanDtoCopyWith<$Res> {
  factory _$PlanDtoCopyWith(_PlanDto value, $Res Function(_PlanDto) _then) = __$PlanDtoCopyWithImpl;
@override @useResult
$Res call({
 String code, ProductKind kind, String priceUzs, String priceUsd, num? dailyCommands, num? dailyScreenTasks, bool vision, bool strongModel
});




}
/// @nodoc
class __$PlanDtoCopyWithImpl<$Res>
    implements _$PlanDtoCopyWith<$Res> {
  __$PlanDtoCopyWithImpl(this._self, this._then);

  final _PlanDto _self;
  final $Res Function(_PlanDto) _then;

/// Create a copy of PlanDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? kind = null,Object? priceUzs = null,Object? priceUsd = null,Object? dailyCommands = freezed,Object? dailyScreenTasks = freezed,Object? vision = null,Object? strongModel = null,}) {
  return _then(_PlanDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ProductKind,priceUzs: null == priceUzs ? _self.priceUzs : priceUzs // ignore: cast_nullable_to_non_nullable
as String,priceUsd: null == priceUsd ? _self.priceUsd : priceUsd // ignore: cast_nullable_to_non_nullable
as String,dailyCommands: freezed == dailyCommands ? _self.dailyCommands : dailyCommands // ignore: cast_nullable_to_non_nullable
as num?,dailyScreenTasks: freezed == dailyScreenTasks ? _self.dailyScreenTasks : dailyScreenTasks // ignore: cast_nullable_to_non_nullable
as num?,vision: null == vision ? _self.vision : vision // ignore: cast_nullable_to_non_nullable
as bool,strongModel: null == strongModel ? _self.strongModel : strongModel // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
