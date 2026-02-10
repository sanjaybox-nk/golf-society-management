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
mixin _$EventNote {

 String? get title; String get content; String? get imageUrl;
/// Create a copy of EventNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventNoteCopyWith<EventNote> get copyWith => _$EventNoteCopyWithImpl<EventNote>(this as EventNote, _$identity);

  /// Serializes this EventNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventNote&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,content,imageUrl);

@override
String toString() {
  return 'EventNote(title: $title, content: $content, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $EventNoteCopyWith<$Res>  {
  factory $EventNoteCopyWith(EventNote value, $Res Function(EventNote) _then) = _$EventNoteCopyWithImpl;
@useResult
$Res call({
 String? title, String content, String? imageUrl
});




}
/// @nodoc
class _$EventNoteCopyWithImpl<$Res>
    implements $EventNoteCopyWith<$Res> {
  _$EventNoteCopyWithImpl(this._self, this._then);

  final EventNote _self;
  final $Res Function(EventNote) _then;

/// Create a copy of EventNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? content = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventNote].
extension EventNotePatterns on EventNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventNote value)  $default,){
final _that = this;
switch (_that) {
case _EventNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventNote value)?  $default,){
final _that = this;
switch (_that) {
case _EventNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String content,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventNote() when $default != null:
return $default(_that.title,_that.content,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String content,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _EventNote():
return $default(_that.title,_that.content,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String content,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _EventNote() when $default != null:
return $default(_that.title,_that.content,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventNote implements EventNote {
  const _EventNote({this.title, required this.content, this.imageUrl});
  factory _EventNote.fromJson(Map<String, dynamic> json) => _$EventNoteFromJson(json);

@override final  String? title;
@override final  String content;
@override final  String? imageUrl;

/// Create a copy of EventNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventNoteCopyWith<_EventNote> get copyWith => __$EventNoteCopyWithImpl<_EventNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventNote&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,content,imageUrl);

@override
String toString() {
  return 'EventNote(title: $title, content: $content, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$EventNoteCopyWith<$Res> implements $EventNoteCopyWith<$Res> {
  factory _$EventNoteCopyWith(_EventNote value, $Res Function(_EventNote) _then) = __$EventNoteCopyWithImpl;
@override @useResult
$Res call({
 String? title, String content, String? imageUrl
});




}
/// @nodoc
class __$EventNoteCopyWithImpl<$Res>
    implements _$EventNoteCopyWith<$Res> {
  __$EventNoteCopyWithImpl(this._self, this._then);

  final _EventNote _self;
  final $Res Function(_EventNote) _then;

/// Create a copy of EventNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? content = null,Object? imageUrl = freezed,}) {
  return _then(_EventNote(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GolfEvent {

 String get id; String get title; String get seasonId;@TimestampConverter() DateTime get date; String? get description; String? get imageUrl;@OptionalTimestampConverter() DateTime? get regTime;@OptionalTimestampConverter() DateTime? get teeOffTime;@OptionalTimestampConverter() DateTime? get registrationDeadline; List<EventRegistration> get registrations;// New detailed fields
 String? get courseName; String? get courseDetails; String? get dressCode; int? get availableBuggies; int? get maxParticipants; List<String> get facilities; double? get memberCost; double? get guestCost; double? get breakfastCost; double? get lunchCost; double? get dinnerCost; double? get buggyCost; bool get hasBreakfast; bool get hasLunch; bool get hasDinner; String? get dinnerLocation; List<EventNote> get notes; List<String> get galleryUrls; bool get showRegistrationButton; int get teeOffInterval; bool get isGroupingPublished;// Multi-day support
 bool? get isMultiDay;@OptionalTimestampConverter() DateTime? get endDate;// Grouping/Tee Sheet data
 Map<String, dynamic> get grouping;// Results/Leaderboard data
 List<Map<String, dynamic>> get results;// Course configuration (Par, SI, holes)
 String? get courseId; Map<String, dynamic> get courseConfig; String? get selectedTeeName; List<String> get flashUpdates; bool get scoringForceActive; bool get isScoringLocked; bool get isStatsReleased; Map<String, dynamic> get finalizedStats; String? get secondaryTemplateId;// Reference for Match Play overlay
 EventStatus get status;
/// Create a copy of GolfEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GolfEventCopyWith<GolfEvent> get copyWith => _$GolfEventCopyWithImpl<GolfEvent>(this as GolfEvent, _$identity);

  /// Serializes this GolfEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GolfEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.regTime, regTime) || other.regTime == regTime)&&(identical(other.teeOffTime, teeOffTime) || other.teeOffTime == teeOffTime)&&(identical(other.registrationDeadline, registrationDeadline) || other.registrationDeadline == registrationDeadline)&&const DeepCollectionEquality().equals(other.registrations, registrations)&&(identical(other.courseName, courseName) || other.courseName == courseName)&&(identical(other.courseDetails, courseDetails) || other.courseDetails == courseDetails)&&(identical(other.dressCode, dressCode) || other.dressCode == dressCode)&&(identical(other.availableBuggies, availableBuggies) || other.availableBuggies == availableBuggies)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&const DeepCollectionEquality().equals(other.facilities, facilities)&&(identical(other.memberCost, memberCost) || other.memberCost == memberCost)&&(identical(other.guestCost, guestCost) || other.guestCost == guestCost)&&(identical(other.breakfastCost, breakfastCost) || other.breakfastCost == breakfastCost)&&(identical(other.lunchCost, lunchCost) || other.lunchCost == lunchCost)&&(identical(other.dinnerCost, dinnerCost) || other.dinnerCost == dinnerCost)&&(identical(other.buggyCost, buggyCost) || other.buggyCost == buggyCost)&&(identical(other.hasBreakfast, hasBreakfast) || other.hasBreakfast == hasBreakfast)&&(identical(other.hasLunch, hasLunch) || other.hasLunch == hasLunch)&&(identical(other.hasDinner, hasDinner) || other.hasDinner == hasDinner)&&(identical(other.dinnerLocation, dinnerLocation) || other.dinnerLocation == dinnerLocation)&&const DeepCollectionEquality().equals(other.notes, notes)&&const DeepCollectionEquality().equals(other.galleryUrls, galleryUrls)&&(identical(other.showRegistrationButton, showRegistrationButton) || other.showRegistrationButton == showRegistrationButton)&&(identical(other.teeOffInterval, teeOffInterval) || other.teeOffInterval == teeOffInterval)&&(identical(other.isGroupingPublished, isGroupingPublished) || other.isGroupingPublished == isGroupingPublished)&&(identical(other.isMultiDay, isMultiDay) || other.isMultiDay == isMultiDay)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.grouping, grouping)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&const DeepCollectionEquality().equals(other.courseConfig, courseConfig)&&(identical(other.selectedTeeName, selectedTeeName) || other.selectedTeeName == selectedTeeName)&&const DeepCollectionEquality().equals(other.flashUpdates, flashUpdates)&&(identical(other.scoringForceActive, scoringForceActive) || other.scoringForceActive == scoringForceActive)&&(identical(other.isScoringLocked, isScoringLocked) || other.isScoringLocked == isScoringLocked)&&(identical(other.isStatsReleased, isStatsReleased) || other.isStatsReleased == isStatsReleased)&&const DeepCollectionEquality().equals(other.finalizedStats, finalizedStats)&&(identical(other.secondaryTemplateId, secondaryTemplateId) || other.secondaryTemplateId == secondaryTemplateId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,seasonId,date,description,imageUrl,regTime,teeOffTime,registrationDeadline,const DeepCollectionEquality().hash(registrations),courseName,courseDetails,dressCode,availableBuggies,maxParticipants,const DeepCollectionEquality().hash(facilities),memberCost,guestCost,breakfastCost,lunchCost,dinnerCost,buggyCost,hasBreakfast,hasLunch,hasDinner,dinnerLocation,const DeepCollectionEquality().hash(notes),const DeepCollectionEquality().hash(galleryUrls),showRegistrationButton,teeOffInterval,isGroupingPublished,isMultiDay,endDate,const DeepCollectionEquality().hash(grouping),const DeepCollectionEquality().hash(results),courseId,const DeepCollectionEquality().hash(courseConfig),selectedTeeName,const DeepCollectionEquality().hash(flashUpdates),scoringForceActive,isScoringLocked,isStatsReleased,const DeepCollectionEquality().hash(finalizedStats),secondaryTemplateId,status]);

@override
String toString() {
  return 'GolfEvent(id: $id, title: $title, seasonId: $seasonId, date: $date, description: $description, imageUrl: $imageUrl, regTime: $regTime, teeOffTime: $teeOffTime, registrationDeadline: $registrationDeadline, registrations: $registrations, courseName: $courseName, courseDetails: $courseDetails, dressCode: $dressCode, availableBuggies: $availableBuggies, maxParticipants: $maxParticipants, facilities: $facilities, memberCost: $memberCost, guestCost: $guestCost, breakfastCost: $breakfastCost, lunchCost: $lunchCost, dinnerCost: $dinnerCost, buggyCost: $buggyCost, hasBreakfast: $hasBreakfast, hasLunch: $hasLunch, hasDinner: $hasDinner, dinnerLocation: $dinnerLocation, notes: $notes, galleryUrls: $galleryUrls, showRegistrationButton: $showRegistrationButton, teeOffInterval: $teeOffInterval, isGroupingPublished: $isGroupingPublished, isMultiDay: $isMultiDay, endDate: $endDate, grouping: $grouping, results: $results, courseId: $courseId, courseConfig: $courseConfig, selectedTeeName: $selectedTeeName, flashUpdates: $flashUpdates, scoringForceActive: $scoringForceActive, isScoringLocked: $isScoringLocked, isStatsReleased: $isStatsReleased, finalizedStats: $finalizedStats, secondaryTemplateId: $secondaryTemplateId, status: $status)';
}


}

/// @nodoc
abstract mixin class $GolfEventCopyWith<$Res>  {
  factory $GolfEventCopyWith(GolfEvent value, $Res Function(GolfEvent) _then) = _$GolfEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String seasonId,@TimestampConverter() DateTime date, String? description, String? imageUrl,@OptionalTimestampConverter() DateTime? regTime,@OptionalTimestampConverter() DateTime? teeOffTime,@OptionalTimestampConverter() DateTime? registrationDeadline, List<EventRegistration> registrations, String? courseName, String? courseDetails, String? dressCode, int? availableBuggies, int? maxParticipants, List<String> facilities, double? memberCost, double? guestCost, double? breakfastCost, double? lunchCost, double? dinnerCost, double? buggyCost, bool hasBreakfast, bool hasLunch, bool hasDinner, String? dinnerLocation, List<EventNote> notes, List<String> galleryUrls, bool showRegistrationButton, int teeOffInterval, bool isGroupingPublished, bool? isMultiDay,@OptionalTimestampConverter() DateTime? endDate, Map<String, dynamic> grouping, List<Map<String, dynamic>> results, String? courseId, Map<String, dynamic> courseConfig, String? selectedTeeName, List<String> flashUpdates, bool scoringForceActive, bool isScoringLocked, bool isStatsReleased, Map<String, dynamic> finalizedStats, String? secondaryTemplateId, EventStatus status
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? seasonId = null,Object? date = null,Object? description = freezed,Object? imageUrl = freezed,Object? regTime = freezed,Object? teeOffTime = freezed,Object? registrationDeadline = freezed,Object? registrations = null,Object? courseName = freezed,Object? courseDetails = freezed,Object? dressCode = freezed,Object? availableBuggies = freezed,Object? maxParticipants = freezed,Object? facilities = null,Object? memberCost = freezed,Object? guestCost = freezed,Object? breakfastCost = freezed,Object? lunchCost = freezed,Object? dinnerCost = freezed,Object? buggyCost = freezed,Object? hasBreakfast = null,Object? hasLunch = null,Object? hasDinner = null,Object? dinnerLocation = freezed,Object? notes = null,Object? galleryUrls = null,Object? showRegistrationButton = null,Object? teeOffInterval = null,Object? isGroupingPublished = null,Object? isMultiDay = freezed,Object? endDate = freezed,Object? grouping = null,Object? results = null,Object? courseId = freezed,Object? courseConfig = null,Object? selectedTeeName = freezed,Object? flashUpdates = null,Object? scoringForceActive = null,Object? isScoringLocked = null,Object? isStatsReleased = null,Object? finalizedStats = null,Object? secondaryTemplateId = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,regTime: freezed == regTime ? _self.regTime : regTime // ignore: cast_nullable_to_non_nullable
as DateTime?,teeOffTime: freezed == teeOffTime ? _self.teeOffTime : teeOffTime // ignore: cast_nullable_to_non_nullable
as DateTime?,registrationDeadline: freezed == registrationDeadline ? _self.registrationDeadline : registrationDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,registrations: null == registrations ? _self.registrations : registrations // ignore: cast_nullable_to_non_nullable
as List<EventRegistration>,courseName: freezed == courseName ? _self.courseName : courseName // ignore: cast_nullable_to_non_nullable
as String?,courseDetails: freezed == courseDetails ? _self.courseDetails : courseDetails // ignore: cast_nullable_to_non_nullable
as String?,dressCode: freezed == dressCode ? _self.dressCode : dressCode // ignore: cast_nullable_to_non_nullable
as String?,availableBuggies: freezed == availableBuggies ? _self.availableBuggies : availableBuggies // ignore: cast_nullable_to_non_nullable
as int?,maxParticipants: freezed == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int?,facilities: null == facilities ? _self.facilities : facilities // ignore: cast_nullable_to_non_nullable
as List<String>,memberCost: freezed == memberCost ? _self.memberCost : memberCost // ignore: cast_nullable_to_non_nullable
as double?,guestCost: freezed == guestCost ? _self.guestCost : guestCost // ignore: cast_nullable_to_non_nullable
as double?,breakfastCost: freezed == breakfastCost ? _self.breakfastCost : breakfastCost // ignore: cast_nullable_to_non_nullable
as double?,lunchCost: freezed == lunchCost ? _self.lunchCost : lunchCost // ignore: cast_nullable_to_non_nullable
as double?,dinnerCost: freezed == dinnerCost ? _self.dinnerCost : dinnerCost // ignore: cast_nullable_to_non_nullable
as double?,buggyCost: freezed == buggyCost ? _self.buggyCost : buggyCost // ignore: cast_nullable_to_non_nullable
as double?,hasBreakfast: null == hasBreakfast ? _self.hasBreakfast : hasBreakfast // ignore: cast_nullable_to_non_nullable
as bool,hasLunch: null == hasLunch ? _self.hasLunch : hasLunch // ignore: cast_nullable_to_non_nullable
as bool,hasDinner: null == hasDinner ? _self.hasDinner : hasDinner // ignore: cast_nullable_to_non_nullable
as bool,dinnerLocation: freezed == dinnerLocation ? _self.dinnerLocation : dinnerLocation // ignore: cast_nullable_to_non_nullable
as String?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<EventNote>,galleryUrls: null == galleryUrls ? _self.galleryUrls : galleryUrls // ignore: cast_nullable_to_non_nullable
as List<String>,showRegistrationButton: null == showRegistrationButton ? _self.showRegistrationButton : showRegistrationButton // ignore: cast_nullable_to_non_nullable
as bool,teeOffInterval: null == teeOffInterval ? _self.teeOffInterval : teeOffInterval // ignore: cast_nullable_to_non_nullable
as int,isGroupingPublished: null == isGroupingPublished ? _self.isGroupingPublished : isGroupingPublished // ignore: cast_nullable_to_non_nullable
as bool,isMultiDay: freezed == isMultiDay ? _self.isMultiDay : isMultiDay // ignore: cast_nullable_to_non_nullable
as bool?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,grouping: null == grouping ? _self.grouping : grouping // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,courseId: freezed == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String?,courseConfig: null == courseConfig ? _self.courseConfig : courseConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,selectedTeeName: freezed == selectedTeeName ? _self.selectedTeeName : selectedTeeName // ignore: cast_nullable_to_non_nullable
as String?,flashUpdates: null == flashUpdates ? _self.flashUpdates : flashUpdates // ignore: cast_nullable_to_non_nullable
as List<String>,scoringForceActive: null == scoringForceActive ? _self.scoringForceActive : scoringForceActive // ignore: cast_nullable_to_non_nullable
as bool,isScoringLocked: null == isScoringLocked ? _self.isScoringLocked : isScoringLocked // ignore: cast_nullable_to_non_nullable
as bool,isStatsReleased: null == isStatsReleased ? _self.isStatsReleased : isStatsReleased // ignore: cast_nullable_to_non_nullable
as bool,finalizedStats: null == finalizedStats ? _self.finalizedStats : finalizedStats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,secondaryTemplateId: freezed == secondaryTemplateId ? _self.secondaryTemplateId : secondaryTemplateId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String seasonId, @TimestampConverter()  DateTime date,  String? description,  String? imageUrl, @OptionalTimestampConverter()  DateTime? regTime, @OptionalTimestampConverter()  DateTime? teeOffTime, @OptionalTimestampConverter()  DateTime? registrationDeadline,  List<EventRegistration> registrations,  String? courseName,  String? courseDetails,  String? dressCode,  int? availableBuggies,  int? maxParticipants,  List<String> facilities,  double? memberCost,  double? guestCost,  double? breakfastCost,  double? lunchCost,  double? dinnerCost,  double? buggyCost,  bool hasBreakfast,  bool hasLunch,  bool hasDinner,  String? dinnerLocation,  List<EventNote> notes,  List<String> galleryUrls,  bool showRegistrationButton,  int teeOffInterval,  bool isGroupingPublished,  bool? isMultiDay, @OptionalTimestampConverter()  DateTime? endDate,  Map<String, dynamic> grouping,  List<Map<String, dynamic>> results,  String? courseId,  Map<String, dynamic> courseConfig,  String? selectedTeeName,  List<String> flashUpdates,  bool scoringForceActive,  bool isScoringLocked,  bool isStatsReleased,  Map<String, dynamic> finalizedStats,  String? secondaryTemplateId,  EventStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GolfEvent() when $default != null:
return $default(_that.id,_that.title,_that.seasonId,_that.date,_that.description,_that.imageUrl,_that.regTime,_that.teeOffTime,_that.registrationDeadline,_that.registrations,_that.courseName,_that.courseDetails,_that.dressCode,_that.availableBuggies,_that.maxParticipants,_that.facilities,_that.memberCost,_that.guestCost,_that.breakfastCost,_that.lunchCost,_that.dinnerCost,_that.buggyCost,_that.hasBreakfast,_that.hasLunch,_that.hasDinner,_that.dinnerLocation,_that.notes,_that.galleryUrls,_that.showRegistrationButton,_that.teeOffInterval,_that.isGroupingPublished,_that.isMultiDay,_that.endDate,_that.grouping,_that.results,_that.courseId,_that.courseConfig,_that.selectedTeeName,_that.flashUpdates,_that.scoringForceActive,_that.isScoringLocked,_that.isStatsReleased,_that.finalizedStats,_that.secondaryTemplateId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String seasonId, @TimestampConverter()  DateTime date,  String? description,  String? imageUrl, @OptionalTimestampConverter()  DateTime? regTime, @OptionalTimestampConverter()  DateTime? teeOffTime, @OptionalTimestampConverter()  DateTime? registrationDeadline,  List<EventRegistration> registrations,  String? courseName,  String? courseDetails,  String? dressCode,  int? availableBuggies,  int? maxParticipants,  List<String> facilities,  double? memberCost,  double? guestCost,  double? breakfastCost,  double? lunchCost,  double? dinnerCost,  double? buggyCost,  bool hasBreakfast,  bool hasLunch,  bool hasDinner,  String? dinnerLocation,  List<EventNote> notes,  List<String> galleryUrls,  bool showRegistrationButton,  int teeOffInterval,  bool isGroupingPublished,  bool? isMultiDay, @OptionalTimestampConverter()  DateTime? endDate,  Map<String, dynamic> grouping,  List<Map<String, dynamic>> results,  String? courseId,  Map<String, dynamic> courseConfig,  String? selectedTeeName,  List<String> flashUpdates,  bool scoringForceActive,  bool isScoringLocked,  bool isStatsReleased,  Map<String, dynamic> finalizedStats,  String? secondaryTemplateId,  EventStatus status)  $default,) {final _that = this;
switch (_that) {
case _GolfEvent():
return $default(_that.id,_that.title,_that.seasonId,_that.date,_that.description,_that.imageUrl,_that.regTime,_that.teeOffTime,_that.registrationDeadline,_that.registrations,_that.courseName,_that.courseDetails,_that.dressCode,_that.availableBuggies,_that.maxParticipants,_that.facilities,_that.memberCost,_that.guestCost,_that.breakfastCost,_that.lunchCost,_that.dinnerCost,_that.buggyCost,_that.hasBreakfast,_that.hasLunch,_that.hasDinner,_that.dinnerLocation,_that.notes,_that.galleryUrls,_that.showRegistrationButton,_that.teeOffInterval,_that.isGroupingPublished,_that.isMultiDay,_that.endDate,_that.grouping,_that.results,_that.courseId,_that.courseConfig,_that.selectedTeeName,_that.flashUpdates,_that.scoringForceActive,_that.isScoringLocked,_that.isStatsReleased,_that.finalizedStats,_that.secondaryTemplateId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String seasonId, @TimestampConverter()  DateTime date,  String? description,  String? imageUrl, @OptionalTimestampConverter()  DateTime? regTime, @OptionalTimestampConverter()  DateTime? teeOffTime, @OptionalTimestampConverter()  DateTime? registrationDeadline,  List<EventRegistration> registrations,  String? courseName,  String? courseDetails,  String? dressCode,  int? availableBuggies,  int? maxParticipants,  List<String> facilities,  double? memberCost,  double? guestCost,  double? breakfastCost,  double? lunchCost,  double? dinnerCost,  double? buggyCost,  bool hasBreakfast,  bool hasLunch,  bool hasDinner,  String? dinnerLocation,  List<EventNote> notes,  List<String> galleryUrls,  bool showRegistrationButton,  int teeOffInterval,  bool isGroupingPublished,  bool? isMultiDay, @OptionalTimestampConverter()  DateTime? endDate,  Map<String, dynamic> grouping,  List<Map<String, dynamic>> results,  String? courseId,  Map<String, dynamic> courseConfig,  String? selectedTeeName,  List<String> flashUpdates,  bool scoringForceActive,  bool isScoringLocked,  bool isStatsReleased,  Map<String, dynamic> finalizedStats,  String? secondaryTemplateId,  EventStatus status)?  $default,) {final _that = this;
switch (_that) {
case _GolfEvent() when $default != null:
return $default(_that.id,_that.title,_that.seasonId,_that.date,_that.description,_that.imageUrl,_that.regTime,_that.teeOffTime,_that.registrationDeadline,_that.registrations,_that.courseName,_that.courseDetails,_that.dressCode,_that.availableBuggies,_that.maxParticipants,_that.facilities,_that.memberCost,_that.guestCost,_that.breakfastCost,_that.lunchCost,_that.dinnerCost,_that.buggyCost,_that.hasBreakfast,_that.hasLunch,_that.hasDinner,_that.dinnerLocation,_that.notes,_that.galleryUrls,_that.showRegistrationButton,_that.teeOffInterval,_that.isGroupingPublished,_that.isMultiDay,_that.endDate,_that.grouping,_that.results,_that.courseId,_that.courseConfig,_that.selectedTeeName,_that.flashUpdates,_that.scoringForceActive,_that.isScoringLocked,_that.isStatsReleased,_that.finalizedStats,_that.secondaryTemplateId,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GolfEvent extends GolfEvent {
  const _GolfEvent({required this.id, required this.title, required this.seasonId, @TimestampConverter() required this.date, this.description, this.imageUrl, @OptionalTimestampConverter() this.regTime, @OptionalTimestampConverter() this.teeOffTime, @OptionalTimestampConverter() this.registrationDeadline, final  List<EventRegistration> registrations = const [], this.courseName, this.courseDetails, this.dressCode, this.availableBuggies, this.maxParticipants, final  List<String> facilities = const [], this.memberCost, this.guestCost, this.breakfastCost, this.lunchCost, this.dinnerCost, this.buggyCost, this.hasBreakfast = false, this.hasLunch = false, this.hasDinner = true, this.dinnerLocation, final  List<EventNote> notes = const [], final  List<String> galleryUrls = const [], this.showRegistrationButton = true, this.teeOffInterval = 10, this.isGroupingPublished = false, this.isMultiDay, @OptionalTimestampConverter() this.endDate, final  Map<String, dynamic> grouping = const {}, final  List<Map<String, dynamic>> results = const [], this.courseId, final  Map<String, dynamic> courseConfig = const {}, this.selectedTeeName, final  List<String> flashUpdates = const [], this.scoringForceActive = false, this.isScoringLocked = false, this.isStatsReleased = false, final  Map<String, dynamic> finalizedStats = const {}, this.secondaryTemplateId, this.status = EventStatus.draft}): _registrations = registrations,_facilities = facilities,_notes = notes,_galleryUrls = galleryUrls,_grouping = grouping,_results = results,_courseConfig = courseConfig,_flashUpdates = flashUpdates,_finalizedStats = finalizedStats,super._();
  factory _GolfEvent.fromJson(Map<String, dynamic> json) => _$GolfEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String seasonId;
@override@TimestampConverter() final  DateTime date;
@override final  String? description;
@override final  String? imageUrl;
@override@OptionalTimestampConverter() final  DateTime? regTime;
@override@OptionalTimestampConverter() final  DateTime? teeOffTime;
@override@OptionalTimestampConverter() final  DateTime? registrationDeadline;
 final  List<EventRegistration> _registrations;
@override@JsonKey() List<EventRegistration> get registrations {
  if (_registrations is EqualUnmodifiableListView) return _registrations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_registrations);
}

// New detailed fields
@override final  String? courseName;
@override final  String? courseDetails;
@override final  String? dressCode;
@override final  int? availableBuggies;
@override final  int? maxParticipants;
 final  List<String> _facilities;
@override@JsonKey() List<String> get facilities {
  if (_facilities is EqualUnmodifiableListView) return _facilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_facilities);
}

@override final  double? memberCost;
@override final  double? guestCost;
@override final  double? breakfastCost;
@override final  double? lunchCost;
@override final  double? dinnerCost;
@override final  double? buggyCost;
@override@JsonKey() final  bool hasBreakfast;
@override@JsonKey() final  bool hasLunch;
@override@JsonKey() final  bool hasDinner;
@override final  String? dinnerLocation;
 final  List<EventNote> _notes;
@override@JsonKey() List<EventNote> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

 final  List<String> _galleryUrls;
@override@JsonKey() List<String> get galleryUrls {
  if (_galleryUrls is EqualUnmodifiableListView) return _galleryUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_galleryUrls);
}

@override@JsonKey() final  bool showRegistrationButton;
@override@JsonKey() final  int teeOffInterval;
@override@JsonKey() final  bool isGroupingPublished;
// Multi-day support
@override final  bool? isMultiDay;
@override@OptionalTimestampConverter() final  DateTime? endDate;
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
@override final  String? courseId;
 final  Map<String, dynamic> _courseConfig;
@override@JsonKey() Map<String, dynamic> get courseConfig {
  if (_courseConfig is EqualUnmodifiableMapView) return _courseConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_courseConfig);
}

@override final  String? selectedTeeName;
 final  List<String> _flashUpdates;
@override@JsonKey() List<String> get flashUpdates {
  if (_flashUpdates is EqualUnmodifiableListView) return _flashUpdates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_flashUpdates);
}

@override@JsonKey() final  bool scoringForceActive;
@override@JsonKey() final  bool isScoringLocked;
@override@JsonKey() final  bool isStatsReleased;
 final  Map<String, dynamic> _finalizedStats;
@override@JsonKey() Map<String, dynamic> get finalizedStats {
  if (_finalizedStats is EqualUnmodifiableMapView) return _finalizedStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_finalizedStats);
}

@override final  String? secondaryTemplateId;
// Reference for Match Play overlay
@override@JsonKey() final  EventStatus status;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GolfEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.regTime, regTime) || other.regTime == regTime)&&(identical(other.teeOffTime, teeOffTime) || other.teeOffTime == teeOffTime)&&(identical(other.registrationDeadline, registrationDeadline) || other.registrationDeadline == registrationDeadline)&&const DeepCollectionEquality().equals(other._registrations, _registrations)&&(identical(other.courseName, courseName) || other.courseName == courseName)&&(identical(other.courseDetails, courseDetails) || other.courseDetails == courseDetails)&&(identical(other.dressCode, dressCode) || other.dressCode == dressCode)&&(identical(other.availableBuggies, availableBuggies) || other.availableBuggies == availableBuggies)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&const DeepCollectionEquality().equals(other._facilities, _facilities)&&(identical(other.memberCost, memberCost) || other.memberCost == memberCost)&&(identical(other.guestCost, guestCost) || other.guestCost == guestCost)&&(identical(other.breakfastCost, breakfastCost) || other.breakfastCost == breakfastCost)&&(identical(other.lunchCost, lunchCost) || other.lunchCost == lunchCost)&&(identical(other.dinnerCost, dinnerCost) || other.dinnerCost == dinnerCost)&&(identical(other.buggyCost, buggyCost) || other.buggyCost == buggyCost)&&(identical(other.hasBreakfast, hasBreakfast) || other.hasBreakfast == hasBreakfast)&&(identical(other.hasLunch, hasLunch) || other.hasLunch == hasLunch)&&(identical(other.hasDinner, hasDinner) || other.hasDinner == hasDinner)&&(identical(other.dinnerLocation, dinnerLocation) || other.dinnerLocation == dinnerLocation)&&const DeepCollectionEquality().equals(other._notes, _notes)&&const DeepCollectionEquality().equals(other._galleryUrls, _galleryUrls)&&(identical(other.showRegistrationButton, showRegistrationButton) || other.showRegistrationButton == showRegistrationButton)&&(identical(other.teeOffInterval, teeOffInterval) || other.teeOffInterval == teeOffInterval)&&(identical(other.isGroupingPublished, isGroupingPublished) || other.isGroupingPublished == isGroupingPublished)&&(identical(other.isMultiDay, isMultiDay) || other.isMultiDay == isMultiDay)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._grouping, _grouping)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&const DeepCollectionEquality().equals(other._courseConfig, _courseConfig)&&(identical(other.selectedTeeName, selectedTeeName) || other.selectedTeeName == selectedTeeName)&&const DeepCollectionEquality().equals(other._flashUpdates, _flashUpdates)&&(identical(other.scoringForceActive, scoringForceActive) || other.scoringForceActive == scoringForceActive)&&(identical(other.isScoringLocked, isScoringLocked) || other.isScoringLocked == isScoringLocked)&&(identical(other.isStatsReleased, isStatsReleased) || other.isStatsReleased == isStatsReleased)&&const DeepCollectionEquality().equals(other._finalizedStats, _finalizedStats)&&(identical(other.secondaryTemplateId, secondaryTemplateId) || other.secondaryTemplateId == secondaryTemplateId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,seasonId,date,description,imageUrl,regTime,teeOffTime,registrationDeadline,const DeepCollectionEquality().hash(_registrations),courseName,courseDetails,dressCode,availableBuggies,maxParticipants,const DeepCollectionEquality().hash(_facilities),memberCost,guestCost,breakfastCost,lunchCost,dinnerCost,buggyCost,hasBreakfast,hasLunch,hasDinner,dinnerLocation,const DeepCollectionEquality().hash(_notes),const DeepCollectionEquality().hash(_galleryUrls),showRegistrationButton,teeOffInterval,isGroupingPublished,isMultiDay,endDate,const DeepCollectionEquality().hash(_grouping),const DeepCollectionEquality().hash(_results),courseId,const DeepCollectionEquality().hash(_courseConfig),selectedTeeName,const DeepCollectionEquality().hash(_flashUpdates),scoringForceActive,isScoringLocked,isStatsReleased,const DeepCollectionEquality().hash(_finalizedStats),secondaryTemplateId,status]);

@override
String toString() {
  return 'GolfEvent(id: $id, title: $title, seasonId: $seasonId, date: $date, description: $description, imageUrl: $imageUrl, regTime: $regTime, teeOffTime: $teeOffTime, registrationDeadline: $registrationDeadline, registrations: $registrations, courseName: $courseName, courseDetails: $courseDetails, dressCode: $dressCode, availableBuggies: $availableBuggies, maxParticipants: $maxParticipants, facilities: $facilities, memberCost: $memberCost, guestCost: $guestCost, breakfastCost: $breakfastCost, lunchCost: $lunchCost, dinnerCost: $dinnerCost, buggyCost: $buggyCost, hasBreakfast: $hasBreakfast, hasLunch: $hasLunch, hasDinner: $hasDinner, dinnerLocation: $dinnerLocation, notes: $notes, galleryUrls: $galleryUrls, showRegistrationButton: $showRegistrationButton, teeOffInterval: $teeOffInterval, isGroupingPublished: $isGroupingPublished, isMultiDay: $isMultiDay, endDate: $endDate, grouping: $grouping, results: $results, courseId: $courseId, courseConfig: $courseConfig, selectedTeeName: $selectedTeeName, flashUpdates: $flashUpdates, scoringForceActive: $scoringForceActive, isScoringLocked: $isScoringLocked, isStatsReleased: $isStatsReleased, finalizedStats: $finalizedStats, secondaryTemplateId: $secondaryTemplateId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$GolfEventCopyWith<$Res> implements $GolfEventCopyWith<$Res> {
  factory _$GolfEventCopyWith(_GolfEvent value, $Res Function(_GolfEvent) _then) = __$GolfEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String seasonId,@TimestampConverter() DateTime date, String? description, String? imageUrl,@OptionalTimestampConverter() DateTime? regTime,@OptionalTimestampConverter() DateTime? teeOffTime,@OptionalTimestampConverter() DateTime? registrationDeadline, List<EventRegistration> registrations, String? courseName, String? courseDetails, String? dressCode, int? availableBuggies, int? maxParticipants, List<String> facilities, double? memberCost, double? guestCost, double? breakfastCost, double? lunchCost, double? dinnerCost, double? buggyCost, bool hasBreakfast, bool hasLunch, bool hasDinner, String? dinnerLocation, List<EventNote> notes, List<String> galleryUrls, bool showRegistrationButton, int teeOffInterval, bool isGroupingPublished, bool? isMultiDay,@OptionalTimestampConverter() DateTime? endDate, Map<String, dynamic> grouping, List<Map<String, dynamic>> results, String? courseId, Map<String, dynamic> courseConfig, String? selectedTeeName, List<String> flashUpdates, bool scoringForceActive, bool isScoringLocked, bool isStatsReleased, Map<String, dynamic> finalizedStats, String? secondaryTemplateId, EventStatus status
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? seasonId = null,Object? date = null,Object? description = freezed,Object? imageUrl = freezed,Object? regTime = freezed,Object? teeOffTime = freezed,Object? registrationDeadline = freezed,Object? registrations = null,Object? courseName = freezed,Object? courseDetails = freezed,Object? dressCode = freezed,Object? availableBuggies = freezed,Object? maxParticipants = freezed,Object? facilities = null,Object? memberCost = freezed,Object? guestCost = freezed,Object? breakfastCost = freezed,Object? lunchCost = freezed,Object? dinnerCost = freezed,Object? buggyCost = freezed,Object? hasBreakfast = null,Object? hasLunch = null,Object? hasDinner = null,Object? dinnerLocation = freezed,Object? notes = null,Object? galleryUrls = null,Object? showRegistrationButton = null,Object? teeOffInterval = null,Object? isGroupingPublished = null,Object? isMultiDay = freezed,Object? endDate = freezed,Object? grouping = null,Object? results = null,Object? courseId = freezed,Object? courseConfig = null,Object? selectedTeeName = freezed,Object? flashUpdates = null,Object? scoringForceActive = null,Object? isScoringLocked = null,Object? isStatsReleased = null,Object? finalizedStats = null,Object? secondaryTemplateId = freezed,Object? status = null,}) {
  return _then(_GolfEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,regTime: freezed == regTime ? _self.regTime : regTime // ignore: cast_nullable_to_non_nullable
as DateTime?,teeOffTime: freezed == teeOffTime ? _self.teeOffTime : teeOffTime // ignore: cast_nullable_to_non_nullable
as DateTime?,registrationDeadline: freezed == registrationDeadline ? _self.registrationDeadline : registrationDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,registrations: null == registrations ? _self._registrations : registrations // ignore: cast_nullable_to_non_nullable
as List<EventRegistration>,courseName: freezed == courseName ? _self.courseName : courseName // ignore: cast_nullable_to_non_nullable
as String?,courseDetails: freezed == courseDetails ? _self.courseDetails : courseDetails // ignore: cast_nullable_to_non_nullable
as String?,dressCode: freezed == dressCode ? _self.dressCode : dressCode // ignore: cast_nullable_to_non_nullable
as String?,availableBuggies: freezed == availableBuggies ? _self.availableBuggies : availableBuggies // ignore: cast_nullable_to_non_nullable
as int?,maxParticipants: freezed == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int?,facilities: null == facilities ? _self._facilities : facilities // ignore: cast_nullable_to_non_nullable
as List<String>,memberCost: freezed == memberCost ? _self.memberCost : memberCost // ignore: cast_nullable_to_non_nullable
as double?,guestCost: freezed == guestCost ? _self.guestCost : guestCost // ignore: cast_nullable_to_non_nullable
as double?,breakfastCost: freezed == breakfastCost ? _self.breakfastCost : breakfastCost // ignore: cast_nullable_to_non_nullable
as double?,lunchCost: freezed == lunchCost ? _self.lunchCost : lunchCost // ignore: cast_nullable_to_non_nullable
as double?,dinnerCost: freezed == dinnerCost ? _self.dinnerCost : dinnerCost // ignore: cast_nullable_to_non_nullable
as double?,buggyCost: freezed == buggyCost ? _self.buggyCost : buggyCost // ignore: cast_nullable_to_non_nullable
as double?,hasBreakfast: null == hasBreakfast ? _self.hasBreakfast : hasBreakfast // ignore: cast_nullable_to_non_nullable
as bool,hasLunch: null == hasLunch ? _self.hasLunch : hasLunch // ignore: cast_nullable_to_non_nullable
as bool,hasDinner: null == hasDinner ? _self.hasDinner : hasDinner // ignore: cast_nullable_to_non_nullable
as bool,dinnerLocation: freezed == dinnerLocation ? _self.dinnerLocation : dinnerLocation // ignore: cast_nullable_to_non_nullable
as String?,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<EventNote>,galleryUrls: null == galleryUrls ? _self._galleryUrls : galleryUrls // ignore: cast_nullable_to_non_nullable
as List<String>,showRegistrationButton: null == showRegistrationButton ? _self.showRegistrationButton : showRegistrationButton // ignore: cast_nullable_to_non_nullable
as bool,teeOffInterval: null == teeOffInterval ? _self.teeOffInterval : teeOffInterval // ignore: cast_nullable_to_non_nullable
as int,isGroupingPublished: null == isGroupingPublished ? _self.isGroupingPublished : isGroupingPublished // ignore: cast_nullable_to_non_nullable
as bool,isMultiDay: freezed == isMultiDay ? _self.isMultiDay : isMultiDay // ignore: cast_nullable_to_non_nullable
as bool?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,grouping: null == grouping ? _self._grouping : grouping // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,courseId: freezed == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String?,courseConfig: null == courseConfig ? _self._courseConfig : courseConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,selectedTeeName: freezed == selectedTeeName ? _self.selectedTeeName : selectedTeeName // ignore: cast_nullable_to_non_nullable
as String?,flashUpdates: null == flashUpdates ? _self._flashUpdates : flashUpdates // ignore: cast_nullable_to_non_nullable
as List<String>,scoringForceActive: null == scoringForceActive ? _self.scoringForceActive : scoringForceActive // ignore: cast_nullable_to_non_nullable
as bool,isScoringLocked: null == isScoringLocked ? _self.isScoringLocked : isScoringLocked // ignore: cast_nullable_to_non_nullable
as bool,isStatsReleased: null == isStatsReleased ? _self.isStatsReleased : isStatsReleased // ignore: cast_nullable_to_non_nullable
as bool,finalizedStats: null == finalizedStats ? _self._finalizedStats : finalizedStats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,secondaryTemplateId: freezed == secondaryTemplateId ? _self.secondaryTemplateId : secondaryTemplateId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,
  ));
}


}

// dart format on
