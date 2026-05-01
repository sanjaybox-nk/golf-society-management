// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'processed_event_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProcessedPlayerScore {

 String get playerId; String get playerName; bool get isGuest; double get handicapIndex; double get courseHandicap; int get playingHandicap; double get appliedSocietyCut; String get teeName; String? get teeColor;// [NEW]
 List<int?> get holeScores; ScoringResult get result; String? get tieBreakLabel; String? get thruLabel; ScoringStatus get scoringStatus;
/// Create a copy of ProcessedPlayerScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessedPlayerScoreCopyWith<ProcessedPlayerScore> get copyWith => _$ProcessedPlayerScoreCopyWithImpl<ProcessedPlayerScore>(this as ProcessedPlayerScore, _$identity);

  /// Serializes this ProcessedPlayerScore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessedPlayerScore&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&(identical(other.handicapIndex, handicapIndex) || other.handicapIndex == handicapIndex)&&(identical(other.courseHandicap, courseHandicap) || other.courseHandicap == courseHandicap)&&(identical(other.playingHandicap, playingHandicap) || other.playingHandicap == playingHandicap)&&(identical(other.appliedSocietyCut, appliedSocietyCut) || other.appliedSocietyCut == appliedSocietyCut)&&(identical(other.teeName, teeName) || other.teeName == teeName)&&(identical(other.teeColor, teeColor) || other.teeColor == teeColor)&&const DeepCollectionEquality().equals(other.holeScores, holeScores)&&(identical(other.result, result) || other.result == result)&&(identical(other.tieBreakLabel, tieBreakLabel) || other.tieBreakLabel == tieBreakLabel)&&(identical(other.thruLabel, thruLabel) || other.thruLabel == thruLabel)&&(identical(other.scoringStatus, scoringStatus) || other.scoringStatus == scoringStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,playerName,isGuest,handicapIndex,courseHandicap,playingHandicap,appliedSocietyCut,teeName,teeColor,const DeepCollectionEquality().hash(holeScores),result,tieBreakLabel,thruLabel,scoringStatus);

@override
String toString() {
  return 'ProcessedPlayerScore(playerId: $playerId, playerName: $playerName, isGuest: $isGuest, handicapIndex: $handicapIndex, courseHandicap: $courseHandicap, playingHandicap: $playingHandicap, appliedSocietyCut: $appliedSocietyCut, teeName: $teeName, teeColor: $teeColor, holeScores: $holeScores, result: $result, tieBreakLabel: $tieBreakLabel, thruLabel: $thruLabel, scoringStatus: $scoringStatus)';
}


}

/// @nodoc
abstract mixin class $ProcessedPlayerScoreCopyWith<$Res>  {
  factory $ProcessedPlayerScoreCopyWith(ProcessedPlayerScore value, $Res Function(ProcessedPlayerScore) _then) = _$ProcessedPlayerScoreCopyWithImpl;
@useResult
$Res call({
 String playerId, String playerName, bool isGuest, double handicapIndex, double courseHandicap, int playingHandicap, double appliedSocietyCut, String teeName, String? teeColor, List<int?> holeScores, ScoringResult result, String? tieBreakLabel, String? thruLabel, ScoringStatus scoringStatus
});




}
/// @nodoc
class _$ProcessedPlayerScoreCopyWithImpl<$Res>
    implements $ProcessedPlayerScoreCopyWith<$Res> {
  _$ProcessedPlayerScoreCopyWithImpl(this._self, this._then);

  final ProcessedPlayerScore _self;
  final $Res Function(ProcessedPlayerScore) _then;

/// Create a copy of ProcessedPlayerScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? playerName = null,Object? isGuest = null,Object? handicapIndex = null,Object? courseHandicap = null,Object? playingHandicap = null,Object? appliedSocietyCut = null,Object? teeName = null,Object? teeColor = freezed,Object? holeScores = null,Object? result = null,Object? tieBreakLabel = freezed,Object? thruLabel = freezed,Object? scoringStatus = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,handicapIndex: null == handicapIndex ? _self.handicapIndex : handicapIndex // ignore: cast_nullable_to_non_nullable
as double,courseHandicap: null == courseHandicap ? _self.courseHandicap : courseHandicap // ignore: cast_nullable_to_non_nullable
as double,playingHandicap: null == playingHandicap ? _self.playingHandicap : playingHandicap // ignore: cast_nullable_to_non_nullable
as int,appliedSocietyCut: null == appliedSocietyCut ? _self.appliedSocietyCut : appliedSocietyCut // ignore: cast_nullable_to_non_nullable
as double,teeName: null == teeName ? _self.teeName : teeName // ignore: cast_nullable_to_non_nullable
as String,teeColor: freezed == teeColor ? _self.teeColor : teeColor // ignore: cast_nullable_to_non_nullable
as String?,holeScores: null == holeScores ? _self.holeScores : holeScores // ignore: cast_nullable_to_non_nullable
as List<int?>,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ScoringResult,tieBreakLabel: freezed == tieBreakLabel ? _self.tieBreakLabel : tieBreakLabel // ignore: cast_nullable_to_non_nullable
as String?,thruLabel: freezed == thruLabel ? _self.thruLabel : thruLabel // ignore: cast_nullable_to_non_nullable
as String?,scoringStatus: null == scoringStatus ? _self.scoringStatus : scoringStatus // ignore: cast_nullable_to_non_nullable
as ScoringStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [ProcessedPlayerScore].
extension ProcessedPlayerScorePatterns on ProcessedPlayerScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProcessedPlayerScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProcessedPlayerScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProcessedPlayerScore value)  $default,){
final _that = this;
switch (_that) {
case _ProcessedPlayerScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProcessedPlayerScore value)?  $default,){
final _that = this;
switch (_that) {
case _ProcessedPlayerScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  String playerName,  bool isGuest,  double handicapIndex,  double courseHandicap,  int playingHandicap,  double appliedSocietyCut,  String teeName,  String? teeColor,  List<int?> holeScores,  ScoringResult result,  String? tieBreakLabel,  String? thruLabel,  ScoringStatus scoringStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProcessedPlayerScore() when $default != null:
return $default(_that.playerId,_that.playerName,_that.isGuest,_that.handicapIndex,_that.courseHandicap,_that.playingHandicap,_that.appliedSocietyCut,_that.teeName,_that.teeColor,_that.holeScores,_that.result,_that.tieBreakLabel,_that.thruLabel,_that.scoringStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  String playerName,  bool isGuest,  double handicapIndex,  double courseHandicap,  int playingHandicap,  double appliedSocietyCut,  String teeName,  String? teeColor,  List<int?> holeScores,  ScoringResult result,  String? tieBreakLabel,  String? thruLabel,  ScoringStatus scoringStatus)  $default,) {final _that = this;
switch (_that) {
case _ProcessedPlayerScore():
return $default(_that.playerId,_that.playerName,_that.isGuest,_that.handicapIndex,_that.courseHandicap,_that.playingHandicap,_that.appliedSocietyCut,_that.teeName,_that.teeColor,_that.holeScores,_that.result,_that.tieBreakLabel,_that.thruLabel,_that.scoringStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  String playerName,  bool isGuest,  double handicapIndex,  double courseHandicap,  int playingHandicap,  double appliedSocietyCut,  String teeName,  String? teeColor,  List<int?> holeScores,  ScoringResult result,  String? tieBreakLabel,  String? thruLabel,  ScoringStatus scoringStatus)?  $default,) {final _that = this;
switch (_that) {
case _ProcessedPlayerScore() when $default != null:
return $default(_that.playerId,_that.playerName,_that.isGuest,_that.handicapIndex,_that.courseHandicap,_that.playingHandicap,_that.appliedSocietyCut,_that.teeName,_that.teeColor,_that.holeScores,_that.result,_that.tieBreakLabel,_that.thruLabel,_that.scoringStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProcessedPlayerScore implements ProcessedPlayerScore {
  const _ProcessedPlayerScore({required this.playerId, required this.playerName, required this.isGuest, required this.handicapIndex, this.courseHandicap = 0.0, required this.playingHandicap, this.appliedSocietyCut = 0.0, required this.teeName, this.teeColor, required final  List<int?> holeScores, required this.result, this.tieBreakLabel, this.thruLabel, this.scoringStatus = ScoringStatus.ok}): _holeScores = holeScores;
  factory _ProcessedPlayerScore.fromJson(Map<String, dynamic> json) => _$ProcessedPlayerScoreFromJson(json);

@override final  String playerId;
@override final  String playerName;
@override final  bool isGuest;
@override final  double handicapIndex;
@override@JsonKey() final  double courseHandicap;
@override final  int playingHandicap;
@override@JsonKey() final  double appliedSocietyCut;
@override final  String teeName;
@override final  String? teeColor;
// [NEW]
 final  List<int?> _holeScores;
// [NEW]
@override List<int?> get holeScores {
  if (_holeScores is EqualUnmodifiableListView) return _holeScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holeScores);
}

@override final  ScoringResult result;
@override final  String? tieBreakLabel;
@override final  String? thruLabel;
@override@JsonKey() final  ScoringStatus scoringStatus;

/// Create a copy of ProcessedPlayerScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProcessedPlayerScoreCopyWith<_ProcessedPlayerScore> get copyWith => __$ProcessedPlayerScoreCopyWithImpl<_ProcessedPlayerScore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProcessedPlayerScoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProcessedPlayerScore&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&(identical(other.handicapIndex, handicapIndex) || other.handicapIndex == handicapIndex)&&(identical(other.courseHandicap, courseHandicap) || other.courseHandicap == courseHandicap)&&(identical(other.playingHandicap, playingHandicap) || other.playingHandicap == playingHandicap)&&(identical(other.appliedSocietyCut, appliedSocietyCut) || other.appliedSocietyCut == appliedSocietyCut)&&(identical(other.teeName, teeName) || other.teeName == teeName)&&(identical(other.teeColor, teeColor) || other.teeColor == teeColor)&&const DeepCollectionEquality().equals(other._holeScores, _holeScores)&&(identical(other.result, result) || other.result == result)&&(identical(other.tieBreakLabel, tieBreakLabel) || other.tieBreakLabel == tieBreakLabel)&&(identical(other.thruLabel, thruLabel) || other.thruLabel == thruLabel)&&(identical(other.scoringStatus, scoringStatus) || other.scoringStatus == scoringStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,playerName,isGuest,handicapIndex,courseHandicap,playingHandicap,appliedSocietyCut,teeName,teeColor,const DeepCollectionEquality().hash(_holeScores),result,tieBreakLabel,thruLabel,scoringStatus);

@override
String toString() {
  return 'ProcessedPlayerScore(playerId: $playerId, playerName: $playerName, isGuest: $isGuest, handicapIndex: $handicapIndex, courseHandicap: $courseHandicap, playingHandicap: $playingHandicap, appliedSocietyCut: $appliedSocietyCut, teeName: $teeName, teeColor: $teeColor, holeScores: $holeScores, result: $result, tieBreakLabel: $tieBreakLabel, thruLabel: $thruLabel, scoringStatus: $scoringStatus)';
}


}

/// @nodoc
abstract mixin class _$ProcessedPlayerScoreCopyWith<$Res> implements $ProcessedPlayerScoreCopyWith<$Res> {
  factory _$ProcessedPlayerScoreCopyWith(_ProcessedPlayerScore value, $Res Function(_ProcessedPlayerScore) _then) = __$ProcessedPlayerScoreCopyWithImpl;
@override @useResult
$Res call({
 String playerId, String playerName, bool isGuest, double handicapIndex, double courseHandicap, int playingHandicap, double appliedSocietyCut, String teeName, String? teeColor, List<int?> holeScores, ScoringResult result, String? tieBreakLabel, String? thruLabel, ScoringStatus scoringStatus
});




}
/// @nodoc
class __$ProcessedPlayerScoreCopyWithImpl<$Res>
    implements _$ProcessedPlayerScoreCopyWith<$Res> {
  __$ProcessedPlayerScoreCopyWithImpl(this._self, this._then);

  final _ProcessedPlayerScore _self;
  final $Res Function(_ProcessedPlayerScore) _then;

/// Create a copy of ProcessedPlayerScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? playerName = null,Object? isGuest = null,Object? handicapIndex = null,Object? courseHandicap = null,Object? playingHandicap = null,Object? appliedSocietyCut = null,Object? teeName = null,Object? teeColor = freezed,Object? holeScores = null,Object? result = null,Object? tieBreakLabel = freezed,Object? thruLabel = freezed,Object? scoringStatus = null,}) {
  return _then(_ProcessedPlayerScore(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,handicapIndex: null == handicapIndex ? _self.handicapIndex : handicapIndex // ignore: cast_nullable_to_non_nullable
as double,courseHandicap: null == courseHandicap ? _self.courseHandicap : courseHandicap // ignore: cast_nullable_to_non_nullable
as double,playingHandicap: null == playingHandicap ? _self.playingHandicap : playingHandicap // ignore: cast_nullable_to_non_nullable
as int,appliedSocietyCut: null == appliedSocietyCut ? _self.appliedSocietyCut : appliedSocietyCut // ignore: cast_nullable_to_non_nullable
as double,teeName: null == teeName ? _self.teeName : teeName // ignore: cast_nullable_to_non_nullable
as String,teeColor: freezed == teeColor ? _self.teeColor : teeColor // ignore: cast_nullable_to_non_nullable
as String?,holeScores: null == holeScores ? _self._holeScores : holeScores // ignore: cast_nullable_to_non_nullable
as List<int?>,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ScoringResult,tieBreakLabel: freezed == tieBreakLabel ? _self.tieBreakLabel : tieBreakLabel // ignore: cast_nullable_to_non_nullable
as String?,thruLabel: freezed == thruLabel ? _self.thruLabel : thruLabel // ignore: cast_nullable_to_non_nullable
as String?,scoringStatus: null == scoringStatus ? _self.scoringStatus : scoringStatus // ignore: cast_nullable_to_non_nullable
as ScoringStatus,
  ));
}


}


/// @nodoc
mixin _$ProcessedGroupResult {

 int get groupIndex; String get label; int get totalScore; List<int> get tieBreakMetrics; int? get sideAScore; int? get sideBScore; String? get sideALabel; String? get sideBLabel;
/// Create a copy of ProcessedGroupResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessedGroupResultCopyWith<ProcessedGroupResult> get copyWith => _$ProcessedGroupResultCopyWithImpl<ProcessedGroupResult>(this as ProcessedGroupResult, _$identity);

  /// Serializes this ProcessedGroupResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessedGroupResult&&(identical(other.groupIndex, groupIndex) || other.groupIndex == groupIndex)&&(identical(other.label, label) || other.label == label)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore)&&const DeepCollectionEquality().equals(other.tieBreakMetrics, tieBreakMetrics)&&(identical(other.sideAScore, sideAScore) || other.sideAScore == sideAScore)&&(identical(other.sideBScore, sideBScore) || other.sideBScore == sideBScore)&&(identical(other.sideALabel, sideALabel) || other.sideALabel == sideALabel)&&(identical(other.sideBLabel, sideBLabel) || other.sideBLabel == sideBLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupIndex,label,totalScore,const DeepCollectionEquality().hash(tieBreakMetrics),sideAScore,sideBScore,sideALabel,sideBLabel);

@override
String toString() {
  return 'ProcessedGroupResult(groupIndex: $groupIndex, label: $label, totalScore: $totalScore, tieBreakMetrics: $tieBreakMetrics, sideAScore: $sideAScore, sideBScore: $sideBScore, sideALabel: $sideALabel, sideBLabel: $sideBLabel)';
}


}

/// @nodoc
abstract mixin class $ProcessedGroupResultCopyWith<$Res>  {
  factory $ProcessedGroupResultCopyWith(ProcessedGroupResult value, $Res Function(ProcessedGroupResult) _then) = _$ProcessedGroupResultCopyWithImpl;
@useResult
$Res call({
 int groupIndex, String label, int totalScore, List<int> tieBreakMetrics, int? sideAScore, int? sideBScore, String? sideALabel, String? sideBLabel
});




}
/// @nodoc
class _$ProcessedGroupResultCopyWithImpl<$Res>
    implements $ProcessedGroupResultCopyWith<$Res> {
  _$ProcessedGroupResultCopyWithImpl(this._self, this._then);

  final ProcessedGroupResult _self;
  final $Res Function(ProcessedGroupResult) _then;

/// Create a copy of ProcessedGroupResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupIndex = null,Object? label = null,Object? totalScore = null,Object? tieBreakMetrics = null,Object? sideAScore = freezed,Object? sideBScore = freezed,Object? sideALabel = freezed,Object? sideBLabel = freezed,}) {
  return _then(_self.copyWith(
groupIndex: null == groupIndex ? _self.groupIndex : groupIndex // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,tieBreakMetrics: null == tieBreakMetrics ? _self.tieBreakMetrics : tieBreakMetrics // ignore: cast_nullable_to_non_nullable
as List<int>,sideAScore: freezed == sideAScore ? _self.sideAScore : sideAScore // ignore: cast_nullable_to_non_nullable
as int?,sideBScore: freezed == sideBScore ? _self.sideBScore : sideBScore // ignore: cast_nullable_to_non_nullable
as int?,sideALabel: freezed == sideALabel ? _self.sideALabel : sideALabel // ignore: cast_nullable_to_non_nullable
as String?,sideBLabel: freezed == sideBLabel ? _self.sideBLabel : sideBLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProcessedGroupResult].
extension ProcessedGroupResultPatterns on ProcessedGroupResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProcessedGroupResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProcessedGroupResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProcessedGroupResult value)  $default,){
final _that = this;
switch (_that) {
case _ProcessedGroupResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProcessedGroupResult value)?  $default,){
final _that = this;
switch (_that) {
case _ProcessedGroupResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int groupIndex,  String label,  int totalScore,  List<int> tieBreakMetrics,  int? sideAScore,  int? sideBScore,  String? sideALabel,  String? sideBLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProcessedGroupResult() when $default != null:
return $default(_that.groupIndex,_that.label,_that.totalScore,_that.tieBreakMetrics,_that.sideAScore,_that.sideBScore,_that.sideALabel,_that.sideBLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int groupIndex,  String label,  int totalScore,  List<int> tieBreakMetrics,  int? sideAScore,  int? sideBScore,  String? sideALabel,  String? sideBLabel)  $default,) {final _that = this;
switch (_that) {
case _ProcessedGroupResult():
return $default(_that.groupIndex,_that.label,_that.totalScore,_that.tieBreakMetrics,_that.sideAScore,_that.sideBScore,_that.sideALabel,_that.sideBLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int groupIndex,  String label,  int totalScore,  List<int> tieBreakMetrics,  int? sideAScore,  int? sideBScore,  String? sideALabel,  String? sideBLabel)?  $default,) {final _that = this;
switch (_that) {
case _ProcessedGroupResult() when $default != null:
return $default(_that.groupIndex,_that.label,_that.totalScore,_that.tieBreakMetrics,_that.sideAScore,_that.sideBScore,_that.sideALabel,_that.sideBLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProcessedGroupResult implements ProcessedGroupResult {
  const _ProcessedGroupResult({required this.groupIndex, required this.label, required this.totalScore, required final  List<int> tieBreakMetrics, this.sideAScore, this.sideBScore, this.sideALabel, this.sideBLabel}): _tieBreakMetrics = tieBreakMetrics;
  factory _ProcessedGroupResult.fromJson(Map<String, dynamic> json) => _$ProcessedGroupResultFromJson(json);

@override final  int groupIndex;
@override final  String label;
@override final  int totalScore;
 final  List<int> _tieBreakMetrics;
@override List<int> get tieBreakMetrics {
  if (_tieBreakMetrics is EqualUnmodifiableListView) return _tieBreakMetrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tieBreakMetrics);
}

@override final  int? sideAScore;
@override final  int? sideBScore;
@override final  String? sideALabel;
@override final  String? sideBLabel;

/// Create a copy of ProcessedGroupResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProcessedGroupResultCopyWith<_ProcessedGroupResult> get copyWith => __$ProcessedGroupResultCopyWithImpl<_ProcessedGroupResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProcessedGroupResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProcessedGroupResult&&(identical(other.groupIndex, groupIndex) || other.groupIndex == groupIndex)&&(identical(other.label, label) || other.label == label)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore)&&const DeepCollectionEquality().equals(other._tieBreakMetrics, _tieBreakMetrics)&&(identical(other.sideAScore, sideAScore) || other.sideAScore == sideAScore)&&(identical(other.sideBScore, sideBScore) || other.sideBScore == sideBScore)&&(identical(other.sideALabel, sideALabel) || other.sideALabel == sideALabel)&&(identical(other.sideBLabel, sideBLabel) || other.sideBLabel == sideBLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupIndex,label,totalScore,const DeepCollectionEquality().hash(_tieBreakMetrics),sideAScore,sideBScore,sideALabel,sideBLabel);

@override
String toString() {
  return 'ProcessedGroupResult(groupIndex: $groupIndex, label: $label, totalScore: $totalScore, tieBreakMetrics: $tieBreakMetrics, sideAScore: $sideAScore, sideBScore: $sideBScore, sideALabel: $sideALabel, sideBLabel: $sideBLabel)';
}


}

/// @nodoc
abstract mixin class _$ProcessedGroupResultCopyWith<$Res> implements $ProcessedGroupResultCopyWith<$Res> {
  factory _$ProcessedGroupResultCopyWith(_ProcessedGroupResult value, $Res Function(_ProcessedGroupResult) _then) = __$ProcessedGroupResultCopyWithImpl;
@override @useResult
$Res call({
 int groupIndex, String label, int totalScore, List<int> tieBreakMetrics, int? sideAScore, int? sideBScore, String? sideALabel, String? sideBLabel
});




}
/// @nodoc
class __$ProcessedGroupResultCopyWithImpl<$Res>
    implements _$ProcessedGroupResultCopyWith<$Res> {
  __$ProcessedGroupResultCopyWithImpl(this._self, this._then);

  final _ProcessedGroupResult _self;
  final $Res Function(_ProcessedGroupResult) _then;

/// Create a copy of ProcessedGroupResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupIndex = null,Object? label = null,Object? totalScore = null,Object? tieBreakMetrics = null,Object? sideAScore = freezed,Object? sideBScore = freezed,Object? sideALabel = freezed,Object? sideBLabel = freezed,}) {
  return _then(_ProcessedGroupResult(
groupIndex: null == groupIndex ? _self.groupIndex : groupIndex // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,tieBreakMetrics: null == tieBreakMetrics ? _self._tieBreakMetrics : tieBreakMetrics // ignore: cast_nullable_to_non_nullable
as List<int>,sideAScore: freezed == sideAScore ? _self.sideAScore : sideAScore // ignore: cast_nullable_to_non_nullable
as int?,sideBScore: freezed == sideBScore ? _self.sideBScore : sideBScore // ignore: cast_nullable_to_non_nullable
as int?,sideALabel: freezed == sideALabel ? _self.sideALabel : sideALabel // ignore: cast_nullable_to_non_nullable
as String?,sideBLabel: freezed == sideBLabel ? _self.sideBLabel : sideBLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProcessedLeaderboardEntry {

 String get entryId; String get playerName; int get score; String get scoreLabel; int get holesPlayed; bool get isGuest; List<String> get teamMemberIds; List<String> get teamMemberNames; List<int> get individualPlayingHandicaps; List<int?> get holeNetScores; List<List<int?>>? get individualHoleScores; List<List<int?>>? get individualHoleNetScores; List<List<int?>>? get individualHolePoints; List<int?>? get holeScores; List<int?>? get holePoints; bool get hasSocietyCut; int get position; List<int> get tieBreakMetrics; ScoringStatus get scoringStatus; double? get handicapIndex; String? get tieBreakLabel; String? get thruLabel;// [NEW]
 String? get matchStatus;// [NEW] e.g. "WIN 7 & 6", "2 UP", "AS"
 int? get matchScore;// [NEW] lead tracking
 bool get isMatch;// [NEW] flag for match play entries
 String? get teeName;// [NEW]
 String? get teeColor;// [NEW]
 int? get absoluteScore;// [NEW]
 String? get absoluteScoreLabel;
/// Create a copy of ProcessedLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessedLeaderboardEntryCopyWith<ProcessedLeaderboardEntry> get copyWith => _$ProcessedLeaderboardEntryCopyWithImpl<ProcessedLeaderboardEntry>(this as ProcessedLeaderboardEntry, _$identity);

  /// Serializes this ProcessedLeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessedLeaderboardEntry&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.score, score) || other.score == score)&&(identical(other.scoreLabel, scoreLabel) || other.scoreLabel == scoreLabel)&&(identical(other.holesPlayed, holesPlayed) || other.holesPlayed == holesPlayed)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&const DeepCollectionEquality().equals(other.teamMemberIds, teamMemberIds)&&const DeepCollectionEquality().equals(other.teamMemberNames, teamMemberNames)&&const DeepCollectionEquality().equals(other.individualPlayingHandicaps, individualPlayingHandicaps)&&const DeepCollectionEquality().equals(other.holeNetScores, holeNetScores)&&const DeepCollectionEquality().equals(other.individualHoleScores, individualHoleScores)&&const DeepCollectionEquality().equals(other.individualHoleNetScores, individualHoleNetScores)&&const DeepCollectionEquality().equals(other.individualHolePoints, individualHolePoints)&&const DeepCollectionEquality().equals(other.holeScores, holeScores)&&const DeepCollectionEquality().equals(other.holePoints, holePoints)&&(identical(other.hasSocietyCut, hasSocietyCut) || other.hasSocietyCut == hasSocietyCut)&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other.tieBreakMetrics, tieBreakMetrics)&&(identical(other.scoringStatus, scoringStatus) || other.scoringStatus == scoringStatus)&&(identical(other.handicapIndex, handicapIndex) || other.handicapIndex == handicapIndex)&&(identical(other.tieBreakLabel, tieBreakLabel) || other.tieBreakLabel == tieBreakLabel)&&(identical(other.thruLabel, thruLabel) || other.thruLabel == thruLabel)&&(identical(other.matchStatus, matchStatus) || other.matchStatus == matchStatus)&&(identical(other.matchScore, matchScore) || other.matchScore == matchScore)&&(identical(other.isMatch, isMatch) || other.isMatch == isMatch)&&(identical(other.teeName, teeName) || other.teeName == teeName)&&(identical(other.teeColor, teeColor) || other.teeColor == teeColor)&&(identical(other.absoluteScore, absoluteScore) || other.absoluteScore == absoluteScore)&&(identical(other.absoluteScoreLabel, absoluteScoreLabel) || other.absoluteScoreLabel == absoluteScoreLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,entryId,playerName,score,scoreLabel,holesPlayed,isGuest,const DeepCollectionEquality().hash(teamMemberIds),const DeepCollectionEquality().hash(teamMemberNames),const DeepCollectionEquality().hash(individualPlayingHandicaps),const DeepCollectionEquality().hash(holeNetScores),const DeepCollectionEquality().hash(individualHoleScores),const DeepCollectionEquality().hash(individualHoleNetScores),const DeepCollectionEquality().hash(individualHolePoints),const DeepCollectionEquality().hash(holeScores),const DeepCollectionEquality().hash(holePoints),hasSocietyCut,position,const DeepCollectionEquality().hash(tieBreakMetrics),scoringStatus,handicapIndex,tieBreakLabel,thruLabel,matchStatus,matchScore,isMatch,teeName,teeColor,absoluteScore,absoluteScoreLabel]);

@override
String toString() {
  return 'ProcessedLeaderboardEntry(entryId: $entryId, playerName: $playerName, score: $score, scoreLabel: $scoreLabel, holesPlayed: $holesPlayed, isGuest: $isGuest, teamMemberIds: $teamMemberIds, teamMemberNames: $teamMemberNames, individualPlayingHandicaps: $individualPlayingHandicaps, holeNetScores: $holeNetScores, individualHoleScores: $individualHoleScores, individualHoleNetScores: $individualHoleNetScores, individualHolePoints: $individualHolePoints, holeScores: $holeScores, holePoints: $holePoints, hasSocietyCut: $hasSocietyCut, position: $position, tieBreakMetrics: $tieBreakMetrics, scoringStatus: $scoringStatus, handicapIndex: $handicapIndex, tieBreakLabel: $tieBreakLabel, thruLabel: $thruLabel, matchStatus: $matchStatus, matchScore: $matchScore, isMatch: $isMatch, teeName: $teeName, teeColor: $teeColor, absoluteScore: $absoluteScore, absoluteScoreLabel: $absoluteScoreLabel)';
}


}

/// @nodoc
abstract mixin class $ProcessedLeaderboardEntryCopyWith<$Res>  {
  factory $ProcessedLeaderboardEntryCopyWith(ProcessedLeaderboardEntry value, $Res Function(ProcessedLeaderboardEntry) _then) = _$ProcessedLeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 String entryId, String playerName, int score, String scoreLabel, int holesPlayed, bool isGuest, List<String> teamMemberIds, List<String> teamMemberNames, List<int> individualPlayingHandicaps, List<int?> holeNetScores, List<List<int?>>? individualHoleScores, List<List<int?>>? individualHoleNetScores, List<List<int?>>? individualHolePoints, List<int?>? holeScores, List<int?>? holePoints, bool hasSocietyCut, int position, List<int> tieBreakMetrics, ScoringStatus scoringStatus, double? handicapIndex, String? tieBreakLabel, String? thruLabel, String? matchStatus, int? matchScore, bool isMatch, String? teeName, String? teeColor, int? absoluteScore, String? absoluteScoreLabel
});




}
/// @nodoc
class _$ProcessedLeaderboardEntryCopyWithImpl<$Res>
    implements $ProcessedLeaderboardEntryCopyWith<$Res> {
  _$ProcessedLeaderboardEntryCopyWithImpl(this._self, this._then);

  final ProcessedLeaderboardEntry _self;
  final $Res Function(ProcessedLeaderboardEntry) _then;

/// Create a copy of ProcessedLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entryId = null,Object? playerName = null,Object? score = null,Object? scoreLabel = null,Object? holesPlayed = null,Object? isGuest = null,Object? teamMemberIds = null,Object? teamMemberNames = null,Object? individualPlayingHandicaps = null,Object? holeNetScores = null,Object? individualHoleScores = freezed,Object? individualHoleNetScores = freezed,Object? individualHolePoints = freezed,Object? holeScores = freezed,Object? holePoints = freezed,Object? hasSocietyCut = null,Object? position = null,Object? tieBreakMetrics = null,Object? scoringStatus = null,Object? handicapIndex = freezed,Object? tieBreakLabel = freezed,Object? thruLabel = freezed,Object? matchStatus = freezed,Object? matchScore = freezed,Object? isMatch = null,Object? teeName = freezed,Object? teeColor = freezed,Object? absoluteScore = freezed,Object? absoluteScoreLabel = freezed,}) {
  return _then(_self.copyWith(
entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,scoreLabel: null == scoreLabel ? _self.scoreLabel : scoreLabel // ignore: cast_nullable_to_non_nullable
as String,holesPlayed: null == holesPlayed ? _self.holesPlayed : holesPlayed // ignore: cast_nullable_to_non_nullable
as int,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,teamMemberIds: null == teamMemberIds ? _self.teamMemberIds : teamMemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,teamMemberNames: null == teamMemberNames ? _self.teamMemberNames : teamMemberNames // ignore: cast_nullable_to_non_nullable
as List<String>,individualPlayingHandicaps: null == individualPlayingHandicaps ? _self.individualPlayingHandicaps : individualPlayingHandicaps // ignore: cast_nullable_to_non_nullable
as List<int>,holeNetScores: null == holeNetScores ? _self.holeNetScores : holeNetScores // ignore: cast_nullable_to_non_nullable
as List<int?>,individualHoleScores: freezed == individualHoleScores ? _self.individualHoleScores : individualHoleScores // ignore: cast_nullable_to_non_nullable
as List<List<int?>>?,individualHoleNetScores: freezed == individualHoleNetScores ? _self.individualHoleNetScores : individualHoleNetScores // ignore: cast_nullable_to_non_nullable
as List<List<int?>>?,individualHolePoints: freezed == individualHolePoints ? _self.individualHolePoints : individualHolePoints // ignore: cast_nullable_to_non_nullable
as List<List<int?>>?,holeScores: freezed == holeScores ? _self.holeScores : holeScores // ignore: cast_nullable_to_non_nullable
as List<int?>?,holePoints: freezed == holePoints ? _self.holePoints : holePoints // ignore: cast_nullable_to_non_nullable
as List<int?>?,hasSocietyCut: null == hasSocietyCut ? _self.hasSocietyCut : hasSocietyCut // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,tieBreakMetrics: null == tieBreakMetrics ? _self.tieBreakMetrics : tieBreakMetrics // ignore: cast_nullable_to_non_nullable
as List<int>,scoringStatus: null == scoringStatus ? _self.scoringStatus : scoringStatus // ignore: cast_nullable_to_non_nullable
as ScoringStatus,handicapIndex: freezed == handicapIndex ? _self.handicapIndex : handicapIndex // ignore: cast_nullable_to_non_nullable
as double?,tieBreakLabel: freezed == tieBreakLabel ? _self.tieBreakLabel : tieBreakLabel // ignore: cast_nullable_to_non_nullable
as String?,thruLabel: freezed == thruLabel ? _self.thruLabel : thruLabel // ignore: cast_nullable_to_non_nullable
as String?,matchStatus: freezed == matchStatus ? _self.matchStatus : matchStatus // ignore: cast_nullable_to_non_nullable
as String?,matchScore: freezed == matchScore ? _self.matchScore : matchScore // ignore: cast_nullable_to_non_nullable
as int?,isMatch: null == isMatch ? _self.isMatch : isMatch // ignore: cast_nullable_to_non_nullable
as bool,teeName: freezed == teeName ? _self.teeName : teeName // ignore: cast_nullable_to_non_nullable
as String?,teeColor: freezed == teeColor ? _self.teeColor : teeColor // ignore: cast_nullable_to_non_nullable
as String?,absoluteScore: freezed == absoluteScore ? _self.absoluteScore : absoluteScore // ignore: cast_nullable_to_non_nullable
as int?,absoluteScoreLabel: freezed == absoluteScoreLabel ? _self.absoluteScoreLabel : absoluteScoreLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProcessedLeaderboardEntry].
extension ProcessedLeaderboardEntryPatterns on ProcessedLeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProcessedLeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProcessedLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProcessedLeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _ProcessedLeaderboardEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProcessedLeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ProcessedLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String entryId,  String playerName,  int score,  String scoreLabel,  int holesPlayed,  bool isGuest,  List<String> teamMemberIds,  List<String> teamMemberNames,  List<int> individualPlayingHandicaps,  List<int?> holeNetScores,  List<List<int?>>? individualHoleScores,  List<List<int?>>? individualHoleNetScores,  List<List<int?>>? individualHolePoints,  List<int?>? holeScores,  List<int?>? holePoints,  bool hasSocietyCut,  int position,  List<int> tieBreakMetrics,  ScoringStatus scoringStatus,  double? handicapIndex,  String? tieBreakLabel,  String? thruLabel,  String? matchStatus,  int? matchScore,  bool isMatch,  String? teeName,  String? teeColor,  int? absoluteScore,  String? absoluteScoreLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProcessedLeaderboardEntry() when $default != null:
return $default(_that.entryId,_that.playerName,_that.score,_that.scoreLabel,_that.holesPlayed,_that.isGuest,_that.teamMemberIds,_that.teamMemberNames,_that.individualPlayingHandicaps,_that.holeNetScores,_that.individualHoleScores,_that.individualHoleNetScores,_that.individualHolePoints,_that.holeScores,_that.holePoints,_that.hasSocietyCut,_that.position,_that.tieBreakMetrics,_that.scoringStatus,_that.handicapIndex,_that.tieBreakLabel,_that.thruLabel,_that.matchStatus,_that.matchScore,_that.isMatch,_that.teeName,_that.teeColor,_that.absoluteScore,_that.absoluteScoreLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String entryId,  String playerName,  int score,  String scoreLabel,  int holesPlayed,  bool isGuest,  List<String> teamMemberIds,  List<String> teamMemberNames,  List<int> individualPlayingHandicaps,  List<int?> holeNetScores,  List<List<int?>>? individualHoleScores,  List<List<int?>>? individualHoleNetScores,  List<List<int?>>? individualHolePoints,  List<int?>? holeScores,  List<int?>? holePoints,  bool hasSocietyCut,  int position,  List<int> tieBreakMetrics,  ScoringStatus scoringStatus,  double? handicapIndex,  String? tieBreakLabel,  String? thruLabel,  String? matchStatus,  int? matchScore,  bool isMatch,  String? teeName,  String? teeColor,  int? absoluteScore,  String? absoluteScoreLabel)  $default,) {final _that = this;
switch (_that) {
case _ProcessedLeaderboardEntry():
return $default(_that.entryId,_that.playerName,_that.score,_that.scoreLabel,_that.holesPlayed,_that.isGuest,_that.teamMemberIds,_that.teamMemberNames,_that.individualPlayingHandicaps,_that.holeNetScores,_that.individualHoleScores,_that.individualHoleNetScores,_that.individualHolePoints,_that.holeScores,_that.holePoints,_that.hasSocietyCut,_that.position,_that.tieBreakMetrics,_that.scoringStatus,_that.handicapIndex,_that.tieBreakLabel,_that.thruLabel,_that.matchStatus,_that.matchScore,_that.isMatch,_that.teeName,_that.teeColor,_that.absoluteScore,_that.absoluteScoreLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String entryId,  String playerName,  int score,  String scoreLabel,  int holesPlayed,  bool isGuest,  List<String> teamMemberIds,  List<String> teamMemberNames,  List<int> individualPlayingHandicaps,  List<int?> holeNetScores,  List<List<int?>>? individualHoleScores,  List<List<int?>>? individualHoleNetScores,  List<List<int?>>? individualHolePoints,  List<int?>? holeScores,  List<int?>? holePoints,  bool hasSocietyCut,  int position,  List<int> tieBreakMetrics,  ScoringStatus scoringStatus,  double? handicapIndex,  String? tieBreakLabel,  String? thruLabel,  String? matchStatus,  int? matchScore,  bool isMatch,  String? teeName,  String? teeColor,  int? absoluteScore,  String? absoluteScoreLabel)?  $default,) {final _that = this;
switch (_that) {
case _ProcessedLeaderboardEntry() when $default != null:
return $default(_that.entryId,_that.playerName,_that.score,_that.scoreLabel,_that.holesPlayed,_that.isGuest,_that.teamMemberIds,_that.teamMemberNames,_that.individualPlayingHandicaps,_that.holeNetScores,_that.individualHoleScores,_that.individualHoleNetScores,_that.individualHolePoints,_that.holeScores,_that.holePoints,_that.hasSocietyCut,_that.position,_that.tieBreakMetrics,_that.scoringStatus,_that.handicapIndex,_that.tieBreakLabel,_that.thruLabel,_that.matchStatus,_that.matchScore,_that.isMatch,_that.teeName,_that.teeColor,_that.absoluteScore,_that.absoluteScoreLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProcessedLeaderboardEntry implements ProcessedLeaderboardEntry {
  const _ProcessedLeaderboardEntry({required this.entryId, required this.playerName, required this.score, required this.scoreLabel, required this.holesPlayed, required this.isGuest, required final  List<String> teamMemberIds, final  List<String> teamMemberNames = const [], required final  List<int> individualPlayingHandicaps, required final  List<int?> holeNetScores, final  List<List<int?>>? individualHoleScores, final  List<List<int?>>? individualHoleNetScores, final  List<List<int?>>? individualHolePoints, final  List<int?>? holeScores, final  List<int?>? holePoints, this.hasSocietyCut = false, required this.position, final  List<int> tieBreakMetrics = const [], this.scoringStatus = ScoringStatus.ok, this.handicapIndex, this.tieBreakLabel, this.thruLabel, this.matchStatus, this.matchScore, this.isMatch = false, this.teeName, this.teeColor, this.absoluteScore, this.absoluteScoreLabel}): _teamMemberIds = teamMemberIds,_teamMemberNames = teamMemberNames,_individualPlayingHandicaps = individualPlayingHandicaps,_holeNetScores = holeNetScores,_individualHoleScores = individualHoleScores,_individualHoleNetScores = individualHoleNetScores,_individualHolePoints = individualHolePoints,_holeScores = holeScores,_holePoints = holePoints,_tieBreakMetrics = tieBreakMetrics;
  factory _ProcessedLeaderboardEntry.fromJson(Map<String, dynamic> json) => _$ProcessedLeaderboardEntryFromJson(json);

@override final  String entryId;
@override final  String playerName;
@override final  int score;
@override final  String scoreLabel;
@override final  int holesPlayed;
@override final  bool isGuest;
 final  List<String> _teamMemberIds;
@override List<String> get teamMemberIds {
  if (_teamMemberIds is EqualUnmodifiableListView) return _teamMemberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teamMemberIds);
}

 final  List<String> _teamMemberNames;
@override@JsonKey() List<String> get teamMemberNames {
  if (_teamMemberNames is EqualUnmodifiableListView) return _teamMemberNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teamMemberNames);
}

 final  List<int> _individualPlayingHandicaps;
@override List<int> get individualPlayingHandicaps {
  if (_individualPlayingHandicaps is EqualUnmodifiableListView) return _individualPlayingHandicaps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_individualPlayingHandicaps);
}

 final  List<int?> _holeNetScores;
@override List<int?> get holeNetScores {
  if (_holeNetScores is EqualUnmodifiableListView) return _holeNetScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holeNetScores);
}

 final  List<List<int?>>? _individualHoleScores;
@override List<List<int?>>? get individualHoleScores {
  final value = _individualHoleScores;
  if (value == null) return null;
  if (_individualHoleScores is EqualUnmodifiableListView) return _individualHoleScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<List<int?>>? _individualHoleNetScores;
@override List<List<int?>>? get individualHoleNetScores {
  final value = _individualHoleNetScores;
  if (value == null) return null;
  if (_individualHoleNetScores is EqualUnmodifiableListView) return _individualHoleNetScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<List<int?>>? _individualHolePoints;
@override List<List<int?>>? get individualHolePoints {
  final value = _individualHolePoints;
  if (value == null) return null;
  if (_individualHolePoints is EqualUnmodifiableListView) return _individualHolePoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<int?>? _holeScores;
@override List<int?>? get holeScores {
  final value = _holeScores;
  if (value == null) return null;
  if (_holeScores is EqualUnmodifiableListView) return _holeScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<int?>? _holePoints;
@override List<int?>? get holePoints {
  final value = _holePoints;
  if (value == null) return null;
  if (_holePoints is EqualUnmodifiableListView) return _holePoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool hasSocietyCut;
@override final  int position;
 final  List<int> _tieBreakMetrics;
@override@JsonKey() List<int> get tieBreakMetrics {
  if (_tieBreakMetrics is EqualUnmodifiableListView) return _tieBreakMetrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tieBreakMetrics);
}

@override@JsonKey() final  ScoringStatus scoringStatus;
@override final  double? handicapIndex;
@override final  String? tieBreakLabel;
@override final  String? thruLabel;
// [NEW]
@override final  String? matchStatus;
// [NEW] e.g. "WIN 7 & 6", "2 UP", "AS"
@override final  int? matchScore;
// [NEW] lead tracking
@override@JsonKey() final  bool isMatch;
// [NEW] flag for match play entries
@override final  String? teeName;
// [NEW]
@override final  String? teeColor;
// [NEW]
@override final  int? absoluteScore;
// [NEW]
@override final  String? absoluteScoreLabel;

/// Create a copy of ProcessedLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProcessedLeaderboardEntryCopyWith<_ProcessedLeaderboardEntry> get copyWith => __$ProcessedLeaderboardEntryCopyWithImpl<_ProcessedLeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProcessedLeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProcessedLeaderboardEntry&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.score, score) || other.score == score)&&(identical(other.scoreLabel, scoreLabel) || other.scoreLabel == scoreLabel)&&(identical(other.holesPlayed, holesPlayed) || other.holesPlayed == holesPlayed)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&const DeepCollectionEquality().equals(other._teamMemberIds, _teamMemberIds)&&const DeepCollectionEquality().equals(other._teamMemberNames, _teamMemberNames)&&const DeepCollectionEquality().equals(other._individualPlayingHandicaps, _individualPlayingHandicaps)&&const DeepCollectionEquality().equals(other._holeNetScores, _holeNetScores)&&const DeepCollectionEquality().equals(other._individualHoleScores, _individualHoleScores)&&const DeepCollectionEquality().equals(other._individualHoleNetScores, _individualHoleNetScores)&&const DeepCollectionEquality().equals(other._individualHolePoints, _individualHolePoints)&&const DeepCollectionEquality().equals(other._holeScores, _holeScores)&&const DeepCollectionEquality().equals(other._holePoints, _holePoints)&&(identical(other.hasSocietyCut, hasSocietyCut) || other.hasSocietyCut == hasSocietyCut)&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other._tieBreakMetrics, _tieBreakMetrics)&&(identical(other.scoringStatus, scoringStatus) || other.scoringStatus == scoringStatus)&&(identical(other.handicapIndex, handicapIndex) || other.handicapIndex == handicapIndex)&&(identical(other.tieBreakLabel, tieBreakLabel) || other.tieBreakLabel == tieBreakLabel)&&(identical(other.thruLabel, thruLabel) || other.thruLabel == thruLabel)&&(identical(other.matchStatus, matchStatus) || other.matchStatus == matchStatus)&&(identical(other.matchScore, matchScore) || other.matchScore == matchScore)&&(identical(other.isMatch, isMatch) || other.isMatch == isMatch)&&(identical(other.teeName, teeName) || other.teeName == teeName)&&(identical(other.teeColor, teeColor) || other.teeColor == teeColor)&&(identical(other.absoluteScore, absoluteScore) || other.absoluteScore == absoluteScore)&&(identical(other.absoluteScoreLabel, absoluteScoreLabel) || other.absoluteScoreLabel == absoluteScoreLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,entryId,playerName,score,scoreLabel,holesPlayed,isGuest,const DeepCollectionEquality().hash(_teamMemberIds),const DeepCollectionEquality().hash(_teamMemberNames),const DeepCollectionEquality().hash(_individualPlayingHandicaps),const DeepCollectionEquality().hash(_holeNetScores),const DeepCollectionEquality().hash(_individualHoleScores),const DeepCollectionEquality().hash(_individualHoleNetScores),const DeepCollectionEquality().hash(_individualHolePoints),const DeepCollectionEquality().hash(_holeScores),const DeepCollectionEquality().hash(_holePoints),hasSocietyCut,position,const DeepCollectionEquality().hash(_tieBreakMetrics),scoringStatus,handicapIndex,tieBreakLabel,thruLabel,matchStatus,matchScore,isMatch,teeName,teeColor,absoluteScore,absoluteScoreLabel]);

@override
String toString() {
  return 'ProcessedLeaderboardEntry(entryId: $entryId, playerName: $playerName, score: $score, scoreLabel: $scoreLabel, holesPlayed: $holesPlayed, isGuest: $isGuest, teamMemberIds: $teamMemberIds, teamMemberNames: $teamMemberNames, individualPlayingHandicaps: $individualPlayingHandicaps, holeNetScores: $holeNetScores, individualHoleScores: $individualHoleScores, individualHoleNetScores: $individualHoleNetScores, individualHolePoints: $individualHolePoints, holeScores: $holeScores, holePoints: $holePoints, hasSocietyCut: $hasSocietyCut, position: $position, tieBreakMetrics: $tieBreakMetrics, scoringStatus: $scoringStatus, handicapIndex: $handicapIndex, tieBreakLabel: $tieBreakLabel, thruLabel: $thruLabel, matchStatus: $matchStatus, matchScore: $matchScore, isMatch: $isMatch, teeName: $teeName, teeColor: $teeColor, absoluteScore: $absoluteScore, absoluteScoreLabel: $absoluteScoreLabel)';
}


}

/// @nodoc
abstract mixin class _$ProcessedLeaderboardEntryCopyWith<$Res> implements $ProcessedLeaderboardEntryCopyWith<$Res> {
  factory _$ProcessedLeaderboardEntryCopyWith(_ProcessedLeaderboardEntry value, $Res Function(_ProcessedLeaderboardEntry) _then) = __$ProcessedLeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 String entryId, String playerName, int score, String scoreLabel, int holesPlayed, bool isGuest, List<String> teamMemberIds, List<String> teamMemberNames, List<int> individualPlayingHandicaps, List<int?> holeNetScores, List<List<int?>>? individualHoleScores, List<List<int?>>? individualHoleNetScores, List<List<int?>>? individualHolePoints, List<int?>? holeScores, List<int?>? holePoints, bool hasSocietyCut, int position, List<int> tieBreakMetrics, ScoringStatus scoringStatus, double? handicapIndex, String? tieBreakLabel, String? thruLabel, String? matchStatus, int? matchScore, bool isMatch, String? teeName, String? teeColor, int? absoluteScore, String? absoluteScoreLabel
});




}
/// @nodoc
class __$ProcessedLeaderboardEntryCopyWithImpl<$Res>
    implements _$ProcessedLeaderboardEntryCopyWith<$Res> {
  __$ProcessedLeaderboardEntryCopyWithImpl(this._self, this._then);

  final _ProcessedLeaderboardEntry _self;
  final $Res Function(_ProcessedLeaderboardEntry) _then;

/// Create a copy of ProcessedLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entryId = null,Object? playerName = null,Object? score = null,Object? scoreLabel = null,Object? holesPlayed = null,Object? isGuest = null,Object? teamMemberIds = null,Object? teamMemberNames = null,Object? individualPlayingHandicaps = null,Object? holeNetScores = null,Object? individualHoleScores = freezed,Object? individualHoleNetScores = freezed,Object? individualHolePoints = freezed,Object? holeScores = freezed,Object? holePoints = freezed,Object? hasSocietyCut = null,Object? position = null,Object? tieBreakMetrics = null,Object? scoringStatus = null,Object? handicapIndex = freezed,Object? tieBreakLabel = freezed,Object? thruLabel = freezed,Object? matchStatus = freezed,Object? matchScore = freezed,Object? isMatch = null,Object? teeName = freezed,Object? teeColor = freezed,Object? absoluteScore = freezed,Object? absoluteScoreLabel = freezed,}) {
  return _then(_ProcessedLeaderboardEntry(
entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,scoreLabel: null == scoreLabel ? _self.scoreLabel : scoreLabel // ignore: cast_nullable_to_non_nullable
as String,holesPlayed: null == holesPlayed ? _self.holesPlayed : holesPlayed // ignore: cast_nullable_to_non_nullable
as int,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,teamMemberIds: null == teamMemberIds ? _self._teamMemberIds : teamMemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,teamMemberNames: null == teamMemberNames ? _self._teamMemberNames : teamMemberNames // ignore: cast_nullable_to_non_nullable
as List<String>,individualPlayingHandicaps: null == individualPlayingHandicaps ? _self._individualPlayingHandicaps : individualPlayingHandicaps // ignore: cast_nullable_to_non_nullable
as List<int>,holeNetScores: null == holeNetScores ? _self._holeNetScores : holeNetScores // ignore: cast_nullable_to_non_nullable
as List<int?>,individualHoleScores: freezed == individualHoleScores ? _self._individualHoleScores : individualHoleScores // ignore: cast_nullable_to_non_nullable
as List<List<int?>>?,individualHoleNetScores: freezed == individualHoleNetScores ? _self._individualHoleNetScores : individualHoleNetScores // ignore: cast_nullable_to_non_nullable
as List<List<int?>>?,individualHolePoints: freezed == individualHolePoints ? _self._individualHolePoints : individualHolePoints // ignore: cast_nullable_to_non_nullable
as List<List<int?>>?,holeScores: freezed == holeScores ? _self._holeScores : holeScores // ignore: cast_nullable_to_non_nullable
as List<int?>?,holePoints: freezed == holePoints ? _self._holePoints : holePoints // ignore: cast_nullable_to_non_nullable
as List<int?>?,hasSocietyCut: null == hasSocietyCut ? _self.hasSocietyCut : hasSocietyCut // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,tieBreakMetrics: null == tieBreakMetrics ? _self._tieBreakMetrics : tieBreakMetrics // ignore: cast_nullable_to_non_nullable
as List<int>,scoringStatus: null == scoringStatus ? _self.scoringStatus : scoringStatus // ignore: cast_nullable_to_non_nullable
as ScoringStatus,handicapIndex: freezed == handicapIndex ? _self.handicapIndex : handicapIndex // ignore: cast_nullable_to_non_nullable
as double?,tieBreakLabel: freezed == tieBreakLabel ? _self.tieBreakLabel : tieBreakLabel // ignore: cast_nullable_to_non_nullable
as String?,thruLabel: freezed == thruLabel ? _self.thruLabel : thruLabel // ignore: cast_nullable_to_non_nullable
as String?,matchStatus: freezed == matchStatus ? _self.matchStatus : matchStatus // ignore: cast_nullable_to_non_nullable
as String?,matchScore: freezed == matchScore ? _self.matchScore : matchScore // ignore: cast_nullable_to_non_nullable
as int?,isMatch: null == isMatch ? _self.isMatch : isMatch // ignore: cast_nullable_to_non_nullable
as bool,teeName: freezed == teeName ? _self.teeName : teeName // ignore: cast_nullable_to_non_nullable
as String?,teeColor: freezed == teeColor ? _self.teeColor : teeColor // ignore: cast_nullable_to_non_nullable
as String?,absoluteScore: freezed == absoluteScore ? _self.absoluteScore : absoluteScore // ignore: cast_nullable_to_non_nullable
as int?,absoluteScoreLabel: freezed == absoluteScoreLabel ? _self.absoluteScoreLabel : absoluteScoreLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProcessedEventData {

 String get eventId; List<ProcessedPlayerScore> get individualScores; List<ProcessedLeaderboardEntry> get leaderboard; List<ProcessedGroupResult> get groupRankings; Map<String, dynamic> get eventStats; List<int> get holePars; int get computeVersion; DateTime get lastComputedAt; int get totalParticipants; int get submittedCount; int get inProgressCount;
/// Create a copy of ProcessedEventData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessedEventDataCopyWith<ProcessedEventData> get copyWith => _$ProcessedEventDataCopyWithImpl<ProcessedEventData>(this as ProcessedEventData, _$identity);

  /// Serializes this ProcessedEventData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessedEventData&&(identical(other.eventId, eventId) || other.eventId == eventId)&&const DeepCollectionEquality().equals(other.individualScores, individualScores)&&const DeepCollectionEquality().equals(other.leaderboard, leaderboard)&&const DeepCollectionEquality().equals(other.groupRankings, groupRankings)&&const DeepCollectionEquality().equals(other.eventStats, eventStats)&&const DeepCollectionEquality().equals(other.holePars, holePars)&&(identical(other.computeVersion, computeVersion) || other.computeVersion == computeVersion)&&(identical(other.lastComputedAt, lastComputedAt) || other.lastComputedAt == lastComputedAt)&&(identical(other.totalParticipants, totalParticipants) || other.totalParticipants == totalParticipants)&&(identical(other.submittedCount, submittedCount) || other.submittedCount == submittedCount)&&(identical(other.inProgressCount, inProgressCount) || other.inProgressCount == inProgressCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,const DeepCollectionEquality().hash(individualScores),const DeepCollectionEquality().hash(leaderboard),const DeepCollectionEquality().hash(groupRankings),const DeepCollectionEquality().hash(eventStats),const DeepCollectionEquality().hash(holePars),computeVersion,lastComputedAt,totalParticipants,submittedCount,inProgressCount);

@override
String toString() {
  return 'ProcessedEventData(eventId: $eventId, individualScores: $individualScores, leaderboard: $leaderboard, groupRankings: $groupRankings, eventStats: $eventStats, holePars: $holePars, computeVersion: $computeVersion, lastComputedAt: $lastComputedAt, totalParticipants: $totalParticipants, submittedCount: $submittedCount, inProgressCount: $inProgressCount)';
}


}

/// @nodoc
abstract mixin class $ProcessedEventDataCopyWith<$Res>  {
  factory $ProcessedEventDataCopyWith(ProcessedEventData value, $Res Function(ProcessedEventData) _then) = _$ProcessedEventDataCopyWithImpl;
@useResult
$Res call({
 String eventId, List<ProcessedPlayerScore> individualScores, List<ProcessedLeaderboardEntry> leaderboard, List<ProcessedGroupResult> groupRankings, Map<String, dynamic> eventStats, List<int> holePars, int computeVersion, DateTime lastComputedAt, int totalParticipants, int submittedCount, int inProgressCount
});




}
/// @nodoc
class _$ProcessedEventDataCopyWithImpl<$Res>
    implements $ProcessedEventDataCopyWith<$Res> {
  _$ProcessedEventDataCopyWithImpl(this._self, this._then);

  final ProcessedEventData _self;
  final $Res Function(ProcessedEventData) _then;

/// Create a copy of ProcessedEventData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? individualScores = null,Object? leaderboard = null,Object? groupRankings = null,Object? eventStats = null,Object? holePars = null,Object? computeVersion = null,Object? lastComputedAt = null,Object? totalParticipants = null,Object? submittedCount = null,Object? inProgressCount = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,individualScores: null == individualScores ? _self.individualScores : individualScores // ignore: cast_nullable_to_non_nullable
as List<ProcessedPlayerScore>,leaderboard: null == leaderboard ? _self.leaderboard : leaderboard // ignore: cast_nullable_to_non_nullable
as List<ProcessedLeaderboardEntry>,groupRankings: null == groupRankings ? _self.groupRankings : groupRankings // ignore: cast_nullable_to_non_nullable
as List<ProcessedGroupResult>,eventStats: null == eventStats ? _self.eventStats : eventStats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,holePars: null == holePars ? _self.holePars : holePars // ignore: cast_nullable_to_non_nullable
as List<int>,computeVersion: null == computeVersion ? _self.computeVersion : computeVersion // ignore: cast_nullable_to_non_nullable
as int,lastComputedAt: null == lastComputedAt ? _self.lastComputedAt : lastComputedAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalParticipants: null == totalParticipants ? _self.totalParticipants : totalParticipants // ignore: cast_nullable_to_non_nullable
as int,submittedCount: null == submittedCount ? _self.submittedCount : submittedCount // ignore: cast_nullable_to_non_nullable
as int,inProgressCount: null == inProgressCount ? _self.inProgressCount : inProgressCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProcessedEventData].
extension ProcessedEventDataPatterns on ProcessedEventData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProcessedEventData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProcessedEventData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProcessedEventData value)  $default,){
final _that = this;
switch (_that) {
case _ProcessedEventData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProcessedEventData value)?  $default,){
final _that = this;
switch (_that) {
case _ProcessedEventData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventId,  List<ProcessedPlayerScore> individualScores,  List<ProcessedLeaderboardEntry> leaderboard,  List<ProcessedGroupResult> groupRankings,  Map<String, dynamic> eventStats,  List<int> holePars,  int computeVersion,  DateTime lastComputedAt,  int totalParticipants,  int submittedCount,  int inProgressCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProcessedEventData() when $default != null:
return $default(_that.eventId,_that.individualScores,_that.leaderboard,_that.groupRankings,_that.eventStats,_that.holePars,_that.computeVersion,_that.lastComputedAt,_that.totalParticipants,_that.submittedCount,_that.inProgressCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventId,  List<ProcessedPlayerScore> individualScores,  List<ProcessedLeaderboardEntry> leaderboard,  List<ProcessedGroupResult> groupRankings,  Map<String, dynamic> eventStats,  List<int> holePars,  int computeVersion,  DateTime lastComputedAt,  int totalParticipants,  int submittedCount,  int inProgressCount)  $default,) {final _that = this;
switch (_that) {
case _ProcessedEventData():
return $default(_that.eventId,_that.individualScores,_that.leaderboard,_that.groupRankings,_that.eventStats,_that.holePars,_that.computeVersion,_that.lastComputedAt,_that.totalParticipants,_that.submittedCount,_that.inProgressCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventId,  List<ProcessedPlayerScore> individualScores,  List<ProcessedLeaderboardEntry> leaderboard,  List<ProcessedGroupResult> groupRankings,  Map<String, dynamic> eventStats,  List<int> holePars,  int computeVersion,  DateTime lastComputedAt,  int totalParticipants,  int submittedCount,  int inProgressCount)?  $default,) {final _that = this;
switch (_that) {
case _ProcessedEventData() when $default != null:
return $default(_that.eventId,_that.individualScores,_that.leaderboard,_that.groupRankings,_that.eventStats,_that.holePars,_that.computeVersion,_that.lastComputedAt,_that.totalParticipants,_that.submittedCount,_that.inProgressCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProcessedEventData implements ProcessedEventData {
  const _ProcessedEventData({required this.eventId, required final  List<ProcessedPlayerScore> individualScores, required final  List<ProcessedLeaderboardEntry> leaderboard, required final  List<ProcessedGroupResult> groupRankings, required final  Map<String, dynamic> eventStats, required final  List<int> holePars, this.computeVersion = 0, required this.lastComputedAt, this.totalParticipants = 0, this.submittedCount = 0, this.inProgressCount = 0}): _individualScores = individualScores,_leaderboard = leaderboard,_groupRankings = groupRankings,_eventStats = eventStats,_holePars = holePars;
  factory _ProcessedEventData.fromJson(Map<String, dynamic> json) => _$ProcessedEventDataFromJson(json);

@override final  String eventId;
 final  List<ProcessedPlayerScore> _individualScores;
@override List<ProcessedPlayerScore> get individualScores {
  if (_individualScores is EqualUnmodifiableListView) return _individualScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_individualScores);
}

 final  List<ProcessedLeaderboardEntry> _leaderboard;
@override List<ProcessedLeaderboardEntry> get leaderboard {
  if (_leaderboard is EqualUnmodifiableListView) return _leaderboard;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_leaderboard);
}

 final  List<ProcessedGroupResult> _groupRankings;
@override List<ProcessedGroupResult> get groupRankings {
  if (_groupRankings is EqualUnmodifiableListView) return _groupRankings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groupRankings);
}

 final  Map<String, dynamic> _eventStats;
@override Map<String, dynamic> get eventStats {
  if (_eventStats is EqualUnmodifiableMapView) return _eventStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_eventStats);
}

 final  List<int> _holePars;
@override List<int> get holePars {
  if (_holePars is EqualUnmodifiableListView) return _holePars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holePars);
}

@override@JsonKey() final  int computeVersion;
@override final  DateTime lastComputedAt;
@override@JsonKey() final  int totalParticipants;
@override@JsonKey() final  int submittedCount;
@override@JsonKey() final  int inProgressCount;

/// Create a copy of ProcessedEventData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProcessedEventDataCopyWith<_ProcessedEventData> get copyWith => __$ProcessedEventDataCopyWithImpl<_ProcessedEventData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProcessedEventDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProcessedEventData&&(identical(other.eventId, eventId) || other.eventId == eventId)&&const DeepCollectionEquality().equals(other._individualScores, _individualScores)&&const DeepCollectionEquality().equals(other._leaderboard, _leaderboard)&&const DeepCollectionEquality().equals(other._groupRankings, _groupRankings)&&const DeepCollectionEquality().equals(other._eventStats, _eventStats)&&const DeepCollectionEquality().equals(other._holePars, _holePars)&&(identical(other.computeVersion, computeVersion) || other.computeVersion == computeVersion)&&(identical(other.lastComputedAt, lastComputedAt) || other.lastComputedAt == lastComputedAt)&&(identical(other.totalParticipants, totalParticipants) || other.totalParticipants == totalParticipants)&&(identical(other.submittedCount, submittedCount) || other.submittedCount == submittedCount)&&(identical(other.inProgressCount, inProgressCount) || other.inProgressCount == inProgressCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,const DeepCollectionEquality().hash(_individualScores),const DeepCollectionEquality().hash(_leaderboard),const DeepCollectionEquality().hash(_groupRankings),const DeepCollectionEquality().hash(_eventStats),const DeepCollectionEquality().hash(_holePars),computeVersion,lastComputedAt,totalParticipants,submittedCount,inProgressCount);

@override
String toString() {
  return 'ProcessedEventData(eventId: $eventId, individualScores: $individualScores, leaderboard: $leaderboard, groupRankings: $groupRankings, eventStats: $eventStats, holePars: $holePars, computeVersion: $computeVersion, lastComputedAt: $lastComputedAt, totalParticipants: $totalParticipants, submittedCount: $submittedCount, inProgressCount: $inProgressCount)';
}


}

/// @nodoc
abstract mixin class _$ProcessedEventDataCopyWith<$Res> implements $ProcessedEventDataCopyWith<$Res> {
  factory _$ProcessedEventDataCopyWith(_ProcessedEventData value, $Res Function(_ProcessedEventData) _then) = __$ProcessedEventDataCopyWithImpl;
@override @useResult
$Res call({
 String eventId, List<ProcessedPlayerScore> individualScores, List<ProcessedLeaderboardEntry> leaderboard, List<ProcessedGroupResult> groupRankings, Map<String, dynamic> eventStats, List<int> holePars, int computeVersion, DateTime lastComputedAt, int totalParticipants, int submittedCount, int inProgressCount
});




}
/// @nodoc
class __$ProcessedEventDataCopyWithImpl<$Res>
    implements _$ProcessedEventDataCopyWith<$Res> {
  __$ProcessedEventDataCopyWithImpl(this._self, this._then);

  final _ProcessedEventData _self;
  final $Res Function(_ProcessedEventData) _then;

/// Create a copy of ProcessedEventData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? individualScores = null,Object? leaderboard = null,Object? groupRankings = null,Object? eventStats = null,Object? holePars = null,Object? computeVersion = null,Object? lastComputedAt = null,Object? totalParticipants = null,Object? submittedCount = null,Object? inProgressCount = null,}) {
  return _then(_ProcessedEventData(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,individualScores: null == individualScores ? _self._individualScores : individualScores // ignore: cast_nullable_to_non_nullable
as List<ProcessedPlayerScore>,leaderboard: null == leaderboard ? _self._leaderboard : leaderboard // ignore: cast_nullable_to_non_nullable
as List<ProcessedLeaderboardEntry>,groupRankings: null == groupRankings ? _self._groupRankings : groupRankings // ignore: cast_nullable_to_non_nullable
as List<ProcessedGroupResult>,eventStats: null == eventStats ? _self._eventStats : eventStats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,holePars: null == holePars ? _self._holePars : holePars // ignore: cast_nullable_to_non_nullable
as List<int>,computeVersion: null == computeVersion ? _self.computeVersion : computeVersion // ignore: cast_nullable_to_non_nullable
as int,lastComputedAt: null == lastComputedAt ? _self.lastComputedAt : lastComputedAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalParticipants: null == totalParticipants ? _self.totalParticipants : totalParticipants // ignore: cast_nullable_to_non_nullable
as int,submittedCount: null == submittedCount ? _self.submittedCount : submittedCount // ignore: cast_nullable_to_non_nullable
as int,inProgressCount: null == inProgressCount ? _self.inProgressCount : inProgressCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
