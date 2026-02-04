import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/competition.dart';
import '../../../models/scorecard.dart';
import 'competitions_repository.dart';

class FirestoreCompetitionsRepository implements CompetitionsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Competition> _compsRef() {
    return _firestore.collection('competitions').withConverter<Competition>(
      fromFirestore: (doc, _) => Competition.fromJson({...doc.data()!, 'id': doc.id}),
      toFirestore: (comp, _) {
        final json = comp.toJson();
        json.remove('id');
        return json;
      },
    );
  }

  CollectionReference<Scorecard> _scorecardsRef(String competitionId) {
    return _firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('scorecards')
        .withConverter<Scorecard>(
      fromFirestore: (doc, _) => Scorecard.fromJson({...doc.data()!, 'id': doc.id}),
      toFirestore: (card, _) {
        final json = card.toJson();
        json.remove('id');
        return json;
      },
    );
  }

  @override
  Stream<List<Competition>> watchCompetitions({CompetitionStatus? status}) {
    var query = _firestore.collection('competitions').where('isTemplate', isEqualTo: false);
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Competition.fromJson(doc.data())).toList();
    });
  }

  @override
  Future<List<Competition>> getCompetitions() async {
    final snapshot = await _firestore.collection('competitions')
        .where('isTemplate', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) => Competition.fromJson(doc.data())).toList();
  }
  @override
  Future<Competition?> getCompetition(String id) async {
    final doc = await _compsRef().doc(id).get();
    return doc.data();
  }

  @override
  Future<String> addCompetition(Competition competition) async {
    final doc = await _compsRef().add(competition);
    return doc.id;
  }

  @override
  Future<void> updateCompetition(Competition competition) async {
    await _compsRef().doc(competition.id).set(competition);
  }

  @override
  Future<void> deleteCompetition(String id) async {
    await _compsRef().doc(id).delete();
  }

  @override
  Stream<List<Competition>> watchTemplates() {
    return _firestore
        .collection('templates')
        .withConverter<Competition>(
          fromFirestore: (doc, _) => Competition.fromJson({...doc.data()!, 'id': doc.id}),
          toFirestore: (comp, _) => comp.toJson()..remove('id'),
        )
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  @override
  Future<String> addTemplate(Competition template) async {
    final doc = await _firestore.collection('templates').add(template.toJson()..remove('id'));
    return doc.id;
  }

  @override
  Future<void> updateTemplate(Competition template) async {
    await _firestore.collection('templates').doc(template.id).set(template.toJson()..remove('id'));
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
    await _scorecardsRef(scorecard.competitionId).doc(scorecard.id).set(scorecard);
  }

  @override
  Future<List<Competition>> getTemplates() async {
    final querySnapshot = await _firestore.collection('templates').get();
    return querySnapshot.docs.map((doc) => Competition.fromJson({...doc.data(), 'id': doc.id})).toList();
  }
}
