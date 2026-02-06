import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../events_provider.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/features/competitions/presentation/widgets/leaderboard_widget.dart';
import 'package:golf_society/models/competition.dart';
import '../../../members/presentation/members_provider.dart';
import '../widgets/grouping_widgets.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../widgets/course_info_card.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../models/scorecard.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../../models/golf_event.dart';

class EventGroupingUserTab extends ConsumerWidget {
  final String eventId;
  const EventGroupingUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final membersAsync = ref.watch(allMembersProvider);
    final competitionsAsync = ref.watch(competitionsListProvider(null));

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        
        final bool isPublished = event.isGroupingPublished;
        final groupsData = event.grouping['groups'] as List?;
        final List<TeeGroup> groups = groupsData != null 
            ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
            : [];

        return Scaffold(
          appBar: BoxyArtAppBar(
            title: 'Grouping',
            subtitle: event.title,
            showBack: true,
          ),
          body: !isPublished
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_clock_rounded, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Grouping not yet published', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('The Admin will publish the tee sheet soon.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              : groups.every((g) => g.players.isEmpty)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No players confirmed yet', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 48),
                            child: Text(
                              'The field is currently being finalized. Check back once registration is closed.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        final members = membersAsync.value ?? [];
                        final memberMap = {for (var m in members) m.id: m};
                        final history = events.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
                        final comps = competitionsAsync.value ?? [];
                        final comp = comps.where((c) => c.id == event.id).firstOrNull;

                        return GroupingCard(
                          group: group,
                          memberMap: memberMap,
                          history: history,
                          totalGroups: groups.length,
                          rules: comp?.rules,
                          courseConfig: event.courseConfig,
                          isAdmin: false,
                        );
                      },
                    ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

}


class EventScoresUserTab extends ConsumerStatefulWidget {
  final String eventId;
  const EventScoresUserTab({super.key, required this.eventId});

  @override
  ConsumerState<EventScoresUserTab> createState() => _EventScoresUserTabState();
}

class _EventScoresUserTabState extends ConsumerState<EventScoresUserTab> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final compAsync = ref.watch(competitionDetailProvider(widget.eventId));

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == widget.eventId, orElse: () => throw 'Event not found');
        
        return compAsync.when(
          data: (comp) {
            final isStableford = comp?.rules.format == CompetitionFormat.stableford;
            final results = event.results;
            final List<LeaderboardEntry> leaderboardEntries = results.map((r) {
              return LeaderboardEntry(
                playerName: r['playerName'] ?? 'Unknown',
                score: isStableford ? (r['points'] ?? 0) : (r['netTotal'] ?? 0),
                handicap: (r['handicap'] as num?)?.toInt() ?? 0,
              );
            }).toList();

            // If no results, show the original mock or empty?
            // For now, if results are empty, we keep the empty state or show a placeholder.

            return Scaffold(
              appBar: BoxyArtAppBar(
                title: 'Scores',
                subtitle: event.title,
                isLarge: true,
                showBack: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      children: [
                        _buildTabButton('My Score', 0),
                        _buildTabButton('Leaderboard', 1),
                        _buildTabButton('Stats', 2),
                      ],
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildTabContent(event, comp, leaderboardEntries),
              ),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    
    // Define icons for each tab
    IconData icon;
    switch (index) {
      case 0:
        icon = Icons.assignment_outlined;
        break;
      case 1:
        icon = Icons.emoji_events_outlined;
        break;
      case 2:
        icon = Icons.bar_chart;
        break;
      default:
        icon = Icons.help_outline;
    }
    
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

  Widget _buildTabContent(GolfEvent event, Competition? comp, List<LeaderboardEntry> mockEntries) {
    final config = ref.watch(themeControllerProvider);
    final currentUser = ref.watch(currentUserProvider);
    
    final isStableford = comp?.rules.format == CompetitionFormat.stableford;
    final playerHandicap = currentUser.handicap?.round() ?? 18;

    final now = DateTime.now();
    final isSameDayOrFuture = now.year == event.date.year && 
                             now.month == event.date.month && 
                             now.day == event.date.day || 
                             now.isAfter(event.date);
    
    final bool isScoringActive = (event.scoringForceActive == true) || isSameDayOrFuture;
    final bool isLocked = event.isScoringLocked == true;

    switch (_selectedTab) {
      case 0: // My Score
        final userScorecard = ref.watch(userScorecardProvider(widget.eventId));
        
        return Column(
          children: [
            if (userScorecard != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(userScorecard.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _getStatusColor(userScorecard.status)),
                    ),
                    child: Text(
                      userScorecard.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(userScorecard.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            CourseInfoCard(
              courseConfig: event.courseConfig,
              selectedTeeName: event.selectedTeeName,
              distanceUnit: config.distanceUnit,
              isStableford: isStableford,
              playerHandicap: playerHandicap,
              scores: userScorecard?.holeScores ?? [],
            ),
            const SizedBox(height: 16),
            if (isLocked)
              const BoxyArtFloatingCard(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'SCORING LOCKED BY ADMIN',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (!isScoringActive)
              _buildInactiveBanner(event)
            else if (userScorecard == null)
              _buildEntryBanner(context, widget.eventId)
            else
              BoxyArtButton(
                title: 'EDIT SCORECARD',
                onTap: () => context.push('/events/${widget.eventId}/scores/entry'),
                fullWidth: true,
                isSecondary: true,
              ),
          ],
        );
      case 1: // Leaderboard
        return Column(
          children: [
            const BoxyArtSectionTitle(title: 'LIVE STANDINGS'),
            const SizedBox(height: 16),
            if (mockEntries.isEmpty)
               const Center(child: Padding(
                 padding: EdgeInsets.all(32.0),
                 child: Text('No scores submitted yet.', style: TextStyle(color: Colors.grey)),
               ))
            else
               LeaderboardWidget(entries: mockEntries, format: comp?.rules.format ?? CompetitionFormat.stableford),
          ],
        );
      case 2: // Stats
        final userScorecard = ref.watch(userScorecardProvider(widget.eventId));
        
        if (userScorecard == null) {
          return const BoxyArtFloatingCard(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Event statistics will appear here once scores are submitted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        // Calculate stats
        final holes = event.courseConfig['holes'] as List? ?? [];
        int eagles = 0;
        int birdies = 0;
        int pars = 0;
        int bogeys = 0;
        int doubleBogeys = 0;
        int others = 0;

        for (int i = 0; i < 18; i++) {
          final score = userScorecard.holeScores.length > i ? userScorecard.holeScores[i] : null;
          if (score != null) {
            final par = holes.length > i ? (holes[i]['par'] as int? ?? 4) : 4;
            final diff = score - par;
            if (diff <= -2) eagles++;
            else if (diff == -1) birdies++;
            else if (diff == 0) pars++;
            else if (diff == 1) bogeys++;
            else if (diff == 2) doubleBogeys++;
            else others++;
          }
        }

        return Column(
          children: [
            const BoxyArtSectionTitle(title: 'SCORE BREAKDOWN'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('EAGLES', eagles.toString(), Colors.purple)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('BIRDIES', birdies.toString(), Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('PARS', pars.toString(), Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildStatCard('BOGEYS', bogeys.toString(), Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('DBL BOGEY', doubleBogeys.toString(), Colors.red)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('OTHERS', others.toString(), Colors.red[900]!)),
              ],
            ),
            const SizedBox(height: 24),
            // More stats can be added here
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInactiveBanner(GolfEvent event) {
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.lock_clock_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'GAME NOT ACTIVE',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Scoring will open on ${DateFormat('EEEE, d MMMM').format(event.date)}.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryBanner(BuildContext context, String eventId) {
    return BoxyArtFloatingCard(
      child: Column(
        children: [
          const Text(
            'Submit your scores hole-by-hole to update\nthe live standings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          BoxyArtButton(
            title: 'ENTER SCORECARD',
            onTap: () => context.push('/events/$eventId/scores/entry'),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ScorecardStatus status) {
    switch (status) {
      case ScorecardStatus.draft:
        return Colors.grey;
      case ScorecardStatus.submitted:
        return Colors.blue;
      case ScorecardStatus.reviewed:
        return Colors.orange;
      case ScorecardStatus.finalScore:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
