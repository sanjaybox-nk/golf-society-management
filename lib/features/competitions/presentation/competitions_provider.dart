import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/competition.dart';
import '../data/competitions_repository.dart';
import '../data/firestore_competitions_repository.dart';
import '../data/scorecard_repository.dart';
import '../data/firestore_scorecard_repository.dart';
import '../../../models/scorecard.dart';
import '../../members/presentation/profile_provider.dart';

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

final competitionDetailProvider = StreamProvider.family<Competition?, String>((ref, id) {
  return ref.watch(competitionsRepositoryProvider).watchCompetition(id);
});

final scorecardsListProvider = StreamProvider.family<List<Scorecard>, String>((ref, competitionId) {
  return ref.watch(scorecardRepositoryProvider).watchScorecards(competitionId);
});

final userScorecardProvider = Provider.family<Scorecard?, String>((ref, competitionId) {
  final scorecardsAsync = ref.watch(scorecardsListProvider(competitionId));
  final currentMember = ref.watch(effectiveUserProvider);
  
  return scorecardsAsync.when(
    data: (scorecards) => scorecards.where((s) => s.entryId == currentMember.id).firstOrNull,
    loading: () => null,
    error: (e, s) => null,
  );
});

final scorecardByEntryIdProvider = Provider.family<Scorecard?, ({String competitionId, String entryId})>((ref, params) {
  final scorecardsAsync = ref.watch(scorecardsListProvider(params.competitionId));
  
  return scorecardsAsync.when(
    data: (scorecards) => scorecards.where((s) => s.entryId == params.entryId).firstOrNull,
    loading: () => null,
    error: (e, s) => null,
  );
});
