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

 String get memberId; String get memberName; bool get isGuest; bool get attendingGolf; bool get attendingBreakfast; bool get attendingLunch; bool get attendingDinner; bool get hasPaid; double get cost;// New fields for registration form
 bool get needsBuggy; String? get dietaryRequirements; String? get specialNeeds;// Guest details (for registrations that include a guest)
 String? get guestName; String? get guestHandicap; bool get guestAttendingBreakfast; bool get guestAttendingLunch; bool get guestAttendingDinner; bool get guestNeedsBuggy; bool get isCaptain;@OptionalTimestampConverter() DateTime? get registeredAt; bool get isConfirmed; bool get guestIsConfirmed; String? get statusOverride;// 'confirmed', 'reserved', 'waitlist'
 String? get buggyStatusOverride;// 'confirmed', 'reserved', 'waitlist'
 String? get guestBuggyStatusOverride;// 'confirmed', 'reserved', 'waitlist'
 List<RegistrationHistoryItem>? get history;
/// Create a copy of EventRegistration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventRegistrationCopyWith<EventRegistration> get copyWith => _$EventRegistrationCopyWithImpl<EventRegistration>(this as EventRegistration, _$identity);

  /// Serializes this EventRegistration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventRegistration&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&(identical(other.attendingGolf, attendingGolf) || other.attendingGolf == attendingGolf)&&(identical(other.attendingBreakfast, attendingBreakfast) || other.attendingBreakfast == attendingBreakfast)&&(identical(other.attendingLunch, attendingLunch) || other.attendingLunch == attendingLunch)&&(identical(other.attendingDinner, attendingDinner) || other.attendingDinner == attendingDinner)&&(identical(other.hasPaid, hasPaid) || other.hasPaid == hasPaid)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.needsBuggy, needsBuggy) || other.needsBuggy == needsBuggy)&&(identical(other.dietaryRequirements, dietaryRequirements) || other.dietaryRequirements == dietaryRequirements)&&(identical(other.specialNeeds, specialNeeds) || other.specialNeeds == specialNeeds)&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.guestHandicap, guestHandicap) || other.guestHandicap == guestHandicap)&&(identical(other.guestAttendingBreakfast, guestAttendingBreakfast) || other.guestAttendingBreakfast == guestAttendingBreakfast)&&(identical(other.guestAttendingLunch, guestAttendingLunch) || other.guestAttendingLunch == guestAttendingLunch)&&(identical(other.guestAttendingDinner, guestAttendingDinner) || other.guestAttendingDinner == guestAttendingDinner)&&(identical(other.guestNeedsBuggy, guestNeedsBuggy) || other.guestNeedsBuggy == guestNeedsBuggy)&&(identical(other.isCaptain, isCaptain) || other.isCaptain == isCaptain)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.isConfirmed, isConfirmed) || other.isConfirmed == isConfirmed)&&(identical(other.guestIsConfirmed, guestIsConfirmed) || other.guestIsConfirmed == guestIsConfirmed)&&(identical(other.statusOverride, statusOverride) || other.statusOverride == statusOverride)&&(identical(other.buggyStatusOverride, buggyStatusOverride) || other.buggyStatusOverride == buggyStatusOverride)&&(identical(other.guestBuggyStatusOverride, guestBuggyStatusOverride) || other.guestBuggyStatusOverride == guestBuggyStatusOverride)&&const DeepCollectionEquality().equals(other.history, history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,memberId,memberName,isGuest,attendingGolf,attendingBreakfast,attendingLunch,attendingDinner,hasPaid,cost,needsBuggy,dietaryRequirements,specialNeeds,guestName,guestHandicap,guestAttendingBreakfast,guestAttendingLunch,guestAttendingDinner,guestNeedsBuggy,isCaptain,registeredAt,isConfirmed,guestIsConfirmed,statusOverride,buggyStatusOverride,guestBuggyStatusOverride,const DeepCollectionEquality().hash(history)]);

@override
String toString() {
  return 'EventRegistration(memberId: $memberId, memberName: $memberName, isGuest: $isGuest, attendingGolf: $attendingGolf, attendingBreakfast: $attendingBreakfast, attendingLunch: $attendingLunch, attendingDinner: $attendingDinner, hasPaid: $hasPaid, cost: $cost, needsBuggy: $needsBuggy, dietaryRequirements: $dietaryRequirements, specialNeeds: $specialNeeds, guestName: $guestName, guestHandicap: $guestHandicap, guestAttendingBreakfast: $guestAttendingBreakfast, guestAttendingLunch: $guestAttendingLunch, guestAttendingDinner: $guestAttendingDinner, guestNeedsBuggy: $guestNeedsBuggy, isCaptain: $isCaptain, registeredAt: $registeredAt, isConfirmed: $isConfirmed, guestIsConfirmed: $guestIsConfirmed, statusOverride: $statusOverride, buggyStatusOverride: $buggyStatusOverride, guestBuggyStatusOverride: $guestBuggyStatusOverride, history: $history)';
}


}

/// @nodoc
abstract mixin class $EventRegistrationCopyWith<$Res>  {
  factory $EventRegistrationCopyWith(EventRegistration value, $Res Function(EventRegistration) _then) = _$EventRegistrationCopyWithImpl;
@useResult
$Res call({
 String memberId, String memberName, bool isGuest, bool attendingGolf, bool attendingBreakfast, bool attendingLunch, bool attendingDinner, bool hasPaid, double cost, bool needsBuggy, String? dietaryRequirements, String? specialNeeds, String? guestName, String? guestHandicap, bool guestAttendingBreakfast, bool guestAttendingLunch, bool guestAttendingDinner, bool guestNeedsBuggy, bool isCaptain,@OptionalTimestampConverter() DateTime? registeredAt, bool isConfirmed, bool guestIsConfirmed, String? statusOverride, String? buggyStatusOverride, String? guestBuggyStatusOverride, List<RegistrationHistoryItem>? history
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
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? memberName = null,Object? isGuest = null,Object? attendingGolf = null,Object? attendingBreakfast = null,Object? attendingLunch = null,Object? attendingDinner = null,Object? hasPaid = null,Object? cost = null,Object? needsBuggy = null,Object? dietaryRequirements = freezed,Object? specialNeeds = freezed,Object? guestName = freezed,Object? guestHandicap = freezed,Object? guestAttendingBreakfast = null,Object? guestAttendingLunch = null,Object? guestAttendingDinner = null,Object? guestNeedsBuggy = null,Object? isCaptain = null,Object? registeredAt = freezed,Object? isConfirmed = null,Object? guestIsConfirmed = null,Object? statusOverride = freezed,Object? buggyStatusOverride = freezed,Object? guestBuggyStatusOverride = freezed,Object? history = freezed,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,attendingGolf: null == attendingGolf ? _self.attendingGolf : attendingGolf // ignore: cast_nullable_to_non_nullable
as bool,attendingBreakfast: null == attendingBreakfast ? _self.attendingBreakfast : attendingBreakfast // ignore: cast_nullable_to_non_nullable
as bool,attendingLunch: null == attendingLunch ? _self.attendingLunch : attendingLunch // ignore: cast_nullable_to_non_nullable
as bool,attendingDinner: null == attendingDinner ? _self.attendingDinner : attendingDinner // ignore: cast_nullable_to_non_nullable
as bool,hasPaid: null == hasPaid ? _self.hasPaid : hasPaid // ignore: cast_nullable_to_non_nullable
as bool,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,needsBuggy: null == needsBuggy ? _self.needsBuggy : needsBuggy // ignore: cast_nullable_to_non_nullable
as bool,dietaryRequirements: freezed == dietaryRequirements ? _self.dietaryRequirements : dietaryRequirements // ignore: cast_nullable_to_non_nullable
as String?,specialNeeds: freezed == specialNeeds ? _self.specialNeeds : specialNeeds // ignore: cast_nullable_to_non_nullable
as String?,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,guestHandicap: freezed == guestHandicap ? _self.guestHandicap : guestHandicap // ignore: cast_nullable_to_non_nullable
as String?,guestAttendingBreakfast: null == guestAttendingBreakfast ? _self.guestAttendingBreakfast : guestAttendingBreakfast // ignore: cast_nullable_to_non_nullable
as bool,guestAttendingLunch: null == guestAttendingLunch ? _self.guestAttendingLunch : guestAttendingLunch // ignore: cast_nullable_to_non_nullable
as bool,guestAttendingDinner: null == guestAttendingDinner ? _self.guestAttendingDinner : guestAttendingDinner // ignore: cast_nullable_to_non_nullable
as bool,guestNeedsBuggy: null == guestNeedsBuggy ? _self.guestNeedsBuggy : guestNeedsBuggy // ignore: cast_nullable_to_non_nullable
as bool,isCaptain: null == isCaptain ? _self.isCaptain : isCaptain // ignore: cast_nullable_to_non_nullable
as bool,registeredAt: freezed == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isConfirmed: null == isConfirmed ? _self.isConfirmed : isConfirmed // ignore: cast_nullable_to_non_nullable
as bool,guestIsConfirmed: null == guestIsConfirmed ? _self.guestIsConfirmed : guestIsConfirmed // ignore: cast_nullable_to_non_nullable
as bool,statusOverride: freezed == statusOverride ? _self.statusOverride : statusOverride // ignore: cast_nullable_to_non_nullable
as String?,buggyStatusOverride: freezed == buggyStatusOverride ? _self.buggyStatusOverride : buggyStatusOverride // ignore: cast_nullable_to_non_nullable
as String?,guestBuggyStatusOverride: freezed == guestBuggyStatusOverride ? _self.guestBuggyStatusOverride : guestBuggyStatusOverride // ignore: cast_nullable_to_non_nullable
as String?,history: freezed == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<RegistrationHistoryItem>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String memberName,  bool isGuest,  bool attendingGolf,  bool attendingBreakfast,  bool attendingLunch,  bool attendingDinner,  bool hasPaid,  double cost,  bool needsBuggy,  String? dietaryRequirements,  String? specialNeeds,  String? guestName,  String? guestHandicap,  bool guestAttendingBreakfast,  bool guestAttendingLunch,  bool guestAttendingDinner,  bool guestNeedsBuggy,  bool isCaptain, @OptionalTimestampConverter()  DateTime? registeredAt,  bool isConfirmed,  bool guestIsConfirmed,  String? statusOverride,  String? buggyStatusOverride,  String? guestBuggyStatusOverride,  List<RegistrationHistoryItem>? history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventRegistration() when $default != null:
return $default(_that.memberId,_that.memberName,_that.isGuest,_that.attendingGolf,_that.attendingBreakfast,_that.attendingLunch,_that.attendingDinner,_that.hasPaid,_that.cost,_that.needsBuggy,_that.dietaryRequirements,_that.specialNeeds,_that.guestName,_that.guestHandicap,_that.guestAttendingBreakfast,_that.guestAttendingLunch,_that.guestAttendingDinner,_that.guestNeedsBuggy,_that.isCaptain,_that.registeredAt,_that.isConfirmed,_that.guestIsConfirmed,_that.statusOverride,_that.buggyStatusOverride,_that.guestBuggyStatusOverride,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String memberName,  bool isGuest,  bool attendingGolf,  bool attendingBreakfast,  bool attendingLunch,  bool attendingDinner,  bool hasPaid,  double cost,  bool needsBuggy,  String? dietaryRequirements,  String? specialNeeds,  String? guestName,  String? guestHandicap,  bool guestAttendingBreakfast,  bool guestAttendingLunch,  bool guestAttendingDinner,  bool guestNeedsBuggy,  bool isCaptain, @OptionalTimestampConverter()  DateTime? registeredAt,  bool isConfirmed,  bool guestIsConfirmed,  String? statusOverride,  String? buggyStatusOverride,  String? guestBuggyStatusOverride,  List<RegistrationHistoryItem>? history)  $default,) {final _that = this;
switch (_that) {
case _EventRegistration():
return $default(_that.memberId,_that.memberName,_that.isGuest,_that.attendingGolf,_that.attendingBreakfast,_that.attendingLunch,_that.attendingDinner,_that.hasPaid,_that.cost,_that.needsBuggy,_that.dietaryRequirements,_that.specialNeeds,_that.guestName,_that.guestHandicap,_that.guestAttendingBreakfast,_that.guestAttendingLunch,_that.guestAttendingDinner,_that.guestNeedsBuggy,_that.isCaptain,_that.registeredAt,_that.isConfirmed,_that.guestIsConfirmed,_that.statusOverride,_that.buggyStatusOverride,_that.guestBuggyStatusOverride,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String memberName,  bool isGuest,  bool attendingGolf,  bool attendingBreakfast,  bool attendingLunch,  bool attendingDinner,  bool hasPaid,  double cost,  bool needsBuggy,  String? dietaryRequirements,  String? specialNeeds,  String? guestName,  String? guestHandicap,  bool guestAttendingBreakfast,  bool guestAttendingLunch,  bool guestAttendingDinner,  bool guestNeedsBuggy,  bool isCaptain, @OptionalTimestampConverter()  DateTime? registeredAt,  bool isConfirmed,  bool guestIsConfirmed,  String? statusOverride,  String? buggyStatusOverride,  String? guestBuggyStatusOverride,  List<RegistrationHistoryItem>? history)?  $default,) {final _that = this;
switch (_that) {
case _EventRegistration() when $default != null:
return $default(_that.memberId,_that.memberName,_that.isGuest,_that.attendingGolf,_that.attendingBreakfast,_that.attendingLunch,_that.attendingDinner,_that.hasPaid,_that.cost,_that.needsBuggy,_that.dietaryRequirements,_that.specialNeeds,_that.guestName,_that.guestHandicap,_that.guestAttendingBreakfast,_that.guestAttendingLunch,_that.guestAttendingDinner,_that.guestNeedsBuggy,_that.isCaptain,_that.registeredAt,_that.isConfirmed,_that.guestIsConfirmed,_that.statusOverride,_that.buggyStatusOverride,_that.guestBuggyStatusOverride,_that.history);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventRegistration extends EventRegistration {
  const _EventRegistration({required this.memberId, required this.memberName, this.isGuest = false, this.attendingGolf = true, this.attendingBreakfast = false, this.attendingLunch = false, this.attendingDinner = false, this.hasPaid = false, this.cost = 0.0, this.needsBuggy = false, this.dietaryRequirements, this.specialNeeds, this.guestName, this.guestHandicap, this.guestAttendingBreakfast = false, this.guestAttendingLunch = false, this.guestAttendingDinner = false, this.guestNeedsBuggy = false, this.isCaptain = false, @OptionalTimestampConverter() this.registeredAt, this.isConfirmed = false, this.guestIsConfirmed = false, this.statusOverride, this.buggyStatusOverride, this.guestBuggyStatusOverride, final  List<RegistrationHistoryItem>? history = const []}): _history = history,super._();
  factory _EventRegistration.fromJson(Map<String, dynamic> json) => _$EventRegistrationFromJson(json);

@override final  String memberId;
@override final  String memberName;
@override@JsonKey() final  bool isGuest;
@override@JsonKey() final  bool attendingGolf;
@override@JsonKey() final  bool attendingBreakfast;
@override@JsonKey() final  bool attendingLunch;
@override@JsonKey() final  bool attendingDinner;
@override@JsonKey() final  bool hasPaid;
@override@JsonKey() final  double cost;
// New fields for registration form
@override@JsonKey() final  bool needsBuggy;
@override final  String? dietaryRequirements;
@override final  String? specialNeeds;
// Guest details (for registrations that include a guest)
@override final  String? guestName;
@override final  String? guestHandicap;
@override@JsonKey() final  bool guestAttendingBreakfast;
@override@JsonKey() final  bool guestAttendingLunch;
@override@JsonKey() final  bool guestAttendingDinner;
@override@JsonKey() final  bool guestNeedsBuggy;
@override@JsonKey() final  bool isCaptain;
@override@OptionalTimestampConverter() final  DateTime? registeredAt;
@override@JsonKey() final  bool isConfirmed;
@override@JsonKey() final  bool guestIsConfirmed;
@override final  String? statusOverride;
// 'confirmed', 'reserved', 'waitlist'
@override final  String? buggyStatusOverride;
// 'confirmed', 'reserved', 'waitlist'
@override final  String? guestBuggyStatusOverride;
// 'confirmed', 'reserved', 'waitlist'
 final  List<RegistrationHistoryItem>? _history;
// 'confirmed', 'reserved', 'waitlist'
@override@JsonKey() List<RegistrationHistoryItem>? get history {
  final value = _history;
  if (value == null) return null;
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventRegistration&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&(identical(other.attendingGolf, attendingGolf) || other.attendingGolf == attendingGolf)&&(identical(other.attendingBreakfast, attendingBreakfast) || other.attendingBreakfast == attendingBreakfast)&&(identical(other.attendingLunch, attendingLunch) || other.attendingLunch == attendingLunch)&&(identical(other.attendingDinner, attendingDinner) || other.attendingDinner == attendingDinner)&&(identical(other.hasPaid, hasPaid) || other.hasPaid == hasPaid)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.needsBuggy, needsBuggy) || other.needsBuggy == needsBuggy)&&(identical(other.dietaryRequirements, dietaryRequirements) || other.dietaryRequirements == dietaryRequirements)&&(identical(other.specialNeeds, specialNeeds) || other.specialNeeds == specialNeeds)&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.guestHandicap, guestHandicap) || other.guestHandicap == guestHandicap)&&(identical(other.guestAttendingBreakfast, guestAttendingBreakfast) || other.guestAttendingBreakfast == guestAttendingBreakfast)&&(identical(other.guestAttendingLunch, guestAttendingLunch) || other.guestAttendingLunch == guestAttendingLunch)&&(identical(other.guestAttendingDinner, guestAttendingDinner) || other.guestAttendingDinner == guestAttendingDinner)&&(identical(other.guestNeedsBuggy, guestNeedsBuggy) || other.guestNeedsBuggy == guestNeedsBuggy)&&(identical(other.isCaptain, isCaptain) || other.isCaptain == isCaptain)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.isConfirmed, isConfirmed) || other.isConfirmed == isConfirmed)&&(identical(other.guestIsConfirmed, guestIsConfirmed) || other.guestIsConfirmed == guestIsConfirmed)&&(identical(other.statusOverride, statusOverride) || other.statusOverride == statusOverride)&&(identical(other.buggyStatusOverride, buggyStatusOverride) || other.buggyStatusOverride == buggyStatusOverride)&&(identical(other.guestBuggyStatusOverride, guestBuggyStatusOverride) || other.guestBuggyStatusOverride == guestBuggyStatusOverride)&&const DeepCollectionEquality().equals(other._history, _history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,memberId,memberName,isGuest,attendingGolf,attendingBreakfast,attendingLunch,attendingDinner,hasPaid,cost,needsBuggy,dietaryRequirements,specialNeeds,guestName,guestHandicap,guestAttendingBreakfast,guestAttendingLunch,guestAttendingDinner,guestNeedsBuggy,isCaptain,registeredAt,isConfirmed,guestIsConfirmed,statusOverride,buggyStatusOverride,guestBuggyStatusOverride,const DeepCollectionEquality().hash(_history)]);

@override
String toString() {
  return 'EventRegistration(memberId: $memberId, memberName: $memberName, isGuest: $isGuest, attendingGolf: $attendingGolf, attendingBreakfast: $attendingBreakfast, attendingLunch: $attendingLunch, attendingDinner: $attendingDinner, hasPaid: $hasPaid, cost: $cost, needsBuggy: $needsBuggy, dietaryRequirements: $dietaryRequirements, specialNeeds: $specialNeeds, guestName: $guestName, guestHandicap: $guestHandicap, guestAttendingBreakfast: $guestAttendingBreakfast, guestAttendingLunch: $guestAttendingLunch, guestAttendingDinner: $guestAttendingDinner, guestNeedsBuggy: $guestNeedsBuggy, isCaptain: $isCaptain, registeredAt: $registeredAt, isConfirmed: $isConfirmed, guestIsConfirmed: $guestIsConfirmed, statusOverride: $statusOverride, buggyStatusOverride: $buggyStatusOverride, guestBuggyStatusOverride: $guestBuggyStatusOverride, history: $history)';
}


}

/// @nodoc
abstract mixin class _$EventRegistrationCopyWith<$Res> implements $EventRegistrationCopyWith<$Res> {
  factory _$EventRegistrationCopyWith(_EventRegistration value, $Res Function(_EventRegistration) _then) = __$EventRegistrationCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String memberName, bool isGuest, bool attendingGolf, bool attendingBreakfast, bool attendingLunch, bool attendingDinner, bool hasPaid, double cost, bool needsBuggy, String? dietaryRequirements, String? specialNeeds, String? guestName, String? guestHandicap, bool guestAttendingBreakfast, bool guestAttendingLunch, bool guestAttendingDinner, bool guestNeedsBuggy, bool isCaptain,@OptionalTimestampConverter() DateTime? registeredAt, bool isConfirmed, bool guestIsConfirmed, String? statusOverride, String? buggyStatusOverride, String? guestBuggyStatusOverride, List<RegistrationHistoryItem>? history
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
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? memberName = null,Object? isGuest = null,Object? attendingGolf = null,Object? attendingBreakfast = null,Object? attendingLunch = null,Object? attendingDinner = null,Object? hasPaid = null,Object? cost = null,Object? needsBuggy = null,Object? dietaryRequirements = freezed,Object? specialNeeds = freezed,Object? guestName = freezed,Object? guestHandicap = freezed,Object? guestAttendingBreakfast = null,Object? guestAttendingLunch = null,Object? guestAttendingDinner = null,Object? guestNeedsBuggy = null,Object? isCaptain = null,Object? registeredAt = freezed,Object? isConfirmed = null,Object? guestIsConfirmed = null,Object? statusOverride = freezed,Object? buggyStatusOverride = freezed,Object? guestBuggyStatusOverride = freezed,Object? history = freezed,}) {
  return _then(_EventRegistration(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,attendingGolf: null == attendingGolf ? _self.attendingGolf : attendingGolf // ignore: cast_nullable_to_non_nullable
as bool,attendingBreakfast: null == attendingBreakfast ? _self.attendingBreakfast : attendingBreakfast // ignore: cast_nullable_to_non_nullable
as bool,attendingLunch: null == attendingLunch ? _self.attendingLunch : attendingLunch // ignore: cast_nullable_to_non_nullable
as bool,attendingDinner: null == attendingDinner ? _self.attendingDinner : attendingDinner // ignore: cast_nullable_to_non_nullable
as bool,hasPaid: null == hasPaid ? _self.hasPaid : hasPaid // ignore: cast_nullable_to_non_nullable
as bool,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,needsBuggy: null == needsBuggy ? _self.needsBuggy : needsBuggy // ignore: cast_nullable_to_non_nullable
as bool,dietaryRequirements: freezed == dietaryRequirements ? _self.dietaryRequirements : dietaryRequirements // ignore: cast_nullable_to_non_nullable
as String?,specialNeeds: freezed == specialNeeds ? _self.specialNeeds : specialNeeds // ignore: cast_nullable_to_non_nullable
as String?,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,guestHandicap: freezed == guestHandicap ? _self.guestHandicap : guestHandicap // ignore: cast_nullable_to_non_nullable
as String?,guestAttendingBreakfast: null == guestAttendingBreakfast ? _self.guestAttendingBreakfast : guestAttendingBreakfast // ignore: cast_nullable_to_non_nullable
as bool,guestAttendingLunch: null == guestAttendingLunch ? _self.guestAttendingLunch : guestAttendingLunch // ignore: cast_nullable_to_non_nullable
as bool,guestAttendingDinner: null == guestAttendingDinner ? _self.guestAttendingDinner : guestAttendingDinner // ignore: cast_nullable_to_non_nullable
as bool,guestNeedsBuggy: null == guestNeedsBuggy ? _self.guestNeedsBuggy : guestNeedsBuggy // ignore: cast_nullable_to_non_nullable
as bool,isCaptain: null == isCaptain ? _self.isCaptain : isCaptain // ignore: cast_nullable_to_non_nullable
as bool,registeredAt: freezed == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isConfirmed: null == isConfirmed ? _self.isConfirmed : isConfirmed // ignore: cast_nullable_to_non_nullable
as bool,guestIsConfirmed: null == guestIsConfirmed ? _self.guestIsConfirmed : guestIsConfirmed // ignore: cast_nullable_to_non_nullable
as bool,statusOverride: freezed == statusOverride ? _self.statusOverride : statusOverride // ignore: cast_nullable_to_non_nullable
as String?,buggyStatusOverride: freezed == buggyStatusOverride ? _self.buggyStatusOverride : buggyStatusOverride // ignore: cast_nullable_to_non_nullable
as String?,guestBuggyStatusOverride: freezed == guestBuggyStatusOverride ? _self.guestBuggyStatusOverride : guestBuggyStatusOverride // ignore: cast_nullable_to_non_nullable
as String?,history: freezed == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<RegistrationHistoryItem>?,
  ));
}


}


/// @nodoc
mixin _$RegistrationHistoryItem {

 DateTime get timestamp; String get action;// e.g., 'Status Update'
 String get description;// e.g., 'Changed from Reserved to Confirmed'
 String? get actor;
/// Create a copy of RegistrationHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationHistoryItemCopyWith<RegistrationHistoryItem> get copyWith => _$RegistrationHistoryItemCopyWithImpl<RegistrationHistoryItem>(this as RegistrationHistoryItem, _$identity);

  /// Serializes this RegistrationHistoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationHistoryItem&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.action, action) || other.action == action)&&(identical(other.description, description) || other.description == description)&&(identical(other.actor, actor) || other.actor == actor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timestamp,action,description,actor);

@override
String toString() {
  return 'RegistrationHistoryItem(timestamp: $timestamp, action: $action, description: $description, actor: $actor)';
}


}

/// @nodoc
abstract mixin class $RegistrationHistoryItemCopyWith<$Res>  {
  factory $RegistrationHistoryItemCopyWith(RegistrationHistoryItem value, $Res Function(RegistrationHistoryItem) _then) = _$RegistrationHistoryItemCopyWithImpl;
@useResult
$Res call({
 DateTime timestamp, String action, String description, String? actor
});




}
/// @nodoc
class _$RegistrationHistoryItemCopyWithImpl<$Res>
    implements $RegistrationHistoryItemCopyWith<$Res> {
  _$RegistrationHistoryItemCopyWithImpl(this._self, this._then);

  final RegistrationHistoryItem _self;
  final $Res Function(RegistrationHistoryItem) _then;

/// Create a copy of RegistrationHistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timestamp = null,Object? action = null,Object? description = null,Object? actor = freezed,}) {
  return _then(_self.copyWith(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegistrationHistoryItem].
extension RegistrationHistoryItemPatterns on RegistrationHistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistrationHistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistrationHistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistrationHistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _RegistrationHistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistrationHistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _RegistrationHistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime timestamp,  String action,  String description,  String? actor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistrationHistoryItem() when $default != null:
return $default(_that.timestamp,_that.action,_that.description,_that.actor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime timestamp,  String action,  String description,  String? actor)  $default,) {final _that = this;
switch (_that) {
case _RegistrationHistoryItem():
return $default(_that.timestamp,_that.action,_that.description,_that.actor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime timestamp,  String action,  String description,  String? actor)?  $default,) {final _that = this;
switch (_that) {
case _RegistrationHistoryItem() when $default != null:
return $default(_that.timestamp,_that.action,_that.description,_that.actor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegistrationHistoryItem implements RegistrationHistoryItem {
  const _RegistrationHistoryItem({required this.timestamp, required this.action, required this.description, this.actor});
  factory _RegistrationHistoryItem.fromJson(Map<String, dynamic> json) => _$RegistrationHistoryItemFromJson(json);

@override final  DateTime timestamp;
@override final  String action;
// e.g., 'Status Update'
@override final  String description;
// e.g., 'Changed from Reserved to Confirmed'
@override final  String? actor;

/// Create a copy of RegistrationHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistrationHistoryItemCopyWith<_RegistrationHistoryItem> get copyWith => __$RegistrationHistoryItemCopyWithImpl<_RegistrationHistoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegistrationHistoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistrationHistoryItem&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.action, action) || other.action == action)&&(identical(other.description, description) || other.description == description)&&(identical(other.actor, actor) || other.actor == actor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timestamp,action,description,actor);

@override
String toString() {
  return 'RegistrationHistoryItem(timestamp: $timestamp, action: $action, description: $description, actor: $actor)';
}


}

/// @nodoc
abstract mixin class _$RegistrationHistoryItemCopyWith<$Res> implements $RegistrationHistoryItemCopyWith<$Res> {
  factory _$RegistrationHistoryItemCopyWith(_RegistrationHistoryItem value, $Res Function(_RegistrationHistoryItem) _then) = __$RegistrationHistoryItemCopyWithImpl;
@override @useResult
$Res call({
 DateTime timestamp, String action, String description, String? actor
});




}
/// @nodoc
class __$RegistrationHistoryItemCopyWithImpl<$Res>
    implements _$RegistrationHistoryItemCopyWith<$Res> {
  __$RegistrationHistoryItemCopyWithImpl(this._self, this._then);

  final _RegistrationHistoryItem _self;
  final $Res Function(_RegistrationHistoryItem) _then;

/// Create a copy of RegistrationHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timestamp = null,Object? action = null,Object? description = null,Object? actor = freezed,}) {
  return _then(_RegistrationHistoryItem(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
