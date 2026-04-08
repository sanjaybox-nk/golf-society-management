import 'package:freezed_annotation/freezed_annotation.dart';
import 'golf_event.dart'; // For EventNote

part 'campaign.freezed.dart';
part 'campaign.g.dart';

enum CampaignStatus { draft, sent }

@freezed
abstract class Campaign with _$Campaign {
  const Campaign._();

  const factory Campaign({
    required String id,
    required String title,
    String? message, // Keep for legacy but optional now
    @Default([]) List<EventNote> notes, // Multi-section support
    required String category, // Urgent, Event, News
    required String targetType, // All Members, Groups, Individual
    required int recipientCount,
    @Default(CampaignStatus.sent) CampaignStatus status,
    required DateTime timestamp,
    String? sentByUserId, // Admin ID who sent it
    String? actionUrl,
    String? targetDescription, // e.g. "Committee" or "John Doe"
  }) = _Campaign;

  factory Campaign.fromJson(Map<String, dynamic> json) => 
      _$CampaignFromJson(json);
}
