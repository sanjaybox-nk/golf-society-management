import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/persistence_service.dart';

// [LAB MODE] Persistence for Marker Selection
class MarkerSelection {
  final bool isSelfMarking;
  final String? targetEntryId;
  final Map<String, String> teeOverrides;

  MarkerSelection({
    required this.isSelfMarking, 
    this.targetEntryId,
    Map<String, String>? teeOverrides,
  }) : teeOverrides = teeOverrides ?? <String, String>{};

  MarkerSelection copyWith({
    bool? isSelfMarking,
    String? targetEntryId,
    Map<String, String>? teeOverrides,
    bool clearTarget = false,
  }) {
    return MarkerSelection(
      isSelfMarking: isSelfMarking ?? this.isSelfMarking,
      targetEntryId: clearTarget ? null : (targetEntryId ?? this.targetEntryId),
      teeOverrides: teeOverrides ?? this.teeOverrides,
    );
  }
}

class MarkerSelectionNotifier extends Notifier<MarkerSelection> {
  static const _keySelf = 'lab_marker_self';
  static const _keyTarget = 'lab_marker_target';
  static const _keyTeeOverrides = 'lab_marker_tee_overrides';
  
  @override
  MarkerSelection build() {
    final prefs = ref.watch(persistenceServiceProvider);
    
    // Default values
    bool self = true;
    String? target;
    final Map<String, String> overrides = {};

    try {
      self = prefs.getBool(_keySelf) ?? true;
      target = prefs.getString(_keyTarget);
      
      final overridesJson = prefs.getString(_keyTeeOverrides);
      if (overridesJson != null && overridesJson.isNotEmpty && overridesJson != 'null') {
        final decoded = jsonDecode(overridesJson);
        if (decoded is Map) {
          decoded.forEach((k, v) {
            overrides[k.toString()] = v.toString();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading MarkerSelection state: $e');
    }

    return MarkerSelection(
      isSelfMarking: self,
      targetEntryId: target,
      teeOverrides: overrides,
    );
  }
  
  void selectSelf() {
    state = state.copyWith(isSelfMarking: true, clearTarget: true);
    ref.read(persistenceServiceProvider).setBool(_keySelf, true);
    ref.read(persistenceServiceProvider).remove(_keyTarget);
  }
  
  void selectTarget(String targetId) {
    state = state.copyWith(isSelfMarking: false, targetEntryId: targetId);
    ref.read(persistenceServiceProvider).setBool(_keySelf, false);
    ref.read(persistenceServiceProvider).setString(_keyTarget, targetId);
  }

  void setManualTee(String entryId, String teeName) {
    final Map<String, String> newOverrides = Map<String, String>.from(state.teeOverrides);
    newOverrides[entryId] = teeName;
    state = state.copyWith(teeOverrides: newOverrides);
    
    // Persist as JSON
    ref.read(persistenceServiceProvider).setString(_keyTeeOverrides, jsonEncode(newOverrides));
  }

  void clearManualTee(String entryId) {
    debugPrint(' [Provider] Clearing Manual Tee for $entryId');
    final Map<String, String> newOverrides = Map<String, String>.from(state.teeOverrides);
    final exists = newOverrides.containsKey(entryId);
    if (exists) {
      newOverrides.remove(entryId);
      state = state.copyWith(teeOverrides: newOverrides);
      ref.read(persistenceServiceProvider).setString(_keyTeeOverrides, jsonEncode(newOverrides));
      debugPrint(' [Provider] Successfully cleared override for $entryId');
    } else {
      debugPrint(' [Provider] No override found to clear for $entryId (already Auto)');
    }
  }
}

final markerSelectionProvider = NotifierProvider<MarkerSelectionNotifier, MarkerSelection>(() => MarkerSelectionNotifier());
