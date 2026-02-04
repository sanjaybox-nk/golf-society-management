import '../../../models/member.dart';

abstract class MembersRepository {
  Stream<List<Member>> watchMembers();
  Future<List<Member>> getMembers();
  Future<Member?> getMember(String id);
  Future<void> addMember(Member member);
  Future<void> updateMember(Member member);
  Future<void> deleteMember(String id);
}
