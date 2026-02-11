import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../../core/services/persistence_service.dart';
import '../../../../models/competition.dart';
import '../../../../models/golf_event.dart';

// [LAB MODE] Master Toggle
class LabModeEnabled extends Notifier<bool> {
  static const _key = 'lab_mode_enabled';
  @override
  bool build() => ref.watch(persistenceServiceProvider).getBool(_key) ?? false;
  void toggle() {
    state = !state;
    ref.read(persistenceServiceProvider).setBool(_key, state);
  }
}
final labModeEnabledProvider = NotifierProvider<LabModeEnabled, bool>(LabModeEnabled.new);

// [LAB MODE] Rich Stats Mode Control
class RichStatsMode extends Notifier<int> {
  static const _key = 'lab_rich_stats_mode';
  @override
  int build() {
    return ref.watch(persistenceServiceProvider).getInt(_key) ?? 0;
  }
  void set(int val) {
    state = val;
    ref.read(persistenceServiceProvider).setInt(_key, val);
  }
}
final richStatsModeProvider = NotifierProvider<RichStatsMode, int>(RichStatsMode.new);

// [LAB MODE] Provider to override the competition format for testing
class GameFormatOverride extends Notifier<CompetitionFormat?> {
  static const _key = 'lab_game_format';
  @override
  CompetitionFormat? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    final saved = ref.watch(persistenceServiceProvider).getString(_key);
    if (saved != null) return CompetitionFormat.values.firstWhereOrNull((e) => e.name == saved);
    return null;
  }
  void set(CompetitionFormat? format) {
    state = format;
    if (format != null) {
      ref.read(persistenceServiceProvider).setString(_key, format.name);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final gameFormatOverrideProvider = NotifierProvider<GameFormatOverride, CompetitionFormat?>(GameFormatOverride.new);

// [LAB MODE] Provider to override the competition mode (Singles/Pairs/Teams) for testing
class GameModeOverride extends Notifier<CompetitionMode?> {
  static const _key = 'lab_game_mode';
  @override
  CompetitionMode? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    final saved = ref.watch(persistenceServiceProvider).getString(_key);
    if (saved != null) return CompetitionMode.values.firstWhereOrNull((e) => e.name == saved);
    return null;
  }
  void set(CompetitionMode? mode) {
    state = mode;
    if (mode != null) {
      ref.read(persistenceServiceProvider).setString(_key, mode.name);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final gameModeOverrideProvider = NotifierProvider<GameModeOverride, CompetitionMode?>(GameModeOverride.new);

// [LAB MODE] Overrides for Scoring State
class ScoringForceActiveOverride extends Notifier<bool?> {
  static const _key = 'lab_force_active';
  @override
  bool? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    return ref.watch(persistenceServiceProvider).getBool(_key);
  }
  void set(bool? val) {
    state = val;
    if (val != null) {
      ref.read(persistenceServiceProvider).setBool(_key, val);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final scoringForceActiveOverrideProvider = NotifierProvider<ScoringForceActiveOverride, bool?>(ScoringForceActiveOverride.new);

class IsScoringLockedOverride extends Notifier<bool?> {
  static const _key = 'lab_force_unlock';
  @override
  bool? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    return ref.watch(persistenceServiceProvider).getBool(_key);
  }
  void set(bool? val) {
    state = val;
    if (val != null) {
      ref.read(persistenceServiceProvider).setBool(_key, val);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final isScoringLockedOverrideProvider = NotifierProvider<IsScoringLockedOverride, bool?>(IsScoringLockedOverride.new);

// [LAB MODE] Provider to simulate empty data (Fresh Start)
class SimulateEmptyData extends Notifier<bool> {
  static const _key = 'lab_simulate_empty';
  @override
  bool build() {
    if (!ref.watch(labModeEnabledProvider)) return false;
    return ref.watch(persistenceServiceProvider).getBool(_key) ?? false;
  }
  void toggle() {
    state = !state;
    ref.read(persistenceServiceProvider).setBool(_key, state);
  }
}
final simulateEmptyDataProvider = NotifierProvider<SimulateEmptyData, bool>(SimulateEmptyData.new);

// [LAB MODE] Scoring Type (Net vs Gross)
enum ScoringType { net, gross }
class ScoringTypeOverride extends Notifier<ScoringType?> {
  static const _key = 'lab_scoring_type';
  @override
  ScoringType? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    final saved = ref.watch(persistenceServiceProvider).getString(_key);
    if (saved != null) return ScoringType.values.firstWhereOrNull((e) => e.name == saved);
    return null;
  }
  void set(ScoringType? val) {
    state = val;
    if (val != null) {
      ref.read(persistenceServiceProvider).setString(_key, val.name);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final scoringTypeOverrideProvider = NotifierProvider<ScoringTypeOverride, ScoringType?>(ScoringTypeOverride.new);

// [LAB MODE] Handicap Cap Override
class HandicapCapOverride extends Notifier<int?> {
  static const _key = 'lab_handicap_cap';
  @override
  int? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    return ref.watch(persistenceServiceProvider).getInt(_key);
  }
  void set(int? val) {
    state = val;
    if (val != null) {
      ref.read(persistenceServiceProvider).setInt(_key, val);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final handicapCapOverrideProvider = NotifierProvider<HandicapCapOverride, int?>(HandicapCapOverride.new);

// [LAB MODE] Provider to override Event Status locally
class EventStatusOverride extends Notifier<EventStatus?> {
  static const _key = 'lab_event_status';
  @override
  EventStatus? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    final saved = ref.watch(persistenceServiceProvider).getString(_key);
    if (saved != null) return EventStatus.values.firstWhereOrNull((e) => e.name == saved);
    return null;
  }
  void set(EventStatus? status) {
    state = status;
    if (status != null) {
      ref.read(persistenceServiceProvider).setString(_key, status.name);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final eventStatusOverrideProvider = NotifierProvider<EventStatusOverride, EventStatus?>(EventStatusOverride.new);

// [LAB MODE] Stats Released Override
class IsStatsReleasedOverride extends Notifier<bool?> {
  static const _key = 'lab_stats_released';
  @override
  bool? build() {
    return ref.watch(persistenceServiceProvider).getBool(_key);
  }
  void set(bool? val) {
    state = val;
    if (val != null) {
      ref.read(persistenceServiceProvider).setBool(_key, val);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final isStatsReleasedOverrideProvider = NotifierProvider<IsStatsReleasedOverride, bool?>(IsStatsReleasedOverride.new);

// [LAB MODE] Rule Tuning Overrides
class HandicapAllowanceOverride extends Notifier<double?> {
  static const _key = 'lab_handicap_allowance';
  @override
  double? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    return ref.watch(persistenceServiceProvider).getDouble(_key);
  }
  void set(double? val) {
    state = val;
    if (val != null) {
      ref.read(persistenceServiceProvider).setDouble(_key, val);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final handicapAllowanceOverrideProvider = NotifierProvider<HandicapAllowanceOverride, double?>(HandicapAllowanceOverride.new);

class TeamBestXCountOverride extends Notifier<int?> {
  static const _key = 'lab_team_best_x';
  @override
  int? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    return ref.watch(persistenceServiceProvider).getInt(_key);
  }
  void set(int? val) {
    state = val;
    if (val != null) {
      ref.read(persistenceServiceProvider).setInt(_key, val);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final teamBestXCountOverrideProvider = NotifierProvider<TeamBestXCountOverride, int?>(TeamBestXCountOverride.new);

class AggregationMethodOverride extends Notifier<String?> {
  static const _key = 'lab_aggregation_method';
  @override
  String? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    return ref.watch(persistenceServiceProvider).getString(_key);
  }
  void set(String? val) {
    state = val;
    if (val != null) {
      ref.read(persistenceServiceProvider).setString(_key, val);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final aggregationMethodOverrideProvider = NotifierProvider<AggregationMethodOverride, String?>(AggregationMethodOverride.new);

// [LAB MODE] Simulation Holes Override
class SimulationHolesNotifier extends Notifier<int?> {
  @override
  int? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    return null;
  }
  
  void set(int? value) => state = value;
}
final simulationHoleCountOverrideProvider = NotifierProvider<SimulationHolesNotifier, int?>(SimulationHolesNotifier.new);

// [LAB MODE] Max Score Configuration Overrides
class MaxScoreTypeOverride extends Notifier<MaxScoreType?> {
  static const _key = 'lab_max_score_type';
  @override
  MaxScoreType? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    final saved = ref.watch(persistenceServiceProvider).getString(_key);
    if (saved != null) return MaxScoreType.values.firstWhereOrNull((e) => e.name == saved);
    return null;
  }
  void set(MaxScoreType? val) {
    state = val;
    if (val != null) {
      ref.read(persistenceServiceProvider).setString(_key, val.name);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final maxScoreTypeOverrideProvider = NotifierProvider<MaxScoreTypeOverride, MaxScoreType?>(MaxScoreTypeOverride.new);

class MaxScoreValueOverride extends Notifier<int?> {
  static const _key = 'lab_max_score_value';
  @override
  int? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    return ref.watch(persistenceServiceProvider).getInt(_key);
  }
  void set(int? val) {
    state = val;
    if (val != null) {
      ref.read(persistenceServiceProvider).setInt(_key, val);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final maxScoreValueOverrideProvider = NotifierProvider<MaxScoreValueOverride, int?>(MaxScoreValueOverride.new);

// [LAB MODE] Matchplay Subtype Override
class MatchplaySubtypeOverride extends Notifier<CompetitionSubtype?> {
  static const _key = 'lab_matchplay_subtype';
  @override
  CompetitionSubtype? build() {
    if (!ref.watch(labModeEnabledProvider)) return null;
    final saved = ref.watch(persistenceServiceProvider).getString(_key);
    if (saved != null) return CompetitionSubtype.values.firstWhereOrNull((e) => e.name == saved);
    return null;
  }
  void set(CompetitionSubtype? val) {
    state = val;
    if (val != null) {
      ref.read(persistenceServiceProvider).setString(_key, val.name);
    } else {
      ref.read(persistenceServiceProvider).remove(_key);
    }
  }
}
final matchplaySubtypeOverrideProvider = NotifierProvider<MatchplaySubtypeOverride, CompetitionSubtype?>(MatchplaySubtypeOverride.new);
