import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/models/scorecard.dart';
import 'scorecard_repository.dart';

class FirestoreScorecardRepository implements ScorecardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Scorecard> get _scorecardsRef =>
      _firestore.collection('scorecards').withConverter<Scorecard>(
        fromFirestore: (snapshot, _) => _mapFirestoreToScorecard(snapshot),
        toFirestore: (scorecard, _) {
          final json = scorecard.toJson();
          json.remove('id');
          return json;
        },
      );

  static Scorecard _mapFirestoreToScorecard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    
    // Safety for mandatory dates to avoid "Null is not a subtype of Object" 
    if (data['createdAt'] == null) data['createdAt'] = Timestamp.now();
    if (data['updatedAt'] == null) data['updatedAt'] = Timestamp.now();
    
    // Safety for mandatory strings
    if (data['competitionId'] == null) data['competitionId'] = 'unknown';
    if (data['roundId'] == null) data['roundId'] = '1';
    if (data['entryId'] == null) data['entryId'] = 'unknown';
    if (data['submittedByUserId'] == null) data['submittedByUserId'] = 'unknown';
    
    return Scorecard.fromJson(data);
  }

  @override
  Future<void> addScorecard(Scorecard scorecard) async {
    if (scorecard.id.isEmpty) {
      await _scorecardsRef.add(scorecard);
    } else {
      await _scorecardsRef.doc(scorecard.id).set(scorecard);
    }
  }

  @override
  Future<void> updateScorecard(Scorecard scorecard) async {
    await _scorecardsRef.doc(scorecard.id).set(scorecard, SetOptions(merge: true));
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
    await _scorecardsRef.doc(id).delete();
  }

  @override
  Stream<List<Scorecard>> watchScorecards(String competitionId) {
    return _scorecardsRef
        .where('competitionId', isEqualTo: competitionId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<Scorecard?> getScorecard(String id) async {
    final doc = await _scorecardsRef.doc(id).get();
    return doc.data();
  }

  @override
  Future<void> deleteAllScorecards(String competitionId) async {
    final snapshot = await _scorecardsRef
        .where('competitionId', isEqualTo: competitionId)
        .get();
        
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
