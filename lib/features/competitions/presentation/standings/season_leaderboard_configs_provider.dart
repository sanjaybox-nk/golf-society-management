import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/season.dart';
import '../../../events/presentation/events_provider.dart';

final seasonLeaderboardConfigsProvider =
    StreamProvider.autoDispose.family<List<LeaderboardConfig>, String>((ref, seasonId) {
  final seasonAsync = ref.watch(seasonByIdProvider(seasonId));
  final season = seasonAsync.value;
  if (season == null) return Stream.value([]);

  // Closed seasons are self-contained — use the snapshot written at archive time.
  // This ensures historical records are preserved even if templates are later edited or deleted.
  if (season.status == SeasonStatus.closed) {
    return Stream.value(season.archivedLeaderboardConfigs);
  }

  // Active seasons use live template references.
  final ids = season.leaderboardIds;
  if (ids.isEmpty) return Stream.value([]);
  return ref.watch(leaderboardTemplatesRepositoryProvider).watchTemplatesByIds(ids);
});
