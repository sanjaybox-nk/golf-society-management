// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Season {

 String get id; String get name; int get year;@TimestampConverter() DateTime get startDate;@TimestampConverter() DateTime get endDate; SeasonStatus get status; bool get isCurrent; PointsMode get pointsMode; int get bestN; TiePolicy get tiePolicy; Map<String, dynamic> get participationPointsRules; Map<String, dynamic> get eclecticRules; Map<String, dynamic> get agmData;
/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonCopyWith<Season> get copyWith => _$SeasonCopyWithImpl<Season>(this as Season, _$identity);

  /// Serializes this Season to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Season&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.year, year) || other.year == year)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.pointsMode, pointsMode) || other.pointsMode == pointsMode)&&(identical(other.bestN, bestN) || other.bestN == bestN)&&(identical(other.tiePolicy, tiePolicy) || other.tiePolicy == tiePolicy)&&const DeepCollectionEquality().equals(other.participationPointsRules, participationPointsRules)&&const DeepCollectionEquality().equals(other.eclecticRules, eclecticRules)&&const DeepCollectionEquality().equals(other.agmData, agmData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,year,startDate,endDate,status,isCurrent,pointsMode,bestN,tiePolicy,const DeepCollectionEquality().hash(participationPointsRules),const DeepCollectionEquality().hash(eclecticRules),const DeepCollectionEquality().hash(agmData));

@override
String toString() {
  return 'Season(id: $id, name: $name, year: $year, startDate: $startDate, endDate: $endDate, status: $status, isCurrent: $isCurrent, pointsMode: $pointsMode, bestN: $bestN, tiePolicy: $tiePolicy, participationPointsRules: $participationPointsRules, eclecticRules: $eclecticRules, agmData: $agmData)';
}


}

/// @nodoc
abstract mixin class $SeasonCopyWith<$Res>  {
  factory $SeasonCopyWith(Season value, $Res Function(Season) _then) = _$SeasonCopyWithImpl;
@useResult
$Res call({
 String id, String name, int year,@TimestampConverter() DateTime startDate,@TimestampConverter() DateTime endDate, SeasonStatus status, bool isCurrent, PointsMode pointsMode, int bestN, TiePolicy tiePolicy, Map<String, dynamic> participationPointsRules, Map<String, dynamic> eclecticRules, Map<String, dynamic> agmData
});




}
/// @nodoc
class _$SeasonCopyWithImpl<$Res>
    implements $SeasonCopyWith<$Res> {
  _$SeasonCopyWithImpl(this._self, this._then);

  final Season _self;
  final $Res Function(Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? year = null,Object? startDate = null,Object? endDate = null,Object? status = null,Object? isCurrent = null,Object? pointsMode = null,Object? bestN = null,Object? tiePolicy = null,Object? participationPointsRules = null,Object? eclecticRules = null,Object? agmData = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SeasonStatus,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,pointsMode: null == pointsMode ? _self.pointsMode : pointsMode // ignore: cast_nullable_to_non_nullable
as PointsMode,bestN: null == bestN ? _self.bestN : bestN // ignore: cast_nullable_to_non_nullable
as int,tiePolicy: null == tiePolicy ? _self.tiePolicy : tiePolicy // ignore: cast_nullable_to_non_nullable
as TiePolicy,participationPointsRules: null == participationPointsRules ? _self.participationPointsRules : participationPointsRules // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,eclecticRules: null == eclecticRules ? _self.eclecticRules : eclecticRules // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,agmData: null == agmData ? _self.agmData : agmData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [Season].
extension SeasonPatterns on Season {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Season value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Season() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Season value)  $default,){
final _that = this;
switch (_that) {
case _Season():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Season value)?  $default,){
final _that = this;
switch (_that) {
case _Season() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int year, @TimestampConverter()  DateTime startDate, @TimestampConverter()  DateTime endDate,  SeasonStatus status,  bool isCurrent,  PointsMode pointsMode,  int bestN,  TiePolicy tiePolicy,  Map<String, dynamic> participationPointsRules,  Map<String, dynamic> eclecticRules,  Map<String, dynamic> agmData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.id,_that.name,_that.year,_that.startDate,_that.endDate,_that.status,_that.isCurrent,_that.pointsMode,_that.bestN,_that.tiePolicy,_that.participationPointsRules,_that.eclecticRules,_that.agmData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int year, @TimestampConverter()  DateTime startDate, @TimestampConverter()  DateTime endDate,  SeasonStatus status,  bool isCurrent,  PointsMode pointsMode,  int bestN,  TiePolicy tiePolicy,  Map<String, dynamic> participationPointsRules,  Map<String, dynamic> eclecticRules,  Map<String, dynamic> agmData)  $default,) {final _that = this;
switch (_that) {
case _Season():
return $default(_that.id,_that.name,_that.year,_that.startDate,_that.endDate,_that.status,_that.isCurrent,_that.pointsMode,_that.bestN,_that.tiePolicy,_that.participationPointsRules,_that.eclecticRules,_that.agmData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int year, @TimestampConverter()  DateTime startDate, @TimestampConverter()  DateTime endDate,  SeasonStatus status,  bool isCurrent,  PointsMode pointsMode,  int bestN,  TiePolicy tiePolicy,  Map<String, dynamic> participationPointsRules,  Map<String, dynamic> eclecticRules,  Map<String, dynamic> agmData)?  $default,) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.id,_that.name,_that.year,_that.startDate,_that.endDate,_that.status,_that.isCurrent,_that.pointsMode,_that.bestN,_that.tiePolicy,_that.participationPointsRules,_that.eclecticRules,_that.agmData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Season extends Season {
  const _Season({required this.id, required this.name, required this.year, @TimestampConverter() required this.startDate, @TimestampConverter() required this.endDate, this.status = SeasonStatus.active, this.isCurrent = false, this.pointsMode = PointsMode.position, this.bestN = 8, this.tiePolicy = TiePolicy.countback, final  Map<String, dynamic> participationPointsRules = const {}, final  Map<String, dynamic> eclecticRules = const {}, final  Map<String, dynamic> agmData = const {}}): _participationPointsRules = participationPointsRules,_eclecticRules = eclecticRules,_agmData = agmData,super._();
  factory _Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

@override final  String id;
@override final  String name;
@override final  int year;
@override@TimestampConverter() final  DateTime startDate;
@override@TimestampConverter() final  DateTime endDate;
@override@JsonKey() final  SeasonStatus status;
@override@JsonKey() final  bool isCurrent;
@override@JsonKey() final  PointsMode pointsMode;
@override@JsonKey() final  int bestN;
@override@JsonKey() final  TiePolicy tiePolicy;
 final  Map<String, dynamic> _participationPointsRules;
@override@JsonKey() Map<String, dynamic> get participationPointsRules {
  if (_participationPointsRules is EqualUnmodifiableMapView) return _participationPointsRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_participationPointsRules);
}

 final  Map<String, dynamic> _eclecticRules;
@override@JsonKey() Map<String, dynamic> get eclecticRules {
  if (_eclecticRules is EqualUnmodifiableMapView) return _eclecticRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_eclecticRules);
}

 final  Map<String, dynamic> _agmData;
@override@JsonKey() Map<String, dynamic> get agmData {
  if (_agmData is EqualUnmodifiableMapView) return _agmData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_agmData);
}


/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonCopyWith<_Season> get copyWith => __$SeasonCopyWithImpl<_Season>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Season&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.year, year) || other.year == year)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.pointsMode, pointsMode) || other.pointsMode == pointsMode)&&(identical(other.bestN, bestN) || other.bestN == bestN)&&(identical(other.tiePolicy, tiePolicy) || other.tiePolicy == tiePolicy)&&const DeepCollectionEquality().equals(other._participationPointsRules, _participationPointsRules)&&const DeepCollectionEquality().equals(other._eclecticRules, _eclecticRules)&&const DeepCollectionEquality().equals(other._agmData, _agmData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,year,startDate,endDate,status,isCurrent,pointsMode,bestN,tiePolicy,const DeepCollectionEquality().hash(_participationPointsRules),const DeepCollectionEquality().hash(_eclecticRules),const DeepCollectionEquality().hash(_agmData));

@override
String toString() {
  return 'Season(id: $id, name: $name, year: $year, startDate: $startDate, endDate: $endDate, status: $status, isCurrent: $isCurrent, pointsMode: $pointsMode, bestN: $bestN, tiePolicy: $tiePolicy, participationPointsRules: $participationPointsRules, eclecticRules: $eclecticRules, agmData: $agmData)';
}


}

/// @nodoc
abstract mixin class _$SeasonCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$SeasonCopyWith(_Season value, $Res Function(_Season) _then) = __$SeasonCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int year,@TimestampConverter() DateTime startDate,@TimestampConverter() DateTime endDate, SeasonStatus status, bool isCurrent, PointsMode pointsMode, int bestN, TiePolicy tiePolicy, Map<String, dynamic> participationPointsRules, Map<String, dynamic> eclecticRules, Map<String, dynamic> agmData
});




}
/// @nodoc
class __$SeasonCopyWithImpl<$Res>
    implements _$SeasonCopyWith<$Res> {
  __$SeasonCopyWithImpl(this._self, this._then);

  final _Season _self;
  final $Res Function(_Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? year = null,Object? startDate = null,Object? endDate = null,Object? status = null,Object? isCurrent = null,Object? pointsMode = null,Object? bestN = null,Object? tiePolicy = null,Object? participationPointsRules = null,Object? eclecticRules = null,Object? agmData = null,}) {
  return _then(_Season(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SeasonStatus,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,pointsMode: null == pointsMode ? _self.pointsMode : pointsMode // ignore: cast_nullable_to_non_nullable
as PointsMode,bestN: null == bestN ? _self.bestN : bestN // ignore: cast_nullable_to_non_nullable
as int,tiePolicy: null == tiePolicy ? _self.tiePolicy : tiePolicy // ignore: cast_nullable_to_non_nullable
as TiePolicy,participationPointsRules: null == participationPointsRules ? _self._participationPointsRules : participationPointsRules // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,eclecticRules: null == eclecticRules ? _self._eclecticRules : eclecticRules // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,agmData: null == agmData ? _self._agmData : agmData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
