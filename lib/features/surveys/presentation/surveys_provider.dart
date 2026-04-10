import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/domain/models/survey.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import '../data/surveys_repository.dart';
import '../data/firestore_surveys_repository.dart';

final surveysRepositoryProvider = Provider<SurveysRepository>((ref) {
  return FirestoreSurveysRepository(FirebaseFirestore.instance);
});

final surveysProvider = StreamProvider<List<Survey>>((ref) {
  return ref.watch(surveysRepositoryProvider).watchSurveys();
});

final activeSurveysProvider = StreamProvider<List<Survey>>((ref) async* {
  final currentUser = ref.watch(effectiveUserProvider);
  final surveysAsync = ref.watch(surveysProvider);

  yield* surveysAsync.when(
    data: (surveys) {
      final now = DateTime.now();
      return Stream.value(surveys.where((s) {
        if (!s.isPublished) return false;
        if (s.deadline != null && s.deadline!.isBefore(now)) return false;
        // Hide if already answered or dismissed by current user
        if (s.responses.containsKey(currentUser.id)) return false;
        if (s.dismissedBy.contains(currentUser.id)) return false;
        return true;
      }).toList());
    },
    loading: () => const Stream.empty(),
    error: (_, __) => Stream.value(<Survey>[]),
  );
});

final surveyProvider = StreamProvider.family<Survey?, String>((ref, id) {
  return ref.watch(surveysRepositoryProvider).watchSurvey(id);
});
