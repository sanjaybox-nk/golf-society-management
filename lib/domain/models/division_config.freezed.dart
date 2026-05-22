// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'division_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DivisionConfig {

/// Handicap index cut-off. Members at or below are Div 1; above are Div 2.
 double get threshold;/// When true, female members form separate Div 1 Ladies / Div 2 Ladies pools.
 bool get genderSeparated;/// Member IDs granted voluntary upgrade to Div 1.
/// Their playing HC is capped at [threshold] during scoring.
 List<String> get voluntaryDiv1MemberIds;
/// Create a copy of DivisionConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DivisionConfigCopyWith<DivisionConfig> get copyWith => _$DivisionConfigCopyWithImpl<DivisionConfig>(this as DivisionConfig, _$identity);

  /// Serializes this DivisionConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DivisionConfig&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.genderSeparated, genderSeparated) || other.genderSeparated == genderSeparated)&&const DeepCollectionEquality().equals(other.voluntaryDiv1MemberIds, voluntaryDiv1MemberIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,threshold,genderSeparated,const DeepCollectionEquality().hash(voluntaryDiv1MemberIds));

@override
String toString() {
  return 'DivisionConfig(threshold: $threshold, genderSeparated: $genderSeparated, voluntaryDiv1MemberIds: $voluntaryDiv1MemberIds)';
}


}

/// @nodoc
abstract mixin class $DivisionConfigCopyWith<$Res>  {
  factory $DivisionConfigCopyWith(DivisionConfig value, $Res Function(DivisionConfig) _then) = _$DivisionConfigCopyWithImpl;
@useResult
$Res call({
 double threshold, bool genderSeparated, List<String> voluntaryDiv1MemberIds
});




}
/// @nodoc
class _$DivisionConfigCopyWithImpl<$Res>
    implements $DivisionConfigCopyWith<$Res> {
  _$DivisionConfigCopyWithImpl(this._self, this._then);

  final DivisionConfig _self;
  final $Res Function(DivisionConfig) _then;

/// Create a copy of DivisionConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? threshold = null,Object? genderSeparated = null,Object? voluntaryDiv1MemberIds = null,}) {
  return _then(_self.copyWith(
threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as double,genderSeparated: null == genderSeparated ? _self.genderSeparated : genderSeparated // ignore: cast_nullable_to_non_nullable
as bool,voluntaryDiv1MemberIds: null == voluntaryDiv1MemberIds ? _self.voluntaryDiv1MemberIds : voluntaryDiv1MemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DivisionConfig].
extension DivisionConfigPatterns on DivisionConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DivisionConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DivisionConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DivisionConfig value)  $default,){
final _that = this;
switch (_that) {
case _DivisionConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DivisionConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DivisionConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double threshold,  bool genderSeparated,  List<String> voluntaryDiv1MemberIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DivisionConfig() when $default != null:
return $default(_that.threshold,_that.genderSeparated,_that.voluntaryDiv1MemberIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double threshold,  bool genderSeparated,  List<String> voluntaryDiv1MemberIds)  $default,) {final _that = this;
switch (_that) {
case _DivisionConfig():
return $default(_that.threshold,_that.genderSeparated,_that.voluntaryDiv1MemberIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double threshold,  bool genderSeparated,  List<String> voluntaryDiv1MemberIds)?  $default,) {final _that = this;
switch (_that) {
case _DivisionConfig() when $default != null:
return $default(_that.threshold,_that.genderSeparated,_that.voluntaryDiv1MemberIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DivisionConfig implements DivisionConfig {
  const _DivisionConfig({this.threshold = 12.0, this.genderSeparated = false, final  List<String> voluntaryDiv1MemberIds = const []}): _voluntaryDiv1MemberIds = voluntaryDiv1MemberIds;
  factory _DivisionConfig.fromJson(Map<String, dynamic> json) => _$DivisionConfigFromJson(json);

/// Handicap index cut-off. Members at or below are Div 1; above are Div 2.
@override@JsonKey() final  double threshold;
/// When true, female members form separate Div 1 Ladies / Div 2 Ladies pools.
@override@JsonKey() final  bool genderSeparated;
/// Member IDs granted voluntary upgrade to Div 1.
/// Their playing HC is capped at [threshold] during scoring.
 final  List<String> _voluntaryDiv1MemberIds;
/// Member IDs granted voluntary upgrade to Div 1.
/// Their playing HC is capped at [threshold] during scoring.
@override@JsonKey() List<String> get voluntaryDiv1MemberIds {
  if (_voluntaryDiv1MemberIds is EqualUnmodifiableListView) return _voluntaryDiv1MemberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_voluntaryDiv1MemberIds);
}


/// Create a copy of DivisionConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DivisionConfigCopyWith<_DivisionConfig> get copyWith => __$DivisionConfigCopyWithImpl<_DivisionConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DivisionConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DivisionConfig&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.genderSeparated, genderSeparated) || other.genderSeparated == genderSeparated)&&const DeepCollectionEquality().equals(other._voluntaryDiv1MemberIds, _voluntaryDiv1MemberIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,threshold,genderSeparated,const DeepCollectionEquality().hash(_voluntaryDiv1MemberIds));

@override
String toString() {
  return 'DivisionConfig(threshold: $threshold, genderSeparated: $genderSeparated, voluntaryDiv1MemberIds: $voluntaryDiv1MemberIds)';
}


}

/// @nodoc
abstract mixin class _$DivisionConfigCopyWith<$Res> implements $DivisionConfigCopyWith<$Res> {
  factory _$DivisionConfigCopyWith(_DivisionConfig value, $Res Function(_DivisionConfig) _then) = __$DivisionConfigCopyWithImpl;
@override @useResult
$Res call({
 double threshold, bool genderSeparated, List<String> voluntaryDiv1MemberIds
});




}
/// @nodoc
class __$DivisionConfigCopyWithImpl<$Res>
    implements _$DivisionConfigCopyWith<$Res> {
  __$DivisionConfigCopyWithImpl(this._self, this._then);

  final _DivisionConfig _self;
  final $Res Function(_DivisionConfig) _then;

/// Create a copy of DivisionConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? threshold = null,Object? genderSeparated = null,Object? voluntaryDiv1MemberIds = null,}) {
  return _then(_DivisionConfig(
threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as double,genderSeparated: null == genderSeparated ? _self.genderSeparated : genderSeparated // ignore: cast_nullable_to_non_nullable
as bool,voluntaryDiv1MemberIds: null == voluntaryDiv1MemberIds ? _self._voluntaryDiv1MemberIds : voluntaryDiv1MemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
