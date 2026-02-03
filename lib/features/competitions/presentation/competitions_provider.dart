import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/competition.dart';
import '../data/competitions_repository.dart';
import '../data/firestore_competitions_repository.dart';
import '../data/scorecard_repository.dart';
import '../data/firestore_scorecard_repository.dart';

final competitionsRepositoryProvider = Provider<CompetitionsRepository>((ref) {
  return FirestoreCompetitionsRepository();
});

final scorecardRepositoryProvider = Provider<ScorecardRepository>((ref) {
  return FirestoreScorecardRepository();
});

final competitionsListProvider = StreamProvider.family<List<Competition>, CompetitionStatus?>((ref, status) {
  return ref.watch(competitionsRepositoryProvider).watchCompetitions(status: status);
});

final templatesListProvider = StreamProvider<List<Competition>>((ref) {
  return ref.watch(competitionsRepositoryProvider).watchTemplates();
});

final competitionDetailProvider = FutureProvider.family<Competition?, String>((ref, id) {
  return ref.watch(competitionsRepositoryProvider).getCompetition(id);
});
