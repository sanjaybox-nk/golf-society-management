import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/models/scorecard.dart';
import 'scorecard_repository.dart';

class FirestoreScorecardRepository implements ScorecardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addScorecard(Scorecard scorecard) async {
    await _firestore.collection('scorecards').doc(scorecard.id.isEmpty ? null : scorecard.id).set(scorecard.toJson());
  }

  @override
  Future<void> updateScorecard(Scorecard scorecard) async {
    await _firestore.collection('scorecards').doc(scorecard.id).update(scorecard.toJson());
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
}
