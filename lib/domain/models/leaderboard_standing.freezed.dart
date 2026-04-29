// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_standing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaderboardStanding {

 String get leaderboardId; String get memberId;// Basic Info
 String get memberName; String? get avatarUrl; double get currentHandicap;// Metrics
 double get points;// Primary sorting metric (OOM points, Stableford total, etc.)
 int get roundsPlayed; int get roundsCounted;// For 'Best N'
// Detailed Data (Optional, based on type)
 List<double> get history;// Last N scores for "Form"
 Map<String, int> get holeScores;// For Eclectic (1-18)
 Map<String, int> get stats;
/// Create a copy of LeaderboardStanding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardStandingCopyWith<LeaderboardStanding> get copyWith => _$LeaderboardStandingCopyWithImpl<LeaderboardStanding>(this as LeaderboardStanding, _$identity);

  /// Serializes this LeaderboardStanding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardStanding&&(identical(other.leaderboardId, leaderboardId) || other.leaderboardId == leaderboardId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.currentHandicap, currentHandicap) || other.currentHandicap == currentHandicap)&&(identical(other.points, points) || other.points == points)&&(identical(other.roundsPlayed, roundsPlayed) || other.roundsPlayed == roundsPlayed)&&(identical(other.roundsCounted, roundsCounted) || other.roundsCounted == roundsCounted)&&const DeepCollectionEquality().equals(other.history, history)&&const DeepCollectionEquality().equals(other.holeScores, holeScores)&&const DeepCollectionEquality().equals(other.stats, stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,leaderboardId,memberId,memberName,avatarUrl,currentHandicap,points,roundsPlayed,roundsCounted,const DeepCollectionEquality().hash(history),const DeepCollectionEquality().hash(holeScores),const DeepCollectionEquality().hash(stats));

@override
String toString() {
  return 'LeaderboardStanding(leaderboardId: $leaderboardId, memberId: $memberId, memberName: $memberName, avatarUrl: $avatarUrl, currentHandicap: $currentHandicap, points: $points, roundsPlayed: $roundsPlayed, roundsCounted: $roundsCounted, history: $history, holeScores: $holeScores, stats: $stats)';
}


}

/// @nodoc
abstract mixin class $LeaderboardStandingCopyWith<$Res>  {
  factory $LeaderboardStandingCopyWith(LeaderboardStanding value, $Res Function(LeaderboardStanding) _then) = _$LeaderboardStandingCopyWithImpl;
@useResult
$Res call({
 String leaderboardId, String memberId, String memberName, String? avatarUrl, double currentHandicap, double points, int roundsPlayed, int roundsCounted, List<double> history, Map<String, int> holeScores, Map<String, int> stats
});




}
/// @nodoc
class _$LeaderboardStandingCopyWithImpl<$Res>
    implements $LeaderboardStandingCopyWith<$Res> {
  _$LeaderboardStandingCopyWithImpl(this._self, this._then);

  final LeaderboardStanding _self;
  final $Res Function(LeaderboardStanding) _then;

/// Create a copy of LeaderboardStanding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? leaderboardId = null,Object? memberId = null,Object? memberName = null,Object? avatarUrl = freezed,Object? currentHandicap = null,Object? points = null,Object? roundsPlayed = null,Object? roundsCounted = null,Object? history = null,Object? holeScores = null,Object? stats = null,}) {
  return _then(_self.copyWith(
leaderboardId: null == leaderboardId ? _self.leaderboardId : leaderboardId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,currentHandicap: null == currentHandicap ? _self.currentHandicap : currentHandicap // ignore: cast_nullable_to_non_nullable
as double,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as double,roundsPlayed: null == roundsPlayed ? _self.roundsPlayed : roundsPlayed // ignore: cast_nullable_to_non_nullable
as int,roundsCounted: null == roundsCounted ? _self.roundsCounted : roundsCounted // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<double>,holeScores: null == holeScores ? _self.holeScores : holeScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaderboardStanding].
extension LeaderboardStandingPatterns on LeaderboardStanding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardStanding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardStanding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardStanding value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardStanding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardStanding value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardStanding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String leaderboardId,  String memberId,  String memberName,  String? avatarUrl,  double currentHandicap,  double points,  int roundsPlayed,  int roundsCounted,  List<double> history,  Map<String, int> holeScores,  Map<String, int> stats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardStanding() when $default != null:
return $default(_that.leaderboardId,_that.memberId,_that.memberName,_that.avatarUrl,_that.currentHandicap,_that.points,_that.roundsPlayed,_that.roundsCounted,_that.history,_that.holeScores,_that.stats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String leaderboardId,  String memberId,  String memberName,  String? avatarUrl,  double currentHandicap,  double points,  int roundsPlayed,  int roundsCounted,  List<double> history,  Map<String, int> holeScores,  Map<String, int> stats)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardStanding():
return $default(_that.leaderboardId,_that.memberId,_that.memberName,_that.avatarUrl,_that.currentHandicap,_that.points,_that.roundsPlayed,_that.roundsCounted,_that.history,_that.holeScores,_that.stats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String leaderboardId,  String memberId,  String memberName,  String? avatarUrl,  double currentHandicap,  double points,  int roundsPlayed,  int roundsCounted,  List<double> history,  Map<String, int> holeScores,  Map<String, int> stats)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardStanding() when $default != null:
return $default(_that.leaderboardId,_that.memberId,_that.memberName,_that.avatarUrl,_that.currentHandicap,_that.points,_that.roundsPlayed,_that.roundsCounted,_that.history,_that.holeScores,_that.stats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardStanding extends LeaderboardStanding {
  const _LeaderboardStanding({required this.leaderboardId, required this.memberId, required this.memberName, this.avatarUrl, required this.currentHandicap, required this.points, required this.roundsPlayed, required this.roundsCounted, final  List<double> history = const [], final  Map<String, int> holeScores = const {}, final  Map<String, int> stats = const {}}): _history = history,_holeScores = holeScores,_stats = stats,super._();
  factory _LeaderboardStanding.fromJson(Map<String, dynamic> json) => _$LeaderboardStandingFromJson(json);

@override final  String leaderboardId;
@override final  String memberId;
// Basic Info
@override final  String memberName;
@override final  String? avatarUrl;
@override final  double currentHandicap;
// Metrics
@override final  double points;
// Primary sorting metric (OOM points, Stableford total, etc.)
@override final  int roundsPlayed;
@override final  int roundsCounted;
// For 'Best N'
// Detailed Data (Optional, based on type)
 final  List<double> _history;
// For 'Best N'
// Detailed Data (Optional, based on type)
@override@JsonKey() List<double> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

// Last N scores for "Form"
 final  Map<String, int> _holeScores;
// Last N scores for "Form"
@override@JsonKey() Map<String, int> get holeScores {
  if (_holeScores is EqualUnmodifiableMapView) return _holeScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_holeScores);
}

// For Eclectic (1-18)
 final  Map<String, int> _stats;
// For Eclectic (1-18)
@override@JsonKey() Map<String, int> get stats {
  if (_stats is EqualUnmodifiableMapView) return _stats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stats);
}


/// Create a copy of LeaderboardStanding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardStandingCopyWith<_LeaderboardStanding> get copyWith => __$LeaderboardStandingCopyWithImpl<_LeaderboardStanding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardStandingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardStanding&&(identical(other.leaderboardId, leaderboardId) || other.leaderboardId == leaderboardId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.currentHandicap, currentHandicap) || other.currentHandicap == currentHandicap)&&(identical(other.points, points) || other.points == points)&&(identical(other.roundsPlayed, roundsPlayed) || other.roundsPlayed == roundsPlayed)&&(identical(other.roundsCounted, roundsCounted) || other.roundsCounted == roundsCounted)&&const DeepCollectionEquality().equals(other._history, _history)&&const DeepCollectionEquality().equals(other._holeScores, _holeScores)&&const DeepCollectionEquality().equals(other._stats, _stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,leaderboardId,memberId,memberName,avatarUrl,currentHandicap,points,roundsPlayed,roundsCounted,const DeepCollectionEquality().hash(_history),const DeepCollectionEquality().hash(_holeScores),const DeepCollectionEquality().hash(_stats));

@override
String toString() {
  return 'LeaderboardStanding(leaderboardId: $leaderboardId, memberId: $memberId, memberName: $memberName, avatarUrl: $avatarUrl, currentHandicap: $currentHandicap, points: $points, roundsPlayed: $roundsPlayed, roundsCounted: $roundsCounted, history: $history, holeScores: $holeScores, stats: $stats)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardStandingCopyWith<$Res> implements $LeaderboardStandingCopyWith<$Res> {
  factory _$LeaderboardStandingCopyWith(_LeaderboardStanding value, $Res Function(_LeaderboardStanding) _then) = __$LeaderboardStandingCopyWithImpl;
@override @useResult
$Res call({
 String leaderboardId, String memberId, String memberName, String? avatarUrl, double currentHandicap, double points, int roundsPlayed, int roundsCounted, List<double> history, Map<String, int> holeScores, Map<String, int> stats
});




}
/// @nodoc
class __$LeaderboardStandingCopyWithImpl<$Res>
    implements _$LeaderboardStandingCopyWith<$Res> {
  __$LeaderboardStandingCopyWithImpl(this._self, this._then);

  final _LeaderboardStanding _self;
  final $Res Function(_LeaderboardStanding) _then;

/// Create a copy of LeaderboardStanding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? leaderboardId = null,Object? memberId = null,Object? memberName = null,Object? avatarUrl = freezed,Object? currentHandicap = null,Object? points = null,Object? roundsPlayed = null,Object? roundsCounted = null,Object? history = null,Object? holeScores = null,Object? stats = null,}) {
  return _then(_LeaderboardStanding(
leaderboardId: null == leaderboardId ? _self.leaderboardId : leaderboardId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,currentHandicap: null == currentHandicap ? _self.currentHandicap : currentHandicap // ignore: cast_nullable_to_non_nullable
as double,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as double,roundsPlayed: null == roundsPlayed ? _self.roundsPlayed : roundsPlayed // ignore: cast_nullable_to_non_nullable
as int,roundsCounted: null == roundsCounted ? _self.roundsCounted : roundsCounted // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<double>,holeScores: null == holeScores ? _self._holeScores : holeScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>,stats: null == stats ? _self._stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
