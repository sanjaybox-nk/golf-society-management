import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/leaderboard_config.dart';

abstract class LeaderboardTemplatesRepository {
  Stream<List<LeaderboardConfig>> watchTemplates();
  Future<String> addTemplate(LeaderboardConfig template);
  Future<void> updateTemplate(LeaderboardConfig template);
  Future<void> deleteTemplate(String id);
}

class FirestoreLeaderboardTemplatesRepository implements LeaderboardTemplatesRepository {
  final FirebaseFirestore _firestore;

  FirestoreLeaderboardTemplatesRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> _collection() {
    return _firestore.collection('leaderboard_templates');
  }

  @override
  Stream<List<LeaderboardConfig>> watchTemplates() {
    return _collection()
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaderboardConfig.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<String> addTemplate(LeaderboardConfig template) async {
    final docRef = await _collection().add(template.toJson());
    return docRef.id;
  }

  @override
  Future<void> updateTemplate(LeaderboardConfig template) async {
    if (template.id.isEmpty) throw Exception('Template ID is required for update');
    await _collection().doc(template.id).update(template.toJson());
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _collection().doc(id).delete();
  }
}
