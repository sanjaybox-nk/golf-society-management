import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:golf_society/utils/json_converters.dart';

part 'competition.freezed.dart';
part 'competition.g.dart';

enum CompetitionType { game, event }

enum CompetitionStatus { draft, open, scoring, review, published, closed }

enum CompetitionFormat { stroke, stableford, maxScore, matchPlay, scramble }

enum CompetitionSubtype { none, texas, florida, grossStableford, fourball, foursomes, ryderCup, teamMatchPlay }

enum CompetitionMode { singles, pairs, teams }

enum HandicapMode { whs, local, none }

enum TieBreakMethod { back9, back6, back3, back1, playoff }

enum AggregationMethod { singleBest, totalSum, stablefordSum }

enum MaxScoreType { fixed, parPlusX, netDoubleBogey }

enum TeamHandicapMethod { whs, average, sum }

@freezed
abstract class MaxScoreConfig with _$MaxScoreConfig {
  const factory MaxScoreConfig({
    @Default(MaxScoreType.parPlusX) MaxScoreType type,
    @Default(5) int value,
  }) = _MaxScoreConfig;

  factory MaxScoreConfig.fromJson(Map<String, dynamic> json) =>
      _$MaxScoreConfigFromJson(json);
}

@freezed
abstract class CompetitionRules with _$CompetitionRules {
  const factory CompetitionRules({
    @Default(CompetitionFormat.stableford) CompetitionFormat format,
    @Default(CompetitionSubtype.none) CompetitionSubtype subtype,
    @Default(CompetitionMode.singles) CompetitionMode mode,
    @Default(HandicapMode.whs) HandicapMode handicapMode,
    @Default(28) int handicapCap,
    @Default(1.0) double handicapAllowance,
    int? teamHandicapCap, // [NEW] For Scramble/Team capping
    @Default(CompetitionFormat.stroke) CompetitionFormat underlyingFormat, // [NEW] For Scramble base logic
    @Default(true) bool useCourseAllowance,
    MaxScoreConfig? maxScoreConfig,
    @Default(1) int roundsCount,
    @Default(AggregationMethod.totalSum) AggregationMethod aggregation,
    @Default(TieBreakMethod.back9) TieBreakMethod tieBreak,
    @Default(true) bool holeByHoleRequired,
    @Default(0) int minDrivesPerPlayer,
    @Default(true) bool useWHSScrambleAllowance,
    @Default(true) bool trackShotAttributions, 
    @Default(true) bool applyCapToIndex,
    @Default(2) int teamBestXCount,
    @Default(4) int teamSize,
    @Default(false) bool useMixedTeeAdjustment, // [NEW] C.R. - Par adjustment
    @Default(TeamHandicapMethod.whs) TeamHandicapMethod teamHandicapMethod, // [NEW] Scramble method
    bool? separateGuests, // [UPDATED] Single override: null = follow society, true = separate, false = hidden
    @Default([]) List<String> oomExcludedRoundIds, // [NEW] Rounds to skip in season standings
  }) = _CompetitionRules;

  factory CompetitionRules.fromJson(Map<String, dynamic> json) =>
      _$CompetitionRulesFromJson(json);
}

@freezed
abstract class Competition with _$Competition {
  const Competition._();

  const factory Competition({
    required String id,
    String? name,
    String? templateId,
    required CompetitionType type,
    @Default(CompetitionStatus.draft) CompetitionStatus status,
    required CompetitionRules rules,
    @TimestampConverter() required DateTime startDate,
    @TimestampConverter() required DateTime endDate,
    @Default({}) Map<String, dynamic> publishSettings,
    @Default(false) bool isDirty,
    int? computeVersion,
    @OptionalTimestampConverter() DateTime? lastComputedAt,
    String? lastComputedBy,
  }) = _Competition;

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(json);
}

extension CompetitionRulesX on CompetitionRules {
  String get gameName {
    if (subtype != CompetitionSubtype.none) {
      return switch (subtype) {
        CompetitionSubtype.texas       => 'Texas Scramble',
        CompetitionSubtype.florida     => 'Florida Scramble',
        CompetitionSubtype.fourball    => 'Fourball',
        CompetitionSubtype.foursomes   => 'Foursomes',
        CompetitionSubtype.ryderCup    => 'Ryder Cup',
        CompetitionSubtype.teamMatchPlay => 'Team Match Play',
        CompetitionSubtype.grossStableford => 'Gross Stableford',
        _                              => subtype.name,
      };
    }
    
    return switch (format) {
      CompetitionFormat.stableford => 'Stableford',
      CompetitionFormat.stroke     => 'Stroke Play',
      CompetitionFormat.maxScore   => 'Max Score',
      CompetitionFormat.matchPlay  => 'Match Play',
      CompetitionFormat.scramble   => 'Scramble',
    };
  }

  String get scoringType {
    if (subtype == CompetitionSubtype.grossStableford) return 'GROSS';
    if (handicapAllowance == 0) return 'GROSS';
    return 'NET';
  }

  String get defaultAllowanceLabel {
    final allowancePercent = (handicapAllowance * 100).round();
    if (format == CompetitionFormat.matchPlay) return '$allowancePercent% DIFF';
    if (format == CompetitionFormat.scramble && useWHSScrambleAllowance) return 'WHS HCP';
    return '$allowancePercent% HCP';
  }

  CompetitionMode get effectiveMode {
    if (subtype == CompetitionSubtype.texas || 
        subtype == CompetitionSubtype.florida ||
        subtype == CompetitionSubtype.ryderCup ||
        subtype == CompetitionSubtype.teamMatchPlay) {
      return CompetitionMode.teams;
    }
    if (subtype == CompetitionSubtype.fourball || 
        subtype == CompetitionSubtype.foursomes) {
      return CompetitionMode.pairs;
    }
    return mode;
  }

  String get modeLabel {
    if (format == CompetitionFormat.scramble) {
      return '$teamSize-MAN TEAM';
    }
    return effectiveMode.name.toUpperCase();
  }
  
  IconData get gameIcon {
    if (subtype != CompetitionSubtype.none) {
      return switch (subtype) {
        CompetitionSubtype.fourball    => Icons.people_outline_rounded,
        CompetitionSubtype.foursomes   => Icons.sync_alt_rounded,
        CompetitionSubtype.texas       => Icons.group_work_rounded,
        CompetitionSubtype.florida     => Icons.group_work_rounded,
        CompetitionSubtype.ryderCup    => Icons.emoji_events_rounded,
        CompetitionSubtype.teamMatchPlay => Icons.compare_arrows_rounded,
        CompetitionSubtype.grossStableford => Icons.format_list_numbered_rounded,
        _                              => Icons.golf_course_rounded,
      };
    }
    
    return switch (format) {
      CompetitionFormat.stableford => Icons.format_list_numbered_rounded,
      CompetitionFormat.stroke     => Icons.golf_course_rounded,
      CompetitionFormat.maxScore   => Icons.vertical_align_top_rounded,
      CompetitionFormat.matchPlay  => Icons.compare_arrows_rounded,
      CompetitionFormat.scramble   => Icons.group_work_rounded,
    };
  }
}
