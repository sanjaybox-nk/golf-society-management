import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../events/presentation/tabs/event_stats_tab.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';

import '../../../competitions/presentation/competitions_provider.dart';
import 'widgets/admin_scorecard_list.dart';

import '../../../events/logic/event_analysis_engine.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../events/presentation/widgets/event_leaderboard.dart';
import '../../../events/presentation/widgets/scorecard_modal.dart';
import '../../../events/domain/registration_logic.dart';

class EventAdminScoresScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventAdminScoresScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventAdminScoresScreen> createState() => _EventAdminScoresScreenState();
}

class _EventAdminScoresScreenState extends ConsumerState<EventAdminScoresScreen> {
  int _selectedTab = 0;
  final Map<String, bool> _optimisticToggles = {};

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));

    return eventAsync.when(
      data: (event) {
        
        // Clear optimistic toggles if they match the server state
        _optimisticToggles.removeWhere((key, val) {
          if (key == 'isStatsReleased') return val == event.isStatsReleased;
          return false;
        });

        return HeadlessScaffold(
          title: 'Scores',
          subtitle: event.title,
          useScaffold: false,
          showBack: true,
          onBack: () => context.go('/admin/events'),
          actions: const [],
          slivers: [
            SliverToBoxAdapter(
              child: ModernUnderlinedFilterBar<int>(
                selectedValue: _selectedTab,
                onTabSelected: (val) => setState(() => _selectedTab = val),
                tabs: const [
                  ModernFilterTab(label: 'Controls', value: 0),
                  ModernFilterTab(label: 'Leaderboard', value: 1),
                  ModernFilterTab(label: 'Scorecards', value: 2),
                  ModernFilterTab(label: 'Stats', value: 3),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: _buildTabContent(event, scorecardsAsync),
              ),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(title: 'Loading...', useScaffold: false, slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))]),
      error: (err, st) => HeadlessScaffold(title: 'Error', useScaffold: false, slivers: [SliverFillRemaining(child: Center(child: Text('Error: $err')))]),
    );
  }


  Widget _buildTabContent(GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) {
    final membersAsync = ref.watch(allMembersProvider);
    switch (_selectedTab) {
      case 0: // Controls
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(event, scorecardsAsync),
            const SizedBox(height: AppSpacing.x2l),
            const BoxyArtSectionTitle(title: 'ANALYTICS & STATS'),
            const SizedBox(height: AppSpacing.md),
            BoxyArtCard(
              child: Column(
                children: [
                   ModernSwitchRow(
                    icon: Icons.analytics_outlined,
                    label: 'Show Live Stats to Players',
                    subtitle: 'Allow players to see live-calculated analytics during the event.',
                    value: _optimisticToggles['isStatsReleased'] ?? (event.isStatsReleased == true),
                    onChanged: (val) {
                      setState(() => _optimisticToggles['isStatsReleased'] = val);
                      ref.read(eventsRepositoryProvider).updateEvent(
                        event.copyWith(isStatsReleased: val),
                      );
                    },
                  ),
                  const Divider(height: AppSpacing.x3l),
                   ModernSwitchRow(
                    icon: Icons.lock_outline,
                    label: 'Close Event & Finalize',
                    subtitle: 'Lock scorecards and calculate final society statistics.',
                    value: event.status == EventStatus.completed,
                    onChanged: (val) {
                      if (val) {
                        _closeEvent(event, scorecardsAsync);
                      } else {
                        _reopenEvent(event);
                      }
                    },
                  ),
                  const Divider(height: AppSpacing.x3l),
                  const SizedBox(height: AppSpacing.md),
                  BoxyArtButton(
                    title: 'RECALCULATE STATS',
                    fullWidth: true,
                    isSecondary: true,
                    onTap: () => _recalculateStats(event, scorecardsAsync),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Last Finalized: ${event.finalizedStats.isNotEmpty ? "Ready" : "Never"}',
                    style: const TextStyle(fontSize: AppTypography.sizeCaption, color: AppColors.textSecondary, fontWeight: AppTypography.weightBold),
                  ),
                ],
              ),
            ),
          ],
        );
      case 1: // Leaderboard
        return Column(
          children: [
            const BoxyArtSectionTitle(title: 'LIVE STANDINGS'),
            const SizedBox(height: AppSpacing.lg),
            scorecardsAsync.when(
              data: (scorecards) => EventLeaderboard(
                event: event,
                comp: ref.watch(competitionDetailProvider(event.id)).value,
                liveScorecards: scorecards,
                membersList: membersAsync.value ?? [],
                showTitles: false, // We already have the title above
                onPlayerTap: (entry) {
                  // Admin navigation to scorecard modal first
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
      case 2: // Scorecards
        return Column(
          children: [
            BoxyArtSectionTitle(title: 'PLAYER SCORECARDS (${RegistrationLogic.getPlayingParticipants(event).length})'),
            const SizedBox(height: AppSpacing.md),
            scorecardsAsync.when(
              data: (scorecards) => AdminScorecardList(
                event: event,
                scorecards: scorecards,
                membersList: membersAsync.value ?? [],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ],
        );
      case 3: // Stats
        final Map<String, int> playerHoleLimits = {};

        return Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            EventStatsTab(
                event: event,
                comp: ref.watch(competitionDetailProvider(event.id)).value,
                liveScorecards: scorecardsAsync.value ?? [],
                isAdmin: true,
                playerHoleLimits: playerHoleLimits,
              ),
              const SizedBox(height: 80),
            ],
        );
      default:
        return const SizedBox.shrink();
    }
  }


  Future<Map<String, dynamic>?> _recalculateStats(GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) async {
    final scorecards = scorecardsAsync.value;
    if (scorecards == null || scorecards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No scores available to calculate stats.')),
      );
      return null;
    }

    final compAsync = ref.read(competitionDetailProvider(event.id));
    final competition = compAsync.value;
    if (competition == null) return null;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculating stats...'), duration: Duration(seconds: 1)),
    );

    final stats = EventAnalysisEngine.calculateFinalStats(
      event: event,
      competition: competition,
      scorecards: scorecards,
    );

    await ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(
        finalizedStats: stats,
        results: (stats['results'] as List?)?.cast<Map<String, dynamic>>() ?? event.results,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stats recalculated and saved!')),
      );
    }
    return stats;
  }

  Future<void> _closeEvent(GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Event?'),
        content: const Text('This will lock all scorecards, finalize the results, and mark the event as completed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('CLOSE', style: TextStyle(color: AppColors.coral500))),
        ],
      ),
    );

    if (confirmed == true) {
      final stats = await _recalculateStats(event, scorecardsAsync);
      await ref.read(eventsRepositoryProvider).updateEvent(
        event.copyWith(
          status: EventStatus.completed,
          isScoringLocked: true,
          finalizedStats: stats ?? {},
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event Closed & Stats Finalized')),
        );
      }
    }
  }

  Future<void> _reopenEvent(GolfEvent event) async {
    await ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(
        status: EventStatus.inPlay,
        isScoringLocked: false,
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Reopened')),
      );
    }
  }

  Widget _buildStatusHeader(GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) {
    
    // Calculate stats
    int totalGolfers = 0;
    for (final r in event.registrations) {
      if (r.attendingGolf && r.isConfirmed) totalGolfers++;
      if (r.attendingGolf && r.isGuest && r.guestIsConfirmed) totalGolfers++;
    }
    
    final submittedCount = scorecardsAsync.when(
      data: (scorecards) => scorecards.where((s) => 
        s.status == ScorecardStatus.submitted || s.status == ScorecardStatus.finalScore
      ).length,
      loading: () => 0,
      error: (err, st) => 0,
    );

    final now = DateTime.now();
    final bool isToday = now.year == event.date.year && 
                        now.month == event.date.month && 
                        now.day == event.date.day;
    final bool isPast = event.date.isBefore(now) && !isToday;
    
    final bool isClosed = event.status == EventStatus.completed || event.isScoringLocked == true;
    final bool isLive = (isToday || event.status == EventStatus.inPlay) && !isClosed;
    
    String status;
    Color statusColor;
    
    if (isClosed) {
      status = 'CLOSED';
      statusColor = Theme.of(context).colorScheme.error;
    } else if (isLive) {
      status = 'LIVE';
      statusColor = Theme.of(context).colorScheme.primary;
    } else if (isPast) {
      status = 'PAST';
      statusColor = AppColors.amber500;
    } else {
      status = 'UPCOMING';
      statusColor = AppColors.teamA;
    }

    return Row(
      children: [
        Expanded(
          child: _buildBadgeCard('STATUS', status, statusColor),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildBadgeCard(
            'SUBMITTED', 
            '$submittedCount / $totalGolfers', 
            AppColors.teamA,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(String label, String value, Color color) {
    return BoxyArtCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2l, horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBlack, color: AppColors.textSecondary, letterSpacing: 1.1)),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: TextStyle(fontSize: AppTypography.sizeLargeBody, fontWeight: AppTypography.weightBlack, color: color)),
        ],
      ),
    );
  }
}
