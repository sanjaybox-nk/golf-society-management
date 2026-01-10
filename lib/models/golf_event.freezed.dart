// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'golf_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GolfEvent {

 String get id; String get title; String get location; DateTime get date; String? get description; String? get imageUrl; DateTime? get regTime; DateTime? get teeOffTime; List<EventRegistration> get registrations;// Grouping/Tee Sheet data
 Map<String, dynamic> get grouping;// Results/Leaderboard data
 List<Map<String, dynamic>> get results;// Course configuration (Par, SI, holes)
 Map<String, dynamic> get courseConfig; List<String> get flashUpdates;
/// Create a copy of GolfEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GolfEventCopyWith<GolfEvent> get copyWith => _$GolfEventCopyWithImpl<GolfEvent>(this as GolfEvent, _$identity);

  /// Serializes this GolfEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GolfEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.location, location) || other.location == location)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.regTime, regTime) || other.regTime == regTime)&&(identical(other.teeOffTime, teeOffTime) || other.teeOffTime == teeOffTime)&&const DeepCollectionEquality().equals(other.registrations, registrations)&&const DeepCollectionEquality().equals(other.grouping, grouping)&&const DeepCollectionEquality().equals(other.results, results)&&const DeepCollectionEquality().equals(other.courseConfig, courseConfig)&&const DeepCollectionEquality().equals(other.flashUpdates, flashUpdates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,location,date,description,imageUrl,regTime,teeOffTime,const DeepCollectionEquality().hash(registrations),const DeepCollectionEquality().hash(grouping),const DeepCollectionEquality().hash(results),const DeepCollectionEquality().hash(courseConfig),const DeepCollectionEquality().hash(flashUpdates));

@override
String toString() {
  return 'GolfEvent(id: $id, title: $title, location: $location, date: $date, description: $description, imageUrl: $imageUrl, regTime: $regTime, teeOffTime: $teeOffTime, registrations: $registrations, grouping: $grouping, results: $results, courseConfig: $courseConfig, flashUpdates: $flashUpdates)';
}


}

/// @nodoc
abstract mixin class $GolfEventCopyWith<$Res>  {
  factory $GolfEventCopyWith(GolfEvent value, $Res Function(GolfEvent) _then) = _$GolfEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String location, DateTime date, String? description, String? imageUrl, DateTime? regTime, DateTime? teeOffTime, List<EventRegistration> registrations, Map<String, dynamic> grouping, List<Map<String, dynamic>> results, Map<String, dynamic> courseConfig, List<String> flashUpdates
});




}
/// @nodoc
class _$GolfEventCopyWithImpl<$Res>
    implements $GolfEventCopyWith<$Res> {
  _$GolfEventCopyWithImpl(this._self, this._then);

  final GolfEvent _self;
  final $Res Function(GolfEvent) _then;

/// Create a copy of GolfEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? location = null,Object? date = null,Object? description = freezed,Object? imageUrl = freezed,Object? regTime = freezed,Object? teeOffTime = freezed,Object? registrations = null,Object? grouping = null,Object? results = null,Object? courseConfig = null,Object? flashUpdates = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,regTime: freezed == regTime ? _self.regTime : regTime // ignore: cast_nullable_to_non_nullable
as DateTime?,teeOffTime: freezed == teeOffTime ? _self.teeOffTime : teeOffTime // ignore: cast_nullable_to_non_nullable
as DateTime?,registrations: null == registrations ? _self.registrations : registrations // ignore: cast_nullable_to_non_nullable
as List<EventRegistration>,grouping: null == grouping ? _self.grouping : grouping // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,courseConfig: null == courseConfig ? _self.courseConfig : courseConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,flashUpdates: null == flashUpdates ? _self.flashUpdates : flashUpdates // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GolfEvent].
extension GolfEventPatterns on GolfEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GolfEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GolfEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GolfEvent value)  $default,){
final _that = this;
switch (_that) {
case _GolfEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GolfEvent value)?  $default,){
final _that = this;
switch (_that) {
case _GolfEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String location,  DateTime date,  String? description,  String? imageUrl,  DateTime? regTime,  DateTime? teeOffTime,  List<EventRegistration> registrations,  Map<String, dynamic> grouping,  List<Map<String, dynamic>> results,  Map<String, dynamic> courseConfig,  List<String> flashUpdates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GolfEvent() when $default != null:
return $default(_that.id,_that.title,_that.location,_that.date,_that.description,_that.imageUrl,_that.regTime,_that.teeOffTime,_that.registrations,_that.grouping,_that.results,_that.courseConfig,_that.flashUpdates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String location,  DateTime date,  String? description,  String? imageUrl,  DateTime? regTime,  DateTime? teeOffTime,  List<EventRegistration> registrations,  Map<String, dynamic> grouping,  List<Map<String, dynamic>> results,  Map<String, dynamic> courseConfig,  List<String> flashUpdates)  $default,) {final _that = this;
switch (_that) {
case _GolfEvent():
return $default(_that.id,_that.title,_that.location,_that.date,_that.description,_that.imageUrl,_that.regTime,_that.teeOffTime,_that.registrations,_that.grouping,_that.results,_that.courseConfig,_that.flashUpdates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String location,  DateTime date,  String? description,  String? imageUrl,  DateTime? regTime,  DateTime? teeOffTime,  List<EventRegistration> registrations,  Map<String, dynamic> grouping,  List<Map<String, dynamic>> results,  Map<String, dynamic> courseConfig,  List<String> flashUpdates)?  $default,) {final _that = this;
switch (_that) {
case _GolfEvent() when $default != null:
return $default(_that.id,_that.title,_that.location,_that.date,_that.description,_that.imageUrl,_that.regTime,_that.teeOffTime,_that.registrations,_that.grouping,_that.results,_that.courseConfig,_that.flashUpdates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GolfEvent extends GolfEvent {
  const _GolfEvent({required this.id, required this.title, required this.location, required this.date, this.description, this.imageUrl, this.regTime, this.teeOffTime, final  List<EventRegistration> registrations = const [], final  Map<String, dynamic> grouping = const {}, final  List<Map<String, dynamic>> results = const [], final  Map<String, dynamic> courseConfig = const {}, final  List<String> flashUpdates = const []}): _registrations = registrations,_grouping = grouping,_results = results,_courseConfig = courseConfig,_flashUpdates = flashUpdates,super._();
  factory _GolfEvent.fromJson(Map<String, dynamic> json) => _$GolfEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String location;
@override final  DateTime date;
@override final  String? description;
@override final  String? imageUrl;
@override final  DateTime? regTime;
@override final  DateTime? teeOffTime;
 final  List<EventRegistration> _registrations;
@override@JsonKey() List<EventRegistration> get registrations {
  if (_registrations is EqualUnmodifiableListView) return _registrations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_registrations);
}

// Grouping/Tee Sheet data
 final  Map<String, dynamic> _grouping;
// Grouping/Tee Sheet data
@override@JsonKey() Map<String, dynamic> get grouping {
  if (_grouping is EqualUnmodifiableMapView) return _grouping;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_grouping);
}

// Results/Leaderboard data
 final  List<Map<String, dynamic>> _results;
// Results/Leaderboard data
@override@JsonKey() List<Map<String, dynamic>> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

// Course configuration (Par, SI, holes)
 final  Map<String, dynamic> _courseConfig;
// Course configuration (Par, SI, holes)
@override@JsonKey() Map<String, dynamic> get courseConfig {
  if (_courseConfig is EqualUnmodifiableMapView) return _courseConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_courseConfig);
}

 final  List<String> _flashUpdates;
@override@JsonKey() List<String> get flashUpdates {
  if (_flashUpdates is EqualUnmodifiableListView) return _flashUpdates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_flashUpdates);
}


/// Create a copy of GolfEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GolfEventCopyWith<_GolfEvent> get copyWith => __$GolfEventCopyWithImpl<_GolfEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GolfEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GolfEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.location, location) || other.location == location)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.regTime, regTime) || other.regTime == regTime)&&(identical(other.teeOffTime, teeOffTime) || other.teeOffTime == teeOffTime)&&const DeepCollectionEquality().equals(other._registrations, _registrations)&&const DeepCollectionEquality().equals(other._grouping, _grouping)&&const DeepCollectionEquality().equals(other._results, _results)&&const DeepCollectionEquality().equals(other._courseConfig, _courseConfig)&&const DeepCollectionEquality().equals(other._flashUpdates, _flashUpdates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,location,date,description,imageUrl,regTime,teeOffTime,const DeepCollectionEquality().hash(_registrations),const DeepCollectionEquality().hash(_grouping),const DeepCollectionEquality().hash(_results),const DeepCollectionEquality().hash(_courseConfig),const DeepCollectionEquality().hash(_flashUpdates));

@override
String toString() {
  return 'GolfEvent(id: $id, title: $title, location: $location, date: $date, description: $description, imageUrl: $imageUrl, regTime: $regTime, teeOffTime: $teeOffTime, registrations: $registrations, grouping: $grouping, results: $results, courseConfig: $courseConfig, flashUpdates: $flashUpdates)';
}


}

/// @nodoc
abstract mixin class _$GolfEventCopyWith<$Res> implements $GolfEventCopyWith<$Res> {
  factory _$GolfEventCopyWith(_GolfEvent value, $Res Function(_GolfEvent) _then) = __$GolfEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String location, DateTime date, String? description, String? imageUrl, DateTime? regTime, DateTime? teeOffTime, List<EventRegistration> registrations, Map<String, dynamic> grouping, List<Map<String, dynamic>> results, Map<String, dynamic> courseConfig, List<String> flashUpdates
});




}
/// @nodoc
class __$GolfEventCopyWithImpl<$Res>
    implements _$GolfEventCopyWith<$Res> {
  __$GolfEventCopyWithImpl(this._self, this._then);

  final _GolfEvent _self;
  final $Res Function(_GolfEvent) _then;

/// Create a copy of GolfEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? location = null,Object? date = null,Object? description = freezed,Object? imageUrl = freezed,Object? regTime = freezed,Object? teeOffTime = freezed,Object? registrations = null,Object? grouping = null,Object? results = null,Object? courseConfig = null,Object? flashUpdates = null,}) {
  return _then(_GolfEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,regTime: freezed == regTime ? _self.regTime : regTime // ignore: cast_nullable_to_non_nullable
as DateTime?,teeOffTime: freezed == teeOffTime ? _self.teeOffTime : teeOffTime // ignore: cast_nullable_to_non_nullable
as DateTime?,registrations: null == registrations ? _self._registrations : registrations // ignore: cast_nullable_to_non_nullable
as List<EventRegistration>,grouping: null == grouping ? _self._grouping : grouping // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,courseConfig: null == courseConfig ? _self._courseConfig : courseConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,flashUpdates: null == flashUpdates ? _self._flashUpdates : flashUpdates // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
