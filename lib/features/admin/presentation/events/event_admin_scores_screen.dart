import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/scorecard.dart';
import '../../../../models/event_registration.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import 'widgets/admin_scorecard_list.dart';
import '../../../../models/competition.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';

class EventAdminScoresScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventAdminScoresScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventAdminScoresScreen> createState() => _EventAdminScoresScreenState();
}

class _EventAdminScoresScreenState extends ConsumerState<EventAdminScoresScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));

    return eventAsync.when(
      data: (event) => Scaffold(
        appBar: BoxyArtAppBar(
          title: 'Event Scores',
          subtitle: event.title,
          centerTitle: true,
          isLarge: true,
          leadingWidth: 70,
          leading: Center(
            child: TextButton(
              onPressed: () => context.canPop() ? context.pop() : context.go('/admin/events'),
              child: const Text('Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  _buildTabButton('Controls', 0, Icons.settings_outlined),
                  _buildTabButton('Leaderboard', 1, Icons.emoji_events_outlined),
                  _buildTabButton('Scorecards', 2, Icons.people_outline),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildTabContent(event, scorecardsAsync),
        ),
      ),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
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
            const BoxyArtSectionTitle(title: 'SCORING CONTROLS'),
            const SizedBox(height: 12),
            BoxyArtFloatingCard(
              child: Column(
                children: [
                  _buildControlRow(
                    context,
                    icon: Icons.rocket_launch,
                    title: 'Force Scoring Active',
                    subtitle: 'Allow players to enter scores before the scheduled date.',
                    value: event.scoringForceActive == true,
                    onChanged: (val) {
                      ref.read(eventsRepositoryProvider).updateEvent(
                        event.copyWith(scoringForceActive: val),
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildControlRow(
                    context,
                    icon: Icons.lock_person,
                    title: 'Lock Final Scores',
                    subtitle: 'Prevent all players from making further edits to their scorecards.',
                    value: event.isScoringLocked == true,
                    onChanged: (val) {
                       ref.read(eventsRepositoryProvider).updateEvent(
                        event.copyWith(isScoringLocked: val),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 32),
                  BoxyArtButton(
                    title: 'RESET ALL SCORES',
                    isSecondary: true,
                    fullWidth: true,
                    onTap: () => _confirmResetAllScores(event),
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
            const SizedBox(height: 16),
            scorecardsAsync.when(
              data: (scorecards) {
                if (scorecards.isEmpty) {
                   return const BoxyArtFloatingCard(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text('No scores submitted yet.')),
                    ),
                  );
                }

                // 1. Filter submitted scores
                final submitted = scorecards.where((s) => 
                  s.status == ScorecardStatus.submitted || s.status == ScorecardStatus.finalScore
                ).toList();

                // 2. Map to entries
                final entries = submitted.map((s) {
                  // Find player name from registrations
                  final reg = event.registrations.firstWhere(
                    (r) => (r.isGuest ? '${r.memberId}_guest' : r.memberId) == s.entryId,
                    orElse: () => EventRegistration(memberId: '', memberName: 'Unknown', attendingGolf: true),
                  );
                  
                  final name = reg.isGuest ? (reg.guestName ?? 'Guest') : reg.memberName;
                  
                  // Estimate handicap (store in scorecard in future, but for now grab from reg or default)
                  final hc = reg.isGuest 
                      ? int.tryParse(reg.guestHandicap ?? '18') ?? 18
                      : 18; // We don't have member handicap map here easily, default 18 for display or fetch

                  return LeaderboardEntry(
                    playerName: name,
                    score: s.points ?? 0, // Default to Stableford points
                    handicap: hc,
                  );
                }).toList();

                // 3. Sort (Desc for points)
                entries.sort((a, b) => b.score.compareTo(a.score));

                return LeaderboardWidget(
                  entries: entries,
                  format: CompetitionFormat.stableford, // Hardcoded for now, should come from competition
                );
              },
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
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _confirmResetAllScores(GolfEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Scores?'),
        content: const Text('This will permanently delete all scorecards and clear the leaderboard for this event. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RESET', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      
      // 1. Delete all scorecard documents
      await ref.read(scorecardRepositoryProvider).deleteAllScorecards(event.id);
      
      // 2. Clear event results (Leaderboard)
      await ref.read(eventsRepositoryProvider).updateEvent(
        event.copyWith(results: []),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All scores and results have been reset.')),
        );
      }
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
    
    final isLive = (event.scoringForceActive == true) || (isSameDayOrFuture && event.isScoringLocked != true);
    final status = (event.isScoringLocked == true) ? 'LOCKED' : (isLive ? 'LIVE' : 'PENDING');
    final statusColor = (event.isScoringLocked == true) ? Colors.red : (isLive ? Colors.green : Colors.orange);

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
