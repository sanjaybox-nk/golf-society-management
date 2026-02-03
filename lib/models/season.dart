import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';

part 'season.freezed.dart';
part 'season.g.dart';

enum SeasonStatus { active, closed }

enum PointsMode { position, stableford, combined }

enum TiePolicy { countback, shared, playoff }

@freezed
abstract class Season with _$Season {
  const Season._();
  
  const factory Season({
    required String id,
    required String name,
    required int year,
    @TimestampConverter() required DateTime startDate,
    @TimestampConverter() required DateTime endDate,
    @Default(SeasonStatus.active) SeasonStatus status,
    @Default(false) bool isCurrent,
    @Default(PointsMode.position) PointsMode pointsMode,
    @Default(8) int bestN,
    @Default(TiePolicy.countback) TiePolicy tiePolicy,
    @Default({}) Map<String, dynamic> participationPointsRules,
    @Default({}) Map<String, dynamic> eclecticRules,
    @Default({}) Map<String, dynamic> agmData,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
}
