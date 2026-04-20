import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import '../../../competitions/data/scorecard_repository.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../events/presentation/widgets/event_leaderboard.dart';
import '../../../events/presentation/widgets/scorecard_modal.dart';
import '../../../events/presentation/tabs/event_user_placeholders.dart';
import 'package:golf_society/domain/models/competition.dart';

class AdminScoresTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int value) => state = value;
}

final adminScoresTabProvider = NotifierProvider<AdminScoresTabNotifier, int>(AdminScoresTabNotifier.new);

class EventAdminScoresScreen extends ConsumerWidget {
  final String eventId;
  const EventAdminScoresScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(adminScoresTabProvider);
    final eventAsync = ref.watch(eventProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));

    return eventAsync.when(
      data: (event) {
        
        // Note: Optimistic toggles were removed during the conversion to ConsumerWidget
        // to resolve a potential type stability issue. They can be re-implemented
        // using a specialized provider if needed.

        return HeadlessScaffold(
          title: 'Scores',
          titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
          subtitle: event.title,

          showBack: true,
          onBack: () => context.go('/admin/events'),
          actions: const [],
          slivers: [
            SliverToBoxAdapter(
              child: ModernUnderlinedFilterBar<int>(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                isExpanded: true,
                selectedValue: selectedTab,
                onTabSelected: (val) => ref.read(adminScoresTabProvider.notifier).set(val),
                tabs: const [
                  ModernFilterTab(label: 'Leaderboard', value: 0),
                  ModernFilterTab(label: 'Groups', value: 1),
                  ModernFilterTab(label: 'Verification', value: 2),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: _buildTabContent(context, ref, event, selectedTab, scorecardsAsync),
              ),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(title: 'Loading...', slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))]),
      error: (err, st) => HeadlessScaffold(title: 'Error', slivers: [SliverFillRemaining(child: Center(child: Text('Error: $err')))]),
    );
  }


  Widget _buildTabContent(BuildContext context, WidgetRef ref, GolfEvent event, int selectedTab, AsyncValue<List<Scorecard>> scorecardsAsync) {
    final membersAsync = ref.watch(allMembersProvider);
    switch (selectedTab) {
      case 0: // Leaderboard
        return Column(
          children: [
            const BoxyArtSectionTitle(title: 'Live standings'),
            scorecardsAsync.when(
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
          ],
        );
      case 1: // Group Scores
        return Column(
          children: [
            SharedTournamentLogic.buildGroupScoresTab(
              ref: ref,
              eventId: event.id,
              event: event,
              rules: ref.watch(competitionDetailProvider(event.id)).value?.rules ?? const CompetitionRules(),
              playerHoleLimits: const {},
              teeOverrides: const {},
            ),
          ],
        );
      case 2: // Verification
        return _buildVerificationTab(context, ref, event, scorecardsAsync);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVerificationTab(BuildContext context, WidgetRef ref, GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) {
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
                        final members = ref.read(allMembersProvider).value ?? [];
                        final entry = LeaderboardEntry(
                          entryId: s.entryId,
                          playerName: reg?.memberName ?? 'Unknown',
                          score: s.points ?? 0,
                          position: 0,
                          handicap: s.playingHandicap ?? (s.handicapIndex ?? 0).round(),
                          handicapIndex: s.handicapIndex ?? 0,
                          playingHandicap: s.playingHandicap,
                          avatarUrl: members.firstWhereOrNull((m) => m.id == s.entryId)?.avatarUrl,
                        );
                        ScorecardModal.show(context, ref, entry: entry, scorecards: scorecards, event: event, comp: ref.watch(competitionDetailProvider(event.id)).value, membersList: members, isAdmin: true);
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
