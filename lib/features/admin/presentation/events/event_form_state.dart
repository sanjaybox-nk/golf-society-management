import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/course_config.dart';

part 'event_form_state.freezed.dart';

@freezed
abstract class EventFormState with _$EventFormState {
  const EventFormState._();
  const factory EventFormState({
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    String? eventId,
    GolfEvent? initialEvent,
    
    // Basic Info
    @Default('') String title,
    @Default('') String description,
    String? imageUrl,
    @Default(EventType.golf) EventType eventType,
    
    // Logistics
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    required TimeOfDay registrationTime,
    DateTime? deadlineDate,
    TimeOfDay? deadlineTime,
    String? selectedSeasonId,
    @Default(false) bool isMultiDay,
    DateTime? endDate,
    @Default(true) bool showRegistrationButton,
    @Default(false) bool isInvitational,
    @Default(10) int teeOffInterval,
    
    // Course
    String? selectedCourseId,
    @Default('') String courseName,
    @Default('') String courseDetails,
    String? selectedTeeName,
    String? selectedFemaleTeeName,
    @Default('') String dressCode,
    int? availableBuggies,
    int? maxParticipants,
    @Default([]) List<String> facilities,
    
    // Holes (Manual Override)
    @Default([]) List<CourseHole> holes,
    double? rating,
    int? slope,
    int? par,
    
    // Competition
    String? selectedTemplateId,
    Competition? eventCompetition,
    @Default(false) bool isCustomized,
    @Default([]) List<String> oomExcludedRoundIds,
    
    // Secondary Competition
    String? secondaryTemplateId,
    Competition? secondaryCompetition,
    @Default(false) bool isSecondaryCustomized,
    
    // Costs
    double? memberCost,
    double? guestCost,
    double? societyGreenFee,
    double? buggyCost,
    double? eventCost,
    
    // Meals
    @Default(false) bool hasBreakfast,
    @Default(false) bool hasLunch,
    @Default(true) bool hasDinner,
    double? breakfastCost,
    double? lunchCost,
    double? dinnerCost,
    double? societyBreakfastCost,
    double? societyLunchCost,
    double? societyDinnerCost,
    @Default('') String dinnerLocation,
    @Default('') String dinnerAddress,
    
    // Awards
    @Default(true) bool showAwards,
    @Default([]) List<EventAward> awards,
    
    // Content
    @Default([]) List<EventNote> notes,
  }) = _EventFormState;

  factory EventFormState.initial() => EventFormState(
    selectedDate: DateTime.now().add(const Duration(days: 1)),
    selectedTime: const TimeOfDay(hour: 9, minute: 0),
    registrationTime: const TimeOfDay(hour: 8, minute: 30),
    awards: [
      const EventAward(id: 'prize_1', label: '1st Place', type: 'Cup'),
      const EventAward(id: 'prize_2', label: '2nd Place', type: 'Cup'),
      const EventAward(id: 'prize_3', label: '3rd Place', type: 'Cup'),
    ],
  );
}
