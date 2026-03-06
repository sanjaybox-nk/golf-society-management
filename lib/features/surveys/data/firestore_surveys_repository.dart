import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/domain/models/survey.dart';
import 'surveys_repository.dart';

class FirestoreSurveysRepository implements SurveysRepository {
  final FirebaseFirestore _firestore;

  FirestoreSurveysRepository(this._firestore);

  CollectionReference<Survey> get _surveysRef =>
      _firestore.collection('surveys').withConverter<Survey>(
        fromFirestore: (snapshot, _) => _mapFirestoreToSurvey(snapshot),
        toFirestore: (survey, _) {
          final json = survey.toJson();
          json.remove('id');
          return json;
        },
      );

  static Survey _mapFirestoreToSurvey(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final Map<String, dynamic> mutableData = Map<String, dynamic>.from(data);
    mutableData['id'] = doc.id;
    return Survey.fromJson(mutableData);
  }

  @override
  Stream<List<Survey>> watchSurveys() {
    return _surveysRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Stream<Survey?> watchSurvey(String id) {
    return _surveysRef.doc(id).snapshots().map((snapshot) => snapshot.data());
  }

  @override
  Future<List<Survey>> getSurveys() async {
    final snapshot = await _surveysRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<Survey?> getSurvey(String id) async {
    final doc = await _surveysRef.doc(id).get();
    return doc.data();
  }

  @override
  Future<String> addSurvey(Survey survey) async {
    if (survey.id.isEmpty) {
      final docRef = await _surveysRef.add(survey);
      return docRef.id;
    } else {
      await _surveysRef.doc(survey.id).set(survey);
      return survey.id;
    }
  }

  @override
  Future<void> updateSurvey(Survey survey) async {
    await _surveysRef.doc(survey.id).set(survey, SetOptions(merge: true));
  }

  @override
  Future<void> deleteSurvey(String id) async {
    await _surveysRef.doc(id).delete();
  }

  @override
  Future<void> submitResponse(String surveyId, String userId, Map<String, dynamic> answers) async {
    final surveyDoc = _firestore.collection('surveys').doc(surveyId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(surveyDoc);
      if (!snapshot.exists) return;

      final data = snapshot.data();
      final responses = Map<String, dynamic>.from(data?['responses'] ?? {});
      responses[userId] = answers;

      transaction.update(surveyDoc, {'responses': responses});
    });
  }
}
