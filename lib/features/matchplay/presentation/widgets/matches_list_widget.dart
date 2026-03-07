import 'package:golf_society/design_system/design_system.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/match_definition.dart';
import '../../domain/match_play_calculator.dart';
import '../../domain/golf_event_match_extensions.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';

class MatchesListWidget extends ConsumerWidget {
  final String eventId;

  const MatchesListWidget({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));

    return eventAsync.when(
      data: (event) {
        final matches = event.matches;
        if (matches.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.x4l),
              child: Text('No matches defined for this event.', style: TextStyle(color: AppColors.textSecondary)),
            ),
          );
        }

        return scorecardsAsync.when(
          data: (scorecards) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final result = MatchPlayCalculator.calculate(
                  match: match,
                  scorecards: scorecards,
                  courseConfig: event.courseConfig,
                  holesToPlay: event.courseConfig.holes.length,
                );

                return _MatchTile(match: match, result: result);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _MatchTile extends StatelessWidget {
  final MatchDefinition match;
  final MatchResult result;

  const _MatchTile({required this.match, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppShapes.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.team1Name ?? 'Side A',
                        style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeBodySmall),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text('vs', style: TextStyle(color: AppColors.textSecondary, fontSize: AppTypography.sizeLabel, fontStyle: FontStyle.italic)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        match.team2Name ?? 'Side B',
                        style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeBodySmall),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: _getStatusColor(result.status).withValues(alpha: AppColors.opacityLow),
                borderRadius: AppShapes.xl,
                border: Border.all(color: _getStatusColor(result.status).withValues(alpha: AppColors.opacityMuted)),
              ),
              child: Text(
                result.status,
                style: TextStyle(
                  color: _getStatusColor(result.status),
                  fontWeight: AppTypography.weightBold,
                  fontSize: AppTypography.sizeLabel,
                ),
              ),
            ),
            if (result.holesPlayed > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Through ${result.holesPlayed} holes',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: AppTypography.sizeCaptionStrong),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'A/S') return AppColors.amber500;
    if (status.contains('UP') || status.contains('&')) return AppColors.teamA;
    return AppColors.textSecondary;
  }
}
