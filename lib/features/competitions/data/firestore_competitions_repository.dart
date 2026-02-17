import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/competition.dart';
import '../../../models/scorecard.dart';
import 'competitions_repository.dart';

class FirestoreCompetitionsRepository implements CompetitionsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Competition> get _compsRef =>
      _firestore.collection('competitions').withConverter<Competition>(
        fromFirestore: (snapshot, _) => _mapFirestoreToCompetition(snapshot),
        toFirestore: (comp, _) {
          final json = comp.toJson();
          json.remove('id');
          // Deep serialization for rules - though json_serializable should handle this if configured
          json['rules'] = comp.rules.toJson();
          return json;
        },
      );

  static Competition _mapFirestoreToCompetition(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final Map<String, dynamic> mutableData = Map<String, dynamic>.from(data);
    mutableData['id'] = doc.id;
    return Competition.fromJson(mutableData);
  }

  CollectionReference<Scorecard> _scorecardsRef(String competitionId) {
    return _firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('scorecards')
        .withConverter<Scorecard>(
      fromFirestore: (snapshot, _) => _mapFirestoreToScorecard(snapshot),
      toFirestore: (card, _) {
        final json = card.toJson();
        json.remove('id');
        return json;
      },
    );
  }

  static Scorecard _mapFirestoreToScorecard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final Map<String, dynamic> mutableData = Map<String, dynamic>.from(data);
    mutableData['id'] = doc.id;
    return Scorecard.fromJson(mutableData);
  }

  @override
  Stream<List<Competition>> watchCompetitions({CompetitionStatus? status}) {
    var query = _compsRef.where('isTemplate', isEqualTo: false);
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Future<List<Competition>> getCompetitions() async {
    final snapshot = await _compsRef
        .where('isTemplate', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<Competition?> getCompetition(String id) async {
    final doc = await _compsRef.doc(id).get();
    return doc.data();
  }

  @override
  Stream<Competition?> watchCompetition(String id) {
    return _compsRef.doc(id).snapshots().map((doc) => doc.data());
  }

  @override
  Future<String> addCompetition(Competition competition) async {
    if (competition.id.isEmpty) {
      throw Exception('Cannot add competition with empty ID. Competition must have a valid ID.');
    }
    await _compsRef.doc(competition.id).set(competition);
    return competition.id;
  }

  @override
  Future<void> updateCompetition(Competition competition) async {
    if (competition.id.isEmpty) {
      throw Exception('Cannot update competition with empty ID');
    }
    await _compsRef.doc(competition.id).set(competition, SetOptions(merge: true));
  }

  @override
  Future<void> deleteCompetition(String id) async {
    await _compsRef.doc(id).delete();
  }

  @override
  Stream<List<Competition>> watchTemplates() {
    return _firestore
        .collection('templates')
        .withConverter<Competition>(
          fromFirestore: (snapshot, _) => _mapFirestoreToCompetition(snapshot),
          toFirestore: (comp, _) {
            final json = comp.toJson();
            json.remove('id');
            json['rules'] = comp.rules.toJson();
            return json;
          },
        )
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  @override
  Future<String> addTemplate(Competition template) async {
    final docRefs = _firestore.collection('templates').withConverter<Competition>(
          fromFirestore: (snapshot, _) => _mapFirestoreToCompetition(snapshot),
          toFirestore: (comp, _) {
            final json = comp.toJson();
            json.remove('id');
            json['rules'] = comp.rules.toJson();
            return json;
          },
        );
    
    final doc = await docRefs.add(template);
    return doc.id;
  }

  @override
  Future<void> updateTemplate(Competition template) async {
    final docRefs = _firestore.collection('templates').withConverter<Competition>(
          fromFirestore: (snapshot, _) => _mapFirestoreToCompetition(snapshot),
          toFirestore: (comp, _) {
            final json = comp.toJson();
            json.remove('id');
            json['rules'] = comp.rules.toJson();
            return json;
          },
        );
    await docRefs.doc(template.id).set(template, SetOptions(merge: true));
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _firestore.collection('templates').doc(id).delete();
  }

  @override
  Stream<List<Scorecard>> watchScorecards(String competitionId) {
    return _scorecardsRef(competitionId).snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }

  @override
  Future<void> submitScorecard(Scorecard scorecard) async {
    await _scorecardsRef(scorecard.competitionId).add(scorecard);
  }

  @override
  Future<void> updateScorecard(Scorecard scorecard) async {
    await _scorecardsRef(scorecard.competitionId).doc(scorecard.id).set(scorecard, SetOptions(merge: true));
  }

  @override
  Future<List<Competition>> getTemplates() async {
    final docRefs = _firestore.collection('templates').withConverter<Competition>(
          fromFirestore: (snapshot, _) => _mapFirestoreToCompetition(snapshot),
          toFirestore: (comp, _) => comp.toJson()..remove('id'),
        );
    final querySnapshot = await docRefs.get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
