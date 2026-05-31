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

final groupingDirtyProvider = NotifierProvider.autoDispose<GroupingDirtyNotifier, bool>(GroupingDirtyNotifier.new);

/// Tracks the temporary grouping state for the current event.
class GroupingLocalGroupsNotifier extends Notifier<List<TeeGroup>?> {
  @override
  List<TeeGroup>? build() => null;

  void setGroups(List<TeeGroup>? groups) {
    state = groups;
  }
}

final groupingLocalGroupsProvider = NotifierProvider.autoDispose<GroupingLocalGroupsNotifier, List<TeeGroup>?>(GroupingLocalGroupsNotifier.new);

/// Tracks the temporary lock status.
class GroupingIsLockedNotifier extends Notifier<bool?> {
  @override
  bool? build() => null;

  void setLocked(bool? value) {
    state = value;
  }
}

final groupingIsLockedProvider = NotifierProvider.autoDispose<GroupingIsLockedNotifier, bool?>(GroupingIsLockedNotifier.new);

/// Tracks if the generation options overlay is shown.
class GroupingShowGenerationOptionsNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}
final groupingShowGenerationOptionsProvider = NotifierProvider.autoDispose<GroupingShowGenerationOptionsNotifier, bool>(GroupingShowGenerationOptionsNotifier.new);

/// Tracks the selected player for swap.
class GroupingSelectedForSwapNotifier extends Notifier<TeeGroupParticipant?> {
  @override
  TeeGroupParticipant? build() => null;
  void set(TeeGroupParticipant? value) => state = value;
}
final groupingSelectedForSwapProvider = NotifierProvider.autoDispose<GroupingSelectedForSwapNotifier, TeeGroupParticipant?>(GroupingSelectedForSwapNotifier.new);

/// Tracks the match pair partner of the selected player (match play only).
class GroupingSelectedMatchPartnerNotifier extends Notifier<TeeGroupParticipant?> {
  @override
  TeeGroupParticipant? build() => null;
  void set(TeeGroupParticipant? value) => state = value;
}
final groupingSelectedMatchPartnerProvider = NotifierProvider.autoDispose<GroupingSelectedMatchPartnerNotifier, TeeGroupParticipant?>(GroupingSelectedMatchPartnerNotifier.new);

/// Tracks the selected strategy for generation.
class GroupingStrategyNotifier extends Notifier<String> {
  @override
  String build() => 'random';
  void set(String value) => state = value;
}
final groupingStrategyProvider = NotifierProvider.autoDispose<GroupingStrategyNotifier, String>(GroupingStrategyNotifier.new);
