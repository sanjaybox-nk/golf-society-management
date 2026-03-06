// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventFormState {

 bool get isLoading; bool get isSaving; String? get eventId; GolfEvent? get initialEvent;// Basic Info
 String get title; String get description; String? get imageUrl; EventType get eventType;// Logistics
 DateTime get selectedDate; TimeOfDay get selectedTime; TimeOfDay get registrationTime; DateTime? get deadlineDate; TimeOfDay? get deadlineTime; String? get selectedSeasonId; bool get isMultiDay; DateTime? get endDate; bool get showRegistrationButton; bool get isInvitational; int get teeOffInterval;// Course
 String? get selectedCourseId; String get courseName; String get courseDetails; String? get selectedTeeName; String? get selectedFemaleTeeName; String get dressCode; int? get availableBuggies; int? get maxParticipants; List<String> get facilities;// Holes (Manual Override)
 List<CourseHole> get holes; double? get rating; int? get slope;// Competition
 String? get selectedTemplateId; Competition? get eventCompetition; bool get isCustomized; List<String> get oomExcludedRoundIds;// Secondary Competition
 String? get secondaryTemplateId; Competition? get secondaryCompetition; bool get isSecondaryCustomized;// Costs
 double? get memberCost; double? get guestCost; double? get societyGreenFee; double? get buggyCost; double? get eventCost;// Meals
 bool get hasBreakfast; bool get hasLunch; bool get hasDinner; double? get breakfastCost; double? get lunchCost; double? get dinnerCost; double? get societyBreakfastCost; double? get societyLunchCost; double? get societyDinnerCost; String get dinnerLocation;// Awards
 bool get showAwards; List<EventAward> get awards;// Content
 List<EventNote> get notes;
/// Create a copy of EventFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventFormStateCopyWith<EventFormState> get copyWith => _$EventFormStateCopyWithImpl<EventFormState>(this as EventFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventFormState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.initialEvent, initialEvent) || other.initialEvent == initialEvent)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.selectedTime, selectedTime) || other.selectedTime == selectedTime)&&(identical(other.registrationTime, registrationTime) || other.registrationTime == registrationTime)&&(identical(other.deadlineDate, deadlineDate) || other.deadlineDate == deadlineDate)&&(identical(other.deadlineTime, deadlineTime) || other.deadlineTime == deadlineTime)&&(identical(other.selectedSeasonId, selectedSeasonId) || other.selectedSeasonId == selectedSeasonId)&&(identical(other.isMultiDay, isMultiDay) || other.isMultiDay == isMultiDay)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.showRegistrationButton, showRegistrationButton) || other.showRegistrationButton == showRegistrationButton)&&(identical(other.isInvitational, isInvitational) || other.isInvitational == isInvitational)&&(identical(other.teeOffInterval, teeOffInterval) || other.teeOffInterval == teeOffInterval)&&(identical(other.selectedCourseId, selectedCourseId) || other.selectedCourseId == selectedCourseId)&&(identical(other.courseName, courseName) || other.courseName == courseName)&&(identical(other.courseDetails, courseDetails) || other.courseDetails == courseDetails)&&(identical(other.selectedTeeName, selectedTeeName) || other.selectedTeeName == selectedTeeName)&&(identical(other.selectedFemaleTeeName, selectedFemaleTeeName) || other.selectedFemaleTeeName == selectedFemaleTeeName)&&(identical(other.dressCode, dressCode) || other.dressCode == dressCode)&&(identical(other.availableBuggies, availableBuggies) || other.availableBuggies == availableBuggies)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&const DeepCollectionEquality().equals(other.facilities, facilities)&&const DeepCollectionEquality().equals(other.holes, holes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.slope, slope) || other.slope == slope)&&(identical(other.selectedTemplateId, selectedTemplateId) || other.selectedTemplateId == selectedTemplateId)&&(identical(other.eventCompetition, eventCompetition) || other.eventCompetition == eventCompetition)&&(identical(other.isCustomized, isCustomized) || other.isCustomized == isCustomized)&&const DeepCollectionEquality().equals(other.oomExcludedRoundIds, oomExcludedRoundIds)&&(identical(other.secondaryTemplateId, secondaryTemplateId) || other.secondaryTemplateId == secondaryTemplateId)&&(identical(other.secondaryCompetition, secondaryCompetition) || other.secondaryCompetition == secondaryCompetition)&&(identical(other.isSecondaryCustomized, isSecondaryCustomized) || other.isSecondaryCustomized == isSecondaryCustomized)&&(identical(other.memberCost, memberCost) || other.memberCost == memberCost)&&(identical(other.guestCost, guestCost) || other.guestCost == guestCost)&&(identical(other.societyGreenFee, societyGreenFee) || other.societyGreenFee == societyGreenFee)&&(identical(other.buggyCost, buggyCost) || other.buggyCost == buggyCost)&&(identical(other.eventCost, eventCost) || other.eventCost == eventCost)&&(identical(other.hasBreakfast, hasBreakfast) || other.hasBreakfast == hasBreakfast)&&(identical(other.hasLunch, hasLunch) || other.hasLunch == hasLunch)&&(identical(other.hasDinner, hasDinner) || other.hasDinner == hasDinner)&&(identical(other.breakfastCost, breakfastCost) || other.breakfastCost == breakfastCost)&&(identical(other.lunchCost, lunchCost) || other.lunchCost == lunchCost)&&(identical(other.dinnerCost, dinnerCost) || other.dinnerCost == dinnerCost)&&(identical(other.societyBreakfastCost, societyBreakfastCost) || other.societyBreakfastCost == societyBreakfastCost)&&(identical(other.societyLunchCost, societyLunchCost) || other.societyLunchCost == societyLunchCost)&&(identical(other.societyDinnerCost, societyDinnerCost) || other.societyDinnerCost == societyDinnerCost)&&(identical(other.dinnerLocation, dinnerLocation) || other.dinnerLocation == dinnerLocation)&&(identical(other.showAwards, showAwards) || other.showAwards == showAwards)&&const DeepCollectionEquality().equals(other.awards, awards)&&const DeepCollectionEquality().equals(other.notes, notes));
}


@override
int get hashCode => Object.hashAll([runtimeType,isLoading,isSaving,eventId,initialEvent,title,description,imageUrl,eventType,selectedDate,selectedTime,registrationTime,deadlineDate,deadlineTime,selectedSeasonId,isMultiDay,endDate,showRegistrationButton,isInvitational,teeOffInterval,selectedCourseId,courseName,courseDetails,selectedTeeName,selectedFemaleTeeName,dressCode,availableBuggies,maxParticipants,const DeepCollectionEquality().hash(facilities),const DeepCollectionEquality().hash(holes),rating,slope,selectedTemplateId,eventCompetition,isCustomized,const DeepCollectionEquality().hash(oomExcludedRoundIds),secondaryTemplateId,secondaryCompetition,isSecondaryCustomized,memberCost,guestCost,societyGreenFee,buggyCost,eventCost,hasBreakfast,hasLunch,hasDinner,breakfastCost,lunchCost,dinnerCost,societyBreakfastCost,societyLunchCost,societyDinnerCost,dinnerLocation,showAwards,const DeepCollectionEquality().hash(awards),const DeepCollectionEquality().hash(notes)]);

@override
String toString() {
  return 'EventFormState(isLoading: $isLoading, isSaving: $isSaving, eventId: $eventId, initialEvent: $initialEvent, title: $title, description: $description, imageUrl: $imageUrl, eventType: $eventType, selectedDate: $selectedDate, selectedTime: $selectedTime, registrationTime: $registrationTime, deadlineDate: $deadlineDate, deadlineTime: $deadlineTime, selectedSeasonId: $selectedSeasonId, isMultiDay: $isMultiDay, endDate: $endDate, showRegistrationButton: $showRegistrationButton, isInvitational: $isInvitational, teeOffInterval: $teeOffInterval, selectedCourseId: $selectedCourseId, courseName: $courseName, courseDetails: $courseDetails, selectedTeeName: $selectedTeeName, selectedFemaleTeeName: $selectedFemaleTeeName, dressCode: $dressCode, availableBuggies: $availableBuggies, maxParticipants: $maxParticipants, facilities: $facilities, holes: $holes, rating: $rating, slope: $slope, selectedTemplateId: $selectedTemplateId, eventCompetition: $eventCompetition, isCustomized: $isCustomized, oomExcludedRoundIds: $oomExcludedRoundIds, secondaryTemplateId: $secondaryTemplateId, secondaryCompetition: $secondaryCompetition, isSecondaryCustomized: $isSecondaryCustomized, memberCost: $memberCost, guestCost: $guestCost, societyGreenFee: $societyGreenFee, buggyCost: $buggyCost, eventCost: $eventCost, hasBreakfast: $hasBreakfast, hasLunch: $hasLunch, hasDinner: $hasDinner, breakfastCost: $breakfastCost, lunchCost: $lunchCost, dinnerCost: $dinnerCost, societyBreakfastCost: $societyBreakfastCost, societyLunchCost: $societyLunchCost, societyDinnerCost: $societyDinnerCost, dinnerLocation: $dinnerLocation, showAwards: $showAwards, awards: $awards, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $EventFormStateCopyWith<$Res>  {
  factory $EventFormStateCopyWith(EventFormState value, $Res Function(EventFormState) _then) = _$EventFormStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isSaving, String? eventId, GolfEvent? initialEvent, String title, String description, String? imageUrl, EventType eventType, DateTime selectedDate, TimeOfDay selectedTime, TimeOfDay registrationTime, DateTime? deadlineDate, TimeOfDay? deadlineTime, String? selectedSeasonId, bool isMultiDay, DateTime? endDate, bool showRegistrationButton, bool isInvitational, int teeOffInterval, String? selectedCourseId, String courseName, String courseDetails, String? selectedTeeName, String? selectedFemaleTeeName, String dressCode, int? availableBuggies, int? maxParticipants, List<String> facilities, List<CourseHole> holes, double? rating, int? slope, String? selectedTemplateId, Competition? eventCompetition, bool isCustomized, List<String> oomExcludedRoundIds, String? secondaryTemplateId, Competition? secondaryCompetition, bool isSecondaryCustomized, double? memberCost, double? guestCost, double? societyGreenFee, double? buggyCost, double? eventCost, bool hasBreakfast, bool hasLunch, bool hasDinner, double? breakfastCost, double? lunchCost, double? dinnerCost, double? societyBreakfastCost, double? societyLunchCost, double? societyDinnerCost, String dinnerLocation, bool showAwards, List<EventAward> awards, List<EventNote> notes
});


$GolfEventCopyWith<$Res>? get initialEvent;$CompetitionCopyWith<$Res>? get eventCompetition;$CompetitionCopyWith<$Res>? get secondaryCompetition;

}
/// @nodoc
class _$EventFormStateCopyWithImpl<$Res>
    implements $EventFormStateCopyWith<$Res> {
  _$EventFormStateCopyWithImpl(this._self, this._then);

  final EventFormState _self;
  final $Res Function(EventFormState) _then;

/// Create a copy of EventFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isSaving = null,Object? eventId = freezed,Object? initialEvent = freezed,Object? title = null,Object? description = null,Object? imageUrl = freezed,Object? eventType = null,Object? selectedDate = null,Object? selectedTime = null,Object? registrationTime = null,Object? deadlineDate = freezed,Object? deadlineTime = freezed,Object? selectedSeasonId = freezed,Object? isMultiDay = null,Object? endDate = freezed,Object? showRegistrationButton = null,Object? isInvitational = null,Object? teeOffInterval = null,Object? selectedCourseId = freezed,Object? courseName = null,Object? courseDetails = null,Object? selectedTeeName = freezed,Object? selectedFemaleTeeName = freezed,Object? dressCode = null,Object? availableBuggies = freezed,Object? maxParticipants = freezed,Object? facilities = null,Object? holes = null,Object? rating = freezed,Object? slope = freezed,Object? selectedTemplateId = freezed,Object? eventCompetition = freezed,Object? isCustomized = null,Object? oomExcludedRoundIds = null,Object? secondaryTemplateId = freezed,Object? secondaryCompetition = freezed,Object? isSecondaryCustomized = null,Object? memberCost = freezed,Object? guestCost = freezed,Object? societyGreenFee = freezed,Object? buggyCost = freezed,Object? eventCost = freezed,Object? hasBreakfast = null,Object? hasLunch = null,Object? hasDinner = null,Object? breakfastCost = freezed,Object? lunchCost = freezed,Object? dinnerCost = freezed,Object? societyBreakfastCost = freezed,Object? societyLunchCost = freezed,Object? societyDinnerCost = freezed,Object? dinnerLocation = null,Object? showAwards = null,Object? awards = null,Object? notes = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,initialEvent: freezed == initialEvent ? _self.initialEvent : initialEvent // ignore: cast_nullable_to_non_nullable
as GolfEvent?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as EventType,selectedDate: null == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,selectedTime: null == selectedTime ? _self.selectedTime : selectedTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,registrationTime: null == registrationTime ? _self.registrationTime : registrationTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,deadlineDate: freezed == deadlineDate ? _self.deadlineDate : deadlineDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deadlineTime: freezed == deadlineTime ? _self.deadlineTime : deadlineTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,selectedSeasonId: freezed == selectedSeasonId ? _self.selectedSeasonId : selectedSeasonId // ignore: cast_nullable_to_non_nullable
as String?,isMultiDay: null == isMultiDay ? _self.isMultiDay : isMultiDay // ignore: cast_nullable_to_non_nullable
as bool,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,showRegistrationButton: null == showRegistrationButton ? _self.showRegistrationButton : showRegistrationButton // ignore: cast_nullable_to_non_nullable
as bool,isInvitational: null == isInvitational ? _self.isInvitational : isInvitational // ignore: cast_nullable_to_non_nullable
as bool,teeOffInterval: null == teeOffInterval ? _self.teeOffInterval : teeOffInterval // ignore: cast_nullable_to_non_nullable
as int,selectedCourseId: freezed == selectedCourseId ? _self.selectedCourseId : selectedCourseId // ignore: cast_nullable_to_non_nullable
as String?,courseName: null == courseName ? _self.courseName : courseName // ignore: cast_nullable_to_non_nullable
as String,courseDetails: null == courseDetails ? _self.courseDetails : courseDetails // ignore: cast_nullable_to_non_nullable
as String,selectedTeeName: freezed == selectedTeeName ? _self.selectedTeeName : selectedTeeName // ignore: cast_nullable_to_non_nullable
as String?,selectedFemaleTeeName: freezed == selectedFemaleTeeName ? _self.selectedFemaleTeeName : selectedFemaleTeeName // ignore: cast_nullable_to_non_nullable
as String?,dressCode: null == dressCode ? _self.dressCode : dressCode // ignore: cast_nullable_to_non_nullable
as String,availableBuggies: freezed == availableBuggies ? _self.availableBuggies : availableBuggies // ignore: cast_nullable_to_non_nullable
as int?,maxParticipants: freezed == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int?,facilities: null == facilities ? _self.facilities : facilities // ignore: cast_nullable_to_non_nullable
as List<String>,holes: null == holes ? _self.holes : holes // ignore: cast_nullable_to_non_nullable
as List<CourseHole>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,slope: freezed == slope ? _self.slope : slope // ignore: cast_nullable_to_non_nullable
as int?,selectedTemplateId: freezed == selectedTemplateId ? _self.selectedTemplateId : selectedTemplateId // ignore: cast_nullable_to_non_nullable
as String?,eventCompetition: freezed == eventCompetition ? _self.eventCompetition : eventCompetition // ignore: cast_nullable_to_non_nullable
as Competition?,isCustomized: null == isCustomized ? _self.isCustomized : isCustomized // ignore: cast_nullable_to_non_nullable
as bool,oomExcludedRoundIds: null == oomExcludedRoundIds ? _self.oomExcludedRoundIds : oomExcludedRoundIds // ignore: cast_nullable_to_non_nullable
as List<String>,secondaryTemplateId: freezed == secondaryTemplateId ? _self.secondaryTemplateId : secondaryTemplateId // ignore: cast_nullable_to_non_nullable
as String?,secondaryCompetition: freezed == secondaryCompetition ? _self.secondaryCompetition : secondaryCompetition // ignore: cast_nullable_to_non_nullable
as Competition?,isSecondaryCustomized: null == isSecondaryCustomized ? _self.isSecondaryCustomized : isSecondaryCustomized // ignore: cast_nullable_to_non_nullable
as bool,memberCost: freezed == memberCost ? _self.memberCost : memberCost // ignore: cast_nullable_to_non_nullable
as double?,guestCost: freezed == guestCost ? _self.guestCost : guestCost // ignore: cast_nullable_to_non_nullable
as double?,societyGreenFee: freezed == societyGreenFee ? _self.societyGreenFee : societyGreenFee // ignore: cast_nullable_to_non_nullable
as double?,buggyCost: freezed == buggyCost ? _self.buggyCost : buggyCost // ignore: cast_nullable_to_non_nullable
as double?,eventCost: freezed == eventCost ? _self.eventCost : eventCost // ignore: cast_nullable_to_non_nullable
as double?,hasBreakfast: null == hasBreakfast ? _self.hasBreakfast : hasBreakfast // ignore: cast_nullable_to_non_nullable
as bool,hasLunch: null == hasLunch ? _self.hasLunch : hasLunch // ignore: cast_nullable_to_non_nullable
as bool,hasDinner: null == hasDinner ? _self.hasDinner : hasDinner // ignore: cast_nullable_to_non_nullable
as bool,breakfastCost: freezed == breakfastCost ? _self.breakfastCost : breakfastCost // ignore: cast_nullable_to_non_nullable
as double?,lunchCost: freezed == lunchCost ? _self.lunchCost : lunchCost // ignore: cast_nullable_to_non_nullable
as double?,dinnerCost: freezed == dinnerCost ? _self.dinnerCost : dinnerCost // ignore: cast_nullable_to_non_nullable
as double?,societyBreakfastCost: freezed == societyBreakfastCost ? _self.societyBreakfastCost : societyBreakfastCost // ignore: cast_nullable_to_non_nullable
as double?,societyLunchCost: freezed == societyLunchCost ? _self.societyLunchCost : societyLunchCost // ignore: cast_nullable_to_non_nullable
as double?,societyDinnerCost: freezed == societyDinnerCost ? _self.societyDinnerCost : societyDinnerCost // ignore: cast_nullable_to_non_nullable
as double?,dinnerLocation: null == dinnerLocation ? _self.dinnerLocation : dinnerLocation // ignore: cast_nullable_to_non_nullable
as String,showAwards: null == showAwards ? _self.showAwards : showAwards // ignore: cast_nullable_to_non_nullable
as bool,awards: null == awards ? _self.awards : awards // ignore: cast_nullable_to_non_nullable
as List<EventAward>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<EventNote>,
  ));
}
/// Create a copy of EventFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GolfEventCopyWith<$Res>? get initialEvent {
    if (_self.initialEvent == null) {
    return null;
  }

  return $GolfEventCopyWith<$Res>(_self.initialEvent!, (value) {
    return _then(_self.copyWith(initialEvent: value));
  });
}/// Create a copy of EventFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionCopyWith<$Res>? get eventCompetition {
    if (_self.eventCompetition == null) {
    return null;
  }

  return $CompetitionCopyWith<$Res>(_self.eventCompetition!, (value) {
    return _then(_self.copyWith(eventCompetition: value));
  });
}/// Create a copy of EventFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionCopyWith<$Res>? get secondaryCompetition {
    if (_self.secondaryCompetition == null) {
    return null;
  }

  return $CompetitionCopyWith<$Res>(_self.secondaryCompetition!, (value) {
    return _then(_self.copyWith(secondaryCompetition: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventFormState].
extension EventFormStatePatterns on EventFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventFormState value)  $default,){
final _that = this;
switch (_that) {
case _EventFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventFormState value)?  $default,){
final _that = this;
switch (_that) {
case _EventFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isSaving,  String? eventId,  GolfEvent? initialEvent,  String title,  String description,  String? imageUrl,  EventType eventType,  DateTime selectedDate,  TimeOfDay selectedTime,  TimeOfDay registrationTime,  DateTime? deadlineDate,  TimeOfDay? deadlineTime,  String? selectedSeasonId,  bool isMultiDay,  DateTime? endDate,  bool showRegistrationButton,  bool isInvitational,  int teeOffInterval,  String? selectedCourseId,  String courseName,  String courseDetails,  String? selectedTeeName,  String? selectedFemaleTeeName,  String dressCode,  int? availableBuggies,  int? maxParticipants,  List<String> facilities,  List<CourseHole> holes,  double? rating,  int? slope,  String? selectedTemplateId,  Competition? eventCompetition,  bool isCustomized,  List<String> oomExcludedRoundIds,  String? secondaryTemplateId,  Competition? secondaryCompetition,  bool isSecondaryCustomized,  double? memberCost,  double? guestCost,  double? societyGreenFee,  double? buggyCost,  double? eventCost,  bool hasBreakfast,  bool hasLunch,  bool hasDinner,  double? breakfastCost,  double? lunchCost,  double? dinnerCost,  double? societyBreakfastCost,  double? societyLunchCost,  double? societyDinnerCost,  String dinnerLocation,  bool showAwards,  List<EventAward> awards,  List<EventNote> notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventFormState() when $default != null:
return $default(_that.isLoading,_that.isSaving,_that.eventId,_that.initialEvent,_that.title,_that.description,_that.imageUrl,_that.eventType,_that.selectedDate,_that.selectedTime,_that.registrationTime,_that.deadlineDate,_that.deadlineTime,_that.selectedSeasonId,_that.isMultiDay,_that.endDate,_that.showRegistrationButton,_that.isInvitational,_that.teeOffInterval,_that.selectedCourseId,_that.courseName,_that.courseDetails,_that.selectedTeeName,_that.selectedFemaleTeeName,_that.dressCode,_that.availableBuggies,_that.maxParticipants,_that.facilities,_that.holes,_that.rating,_that.slope,_that.selectedTemplateId,_that.eventCompetition,_that.isCustomized,_that.oomExcludedRoundIds,_that.secondaryTemplateId,_that.secondaryCompetition,_that.isSecondaryCustomized,_that.memberCost,_that.guestCost,_that.societyGreenFee,_that.buggyCost,_that.eventCost,_that.hasBreakfast,_that.hasLunch,_that.hasDinner,_that.breakfastCost,_that.lunchCost,_that.dinnerCost,_that.societyBreakfastCost,_that.societyLunchCost,_that.societyDinnerCost,_that.dinnerLocation,_that.showAwards,_that.awards,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isSaving,  String? eventId,  GolfEvent? initialEvent,  String title,  String description,  String? imageUrl,  EventType eventType,  DateTime selectedDate,  TimeOfDay selectedTime,  TimeOfDay registrationTime,  DateTime? deadlineDate,  TimeOfDay? deadlineTime,  String? selectedSeasonId,  bool isMultiDay,  DateTime? endDate,  bool showRegistrationButton,  bool isInvitational,  int teeOffInterval,  String? selectedCourseId,  String courseName,  String courseDetails,  String? selectedTeeName,  String? selectedFemaleTeeName,  String dressCode,  int? availableBuggies,  int? maxParticipants,  List<String> facilities,  List<CourseHole> holes,  double? rating,  int? slope,  String? selectedTemplateId,  Competition? eventCompetition,  bool isCustomized,  List<String> oomExcludedRoundIds,  String? secondaryTemplateId,  Competition? secondaryCompetition,  bool isSecondaryCustomized,  double? memberCost,  double? guestCost,  double? societyGreenFee,  double? buggyCost,  double? eventCost,  bool hasBreakfast,  bool hasLunch,  bool hasDinner,  double? breakfastCost,  double? lunchCost,  double? dinnerCost,  double? societyBreakfastCost,  double? societyLunchCost,  double? societyDinnerCost,  String dinnerLocation,  bool showAwards,  List<EventAward> awards,  List<EventNote> notes)  $default,) {final _that = this;
switch (_that) {
case _EventFormState():
return $default(_that.isLoading,_that.isSaving,_that.eventId,_that.initialEvent,_that.title,_that.description,_that.imageUrl,_that.eventType,_that.selectedDate,_that.selectedTime,_that.registrationTime,_that.deadlineDate,_that.deadlineTime,_that.selectedSeasonId,_that.isMultiDay,_that.endDate,_that.showRegistrationButton,_that.isInvitational,_that.teeOffInterval,_that.selectedCourseId,_that.courseName,_that.courseDetails,_that.selectedTeeName,_that.selectedFemaleTeeName,_that.dressCode,_that.availableBuggies,_that.maxParticipants,_that.facilities,_that.holes,_that.rating,_that.slope,_that.selectedTemplateId,_that.eventCompetition,_that.isCustomized,_that.oomExcludedRoundIds,_that.secondaryTemplateId,_that.secondaryCompetition,_that.isSecondaryCustomized,_that.memberCost,_that.guestCost,_that.societyGreenFee,_that.buggyCost,_that.eventCost,_that.hasBreakfast,_that.hasLunch,_that.hasDinner,_that.breakfastCost,_that.lunchCost,_that.dinnerCost,_that.societyBreakfastCost,_that.societyLunchCost,_that.societyDinnerCost,_that.dinnerLocation,_that.showAwards,_that.awards,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isSaving,  String? eventId,  GolfEvent? initialEvent,  String title,  String description,  String? imageUrl,  EventType eventType,  DateTime selectedDate,  TimeOfDay selectedTime,  TimeOfDay registrationTime,  DateTime? deadlineDate,  TimeOfDay? deadlineTime,  String? selectedSeasonId,  bool isMultiDay,  DateTime? endDate,  bool showRegistrationButton,  bool isInvitational,  int teeOffInterval,  String? selectedCourseId,  String courseName,  String courseDetails,  String? selectedTeeName,  String? selectedFemaleTeeName,  String dressCode,  int? availableBuggies,  int? maxParticipants,  List<String> facilities,  List<CourseHole> holes,  double? rating,  int? slope,  String? selectedTemplateId,  Competition? eventCompetition,  bool isCustomized,  List<String> oomExcludedRoundIds,  String? secondaryTemplateId,  Competition? secondaryCompetition,  bool isSecondaryCustomized,  double? memberCost,  double? guestCost,  double? societyGreenFee,  double? buggyCost,  double? eventCost,  bool hasBreakfast,  bool hasLunch,  bool hasDinner,  double? breakfastCost,  double? lunchCost,  double? dinnerCost,  double? societyBreakfastCost,  double? societyLunchCost,  double? societyDinnerCost,  String dinnerLocation,  bool showAwards,  List<EventAward> awards,  List<EventNote> notes)?  $default,) {final _that = this;
switch (_that) {
case _EventFormState() when $default != null:
return $default(_that.isLoading,_that.isSaving,_that.eventId,_that.initialEvent,_that.title,_that.description,_that.imageUrl,_that.eventType,_that.selectedDate,_that.selectedTime,_that.registrationTime,_that.deadlineDate,_that.deadlineTime,_that.selectedSeasonId,_that.isMultiDay,_that.endDate,_that.showRegistrationButton,_that.isInvitational,_that.teeOffInterval,_that.selectedCourseId,_that.courseName,_that.courseDetails,_that.selectedTeeName,_that.selectedFemaleTeeName,_that.dressCode,_that.availableBuggies,_that.maxParticipants,_that.facilities,_that.holes,_that.rating,_that.slope,_that.selectedTemplateId,_that.eventCompetition,_that.isCustomized,_that.oomExcludedRoundIds,_that.secondaryTemplateId,_that.secondaryCompetition,_that.isSecondaryCustomized,_that.memberCost,_that.guestCost,_that.societyGreenFee,_that.buggyCost,_that.eventCost,_that.hasBreakfast,_that.hasLunch,_that.hasDinner,_that.breakfastCost,_that.lunchCost,_that.dinnerCost,_that.societyBreakfastCost,_that.societyLunchCost,_that.societyDinnerCost,_that.dinnerLocation,_that.showAwards,_that.awards,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _EventFormState extends EventFormState {
  const _EventFormState({this.isLoading = false, this.isSaving = false, this.eventId, this.initialEvent, this.title = '', this.description = '', this.imageUrl, this.eventType = EventType.golf, required this.selectedDate, required this.selectedTime, required this.registrationTime, this.deadlineDate, this.deadlineTime, this.selectedSeasonId, this.isMultiDay = false, this.endDate, this.showRegistrationButton = true, this.isInvitational = false, this.teeOffInterval = 10, this.selectedCourseId, this.courseName = '', this.courseDetails = '', this.selectedTeeName, this.selectedFemaleTeeName, this.dressCode = '', this.availableBuggies, this.maxParticipants, final  List<String> facilities = const [], final  List<CourseHole> holes = const [], this.rating, this.slope, this.selectedTemplateId, this.eventCompetition, this.isCustomized = false, final  List<String> oomExcludedRoundIds = const [], this.secondaryTemplateId, this.secondaryCompetition, this.isSecondaryCustomized = false, this.memberCost, this.guestCost, this.societyGreenFee, this.buggyCost, this.eventCost, this.hasBreakfast = false, this.hasLunch = false, this.hasDinner = true, this.breakfastCost, this.lunchCost, this.dinnerCost, this.societyBreakfastCost, this.societyLunchCost, this.societyDinnerCost, this.dinnerLocation = '', this.showAwards = true, final  List<EventAward> awards = const [], final  List<EventNote> notes = const []}): _facilities = facilities,_holes = holes,_oomExcludedRoundIds = oomExcludedRoundIds,_awards = awards,_notes = notes,super._();
  

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isSaving;
@override final  String? eventId;
@override final  GolfEvent? initialEvent;
// Basic Info
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override final  String? imageUrl;
@override@JsonKey() final  EventType eventType;
// Logistics
@override final  DateTime selectedDate;
@override final  TimeOfDay selectedTime;
@override final  TimeOfDay registrationTime;
@override final  DateTime? deadlineDate;
@override final  TimeOfDay? deadlineTime;
@override final  String? selectedSeasonId;
@override@JsonKey() final  bool isMultiDay;
@override final  DateTime? endDate;
@override@JsonKey() final  bool showRegistrationButton;
@override@JsonKey() final  bool isInvitational;
@override@JsonKey() final  int teeOffInterval;
// Course
@override final  String? selectedCourseId;
@override@JsonKey() final  String courseName;
@override@JsonKey() final  String courseDetails;
@override final  String? selectedTeeName;
@override final  String? selectedFemaleTeeName;
@override@JsonKey() final  String dressCode;
@override final  int? availableBuggies;
@override final  int? maxParticipants;
 final  List<String> _facilities;
@override@JsonKey() List<String> get facilities {
  if (_facilities is EqualUnmodifiableListView) return _facilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_facilities);
}

// Holes (Manual Override)
 final  List<CourseHole> _holes;
// Holes (Manual Override)
@override@JsonKey() List<CourseHole> get holes {
  if (_holes is EqualUnmodifiableListView) return _holes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holes);
}

@override final  double? rating;
@override final  int? slope;
// Competition
@override final  String? selectedTemplateId;
@override final  Competition? eventCompetition;
@override@JsonKey() final  bool isCustomized;
 final  List<String> _oomExcludedRoundIds;
@override@JsonKey() List<String> get oomExcludedRoundIds {
  if (_oomExcludedRoundIds is EqualUnmodifiableListView) return _oomExcludedRoundIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_oomExcludedRoundIds);
}

// Secondary Competition
@override final  String? secondaryTemplateId;
@override final  Competition? secondaryCompetition;
@override@JsonKey() final  bool isSecondaryCustomized;
// Costs
@override final  double? memberCost;
@override final  double? guestCost;
@override final  double? societyGreenFee;
@override final  double? buggyCost;
@override final  double? eventCost;
// Meals
@override@JsonKey() final  bool hasBreakfast;
@override@JsonKey() final  bool hasLunch;
@override@JsonKey() final  bool hasDinner;
@override final  double? breakfastCost;
@override final  double? lunchCost;
@override final  double? dinnerCost;
@override final  double? societyBreakfastCost;
@override final  double? societyLunchCost;
@override final  double? societyDinnerCost;
@override@JsonKey() final  String dinnerLocation;
// Awards
@override@JsonKey() final  bool showAwards;
 final  List<EventAward> _awards;
@override@JsonKey() List<EventAward> get awards {
  if (_awards is EqualUnmodifiableListView) return _awards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_awards);
}

// Content
 final  List<EventNote> _notes;
// Content
@override@JsonKey() List<EventNote> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}


/// Create a copy of EventFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventFormStateCopyWith<_EventFormState> get copyWith => __$EventFormStateCopyWithImpl<_EventFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventFormState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.initialEvent, initialEvent) || other.initialEvent == initialEvent)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.selectedTime, selectedTime) || other.selectedTime == selectedTime)&&(identical(other.registrationTime, registrationTime) || other.registrationTime == registrationTime)&&(identical(other.deadlineDate, deadlineDate) || other.deadlineDate == deadlineDate)&&(identical(other.deadlineTime, deadlineTime) || other.deadlineTime == deadlineTime)&&(identical(other.selectedSeasonId, selectedSeasonId) || other.selectedSeasonId == selectedSeasonId)&&(identical(other.isMultiDay, isMultiDay) || other.isMultiDay == isMultiDay)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.showRegistrationButton, showRegistrationButton) || other.showRegistrationButton == showRegistrationButton)&&(identical(other.isInvitational, isInvitational) || other.isInvitational == isInvitational)&&(identical(other.teeOffInterval, teeOffInterval) || other.teeOffInterval == teeOffInterval)&&(identical(other.selectedCourseId, selectedCourseId) || other.selectedCourseId == selectedCourseId)&&(identical(other.courseName, courseName) || other.courseName == courseName)&&(identical(other.courseDetails, courseDetails) || other.courseDetails == courseDetails)&&(identical(other.selectedTeeName, selectedTeeName) || other.selectedTeeName == selectedTeeName)&&(identical(other.selectedFemaleTeeName, selectedFemaleTeeName) || other.selectedFemaleTeeName == selectedFemaleTeeName)&&(identical(other.dressCode, dressCode) || other.dressCode == dressCode)&&(identical(other.availableBuggies, availableBuggies) || other.availableBuggies == availableBuggies)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&const DeepCollectionEquality().equals(other._facilities, _facilities)&&const DeepCollectionEquality().equals(other._holes, _holes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.slope, slope) || other.slope == slope)&&(identical(other.selectedTemplateId, selectedTemplateId) || other.selectedTemplateId == selectedTemplateId)&&(identical(other.eventCompetition, eventCompetition) || other.eventCompetition == eventCompetition)&&(identical(other.isCustomized, isCustomized) || other.isCustomized == isCustomized)&&const DeepCollectionEquality().equals(other._oomExcludedRoundIds, _oomExcludedRoundIds)&&(identical(other.secondaryTemplateId, secondaryTemplateId) || other.secondaryTemplateId == secondaryTemplateId)&&(identical(other.secondaryCompetition, secondaryCompetition) || other.secondaryCompetition == secondaryCompetition)&&(identical(other.isSecondaryCustomized, isSecondaryCustomized) || other.isSecondaryCustomized == isSecondaryCustomized)&&(identical(other.memberCost, memberCost) || other.memberCost == memberCost)&&(identical(other.guestCost, guestCost) || other.guestCost == guestCost)&&(identical(other.societyGreenFee, societyGreenFee) || other.societyGreenFee == societyGreenFee)&&(identical(other.buggyCost, buggyCost) || other.buggyCost == buggyCost)&&(identical(other.eventCost, eventCost) || other.eventCost == eventCost)&&(identical(other.hasBreakfast, hasBreakfast) || other.hasBreakfast == hasBreakfast)&&(identical(other.hasLunch, hasLunch) || other.hasLunch == hasLunch)&&(identical(other.hasDinner, hasDinner) || other.hasDinner == hasDinner)&&(identical(other.breakfastCost, breakfastCost) || other.breakfastCost == breakfastCost)&&(identical(other.lunchCost, lunchCost) || other.lunchCost == lunchCost)&&(identical(other.dinnerCost, dinnerCost) || other.dinnerCost == dinnerCost)&&(identical(other.societyBreakfastCost, societyBreakfastCost) || other.societyBreakfastCost == societyBreakfastCost)&&(identical(other.societyLunchCost, societyLunchCost) || other.societyLunchCost == societyLunchCost)&&(identical(other.societyDinnerCost, societyDinnerCost) || other.societyDinnerCost == societyDinnerCost)&&(identical(other.dinnerLocation, dinnerLocation) || other.dinnerLocation == dinnerLocation)&&(identical(other.showAwards, showAwards) || other.showAwards == showAwards)&&const DeepCollectionEquality().equals(other._awards, _awards)&&const DeepCollectionEquality().equals(other._notes, _notes));
}


@override
int get hashCode => Object.hashAll([runtimeType,isLoading,isSaving,eventId,initialEvent,title,description,imageUrl,eventType,selectedDate,selectedTime,registrationTime,deadlineDate,deadlineTime,selectedSeasonId,isMultiDay,endDate,showRegistrationButton,isInvitational,teeOffInterval,selectedCourseId,courseName,courseDetails,selectedTeeName,selectedFemaleTeeName,dressCode,availableBuggies,maxParticipants,const DeepCollectionEquality().hash(_facilities),const DeepCollectionEquality().hash(_holes),rating,slope,selectedTemplateId,eventCompetition,isCustomized,const DeepCollectionEquality().hash(_oomExcludedRoundIds),secondaryTemplateId,secondaryCompetition,isSecondaryCustomized,memberCost,guestCost,societyGreenFee,buggyCost,eventCost,hasBreakfast,hasLunch,hasDinner,breakfastCost,lunchCost,dinnerCost,societyBreakfastCost,societyLunchCost,societyDinnerCost,dinnerLocation,showAwards,const DeepCollectionEquality().hash(_awards),const DeepCollectionEquality().hash(_notes)]);

@override
String toString() {
  return 'EventFormState(isLoading: $isLoading, isSaving: $isSaving, eventId: $eventId, initialEvent: $initialEvent, title: $title, description: $description, imageUrl: $imageUrl, eventType: $eventType, selectedDate: $selectedDate, selectedTime: $selectedTime, registrationTime: $registrationTime, deadlineDate: $deadlineDate, deadlineTime: $deadlineTime, selectedSeasonId: $selectedSeasonId, isMultiDay: $isMultiDay, endDate: $endDate, showRegistrationButton: $showRegistrationButton, isInvitational: $isInvitational, teeOffInterval: $teeOffInterval, selectedCourseId: $selectedCourseId, courseName: $courseName, courseDetails: $courseDetails, selectedTeeName: $selectedTeeName, selectedFemaleTeeName: $selectedFemaleTeeName, dressCode: $dressCode, availableBuggies: $availableBuggies, maxParticipants: $maxParticipants, facilities: $facilities, holes: $holes, rating: $rating, slope: $slope, selectedTemplateId: $selectedTemplateId, eventCompetition: $eventCompetition, isCustomized: $isCustomized, oomExcludedRoundIds: $oomExcludedRoundIds, secondaryTemplateId: $secondaryTemplateId, secondaryCompetition: $secondaryCompetition, isSecondaryCustomized: $isSecondaryCustomized, memberCost: $memberCost, guestCost: $guestCost, societyGreenFee: $societyGreenFee, buggyCost: $buggyCost, eventCost: $eventCost, hasBreakfast: $hasBreakfast, hasLunch: $hasLunch, hasDinner: $hasDinner, breakfastCost: $breakfastCost, lunchCost: $lunchCost, dinnerCost: $dinnerCost, societyBreakfastCost: $societyBreakfastCost, societyLunchCost: $societyLunchCost, societyDinnerCost: $societyDinnerCost, dinnerLocation: $dinnerLocation, showAwards: $showAwards, awards: $awards, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$EventFormStateCopyWith<$Res> implements $EventFormStateCopyWith<$Res> {
  factory _$EventFormStateCopyWith(_EventFormState value, $Res Function(_EventFormState) _then) = __$EventFormStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isSaving, String? eventId, GolfEvent? initialEvent, String title, String description, String? imageUrl, EventType eventType, DateTime selectedDate, TimeOfDay selectedTime, TimeOfDay registrationTime, DateTime? deadlineDate, TimeOfDay? deadlineTime, String? selectedSeasonId, bool isMultiDay, DateTime? endDate, bool showRegistrationButton, bool isInvitational, int teeOffInterval, String? selectedCourseId, String courseName, String courseDetails, String? selectedTeeName, String? selectedFemaleTeeName, String dressCode, int? availableBuggies, int? maxParticipants, List<String> facilities, List<CourseHole> holes, double? rating, int? slope, String? selectedTemplateId, Competition? eventCompetition, bool isCustomized, List<String> oomExcludedRoundIds, String? secondaryTemplateId, Competition? secondaryCompetition, bool isSecondaryCustomized, double? memberCost, double? guestCost, double? societyGreenFee, double? buggyCost, double? eventCost, bool hasBreakfast, bool hasLunch, bool hasDinner, double? breakfastCost, double? lunchCost, double? dinnerCost, double? societyBreakfastCost, double? societyLunchCost, double? societyDinnerCost, String dinnerLocation, bool showAwards, List<EventAward> awards, List<EventNote> notes
});


@override $GolfEventCopyWith<$Res>? get initialEvent;@override $CompetitionCopyWith<$Res>? get eventCompetition;@override $CompetitionCopyWith<$Res>? get secondaryCompetition;

}
/// @nodoc
class __$EventFormStateCopyWithImpl<$Res>
    implements _$EventFormStateCopyWith<$Res> {
  __$EventFormStateCopyWithImpl(this._self, this._then);

  final _EventFormState _self;
  final $Res Function(_EventFormState) _then;

/// Create a copy of EventFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isSaving = null,Object? eventId = freezed,Object? initialEvent = freezed,Object? title = null,Object? description = null,Object? imageUrl = freezed,Object? eventType = null,Object? selectedDate = null,Object? selectedTime = null,Object? registrationTime = null,Object? deadlineDate = freezed,Object? deadlineTime = freezed,Object? selectedSeasonId = freezed,Object? isMultiDay = null,Object? endDate = freezed,Object? showRegistrationButton = null,Object? isInvitational = null,Object? teeOffInterval = null,Object? selectedCourseId = freezed,Object? courseName = null,Object? courseDetails = null,Object? selectedTeeName = freezed,Object? selectedFemaleTeeName = freezed,Object? dressCode = null,Object? availableBuggies = freezed,Object? maxParticipants = freezed,Object? facilities = null,Object? holes = null,Object? rating = freezed,Object? slope = freezed,Object? selectedTemplateId = freezed,Object? eventCompetition = freezed,Object? isCustomized = null,Object? oomExcludedRoundIds = null,Object? secondaryTemplateId = freezed,Object? secondaryCompetition = freezed,Object? isSecondaryCustomized = null,Object? memberCost = freezed,Object? guestCost = freezed,Object? societyGreenFee = freezed,Object? buggyCost = freezed,Object? eventCost = freezed,Object? hasBreakfast = null,Object? hasLunch = null,Object? hasDinner = null,Object? breakfastCost = freezed,Object? lunchCost = freezed,Object? dinnerCost = freezed,Object? societyBreakfastCost = freezed,Object? societyLunchCost = freezed,Object? societyDinnerCost = freezed,Object? dinnerLocation = null,Object? showAwards = null,Object? awards = null,Object? notes = null,}) {
  return _then(_EventFormState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,initialEvent: freezed == initialEvent ? _self.initialEvent : initialEvent // ignore: cast_nullable_to_non_nullable
as GolfEvent?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as EventType,selectedDate: null == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,selectedTime: null == selectedTime ? _self.selectedTime : selectedTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,registrationTime: null == registrationTime ? _self.registrationTime : registrationTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,deadlineDate: freezed == deadlineDate ? _self.deadlineDate : deadlineDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deadlineTime: freezed == deadlineTime ? _self.deadlineTime : deadlineTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,selectedSeasonId: freezed == selectedSeasonId ? _self.selectedSeasonId : selectedSeasonId // ignore: cast_nullable_to_non_nullable
as String?,isMultiDay: null == isMultiDay ? _self.isMultiDay : isMultiDay // ignore: cast_nullable_to_non_nullable
as bool,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,showRegistrationButton: null == showRegistrationButton ? _self.showRegistrationButton : showRegistrationButton // ignore: cast_nullable_to_non_nullable
as bool,isInvitational: null == isInvitational ? _self.isInvitational : isInvitational // ignore: cast_nullable_to_non_nullable
as bool,teeOffInterval: null == teeOffInterval ? _self.teeOffInterval : teeOffInterval // ignore: cast_nullable_to_non_nullable
as int,selectedCourseId: freezed == selectedCourseId ? _self.selectedCourseId : selectedCourseId // ignore: cast_nullable_to_non_nullable
as String?,courseName: null == courseName ? _self.courseName : courseName // ignore: cast_nullable_to_non_nullable
as String,courseDetails: null == courseDetails ? _self.courseDetails : courseDetails // ignore: cast_nullable_to_non_nullable
as String,selectedTeeName: freezed == selectedTeeName ? _self.selectedTeeName : selectedTeeName // ignore: cast_nullable_to_non_nullable
as String?,selectedFemaleTeeName: freezed == selectedFemaleTeeName ? _self.selectedFemaleTeeName : selectedFemaleTeeName // ignore: cast_nullable_to_non_nullable
as String?,dressCode: null == dressCode ? _self.dressCode : dressCode // ignore: cast_nullable_to_non_nullable
as String,availableBuggies: freezed == availableBuggies ? _self.availableBuggies : availableBuggies // ignore: cast_nullable_to_non_nullable
as int?,maxParticipants: freezed == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int?,facilities: null == facilities ? _self._facilities : facilities // ignore: cast_nullable_to_non_nullable
as List<String>,holes: null == holes ? _self._holes : holes // ignore: cast_nullable_to_non_nullable
as List<CourseHole>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,slope: freezed == slope ? _self.slope : slope // ignore: cast_nullable_to_non_nullable
as int?,selectedTemplateId: freezed == selectedTemplateId ? _self.selectedTemplateId : selectedTemplateId // ignore: cast_nullable_to_non_nullable
as String?,eventCompetition: freezed == eventCompetition ? _self.eventCompetition : eventCompetition // ignore: cast_nullable_to_non_nullable
as Competition?,isCustomized: null == isCustomized ? _self.isCustomized : isCustomized // ignore: cast_nullable_to_non_nullable
as bool,oomExcludedRoundIds: null == oomExcludedRoundIds ? _self._oomExcludedRoundIds : oomExcludedRoundIds // ignore: cast_nullable_to_non_nullable
as List<String>,secondaryTemplateId: freezed == secondaryTemplateId ? _self.secondaryTemplateId : secondaryTemplateId // ignore: cast_nullable_to_non_nullable
as String?,secondaryCompetition: freezed == secondaryCompetition ? _self.secondaryCompetition : secondaryCompetition // ignore: cast_nullable_to_non_nullable
as Competition?,isSecondaryCustomized: null == isSecondaryCustomized ? _self.isSecondaryCustomized : isSecondaryCustomized // ignore: cast_nullable_to_non_nullable
as bool,memberCost: freezed == memberCost ? _self.memberCost : memberCost // ignore: cast_nullable_to_non_nullable
as double?,guestCost: freezed == guestCost ? _self.guestCost : guestCost // ignore: cast_nullable_to_non_nullable
as double?,societyGreenFee: freezed == societyGreenFee ? _self.societyGreenFee : societyGreenFee // ignore: cast_nullable_to_non_nullable
as double?,buggyCost: freezed == buggyCost ? _self.buggyCost : buggyCost // ignore: cast_nullable_to_non_nullable
as double?,eventCost: freezed == eventCost ? _self.eventCost : eventCost // ignore: cast_nullable_to_non_nullable
as double?,hasBreakfast: null == hasBreakfast ? _self.hasBreakfast : hasBreakfast // ignore: cast_nullable_to_non_nullable
as bool,hasLunch: null == hasLunch ? _self.hasLunch : hasLunch // ignore: cast_nullable_to_non_nullable
as bool,hasDinner: null == hasDinner ? _self.hasDinner : hasDinner // ignore: cast_nullable_to_non_nullable
as bool,breakfastCost: freezed == breakfastCost ? _self.breakfastCost : breakfastCost // ignore: cast_nullable_to_non_nullable
as double?,lunchCost: freezed == lunchCost ? _self.lunchCost : lunchCost // ignore: cast_nullable_to_non_nullable
as double?,dinnerCost: freezed == dinnerCost ? _self.dinnerCost : dinnerCost // ignore: cast_nullable_to_non_nullable
as double?,societyBreakfastCost: freezed == societyBreakfastCost ? _self.societyBreakfastCost : societyBreakfastCost // ignore: cast_nullable_to_non_nullable
as double?,societyLunchCost: freezed == societyLunchCost ? _self.societyLunchCost : societyLunchCost // ignore: cast_nullable_to_non_nullable
as double?,societyDinnerCost: freezed == societyDinnerCost ? _self.societyDinnerCost : societyDinnerCost // ignore: cast_nullable_to_non_nullable
as double?,dinnerLocation: null == dinnerLocation ? _self.dinnerLocation : dinnerLocation // ignore: cast_nullable_to_non_nullable
as String,showAwards: null == showAwards ? _self.showAwards : showAwards // ignore: cast_nullable_to_non_nullable
as bool,awards: null == awards ? _self._awards : awards // ignore: cast_nullable_to_non_nullable
as List<EventAward>,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<EventNote>,
  ));
}

/// Create a copy of EventFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GolfEventCopyWith<$Res>? get initialEvent {
    if (_self.initialEvent == null) {
    return null;
  }

  return $GolfEventCopyWith<$Res>(_self.initialEvent!, (value) {
    return _then(_self.copyWith(initialEvent: value));
  });
}/// Create a copy of EventFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionCopyWith<$Res>? get eventCompetition {
    if (_self.eventCompetition == null) {
    return null;
  }

  return $CompetitionCopyWith<$Res>(_self.eventCompetition!, (value) {
    return _then(_self.copyWith(eventCompetition: value));
  });
}/// Create a copy of EventFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionCopyWith<$Res>? get secondaryCompetition {
    if (_self.secondaryCompetition == null) {
    return null;
  }

  return $CompetitionCopyWith<$Res>(_self.secondaryCompetition!, (value) {
    return _then(_self.copyWith(secondaryCompetition: value));
  });
}
}

// dart format on
