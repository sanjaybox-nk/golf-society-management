// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'competition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaxScoreConfig {

 MaxScoreType get type; int get value;
/// Create a copy of MaxScoreConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaxScoreConfigCopyWith<MaxScoreConfig> get copyWith => _$MaxScoreConfigCopyWithImpl<MaxScoreConfig>(this as MaxScoreConfig, _$identity);

  /// Serializes this MaxScoreConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaxScoreConfig&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value);

@override
String toString() {
  return 'MaxScoreConfig(type: $type, value: $value)';
}


}

/// @nodoc
abstract mixin class $MaxScoreConfigCopyWith<$Res>  {
  factory $MaxScoreConfigCopyWith(MaxScoreConfig value, $Res Function(MaxScoreConfig) _then) = _$MaxScoreConfigCopyWithImpl;
@useResult
$Res call({
 MaxScoreType type, int value
});




}
/// @nodoc
class _$MaxScoreConfigCopyWithImpl<$Res>
    implements $MaxScoreConfigCopyWith<$Res> {
  _$MaxScoreConfigCopyWithImpl(this._self, this._then);

  final MaxScoreConfig _self;
  final $Res Function(MaxScoreConfig) _then;

/// Create a copy of MaxScoreConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? value = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MaxScoreType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MaxScoreConfig].
extension MaxScoreConfigPatterns on MaxScoreConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaxScoreConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaxScoreConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaxScoreConfig value)  $default,){
final _that = this;
switch (_that) {
case _MaxScoreConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaxScoreConfig value)?  $default,){
final _that = this;
switch (_that) {
case _MaxScoreConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MaxScoreType type,  int value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaxScoreConfig() when $default != null:
return $default(_that.type,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MaxScoreType type,  int value)  $default,) {final _that = this;
switch (_that) {
case _MaxScoreConfig():
return $default(_that.type,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MaxScoreType type,  int value)?  $default,) {final _that = this;
switch (_that) {
case _MaxScoreConfig() when $default != null:
return $default(_that.type,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaxScoreConfig implements MaxScoreConfig {
  const _MaxScoreConfig({this.type = MaxScoreType.parPlusX, this.value = 5});
  factory _MaxScoreConfig.fromJson(Map<String, dynamic> json) => _$MaxScoreConfigFromJson(json);

@override@JsonKey() final  MaxScoreType type;
@override@JsonKey() final  int value;

/// Create a copy of MaxScoreConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaxScoreConfigCopyWith<_MaxScoreConfig> get copyWith => __$MaxScoreConfigCopyWithImpl<_MaxScoreConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaxScoreConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaxScoreConfig&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value);

@override
String toString() {
  return 'MaxScoreConfig(type: $type, value: $value)';
}


}

/// @nodoc
abstract mixin class _$MaxScoreConfigCopyWith<$Res> implements $MaxScoreConfigCopyWith<$Res> {
  factory _$MaxScoreConfigCopyWith(_MaxScoreConfig value, $Res Function(_MaxScoreConfig) _then) = __$MaxScoreConfigCopyWithImpl;
@override @useResult
$Res call({
 MaxScoreType type, int value
});




}
/// @nodoc
class __$MaxScoreConfigCopyWithImpl<$Res>
    implements _$MaxScoreConfigCopyWith<$Res> {
  __$MaxScoreConfigCopyWithImpl(this._self, this._then);

  final _MaxScoreConfig _self;
  final $Res Function(_MaxScoreConfig) _then;

/// Create a copy of MaxScoreConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? value = null,}) {
  return _then(_MaxScoreConfig(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MaxScoreType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CompetitionRules {

 CompetitionFormat get format; CompetitionSubtype get subtype; CompetitionMode get mode; HandicapMode get handicapMode; int get handicapCap; double get handicapAllowance; bool get useCourseAllowance; MaxScoreConfig? get maxScoreConfig; int get roundsCount; AggregationMethod get aggregation; TieBreakMethod get tieBreak; bool get holeByHoleRequired;
/// Create a copy of CompetitionRules
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompetitionRulesCopyWith<CompetitionRules> get copyWith => _$CompetitionRulesCopyWithImpl<CompetitionRules>(this as CompetitionRules, _$identity);

  /// Serializes this CompetitionRules to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompetitionRules&&(identical(other.format, format) || other.format == format)&&(identical(other.subtype, subtype) || other.subtype == subtype)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.handicapMode, handicapMode) || other.handicapMode == handicapMode)&&(identical(other.handicapCap, handicapCap) || other.handicapCap == handicapCap)&&(identical(other.handicapAllowance, handicapAllowance) || other.handicapAllowance == handicapAllowance)&&(identical(other.useCourseAllowance, useCourseAllowance) || other.useCourseAllowance == useCourseAllowance)&&(identical(other.maxScoreConfig, maxScoreConfig) || other.maxScoreConfig == maxScoreConfig)&&(identical(other.roundsCount, roundsCount) || other.roundsCount == roundsCount)&&(identical(other.aggregation, aggregation) || other.aggregation == aggregation)&&(identical(other.tieBreak, tieBreak) || other.tieBreak == tieBreak)&&(identical(other.holeByHoleRequired, holeByHoleRequired) || other.holeByHoleRequired == holeByHoleRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,subtype,mode,handicapMode,handicapCap,handicapAllowance,useCourseAllowance,maxScoreConfig,roundsCount,aggregation,tieBreak,holeByHoleRequired);

@override
String toString() {
  return 'CompetitionRules(format: $format, subtype: $subtype, mode: $mode, handicapMode: $handicapMode, handicapCap: $handicapCap, handicapAllowance: $handicapAllowance, useCourseAllowance: $useCourseAllowance, maxScoreConfig: $maxScoreConfig, roundsCount: $roundsCount, aggregation: $aggregation, tieBreak: $tieBreak, holeByHoleRequired: $holeByHoleRequired)';
}


}

/// @nodoc
abstract mixin class $CompetitionRulesCopyWith<$Res>  {
  factory $CompetitionRulesCopyWith(CompetitionRules value, $Res Function(CompetitionRules) _then) = _$CompetitionRulesCopyWithImpl;
@useResult
$Res call({
 CompetitionFormat format, CompetitionSubtype subtype, CompetitionMode mode, HandicapMode handicapMode, int handicapCap, double handicapAllowance, bool useCourseAllowance, MaxScoreConfig? maxScoreConfig, int roundsCount, AggregationMethod aggregation, TieBreakMethod tieBreak, bool holeByHoleRequired
});


$MaxScoreConfigCopyWith<$Res>? get maxScoreConfig;

}
/// @nodoc
class _$CompetitionRulesCopyWithImpl<$Res>
    implements $CompetitionRulesCopyWith<$Res> {
  _$CompetitionRulesCopyWithImpl(this._self, this._then);

  final CompetitionRules _self;
  final $Res Function(CompetitionRules) _then;

/// Create a copy of CompetitionRules
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? format = null,Object? subtype = null,Object? mode = null,Object? handicapMode = null,Object? handicapCap = null,Object? handicapAllowance = null,Object? useCourseAllowance = null,Object? maxScoreConfig = freezed,Object? roundsCount = null,Object? aggregation = null,Object? tieBreak = null,Object? holeByHoleRequired = null,}) {
  return _then(_self.copyWith(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as CompetitionFormat,subtype: null == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as CompetitionSubtype,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CompetitionMode,handicapMode: null == handicapMode ? _self.handicapMode : handicapMode // ignore: cast_nullable_to_non_nullable
as HandicapMode,handicapCap: null == handicapCap ? _self.handicapCap : handicapCap // ignore: cast_nullable_to_non_nullable
as int,handicapAllowance: null == handicapAllowance ? _self.handicapAllowance : handicapAllowance // ignore: cast_nullable_to_non_nullable
as double,useCourseAllowance: null == useCourseAllowance ? _self.useCourseAllowance : useCourseAllowance // ignore: cast_nullable_to_non_nullable
as bool,maxScoreConfig: freezed == maxScoreConfig ? _self.maxScoreConfig : maxScoreConfig // ignore: cast_nullable_to_non_nullable
as MaxScoreConfig?,roundsCount: null == roundsCount ? _self.roundsCount : roundsCount // ignore: cast_nullable_to_non_nullable
as int,aggregation: null == aggregation ? _self.aggregation : aggregation // ignore: cast_nullable_to_non_nullable
as AggregationMethod,tieBreak: null == tieBreak ? _self.tieBreak : tieBreak // ignore: cast_nullable_to_non_nullable
as TieBreakMethod,holeByHoleRequired: null == holeByHoleRequired ? _self.holeByHoleRequired : holeByHoleRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CompetitionRules
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaxScoreConfigCopyWith<$Res>? get maxScoreConfig {
    if (_self.maxScoreConfig == null) {
    return null;
  }

  return $MaxScoreConfigCopyWith<$Res>(_self.maxScoreConfig!, (value) {
    return _then(_self.copyWith(maxScoreConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [CompetitionRules].
extension CompetitionRulesPatterns on CompetitionRules {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompetitionRules value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompetitionRules() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompetitionRules value)  $default,){
final _that = this;
switch (_that) {
case _CompetitionRules():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompetitionRules value)?  $default,){
final _that = this;
switch (_that) {
case _CompetitionRules() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CompetitionFormat format,  CompetitionSubtype subtype,  CompetitionMode mode,  HandicapMode handicapMode,  int handicapCap,  double handicapAllowance,  bool useCourseAllowance,  MaxScoreConfig? maxScoreConfig,  int roundsCount,  AggregationMethod aggregation,  TieBreakMethod tieBreak,  bool holeByHoleRequired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompetitionRules() when $default != null:
return $default(_that.format,_that.subtype,_that.mode,_that.handicapMode,_that.handicapCap,_that.handicapAllowance,_that.useCourseAllowance,_that.maxScoreConfig,_that.roundsCount,_that.aggregation,_that.tieBreak,_that.holeByHoleRequired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CompetitionFormat format,  CompetitionSubtype subtype,  CompetitionMode mode,  HandicapMode handicapMode,  int handicapCap,  double handicapAllowance,  bool useCourseAllowance,  MaxScoreConfig? maxScoreConfig,  int roundsCount,  AggregationMethod aggregation,  TieBreakMethod tieBreak,  bool holeByHoleRequired)  $default,) {final _that = this;
switch (_that) {
case _CompetitionRules():
return $default(_that.format,_that.subtype,_that.mode,_that.handicapMode,_that.handicapCap,_that.handicapAllowance,_that.useCourseAllowance,_that.maxScoreConfig,_that.roundsCount,_that.aggregation,_that.tieBreak,_that.holeByHoleRequired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CompetitionFormat format,  CompetitionSubtype subtype,  CompetitionMode mode,  HandicapMode handicapMode,  int handicapCap,  double handicapAllowance,  bool useCourseAllowance,  MaxScoreConfig? maxScoreConfig,  int roundsCount,  AggregationMethod aggregation,  TieBreakMethod tieBreak,  bool holeByHoleRequired)?  $default,) {final _that = this;
switch (_that) {
case _CompetitionRules() when $default != null:
return $default(_that.format,_that.subtype,_that.mode,_that.handicapMode,_that.handicapCap,_that.handicapAllowance,_that.useCourseAllowance,_that.maxScoreConfig,_that.roundsCount,_that.aggregation,_that.tieBreak,_that.holeByHoleRequired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompetitionRules implements CompetitionRules {
  const _CompetitionRules({this.format = CompetitionFormat.stableford, this.subtype = CompetitionSubtype.none, this.mode = CompetitionMode.singles, this.handicapMode = HandicapMode.whs, this.handicapCap = 28, this.handicapAllowance = 0.95, this.useCourseAllowance = true, this.maxScoreConfig, this.roundsCount = 1, this.aggregation = AggregationMethod.totalSum, this.tieBreak = TieBreakMethod.back9, this.holeByHoleRequired = true});
  factory _CompetitionRules.fromJson(Map<String, dynamic> json) => _$CompetitionRulesFromJson(json);

@override@JsonKey() final  CompetitionFormat format;
@override@JsonKey() final  CompetitionSubtype subtype;
@override@JsonKey() final  CompetitionMode mode;
@override@JsonKey() final  HandicapMode handicapMode;
@override@JsonKey() final  int handicapCap;
@override@JsonKey() final  double handicapAllowance;
@override@JsonKey() final  bool useCourseAllowance;
@override final  MaxScoreConfig? maxScoreConfig;
@override@JsonKey() final  int roundsCount;
@override@JsonKey() final  AggregationMethod aggregation;
@override@JsonKey() final  TieBreakMethod tieBreak;
@override@JsonKey() final  bool holeByHoleRequired;

/// Create a copy of CompetitionRules
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompetitionRulesCopyWith<_CompetitionRules> get copyWith => __$CompetitionRulesCopyWithImpl<_CompetitionRules>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompetitionRulesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompetitionRules&&(identical(other.format, format) || other.format == format)&&(identical(other.subtype, subtype) || other.subtype == subtype)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.handicapMode, handicapMode) || other.handicapMode == handicapMode)&&(identical(other.handicapCap, handicapCap) || other.handicapCap == handicapCap)&&(identical(other.handicapAllowance, handicapAllowance) || other.handicapAllowance == handicapAllowance)&&(identical(other.useCourseAllowance, useCourseAllowance) || other.useCourseAllowance == useCourseAllowance)&&(identical(other.maxScoreConfig, maxScoreConfig) || other.maxScoreConfig == maxScoreConfig)&&(identical(other.roundsCount, roundsCount) || other.roundsCount == roundsCount)&&(identical(other.aggregation, aggregation) || other.aggregation == aggregation)&&(identical(other.tieBreak, tieBreak) || other.tieBreak == tieBreak)&&(identical(other.holeByHoleRequired, holeByHoleRequired) || other.holeByHoleRequired == holeByHoleRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,subtype,mode,handicapMode,handicapCap,handicapAllowance,useCourseAllowance,maxScoreConfig,roundsCount,aggregation,tieBreak,holeByHoleRequired);

@override
String toString() {
  return 'CompetitionRules(format: $format, subtype: $subtype, mode: $mode, handicapMode: $handicapMode, handicapCap: $handicapCap, handicapAllowance: $handicapAllowance, useCourseAllowance: $useCourseAllowance, maxScoreConfig: $maxScoreConfig, roundsCount: $roundsCount, aggregation: $aggregation, tieBreak: $tieBreak, holeByHoleRequired: $holeByHoleRequired)';
}


}

/// @nodoc
abstract mixin class _$CompetitionRulesCopyWith<$Res> implements $CompetitionRulesCopyWith<$Res> {
  factory _$CompetitionRulesCopyWith(_CompetitionRules value, $Res Function(_CompetitionRules) _then) = __$CompetitionRulesCopyWithImpl;
@override @useResult
$Res call({
 CompetitionFormat format, CompetitionSubtype subtype, CompetitionMode mode, HandicapMode handicapMode, int handicapCap, double handicapAllowance, bool useCourseAllowance, MaxScoreConfig? maxScoreConfig, int roundsCount, AggregationMethod aggregation, TieBreakMethod tieBreak, bool holeByHoleRequired
});


@override $MaxScoreConfigCopyWith<$Res>? get maxScoreConfig;

}
/// @nodoc
class __$CompetitionRulesCopyWithImpl<$Res>
    implements _$CompetitionRulesCopyWith<$Res> {
  __$CompetitionRulesCopyWithImpl(this._self, this._then);

  final _CompetitionRules _self;
  final $Res Function(_CompetitionRules) _then;

/// Create a copy of CompetitionRules
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? subtype = null,Object? mode = null,Object? handicapMode = null,Object? handicapCap = null,Object? handicapAllowance = null,Object? useCourseAllowance = null,Object? maxScoreConfig = freezed,Object? roundsCount = null,Object? aggregation = null,Object? tieBreak = null,Object? holeByHoleRequired = null,}) {
  return _then(_CompetitionRules(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as CompetitionFormat,subtype: null == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as CompetitionSubtype,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CompetitionMode,handicapMode: null == handicapMode ? _self.handicapMode : handicapMode // ignore: cast_nullable_to_non_nullable
as HandicapMode,handicapCap: null == handicapCap ? _self.handicapCap : handicapCap // ignore: cast_nullable_to_non_nullable
as int,handicapAllowance: null == handicapAllowance ? _self.handicapAllowance : handicapAllowance // ignore: cast_nullable_to_non_nullable
as double,useCourseAllowance: null == useCourseAllowance ? _self.useCourseAllowance : useCourseAllowance // ignore: cast_nullable_to_non_nullable
as bool,maxScoreConfig: freezed == maxScoreConfig ? _self.maxScoreConfig : maxScoreConfig // ignore: cast_nullable_to_non_nullable
as MaxScoreConfig?,roundsCount: null == roundsCount ? _self.roundsCount : roundsCount // ignore: cast_nullable_to_non_nullable
as int,aggregation: null == aggregation ? _self.aggregation : aggregation // ignore: cast_nullable_to_non_nullable
as AggregationMethod,tieBreak: null == tieBreak ? _self.tieBreak : tieBreak // ignore: cast_nullable_to_non_nullable
as TieBreakMethod,holeByHoleRequired: null == holeByHoleRequired ? _self.holeByHoleRequired : holeByHoleRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CompetitionRules
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaxScoreConfigCopyWith<$Res>? get maxScoreConfig {
    if (_self.maxScoreConfig == null) {
    return null;
  }

  return $MaxScoreConfigCopyWith<$Res>(_self.maxScoreConfig!, (value) {
    return _then(_self.copyWith(maxScoreConfig: value));
  });
}
}


/// @nodoc
mixin _$Competition {

 String get id; String? get name; String? get templateId; CompetitionType get type; CompetitionStatus get status; CompetitionRules get rules;@TimestampConverter() DateTime get startDate;@TimestampConverter() DateTime get endDate; Map<String, dynamic> get publishSettings; bool get isDirty; int? get computeVersion;@OptionalTimestampConverter() DateTime? get lastComputedAt; String? get lastComputedBy;
/// Create a copy of Competition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompetitionCopyWith<Competition> get copyWith => _$CompetitionCopyWithImpl<Competition>(this as Competition, _$identity);

  /// Serializes this Competition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Competition&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.rules, rules) || other.rules == rules)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.publishSettings, publishSettings)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.computeVersion, computeVersion) || other.computeVersion == computeVersion)&&(identical(other.lastComputedAt, lastComputedAt) || other.lastComputedAt == lastComputedAt)&&(identical(other.lastComputedBy, lastComputedBy) || other.lastComputedBy == lastComputedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,templateId,type,status,rules,startDate,endDate,const DeepCollectionEquality().hash(publishSettings),isDirty,computeVersion,lastComputedAt,lastComputedBy);

@override
String toString() {
  return 'Competition(id: $id, name: $name, templateId: $templateId, type: $type, status: $status, rules: $rules, startDate: $startDate, endDate: $endDate, publishSettings: $publishSettings, isDirty: $isDirty, computeVersion: $computeVersion, lastComputedAt: $lastComputedAt, lastComputedBy: $lastComputedBy)';
}


}

/// @nodoc
abstract mixin class $CompetitionCopyWith<$Res>  {
  factory $CompetitionCopyWith(Competition value, $Res Function(Competition) _then) = _$CompetitionCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? templateId, CompetitionType type, CompetitionStatus status, CompetitionRules rules,@TimestampConverter() DateTime startDate,@TimestampConverter() DateTime endDate, Map<String, dynamic> publishSettings, bool isDirty, int? computeVersion,@OptionalTimestampConverter() DateTime? lastComputedAt, String? lastComputedBy
});


$CompetitionRulesCopyWith<$Res> get rules;

}
/// @nodoc
class _$CompetitionCopyWithImpl<$Res>
    implements $CompetitionCopyWith<$Res> {
  _$CompetitionCopyWithImpl(this._self, this._then);

  final Competition _self;
  final $Res Function(Competition) _then;

/// Create a copy of Competition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? templateId = freezed,Object? type = null,Object? status = null,Object? rules = null,Object? startDate = null,Object? endDate = null,Object? publishSettings = null,Object? isDirty = null,Object? computeVersion = freezed,Object? lastComputedAt = freezed,Object? lastComputedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CompetitionType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CompetitionStatus,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as CompetitionRules,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,publishSettings: null == publishSettings ? _self.publishSettings : publishSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,computeVersion: freezed == computeVersion ? _self.computeVersion : computeVersion // ignore: cast_nullable_to_non_nullable
as int?,lastComputedAt: freezed == lastComputedAt ? _self.lastComputedAt : lastComputedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastComputedBy: freezed == lastComputedBy ? _self.lastComputedBy : lastComputedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Competition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionRulesCopyWith<$Res> get rules {
  
  return $CompetitionRulesCopyWith<$Res>(_self.rules, (value) {
    return _then(_self.copyWith(rules: value));
  });
}
}


/// Adds pattern-matching-related methods to [Competition].
extension CompetitionPatterns on Competition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Competition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Competition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Competition value)  $default,){
final _that = this;
switch (_that) {
case _Competition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Competition value)?  $default,){
final _that = this;
switch (_that) {
case _Competition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? templateId,  CompetitionType type,  CompetitionStatus status,  CompetitionRules rules, @TimestampConverter()  DateTime startDate, @TimestampConverter()  DateTime endDate,  Map<String, dynamic> publishSettings,  bool isDirty,  int? computeVersion, @OptionalTimestampConverter()  DateTime? lastComputedAt,  String? lastComputedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Competition() when $default != null:
return $default(_that.id,_that.name,_that.templateId,_that.type,_that.status,_that.rules,_that.startDate,_that.endDate,_that.publishSettings,_that.isDirty,_that.computeVersion,_that.lastComputedAt,_that.lastComputedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? templateId,  CompetitionType type,  CompetitionStatus status,  CompetitionRules rules, @TimestampConverter()  DateTime startDate, @TimestampConverter()  DateTime endDate,  Map<String, dynamic> publishSettings,  bool isDirty,  int? computeVersion, @OptionalTimestampConverter()  DateTime? lastComputedAt,  String? lastComputedBy)  $default,) {final _that = this;
switch (_that) {
case _Competition():
return $default(_that.id,_that.name,_that.templateId,_that.type,_that.status,_that.rules,_that.startDate,_that.endDate,_that.publishSettings,_that.isDirty,_that.computeVersion,_that.lastComputedAt,_that.lastComputedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? templateId,  CompetitionType type,  CompetitionStatus status,  CompetitionRules rules, @TimestampConverter()  DateTime startDate, @TimestampConverter()  DateTime endDate,  Map<String, dynamic> publishSettings,  bool isDirty,  int? computeVersion, @OptionalTimestampConverter()  DateTime? lastComputedAt,  String? lastComputedBy)?  $default,) {final _that = this;
switch (_that) {
case _Competition() when $default != null:
return $default(_that.id,_that.name,_that.templateId,_that.type,_that.status,_that.rules,_that.startDate,_that.endDate,_that.publishSettings,_that.isDirty,_that.computeVersion,_that.lastComputedAt,_that.lastComputedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Competition extends Competition {
  const _Competition({required this.id, this.name, this.templateId, required this.type, this.status = CompetitionStatus.draft, required this.rules, @TimestampConverter() required this.startDate, @TimestampConverter() required this.endDate, final  Map<String, dynamic> publishSettings = const {}, this.isDirty = false, this.computeVersion, @OptionalTimestampConverter() this.lastComputedAt, this.lastComputedBy}): _publishSettings = publishSettings,super._();
  factory _Competition.fromJson(Map<String, dynamic> json) => _$CompetitionFromJson(json);

@override final  String id;
@override final  String? name;
@override final  String? templateId;
@override final  CompetitionType type;
@override@JsonKey() final  CompetitionStatus status;
@override final  CompetitionRules rules;
@override@TimestampConverter() final  DateTime startDate;
@override@TimestampConverter() final  DateTime endDate;
 final  Map<String, dynamic> _publishSettings;
@override@JsonKey() Map<String, dynamic> get publishSettings {
  if (_publishSettings is EqualUnmodifiableMapView) return _publishSettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_publishSettings);
}

@override@JsonKey() final  bool isDirty;
@override final  int? computeVersion;
@override@OptionalTimestampConverter() final  DateTime? lastComputedAt;
@override final  String? lastComputedBy;

/// Create a copy of Competition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompetitionCopyWith<_Competition> get copyWith => __$CompetitionCopyWithImpl<_Competition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompetitionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Competition&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.rules, rules) || other.rules == rules)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._publishSettings, _publishSettings)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.computeVersion, computeVersion) || other.computeVersion == computeVersion)&&(identical(other.lastComputedAt, lastComputedAt) || other.lastComputedAt == lastComputedAt)&&(identical(other.lastComputedBy, lastComputedBy) || other.lastComputedBy == lastComputedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,templateId,type,status,rules,startDate,endDate,const DeepCollectionEquality().hash(_publishSettings),isDirty,computeVersion,lastComputedAt,lastComputedBy);

@override
String toString() {
  return 'Competition(id: $id, name: $name, templateId: $templateId, type: $type, status: $status, rules: $rules, startDate: $startDate, endDate: $endDate, publishSettings: $publishSettings, isDirty: $isDirty, computeVersion: $computeVersion, lastComputedAt: $lastComputedAt, lastComputedBy: $lastComputedBy)';
}


}

/// @nodoc
abstract mixin class _$CompetitionCopyWith<$Res> implements $CompetitionCopyWith<$Res> {
  factory _$CompetitionCopyWith(_Competition value, $Res Function(_Competition) _then) = __$CompetitionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? templateId, CompetitionType type, CompetitionStatus status, CompetitionRules rules,@TimestampConverter() DateTime startDate,@TimestampConverter() DateTime endDate, Map<String, dynamic> publishSettings, bool isDirty, int? computeVersion,@OptionalTimestampConverter() DateTime? lastComputedAt, String? lastComputedBy
});


@override $CompetitionRulesCopyWith<$Res> get rules;

}
/// @nodoc
class __$CompetitionCopyWithImpl<$Res>
    implements _$CompetitionCopyWith<$Res> {
  __$CompetitionCopyWithImpl(this._self, this._then);

  final _Competition _self;
  final $Res Function(_Competition) _then;

/// Create a copy of Competition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? templateId = freezed,Object? type = null,Object? status = null,Object? rules = null,Object? startDate = null,Object? endDate = null,Object? publishSettings = null,Object? isDirty = null,Object? computeVersion = freezed,Object? lastComputedAt = freezed,Object? lastComputedBy = freezed,}) {
  return _then(_Competition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CompetitionType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CompetitionStatus,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as CompetitionRules,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,publishSettings: null == publishSettings ? _self._publishSettings : publishSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,computeVersion: freezed == computeVersion ? _self.computeVersion : computeVersion // ignore: cast_nullable_to_non_nullable
as int?,lastComputedAt: freezed == lastComputedAt ? _self.lastComputedAt : lastComputedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastComputedBy: freezed == lastComputedBy ? _self.lastComputedBy : lastComputedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Competition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionRulesCopyWith<$Res> get rules {
  
  return $CompetitionRulesCopyWith<$Res>(_self.rules, (value) {
    return _then(_self.copyWith(rules: value));
  });
}
}

// dart format on
