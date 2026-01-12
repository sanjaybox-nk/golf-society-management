import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/member.dart';
import 'members_repository.dart';

class FirestoreMembersRepository implements MembersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Member> _membersRef() {
    return _firestore.collection('members').withConverter<Member>(
      fromFirestore: (doc, _) {
        final data = doc.data()!;
        // Ensure ID is set from doc ID if missing (though we usually set it)
        return Member.fromJson({...data, 'id': doc.id});
      },
      toFirestore: (member, _) {
        final json = member.toJson();
        // Remove ID
        json.remove('id');
        return json;
      },
    );
  }

  @override
  Stream<List<Member>> watchMembers() {
    return _membersRef()
        .orderBy('lastName') // Default sort
        .snapshots()
        .map((snapshot) {
          final members = snapshot.docs.map((doc) => doc.data()).toList();
          for (var m in members) {
            print('📦 Firestore Member: ${m.firstName} has avatar: ${m.avatarUrl}');
          }
          return members;
        });
  }

  @override
  Future<List<Member>> getMembers() async {
    final snapshot = await _membersRef().get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<void> addMember(Member member) async {
    // If ID is empty, let Firestore generate it
    if (member.id.isEmpty) {
      await _membersRef().add(member);
    } else {
      await _membersRef().doc(member.id).set(member);
    }
  }

  @override
  Future<void> updateMember(Member member) async {
    await _membersRef().doc(member.id).set(member);
  }

  @override
  Future<void> deleteMember(String id) async {
    await _membersRef().doc(id).delete();
  }
}
