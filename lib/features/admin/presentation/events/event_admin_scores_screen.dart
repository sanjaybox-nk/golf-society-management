import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../events/presentation/tabs/event_stats_tab.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/scorecard.dart';

import '../../../competitions/presentation/competitions_provider.dart';
import 'widgets/admin_scorecard_list.dart';

import '../../../events/logic/event_analysis_engine.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../debug/presentation/state/debug_providers.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../events/presentation/widgets/event_leaderboard.dart';
import '../../../events/presentation/widgets/scorecard_modal.dart';

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
        final primary = Theme.of(context).primaryColor;
        
        // Clear optimistic toggles if they match the server state
        _optimisticToggles.removeWhere((key, val) {
          if (key == 'isStatsReleased') return val == event.isStatsReleased;
          return false;
        });

        return HeadlessScaffold(
          title: 'Manage Scores',
          subtitle: event.title,
          showBack: true,
          onBack: () => context.go('/admin/events'),
          actions: [
            BoxyArtGlassIconButton(
              icon: Icons.settings_outlined,
              tooltip: 'Controls',
              iconColor: _selectedTab == 0 ? primary : primary.withValues(alpha: 0.4),
              backgroundColor: _selectedTab == 0 ? Colors.white.withValues(alpha: 0.9) : primary.withValues(alpha: 0.05),
              onPressed: () => setState(() => _selectedTab = 0),
            ),
            const SizedBox(width: 8),
            BoxyArtGlassIconButton(
              icon: Icons.emoji_events_outlined,
              tooltip: 'Leaderboard',
              iconColor: _selectedTab == 1 ? primary : primary.withValues(alpha: 0.4),
              backgroundColor: _selectedTab == 1 ? Colors.white.withValues(alpha: 0.9) : primary.withValues(alpha: 0.05),
              onPressed: () => setState(() => _selectedTab = 1),
            ),
            const SizedBox(width: 8),
            BoxyArtGlassIconButton(
              icon: Icons.people_outline,
              tooltip: 'Scorecards',
              iconColor: _selectedTab == 2 ? primary : primary.withValues(alpha: 0.4),
              backgroundColor: _selectedTab == 2 ? Colors.white.withValues(alpha: 0.9) : primary.withValues(alpha: 0.05),
              onPressed: () => setState(() => _selectedTab = 2),
            ),
            const SizedBox(width: 8),
            BoxyArtGlassIconButton(
              icon: Icons.analytics_outlined,
              tooltip: 'Stats',
              iconColor: _selectedTab == 3 ? primary : primary.withValues(alpha: 0.4),
              backgroundColor: _selectedTab == 3 ? Colors.white.withValues(alpha: 0.9) : primary.withValues(alpha: 0.05),
              onPressed: () => setState(() => _selectedTab = 3),
            ),
          ],
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _buildTabContent(event, scorecardsAsync),
              ),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(title: 'Loading...', slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))]),
      error: (err, st) => HeadlessScaffold(title: 'Error', slivers: [SliverFillRemaining(child: Center(child: Text('Error: $err')))]),
    );
  }


  Widget _buildTabContent(GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) {
    switch (_selectedTab) {
      case 0: // Controls
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(event, scorecardsAsync),
            const SizedBox(height: 24),
            const BoxyArtSectionTitle(title: 'ANALYTICS & STATS'),
            const SizedBox(height: 12),
            BoxyArtFloatingCard(
              child: Column(
                children: [
                   _buildControlRow(
                    context,
                    icon: Icons.analytics_outlined,
                    title: 'Show Live Stats to Players',
                    subtitle: 'Allow players to see live-calculated analytics during the event.',
                    value: _optimisticToggles['isStatsReleased'] ?? (event.isStatsReleased == true),
                    onChanged: (val) {
                      setState(() => _optimisticToggles['isStatsReleased'] = val);
                      ref.read(eventsRepositoryProvider).updateEvent(
                        event.copyWith(isStatsReleased: val),
                      );
                    },
                  ),
                  const Divider(height: 32),
                   _buildControlRow(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Close Event & Finalize',
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
                  const Divider(height: 32),
                  const SizedBox(height: 12),
                  BoxyArtButton(
                    title: 'RECALCULATE STATS',
                    fullWidth: true,
                    isSecondary: true,
                    onTap: () => _recalculateStats(event, scorecardsAsync),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Finalized: ${event.finalizedStats.isNotEmpty ? "Ready" : "Never"}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      case 1: // Leaderboard
        final membersAsync = ref.watch(allMembersProvider);
        return Column(
          children: [
            const BoxyArtSectionTitle(title: 'LIVE STANDINGS'),
            const SizedBox(height: 16),
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
            BoxyArtSectionTitle(title: 'PLAYER SCORECARDS (${event.registrations.where((r) => r.attendingGolf).length})'),
            const SizedBox(height: 12),
            scorecardsAsync.when(
              data: (scorecards) => AdminScorecardList(
                event: event,
                scorecards: scorecards,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ],
        );
      case 3: // Stats
        // [Lab Mode Simulation]
        final simulationHoles = ref.watch(simulationHoleCountOverrideProvider);
        final statusOverride = ref.watch(eventStatusOverrideProvider);
        final effectiveStatus = statusOverride ?? event.status;
        final Map<String, int> playerHoleLimits = {};

        if (simulationHoles != null && effectiveStatus == EventStatus.inPlay) {
          final groupsData = event.grouping['groups'] as List?;
          if (groupsData != null) {
            final List<TeeGroup> groups = groupsData.map((g) => TeeGroup.fromJson(g)).toList();
            for (int i = 0; i < groups.length; i++) {
              final groupLimit = (simulationHoles - i).clamp(0, 18);
              for (var p in groups[i].players) {
                playerHoleLimits[p.registrationMemberId] = groupLimit;
                playerHoleLimits['${p.registrationMemberId}_guest'] = groupLimit;
              }
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              EventStatsTab(
                event: event,
                comp: ref.watch(competitionDetailProvider(event.id)).value,
                liveScorecards: scorecardsAsync.value ?? [],
                isAdmin: true,
                playerHoleLimits: playerHoleLimits,
              ),
              const SizedBox(height: 80),
            ],
          ),
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
      event.copyWith(finalizedStats: stats),
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
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('CLOSE', style: TextStyle(color: Colors.red))),
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
    final isSameDayOrFuture = now.year == event.date.year && 
                             now.month == event.date.month && 
                             now.day == event.date.day || 
                             now.isAfter(event.date);
    
    final bool isLive = isSameDayOrFuture && event.isScoringLocked != true;
    final bool isClosed = event.status == EventStatus.completed || event.isScoringLocked == true;
    final status = isClosed ? 'CLOSED' : (isLive ? 'LIVE' : 'PENDING');
    final statusColor = isClosed ? Colors.red : (isLive ? Colors.green : Colors.orange);

    return Row(
      children: [
        Expanded(
          child: _buildBadgeCard('STATUS', status, statusColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBadgeCard(
            'SUBMITTED', 
            '$submittedCount / $totalGolfers', 
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(String label, String value, Color color) {
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value, 
          onChanged: onChanged,
          activeTrackColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}
