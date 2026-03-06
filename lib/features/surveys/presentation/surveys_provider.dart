import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/domain/models/survey.dart';
import '../data/surveys_repository.dart';
import '../data/firestore_surveys_repository.dart';

final surveysRepositoryProvider = Provider<SurveysRepository>((ref) {
  return FirestoreSurveysRepository(FirebaseFirestore.instance);
});

final surveysProvider = StreamProvider<List<Survey>>((ref) {
  return ref.watch(surveysRepositoryProvider).watchSurveys();
});

final activeSurveysProvider = StreamProvider<List<Survey>>((ref) {
  return ref.watch(surveysProvider).when(
    data: (surveys) {
      final now = DateTime.now();
      return Stream.value(surveys.where((s) {
        if (!s.isPublished) return false;
        if (s.deadline != null && s.deadline!.isBefore(now)) return false;
        return true;
      }).toList());
    },
    loading: () => Stream.value([]),
    error: (_, _) => Stream.value([]),
  );
});

final surveyProvider = StreamProvider.family<Survey?, String>((ref, id) {
  return ref.watch(surveysRepositoryProvider).watchSurvey(id);
});
