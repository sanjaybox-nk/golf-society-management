import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_config.freezed.dart';
part 'course_config.g.dart';

@freezed
abstract class TeeConfig with _$TeeConfig {
  const factory TeeConfig({
    required String name,
    required double rating,
    required int slope,
    required List<int> holePars,
    required List<int> holeSIs,
    required List<int> yardages,
  }) = _TeeConfig;

  factory TeeConfig.fromJson(Map<String, dynamic> json) => _$TeeConfigFromJson(json);
}

@freezed
abstract class CourseHole with _$CourseHole {
  const factory CourseHole({
    required int hole,
    required int par,
    required int si,
    int? yardage,
  }) = _CourseHole;

  factory CourseHole.fromJson(Map<String, dynamic> json) => _$CourseHoleFromJson(json);
}

@freezed
abstract class CourseConfig with _$CourseConfig {
  const factory CourseConfig({
    @Default('') String name,
    @Default('') String address,
    @Default([]) List<TeeConfig> tees,
    @Default([]) List<CourseHole> holes, // Flattened/Resolved holes for the event
    double? rating,
    int? slope,
    int? par,
    String? selectedTeeName,
    @Default(true) bool isGlobal,
  }) = _CourseConfig;

  factory CourseConfig.fromJson(Map<String, dynamic> json) => _$CourseConfigFromJson(json);
}
