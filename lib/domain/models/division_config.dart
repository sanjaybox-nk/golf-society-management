import 'package:freezed_annotation/freezed_annotation.dart';

part 'division_config.freezed.dart';
part 'division_config.g.dart';

/// Which division a member belongs to, after applying threshold + gender split.
enum Division {
  div1,       // HC <= threshold (or voluntary upgrade)
  div2,       // HC > threshold
  div1Ladies, // HC <= threshold, female (when genderSeparated)
  div2Ladies, // HC > threshold, female (when genderSeparated)
}

@freezed
abstract class DivisionConfig with _$DivisionConfig {
  const factory DivisionConfig({
    /// Handicap index cut-off. Members at or below are Div 1; above are Div 2.
    @Default(12.0) double threshold,

    /// When true, female members form separate Div 1 Ladies / Div 2 Ladies pools.
    @Default(false) bool genderSeparated,

    /// Member IDs granted voluntary upgrade to Div 1.
    /// Their playing HC is capped at [threshold] during scoring.
    @Default([]) List<String> voluntaryDiv1MemberIds,
  }) = _DivisionConfig;

  factory DivisionConfig.fromJson(Map<String, dynamic> json) =>
      _$DivisionConfigFromJson(json);
}
