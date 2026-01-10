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
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  bio: json['bio'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  handicap: (json['handicap'] as num?)?.toDouble() ?? 0.0,
  whsNumber: json['whsNumber'] as String?,
  isHandicapLocked: json['isHandicapLocked'] as bool? ?? false,
  role:
      $enumDecodeNullable(_$MemberRoleEnumMap, json['role']) ??
      MemberRole.member,
  hasPaid: json['hasPaid'] as bool? ?? false,
  isArchived: json['isArchived'] as bool? ?? false,
);

Map<String, dynamic> _$MemberToJson(_Member instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'bio': instance.bio,
  'avatarUrl': instance.avatarUrl,
  'handicap': instance.handicap,
  'whsNumber': instance.whsNumber,
  'isHandicapLocked': instance.isHandicapLocked,
  'role': _$MemberRoleEnumMap[instance.role]!,
  'hasPaid': instance.hasPaid,
  'isArchived': instance.isArchived,
};

const _$MemberRoleEnumMap = {
  MemberRole.admin: 'admin',
  MemberRole.member: 'member',
};
