import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';

/// Tracks if the current grouping screen has unsaved changes.
class GroupingDirtyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setDirty(bool value) {
    state = value;
  }
}

final groupingDirtyProvider = NotifierProvider<GroupingDirtyNotifier, bool>(GroupingDirtyNotifier.new);

/// Tracks the temporary grouping state for the current event.
class GroupingLocalGroupsNotifier extends Notifier<List<TeeGroup>?> {
  @override
  List<TeeGroup>? build() => null;

  void setGroups(List<TeeGroup>? groups) {
    state = groups;
  }
}

final groupingLocalGroupsProvider = NotifierProvider<GroupingLocalGroupsNotifier, List<TeeGroup>?>(GroupingLocalGroupsNotifier.new);

/// Tracks the temporary lock status.
class GroupingIsLockedNotifier extends Notifier<bool?> {
  @override
  bool? build() => null;

  void setLocked(bool? value) {
    state = value;
  }
}


final groupingIsLockedProvider = NotifierProvider<GroupingIsLockedNotifier, bool?>(GroupingIsLockedNotifier.new);

/// Tracks if the generation options overlay is shown.
class GroupingShowGenerationOptionsNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}
final groupingShowGenerationOptionsProvider = NotifierProvider<GroupingShowGenerationOptionsNotifier, bool>(GroupingShowGenerationOptionsNotifier.new);

/// Tracks the selected player for swap.
class GroupingSelectedForSwapNotifier extends Notifier<TeeGroupParticipant?> {
  @override
  TeeGroupParticipant? build() => null;
  void set(TeeGroupParticipant? value) => state = value;
}
final groupingSelectedForSwapProvider = NotifierProvider<GroupingSelectedForSwapNotifier, TeeGroupParticipant?>(GroupingSelectedForSwapNotifier.new);

/// Tracks if match play mode is active.
class GroupingMatchPlayModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}
final groupingMatchPlayModeProvider = NotifierProvider<GroupingMatchPlayModeNotifier, bool>(GroupingMatchPlayModeNotifier.new);

/// Tracks the selected strategy for generation.
class GroupingStrategyNotifier extends Notifier<String> {
  @override
  String build() => 'random';
  void set(String value) => state = value;
}
final groupingStrategyProvider = NotifierProvider<GroupingStrategyNotifier, String>(GroupingStrategyNotifier.new);

/// Tracks the temporary tee-off time (seed) for generation.
class GroupingTeeTimeNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;
  void set(DateTime? value) => state = value;
}
final groupingTeeTimeProvider = NotifierProvider<GroupingTeeTimeNotifier, DateTime?>(GroupingTeeTimeNotifier.new);

/// Tracks the temporary tee interval for generation.
class GroupingIntervalNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  void set(int? value) => state = value;
}
final groupingIntervalProvider = NotifierProvider<GroupingIntervalNotifier, int?>(GroupingIntervalNotifier.new);
