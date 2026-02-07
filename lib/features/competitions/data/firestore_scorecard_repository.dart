import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/models/scorecard.dart';
import 'scorecard_repository.dart';

class FirestoreScorecardRepository implements ScorecardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addScorecard(Scorecard scorecard) async {
    final docRef = scorecard.id.isEmpty 
        ? _firestore.collection('scorecards').doc() 
        : _firestore.collection('scorecards').doc(scorecard.id);
        
    await docRef.set(scorecard.copyWith(id: docRef.id).toJson());
  }

  @override
  Future<void> updateScorecard(Scorecard scorecard) async {
    await _firestore.collection('scorecards').doc(scorecard.id).update(scorecard.toJson());
  }

  @override
  Future<void> updateScorecardStatus(String id, ScorecardStatus status) async {
    await _firestore.collection('scorecards').doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteScorecard(String id) async {
    await _firestore.collection('scorecards').doc(id).delete();
  }

  @override
  Stream<List<Scorecard>> watchScorecards(String competitionId) {
    return _firestore
        .collection('scorecards')
        .where('competitionId', isEqualTo: competitionId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Scorecard.fromJson(doc.data())).toList());
  }

  @override
  Future<Scorecard?> getScorecard(String id) async {
    final doc = await _firestore.collection('scorecards').doc(id).get();
    if (!doc.exists) return null;
    return Scorecard.fromJson(doc.data()!);
  }

  @override
  Future<void> deleteAllScorecards(String competitionId) async {
    final snapshot = await _firestore
        .collection('scorecards')
        .where('competitionId', isEqualTo: competitionId)
        .get();
        
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
