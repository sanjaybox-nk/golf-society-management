// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
LeaderboardConfig _$LeaderboardConfigFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'orderOfMerit':
          return OrderOfMeritConfig.fromJson(
            json
          );
                case 'bestOfSeries':
          return BestOfSeriesConfig.fromJson(
            json
          );
                case 'eclectic':
          return EclecticConfig.fromJson(
            json
          );
                case 'markerCounter':
          return MarkerCounterConfig.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'LeaderboardConfig',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$LeaderboardConfig {

 String get id; String get name;
/// Create a copy of LeaderboardConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardConfigCopyWith<LeaderboardConfig> get copyWith => _$LeaderboardConfigCopyWithImpl<LeaderboardConfig>(this as LeaderboardConfig, _$identity);

  /// Serializes this LeaderboardConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'LeaderboardConfig(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $LeaderboardConfigCopyWith<$Res>  {
  factory $LeaderboardConfigCopyWith(LeaderboardConfig value, $Res Function(LeaderboardConfig) _then) = _$LeaderboardConfigCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$LeaderboardConfigCopyWithImpl<$Res>
    implements $LeaderboardConfigCopyWith<$Res> {
  _$LeaderboardConfigCopyWithImpl(this._self, this._then);

  final LeaderboardConfig _self;
  final $Res Function(LeaderboardConfig) _then;

/// Create a copy of LeaderboardConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaderboardConfig].
extension LeaderboardConfigPatterns on LeaderboardConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OrderOfMeritConfig value)?  orderOfMerit,TResult Function( BestOfSeriesConfig value)?  bestOfSeries,TResult Function( EclecticConfig value)?  eclectic,TResult Function( MarkerCounterConfig value)?  markerCounter,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OrderOfMeritConfig() when orderOfMerit != null:
return orderOfMerit(_that);case BestOfSeriesConfig() when bestOfSeries != null:
return bestOfSeries(_that);case EclecticConfig() when eclectic != null:
return eclectic(_that);case MarkerCounterConfig() when markerCounter != null:
return markerCounter(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OrderOfMeritConfig value)  orderOfMerit,required TResult Function( BestOfSeriesConfig value)  bestOfSeries,required TResult Function( EclecticConfig value)  eclectic,required TResult Function( MarkerCounterConfig value)  markerCounter,}){
final _that = this;
switch (_that) {
case OrderOfMeritConfig():
return orderOfMerit(_that);case BestOfSeriesConfig():
return bestOfSeries(_that);case EclecticConfig():
return eclectic(_that);case MarkerCounterConfig():
return markerCounter(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OrderOfMeritConfig value)?  orderOfMerit,TResult? Function( BestOfSeriesConfig value)?  bestOfSeries,TResult? Function( EclecticConfig value)?  eclectic,TResult? Function( MarkerCounterConfig value)?  markerCounter,}){
final _that = this;
switch (_that) {
case OrderOfMeritConfig() when orderOfMerit != null:
return orderOfMerit(_that);case BestOfSeriesConfig() when bestOfSeries != null:
return bestOfSeries(_that);case EclecticConfig() when eclectic != null:
return eclectic(_that);case MarkerCounterConfig() when markerCounter != null:
return markerCounter(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String name,  OOMSource source,  OOMRankingBasis rankingBasis,  Map<int, int> positionPointsMap,  int appearancePoints,  int bestN)?  orderOfMerit,TResult Function( String id,  String name,  int bestN,  BestOfMetric metric,  ScoringType scoringType,  TiePolicy tiePolicy,  Map<int, int> positionPointsMap,  int appearancePoints)?  bestOfSeries,TResult Function( String id,  String name,  EclecticMetric metric,  int handicapPercentage)?  eclectic,TResult Function( String id,  String name,  Set<MarkerType> targetTypes,  HoleFilter holeFilter,  MarkerRankingMethod rankingMethod,  int bestN)?  markerCounter,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OrderOfMeritConfig() when orderOfMerit != null:
return orderOfMerit(_that.id,_that.name,_that.source,_that.rankingBasis,_that.positionPointsMap,_that.appearancePoints,_that.bestN);case BestOfSeriesConfig() when bestOfSeries != null:
return bestOfSeries(_that.id,_that.name,_that.bestN,_that.metric,_that.scoringType,_that.tiePolicy,_that.positionPointsMap,_that.appearancePoints);case EclecticConfig() when eclectic != null:
return eclectic(_that.id,_that.name,_that.metric,_that.handicapPercentage);case MarkerCounterConfig() when markerCounter != null:
return markerCounter(_that.id,_that.name,_that.targetTypes,_that.holeFilter,_that.rankingMethod,_that.bestN);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String name,  OOMSource source,  OOMRankingBasis rankingBasis,  Map<int, int> positionPointsMap,  int appearancePoints,  int bestN)  orderOfMerit,required TResult Function( String id,  String name,  int bestN,  BestOfMetric metric,  ScoringType scoringType,  TiePolicy tiePolicy,  Map<int, int> positionPointsMap,  int appearancePoints)  bestOfSeries,required TResult Function( String id,  String name,  EclecticMetric metric,  int handicapPercentage)  eclectic,required TResult Function( String id,  String name,  Set<MarkerType> targetTypes,  HoleFilter holeFilter,  MarkerRankingMethod rankingMethod,  int bestN)  markerCounter,}) {final _that = this;
switch (_that) {
case OrderOfMeritConfig():
return orderOfMerit(_that.id,_that.name,_that.source,_that.rankingBasis,_that.positionPointsMap,_that.appearancePoints,_that.bestN);case BestOfSeriesConfig():
return bestOfSeries(_that.id,_that.name,_that.bestN,_that.metric,_that.scoringType,_that.tiePolicy,_that.positionPointsMap,_that.appearancePoints);case EclecticConfig():
return eclectic(_that.id,_that.name,_that.metric,_that.handicapPercentage);case MarkerCounterConfig():
return markerCounter(_that.id,_that.name,_that.targetTypes,_that.holeFilter,_that.rankingMethod,_that.bestN);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String name,  OOMSource source,  OOMRankingBasis rankingBasis,  Map<int, int> positionPointsMap,  int appearancePoints,  int bestN)?  orderOfMerit,TResult? Function( String id,  String name,  int bestN,  BestOfMetric metric,  ScoringType scoringType,  TiePolicy tiePolicy,  Map<int, int> positionPointsMap,  int appearancePoints)?  bestOfSeries,TResult? Function( String id,  String name,  EclecticMetric metric,  int handicapPercentage)?  eclectic,TResult? Function( String id,  String name,  Set<MarkerType> targetTypes,  HoleFilter holeFilter,  MarkerRankingMethod rankingMethod,  int bestN)?  markerCounter,}) {final _that = this;
switch (_that) {
case OrderOfMeritConfig() when orderOfMerit != null:
return orderOfMerit(_that.id,_that.name,_that.source,_that.rankingBasis,_that.positionPointsMap,_that.appearancePoints,_that.bestN);case BestOfSeriesConfig() when bestOfSeries != null:
return bestOfSeries(_that.id,_that.name,_that.bestN,_that.metric,_that.scoringType,_that.tiePolicy,_that.positionPointsMap,_that.appearancePoints);case EclecticConfig() when eclectic != null:
return eclectic(_that.id,_that.name,_that.metric,_that.handicapPercentage);case MarkerCounterConfig() when markerCounter != null:
return markerCounter(_that.id,_that.name,_that.targetTypes,_that.holeFilter,_that.rankingMethod,_that.bestN);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class OrderOfMeritConfig extends LeaderboardConfig {
  const OrderOfMeritConfig({required this.id, required this.name, this.source = OOMSource.position, this.rankingBasis = OOMRankingBasis.stableford, final  Map<int, int> positionPointsMap = const {}, this.appearancePoints = 0, this.bestN = 0, final  String? $type}): _positionPointsMap = positionPointsMap,$type = $type ?? 'orderOfMerit',super._();
  factory OrderOfMeritConfig.fromJson(Map<String, dynamic> json) => _$OrderOfMeritConfigFromJson(json);

@override final  String id;
@override final  String name;
@JsonKey() final  OOMSource source;
@JsonKey() final  OOMRankingBasis rankingBasis;
 final  Map<int, int> _positionPointsMap;
@JsonKey() Map<int, int> get positionPointsMap {
  if (_positionPointsMap is EqualUnmodifiableMapView) return _positionPointsMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_positionPointsMap);
}

@JsonKey() final  int appearancePoints;
@JsonKey() final  int bestN;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of LeaderboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderOfMeritConfigCopyWith<OrderOfMeritConfig> get copyWith => _$OrderOfMeritConfigCopyWithImpl<OrderOfMeritConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderOfMeritConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderOfMeritConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.source, source) || other.source == source)&&(identical(other.rankingBasis, rankingBasis) || other.rankingBasis == rankingBasis)&&const DeepCollectionEquality().equals(other._positionPointsMap, _positionPointsMap)&&(identical(other.appearancePoints, appearancePoints) || other.appearancePoints == appearancePoints)&&(identical(other.bestN, bestN) || other.bestN == bestN));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,source,rankingBasis,const DeepCollectionEquality().hash(_positionPointsMap),appearancePoints,bestN);

@override
String toString() {
  return 'LeaderboardConfig.orderOfMerit(id: $id, name: $name, source: $source, rankingBasis: $rankingBasis, positionPointsMap: $positionPointsMap, appearancePoints: $appearancePoints, bestN: $bestN)';
}


}

/// @nodoc
abstract mixin class $OrderOfMeritConfigCopyWith<$Res> implements $LeaderboardConfigCopyWith<$Res> {
  factory $OrderOfMeritConfigCopyWith(OrderOfMeritConfig value, $Res Function(OrderOfMeritConfig) _then) = _$OrderOfMeritConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, OOMSource source, OOMRankingBasis rankingBasis, Map<int, int> positionPointsMap, int appearancePoints, int bestN
});




}
/// @nodoc
class _$OrderOfMeritConfigCopyWithImpl<$Res>
    implements $OrderOfMeritConfigCopyWith<$Res> {
  _$OrderOfMeritConfigCopyWithImpl(this._self, this._then);

  final OrderOfMeritConfig _self;
  final $Res Function(OrderOfMeritConfig) _then;

/// Create a copy of LeaderboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? source = null,Object? rankingBasis = null,Object? positionPointsMap = null,Object? appearancePoints = null,Object? bestN = null,}) {
  return _then(OrderOfMeritConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as OOMSource,rankingBasis: null == rankingBasis ? _self.rankingBasis : rankingBasis // ignore: cast_nullable_to_non_nullable
as OOMRankingBasis,positionPointsMap: null == positionPointsMap ? _self._positionPointsMap : positionPointsMap // ignore: cast_nullable_to_non_nullable
as Map<int, int>,appearancePoints: null == appearancePoints ? _self.appearancePoints : appearancePoints // ignore: cast_nullable_to_non_nullable
as int,bestN: null == bestN ? _self.bestN : bestN // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class BestOfSeriesConfig extends LeaderboardConfig {
  const BestOfSeriesConfig({required this.id, required this.name, this.bestN = 8, this.metric = BestOfMetric.stableford, this.scoringType = ScoringType.accumulative, this.tiePolicy = TiePolicy.countback, final  Map<int, int> positionPointsMap = const {}, this.appearancePoints = 0, final  String? $type}): _positionPointsMap = positionPointsMap,$type = $type ?? 'bestOfSeries',super._();
  factory BestOfSeriesConfig.fromJson(Map<String, dynamic> json) => _$BestOfSeriesConfigFromJson(json);

@override final  String id;
@override final  String name;
@JsonKey() final  int bestN;
@JsonKey() final  BestOfMetric metric;
@JsonKey() final  ScoringType scoringType;
@JsonKey() final  TiePolicy tiePolicy;
 final  Map<int, int> _positionPointsMap;
@JsonKey() Map<int, int> get positionPointsMap {
  if (_positionPointsMap is EqualUnmodifiableMapView) return _positionPointsMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_positionPointsMap);
}

@JsonKey() final  int appearancePoints;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of LeaderboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BestOfSeriesConfigCopyWith<BestOfSeriesConfig> get copyWith => _$BestOfSeriesConfigCopyWithImpl<BestOfSeriesConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BestOfSeriesConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BestOfSeriesConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.bestN, bestN) || other.bestN == bestN)&&(identical(other.metric, metric) || other.metric == metric)&&(identical(other.scoringType, scoringType) || other.scoringType == scoringType)&&(identical(other.tiePolicy, tiePolicy) || other.tiePolicy == tiePolicy)&&const DeepCollectionEquality().equals(other._positionPointsMap, _positionPointsMap)&&(identical(other.appearancePoints, appearancePoints) || other.appearancePoints == appearancePoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,bestN,metric,scoringType,tiePolicy,const DeepCollectionEquality().hash(_positionPointsMap),appearancePoints);

@override
String toString() {
  return 'LeaderboardConfig.bestOfSeries(id: $id, name: $name, bestN: $bestN, metric: $metric, scoringType: $scoringType, tiePolicy: $tiePolicy, positionPointsMap: $positionPointsMap, appearancePoints: $appearancePoints)';
}


}

/// @nodoc
abstract mixin class $BestOfSeriesConfigCopyWith<$Res> implements $LeaderboardConfigCopyWith<$Res> {
  factory $BestOfSeriesConfigCopyWith(BestOfSeriesConfig value, $Res Function(BestOfSeriesConfig) _then) = _$BestOfSeriesConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int bestN, BestOfMetric metric, ScoringType scoringType, TiePolicy tiePolicy, Map<int, int> positionPointsMap, int appearancePoints
});




}
/// @nodoc
class _$BestOfSeriesConfigCopyWithImpl<$Res>
    implements $BestOfSeriesConfigCopyWith<$Res> {
  _$BestOfSeriesConfigCopyWithImpl(this._self, this._then);

  final BestOfSeriesConfig _self;
  final $Res Function(BestOfSeriesConfig) _then;

/// Create a copy of LeaderboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? bestN = null,Object? metric = null,Object? scoringType = null,Object? tiePolicy = null,Object? positionPointsMap = null,Object? appearancePoints = null,}) {
  return _then(BestOfSeriesConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bestN: null == bestN ? _self.bestN : bestN // ignore: cast_nullable_to_non_nullable
as int,metric: null == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as BestOfMetric,scoringType: null == scoringType ? _self.scoringType : scoringType // ignore: cast_nullable_to_non_nullable
as ScoringType,tiePolicy: null == tiePolicy ? _self.tiePolicy : tiePolicy // ignore: cast_nullable_to_non_nullable
as TiePolicy,positionPointsMap: null == positionPointsMap ? _self._positionPointsMap : positionPointsMap // ignore: cast_nullable_to_non_nullable
as Map<int, int>,appearancePoints: null == appearancePoints ? _self.appearancePoints : appearancePoints // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class EclecticConfig extends LeaderboardConfig {
  const EclecticConfig({required this.id, required this.name, this.metric = EclecticMetric.strokes, this.handicapPercentage = 0, final  String? $type}): $type = $type ?? 'eclectic',super._();
  factory EclecticConfig.fromJson(Map<String, dynamic> json) => _$EclecticConfigFromJson(json);

@override final  String id;
@override final  String name;
@JsonKey() final  EclecticMetric metric;
@JsonKey() final  int handicapPercentage;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of LeaderboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EclecticConfigCopyWith<EclecticConfig> get copyWith => _$EclecticConfigCopyWithImpl<EclecticConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EclecticConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EclecticConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.metric, metric) || other.metric == metric)&&(identical(other.handicapPercentage, handicapPercentage) || other.handicapPercentage == handicapPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,metric,handicapPercentage);

@override
String toString() {
  return 'LeaderboardConfig.eclectic(id: $id, name: $name, metric: $metric, handicapPercentage: $handicapPercentage)';
}


}

/// @nodoc
abstract mixin class $EclecticConfigCopyWith<$Res> implements $LeaderboardConfigCopyWith<$Res> {
  factory $EclecticConfigCopyWith(EclecticConfig value, $Res Function(EclecticConfig) _then) = _$EclecticConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, EclecticMetric metric, int handicapPercentage
});




}
/// @nodoc
class _$EclecticConfigCopyWithImpl<$Res>
    implements $EclecticConfigCopyWith<$Res> {
  _$EclecticConfigCopyWithImpl(this._self, this._then);

  final EclecticConfig _self;
  final $Res Function(EclecticConfig) _then;

/// Create a copy of LeaderboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? metric = null,Object? handicapPercentage = null,}) {
  return _then(EclecticConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,metric: null == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as EclecticMetric,handicapPercentage: null == handicapPercentage ? _self.handicapPercentage : handicapPercentage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MarkerCounterConfig extends LeaderboardConfig {
  const MarkerCounterConfig({required this.id, required this.name, required final  Set<MarkerType> targetTypes, this.holeFilter = HoleFilter.all, this.rankingMethod = MarkerRankingMethod.count, this.bestN = 0, final  String? $type}): _targetTypes = targetTypes,$type = $type ?? 'markerCounter',super._();
  factory MarkerCounterConfig.fromJson(Map<String, dynamic> json) => _$MarkerCounterConfigFromJson(json);

@override final  String id;
@override final  String name;
 final  Set<MarkerType> _targetTypes;
 Set<MarkerType> get targetTypes {
  if (_targetTypes is EqualUnmodifiableSetView) return _targetTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_targetTypes);
}

@JsonKey() final  HoleFilter holeFilter;
@JsonKey() final  MarkerRankingMethod rankingMethod;
@JsonKey() final  int bestN;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of LeaderboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkerCounterConfigCopyWith<MarkerCounterConfig> get copyWith => _$MarkerCounterConfigCopyWithImpl<MarkerCounterConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarkerCounterConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerCounterConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._targetTypes, _targetTypes)&&(identical(other.holeFilter, holeFilter) || other.holeFilter == holeFilter)&&(identical(other.rankingMethod, rankingMethod) || other.rankingMethod == rankingMethod)&&(identical(other.bestN, bestN) || other.bestN == bestN));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_targetTypes),holeFilter,rankingMethod,bestN);

@override
String toString() {
  return 'LeaderboardConfig.markerCounter(id: $id, name: $name, targetTypes: $targetTypes, holeFilter: $holeFilter, rankingMethod: $rankingMethod, bestN: $bestN)';
}


}

/// @nodoc
abstract mixin class $MarkerCounterConfigCopyWith<$Res> implements $LeaderboardConfigCopyWith<$Res> {
  factory $MarkerCounterConfigCopyWith(MarkerCounterConfig value, $Res Function(MarkerCounterConfig) _then) = _$MarkerCounterConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Set<MarkerType> targetTypes, HoleFilter holeFilter, MarkerRankingMethod rankingMethod, int bestN
});




}
/// @nodoc
class _$MarkerCounterConfigCopyWithImpl<$Res>
    implements $MarkerCounterConfigCopyWith<$Res> {
  _$MarkerCounterConfigCopyWithImpl(this._self, this._then);

  final MarkerCounterConfig _self;
  final $Res Function(MarkerCounterConfig) _then;

/// Create a copy of LeaderboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? targetTypes = null,Object? holeFilter = null,Object? rankingMethod = null,Object? bestN = null,}) {
  return _then(MarkerCounterConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetTypes: null == targetTypes ? _self._targetTypes : targetTypes // ignore: cast_nullable_to_non_nullable
as Set<MarkerType>,holeFilter: null == holeFilter ? _self.holeFilter : holeFilter // ignore: cast_nullable_to_non_nullable
as HoleFilter,rankingMethod: null == rankingMethod ? _self.rankingMethod : rankingMethod // ignore: cast_nullable_to_non_nullable
as MarkerRankingMethod,bestN: null == bestN ? _self.bestN : bestN // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
