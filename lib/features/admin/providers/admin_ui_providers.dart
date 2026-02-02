import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/grouping_service.dart';

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
