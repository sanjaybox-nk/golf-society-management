import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:golf_society/utils/json_converters.dart';

part 'guest_profile.freezed.dart';
part 'guest_profile.g.dart';

@freezed
abstract class GuestProfile with _$GuestProfile {
  const GuestProfile._();

  const factory GuestProfile({
    required String id,
    required String name,
    required String email,
    @Default(28.0) double handicap,
    @OptionalTimestampConverter() DateTime? firstPlayedAt,
    @OptionalTimestampConverter() DateTime? lastPlayedAt,
    @Default(0) int eventCount,
  }) = _GuestProfile;

  factory GuestProfile.fromJson(Map<String, dynamic> json) =>
      _$GuestProfileFromJson(json);
  @override
  Map<String, dynamic> toJson();
}
