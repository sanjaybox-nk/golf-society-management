import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        return Colors.green.shade700;
      case MemberStatus.pending:
        return Colors.blue.shade700;
      case MemberStatus.suspended:
        return Colors.orange.shade800;
      case MemberStatus.archived:
      case MemberStatus.inactive:
        return Colors.grey.shade600;
      case MemberStatus.left:
        return Colors.red.shade700;
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
