import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';

abstract class LeaderboardTemplatesRepository {
  Stream<List<LeaderboardConfig>> watchTemplates();
  Future<String> addTemplate(LeaderboardConfig template);
  Future<void> updateTemplate(LeaderboardConfig template);
  Future<void> deleteTemplate(String id);
  Future<LeaderboardConfig?> getTemplate(String id);
  Stream<List<LeaderboardConfig>> watchTemplatesByIds(List<String> ids);
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

  @override
  Future<LeaderboardConfig?> getTemplate(String id) async {
    final doc = await _collection().doc(id).get();
    if (!doc.exists) return null;
    return LeaderboardConfig.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Stream<List<LeaderboardConfig>> watchTemplatesByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);
    return _collection()
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots()
        .map((snapshot) {
          final byId = {
            for (final doc in snapshot.docs)
              doc.id: LeaderboardConfig.fromJson({...doc.data(), 'id': doc.id}),
          };
          return ids
              .where((id) => byId.containsKey(id))
              .map((id) => byId[id]!)
              .toList();
        });
  }
}
