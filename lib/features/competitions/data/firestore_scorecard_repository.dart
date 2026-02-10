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
        .map((snapshot) => snapshot.docs.map((doc) => _mapScorecard(doc)).toList());
  }
  @override
  Future<Scorecard?> getScorecard(String id) async {
    final doc = await _firestore.collection('scorecards').doc(id).get();
    if (!doc.exists) return null;
    return _mapScorecard(doc);
  }

  Scorecard _mapScorecard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    
    // Safety for mandatory dates to avoid "Null is not a subtype of Object" 
    // This happens because generated code casts json['updatedAt'] as Object 
    // before passing to the converter.
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
