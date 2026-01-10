import 'package:freezed_annotation/freezed_annotation.dart';
import 'golf_event.dart';

part 'season.freezed.dart';
part 'season.g.dart';

@freezed
abstract class Season with _$Season {
  const Season._();
  
  const factory Season({
    required String id,
    required int year,
    @Default([]) List<GolfEvent> events,
    // Add AGM data later if needed, dynamic map for now
    @Default({}) Map<String, dynamic> agmData,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
}
