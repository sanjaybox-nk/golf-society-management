import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';
part 'member.g.dart';

enum MemberRole { admin, member }

@freezed
abstract class Member with _$Member {
  const Member._();
  
  const factory Member({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? address,
    String? bio,
    String? avatarUrl,
    @Default(0.0) double handicap,
    String? whsNumber,
    @Default(false) bool isHandicapLocked,
    @Default(MemberRole.member) MemberRole role,
    @Default(false) bool hasPaid,
    @Default(false) bool isArchived,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}
