import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';
import 'leaderboard_config.dart';

part 'season.freezed.dart';
part 'season.g.dart';

enum SeasonStatus { active, closed }

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
    @Default([]) List<LeaderboardConfig> leaderboards,
    @Default({}) Map<String, dynamic> agmData,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
}
