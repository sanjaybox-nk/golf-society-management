import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/leaderboard_standing.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';

final leaderboardStandingsProvider = StreamProvider.family<List<LeaderboardStanding>, ({String seasonId, String leaderboardId})>((ref, params) {
   final repo = ref.watch(seasonsRepositoryProvider);
   return repo.watchLeaderboardStandings(params.seasonId, params.leaderboardId);
});
