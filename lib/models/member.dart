import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/status_colors.dart';

part 'member.freezed.dart';
part 'member.g.dart';

// Converter to handle Firestore Timestamp objects
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return null;
  }

  @override
  Object? toJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}

enum MemberRole { 
  superAdmin,
  admin, 
  restrictedAdmin,
  viewer,
  member 
}
enum MemberStatus { 
  member, 
  active, // For compatibility
  inactive, // For compatibility 
  pending,
  suspended, 
  archived, 
  left 
}

extension MemberStatusX on MemberStatus {
  String get displayName => name[0].toUpperCase() + name.substring(1).toLowerCase();

  Color get color {
    switch (this) {
      case MemberStatus.member:
      case MemberStatus.active:
        return StatusColors.positive;
      case MemberStatus.pending:
        return StatusColors.warning;
      case MemberStatus.suspended:
        return StatusColors.negative;
      case MemberStatus.archived:
      case MemberStatus.inactive:
      case MemberStatus.left:
        return StatusColors.neutral;
    }
  }
}

@freezed
abstract class Member with _$Member {
  const Member._();
  
  const factory Member({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    String? nickname,
    String? phone,
    String? address,
    String? bio,
    String? avatarUrl,
    @Default(0.0) double handicap,
    String? whsNumber,
    @Default(false) bool isHandicapLocked,
    @Default(MemberRole.member) MemberRole role,
    String? societyRole, // [NEW]
    @Default(MemberStatus.member) MemberStatus status,
    @Default(false) bool hasPaid,
    @Default(false) bool isArchived,
    @TimestampConverter() DateTime? joinedDate,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}
