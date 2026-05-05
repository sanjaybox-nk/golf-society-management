import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/services/persistence_service.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';

class MarkerSelection {
  final bool isSelfMarking;
  final List<String> targetEntryIds;
  final Map<String, String> teeOverrides;
  final int lastViewedHoleIndex;
  final String? myMarkerId;
  final bool isGroupScorer;
  final Map<String, String> markerAssignments; // playerId -> markerId

  MarkerSelection({
    required this.isSelfMarking, 
    List<String>? targetEntryIds,
    Map<String, String>? teeOverrides,
    this.lastViewedHoleIndex = 0,
    this.myMarkerId,
    this.isGroupScorer = false,
    Map<String, String>? markerAssignments,
  }) : targetEntryIds = targetEntryIds ?? const [],
       teeOverrides = teeOverrides ?? <String, String>{},
       markerAssignments = markerAssignments ?? <String, String>{};

  MarkerSelection copyWith({
    bool? isSelfMarking,
    List<String>? targetEntryIds,
    Map<String, String>? teeOverrides,
    int? lastViewedHoleIndex,
    String? myMarkerId,
    bool? isGroupScorer,
    Map<String, String>? markerAssignments,
  }) {
    return MarkerSelection(
      isSelfMarking: isSelfMarking ?? this.isSelfMarking,
      targetEntryIds: targetEntryIds ?? this.targetEntryIds,
      teeOverrides: teeOverrides ?? this.teeOverrides,
      lastViewedHoleIndex: lastViewedHoleIndex ?? this.lastViewedHoleIndex,
      myMarkerId: myMarkerId ?? this.myMarkerId,
      isGroupScorer: isGroupScorer ?? this.isGroupScorer,
      markerAssignments: markerAssignments ?? this.markerAssignments,
    );
  }
}

class MarkerSelectionNotifier extends Notifier<MarkerSelection> {
  // Base keys - will be prefixed with userId
  static const _baseKeySelf = 'lab_marker_self';
  static const _baseKeyTargets = 'lab_marker_targets_v2';
  static const _baseKeyTeeOverrides = 'lab_marker_tee_overrides';
  static const _baseKeyLastHole = 'lab_marker_last_hole';
  static const _baseKeyMyMarker = 'lab_marker_my_marker';

  String _getKey(String base) {
    final userId = ref.read(effectiveUserProvider).id;
    return '${base}_$userId';
  }
  
  @override
  MarkerSelection build() {
    // Watch effectiveUser to trigger a full state rebuild when the user switches
    final currentUser = ref.watch(effectiveUserProvider);
    final userId = currentUser.id;
    final prefs = ref.watch(persistenceServiceProvider);
    
    // Default values
    bool self = true;
    List<String> targets = [];
    final Map<String, String> overrides = {};
    int lastHole = 0;
    String? myMarker;

    try {
      self = prefs.getBool('${_baseKeySelf}_$userId') ?? true;
      final targetsJson = prefs.getString('${_baseKeyTargets}_$userId');
      if (targetsJson != null && targetsJson.isNotEmpty) {
        final decoded = jsonDecode(targetsJson);
        if (decoded is List) {
          targets = decoded.map((e) => e.toString()).toList();
        }
      }
      final overridesJson = prefs.getString('${_baseKeyTeeOverrides}_$userId');
      if (overridesJson != null && overridesJson.isNotEmpty && overridesJson != 'null') {
        final decoded = jsonDecode(overridesJson);
        if (decoded is Map) {
          decoded.forEach((k, v) {
            overrides[k.toString()] = v.toString();
          });
        }
      }
      lastHole = prefs.getInt('${_baseKeyLastHole}_$userId') ?? 0;
      myMarker = prefs.getString('${_baseKeyMyMarker}_$userId');
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading MarkerSelection state for $userId: $e');
    }

    return MarkerSelection(
      isSelfMarking: self,
      targetEntryIds: targets,
      teeOverrides: overrides,
      lastViewedHoleIndex: lastHole,
      myMarkerId: myMarker,
    );
  }
  
  void setSelfMarking(bool val) {
    state = state.copyWith(isSelfMarking: val);
    ref.read(persistenceServiceProvider).setBool(_getKey(_baseKeySelf), val);
  }
  
  void toggleTarget(String targetId) {
    final List<String> currentTargets = List<String>.from(state.targetEntryIds);
    if (currentTargets.contains(targetId)) {
      currentTargets.remove(targetId);
    } else {
      if (currentTargets.length < 10) { 
        currentTargets.add(targetId);
      }
    }
    
    state = state.copyWith(targetEntryIds: currentTargets);
    ref.read(persistenceServiceProvider).setString(_getKey(_baseKeyTargets), jsonEncode(currentTargets));
  }

  void validateTargets(List<String> validIds) {
    final List<String> currentTargets = List<String>.from(state.targetEntryIds);
    final List<String> validated = currentTargets.where((id) => validIds.contains(id)).toList();
    
    if (validated.length != currentTargets.length) {
      state = state.copyWith(targetEntryIds: validated);
      ref.read(persistenceServiceProvider).setString(_getKey(_baseKeyTargets), jsonEncode(validated));
    }
  }

  void setManualTee(String entryId, String teeName) {
    final Map<String, String> newOverrides = Map<String, String>.from(state.teeOverrides);
    newOverrides[entryId] = teeName;
    state = state.copyWith(teeOverrides: newOverrides);
    
    ref.read(persistenceServiceProvider).setString(_getKey(_baseKeyTeeOverrides), jsonEncode(newOverrides));
  }

  void clearManualTee(String entryId) {
    final Map<String, String> newOverrides = Map<String, String>.from(state.teeOverrides);
    if (newOverrides.containsKey(entryId)) {
      newOverrides.remove(entryId);
      state = state.copyWith(teeOverrides: newOverrides);
      ref.read(persistenceServiceProvider).setString(_getKey(_baseKeyTeeOverrides), jsonEncode(newOverrides));
    }
  }

  void setLastViewedHole(int index) {
    if (state.lastViewedHoleIndex != index) {
      state = state.copyWith(lastViewedHoleIndex: index);
      ref.read(persistenceServiceProvider).setInt(_getKey(_baseKeyLastHole), index);
    }
  }

  void setMyMarker(String? markerId) {
    state = state.copyWith(myMarkerId: markerId);
    if (markerId != null) {
      ref.read(persistenceServiceProvider).setString(_getKey(_baseKeyMyMarker), markerId);
    } else {
      ref.read(persistenceServiceProvider).remove(_getKey(_baseKeyMyMarker));
    }
  }

  void toggleGroupScorer(bool value) {
    state = state.copyWith(isGroupScorer: value);
  }

  /// Clears all marker targets when the active event changes, preventing stale
  /// targets from a previous event appearing pre-selected in the new event's sheet.
  void clearTargets(String eventId) {
    state = state.copyWith(targetEntryIds: []);
    ref.read(persistenceServiceProvider).setString(_getKey(_baseKeyTargets), jsonEncode([]));
  }
}

final markerSelectionProvider = NotifierProvider<MarkerSelectionNotifier, MarkerSelection>(() => MarkerSelectionNotifier());
