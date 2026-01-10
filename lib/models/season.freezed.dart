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

 String get id; int get year; List<GolfEvent> get events;// Add AGM data later if needed, dynamic map for now
 Map<String, dynamic> get agmData;
/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonCopyWith<Season> get copyWith => _$SeasonCopyWithImpl<Season>(this as Season, _$identity);

  /// Serializes this Season to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Season&&(identical(other.id, id) || other.id == id)&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.events, events)&&const DeepCollectionEquality().equals(other.agmData, agmData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,year,const DeepCollectionEquality().hash(events),const DeepCollectionEquality().hash(agmData));

@override
String toString() {
  return 'Season(id: $id, year: $year, events: $events, agmData: $agmData)';
}


}

/// @nodoc
abstract mixin class $SeasonCopyWith<$Res>  {
  factory $SeasonCopyWith(Season value, $Res Function(Season) _then) = _$SeasonCopyWithImpl;
@useResult
$Res call({
 String id, int year, List<GolfEvent> events, Map<String, dynamic> agmData
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? year = null,Object? events = null,Object? agmData = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<GolfEvent>,agmData: null == agmData ? _self.agmData : agmData // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int year,  List<GolfEvent> events,  Map<String, dynamic> agmData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.id,_that.year,_that.events,_that.agmData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int year,  List<GolfEvent> events,  Map<String, dynamic> agmData)  $default,) {final _that = this;
switch (_that) {
case _Season():
return $default(_that.id,_that.year,_that.events,_that.agmData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int year,  List<GolfEvent> events,  Map<String, dynamic> agmData)?  $default,) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.id,_that.year,_that.events,_that.agmData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Season extends Season {
  const _Season({required this.id, required this.year, final  List<GolfEvent> events = const [], final  Map<String, dynamic> agmData = const {}}): _events = events,_agmData = agmData,super._();
  factory _Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

@override final  String id;
@override final  int year;
 final  List<GolfEvent> _events;
@override@JsonKey() List<GolfEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

// Add AGM data later if needed, dynamic map for now
 final  Map<String, dynamic> _agmData;
// Add AGM data later if needed, dynamic map for now
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Season&&(identical(other.id, id) || other.id == id)&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other._events, _events)&&const DeepCollectionEquality().equals(other._agmData, _agmData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,year,const DeepCollectionEquality().hash(_events),const DeepCollectionEquality().hash(_agmData));

@override
String toString() {
  return 'Season(id: $id, year: $year, events: $events, agmData: $agmData)';
}


}

/// @nodoc
abstract mixin class _$SeasonCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$SeasonCopyWith(_Season value, $Res Function(_Season) _then) = __$SeasonCopyWithImpl;
@override @useResult
$Res call({
 String id, int year, List<GolfEvent> events, Map<String, dynamic> agmData
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? year = null,Object? events = null,Object? agmData = null,}) {
  return _then(_Season(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<GolfEvent>,agmData: null == agmData ? _self._agmData : agmData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
