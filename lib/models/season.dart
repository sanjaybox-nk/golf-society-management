import 'package:freezed_annotation/freezed_annotation.dart';

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
    @Default(SeasonStatus.active) SeasonStatus status,
    @Default(false) bool isCurrent,
    // Add AGM data later if needed, dynamic map for now
    @Default({}) Map<String, dynamic> agmData,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
}
