// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scorecard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HoleAuditEntry {

 int get hole; int get playerScore; int get markerScore; int get resolvedTo; String get reason; String get editorId;@TimestampConverter() DateTime get timestamp;
/// Create a copy of HoleAuditEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HoleAuditEntryCopyWith<HoleAuditEntry> get copyWith => _$HoleAuditEntryCopyWithImpl<HoleAuditEntry>(this as HoleAuditEntry, _$identity);

  /// Serializes this HoleAuditEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HoleAuditEntry&&(identical(other.hole, hole) || other.hole == hole)&&(identical(other.playerScore, playerScore) || other.playerScore == playerScore)&&(identical(other.markerScore, markerScore) || other.markerScore == markerScore)&&(identical(other.resolvedTo, resolvedTo) || other.resolvedTo == resolvedTo)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.editorId, editorId) || other.editorId == editorId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hole,playerScore,markerScore,resolvedTo,reason,editorId,timestamp);

@override
String toString() {
  return 'HoleAuditEntry(hole: $hole, playerScore: $playerScore, markerScore: $markerScore, resolvedTo: $resolvedTo, reason: $reason, editorId: $editorId, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $HoleAuditEntryCopyWith<$Res>  {
  factory $HoleAuditEntryCopyWith(HoleAuditEntry value, $Res Function(HoleAuditEntry) _then) = _$HoleAuditEntryCopyWithImpl;
@useResult
$Res call({
 int hole, int playerScore, int markerScore, int resolvedTo, String reason, String editorId,@TimestampConverter() DateTime timestamp
});




}
/// @nodoc
class _$HoleAuditEntryCopyWithImpl<$Res>
    implements $HoleAuditEntryCopyWith<$Res> {
  _$HoleAuditEntryCopyWithImpl(this._self, this._then);

  final HoleAuditEntry _self;
  final $Res Function(HoleAuditEntry) _then;

/// Create a copy of HoleAuditEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hole = null,Object? playerScore = null,Object? markerScore = null,Object? resolvedTo = null,Object? reason = null,Object? editorId = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
hole: null == hole ? _self.hole : hole // ignore: cast_nullable_to_non_nullable
as int,playerScore: null == playerScore ? _self.playerScore : playerScore // ignore: cast_nullable_to_non_nullable
as int,markerScore: null == markerScore ? _self.markerScore : markerScore // ignore: cast_nullable_to_non_nullable
as int,resolvedTo: null == resolvedTo ? _self.resolvedTo : resolvedTo // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,editorId: null == editorId ? _self.editorId : editorId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HoleAuditEntry].
extension HoleAuditEntryPatterns on HoleAuditEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HoleAuditEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HoleAuditEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HoleAuditEntry value)  $default,){
final _that = this;
switch (_that) {
case _HoleAuditEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HoleAuditEntry value)?  $default,){
final _that = this;
switch (_that) {
case _HoleAuditEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int hole,  int playerScore,  int markerScore,  int resolvedTo,  String reason,  String editorId, @TimestampConverter()  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HoleAuditEntry() when $default != null:
return $default(_that.hole,_that.playerScore,_that.markerScore,_that.resolvedTo,_that.reason,_that.editorId,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int hole,  int playerScore,  int markerScore,  int resolvedTo,  String reason,  String editorId, @TimestampConverter()  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _HoleAuditEntry():
return $default(_that.hole,_that.playerScore,_that.markerScore,_that.resolvedTo,_that.reason,_that.editorId,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int hole,  int playerScore,  int markerScore,  int resolvedTo,  String reason,  String editorId, @TimestampConverter()  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _HoleAuditEntry() when $default != null:
return $default(_that.hole,_that.playerScore,_that.markerScore,_that.resolvedTo,_that.reason,_that.editorId,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HoleAuditEntry implements HoleAuditEntry {
  const _HoleAuditEntry({required this.hole, required this.playerScore, required this.markerScore, required this.resolvedTo, required this.reason, required this.editorId, @TimestampConverter() required this.timestamp});
  factory _HoleAuditEntry.fromJson(Map<String, dynamic> json) => _$HoleAuditEntryFromJson(json);

@override final  int hole;
@override final  int playerScore;
@override final  int markerScore;
@override final  int resolvedTo;
@override final  String reason;
@override final  String editorId;
@override@TimestampConverter() final  DateTime timestamp;

/// Create a copy of HoleAuditEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HoleAuditEntryCopyWith<_HoleAuditEntry> get copyWith => __$HoleAuditEntryCopyWithImpl<_HoleAuditEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HoleAuditEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HoleAuditEntry&&(identical(other.hole, hole) || other.hole == hole)&&(identical(other.playerScore, playerScore) || other.playerScore == playerScore)&&(identical(other.markerScore, markerScore) || other.markerScore == markerScore)&&(identical(other.resolvedTo, resolvedTo) || other.resolvedTo == resolvedTo)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.editorId, editorId) || other.editorId == editorId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hole,playerScore,markerScore,resolvedTo,reason,editorId,timestamp);

@override
String toString() {
  return 'HoleAuditEntry(hole: $hole, playerScore: $playerScore, markerScore: $markerScore, resolvedTo: $resolvedTo, reason: $reason, editorId: $editorId, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$HoleAuditEntryCopyWith<$Res> implements $HoleAuditEntryCopyWith<$Res> {
  factory _$HoleAuditEntryCopyWith(_HoleAuditEntry value, $Res Function(_HoleAuditEntry) _then) = __$HoleAuditEntryCopyWithImpl;
@override @useResult
$Res call({
 int hole, int playerScore, int markerScore, int resolvedTo, String reason, String editorId,@TimestampConverter() DateTime timestamp
});




}
/// @nodoc
class __$HoleAuditEntryCopyWithImpl<$Res>
    implements _$HoleAuditEntryCopyWith<$Res> {
  __$HoleAuditEntryCopyWithImpl(this._self, this._then);

  final _HoleAuditEntry _self;
  final $Res Function(_HoleAuditEntry) _then;

/// Create a copy of HoleAuditEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hole = null,Object? playerScore = null,Object? markerScore = null,Object? resolvedTo = null,Object? reason = null,Object? editorId = null,Object? timestamp = null,}) {
  return _then(_HoleAuditEntry(
hole: null == hole ? _self.hole : hole // ignore: cast_nullable_to_non_nullable
as int,playerScore: null == playerScore ? _self.playerScore : playerScore // ignore: cast_nullable_to_non_nullable
as int,markerScore: null == markerScore ? _self.markerScore : markerScore // ignore: cast_nullable_to_non_nullable
as int,resolvedTo: null == resolvedTo ? _self.resolvedTo : resolvedTo // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,editorId: null == editorId ? _self.editorId : editorId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Scorecard {

 String get id; String get competitionId; String get roundId; String get entryId; String get submittedByUserId; ScorecardStatus get status; ScoringStatus get scoringStatus; List<int?> get holeScores; List<int?> get playerVerifierScores; String? get markerId; String? get guestInputAssigneeId; Map<int, String?> get shotAttributions; int? get grossTotal; int? get netTotal; int? get points; double? get handicapIndex; int? get playingHandicap; String? get assignedTeeName; List<HoleAuditEntry> get holeAuditLog; String? get approvedBy;@OptionalTimestampConverter() DateTime? get approvedAt; bool get adminOverridePublish; bool get verifiedByPlayer; bool get verifiedByMarker; bool get markerReassignmentOpen;@OptionalTimestampConverter() DateTime? get playerVerifiedAt;@OptionalTimestampConverter() DateTime? get markerVerifiedAt; Map<int, List<String>> get holeTags; List<int> get conflictedHoles; int get committeeAdjustment; String? get committeeNote;@TimestampConverter() DateTime? get submittedAt;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of Scorecard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScorecardCopyWith<Scorecard> get copyWith => _$ScorecardCopyWithImpl<Scorecard>(this as Scorecard, _$identity);

  /// Serializes this Scorecard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scorecard&&(identical(other.id, id) || other.id == id)&&(identical(other.competitionId, competitionId) || other.competitionId == competitionId)&&(identical(other.roundId, roundId) || other.roundId == roundId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.submittedByUserId, submittedByUserId) || other.submittedByUserId == submittedByUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.scoringStatus, scoringStatus) || other.scoringStatus == scoringStatus)&&const DeepCollectionEquality().equals(other.holeScores, holeScores)&&const DeepCollectionEquality().equals(other.playerVerifierScores, playerVerifierScores)&&(identical(other.markerId, markerId) || other.markerId == markerId)&&(identical(other.guestInputAssigneeId, guestInputAssigneeId) || other.guestInputAssigneeId == guestInputAssigneeId)&&const DeepCollectionEquality().equals(other.shotAttributions, shotAttributions)&&(identical(other.grossTotal, grossTotal) || other.grossTotal == grossTotal)&&(identical(other.netTotal, netTotal) || other.netTotal == netTotal)&&(identical(other.points, points) || other.points == points)&&(identical(other.handicapIndex, handicapIndex) || other.handicapIndex == handicapIndex)&&(identical(other.playingHandicap, playingHandicap) || other.playingHandicap == playingHandicap)&&(identical(other.assignedTeeName, assignedTeeName) || other.assignedTeeName == assignedTeeName)&&const DeepCollectionEquality().equals(other.holeAuditLog, holeAuditLog)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.adminOverridePublish, adminOverridePublish) || other.adminOverridePublish == adminOverridePublish)&&(identical(other.verifiedByPlayer, verifiedByPlayer) || other.verifiedByPlayer == verifiedByPlayer)&&(identical(other.verifiedByMarker, verifiedByMarker) || other.verifiedByMarker == verifiedByMarker)&&(identical(other.markerReassignmentOpen, markerReassignmentOpen) || other.markerReassignmentOpen == markerReassignmentOpen)&&(identical(other.playerVerifiedAt, playerVerifiedAt) || other.playerVerifiedAt == playerVerifiedAt)&&(identical(other.markerVerifiedAt, markerVerifiedAt) || other.markerVerifiedAt == markerVerifiedAt)&&const DeepCollectionEquality().equals(other.holeTags, holeTags)&&const DeepCollectionEquality().equals(other.conflictedHoles, conflictedHoles)&&(identical(other.committeeAdjustment, committeeAdjustment) || other.committeeAdjustment == committeeAdjustment)&&(identical(other.committeeNote, committeeNote) || other.committeeNote == committeeNote)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,competitionId,roundId,entryId,submittedByUserId,status,scoringStatus,const DeepCollectionEquality().hash(holeScores),const DeepCollectionEquality().hash(playerVerifierScores),markerId,guestInputAssigneeId,const DeepCollectionEquality().hash(shotAttributions),grossTotal,netTotal,points,handicapIndex,playingHandicap,assignedTeeName,const DeepCollectionEquality().hash(holeAuditLog),approvedBy,approvedAt,adminOverridePublish,verifiedByPlayer,verifiedByMarker,markerReassignmentOpen,playerVerifiedAt,markerVerifiedAt,const DeepCollectionEquality().hash(holeTags),const DeepCollectionEquality().hash(conflictedHoles),committeeAdjustment,committeeNote,submittedAt,createdAt,updatedAt]);

@override
String toString() {
  return 'Scorecard(id: $id, competitionId: $competitionId, roundId: $roundId, entryId: $entryId, submittedByUserId: $submittedByUserId, status: $status, scoringStatus: $scoringStatus, holeScores: $holeScores, playerVerifierScores: $playerVerifierScores, markerId: $markerId, guestInputAssigneeId: $guestInputAssigneeId, shotAttributions: $shotAttributions, grossTotal: $grossTotal, netTotal: $netTotal, points: $points, handicapIndex: $handicapIndex, playingHandicap: $playingHandicap, assignedTeeName: $assignedTeeName, holeAuditLog: $holeAuditLog, approvedBy: $approvedBy, approvedAt: $approvedAt, adminOverridePublish: $adminOverridePublish, verifiedByPlayer: $verifiedByPlayer, verifiedByMarker: $verifiedByMarker, markerReassignmentOpen: $markerReassignmentOpen, playerVerifiedAt: $playerVerifiedAt, markerVerifiedAt: $markerVerifiedAt, holeTags: $holeTags, conflictedHoles: $conflictedHoles, committeeAdjustment: $committeeAdjustment, committeeNote: $committeeNote, submittedAt: $submittedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ScorecardCopyWith<$Res>  {
  factory $ScorecardCopyWith(Scorecard value, $Res Function(Scorecard) _then) = _$ScorecardCopyWithImpl;
@useResult
$Res call({
 String id, String competitionId, String roundId, String entryId, String submittedByUserId, ScorecardStatus status, ScoringStatus scoringStatus, List<int?> holeScores, List<int?> playerVerifierScores, String? markerId, String? guestInputAssigneeId, Map<int, String?> shotAttributions, int? grossTotal, int? netTotal, int? points, double? handicapIndex, int? playingHandicap, String? assignedTeeName, List<HoleAuditEntry> holeAuditLog, String? approvedBy,@OptionalTimestampConverter() DateTime? approvedAt, bool adminOverridePublish, bool verifiedByPlayer, bool verifiedByMarker, bool markerReassignmentOpen,@OptionalTimestampConverter() DateTime? playerVerifiedAt,@OptionalTimestampConverter() DateTime? markerVerifiedAt, Map<int, List<String>> holeTags, List<int> conflictedHoles, int committeeAdjustment, String? committeeNote,@TimestampConverter() DateTime? submittedAt,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$ScorecardCopyWithImpl<$Res>
    implements $ScorecardCopyWith<$Res> {
  _$ScorecardCopyWithImpl(this._self, this._then);

  final Scorecard _self;
  final $Res Function(Scorecard) _then;

/// Create a copy of Scorecard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? competitionId = null,Object? roundId = null,Object? entryId = null,Object? submittedByUserId = null,Object? status = null,Object? scoringStatus = null,Object? holeScores = null,Object? playerVerifierScores = null,Object? markerId = freezed,Object? guestInputAssigneeId = freezed,Object? shotAttributions = null,Object? grossTotal = freezed,Object? netTotal = freezed,Object? points = freezed,Object? handicapIndex = freezed,Object? playingHandicap = freezed,Object? assignedTeeName = freezed,Object? holeAuditLog = null,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? adminOverridePublish = null,Object? verifiedByPlayer = null,Object? verifiedByMarker = null,Object? markerReassignmentOpen = null,Object? playerVerifiedAt = freezed,Object? markerVerifiedAt = freezed,Object? holeTags = null,Object? conflictedHoles = null,Object? committeeAdjustment = null,Object? committeeNote = freezed,Object? submittedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,competitionId: null == competitionId ? _self.competitionId : competitionId // ignore: cast_nullable_to_non_nullable
as String,roundId: null == roundId ? _self.roundId : roundId // ignore: cast_nullable_to_non_nullable
as String,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String,submittedByUserId: null == submittedByUserId ? _self.submittedByUserId : submittedByUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScorecardStatus,scoringStatus: null == scoringStatus ? _self.scoringStatus : scoringStatus // ignore: cast_nullable_to_non_nullable
as ScoringStatus,holeScores: null == holeScores ? _self.holeScores : holeScores // ignore: cast_nullable_to_non_nullable
as List<int?>,playerVerifierScores: null == playerVerifierScores ? _self.playerVerifierScores : playerVerifierScores // ignore: cast_nullable_to_non_nullable
as List<int?>,markerId: freezed == markerId ? _self.markerId : markerId // ignore: cast_nullable_to_non_nullable
as String?,guestInputAssigneeId: freezed == guestInputAssigneeId ? _self.guestInputAssigneeId : guestInputAssigneeId // ignore: cast_nullable_to_non_nullable
as String?,shotAttributions: null == shotAttributions ? _self.shotAttributions : shotAttributions // ignore: cast_nullable_to_non_nullable
as Map<int, String?>,grossTotal: freezed == grossTotal ? _self.grossTotal : grossTotal // ignore: cast_nullable_to_non_nullable
as int?,netTotal: freezed == netTotal ? _self.netTotal : netTotal // ignore: cast_nullable_to_non_nullable
as int?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int?,handicapIndex: freezed == handicapIndex ? _self.handicapIndex : handicapIndex // ignore: cast_nullable_to_non_nullable
as double?,playingHandicap: freezed == playingHandicap ? _self.playingHandicap : playingHandicap // ignore: cast_nullable_to_non_nullable
as int?,assignedTeeName: freezed == assignedTeeName ? _self.assignedTeeName : assignedTeeName // ignore: cast_nullable_to_non_nullable
as String?,holeAuditLog: null == holeAuditLog ? _self.holeAuditLog : holeAuditLog // ignore: cast_nullable_to_non_nullable
as List<HoleAuditEntry>,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,adminOverridePublish: null == adminOverridePublish ? _self.adminOverridePublish : adminOverridePublish // ignore: cast_nullable_to_non_nullable
as bool,verifiedByPlayer: null == verifiedByPlayer ? _self.verifiedByPlayer : verifiedByPlayer // ignore: cast_nullable_to_non_nullable
as bool,verifiedByMarker: null == verifiedByMarker ? _self.verifiedByMarker : verifiedByMarker // ignore: cast_nullable_to_non_nullable
as bool,markerReassignmentOpen: null == markerReassignmentOpen ? _self.markerReassignmentOpen : markerReassignmentOpen // ignore: cast_nullable_to_non_nullable
as bool,playerVerifiedAt: freezed == playerVerifiedAt ? _self.playerVerifiedAt : playerVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,markerVerifiedAt: freezed == markerVerifiedAt ? _self.markerVerifiedAt : markerVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,holeTags: null == holeTags ? _self.holeTags : holeTags // ignore: cast_nullable_to_non_nullable
as Map<int, List<String>>,conflictedHoles: null == conflictedHoles ? _self.conflictedHoles : conflictedHoles // ignore: cast_nullable_to_non_nullable
as List<int>,committeeAdjustment: null == committeeAdjustment ? _self.committeeAdjustment : committeeAdjustment // ignore: cast_nullable_to_non_nullable
as int,committeeNote: freezed == committeeNote ? _self.committeeNote : committeeNote // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Scorecard].
extension ScorecardPatterns on Scorecard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Scorecard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Scorecard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Scorecard value)  $default,){
final _that = this;
switch (_that) {
case _Scorecard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Scorecard value)?  $default,){
final _that = this;
switch (_that) {
case _Scorecard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String competitionId,  String roundId,  String entryId,  String submittedByUserId,  ScorecardStatus status,  ScoringStatus scoringStatus,  List<int?> holeScores,  List<int?> playerVerifierScores,  String? markerId,  String? guestInputAssigneeId,  Map<int, String?> shotAttributions,  int? grossTotal,  int? netTotal,  int? points,  double? handicapIndex,  int? playingHandicap,  String? assignedTeeName,  List<HoleAuditEntry> holeAuditLog,  String? approvedBy, @OptionalTimestampConverter()  DateTime? approvedAt,  bool adminOverridePublish,  bool verifiedByPlayer,  bool verifiedByMarker,  bool markerReassignmentOpen, @OptionalTimestampConverter()  DateTime? playerVerifiedAt, @OptionalTimestampConverter()  DateTime? markerVerifiedAt,  Map<int, List<String>> holeTags,  List<int> conflictedHoles,  int committeeAdjustment,  String? committeeNote, @TimestampConverter()  DateTime? submittedAt, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scorecard() when $default != null:
return $default(_that.id,_that.competitionId,_that.roundId,_that.entryId,_that.submittedByUserId,_that.status,_that.scoringStatus,_that.holeScores,_that.playerVerifierScores,_that.markerId,_that.guestInputAssigneeId,_that.shotAttributions,_that.grossTotal,_that.netTotal,_that.points,_that.handicapIndex,_that.playingHandicap,_that.assignedTeeName,_that.holeAuditLog,_that.approvedBy,_that.approvedAt,_that.adminOverridePublish,_that.verifiedByPlayer,_that.verifiedByMarker,_that.markerReassignmentOpen,_that.playerVerifiedAt,_that.markerVerifiedAt,_that.holeTags,_that.conflictedHoles,_that.committeeAdjustment,_that.committeeNote,_that.submittedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String competitionId,  String roundId,  String entryId,  String submittedByUserId,  ScorecardStatus status,  ScoringStatus scoringStatus,  List<int?> holeScores,  List<int?> playerVerifierScores,  String? markerId,  String? guestInputAssigneeId,  Map<int, String?> shotAttributions,  int? grossTotal,  int? netTotal,  int? points,  double? handicapIndex,  int? playingHandicap,  String? assignedTeeName,  List<HoleAuditEntry> holeAuditLog,  String? approvedBy, @OptionalTimestampConverter()  DateTime? approvedAt,  bool adminOverridePublish,  bool verifiedByPlayer,  bool verifiedByMarker,  bool markerReassignmentOpen, @OptionalTimestampConverter()  DateTime? playerVerifiedAt, @OptionalTimestampConverter()  DateTime? markerVerifiedAt,  Map<int, List<String>> holeTags,  List<int> conflictedHoles,  int committeeAdjustment,  String? committeeNote, @TimestampConverter()  DateTime? submittedAt, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Scorecard():
return $default(_that.id,_that.competitionId,_that.roundId,_that.entryId,_that.submittedByUserId,_that.status,_that.scoringStatus,_that.holeScores,_that.playerVerifierScores,_that.markerId,_that.guestInputAssigneeId,_that.shotAttributions,_that.grossTotal,_that.netTotal,_that.points,_that.handicapIndex,_that.playingHandicap,_that.assignedTeeName,_that.holeAuditLog,_that.approvedBy,_that.approvedAt,_that.adminOverridePublish,_that.verifiedByPlayer,_that.verifiedByMarker,_that.markerReassignmentOpen,_that.playerVerifiedAt,_that.markerVerifiedAt,_that.holeTags,_that.conflictedHoles,_that.committeeAdjustment,_that.committeeNote,_that.submittedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String competitionId,  String roundId,  String entryId,  String submittedByUserId,  ScorecardStatus status,  ScoringStatus scoringStatus,  List<int?> holeScores,  List<int?> playerVerifierScores,  String? markerId,  String? guestInputAssigneeId,  Map<int, String?> shotAttributions,  int? grossTotal,  int? netTotal,  int? points,  double? handicapIndex,  int? playingHandicap,  String? assignedTeeName,  List<HoleAuditEntry> holeAuditLog,  String? approvedBy, @OptionalTimestampConverter()  DateTime? approvedAt,  bool adminOverridePublish,  bool verifiedByPlayer,  bool verifiedByMarker,  bool markerReassignmentOpen, @OptionalTimestampConverter()  DateTime? playerVerifiedAt, @OptionalTimestampConverter()  DateTime? markerVerifiedAt,  Map<int, List<String>> holeTags,  List<int> conflictedHoles,  int committeeAdjustment,  String? committeeNote, @TimestampConverter()  DateTime? submittedAt, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Scorecard() when $default != null:
return $default(_that.id,_that.competitionId,_that.roundId,_that.entryId,_that.submittedByUserId,_that.status,_that.scoringStatus,_that.holeScores,_that.playerVerifierScores,_that.markerId,_that.guestInputAssigneeId,_that.shotAttributions,_that.grossTotal,_that.netTotal,_that.points,_that.handicapIndex,_that.playingHandicap,_that.assignedTeeName,_that.holeAuditLog,_that.approvedBy,_that.approvedAt,_that.adminOverridePublish,_that.verifiedByPlayer,_that.verifiedByMarker,_that.markerReassignmentOpen,_that.playerVerifiedAt,_that.markerVerifiedAt,_that.holeTags,_that.conflictedHoles,_that.committeeAdjustment,_that.committeeNote,_that.submittedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Scorecard extends Scorecard {
  const _Scorecard({required this.id, required this.competitionId, required this.roundId, required this.entryId, required this.submittedByUserId, this.status = ScorecardStatus.draft, this.scoringStatus = ScoringStatus.ok, final  List<int?> holeScores = const [], final  List<int?> playerVerifierScores = const [], this.markerId, this.guestInputAssigneeId, final  Map<int, String?> shotAttributions = const {}, this.grossTotal, this.netTotal, this.points, this.handicapIndex, this.playingHandicap, this.assignedTeeName, final  List<HoleAuditEntry> holeAuditLog = const [], this.approvedBy, @OptionalTimestampConverter() this.approvedAt, this.adminOverridePublish = false, this.verifiedByPlayer = false, this.verifiedByMarker = false, this.markerReassignmentOpen = false, @OptionalTimestampConverter() this.playerVerifiedAt, @OptionalTimestampConverter() this.markerVerifiedAt, final  Map<int, List<String>> holeTags = const {}, final  List<int> conflictedHoles = const [], this.committeeAdjustment = 0, this.committeeNote, @TimestampConverter() this.submittedAt, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt}): _holeScores = holeScores,_playerVerifierScores = playerVerifierScores,_shotAttributions = shotAttributions,_holeAuditLog = holeAuditLog,_holeTags = holeTags,_conflictedHoles = conflictedHoles,super._();
  factory _Scorecard.fromJson(Map<String, dynamic> json) => _$ScorecardFromJson(json);

@override final  String id;
@override final  String competitionId;
@override final  String roundId;
@override final  String entryId;
@override final  String submittedByUserId;
@override@JsonKey() final  ScorecardStatus status;
@override@JsonKey() final  ScoringStatus scoringStatus;
 final  List<int?> _holeScores;
@override@JsonKey() List<int?> get holeScores {
  if (_holeScores is EqualUnmodifiableListView) return _holeScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holeScores);
}

 final  List<int?> _playerVerifierScores;
@override@JsonKey() List<int?> get playerVerifierScores {
  if (_playerVerifierScores is EqualUnmodifiableListView) return _playerVerifierScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playerVerifierScores);
}

@override final  String? markerId;
@override final  String? guestInputAssigneeId;
 final  Map<int, String?> _shotAttributions;
@override@JsonKey() Map<int, String?> get shotAttributions {
  if (_shotAttributions is EqualUnmodifiableMapView) return _shotAttributions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_shotAttributions);
}

@override final  int? grossTotal;
@override final  int? netTotal;
@override final  int? points;
@override final  double? handicapIndex;
@override final  int? playingHandicap;
@override final  String? assignedTeeName;
 final  List<HoleAuditEntry> _holeAuditLog;
@override@JsonKey() List<HoleAuditEntry> get holeAuditLog {
  if (_holeAuditLog is EqualUnmodifiableListView) return _holeAuditLog;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holeAuditLog);
}

@override final  String? approvedBy;
@override@OptionalTimestampConverter() final  DateTime? approvedAt;
@override@JsonKey() final  bool adminOverridePublish;
@override@JsonKey() final  bool verifiedByPlayer;
@override@JsonKey() final  bool verifiedByMarker;
@override@JsonKey() final  bool markerReassignmentOpen;
@override@OptionalTimestampConverter() final  DateTime? playerVerifiedAt;
@override@OptionalTimestampConverter() final  DateTime? markerVerifiedAt;
 final  Map<int, List<String>> _holeTags;
@override@JsonKey() Map<int, List<String>> get holeTags {
  if (_holeTags is EqualUnmodifiableMapView) return _holeTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_holeTags);
}

 final  List<int> _conflictedHoles;
@override@JsonKey() List<int> get conflictedHoles {
  if (_conflictedHoles is EqualUnmodifiableListView) return _conflictedHoles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conflictedHoles);
}

@override@JsonKey() final  int committeeAdjustment;
@override final  String? committeeNote;
@override@TimestampConverter() final  DateTime? submittedAt;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of Scorecard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScorecardCopyWith<_Scorecard> get copyWith => __$ScorecardCopyWithImpl<_Scorecard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScorecardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scorecard&&(identical(other.id, id) || other.id == id)&&(identical(other.competitionId, competitionId) || other.competitionId == competitionId)&&(identical(other.roundId, roundId) || other.roundId == roundId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.submittedByUserId, submittedByUserId) || other.submittedByUserId == submittedByUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.scoringStatus, scoringStatus) || other.scoringStatus == scoringStatus)&&const DeepCollectionEquality().equals(other._holeScores, _holeScores)&&const DeepCollectionEquality().equals(other._playerVerifierScores, _playerVerifierScores)&&(identical(other.markerId, markerId) || other.markerId == markerId)&&(identical(other.guestInputAssigneeId, guestInputAssigneeId) || other.guestInputAssigneeId == guestInputAssigneeId)&&const DeepCollectionEquality().equals(other._shotAttributions, _shotAttributions)&&(identical(other.grossTotal, grossTotal) || other.grossTotal == grossTotal)&&(identical(other.netTotal, netTotal) || other.netTotal == netTotal)&&(identical(other.points, points) || other.points == points)&&(identical(other.handicapIndex, handicapIndex) || other.handicapIndex == handicapIndex)&&(identical(other.playingHandicap, playingHandicap) || other.playingHandicap == playingHandicap)&&(identical(other.assignedTeeName, assignedTeeName) || other.assignedTeeName == assignedTeeName)&&const DeepCollectionEquality().equals(other._holeAuditLog, _holeAuditLog)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.adminOverridePublish, adminOverridePublish) || other.adminOverridePublish == adminOverridePublish)&&(identical(other.verifiedByPlayer, verifiedByPlayer) || other.verifiedByPlayer == verifiedByPlayer)&&(identical(other.verifiedByMarker, verifiedByMarker) || other.verifiedByMarker == verifiedByMarker)&&(identical(other.markerReassignmentOpen, markerReassignmentOpen) || other.markerReassignmentOpen == markerReassignmentOpen)&&(identical(other.playerVerifiedAt, playerVerifiedAt) || other.playerVerifiedAt == playerVerifiedAt)&&(identical(other.markerVerifiedAt, markerVerifiedAt) || other.markerVerifiedAt == markerVerifiedAt)&&const DeepCollectionEquality().equals(other._holeTags, _holeTags)&&const DeepCollectionEquality().equals(other._conflictedHoles, _conflictedHoles)&&(identical(other.committeeAdjustment, committeeAdjustment) || other.committeeAdjustment == committeeAdjustment)&&(identical(other.committeeNote, committeeNote) || other.committeeNote == committeeNote)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,competitionId,roundId,entryId,submittedByUserId,status,scoringStatus,const DeepCollectionEquality().hash(_holeScores),const DeepCollectionEquality().hash(_playerVerifierScores),markerId,guestInputAssigneeId,const DeepCollectionEquality().hash(_shotAttributions),grossTotal,netTotal,points,handicapIndex,playingHandicap,assignedTeeName,const DeepCollectionEquality().hash(_holeAuditLog),approvedBy,approvedAt,adminOverridePublish,verifiedByPlayer,verifiedByMarker,markerReassignmentOpen,playerVerifiedAt,markerVerifiedAt,const DeepCollectionEquality().hash(_holeTags),const DeepCollectionEquality().hash(_conflictedHoles),committeeAdjustment,committeeNote,submittedAt,createdAt,updatedAt]);

@override
String toString() {
  return 'Scorecard(id: $id, competitionId: $competitionId, roundId: $roundId, entryId: $entryId, submittedByUserId: $submittedByUserId, status: $status, scoringStatus: $scoringStatus, holeScores: $holeScores, playerVerifierScores: $playerVerifierScores, markerId: $markerId, guestInputAssigneeId: $guestInputAssigneeId, shotAttributions: $shotAttributions, grossTotal: $grossTotal, netTotal: $netTotal, points: $points, handicapIndex: $handicapIndex, playingHandicap: $playingHandicap, assignedTeeName: $assignedTeeName, holeAuditLog: $holeAuditLog, approvedBy: $approvedBy, approvedAt: $approvedAt, adminOverridePublish: $adminOverridePublish, verifiedByPlayer: $verifiedByPlayer, verifiedByMarker: $verifiedByMarker, markerReassignmentOpen: $markerReassignmentOpen, playerVerifiedAt: $playerVerifiedAt, markerVerifiedAt: $markerVerifiedAt, holeTags: $holeTags, conflictedHoles: $conflictedHoles, committeeAdjustment: $committeeAdjustment, committeeNote: $committeeNote, submittedAt: $submittedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ScorecardCopyWith<$Res> implements $ScorecardCopyWith<$Res> {
  factory _$ScorecardCopyWith(_Scorecard value, $Res Function(_Scorecard) _then) = __$ScorecardCopyWithImpl;
@override @useResult
$Res call({
 String id, String competitionId, String roundId, String entryId, String submittedByUserId, ScorecardStatus status, ScoringStatus scoringStatus, List<int?> holeScores, List<int?> playerVerifierScores, String? markerId, String? guestInputAssigneeId, Map<int, String?> shotAttributions, int? grossTotal, int? netTotal, int? points, double? handicapIndex, int? playingHandicap, String? assignedTeeName, List<HoleAuditEntry> holeAuditLog, String? approvedBy,@OptionalTimestampConverter() DateTime? approvedAt, bool adminOverridePublish, bool verifiedByPlayer, bool verifiedByMarker, bool markerReassignmentOpen,@OptionalTimestampConverter() DateTime? playerVerifiedAt,@OptionalTimestampConverter() DateTime? markerVerifiedAt, Map<int, List<String>> holeTags, List<int> conflictedHoles, int committeeAdjustment, String? committeeNote,@TimestampConverter() DateTime? submittedAt,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$ScorecardCopyWithImpl<$Res>
    implements _$ScorecardCopyWith<$Res> {
  __$ScorecardCopyWithImpl(this._self, this._then);

  final _Scorecard _self;
  final $Res Function(_Scorecard) _then;

/// Create a copy of Scorecard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? competitionId = null,Object? roundId = null,Object? entryId = null,Object? submittedByUserId = null,Object? status = null,Object? scoringStatus = null,Object? holeScores = null,Object? playerVerifierScores = null,Object? markerId = freezed,Object? guestInputAssigneeId = freezed,Object? shotAttributions = null,Object? grossTotal = freezed,Object? netTotal = freezed,Object? points = freezed,Object? handicapIndex = freezed,Object? playingHandicap = freezed,Object? assignedTeeName = freezed,Object? holeAuditLog = null,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? adminOverridePublish = null,Object? verifiedByPlayer = null,Object? verifiedByMarker = null,Object? markerReassignmentOpen = null,Object? playerVerifiedAt = freezed,Object? markerVerifiedAt = freezed,Object? holeTags = null,Object? conflictedHoles = null,Object? committeeAdjustment = null,Object? committeeNote = freezed,Object? submittedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Scorecard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,competitionId: null == competitionId ? _self.competitionId : competitionId // ignore: cast_nullable_to_non_nullable
as String,roundId: null == roundId ? _self.roundId : roundId // ignore: cast_nullable_to_non_nullable
as String,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String,submittedByUserId: null == submittedByUserId ? _self.submittedByUserId : submittedByUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScorecardStatus,scoringStatus: null == scoringStatus ? _self.scoringStatus : scoringStatus // ignore: cast_nullable_to_non_nullable
as ScoringStatus,holeScores: null == holeScores ? _self._holeScores : holeScores // ignore: cast_nullable_to_non_nullable
as List<int?>,playerVerifierScores: null == playerVerifierScores ? _self._playerVerifierScores : playerVerifierScores // ignore: cast_nullable_to_non_nullable
as List<int?>,markerId: freezed == markerId ? _self.markerId : markerId // ignore: cast_nullable_to_non_nullable
as String?,guestInputAssigneeId: freezed == guestInputAssigneeId ? _self.guestInputAssigneeId : guestInputAssigneeId // ignore: cast_nullable_to_non_nullable
as String?,shotAttributions: null == shotAttributions ? _self._shotAttributions : shotAttributions // ignore: cast_nullable_to_non_nullable
as Map<int, String?>,grossTotal: freezed == grossTotal ? _self.grossTotal : grossTotal // ignore: cast_nullable_to_non_nullable
as int?,netTotal: freezed == netTotal ? _self.netTotal : netTotal // ignore: cast_nullable_to_non_nullable
as int?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int?,handicapIndex: freezed == handicapIndex ? _self.handicapIndex : handicapIndex // ignore: cast_nullable_to_non_nullable
as double?,playingHandicap: freezed == playingHandicap ? _self.playingHandicap : playingHandicap // ignore: cast_nullable_to_non_nullable
as int?,assignedTeeName: freezed == assignedTeeName ? _self.assignedTeeName : assignedTeeName // ignore: cast_nullable_to_non_nullable
as String?,holeAuditLog: null == holeAuditLog ? _self._holeAuditLog : holeAuditLog // ignore: cast_nullable_to_non_nullable
as List<HoleAuditEntry>,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,adminOverridePublish: null == adminOverridePublish ? _self.adminOverridePublish : adminOverridePublish // ignore: cast_nullable_to_non_nullable
as bool,verifiedByPlayer: null == verifiedByPlayer ? _self.verifiedByPlayer : verifiedByPlayer // ignore: cast_nullable_to_non_nullable
as bool,verifiedByMarker: null == verifiedByMarker ? _self.verifiedByMarker : verifiedByMarker // ignore: cast_nullable_to_non_nullable
as bool,markerReassignmentOpen: null == markerReassignmentOpen ? _self.markerReassignmentOpen : markerReassignmentOpen // ignore: cast_nullable_to_non_nullable
as bool,playerVerifiedAt: freezed == playerVerifiedAt ? _self.playerVerifiedAt : playerVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,markerVerifiedAt: freezed == markerVerifiedAt ? _self.markerVerifiedAt : markerVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,holeTags: null == holeTags ? _self._holeTags : holeTags // ignore: cast_nullable_to_non_nullable
as Map<int, List<String>>,conflictedHoles: null == conflictedHoles ? _self._conflictedHoles : conflictedHoles // ignore: cast_nullable_to_non_nullable
as List<int>,committeeAdjustment: null == committeeAdjustment ? _self.committeeAdjustment : committeeAdjustment // ignore: cast_nullable_to_non_nullable
as int,committeeNote: freezed == committeeNote ? _self.committeeNote : committeeNote // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
