import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/course.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';

class EventFormNotifier extends AsyncNotifier<EventFormState> {
  @override
  Future<EventFormState> build() async {
    return EventFormState.initial();
  }

  Future<void> initialize((GolfEvent?, String?) arg) async {
    final event = arg.$1;
    final eventId = arg.$2;
    
    state = const AsyncValue.loading();
    
    try {
      if (event != null) {
        final newState = await _initFromEvent(event);
        state = AsyncValue.data(newState);
        return;
      } else if (eventId != null && eventId != 'new') {
        final repo = ref.read(eventsRepositoryProvider);
        final fetchedEvent = await repo.getEvent(eventId);
        if (fetchedEvent != null) {
          final newState = await _initFromEvent(fetchedEvent);
          state = AsyncValue.data(newState);
          return;
        }
      }
      state = AsyncValue.data(EventFormState.initial());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<EventFormState> _initFromEvent(GolfEvent e) async {
    // Fetch competition
    final compRepo = ref.read(competitionsRepositoryProvider);
    final comp = await compRepo.getCompetition(e.id);
    final secondaryComp = await compRepo.getCompetition('${e.id}_secondary');

    return EventFormState(
      eventId: e.id,
      initialEvent: e,
      title: e.title,
      description: e.description ?? '',
      imageUrl: e.imageUrl,
      eventType: e.eventType,
      selectedDate: e.date,
      selectedTime: TimeOfDay.fromDateTime(e.teeOffTime ?? e.date),
      registrationTime: TimeOfDay.fromDateTime(e.regTime ?? e.date),
      deadlineDate: e.registrationDeadline,
      deadlineTime: e.registrationDeadline != null ? TimeOfDay.fromDateTime(e.registrationDeadline!) : null,
      selectedSeasonId: e.seasonId,
      isMultiDay: e.isMultiDay,
      endDate: e.endDate,
      showRegistrationButton: e.showRegistrationButton,
      isInvitational: e.isInvitational,
      teeOffInterval: e.teeOffInterval,
      selectedCourseId: e.courseId,
      courseName: e.courseName ?? '',
      courseDetails: e.courseDetails ?? '',
      selectedTeeName: e.selectedTeeName,
      selectedFemaleTeeName: e.selectedFemaleTeeName,
      dressCode: e.dressCode ?? '',
      availableBuggies: e.availableBuggies,
      maxParticipants: e.maxParticipants,
      facilities: e.facilities,
      holes: e.courseConfig.holes,
      rating: e.courseConfig.rating,
      slope: e.courseConfig.slope,
      selectedTemplateId: comp?.templateId,
      eventCompetition: comp,
      isCustomized: comp?.computeVersion != null && comp!.computeVersion! > 0,
      oomExcludedRoundIds: comp?.rules.oomExcludedRoundIds ?? [],
      secondaryTemplateId: e.secondaryTemplateId,
      secondaryCompetition: secondaryComp,
      isSecondaryCustomized: secondaryComp?.computeVersion != null && secondaryComp!.computeVersion! > 0,
      memberCost: e.memberCost,
      guestCost: e.guestCost,
      societyGreenFee: e.societyGreenFee,
      buggyCost: e.buggyCost,
      eventCost: e.eventCost,
      hasBreakfast: e.hasBreakfast,
      hasLunch: e.hasLunch,
      hasDinner: e.hasDinner,
      breakfastCost: e.breakfastCost,
      lunchCost: e.lunchCost,
      dinnerCost: e.dinnerCost,
      societyBreakfastCost: e.societyBreakfastCost,
      societyLunchCost: e.societyLunchCost,
      societyDinnerCost: e.societyDinnerCost,
      dinnerLocation: e.dinnerLocation ?? '',
      showAwards: e.showAwards,
      awards: e.awards,
      notes: e.notes,
    );
  }

  // State Updates
  void updateTitle(String v) => state = AsyncData(state.value!.copyWith(title: v));
  void updateDescription(String v) => state = AsyncData(state.value!.copyWith(description: v));
  void updateImageUrl(String? v) => state = AsyncData(state.value!.copyWith(imageUrl: v));
  void updateEventType(EventType v) => state = AsyncData(state.value!.copyWith(eventType: v));
  void updateDate(DateTime v) => state = AsyncData(state.value!.copyWith(selectedDate: v));
  void updateTime(TimeOfDay v, {bool isTeeOff = true}) {
    if (isTeeOff) {
      state = AsyncData(state.value!.copyWith(selectedTime: v));
    } else {
      state = AsyncData(state.value!.copyWith(registrationTime: v));
    }
  }
  void updateDeadline(DateTime? date, TimeOfDay? time) => 
    state = AsyncData(state.value!.copyWith(deadlineDate: date, deadlineTime: time));
  
  void updateMultiDay(bool v) => state = AsyncData(state.value!.copyWith(isMultiDay: v));
  void updateEndDate(DateTime? v) => state = AsyncData(state.value!.copyWith(endDate: v));
  void updateTeeOffInterval(int v) => state = AsyncData(state.value!.copyWith(teeOffInterval: v));
  void updateShowRegistrationButton(bool v) => state = AsyncData(state.value!.copyWith(showRegistrationButton: v));
  void updateIsInvitational(bool v) => state = AsyncData(state.value!.copyWith(isInvitational: v));
  
  void updateCourse(Course course) {
    state = AsyncData(state.value!.copyWith(
      selectedCourseId: course.id,
      courseName: course.name,
      courseDetails: course.address,
      selectedTeeName: course.tees.firstOrNull?.name,
      holes: course.tees.firstOrNull?.holePars.asMap().entries.map((entry) {
        final i = entry.key;
        return CourseHole(
          hole: i + 1,
          par: course.tees.firstOrNull!.holePars[i],
          si: course.tees.firstOrNull!.holeSIs[i],
          yardage: course.tees.firstOrNull!.yardages[i],
        );
      }).toList() ?? [],
    ));
  }

  void updateCourseNameManual(String v) => state = AsyncData(state.value!.copyWith(courseName: v));
  void updateSelectedTeeName(String? v) => state = AsyncData(state.value!.copyWith(selectedTeeName: v));
  void updateSelectedFemaleTeeName(String? v) => state = AsyncData(state.value!.copyWith(selectedFemaleTeeName: v));
  void updateDressCode(String v) => state = AsyncData(state.value!.copyWith(dressCode: v));
  void updateAvailableBuggies(int? v) => state = AsyncData(state.value!.copyWith(availableBuggies: v));
  void updateBuggyCost(double? v) => state = AsyncData(state.value!.copyWith(buggyCost: v));
  void updateMaxParticipants(int? v) => state = AsyncData(state.value!.copyWith(maxParticipants: v));

  void updateTemplateId(String? v) => state = AsyncData(state.value!.copyWith(selectedTemplateId: v));
  void updateSecondaryTemplateId(String? v) => state = AsyncData(state.value!.copyWith(secondaryTemplateId: v));
  void toggleOomRound(String roundId, bool include) {
    final s = state.value!;
    final List<String> excluded = List.from(s.oomExcludedRoundIds);
    if (include) {
      excluded.remove(roundId);
    } else {
      if (!excluded.contains(roundId)) excluded.add(roundId);
    }
    state = AsyncData(s.copyWith(oomExcludedRoundIds: excluded));
  }

  // Image Picking
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked != null) {
      state = AsyncData(state.value!.copyWith(imageUrl: picked.path));
    }
  }

  // Cost Logic
  void updateSocietyFee(double? v) {
    final s = state.value!;
    final member = v != null ? (v * 1.10).roundToDouble() : s.memberCost;
    final guest = member != null ? member + 10 : s.guestCost;
    state = AsyncData(s.copyWith(
      societyGreenFee: v,
      memberCost: member,
      guestCost: guest,
    ));
  }

  void updateEventCost(double? v) => state = AsyncData(state.value!.copyWith(eventCost: v));
  void updateMemberCost(double? v) => state = AsyncData(state.value!.copyWith(memberCost: v));
  void updateGuestCost(double? v) => state = AsyncData(state.value!.copyWith(guestCost: v));
  
  void updateHasBreakfast(bool v) => state = AsyncData(state.value!.copyWith(hasBreakfast: v));
  void updateHasLunch(bool v) => state = AsyncData(state.value!.copyWith(hasLunch: v));
  void updateHasDinner(bool v) => state = AsyncData(state.value!.copyWith(hasDinner: v));
  
  void updateSocietyBreakfastCost(double v) => state = AsyncData(state.value!.copyWith(societyBreakfastCost: v));
  void updateBreakfastCost(double v) => state = AsyncData(state.value!.copyWith(breakfastCost: v));
  void updateSocietyLunchCost(double v) => state = AsyncData(state.value!.copyWith(societyLunchCost: v));
  void updateLunchCost(double v) => state = AsyncData(state.value!.copyWith(lunchCost: v));
  void updateSocietyDinnerCost(double v) => state = AsyncData(state.value!.copyWith(societyDinnerCost: v));
  void updateDinnerCost(double v) => state = AsyncData(state.value!.copyWith(dinnerCost: v));
  void updateDinnerLocation(String v) => state = AsyncData(state.value!.copyWith(dinnerLocation: v));

  // Awards Logic
  void updateShowAwards(bool v) => state = AsyncData(state.value!.copyWith(showAwards: v));
  void addAward() {
    final s = state.value!;
    final List<EventAward> awards = List.from(s.awards);
    awards.add(EventAward(id: 'award_${DateTime.now().millisecondsSinceEpoch}', label: '', type: 'Cup'));
    state = AsyncData(s.copyWith(awards: awards));
  }
  void updateAward(int index, EventAward award) {
    final s = state.value!;
    final List<EventAward> awards = List.from(s.awards);
    awards[index] = award;
    state = AsyncData(s.copyWith(awards: awards));
  }
  void removeAward(int index) {
    final s = state.value!;
    final List<EventAward> awards = List.from(s.awards);
    awards.removeAt(index);
    state = AsyncData(s.copyWith(awards: awards));
  }

  // Content Logic
  void updateFacilities(List<String> v) => state = AsyncData(state.value!.copyWith(facilities: v));
  void updateNotes(List<EventNote> v) => state = AsyncData(state.value!.copyWith(notes: v));

  // Save Orchestration
  Future<bool> save() async {
    final s = state.value!;
    if (s.title.trim().isEmpty) {
      state = AsyncError('Title is required', StackTrace.current);
      return false;
    }
    if (s.selectedCourseId == null && s.courseName.trim().isEmpty) {
      state = AsyncError('Course selection or manual name is required', StackTrace.current);
      return false;
    }

    state = const AsyncLoading();
    
    try {
      final repo = ref.read(eventsRepositoryProvider);
      final event = _constructEvent(s);
      
      String eventId;
      if (s.eventId == null) {
        eventId = await repo.addEvent(event);
      } else {
        await repo.updateEvent(event);
        eventId = s.eventId!;
      }

      // Competition Management
      await _syncCompetitions(eventId, s);
      
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  GolfEvent constructPreviewEvent() => _constructEvent(state.value!);

  GolfEvent _constructEvent(EventFormState s) {

    return GolfEvent(
      id: s.eventId ?? '',
      title: s.title,
      seasonId: s.selectedSeasonId ?? '', // Should be validated
      date: s.selectedDate,
      description: s.description,
      imageUrl: s.imageUrl,
      regTime: DateTime(s.selectedDate.year, s.selectedDate.month, s.selectedDate.day, s.registrationTime.hour, s.registrationTime.minute),
      teeOffTime: DateTime(s.selectedDate.year, s.selectedDate.month, s.selectedDate.day, s.selectedTime.hour, s.selectedTime.minute),
      registrationDeadline: s.deadlineDate != null && s.deadlineTime != null 
        ? DateTime(s.deadlineDate!.year, s.deadlineDate!.month, s.deadlineDate!.day, s.deadlineTime!.hour, s.deadlineTime!.minute)
        : null,
      courseId: s.selectedCourseId,
      courseName: s.courseName,
      courseDetails: s.courseDetails,
      courseConfig: CourseConfig(
        holes: s.holes,
        rating: s.rating,
        slope: s.slope,
      ),
      selectedTeeName: s.selectedTeeName,
      selectedFemaleTeeName: s.selectedFemaleTeeName,
      memberCost: s.memberCost,
      guestCost: s.guestCost,
      societyGreenFee: s.societyGreenFee,
      buggyCost: s.buggyCost,
      eventCost: s.eventCost,
      hasBreakfast: s.hasBreakfast,
      hasLunch: s.hasLunch,
      hasDinner: s.hasDinner,
      breakfastCost: s.breakfastCost,
      lunchCost: s.lunchCost,
      dinnerCost: s.dinnerCost,
      societyBreakfastCost: s.societyBreakfastCost,
      societyLunchCost: s.societyLunchCost,
      societyDinnerCost: s.societyDinnerCost,
      dinnerLocation: s.dinnerLocation,
      awards: s.awards,
      showAwards: s.showAwards,
      eventType: s.eventType,
      isMultiDay: s.isMultiDay,
      endDate: s.endDate,
      secondaryTemplateId: s.secondaryTemplateId,
    );
  }

  Future<void> _syncCompetitions(String eventId, EventFormState s) async {
    final compRepo = ref.read(competitionsRepositoryProvider);
    final hasTemplate = s.selectedTemplateId != null;
    final templateChanged = s.selectedTemplateId != s.initialEvent?.secondaryTemplateId; // This check might be wrong, checking against primary

    // Primary Competition
    if (hasTemplate && (s.eventCompetition == null || templateChanged)) {
      final templates = ref.read(templatesListProvider).value;
      final template = templates?.firstWhereOrNull((t) => t.id == s.selectedTemplateId);
      
      if (template != null) {
        final newComp = Competition(
          id: eventId,
          templateId: s.selectedTemplateId,
          type: CompetitionType.event,
          status: CompetitionStatus.draft,
          rules: template.rules,
          startDate: s.selectedDate,
          endDate: s.isMultiDay && s.endDate != null ? s.endDate! : s.selectedDate,
          publishSettings: {},
          isDirty: true,
        );
        await compRepo.addCompetition(newComp);
      }
    } else if (s.eventCompetition != null) {
      final updatedComp = s.eventCompetition!.copyWith(
        startDate: s.selectedDate,
        endDate: s.isMultiDay && s.endDate != null ? s.endDate! : s.selectedDate,
        rules: s.eventCompetition!.rules.copyWith(
          oomExcludedRoundIds: s.oomExcludedRoundIds,
        ),
      );
      await compRepo.updateCompetition(updatedComp);
    } else if (!hasTemplate) {
      await compRepo.deleteCompetition(eventId);
    }

    // Secondary Competition
    if (s.secondaryTemplateId != null) {
      final secondaryId = '${eventId}_secondary';
      if (s.secondaryCompetition == null) {
        final templates = ref.read(templatesListProvider).value;
        final template = templates?.firstWhereOrNull((t) => t.id == s.secondaryTemplateId);
        if (template != null) {
          final newSecondary = Competition(
            id: secondaryId,
            templateId: s.secondaryTemplateId,
            type: CompetitionType.event,
            status: CompetitionStatus.draft,
            rules: template.rules,
            startDate: s.selectedDate,
            endDate: s.isMultiDay && s.endDate != null ? s.endDate! : s.selectedDate,
            publishSettings: {},
            isDirty: true,
          );
          await compRepo.addCompetition(newSecondary);
        }
      } else {
        final updatedSecondary = s.secondaryCompetition!.copyWith(
          startDate: s.selectedDate,
          endDate: s.isMultiDay && s.endDate != null ? s.endDate! : s.selectedDate,
        );
        await compRepo.updateCompetition(updatedSecondary);
      }
    } else {
      await compRepo.deleteCompetition('${eventId}_secondary');
    }
  }
}

final eventFormNotifierProvider = AsyncNotifierProvider<EventFormNotifier, EventFormState>(
  EventFormNotifier.new,
);
