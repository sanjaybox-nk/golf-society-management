import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/json_converters.dart';

part 'member.freezed.dart';
part 'member.g.dart';

enum MemberRole { 
  superAdmin,
  admin, 
  restrictedAdmin,
  viewer,
  member 
}

extension MemberRoleX on MemberRole {
  String get displayName {
    switch (this) {
      case MemberRole.superAdmin: return 'Super Admin';
      case MemberRole.admin: return 'Admin';
      case MemberRole.restrictedAdmin: return 'Restricted Admin';
      case MemberRole.viewer: return 'Viewer';
      case MemberRole.member: return 'Member';
    }
  }
}
enum MemberStatus { 
  member, 
  active, // For compatibility
  inactive, // For compatibility 
  pending,
  suspended, 
  archived, 
  left,
  expired, // [NEW] Membership has ended
  gracePeriod // [NEW] Membership ended but in grace period
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
        return AppColors.dark900;
      case MemberStatus.pending:
        return StatusColors.warning;
      case MemberStatus.suspended:
        return StatusColors.negative;
      case MemberStatus.archived:
      case MemberStatus.inactive:
      case MemberStatus.left:
        return StatusColors.neutral;
      case MemberStatus.expired:
        return StatusColors.negative;
      case MemberStatus.gracePeriod:
        return StatusColors.warning;
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
    String? gender, // [NEW] 'Male' or 'Female'
    @OptionalTimestampConverter() DateTime? joinedDate,
    @OptionalTimestampConverter() DateTime? membershipEndDate, // [NEW] Track annual renewal term
    @Default(MemberRenewalStatus.none) MemberRenewalStatus renewalStatus, // [NEW] Member renewal choice
  }) = _Member;

  String get displayName => '$firstName $lastName';

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}
