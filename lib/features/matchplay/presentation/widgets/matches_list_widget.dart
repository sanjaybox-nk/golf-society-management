import 'package:golf_society/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../domain/match_definition.dart';
import '../../domain/match_play_calculator.dart';
import '../../domain/golf_event_match_extensions.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../members/presentation/members_provider.dart';

class MatchesListWidget extends ConsumerWidget {
  final String eventId;
  final Function(MatchDefinition)? onTap;

  const MatchesListWidget({super.key, required this.eventId, this.onTap});

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

                return _MatchTile(
                  match: match, 
                  result: result,
                  onTap: onTap != null ? () => onTap!(match) : null,
                );
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

class _MatchTile extends ConsumerWidget {
  final MatchDefinition match;
  final MatchResult result;
  final VoidCallback? onTap;

  const _MatchTile({required this.match, required this.result, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final members = ref.watch(allMembersProvider).value ?? [];
    
    final memberA = match.team1Ids.isNotEmpty ? members.firstWhereOrNull((m) => m.id == match.team1Ids.first) : null;
    final memberB = match.team2Ids.isNotEmpty ? members.firstWhereOrNull((m) => m.id == match.team2Ids.first) : null;

    final content = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BoxyArtCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: [
            // Side A
            BoxyArtMemberRow(
              name: (match.team1Name ?? memberA?.displayName ?? 'Side A'), // Removed .toUpperCase()
              initials: (match.team1Name?.isNotEmpty == true ? match.team1Name![0] : (memberA?.displayName != null && memberA!.displayName.isNotEmpty ? memberA.displayName[0] : 'A')).toUpperCase(),
              avatarUrl: memberA?.avatarUrl,
              handicapIndex: memberA?.handicap,
              matchSide: 'A',
              useCard: false,
              showChevron: false,
              showVerticalDivider: true,
              accentColor: AppColors.lime600,
              varietyPillarColor: AppColors.lime600,
            ),
            
            // VS Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                   const Expanded(child: BoxyArtDivider(verticalPadding: 0)),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                     child: Text(
                       'VS',
                       style: AppTypography.micro.copyWith(
                         color: AppColors.textTertiary,
                         fontWeight: AppTypography.weightBlack,
                         letterSpacing: 2.0,
                       ),
                     ),
                   ),
                   const Expanded(child: BoxyArtDivider(verticalPadding: 0)),
                ],
              ),
            ),
            
            // Side B
            BoxyArtMemberRow(
              name: (match.team2Name ?? memberB?.displayName ?? 'Side B'), // Removed .toUpperCase()
              initials: (match.team2Name?.isNotEmpty == true ? match.team2Name![0] : (memberB?.displayName != null && memberB!.displayName.isNotEmpty ? memberB.displayName[0] : 'B')).toUpperCase(),
              avatarUrl: memberB?.avatarUrl,
              handicapIndex: memberB?.handicap,
              matchSide: 'B',
              useCard: false,
              showChevron: false,
              showVerticalDivider: true,
              accentColor: AppColors.amber500,
              varietyPillarColor: AppColors.amber500,
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Result Pill
            BoxyArtIndicator.status(
              label: result.status,
              color: _getStatusColor(result.status, theme, match),
              hasHorizontalMargin: false,
            ),
            
            if (match.manualResult != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'MANUAL RESULT',
                style: AppTypography.micro.copyWith(
                  color: AppColors.amber500,
                  fontWeight: AppTypography.weightBlack,
                  letterSpacing: 1.0,
                ),
              ),
            ],
            
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
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.rMd),
        child: content,
      );
    }
    return content;
  }

  Color _getStatusColor(String status, ThemeData theme, MatchDefinition match) {
    if (match.manualResult != null) return AppColors.amber500;
    if (status == 'A/S') return AppColors.amber500;
    if (status.contains('UP') || status.contains('&')) {
       // In match play, we use Team A / Team B colors if we can detect the winner
       return theme.colorScheme.primary; 
    }
    return AppColors.textTertiary;
  }
}
