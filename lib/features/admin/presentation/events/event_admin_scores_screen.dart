import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../events/presentation/widgets/event_leaderboard.dart';
import '../../../events/presentation/widgets/scorecard_modal.dart';
import '../../../matchplay/presentation/widgets/match_play_bracket_hub.dart';

class EventAdminScoresScreen extends ConsumerWidget {
  final String eventId;

  const EventAdminScoresScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(adminEventsProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
    
    // We can use a local state for tab index or just rely on a provider
    // Using a basic state for now as this is a stateless view of the event data
    final selectedTab = 0; // This should ideally be managed by a controller

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) return const Center(child: Text('Event not found'));

        return HeadlessScaffold(
          title: 'Event Scores',
          subtitle: event.title,
          titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
          showBack: true,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: true,
              child: _buildTabContent(context, ref, event, selectedTab, scorecardsAsync),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTabContent(BuildContext context, WidgetRef ref, GolfEvent event, int selectedTab, AsyncValue<List<Scorecard>> scorecardsAsync) {
    final membersAsync = ref.watch(allMembersProvider);
    
    // Determining if it is a match play event
    final isMatchPlay = event.secondaryTemplateId == 'matchplay' || event.groupingStrategy == 'matchplay';

    return Column(
      children: [
        if (isMatchPlay) ...[
             const BoxyArtSectionTitle(title: 'Tournament Bracket'),
             Expanded(child: MatchPlayBracketHub(eventId: event.id)),
        ] else ...[
             const BoxyArtSectionTitle(title: 'Live standings'),
             Expanded(
               child: scorecardsAsync.when(
                 data: (scorecards) => EventLeaderboard(
                   event: event,
                   comp: ref.watch(competitionDetailProvider(event.id)).value,
                   liveScorecards: scorecards,
                   membersList: membersAsync.value ?? [],
                   showTitles: false, 
                   onPlayerTap: (entry) {
                     ScorecardModal.show(
                       context, 
                       ref, 
                       entry: entry, 
                       scorecards: scorecards, 
                       event: event, 
                       comp: ref.watch(competitionDetailProvider(event.id)).value,
                       membersList: membersAsync.value ?? [],
                       isAdmin: true,
                     );
                   },
                 ),
                 loading: () => const Center(child: CircularProgressIndicator()),
                 error: (e, s) => Center(child: Text('Error loading leaderboard: $e')),
               ),
             ),
        ],
      ],
    );
  }

  Widget _buildVerificationTab(BuildContext context, WidgetRef ref, GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) {
    final membersAsync = ref.watch(allMembersProvider);
    return scorecardsAsync.when(
      data: (scorecards) {
        final totalGolfers = event.registrations.where((r) => r.attendingGolf).length;
        final submitted = scorecards.where((s) => s.status == ScorecardStatus.submitted).toList();
        final reviewed = scorecards.where((s) => s.status == ScorecardStatus.reviewed || s.status == ScorecardStatus.finalScore).toList();
        final incomplete = scorecards.where((s) => 
          s.scoringStatus == ScoringStatus.incomplete || 
          (s.holeScores.contains(null) && s.scoringStatus == ScoringStatus.ok)
        ).toList();
        
        final outliers = scorecards.where((s) => s.scoringStatus != ScoringStatus.ok).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoxyArtSectionTitle(title: 'Summary', isPeeking: true),
            Row(
              children: [
                Expanded(child: _buildStatMiniCard('Pending', '${submitted.length}', AppColors.amber500)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildStatMiniCard('Incomplete', '${incomplete.length}', AppColors.coral500)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildStatMiniCard('Reviewed', '${reviewed.length} / $totalGolfers', AppColors.lime500)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            if (submitted.isNotEmpty) ...[
              BoxyArtButton(
                title: 'Review All Submitted',
                icon: Icons.done_all_rounded,
                isPrimary: true,
                fullWidth: true,
                onTap: () async {
                  final confirmed = await showBoxyArtDialog<bool>(
                    context: context,
                    title: 'Approve Scorecards?',
                    message: 'This will mark all ${submitted.length} submitted scorecards as Reviewed.',
                    confirmText: 'Approve',
                  );
                  if (confirmed == true) {
                    await ref.read(scorecardRepositoryProvider).approveAllScorecards(event.id);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            if (incomplete.isNotEmpty || outliers.isNotEmpty) ...[
              const BoxyArtSectionTitle(title: 'Issues to resolve', isPeeking: true),
              ...[...incomplete, ...outliers].map((s) {
                 final reg = event.registrations.firstWhereOrNull((r) => r.memberId == s.entryId);
                 return Padding(
                   padding: const EdgeInsets.only(bottom: AppSpacing.md),
                   child: BoxyArtNavTile(
                     title: reg?.memberName ?? 'Unknown Player',
                     subtitle: s.scoringStatus == ScoringStatus.incomplete ? 'Incomplete Card' : s.scoringStatus.name.toUpperCase(),
                     icon: Icons.warning_amber_rounded,
                     iconColor: AppColors.coral500,
                     onTap: () {
                        // Open scorecard modal for editing
                        final comp = ref.read(competitionDetailProvider(event.id)).value;
                        final members = membersAsync.value ?? [];
                        final entry = LeaderboardEntry(
                          entryId: s.entryId,
                          playerName: reg?.memberName ?? 'Unknown',
                          score: (s.points ?? 0).toInt(),
                          handicap: s.playingHandicap ?? (s.handicapIndex ?? 0).round(),
                          handicapIndex: s.handicapIndex ?? 0,
                          scoringStatus: s.scoringStatus,
                          mode: comp?.rules.mode ?? CompetitionMode.singles,
                          avatarUrl: members.firstWhereOrNull((m) => m.id == s.entryId)?.avatarUrl,
                        );
                        ScorecardModal.show(context, ref, entry: entry, scorecards: scorecards, event: event, comp: comp, membersList: members, isAdmin: true);
                     },
                   ),
                 );
              }),
            ] else ...[
               const BoxyArtEmptyCard(
                 title: 'Verification Complete',
                 message: 'No score discrepancies or incomplete cards found. The field is ready for finalization.',
                 icon: Icons.verified_user_outlined,
               ),
            ],
            const SizedBox(height: AppSpacing.hero),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildStatMiniCard(String label, String value, Color color) {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Text(label, style: AppTypography.micro.copyWith(color: AppColors.textSecondary, fontWeight: AppTypography.weightBold)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.headline.copyWith(color: color)),
        ],
      ),
    );
  }
}
