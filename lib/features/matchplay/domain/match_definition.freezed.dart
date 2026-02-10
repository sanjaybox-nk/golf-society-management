// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_definition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchDefinition {

 String get id; MatchType get type; List<String> get team1Ids;// Player IDs for Side A
 List<String> get team2Ids;// Player IDs for Side B
 Map<String, int> get strokesReceived;// Map<PlayerID, Strokes> relative to scratch/lowest
 String? get groupId;// Optional link to TeeGroup
// Bracket / Season Data
 MatchRoundType get round; String? get bracketId;// ID of the tournament/bracket
 String? get nextMatchId;// ID of the match winner advances to
 int? get bracketOrder;// Visual ordering index
// Override Labels (optional)
 String? get team1Name;// e.g., "Team Europe" or "Names calculated"
 String? get team2Name;
/// Create a copy of MatchDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchDefinitionCopyWith<MatchDefinition> get copyWith => _$MatchDefinitionCopyWithImpl<MatchDefinition>(this as MatchDefinition, _$identity);

  /// Serializes this MatchDefinition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchDefinition&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.team1Ids, team1Ids)&&const DeepCollectionEquality().equals(other.team2Ids, team2Ids)&&const DeepCollectionEquality().equals(other.strokesReceived, strokesReceived)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.round, round) || other.round == round)&&(identical(other.bracketId, bracketId) || other.bracketId == bracketId)&&(identical(other.nextMatchId, nextMatchId) || other.nextMatchId == nextMatchId)&&(identical(other.bracketOrder, bracketOrder) || other.bracketOrder == bracketOrder)&&(identical(other.team1Name, team1Name) || other.team1Name == team1Name)&&(identical(other.team2Name, team2Name) || other.team2Name == team2Name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,const DeepCollectionEquality().hash(team1Ids),const DeepCollectionEquality().hash(team2Ids),const DeepCollectionEquality().hash(strokesReceived),groupId,round,bracketId,nextMatchId,bracketOrder,team1Name,team2Name);

@override
String toString() {
  return 'MatchDefinition(id: $id, type: $type, team1Ids: $team1Ids, team2Ids: $team2Ids, strokesReceived: $strokesReceived, groupId: $groupId, round: $round, bracketId: $bracketId, nextMatchId: $nextMatchId, bracketOrder: $bracketOrder, team1Name: $team1Name, team2Name: $team2Name)';
}


}

/// @nodoc
abstract mixin class $MatchDefinitionCopyWith<$Res>  {
  factory $MatchDefinitionCopyWith(MatchDefinition value, $Res Function(MatchDefinition) _then) = _$MatchDefinitionCopyWithImpl;
@useResult
$Res call({
 String id, MatchType type, List<String> team1Ids, List<String> team2Ids, Map<String, int> strokesReceived, String? groupId, MatchRoundType round, String? bracketId, String? nextMatchId, int? bracketOrder, String? team1Name, String? team2Name
});




}
/// @nodoc
class _$MatchDefinitionCopyWithImpl<$Res>
    implements $MatchDefinitionCopyWith<$Res> {
  _$MatchDefinitionCopyWithImpl(this._self, this._then);

  final MatchDefinition _self;
  final $Res Function(MatchDefinition) _then;

/// Create a copy of MatchDefinition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? team1Ids = null,Object? team2Ids = null,Object? strokesReceived = null,Object? groupId = freezed,Object? round = null,Object? bracketId = freezed,Object? nextMatchId = freezed,Object? bracketOrder = freezed,Object? team1Name = freezed,Object? team2Name = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MatchType,team1Ids: null == team1Ids ? _self.team1Ids : team1Ids // ignore: cast_nullable_to_non_nullable
as List<String>,team2Ids: null == team2Ids ? _self.team2Ids : team2Ids // ignore: cast_nullable_to_non_nullable
as List<String>,strokesReceived: null == strokesReceived ? _self.strokesReceived : strokesReceived // ignore: cast_nullable_to_non_nullable
as Map<String, int>,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as MatchRoundType,bracketId: freezed == bracketId ? _self.bracketId : bracketId // ignore: cast_nullable_to_non_nullable
as String?,nextMatchId: freezed == nextMatchId ? _self.nextMatchId : nextMatchId // ignore: cast_nullable_to_non_nullable
as String?,bracketOrder: freezed == bracketOrder ? _self.bracketOrder : bracketOrder // ignore: cast_nullable_to_non_nullable
as int?,team1Name: freezed == team1Name ? _self.team1Name : team1Name // ignore: cast_nullable_to_non_nullable
as String?,team2Name: freezed == team2Name ? _self.team2Name : team2Name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchDefinition].
extension MatchDefinitionPatterns on MatchDefinition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchDefinition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchDefinition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchDefinition value)  $default,){
final _that = this;
switch (_that) {
case _MatchDefinition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchDefinition value)?  $default,){
final _that = this;
switch (_that) {
case _MatchDefinition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MatchType type,  List<String> team1Ids,  List<String> team2Ids,  Map<String, int> strokesReceived,  String? groupId,  MatchRoundType round,  String? bracketId,  String? nextMatchId,  int? bracketOrder,  String? team1Name,  String? team2Name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchDefinition() when $default != null:
return $default(_that.id,_that.type,_that.team1Ids,_that.team2Ids,_that.strokesReceived,_that.groupId,_that.round,_that.bracketId,_that.nextMatchId,_that.bracketOrder,_that.team1Name,_that.team2Name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MatchType type,  List<String> team1Ids,  List<String> team2Ids,  Map<String, int> strokesReceived,  String? groupId,  MatchRoundType round,  String? bracketId,  String? nextMatchId,  int? bracketOrder,  String? team1Name,  String? team2Name)  $default,) {final _that = this;
switch (_that) {
case _MatchDefinition():
return $default(_that.id,_that.type,_that.team1Ids,_that.team2Ids,_that.strokesReceived,_that.groupId,_that.round,_that.bracketId,_that.nextMatchId,_that.bracketOrder,_that.team1Name,_that.team2Name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MatchType type,  List<String> team1Ids,  List<String> team2Ids,  Map<String, int> strokesReceived,  String? groupId,  MatchRoundType round,  String? bracketId,  String? nextMatchId,  int? bracketOrder,  String? team1Name,  String? team2Name)?  $default,) {final _that = this;
switch (_that) {
case _MatchDefinition() when $default != null:
return $default(_that.id,_that.type,_that.team1Ids,_that.team2Ids,_that.strokesReceived,_that.groupId,_that.round,_that.bracketId,_that.nextMatchId,_that.bracketOrder,_that.team1Name,_that.team2Name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchDefinition implements MatchDefinition {
  const _MatchDefinition({required this.id, required this.type, required final  List<String> team1Ids, required final  List<String> team2Ids, final  Map<String, int> strokesReceived = const {}, this.groupId, this.round = MatchRoundType.group, this.bracketId, this.nextMatchId, this.bracketOrder, this.team1Name, this.team2Name}): _team1Ids = team1Ids,_team2Ids = team2Ids,_strokesReceived = strokesReceived;
  factory _MatchDefinition.fromJson(Map<String, dynamic> json) => _$MatchDefinitionFromJson(json);

@override final  String id;
@override final  MatchType type;
 final  List<String> _team1Ids;
@override List<String> get team1Ids {
  if (_team1Ids is EqualUnmodifiableListView) return _team1Ids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_team1Ids);
}

// Player IDs for Side A
 final  List<String> _team2Ids;
// Player IDs for Side A
@override List<String> get team2Ids {
  if (_team2Ids is EqualUnmodifiableListView) return _team2Ids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_team2Ids);
}

// Player IDs for Side B
 final  Map<String, int> _strokesReceived;
// Player IDs for Side B
@override@JsonKey() Map<String, int> get strokesReceived {
  if (_strokesReceived is EqualUnmodifiableMapView) return _strokesReceived;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_strokesReceived);
}

// Map<PlayerID, Strokes> relative to scratch/lowest
@override final  String? groupId;
// Optional link to TeeGroup
// Bracket / Season Data
@override@JsonKey() final  MatchRoundType round;
@override final  String? bracketId;
// ID of the tournament/bracket
@override final  String? nextMatchId;
// ID of the match winner advances to
@override final  int? bracketOrder;
// Visual ordering index
// Override Labels (optional)
@override final  String? team1Name;
// e.g., "Team Europe" or "Names calculated"
@override final  String? team2Name;

/// Create a copy of MatchDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchDefinitionCopyWith<_MatchDefinition> get copyWith => __$MatchDefinitionCopyWithImpl<_MatchDefinition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchDefinitionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchDefinition&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._team1Ids, _team1Ids)&&const DeepCollectionEquality().equals(other._team2Ids, _team2Ids)&&const DeepCollectionEquality().equals(other._strokesReceived, _strokesReceived)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.round, round) || other.round == round)&&(identical(other.bracketId, bracketId) || other.bracketId == bracketId)&&(identical(other.nextMatchId, nextMatchId) || other.nextMatchId == nextMatchId)&&(identical(other.bracketOrder, bracketOrder) || other.bracketOrder == bracketOrder)&&(identical(other.team1Name, team1Name) || other.team1Name == team1Name)&&(identical(other.team2Name, team2Name) || other.team2Name == team2Name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,const DeepCollectionEquality().hash(_team1Ids),const DeepCollectionEquality().hash(_team2Ids),const DeepCollectionEquality().hash(_strokesReceived),groupId,round,bracketId,nextMatchId,bracketOrder,team1Name,team2Name);

@override
String toString() {
  return 'MatchDefinition(id: $id, type: $type, team1Ids: $team1Ids, team2Ids: $team2Ids, strokesReceived: $strokesReceived, groupId: $groupId, round: $round, bracketId: $bracketId, nextMatchId: $nextMatchId, bracketOrder: $bracketOrder, team1Name: $team1Name, team2Name: $team2Name)';
}


}

/// @nodoc
abstract mixin class _$MatchDefinitionCopyWith<$Res> implements $MatchDefinitionCopyWith<$Res> {
  factory _$MatchDefinitionCopyWith(_MatchDefinition value, $Res Function(_MatchDefinition) _then) = __$MatchDefinitionCopyWithImpl;
@override @useResult
$Res call({
 String id, MatchType type, List<String> team1Ids, List<String> team2Ids, Map<String, int> strokesReceived, String? groupId, MatchRoundType round, String? bracketId, String? nextMatchId, int? bracketOrder, String? team1Name, String? team2Name
});




}
/// @nodoc
class __$MatchDefinitionCopyWithImpl<$Res>
    implements _$MatchDefinitionCopyWith<$Res> {
  __$MatchDefinitionCopyWithImpl(this._self, this._then);

  final _MatchDefinition _self;
  final $Res Function(_MatchDefinition) _then;

/// Create a copy of MatchDefinition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? team1Ids = null,Object? team2Ids = null,Object? strokesReceived = null,Object? groupId = freezed,Object? round = null,Object? bracketId = freezed,Object? nextMatchId = freezed,Object? bracketOrder = freezed,Object? team1Name = freezed,Object? team2Name = freezed,}) {
  return _then(_MatchDefinition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MatchType,team1Ids: null == team1Ids ? _self._team1Ids : team1Ids // ignore: cast_nullable_to_non_nullable
as List<String>,team2Ids: null == team2Ids ? _self._team2Ids : team2Ids // ignore: cast_nullable_to_non_nullable
as List<String>,strokesReceived: null == strokesReceived ? _self._strokesReceived : strokesReceived // ignore: cast_nullable_to_non_nullable
as Map<String, int>,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as MatchRoundType,bracketId: freezed == bracketId ? _self.bracketId : bracketId // ignore: cast_nullable_to_non_nullable
as String?,nextMatchId: freezed == nextMatchId ? _self.nextMatchId : nextMatchId // ignore: cast_nullable_to_non_nullable
as String?,bracketOrder: freezed == bracketOrder ? _self.bracketOrder : bracketOrder // ignore: cast_nullable_to_non_nullable
as int?,team1Name: freezed == team1Name ? _self.team1Name : team1Name // ignore: cast_nullable_to_non_nullable
as String?,team2Name: freezed == team2Name ? _self.team2Name : team2Name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MatchResult {

 String get matchId; int get winningTeamIndex;// 0 = Team 1, 1 = Team 2, -1 = Halve/Draw
 String get status;// Display string: "3&2", "1UP", "A/S"
 int get score;// Positive = Team 1 UP, Negative = Team 2 UP
 List<int> get holeResults;// 1 = T1 Win, -1 = T2 Win, 0 = Halve, null = Not Played
 int get holesPlayed; bool get isFinal;
/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchResultCopyWith<MatchResult> get copyWith => _$MatchResultCopyWithImpl<MatchResult>(this as MatchResult, _$identity);

  /// Serializes this MatchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchResult&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.winningTeamIndex, winningTeamIndex) || other.winningTeamIndex == winningTeamIndex)&&(identical(other.status, status) || other.status == status)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other.holeResults, holeResults)&&(identical(other.holesPlayed, holesPlayed) || other.holesPlayed == holesPlayed)&&(identical(other.isFinal, isFinal) || other.isFinal == isFinal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,matchId,winningTeamIndex,status,score,const DeepCollectionEquality().hash(holeResults),holesPlayed,isFinal);

@override
String toString() {
  return 'MatchResult(matchId: $matchId, winningTeamIndex: $winningTeamIndex, status: $status, score: $score, holeResults: $holeResults, holesPlayed: $holesPlayed, isFinal: $isFinal)';
}


}

/// @nodoc
abstract mixin class $MatchResultCopyWith<$Res>  {
  factory $MatchResultCopyWith(MatchResult value, $Res Function(MatchResult) _then) = _$MatchResultCopyWithImpl;
@useResult
$Res call({
 String matchId, int winningTeamIndex, String status, int score, List<int> holeResults, int holesPlayed, bool isFinal
});




}
/// @nodoc
class _$MatchResultCopyWithImpl<$Res>
    implements $MatchResultCopyWith<$Res> {
  _$MatchResultCopyWithImpl(this._self, this._then);

  final MatchResult _self;
  final $Res Function(MatchResult) _then;

/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? matchId = null,Object? winningTeamIndex = null,Object? status = null,Object? score = null,Object? holeResults = null,Object? holesPlayed = null,Object? isFinal = null,}) {
  return _then(_self.copyWith(
matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,winningTeamIndex: null == winningTeamIndex ? _self.winningTeamIndex : winningTeamIndex // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,holeResults: null == holeResults ? _self.holeResults : holeResults // ignore: cast_nullable_to_non_nullable
as List<int>,holesPlayed: null == holesPlayed ? _self.holesPlayed : holesPlayed // ignore: cast_nullable_to_non_nullable
as int,isFinal: null == isFinal ? _self.isFinal : isFinal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchResult].
extension MatchResultPatterns on MatchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchResult value)  $default,){
final _that = this;
switch (_that) {
case _MatchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchResult value)?  $default,){
final _that = this;
switch (_that) {
case _MatchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String matchId,  int winningTeamIndex,  String status,  int score,  List<int> holeResults,  int holesPlayed,  bool isFinal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchResult() when $default != null:
return $default(_that.matchId,_that.winningTeamIndex,_that.status,_that.score,_that.holeResults,_that.holesPlayed,_that.isFinal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String matchId,  int winningTeamIndex,  String status,  int score,  List<int> holeResults,  int holesPlayed,  bool isFinal)  $default,) {final _that = this;
switch (_that) {
case _MatchResult():
return $default(_that.matchId,_that.winningTeamIndex,_that.status,_that.score,_that.holeResults,_that.holesPlayed,_that.isFinal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String matchId,  int winningTeamIndex,  String status,  int score,  List<int> holeResults,  int holesPlayed,  bool isFinal)?  $default,) {final _that = this;
switch (_that) {
case _MatchResult() when $default != null:
return $default(_that.matchId,_that.winningTeamIndex,_that.status,_that.score,_that.holeResults,_that.holesPlayed,_that.isFinal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchResult implements MatchResult {
  const _MatchResult({required this.matchId, required this.winningTeamIndex, required this.status, required this.score, required final  List<int> holeResults, required this.holesPlayed, this.isFinal = false}): _holeResults = holeResults;
  factory _MatchResult.fromJson(Map<String, dynamic> json) => _$MatchResultFromJson(json);

@override final  String matchId;
@override final  int winningTeamIndex;
// 0 = Team 1, 1 = Team 2, -1 = Halve/Draw
@override final  String status;
// Display string: "3&2", "1UP", "A/S"
@override final  int score;
// Positive = Team 1 UP, Negative = Team 2 UP
 final  List<int> _holeResults;
// Positive = Team 1 UP, Negative = Team 2 UP
@override List<int> get holeResults {
  if (_holeResults is EqualUnmodifiableListView) return _holeResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holeResults);
}

// 1 = T1 Win, -1 = T2 Win, 0 = Halve, null = Not Played
@override final  int holesPlayed;
@override@JsonKey() final  bool isFinal;

/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchResultCopyWith<_MatchResult> get copyWith => __$MatchResultCopyWithImpl<_MatchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchResult&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.winningTeamIndex, winningTeamIndex) || other.winningTeamIndex == winningTeamIndex)&&(identical(other.status, status) || other.status == status)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other._holeResults, _holeResults)&&(identical(other.holesPlayed, holesPlayed) || other.holesPlayed == holesPlayed)&&(identical(other.isFinal, isFinal) || other.isFinal == isFinal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,matchId,winningTeamIndex,status,score,const DeepCollectionEquality().hash(_holeResults),holesPlayed,isFinal);

@override
String toString() {
  return 'MatchResult(matchId: $matchId, winningTeamIndex: $winningTeamIndex, status: $status, score: $score, holeResults: $holeResults, holesPlayed: $holesPlayed, isFinal: $isFinal)';
}


}

/// @nodoc
abstract mixin class _$MatchResultCopyWith<$Res> implements $MatchResultCopyWith<$Res> {
  factory _$MatchResultCopyWith(_MatchResult value, $Res Function(_MatchResult) _then) = __$MatchResultCopyWithImpl;
@override @useResult
$Res call({
 String matchId, int winningTeamIndex, String status, int score, List<int> holeResults, int holesPlayed, bool isFinal
});




}
/// @nodoc
class __$MatchResultCopyWithImpl<$Res>
    implements _$MatchResultCopyWith<$Res> {
  __$MatchResultCopyWithImpl(this._self, this._then);

  final _MatchResult _self;
  final $Res Function(_MatchResult) _then;

/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? matchId = null,Object? winningTeamIndex = null,Object? status = null,Object? score = null,Object? holeResults = null,Object? holesPlayed = null,Object? isFinal = null,}) {
  return _then(_MatchResult(
matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,winningTeamIndex: null == winningTeamIndex ? _self.winningTeamIndex : winningTeamIndex // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,holeResults: null == holeResults ? _self._holeResults : holeResults // ignore: cast_nullable_to_non_nullable
as List<int>,holesPlayed: null == holesPlayed ? _self.holesPlayed : holesPlayed // ignore: cast_nullable_to_non_nullable
as int,isFinal: null == isFinal ? _self.isFinal : isFinal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
