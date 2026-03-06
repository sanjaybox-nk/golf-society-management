import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:golf_society/utils/json_converters.dart';

part 'audit_activity.freezed.dart';
part 'audit_activity.g.dart';

enum ActivityType { registration, score, event, payment, other }

@freezed
abstract class AuditActivity with _$AuditActivity {
  const factory AuditActivity({
    required String id,
    required String message,
    required ActivityType type,
    @TimestampConverter() required DateTime timestamp,
    String? userId,
    String? userName,
    String? relatedId,
  }) = _AuditActivity;

  factory AuditActivity.fromJson(Map<String, dynamic> json) => _$AuditActivityFromJson(json);

  // Helper for UI styling
  static (IconData, Color) getAppearance(ActivityType type) {
    switch (type) {
      case ActivityType.registration:
        return (Icons.person_add_rounded, Colors.blue);
      case ActivityType.score:
        return (Icons.sports_score_rounded, Colors.green);
      case ActivityType.payment:
        return (Icons.payments_rounded, Colors.orange);
      case ActivityType.event:
        return (Icons.campaign_rounded, Colors.purple);
      case ActivityType.other:
        return (Icons.info_outline_rounded, Colors.grey);
    }
  }
}
