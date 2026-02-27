
import 'package:freezed_annotation/freezed_annotation.dart';

part 'campaign.freezed.dart';
part 'campaign.g.dart';

@freezed
abstract class Campaign with _$Campaign {
  const Campaign._();

  const factory Campaign({
    required String id,
    required String title,
    required String message,
    required String category, // Urgent, Event, News
    required String targetType, // All Members, Groups, Individual
    required int recipientCount,
    required DateTime timestamp,
    String? sentByUserId, // Admin ID who sent it
    String? actionUrl,
    String? targetDescription, // e.g. "Committee" or "John Doe"
  }) = _Campaign;

  factory Campaign.fromJson(Map<String, dynamic> json) => 
      _$CampaignFromJson(json);
}
