// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'billing_status_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillingStatusDto {

 String get plan;/// Share of this period’s allowance used, 0–100 (D9).
 num get usedPercent;/// Allowance used up: simple mode until the period ends.
 bool get simple; DateTime get periodEnd;/// Paid plan state; null on Free.
 BillingStatusDtoSubscriptionStatus? get subscriptionStatus; bool get cancelAtPeriodEnd;/// Payment methods set up here.
 List<BillingStatusDtoProviders> get providers;
/// Create a copy of BillingStatusDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingStatusDtoCopyWith<BillingStatusDto> get copyWith => _$BillingStatusDtoCopyWithImpl<BillingStatusDto>(this as BillingStatusDto, _$identity);

  /// Serializes this BillingStatusDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BillingStatusDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingStatusDto&&(identical(other.plan, _this.plan) || other.plan == _this.plan)&&(identical(other.usedPercent, _this.usedPercent) || other.usedPercent == _this.usedPercent)&&(identical(other.simple, _this.simple) || other.simple == _this.simple)&&(identical(other.periodEnd, _this.periodEnd) || other.periodEnd == _this.periodEnd)&&(identical(other.subscriptionStatus, _this.subscriptionStatus) || other.subscriptionStatus == _this.subscriptionStatus)&&(identical(other.cancelAtPeriodEnd, _this.cancelAtPeriodEnd) || other.cancelAtPeriodEnd == _this.cancelAtPeriodEnd)&&const DeepCollectionEquality().equals(other.providers, _this.providers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BillingStatusDto;
  return Object.hash(runtimeType,_this.plan,_this.usedPercent,_this.simple,_this.periodEnd,_this.subscriptionStatus,_this.cancelAtPeriodEnd,const DeepCollectionEquality().hash(_this.providers));
}

@override
String toString() {
  final _this = this as BillingStatusDto;
  return 'BillingStatusDto(plan: ${_this.plan}, usedPercent: ${_this.usedPercent}, simple: ${_this.simple}, periodEnd: ${_this.periodEnd}, subscriptionStatus: ${_this.subscriptionStatus}, cancelAtPeriodEnd: ${_this.cancelAtPeriodEnd}, providers: ${_this.providers})';
}


}

/// @nodoc
abstract mixin class $BillingStatusDtoCopyWith<$Res>  {
  factory $BillingStatusDtoCopyWith(BillingStatusDto value, $Res Function(BillingStatusDto) _then) = _$BillingStatusDtoCopyWithImpl;
@useResult
$Res call({
 String plan, num usedPercent, bool simple, DateTime periodEnd, BillingStatusDtoSubscriptionStatus? subscriptionStatus, bool cancelAtPeriodEnd, List<BillingStatusDtoProviders> providers
});




}
/// @nodoc
class _$BillingStatusDtoCopyWithImpl<$Res>
    implements $BillingStatusDtoCopyWith<$Res> {
  _$BillingStatusDtoCopyWithImpl(this._self, this._then);

  final BillingStatusDto _self;
  final $Res Function(BillingStatusDto) _then;

/// Create a copy of BillingStatusDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plan = null,Object? usedPercent = null,Object? simple = null,Object? periodEnd = null,Object? subscriptionStatus = freezed,Object? cancelAtPeriodEnd = null,Object? providers = null,}) {
  return _then(BillingStatusDto(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,usedPercent: null == usedPercent ? _self.usedPercent : usedPercent // ignore: cast_nullable_to_non_nullable
as num,simple: null == simple ? _self.simple : simple // ignore: cast_nullable_to_non_nullable
as bool,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,subscriptionStatus: freezed == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as BillingStatusDtoSubscriptionStatus?,cancelAtPeriodEnd: null == cancelAtPeriodEnd ? _self.cancelAtPeriodEnd : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
as bool,providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as List<BillingStatusDtoProviders>,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingStatusDto].
extension BillingStatusDtoPatterns on BillingStatusDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingStatusDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingStatusDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingStatusDto value)  $default,){
final _that = this;
switch (_that) {
case _BillingStatusDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingStatusDto value)?  $default,){
final _that = this;
switch (_that) {
case _BillingStatusDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String plan,  num usedPercent,  bool simple,  DateTime periodEnd,  BillingStatusDtoSubscriptionStatus? subscriptionStatus,  bool cancelAtPeriodEnd,  List<BillingStatusDtoProviders> providers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingStatusDto() when $default != null:
return $default(_that.plan,_that.usedPercent,_that.simple,_that.periodEnd,_that.subscriptionStatus,_that.cancelAtPeriodEnd,_that.providers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String plan,  num usedPercent,  bool simple,  DateTime periodEnd,  BillingStatusDtoSubscriptionStatus? subscriptionStatus,  bool cancelAtPeriodEnd,  List<BillingStatusDtoProviders> providers)  $default,) {final _that = this;
switch (_that) {
case _BillingStatusDto():
return $default(_that.plan,_that.usedPercent,_that.simple,_that.periodEnd,_that.subscriptionStatus,_that.cancelAtPeriodEnd,_that.providers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String plan,  num usedPercent,  bool simple,  DateTime periodEnd,  BillingStatusDtoSubscriptionStatus? subscriptionStatus,  bool cancelAtPeriodEnd,  List<BillingStatusDtoProviders> providers)?  $default,) {final _that = this;
switch (_that) {
case _BillingStatusDto() when $default != null:
return $default(_that.plan,_that.usedPercent,_that.simple,_that.periodEnd,_that.subscriptionStatus,_that.cancelAtPeriodEnd,_that.providers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingStatusDto implements BillingStatusDto {
  const _BillingStatusDto({required this.plan, required this.usedPercent, required this.simple, required this.periodEnd, required this.subscriptionStatus, required this.cancelAtPeriodEnd, required  List<BillingStatusDtoProviders> providers}): _providers = providers;
  factory _BillingStatusDto.fromJson(Map<String, dynamic> json) => _$BillingStatusDtoFromJson(json);

@override final  String plan;
/// Share of this period’s allowance used, 0–100 (D9).
@override final  num usedPercent;
/// Allowance used up: simple mode until the period ends.
@override final  bool simple;
@override final  DateTime periodEnd;
/// Paid plan state; null on Free.
@override final  BillingStatusDtoSubscriptionStatus? subscriptionStatus;
@override final  bool cancelAtPeriodEnd;
/// Payment methods set up here.
 final  List<BillingStatusDtoProviders> _providers;
/// Payment methods set up here.
@override List<BillingStatusDtoProviders> get providers {
  if (_providers is EqualUnmodifiableListView) return _providers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providers);
}


/// Create a copy of BillingStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingStatusDtoCopyWith<_BillingStatusDto> get copyWith => __$BillingStatusDtoCopyWithImpl<_BillingStatusDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingStatusDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingStatusDto&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.usedPercent, usedPercent) || other.usedPercent == usedPercent)&&(identical(other.simple, simple) || other.simple == simple)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.cancelAtPeriodEnd, cancelAtPeriodEnd) || other.cancelAtPeriodEnd == cancelAtPeriodEnd)&&const DeepCollectionEquality().equals(other.providers, _providers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,plan,usedPercent,simple,periodEnd,subscriptionStatus,cancelAtPeriodEnd,const DeepCollectionEquality().hash(_providers));
}

@override
String toString() {
    return 'BillingStatusDto(plan: $plan, usedPercent: $usedPercent, simple: $simple, periodEnd: $periodEnd, subscriptionStatus: $subscriptionStatus, cancelAtPeriodEnd: $cancelAtPeriodEnd, providers: $providers)';
}


}

/// @nodoc
abstract mixin class _$BillingStatusDtoCopyWith<$Res> implements $BillingStatusDtoCopyWith<$Res> {
  factory _$BillingStatusDtoCopyWith(_BillingStatusDto value, $Res Function(_BillingStatusDto) _then) = __$BillingStatusDtoCopyWithImpl;
@override @useResult
$Res call({
 String plan, num usedPercent, bool simple, DateTime periodEnd, BillingStatusDtoSubscriptionStatus? subscriptionStatus, bool cancelAtPeriodEnd, List<BillingStatusDtoProviders> providers
});




}
/// @nodoc
class __$BillingStatusDtoCopyWithImpl<$Res>
    implements _$BillingStatusDtoCopyWith<$Res> {
  __$BillingStatusDtoCopyWithImpl(this._self, this._then);

  final _BillingStatusDto _self;
  final $Res Function(_BillingStatusDto) _then;

/// Create a copy of BillingStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? usedPercent = null,Object? simple = null,Object? periodEnd = null,Object? subscriptionStatus = freezed,Object? cancelAtPeriodEnd = null,Object? providers = null,}) {
  return _then(_BillingStatusDto(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,usedPercent: null == usedPercent ? _self.usedPercent : usedPercent // ignore: cast_nullable_to_non_nullable
as num,simple: null == simple ? _self.simple : simple // ignore: cast_nullable_to_non_nullable
as bool,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,subscriptionStatus: freezed == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as BillingStatusDtoSubscriptionStatus?,cancelAtPeriodEnd: null == cancelAtPeriodEnd ? _self.cancelAtPeriodEnd : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
as bool,providers: null == providers ? _self._providers : providers // ignore: cast_nullable_to_non_nullable
as List<BillingStatusDtoProviders>,
  ));
}


}

// dart format on
