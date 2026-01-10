// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_registration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventRegistration {

 String get memberId; String get memberName; bool get isGuest; bool get attendingGolf; bool get attendingDinner; bool get hasPaid; double get cost;
/// Create a copy of EventRegistration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventRegistrationCopyWith<EventRegistration> get copyWith => _$EventRegistrationCopyWithImpl<EventRegistration>(this as EventRegistration, _$identity);

  /// Serializes this EventRegistration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventRegistration&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&(identical(other.attendingGolf, attendingGolf) || other.attendingGolf == attendingGolf)&&(identical(other.attendingDinner, attendingDinner) || other.attendingDinner == attendingDinner)&&(identical(other.hasPaid, hasPaid) || other.hasPaid == hasPaid)&&(identical(other.cost, cost) || other.cost == cost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,memberName,isGuest,attendingGolf,attendingDinner,hasPaid,cost);

@override
String toString() {
  return 'EventRegistration(memberId: $memberId, memberName: $memberName, isGuest: $isGuest, attendingGolf: $attendingGolf, attendingDinner: $attendingDinner, hasPaid: $hasPaid, cost: $cost)';
}


}

/// @nodoc
abstract mixin class $EventRegistrationCopyWith<$Res>  {
  factory $EventRegistrationCopyWith(EventRegistration value, $Res Function(EventRegistration) _then) = _$EventRegistrationCopyWithImpl;
@useResult
$Res call({
 String memberId, String memberName, bool isGuest, bool attendingGolf, bool attendingDinner, bool hasPaid, double cost
});




}
/// @nodoc
class _$EventRegistrationCopyWithImpl<$Res>
    implements $EventRegistrationCopyWith<$Res> {
  _$EventRegistrationCopyWithImpl(this._self, this._then);

  final EventRegistration _self;
  final $Res Function(EventRegistration) _then;

/// Create a copy of EventRegistration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? memberName = null,Object? isGuest = null,Object? attendingGolf = null,Object? attendingDinner = null,Object? hasPaid = null,Object? cost = null,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,attendingGolf: null == attendingGolf ? _self.attendingGolf : attendingGolf // ignore: cast_nullable_to_non_nullable
as bool,attendingDinner: null == attendingDinner ? _self.attendingDinner : attendingDinner // ignore: cast_nullable_to_non_nullable
as bool,hasPaid: null == hasPaid ? _self.hasPaid : hasPaid // ignore: cast_nullable_to_non_nullable
as bool,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EventRegistration].
extension EventRegistrationPatterns on EventRegistration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventRegistration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventRegistration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventRegistration value)  $default,){
final _that = this;
switch (_that) {
case _EventRegistration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventRegistration value)?  $default,){
final _that = this;
switch (_that) {
case _EventRegistration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String memberName,  bool isGuest,  bool attendingGolf,  bool attendingDinner,  bool hasPaid,  double cost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventRegistration() when $default != null:
return $default(_that.memberId,_that.memberName,_that.isGuest,_that.attendingGolf,_that.attendingDinner,_that.hasPaid,_that.cost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String memberName,  bool isGuest,  bool attendingGolf,  bool attendingDinner,  bool hasPaid,  double cost)  $default,) {final _that = this;
switch (_that) {
case _EventRegistration():
return $default(_that.memberId,_that.memberName,_that.isGuest,_that.attendingGolf,_that.attendingDinner,_that.hasPaid,_that.cost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String memberName,  bool isGuest,  bool attendingGolf,  bool attendingDinner,  bool hasPaid,  double cost)?  $default,) {final _that = this;
switch (_that) {
case _EventRegistration() when $default != null:
return $default(_that.memberId,_that.memberName,_that.isGuest,_that.attendingGolf,_that.attendingDinner,_that.hasPaid,_that.cost);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventRegistration extends EventRegistration {
  const _EventRegistration({required this.memberId, required this.memberName, this.isGuest = false, this.attendingGolf = true, this.attendingDinner = false, this.hasPaid = false, this.cost = 0.0}): super._();
  factory _EventRegistration.fromJson(Map<String, dynamic> json) => _$EventRegistrationFromJson(json);

@override final  String memberId;
@override final  String memberName;
@override@JsonKey() final  bool isGuest;
@override@JsonKey() final  bool attendingGolf;
@override@JsonKey() final  bool attendingDinner;
@override@JsonKey() final  bool hasPaid;
@override@JsonKey() final  double cost;

/// Create a copy of EventRegistration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventRegistrationCopyWith<_EventRegistration> get copyWith => __$EventRegistrationCopyWithImpl<_EventRegistration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventRegistrationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventRegistration&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&(identical(other.attendingGolf, attendingGolf) || other.attendingGolf == attendingGolf)&&(identical(other.attendingDinner, attendingDinner) || other.attendingDinner == attendingDinner)&&(identical(other.hasPaid, hasPaid) || other.hasPaid == hasPaid)&&(identical(other.cost, cost) || other.cost == cost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,memberName,isGuest,attendingGolf,attendingDinner,hasPaid,cost);

@override
String toString() {
  return 'EventRegistration(memberId: $memberId, memberName: $memberName, isGuest: $isGuest, attendingGolf: $attendingGolf, attendingDinner: $attendingDinner, hasPaid: $hasPaid, cost: $cost)';
}


}

/// @nodoc
abstract mixin class _$EventRegistrationCopyWith<$Res> implements $EventRegistrationCopyWith<$Res> {
  factory _$EventRegistrationCopyWith(_EventRegistration value, $Res Function(_EventRegistration) _then) = __$EventRegistrationCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String memberName, bool isGuest, bool attendingGolf, bool attendingDinner, bool hasPaid, double cost
});




}
/// @nodoc
class __$EventRegistrationCopyWithImpl<$Res>
    implements _$EventRegistrationCopyWith<$Res> {
  __$EventRegistrationCopyWithImpl(this._self, this._then);

  final _EventRegistration _self;
  final $Res Function(_EventRegistration) _then;

/// Create a copy of EventRegistration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? memberName = null,Object? isGuest = null,Object? attendingGolf = null,Object? attendingDinner = null,Object? hasPaid = null,Object? cost = null,}) {
  return _then(_EventRegistration(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,attendingGolf: null == attendingGolf ? _self.attendingGolf : attendingGolf // ignore: cast_nullable_to_non_nullable
as bool,attendingDinner: null == attendingDinner ? _self.attendingDinner : attendingDinner // ignore: cast_nullable_to_non_nullable
as bool,hasPaid: null == hasPaid ? _self.hasPaid : hasPaid // ignore: cast_nullable_to_non_nullable
as bool,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
