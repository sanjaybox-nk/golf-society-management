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
          loading: () => const BoxyArtLoadingCard(useCard: false),
          error: (e, s) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const BoxyArtLoadingCard(useCard: false),
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: IntrinsicHeight(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Side A
                  Expanded(
                    child: Column(
                      children: [
                        BoxyArtAvatar(
                          url: null, // Teams usually don't have personal avatars here
                          initials: match.team1Name?.substring(0, 1) ?? 'A',
                          radius: 24,
                          borderColor: result.status.contains('UP') && !result.status.contains('Side B') ? AppColors.teamA : Colors.transparent,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          match.team1Name ?? 'Side A',
                          style: AppTypography.captionStrong.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),

                  // VS Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      children: [
                        const Text(
                          'VS',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            fontWeight: AppTypography.weightExtraBold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          width: 1,
                          height: 40,
                          color: theme.dividerColor.withValues(alpha: AppColors.opacitySubtle),
                        ),
                      ],
                    ),
                  ),

                  // Side B
                  Expanded(
                    child: Column(
                      children: [
                        BoxyArtAvatar(
                          url: null,
                          initials: match.team2Name?.substring(0, 1) ?? 'B',
                          radius: 24,
                          borderColor: result.status.contains('UP') && result.status.contains('Side B') ? AppColors.teamB : Colors.transparent,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          match.team2Name ?? 'Side B',
                          style: AppTypography.captionStrong.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Result Pill
              BoxyArtPill.status(
                label: result.status,
                color: _getStatusColor(result.status, theme),
                hasHorizontalMargin: false,
              ),
              
              if (result.holesPlayed > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  result.holesPlayed == 18 ? 'Final Result' : 'Through ${result.holesPlayed} holes',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppTypography.weightMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    if (status == 'A/S') return AppColors.amber500;
    if (status.contains('UP') || status.contains('&')) {
       // In match play, we use Team A / Team B colors if we can detect the winner
       return theme.colorScheme.primary; 
    }
    return AppColors.textTertiary;
  }
}
