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
mixin _$AdminEditAudit {

 bool get overridden; String get reason; String get editorId;@TimestampConverter() DateTime get timestamp;
/// Create a copy of AdminEditAudit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminEditAuditCopyWith<AdminEditAudit> get copyWith => _$AdminEditAuditCopyWithImpl<AdminEditAudit>(this as AdminEditAudit, _$identity);

  /// Serializes this AdminEditAudit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminEditAudit&&(identical(other.overridden, overridden) || other.overridden == overridden)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.editorId, editorId) || other.editorId == editorId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,overridden,reason,editorId,timestamp);

@override
String toString() {
  return 'AdminEditAudit(overridden: $overridden, reason: $reason, editorId: $editorId, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $AdminEditAuditCopyWith<$Res>  {
  factory $AdminEditAuditCopyWith(AdminEditAudit value, $Res Function(AdminEditAudit) _then) = _$AdminEditAuditCopyWithImpl;
@useResult
$Res call({
 bool overridden, String reason, String editorId,@TimestampConverter() DateTime timestamp
});




}
/// @nodoc
class _$AdminEditAuditCopyWithImpl<$Res>
    implements $AdminEditAuditCopyWith<$Res> {
  _$AdminEditAuditCopyWithImpl(this._self, this._then);

  final AdminEditAudit _self;
  final $Res Function(AdminEditAudit) _then;

/// Create a copy of AdminEditAudit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? overridden = null,Object? reason = null,Object? editorId = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
overridden: null == overridden ? _self.overridden : overridden // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,editorId: null == editorId ? _self.editorId : editorId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminEditAudit].
extension AdminEditAuditPatterns on AdminEditAudit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminEditAudit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminEditAudit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminEditAudit value)  $default,){
final _that = this;
switch (_that) {
case _AdminEditAudit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminEditAudit value)?  $default,){
final _that = this;
switch (_that) {
case _AdminEditAudit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool overridden,  String reason,  String editorId, @TimestampConverter()  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminEditAudit() when $default != null:
return $default(_that.overridden,_that.reason,_that.editorId,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool overridden,  String reason,  String editorId, @TimestampConverter()  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _AdminEditAudit():
return $default(_that.overridden,_that.reason,_that.editorId,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool overridden,  String reason,  String editorId, @TimestampConverter()  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _AdminEditAudit() when $default != null:
return $default(_that.overridden,_that.reason,_that.editorId,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminEditAudit implements AdminEditAudit {
  const _AdminEditAudit({required this.overridden, required this.reason, required this.editorId, @TimestampConverter() required this.timestamp});
  factory _AdminEditAudit.fromJson(Map<String, dynamic> json) => _$AdminEditAuditFromJson(json);

@override final  bool overridden;
@override final  String reason;
@override final  String editorId;
@override@TimestampConverter() final  DateTime timestamp;

/// Create a copy of AdminEditAudit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminEditAuditCopyWith<_AdminEditAudit> get copyWith => __$AdminEditAuditCopyWithImpl<_AdminEditAudit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminEditAuditToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminEditAudit&&(identical(other.overridden, overridden) || other.overridden == overridden)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.editorId, editorId) || other.editorId == editorId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,overridden,reason,editorId,timestamp);

@override
String toString() {
  return 'AdminEditAudit(overridden: $overridden, reason: $reason, editorId: $editorId, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$AdminEditAuditCopyWith<$Res> implements $AdminEditAuditCopyWith<$Res> {
  factory _$AdminEditAuditCopyWith(_AdminEditAudit value, $Res Function(_AdminEditAudit) _then) = __$AdminEditAuditCopyWithImpl;
@override @useResult
$Res call({
 bool overridden, String reason, String editorId,@TimestampConverter() DateTime timestamp
});




}
/// @nodoc
class __$AdminEditAuditCopyWithImpl<$Res>
    implements _$AdminEditAuditCopyWith<$Res> {
  __$AdminEditAuditCopyWithImpl(this._self, this._then);

  final _AdminEditAudit _self;
  final $Res Function(_AdminEditAudit) _then;

/// Create a copy of AdminEditAudit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? overridden = null,Object? reason = null,Object? editorId = null,Object? timestamp = null,}) {
  return _then(_AdminEditAudit(
overridden: null == overridden ? _self.overridden : overridden // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,editorId: null == editorId ? _self.editorId : editorId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Scorecard {

 String get id; String get competitionId; String get roundId; String get entryId;// memberId or teamId
 String get submittedByUserId; ScorecardStatus get status; ScoringStatus get scoringStatus; List<int?> get holeScores; List<int?> get playerVerifierScores; String? get markerId; int? get grossTotal; int? get netTotal; int? get points; AdminEditAudit? get adminEditAudit; bool get adminOverridePublish;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of Scorecard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScorecardCopyWith<Scorecard> get copyWith => _$ScorecardCopyWithImpl<Scorecard>(this as Scorecard, _$identity);

  /// Serializes this Scorecard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scorecard&&(identical(other.id, id) || other.id == id)&&(identical(other.competitionId, competitionId) || other.competitionId == competitionId)&&(identical(other.roundId, roundId) || other.roundId == roundId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.submittedByUserId, submittedByUserId) || other.submittedByUserId == submittedByUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.scoringStatus, scoringStatus) || other.scoringStatus == scoringStatus)&&const DeepCollectionEquality().equals(other.holeScores, holeScores)&&const DeepCollectionEquality().equals(other.playerVerifierScores, playerVerifierScores)&&(identical(other.markerId, markerId) || other.markerId == markerId)&&(identical(other.grossTotal, grossTotal) || other.grossTotal == grossTotal)&&(identical(other.netTotal, netTotal) || other.netTotal == netTotal)&&(identical(other.points, points) || other.points == points)&&(identical(other.adminEditAudit, adminEditAudit) || other.adminEditAudit == adminEditAudit)&&(identical(other.adminOverridePublish, adminOverridePublish) || other.adminOverridePublish == adminOverridePublish)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,competitionId,roundId,entryId,submittedByUserId,status,scoringStatus,const DeepCollectionEquality().hash(holeScores),const DeepCollectionEquality().hash(playerVerifierScores),markerId,grossTotal,netTotal,points,adminEditAudit,adminOverridePublish,createdAt,updatedAt);

@override
String toString() {
  return 'Scorecard(id: $id, competitionId: $competitionId, roundId: $roundId, entryId: $entryId, submittedByUserId: $submittedByUserId, status: $status, scoringStatus: $scoringStatus, holeScores: $holeScores, playerVerifierScores: $playerVerifierScores, markerId: $markerId, grossTotal: $grossTotal, netTotal: $netTotal, points: $points, adminEditAudit: $adminEditAudit, adminOverridePublish: $adminOverridePublish, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ScorecardCopyWith<$Res>  {
  factory $ScorecardCopyWith(Scorecard value, $Res Function(Scorecard) _then) = _$ScorecardCopyWithImpl;
@useResult
$Res call({
 String id, String competitionId, String roundId, String entryId, String submittedByUserId, ScorecardStatus status, ScoringStatus scoringStatus, List<int?> holeScores, List<int?> playerVerifierScores, String? markerId, int? grossTotal, int? netTotal, int? points, AdminEditAudit? adminEditAudit, bool adminOverridePublish,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});


$AdminEditAuditCopyWith<$Res>? get adminEditAudit;

}
/// @nodoc
class _$ScorecardCopyWithImpl<$Res>
    implements $ScorecardCopyWith<$Res> {
  _$ScorecardCopyWithImpl(this._self, this._then);

  final Scorecard _self;
  final $Res Function(Scorecard) _then;

/// Create a copy of Scorecard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? competitionId = null,Object? roundId = null,Object? entryId = null,Object? submittedByUserId = null,Object? status = null,Object? scoringStatus = null,Object? holeScores = null,Object? playerVerifierScores = null,Object? markerId = freezed,Object? grossTotal = freezed,Object? netTotal = freezed,Object? points = freezed,Object? adminEditAudit = freezed,Object? adminOverridePublish = null,Object? createdAt = null,Object? updatedAt = null,}) {
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
as String?,grossTotal: freezed == grossTotal ? _self.grossTotal : grossTotal // ignore: cast_nullable_to_non_nullable
as int?,netTotal: freezed == netTotal ? _self.netTotal : netTotal // ignore: cast_nullable_to_non_nullable
as int?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int?,adminEditAudit: freezed == adminEditAudit ? _self.adminEditAudit : adminEditAudit // ignore: cast_nullable_to_non_nullable
as AdminEditAudit?,adminOverridePublish: null == adminOverridePublish ? _self.adminOverridePublish : adminOverridePublish // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Scorecard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminEditAuditCopyWith<$Res>? get adminEditAudit {
    if (_self.adminEditAudit == null) {
    return null;
  }

  return $AdminEditAuditCopyWith<$Res>(_self.adminEditAudit!, (value) {
    return _then(_self.copyWith(adminEditAudit: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String competitionId,  String roundId,  String entryId,  String submittedByUserId,  ScorecardStatus status,  ScoringStatus scoringStatus,  List<int?> holeScores,  List<int?> playerVerifierScores,  String? markerId,  int? grossTotal,  int? netTotal,  int? points,  AdminEditAudit? adminEditAudit,  bool adminOverridePublish, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scorecard() when $default != null:
return $default(_that.id,_that.competitionId,_that.roundId,_that.entryId,_that.submittedByUserId,_that.status,_that.scoringStatus,_that.holeScores,_that.playerVerifierScores,_that.markerId,_that.grossTotal,_that.netTotal,_that.points,_that.adminEditAudit,_that.adminOverridePublish,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String competitionId,  String roundId,  String entryId,  String submittedByUserId,  ScorecardStatus status,  ScoringStatus scoringStatus,  List<int?> holeScores,  List<int?> playerVerifierScores,  String? markerId,  int? grossTotal,  int? netTotal,  int? points,  AdminEditAudit? adminEditAudit,  bool adminOverridePublish, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Scorecard():
return $default(_that.id,_that.competitionId,_that.roundId,_that.entryId,_that.submittedByUserId,_that.status,_that.scoringStatus,_that.holeScores,_that.playerVerifierScores,_that.markerId,_that.grossTotal,_that.netTotal,_that.points,_that.adminEditAudit,_that.adminOverridePublish,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String competitionId,  String roundId,  String entryId,  String submittedByUserId,  ScorecardStatus status,  ScoringStatus scoringStatus,  List<int?> holeScores,  List<int?> playerVerifierScores,  String? markerId,  int? grossTotal,  int? netTotal,  int? points,  AdminEditAudit? adminEditAudit,  bool adminOverridePublish, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Scorecard() when $default != null:
return $default(_that.id,_that.competitionId,_that.roundId,_that.entryId,_that.submittedByUserId,_that.status,_that.scoringStatus,_that.holeScores,_that.playerVerifierScores,_that.markerId,_that.grossTotal,_that.netTotal,_that.points,_that.adminEditAudit,_that.adminOverridePublish,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Scorecard extends Scorecard {
  const _Scorecard({required this.id, required this.competitionId, required this.roundId, required this.entryId, required this.submittedByUserId, this.status = ScorecardStatus.draft, this.scoringStatus = ScoringStatus.ok, final  List<int?> holeScores = const [], final  List<int?> playerVerifierScores = const [], this.markerId, this.grossTotal, this.netTotal, this.points, this.adminEditAudit, this.adminOverridePublish = false, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt}): _holeScores = holeScores,_playerVerifierScores = playerVerifierScores,super._();
  factory _Scorecard.fromJson(Map<String, dynamic> json) => _$ScorecardFromJson(json);

@override final  String id;
@override final  String competitionId;
@override final  String roundId;
@override final  String entryId;
// memberId or teamId
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
@override final  int? grossTotal;
@override final  int? netTotal;
@override final  int? points;
@override final  AdminEditAudit? adminEditAudit;
@override@JsonKey() final  bool adminOverridePublish;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scorecard&&(identical(other.id, id) || other.id == id)&&(identical(other.competitionId, competitionId) || other.competitionId == competitionId)&&(identical(other.roundId, roundId) || other.roundId == roundId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.submittedByUserId, submittedByUserId) || other.submittedByUserId == submittedByUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.scoringStatus, scoringStatus) || other.scoringStatus == scoringStatus)&&const DeepCollectionEquality().equals(other._holeScores, _holeScores)&&const DeepCollectionEquality().equals(other._playerVerifierScores, _playerVerifierScores)&&(identical(other.markerId, markerId) || other.markerId == markerId)&&(identical(other.grossTotal, grossTotal) || other.grossTotal == grossTotal)&&(identical(other.netTotal, netTotal) || other.netTotal == netTotal)&&(identical(other.points, points) || other.points == points)&&(identical(other.adminEditAudit, adminEditAudit) || other.adminEditAudit == adminEditAudit)&&(identical(other.adminOverridePublish, adminOverridePublish) || other.adminOverridePublish == adminOverridePublish)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,competitionId,roundId,entryId,submittedByUserId,status,scoringStatus,const DeepCollectionEquality().hash(_holeScores),const DeepCollectionEquality().hash(_playerVerifierScores),markerId,grossTotal,netTotal,points,adminEditAudit,adminOverridePublish,createdAt,updatedAt);

@override
String toString() {
  return 'Scorecard(id: $id, competitionId: $competitionId, roundId: $roundId, entryId: $entryId, submittedByUserId: $submittedByUserId, status: $status, scoringStatus: $scoringStatus, holeScores: $holeScores, playerVerifierScores: $playerVerifierScores, markerId: $markerId, grossTotal: $grossTotal, netTotal: $netTotal, points: $points, adminEditAudit: $adminEditAudit, adminOverridePublish: $adminOverridePublish, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ScorecardCopyWith<$Res> implements $ScorecardCopyWith<$Res> {
  factory _$ScorecardCopyWith(_Scorecard value, $Res Function(_Scorecard) _then) = __$ScorecardCopyWithImpl;
@override @useResult
$Res call({
 String id, String competitionId, String roundId, String entryId, String submittedByUserId, ScorecardStatus status, ScoringStatus scoringStatus, List<int?> holeScores, List<int?> playerVerifierScores, String? markerId, int? grossTotal, int? netTotal, int? points, AdminEditAudit? adminEditAudit, bool adminOverridePublish,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});


@override $AdminEditAuditCopyWith<$Res>? get adminEditAudit;

}
/// @nodoc
class __$ScorecardCopyWithImpl<$Res>
    implements _$ScorecardCopyWith<$Res> {
  __$ScorecardCopyWithImpl(this._self, this._then);

  final _Scorecard _self;
  final $Res Function(_Scorecard) _then;

/// Create a copy of Scorecard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? competitionId = null,Object? roundId = null,Object? entryId = null,Object? submittedByUserId = null,Object? status = null,Object? scoringStatus = null,Object? holeScores = null,Object? playerVerifierScores = null,Object? markerId = freezed,Object? grossTotal = freezed,Object? netTotal = freezed,Object? points = freezed,Object? adminEditAudit = freezed,Object? adminOverridePublish = null,Object? createdAt = null,Object? updatedAt = null,}) {
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
as String?,grossTotal: freezed == grossTotal ? _self.grossTotal : grossTotal // ignore: cast_nullable_to_non_nullable
as int?,netTotal: freezed == netTotal ? _self.netTotal : netTotal // ignore: cast_nullable_to_non_nullable
as int?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int?,adminEditAudit: freezed == adminEditAudit ? _self.adminEditAudit : adminEditAudit // ignore: cast_nullable_to_non_nullable
as AdminEditAudit?,adminOverridePublish: null == adminOverridePublish ? _self.adminOverridePublish : adminOverridePublish // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Scorecard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminEditAuditCopyWith<$Res>? get adminEditAudit {
    if (_self.adminEditAudit == null) {
    return null;
  }

  return $AdminEditAuditCopyWith<$Res>(_self.adminEditAudit!, (value) {
    return _then(_self.copyWith(adminEditAudit: value));
  });
}
}

// dart format on
