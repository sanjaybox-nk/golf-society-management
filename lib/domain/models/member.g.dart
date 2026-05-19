// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Member _$MemberFromJson(Map<String, dynamic> json) => _Member(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  nickname: json['nickname'] as String?,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  bio: json['bio'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  handicap: (json['handicap'] as num?)?.toDouble() ?? 0.0,
  handicapId: json['handicapId'] as String?,
  isHandicapLocked: json['isHandicapLocked'] as bool? ?? false,
  role:
      $enumDecodeNullable(_$MemberRoleEnumMap, json['role']) ??
      MemberRole.member,
  societyRole: json['societyRole'] as String?,
  status:
      $enumDecodeNullable(_$MemberStatusEnumMap, json['status']) ??
      MemberStatus.member,
  hasPaid: json['hasPaid'] as bool? ?? false,
  isArchived: json['isArchived'] as bool? ?? false,
  accountCredit: (json['accountCredit'] as num?)?.toDouble() ?? 0.0,
  gender: json['gender'] as String?,
  joinedDate: const OptionalTimestampConverter().fromJson(json['joinedDate']),
  membershipEndDate: const OptionalTimestampConverter().fromJson(
    json['membershipEndDate'],
  ),
  renewalStatus:
      $enumDecodeNullable(
        _$MemberRenewalStatusEnumMap,
        json['renewalStatus'],
      ) ??
      MemberRenewalStatus.none,
  allowSocialEventsOnly: json['allowSocialEventsOnly'] as bool? ?? false,
  lastNudgedAt: const OptionalTimestampConverter().fromJson(
    json['lastNudgedAt'],
  ),
  nudgeCount: (json['nudgeCount'] as num?)?.toInt() ?? 0,
  handicapHistory:
      (json['handicapHistory'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      const [],
  isFoundingMember: json['isFoundingMember'] as bool? ?? false,
);

Map<String, dynamic> _$MemberToJson(_Member instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'nickname': instance.nickname,
  'phone': instance.phone,
  'address': instance.address,
  'bio': instance.bio,
  'avatarUrl': instance.avatarUrl,
  'handicap': instance.handicap,
  'handicapId': instance.handicapId,
  'isHandicapLocked': instance.isHandicapLocked,
  'role': _$MemberRoleEnumMap[instance.role]!,
  'societyRole': instance.societyRole,
  'status': _$MemberStatusEnumMap[instance.status]!,
  'hasPaid': instance.hasPaid,
  'isArchived': instance.isArchived,
  'accountCredit': instance.accountCredit,
  'gender': instance.gender,
  'joinedDate': const OptionalTimestampConverter().toJson(instance.joinedDate),
  'membershipEndDate': const OptionalTimestampConverter().toJson(
    instance.membershipEndDate,
  ),
  'renewalStatus': _$MemberRenewalStatusEnumMap[instance.renewalStatus]!,
  'allowSocialEventsOnly': instance.allowSocialEventsOnly,
  'lastNudgedAt': const OptionalTimestampConverter().toJson(
    instance.lastNudgedAt,
  ),
  'nudgeCount': instance.nudgeCount,
  'handicapHistory': instance.handicapHistory,
  'isFoundingMember': instance.isFoundingMember,
};

const _$MemberRoleEnumMap = {
  MemberRole.superAdmin: 'superAdmin',
  MemberRole.admin: 'admin',
  MemberRole.restrictedAdmin: 'restrictedAdmin',
  MemberRole.scorer: 'scorer',
  MemberRole.viewer: 'viewer',
  MemberRole.member: 'member',
  MemberRole.socialMember: 'socialMember',
};

const _$MemberStatusEnumMap = {
  MemberStatus.member: 'member',
  MemberStatus.active: 'active',
  MemberStatus.inactive: 'inactive',
  MemberStatus.pending: 'pending',
  MemberStatus.suspended: 'suspended',
  MemberStatus.archived: 'archived',
  MemberStatus.left: 'left',
  MemberStatus.expired: 'expired',
  MemberStatus.gracePeriod: 'gracePeriod',
  MemberStatus.social: 'social',
};

const _$MemberRenewalStatusEnumMap = {
  MemberRenewalStatus.none: 'none',
  MemberRenewalStatus.renew: 'renew',
  MemberRenewalStatus.suspend: 'suspend',
  MemberRenewalStatus.leave: 'leave',
};
