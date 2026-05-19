import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/json_converters.dart';

part 'member.freezed.dart';
part 'member.g.dart';

enum MemberRole {
  superAdmin,
  admin,
  restrictedAdmin,
  scorer,
  viewer,
  member,
  socialMember,
}

extension MemberRoleX on MemberRole {
  String get displayName {
    switch (this) {
      case MemberRole.superAdmin: return 'Super Admin';
      case MemberRole.admin: return 'Admin';
      case MemberRole.restrictedAdmin: return 'Restricted Admin';
      case MemberRole.scorer: return 'Scorer';
      case MemberRole.viewer: return 'Viewer';
      case MemberRole.member: return 'Member';
      case MemberRole.socialMember: return 'Social Member';
    }
  }

  bool get isScorer => this == MemberRole.scorer;
  bool get isSocialMember => this == MemberRole.socialMember;
  bool get isEventOfficer => this == MemberRole.restrictedAdmin;
  bool get hasAdminAccess => this == MemberRole.superAdmin || this == MemberRole.admin || this == MemberRole.restrictedAdmin;
  bool get isFullAdmin => this == MemberRole.superAdmin || this == MemberRole.admin;
  bool get isFullMember => this == MemberRole.member || hasAdminAccess || isScorer;
}
enum MemberStatus {
  member,
  active,
  inactive,
  pending,
  suspended,
  archived,
  left,
  expired,
  gracePeriod,
  social, // Social-only membership tier — attends social events, no golf
}

enum MemberRenewalStatus {
  none,
  renew,
  suspend,
  leave
}

extension MemberStatusX on MemberStatus {
  String get displayName => name[0].toUpperCase() + name.substring(1).toLowerCase();

  Color get color {
    switch (this) {
      case MemberStatus.member:
      case MemberStatus.active:
        return AppColors.lime500; // Standardized Success
      case MemberStatus.pending:
        return AppColors.teamA;   // Standardized Informative (Blue)
      case MemberStatus.suspended:
        return AppColors.coral500; // Standardized Critical
      case MemberStatus.archived:
      case MemberStatus.inactive:
      case MemberStatus.left:
        return AppColors.dark300; // Standardized Neutral
      case MemberStatus.expired:
        return AppColors.amber500;
      case MemberStatus.gracePeriod:
        return AppColors.amber400;
      case MemberStatus.social:
        return AppColors.guestPurple;
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
    String? handicapId,
    @Default(false) bool isHandicapLocked,
    @Default(MemberRole.member) MemberRole role,
    String? societyRole, // [NEW]
    @Default(MemberStatus.member) MemberStatus status,
    @Default(false) bool hasPaid,
    @Default(false) bool isArchived,
    @Default(0.0) double accountCredit, // Account credit for vouchers or overpayments
    String? gender, // [NEW] 'Male' or 'Female'
    @OptionalTimestampConverter() DateTime? joinedDate,
    @OptionalTimestampConverter() DateTime? membershipEndDate, // [NEW] Track annual renewal term
    @Default(MemberRenewalStatus.none) MemberRenewalStatus renewalStatus, // [NEW] Member renewal choice
    @Default(false) bool allowSocialEventsOnly, // [NEW] Master switch for suspended members
    @OptionalTimestampConverter() DateTime? lastNudgedAt, // [NEW] Track recent renewal nudges
    @Default(0) int nudgeCount, // [NEW] Track frequency of nudges
    @Default([]) List<double> handicapHistory, // [NEW] For trend analysis
    @Default(false) bool isFoundingMember, // [NEW] Honorary founding status
  }) = _Member;

  String get displayName => '$firstName $lastName';

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}
