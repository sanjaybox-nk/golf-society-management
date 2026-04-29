// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'matchplay.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchplayResult {

 String get winnerId; String get scoreDisplay;// e.g., "3 & 2", "1 Up", "2 Up"
 List<int> get holeWins;// 1 for Player A win, -1 for Player B win, 0 for halved
 bool get isWalkover;
/// Create a copy of MatchplayResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchplayResultCopyWith<MatchplayResult> get copyWith => _$MatchplayResultCopyWithImpl<MatchplayResult>(this as MatchplayResult, _$identity);

  /// Serializes this MatchplayResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchplayResult&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.scoreDisplay, scoreDisplay) || other.scoreDisplay == scoreDisplay)&&const DeepCollectionEquality().equals(other.holeWins, holeWins)&&(identical(other.isWalkover, isWalkover) || other.isWalkover == isWalkover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,winnerId,scoreDisplay,const DeepCollectionEquality().hash(holeWins),isWalkover);

@override
String toString() {
  return 'MatchplayResult(winnerId: $winnerId, scoreDisplay: $scoreDisplay, holeWins: $holeWins, isWalkover: $isWalkover)';
}


}

/// @nodoc
abstract mixin class $MatchplayResultCopyWith<$Res>  {
  factory $MatchplayResultCopyWith(MatchplayResult value, $Res Function(MatchplayResult) _then) = _$MatchplayResultCopyWithImpl;
@useResult
$Res call({
 String winnerId, String scoreDisplay, List<int> holeWins, bool isWalkover
});




}
/// @nodoc
class _$MatchplayResultCopyWithImpl<$Res>
    implements $MatchplayResultCopyWith<$Res> {
  _$MatchplayResultCopyWithImpl(this._self, this._then);

  final MatchplayResult _self;
  final $Res Function(MatchplayResult) _then;

/// Create a copy of MatchplayResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? winnerId = null,Object? scoreDisplay = null,Object? holeWins = null,Object? isWalkover = null,}) {
  return _then(_self.copyWith(
winnerId: null == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String,scoreDisplay: null == scoreDisplay ? _self.scoreDisplay : scoreDisplay // ignore: cast_nullable_to_non_nullable
as String,holeWins: null == holeWins ? _self.holeWins : holeWins // ignore: cast_nullable_to_non_nullable
as List<int>,isWalkover: null == isWalkover ? _self.isWalkover : isWalkover // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchplayResult].
extension MatchplayResultPatterns on MatchplayResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchplayResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchplayResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchplayResult value)  $default,){
final _that = this;
switch (_that) {
case _MatchplayResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchplayResult value)?  $default,){
final _that = this;
switch (_that) {
case _MatchplayResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String winnerId,  String scoreDisplay,  List<int> holeWins,  bool isWalkover)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchplayResult() when $default != null:
return $default(_that.winnerId,_that.scoreDisplay,_that.holeWins,_that.isWalkover);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String winnerId,  String scoreDisplay,  List<int> holeWins,  bool isWalkover)  $default,) {final _that = this;
switch (_that) {
case _MatchplayResult():
return $default(_that.winnerId,_that.scoreDisplay,_that.holeWins,_that.isWalkover);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String winnerId,  String scoreDisplay,  List<int> holeWins,  bool isWalkover)?  $default,) {final _that = this;
switch (_that) {
case _MatchplayResult() when $default != null:
return $default(_that.winnerId,_that.scoreDisplay,_that.holeWins,_that.isWalkover);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchplayResult implements MatchplayResult {
  const _MatchplayResult({required this.winnerId, required this.scoreDisplay, final  List<int> holeWins = const [], this.isWalkover = false}): _holeWins = holeWins;
  factory _MatchplayResult.fromJson(Map<String, dynamic> json) => _$MatchplayResultFromJson(json);

@override final  String winnerId;
@override final  String scoreDisplay;
// e.g., "3 & 2", "1 Up", "2 Up"
 final  List<int> _holeWins;
// e.g., "3 & 2", "1 Up", "2 Up"
@override@JsonKey() List<int> get holeWins {
  if (_holeWins is EqualUnmodifiableListView) return _holeWins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holeWins);
}

// 1 for Player A win, -1 for Player B win, 0 for halved
@override@JsonKey() final  bool isWalkover;

/// Create a copy of MatchplayResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchplayResultCopyWith<_MatchplayResult> get copyWith => __$MatchplayResultCopyWithImpl<_MatchplayResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchplayResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchplayResult&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.scoreDisplay, scoreDisplay) || other.scoreDisplay == scoreDisplay)&&const DeepCollectionEquality().equals(other._holeWins, _holeWins)&&(identical(other.isWalkover, isWalkover) || other.isWalkover == isWalkover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,winnerId,scoreDisplay,const DeepCollectionEquality().hash(_holeWins),isWalkover);

@override
String toString() {
  return 'MatchplayResult(winnerId: $winnerId, scoreDisplay: $scoreDisplay, holeWins: $holeWins, isWalkover: $isWalkover)';
}


}

/// @nodoc
abstract mixin class _$MatchplayResultCopyWith<$Res> implements $MatchplayResultCopyWith<$Res> {
  factory _$MatchplayResultCopyWith(_MatchplayResult value, $Res Function(_MatchplayResult) _then) = __$MatchplayResultCopyWithImpl;
@override @useResult
$Res call({
 String winnerId, String scoreDisplay, List<int> holeWins, bool isWalkover
});




}
/// @nodoc
class __$MatchplayResultCopyWithImpl<$Res>
    implements _$MatchplayResultCopyWith<$Res> {
  __$MatchplayResultCopyWithImpl(this._self, this._then);

  final _MatchplayResult _self;
  final $Res Function(_MatchplayResult) _then;

/// Create a copy of MatchplayResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? winnerId = null,Object? scoreDisplay = null,Object? holeWins = null,Object? isWalkover = null,}) {
  return _then(_MatchplayResult(
winnerId: null == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String,scoreDisplay: null == scoreDisplay ? _self.scoreDisplay : scoreDisplay // ignore: cast_nullable_to_non_nullable
as String,holeWins: null == holeWins ? _self._holeWins : holeWins // ignore: cast_nullable_to_non_nullable
as List<int>,isWalkover: null == isWalkover ? _self.isWalkover : isWalkover // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MatchplayMatch {

 String get id; String get playerAId; String get playerBId; String? get playerAName; String? get playerBName; double get playerAHandicap; double get playerBHandicap; int get strokesReceived;// Result of (A-B) * allowance
 MatchplayStatus get status; MatchplayResult? get result; String? get eventId;// Link to a specific society event if played during one
@OptionalTimestampConverter() DateTime? get playedDate;
/// Create a copy of MatchplayMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchplayMatchCopyWith<MatchplayMatch> get copyWith => _$MatchplayMatchCopyWithImpl<MatchplayMatch>(this as MatchplayMatch, _$identity);

  /// Serializes this MatchplayMatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchplayMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.playerAId, playerAId) || other.playerAId == playerAId)&&(identical(other.playerBId, playerBId) || other.playerBId == playerBId)&&(identical(other.playerAName, playerAName) || other.playerAName == playerAName)&&(identical(other.playerBName, playerBName) || other.playerBName == playerBName)&&(identical(other.playerAHandicap, playerAHandicap) || other.playerAHandicap == playerAHandicap)&&(identical(other.playerBHandicap, playerBHandicap) || other.playerBHandicap == playerBHandicap)&&(identical(other.strokesReceived, strokesReceived) || other.strokesReceived == strokesReceived)&&(identical(other.status, status) || other.status == status)&&(identical(other.result, result) || other.result == result)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.playedDate, playedDate) || other.playedDate == playedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,playerAId,playerBId,playerAName,playerBName,playerAHandicap,playerBHandicap,strokesReceived,status,result,eventId,playedDate);

@override
String toString() {
  return 'MatchplayMatch(id: $id, playerAId: $playerAId, playerBId: $playerBId, playerAName: $playerAName, playerBName: $playerBName, playerAHandicap: $playerAHandicap, playerBHandicap: $playerBHandicap, strokesReceived: $strokesReceived, status: $status, result: $result, eventId: $eventId, playedDate: $playedDate)';
}


}

/// @nodoc
abstract mixin class $MatchplayMatchCopyWith<$Res>  {
  factory $MatchplayMatchCopyWith(MatchplayMatch value, $Res Function(MatchplayMatch) _then) = _$MatchplayMatchCopyWithImpl;
@useResult
$Res call({
 String id, String playerAId, String playerBId, String? playerAName, String? playerBName, double playerAHandicap, double playerBHandicap, int strokesReceived, MatchplayStatus status, MatchplayResult? result, String? eventId,@OptionalTimestampConverter() DateTime? playedDate
});


$MatchplayResultCopyWith<$Res>? get result;

}
/// @nodoc
class _$MatchplayMatchCopyWithImpl<$Res>
    implements $MatchplayMatchCopyWith<$Res> {
  _$MatchplayMatchCopyWithImpl(this._self, this._then);

  final MatchplayMatch _self;
  final $Res Function(MatchplayMatch) _then;

/// Create a copy of MatchplayMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? playerAId = null,Object? playerBId = null,Object? playerAName = freezed,Object? playerBName = freezed,Object? playerAHandicap = null,Object? playerBHandicap = null,Object? strokesReceived = null,Object? status = null,Object? result = freezed,Object? eventId = freezed,Object? playedDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playerAId: null == playerAId ? _self.playerAId : playerAId // ignore: cast_nullable_to_non_nullable
as String,playerBId: null == playerBId ? _self.playerBId : playerBId // ignore: cast_nullable_to_non_nullable
as String,playerAName: freezed == playerAName ? _self.playerAName : playerAName // ignore: cast_nullable_to_non_nullable
as String?,playerBName: freezed == playerBName ? _self.playerBName : playerBName // ignore: cast_nullable_to_non_nullable
as String?,playerAHandicap: null == playerAHandicap ? _self.playerAHandicap : playerAHandicap // ignore: cast_nullable_to_non_nullable
as double,playerBHandicap: null == playerBHandicap ? _self.playerBHandicap : playerBHandicap // ignore: cast_nullable_to_non_nullable
as double,strokesReceived: null == strokesReceived ? _self.strokesReceived : strokesReceived // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchplayStatus,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as MatchplayResult?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,playedDate: freezed == playedDate ? _self.playedDate : playedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of MatchplayMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchplayResultCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $MatchplayResultCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [MatchplayMatch].
extension MatchplayMatchPatterns on MatchplayMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchplayMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchplayMatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchplayMatch value)  $default,){
final _that = this;
switch (_that) {
case _MatchplayMatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchplayMatch value)?  $default,){
final _that = this;
switch (_that) {
case _MatchplayMatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String playerAId,  String playerBId,  String? playerAName,  String? playerBName,  double playerAHandicap,  double playerBHandicap,  int strokesReceived,  MatchplayStatus status,  MatchplayResult? result,  String? eventId, @OptionalTimestampConverter()  DateTime? playedDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchplayMatch() when $default != null:
return $default(_that.id,_that.playerAId,_that.playerBId,_that.playerAName,_that.playerBName,_that.playerAHandicap,_that.playerBHandicap,_that.strokesReceived,_that.status,_that.result,_that.eventId,_that.playedDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String playerAId,  String playerBId,  String? playerAName,  String? playerBName,  double playerAHandicap,  double playerBHandicap,  int strokesReceived,  MatchplayStatus status,  MatchplayResult? result,  String? eventId, @OptionalTimestampConverter()  DateTime? playedDate)  $default,) {final _that = this;
switch (_that) {
case _MatchplayMatch():
return $default(_that.id,_that.playerAId,_that.playerBId,_that.playerAName,_that.playerBName,_that.playerAHandicap,_that.playerBHandicap,_that.strokesReceived,_that.status,_that.result,_that.eventId,_that.playedDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String playerAId,  String playerBId,  String? playerAName,  String? playerBName,  double playerAHandicap,  double playerBHandicap,  int strokesReceived,  MatchplayStatus status,  MatchplayResult? result,  String? eventId, @OptionalTimestampConverter()  DateTime? playedDate)?  $default,) {final _that = this;
switch (_that) {
case _MatchplayMatch() when $default != null:
return $default(_that.id,_that.playerAId,_that.playerBId,_that.playerAName,_that.playerBName,_that.playerAHandicap,_that.playerBHandicap,_that.strokesReceived,_that.status,_that.result,_that.eventId,_that.playedDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchplayMatch implements MatchplayMatch {
  const _MatchplayMatch({required this.id, required this.playerAId, required this.playerBId, this.playerAName, this.playerBName, required this.playerAHandicap, required this.playerBHandicap, required this.strokesReceived, this.status = MatchplayStatus.scheduled, this.result, this.eventId, @OptionalTimestampConverter() this.playedDate});
  factory _MatchplayMatch.fromJson(Map<String, dynamic> json) => _$MatchplayMatchFromJson(json);

@override final  String id;
@override final  String playerAId;
@override final  String playerBId;
@override final  String? playerAName;
@override final  String? playerBName;
@override final  double playerAHandicap;
@override final  double playerBHandicap;
@override final  int strokesReceived;
// Result of (A-B) * allowance
@override@JsonKey() final  MatchplayStatus status;
@override final  MatchplayResult? result;
@override final  String? eventId;
// Link to a specific society event if played during one
@override@OptionalTimestampConverter() final  DateTime? playedDate;

/// Create a copy of MatchplayMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchplayMatchCopyWith<_MatchplayMatch> get copyWith => __$MatchplayMatchCopyWithImpl<_MatchplayMatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchplayMatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchplayMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.playerAId, playerAId) || other.playerAId == playerAId)&&(identical(other.playerBId, playerBId) || other.playerBId == playerBId)&&(identical(other.playerAName, playerAName) || other.playerAName == playerAName)&&(identical(other.playerBName, playerBName) || other.playerBName == playerBName)&&(identical(other.playerAHandicap, playerAHandicap) || other.playerAHandicap == playerAHandicap)&&(identical(other.playerBHandicap, playerBHandicap) || other.playerBHandicap == playerBHandicap)&&(identical(other.strokesReceived, strokesReceived) || other.strokesReceived == strokesReceived)&&(identical(other.status, status) || other.status == status)&&(identical(other.result, result) || other.result == result)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.playedDate, playedDate) || other.playedDate == playedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,playerAId,playerBId,playerAName,playerBName,playerAHandicap,playerBHandicap,strokesReceived,status,result,eventId,playedDate);

@override
String toString() {
  return 'MatchplayMatch(id: $id, playerAId: $playerAId, playerBId: $playerBId, playerAName: $playerAName, playerBName: $playerBName, playerAHandicap: $playerAHandicap, playerBHandicap: $playerBHandicap, strokesReceived: $strokesReceived, status: $status, result: $result, eventId: $eventId, playedDate: $playedDate)';
}


}

/// @nodoc
abstract mixin class _$MatchplayMatchCopyWith<$Res> implements $MatchplayMatchCopyWith<$Res> {
  factory _$MatchplayMatchCopyWith(_MatchplayMatch value, $Res Function(_MatchplayMatch) _then) = __$MatchplayMatchCopyWithImpl;
@override @useResult
$Res call({
 String id, String playerAId, String playerBId, String? playerAName, String? playerBName, double playerAHandicap, double playerBHandicap, int strokesReceived, MatchplayStatus status, MatchplayResult? result, String? eventId,@OptionalTimestampConverter() DateTime? playedDate
});


@override $MatchplayResultCopyWith<$Res>? get result;

}
/// @nodoc
class __$MatchplayMatchCopyWithImpl<$Res>
    implements _$MatchplayMatchCopyWith<$Res> {
  __$MatchplayMatchCopyWithImpl(this._self, this._then);

  final _MatchplayMatch _self;
  final $Res Function(_MatchplayMatch) _then;

/// Create a copy of MatchplayMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? playerAId = null,Object? playerBId = null,Object? playerAName = freezed,Object? playerBName = freezed,Object? playerAHandicap = null,Object? playerBHandicap = null,Object? strokesReceived = null,Object? status = null,Object? result = freezed,Object? eventId = freezed,Object? playedDate = freezed,}) {
  return _then(_MatchplayMatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playerAId: null == playerAId ? _self.playerAId : playerAId // ignore: cast_nullable_to_non_nullable
as String,playerBId: null == playerBId ? _self.playerBId : playerBId // ignore: cast_nullable_to_non_nullable
as String,playerAName: freezed == playerAName ? _self.playerAName : playerAName // ignore: cast_nullable_to_non_nullable
as String?,playerBName: freezed == playerBName ? _self.playerBName : playerBName // ignore: cast_nullable_to_non_nullable
as String?,playerAHandicap: null == playerAHandicap ? _self.playerAHandicap : playerAHandicap // ignore: cast_nullable_to_non_nullable
as double,playerBHandicap: null == playerBHandicap ? _self.playerBHandicap : playerBHandicap // ignore: cast_nullable_to_non_nullable
as double,strokesReceived: null == strokesReceived ? _self.strokesReceived : strokesReceived // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchplayStatus,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as MatchplayResult?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,playedDate: freezed == playedDate ? _self.playedDate : playedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of MatchplayMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchplayResultCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $MatchplayResultCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// @nodoc
mixin _$MatchplayRound {

 String get id; String get name;// e.g., "Quarter Finals"
 List<MatchplayMatch> get matches;@TimestampConverter() DateTime get deadline;
/// Create a copy of MatchplayRound
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchplayRoundCopyWith<MatchplayRound> get copyWith => _$MatchplayRoundCopyWithImpl<MatchplayRound>(this as MatchplayRound, _$identity);

  /// Serializes this MatchplayRound to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchplayRound&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.matches, matches)&&(identical(other.deadline, deadline) || other.deadline == deadline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(matches),deadline);

@override
String toString() {
  return 'MatchplayRound(id: $id, name: $name, matches: $matches, deadline: $deadline)';
}


}

/// @nodoc
abstract mixin class $MatchplayRoundCopyWith<$Res>  {
  factory $MatchplayRoundCopyWith(MatchplayRound value, $Res Function(MatchplayRound) _then) = _$MatchplayRoundCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<MatchplayMatch> matches,@TimestampConverter() DateTime deadline
});




}
/// @nodoc
class _$MatchplayRoundCopyWithImpl<$Res>
    implements $MatchplayRoundCopyWith<$Res> {
  _$MatchplayRoundCopyWithImpl(this._self, this._then);

  final MatchplayRound _self;
  final $Res Function(MatchplayRound) _then;

/// Create a copy of MatchplayRound
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? matches = null,Object? deadline = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,matches: null == matches ? _self.matches : matches // ignore: cast_nullable_to_non_nullable
as List<MatchplayMatch>,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchplayRound].
extension MatchplayRoundPatterns on MatchplayRound {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchplayRound value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchplayRound() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchplayRound value)  $default,){
final _that = this;
switch (_that) {
case _MatchplayRound():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchplayRound value)?  $default,){
final _that = this;
switch (_that) {
case _MatchplayRound() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<MatchplayMatch> matches, @TimestampConverter()  DateTime deadline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchplayRound() when $default != null:
return $default(_that.id,_that.name,_that.matches,_that.deadline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<MatchplayMatch> matches, @TimestampConverter()  DateTime deadline)  $default,) {final _that = this;
switch (_that) {
case _MatchplayRound():
return $default(_that.id,_that.name,_that.matches,_that.deadline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<MatchplayMatch> matches, @TimestampConverter()  DateTime deadline)?  $default,) {final _that = this;
switch (_that) {
case _MatchplayRound() when $default != null:
return $default(_that.id,_that.name,_that.matches,_that.deadline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchplayRound implements MatchplayRound {
  const _MatchplayRound({required this.id, required this.name, final  List<MatchplayMatch> matches = const [], @TimestampConverter() required this.deadline}): _matches = matches;
  factory _MatchplayRound.fromJson(Map<String, dynamic> json) => _$MatchplayRoundFromJson(json);

@override final  String id;
@override final  String name;
// e.g., "Quarter Finals"
 final  List<MatchplayMatch> _matches;
// e.g., "Quarter Finals"
@override@JsonKey() List<MatchplayMatch> get matches {
  if (_matches is EqualUnmodifiableListView) return _matches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matches);
}

@override@TimestampConverter() final  DateTime deadline;

/// Create a copy of MatchplayRound
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchplayRoundCopyWith<_MatchplayRound> get copyWith => __$MatchplayRoundCopyWithImpl<_MatchplayRound>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchplayRoundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchplayRound&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._matches, _matches)&&(identical(other.deadline, deadline) || other.deadline == deadline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_matches),deadline);

@override
String toString() {
  return 'MatchplayRound(id: $id, name: $name, matches: $matches, deadline: $deadline)';
}


}

/// @nodoc
abstract mixin class _$MatchplayRoundCopyWith<$Res> implements $MatchplayRoundCopyWith<$Res> {
  factory _$MatchplayRoundCopyWith(_MatchplayRound value, $Res Function(_MatchplayRound) _then) = __$MatchplayRoundCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<MatchplayMatch> matches,@TimestampConverter() DateTime deadline
});




}
/// @nodoc
class __$MatchplayRoundCopyWithImpl<$Res>
    implements _$MatchplayRoundCopyWith<$Res> {
  __$MatchplayRoundCopyWithImpl(this._self, this._then);

  final _MatchplayRound _self;
  final $Res Function(_MatchplayRound) _then;

/// Create a copy of MatchplayRound
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? matches = null,Object? deadline = null,}) {
  return _then(_MatchplayRound(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,matches: null == matches ? _self._matches : matches // ignore: cast_nullable_to_non_nullable
as List<MatchplayMatch>,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$MatchplayComp {

 String get id; String get title; bool get isActive; List<MatchplayRound> get rounds; double get handicapAllowance;// Usually full difference or 90%
@TimestampConverter() DateTime get createdAt;
/// Create a copy of MatchplayComp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchplayCompCopyWith<MatchplayComp> get copyWith => _$MatchplayCompCopyWithImpl<MatchplayComp>(this as MatchplayComp, _$identity);

  /// Serializes this MatchplayComp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchplayComp&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.rounds, rounds)&&(identical(other.handicapAllowance, handicapAllowance) || other.handicapAllowance == handicapAllowance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,isActive,const DeepCollectionEquality().hash(rounds),handicapAllowance,createdAt);

@override
String toString() {
  return 'MatchplayComp(id: $id, title: $title, isActive: $isActive, rounds: $rounds, handicapAllowance: $handicapAllowance, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MatchplayCompCopyWith<$Res>  {
  factory $MatchplayCompCopyWith(MatchplayComp value, $Res Function(MatchplayComp) _then) = _$MatchplayCompCopyWithImpl;
@useResult
$Res call({
 String id, String title, bool isActive, List<MatchplayRound> rounds, double handicapAllowance,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$MatchplayCompCopyWithImpl<$Res>
    implements $MatchplayCompCopyWith<$Res> {
  _$MatchplayCompCopyWithImpl(this._self, this._then);

  final MatchplayComp _self;
  final $Res Function(MatchplayComp) _then;

/// Create a copy of MatchplayComp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? isActive = null,Object? rounds = null,Object? handicapAllowance = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as List<MatchplayRound>,handicapAllowance: null == handicapAllowance ? _self.handicapAllowance : handicapAllowance // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchplayComp].
extension MatchplayCompPatterns on MatchplayComp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchplayComp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchplayComp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchplayComp value)  $default,){
final _that = this;
switch (_that) {
case _MatchplayComp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchplayComp value)?  $default,){
final _that = this;
switch (_that) {
case _MatchplayComp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  bool isActive,  List<MatchplayRound> rounds,  double handicapAllowance, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchplayComp() when $default != null:
return $default(_that.id,_that.title,_that.isActive,_that.rounds,_that.handicapAllowance,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  bool isActive,  List<MatchplayRound> rounds,  double handicapAllowance, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MatchplayComp():
return $default(_that.id,_that.title,_that.isActive,_that.rounds,_that.handicapAllowance,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  bool isActive,  List<MatchplayRound> rounds,  double handicapAllowance, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MatchplayComp() when $default != null:
return $default(_that.id,_that.title,_that.isActive,_that.rounds,_that.handicapAllowance,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchplayComp implements MatchplayComp {
  const _MatchplayComp({required this.id, required this.title, this.isActive = true, final  List<MatchplayRound> rounds = const [], this.handicapAllowance = 1.0, @TimestampConverter() required this.createdAt}): _rounds = rounds;
  factory _MatchplayComp.fromJson(Map<String, dynamic> json) => _$MatchplayCompFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  bool isActive;
 final  List<MatchplayRound> _rounds;
@override@JsonKey() List<MatchplayRound> get rounds {
  if (_rounds is EqualUnmodifiableListView) return _rounds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rounds);
}

@override@JsonKey() final  double handicapAllowance;
// Usually full difference or 90%
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of MatchplayComp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchplayCompCopyWith<_MatchplayComp> get copyWith => __$MatchplayCompCopyWithImpl<_MatchplayComp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchplayCompToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchplayComp&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._rounds, _rounds)&&(identical(other.handicapAllowance, handicapAllowance) || other.handicapAllowance == handicapAllowance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,isActive,const DeepCollectionEquality().hash(_rounds),handicapAllowance,createdAt);

@override
String toString() {
  return 'MatchplayComp(id: $id, title: $title, isActive: $isActive, rounds: $rounds, handicapAllowance: $handicapAllowance, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MatchplayCompCopyWith<$Res> implements $MatchplayCompCopyWith<$Res> {
  factory _$MatchplayCompCopyWith(_MatchplayComp value, $Res Function(_MatchplayComp) _then) = __$MatchplayCompCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, bool isActive, List<MatchplayRound> rounds, double handicapAllowance,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$MatchplayCompCopyWithImpl<$Res>
    implements _$MatchplayCompCopyWith<$Res> {
  __$MatchplayCompCopyWithImpl(this._self, this._then);

  final _MatchplayComp _self;
  final $Res Function(_MatchplayComp) _then;

/// Create a copy of MatchplayComp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? isActive = null,Object? rounds = null,Object? handicapAllowance = null,Object? createdAt = null,}) {
  return _then(_MatchplayComp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rounds: null == rounds ? _self._rounds : rounds // ignore: cast_nullable_to_non_nullable
as List<MatchplayRound>,handicapAllowance: null == handicapAllowance ? _self.handicapAllowance : handicapAllowance // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
