import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';

final leaderboardStandingsProvider = StreamProvider.family<List<LeaderboardStanding>, ({String seasonId, String leaderboardId})>((ref, params) {
   final repo = ref.watch(seasonsRepositoryProvider);
   return repo.watchLeaderboardStandings(params.seasonId, params.leaderboardId);
});

final leaderboardTemplatesProvider = StreamProvider<List<LeaderboardConfig>>((ref) {
  return ref.watch(leaderboardTemplatesRepositoryProvider).watchTemplates();
});
