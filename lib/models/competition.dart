import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';

part 'competition.freezed.dart';
part 'competition.g.dart';

enum CompetitionType { game, event }

enum CompetitionStatus { draft, open, scoring, review, published, closed }

enum CompetitionFormat { stroke, stableford, maxScore, matchPlay, scramble }

enum CompetitionSubtype { none, texas, florida, grossStableford, fourball, foursomes }

enum CompetitionMode { singles, pairs, teams }

enum HandicapMode { whs, local, none }

enum TieBreakMethod { back9, back6, back3, back1, playoff }

enum AggregationMethod { singleBest, totalSum, stablefordSum }

enum MaxScoreType { fixed, parPlusX }

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
    @Default(0.95) double handicapAllowance,
    @Default(true) bool useCourseAllowance,
    MaxScoreConfig? maxScoreConfig,
    @Default(1) int roundsCount,
    @Default(AggregationMethod.totalSum) AggregationMethod aggregation,
    @Default(TieBreakMethod.back9) TieBreakMethod tieBreak,
    @Default(true) bool holeByHoleRequired,
    @Default(0) int minDrivesPerPlayer,
    @Default(false) bool useWHSScrambleAllowance,
    @Default(true) bool applyCapToIndex,
    @Default(2) int teamBestXCount,
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
      if (subtype == CompetitionSubtype.fourball) return 'FOURBALL';
      if (subtype == CompetitionSubtype.foursomes) return 'FOURSOMES';
      if (subtype == CompetitionSubtype.grossStableford) return 'GROSS STABLEFORD';
      if (subtype == CompetitionSubtype.texas) return 'TEXAS SCRAMBLE';
      if (subtype == CompetitionSubtype.florida) return 'FLORIDA SCRAMBLE';
      return subtype.name.toUpperCase();
    }
    
    // Split camelCase format (e.g. matchPlay -> MATCH PLAY)
    return format.name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .toUpperCase();
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
}
