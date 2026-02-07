import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../events_provider.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:golf_society/features/competitions/presentation/widgets/leaderboard_widget.dart';
import 'package:golf_society/models/competition.dart';
import '../../../members/presentation/members_provider.dart';
import '../widgets/grouping_widgets.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../widgets/course_info_card.dart';
import '../widgets/hole_by_hole_scoring_widget.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../models/scorecard.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/event_registration.dart';
import '../../../../core/utils/handicap_calculator.dart';

class EventGroupingUserTab extends ConsumerWidget {
  final String eventId;
  const EventGroupingUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final membersAsync = ref.watch(allMembersProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final isPeeking = ref.watch(impersonationProvider) != null;

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
            isPeeking: isPeeking,
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
                        final comp = compAsync.value;

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
  bool _isSelfMarking = true;
  String? _targetEntryId;
  MarkerTab _markerTab = MarkerTab.player;

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
                playingHandicap: (r['playingHandicap'] as num?)?.toInt(),
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
                isPeeking: ref.watch(impersonationProvider) != null,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      children: [
                        _buildTabButton('My Score', 0),
                        _buildTabButton('Groups', 1),
                        _buildTabButton('Leaderboard', 2),
                        _buildTabButton('Stats', 3),
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
        icon = Icons.groups_outlined;
        break;
      case 2:
        icon = Icons.emoji_events_outlined;
        break;
      case 3:
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
    final currentUser = ref.watch(effectiveUserProvider);
    
    final isStableford = comp?.rules.format == CompetitionFormat.stableford;

    final now = DateTime.now();
    final isSameDayOrFuture = now.year == event.date.year && 
                             now.month == event.date.month && 
                             now.day == event.date.day || 
                             now.isAfter(event.date);
    
    final bool isLocked = event.isScoringLocked == true;
    final bool isScoringActive = (event.scoringForceActive == true) || (isSameDayOrFuture && !isLocked);

    switch (_selectedTab) {
      case 0: // My Score
        var userScorecard = ref.watch(userScorecardProvider(widget.eventId));
        List<int>? fallbackScores;
        ScorecardStatus? fallbackStatus;

        // Fallback: Check if there's a seeded result for this user
        // Only use seeded results if scoring is NOT active (history/preview)
        // If scoring IS active, we want a clean slate so the user can play.
        if (userScorecard == null && !isScoringActive) {
          final seededResult = event.results.firstWhere(
            (r) => r['playerId'] == currentUser.id,
            orElse: () => {},
          );
          if (seededResult.isNotEmpty && seededResult['holeScores'] != null) {
            fallbackScores = List<int>.from(seededResult['holeScores']);
            fallbackStatus = ScorecardStatus.values.firstWhere(
              (s) => s.name == seededResult['status'],
              orElse: () => ScorecardStatus.finalScore,
            );
          }
        }

        final displayScores = userScorecard?.holeScores ?? (isScoringActive ? [] : (fallbackScores ?? []));
        final displayStatus = userScorecard?.status ?? (isScoringActive ? null : fallbackStatus);

        // Calculate playing handicap (Hoisted)
        // Dynamic HC Source:
        // - Self Marking: Current User
        // - Marking Other (Player Tab): Target User
        // - Marking Other (Verifier Tab): Current User (My HC)
        double baseHcp = currentUser.handicap;

        // Fetch members to lookup dynamic handicap
        final allMembersAsync = ref.watch(allMembersProvider);
        
        if (!_isSelfMarking && _markerTab == MarkerTab.player && _targetEntryId != null) {
           // Try to find target member in the loaded list
           if (allMembersAsync.hasValue) {
              try {
                final targetMember = allMembersAsync.value!.firstWhere((m) => m.id == _targetEntryId);
                baseHcp = targetMember.handicap;
              } catch (_) {
                // Member not found in list, use default/current
              }
           }
        }
        

        double cappedHcp = baseHcp;
        if (comp != null) {
          if (baseHcp > comp.rules.handicapCap) {
            cappedHcp = comp.rules.handicapCap.toDouble();
          }
          cappedHcp = cappedHcp * comp.rules.handicapAllowance;
        }
        final int playingHcpValue = cappedHcp.round();

        // Determine Badge State
        String badgeText;
        Color badgeColor;
        VoidCallback? onBadgeTap;
        
        // Calculate completion (assuming 18 holes for now)
        final bool isComplete = (displayScores.length == 18) && 
                                displayScores.every((s) => s != null && s > 0);

        if (!isScoringActive) {
          badgeText = "NOT ACTIVE";
          badgeColor = Colors.grey;
        } else if (isLocked) {
          badgeText = "FINAL SCORE";
          badgeColor = Colors.green;
        } else if (displayStatus != null) {
          if (displayStatus == ScorecardStatus.draft && isComplete) {
            badgeText = "SUBMIT";
            badgeColor = Colors.green; // Action color
            onBadgeTap = () => _submitScorecard(userScorecard!.id);
          } else {
            badgeText = displayStatus.name.toUpperCase();
            badgeColor = _getStatusColor(displayStatus);
            
            // Allow Unsubmit if Submitted or Final (and not locked)
            if (!isLocked && (displayStatus == ScorecardStatus.submitted || displayStatus == ScorecardStatus.finalScore)) {
               onBadgeTap = () => _confirmUnsubmit(userScorecard!.id);
            }
          }
        } else {
          badgeText = "ACTIVE";
          badgeColor = Colors.blue;
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Handicap Info
                  Row(
                    children: [
                      Text(
                        'HC: ${_formatHcp(baseHcp)}', 
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.grey.shade600, 
                          fontWeight: FontWeight.w600
                        )
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4, 
                        height: 4, 
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300, 
                          shape: BoxShape.circle
                        )
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PHC: $playingHcpValue', 
                        style: TextStyle(
                          fontSize: 12, 
                          color: Theme.of(context).primaryColor, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),

                  // Marker Toggle (Replaces Status Badge)
                  GestureDetector(
                    onTap: () => _showMarkerSelectionSheet(event, isScoringActive),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isSelfMarking ? Icons.person : Icons.supervisor_account, 
                            size: 14, 
                            color: Theme.of(context).primaryColor
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isSelfMarking 
                                ? 'Marking: SELF' 
                                : (_targetEntryId != null 
                                    ? 'Marking: ${event.registrations.firstWhere((r) => r.memberId == _targetEntryId, orElse: () => EventRegistration(memberId: '', memberName: 'OTHER')).memberName.split(' ').first.toUpperCase()}' 
                                    : 'Marking: SELECT'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isScoringActive) ...[
              // NEW Hole-by-Hole View (Stacked below)
              Consumer(
                builder: (context, ref, _) {
                  final currentUser = ref.watch(effectiveUserProvider);
                  // My Card (Verifier)
                  final myCard = ref.watch(userScorecardProvider(widget.eventId));
                  
                  // Target Card (Official)
                  final targetId = _isSelfMarking ? currentUser.id : (_targetEntryId ?? currentUser.id);
                  final targetCard = ref.watch(scorecardByEntryIdProvider((
                    competitionId: widget.eventId, 
                    entryId: targetId
                  )));

                  // Determine what to show on the Grid (CourseInfoCard)
                  // If Self Marking: Show My Official Card (displayScores already handles this standard flow)
                  // If Marker Mode:
                  //   - Tab 0 (Player): Show Target Card
                  //   - Tab 1 (Verifier): Show My Verifier Scores
                  
                  List<int?> gridScores = [];
                  if (_isSelfMarking) {
                     gridScores = displayScores;
                  } else {
                     if (_markerTab == MarkerTab.player) {
                       gridScores = targetCard?.holeScores ?? [];
                     } else {
                       gridScores = myCard?.playerVerifierScores ?? [];
                     }
                  }

                  final isVerifierView = !_isSelfMarking && _markerTab == MarkerTab.verifier;

                  return Column(
                    children: [
                      CourseInfoCard(
                        courseConfig: event.courseConfig,
                        selectedTeeName: event.selectedTeeName,
                        distanceUnit: config.distanceUnit,
                        isStableford: isStableford,
                        playerHandicap: playingHcpValue,
                        // Only show scores if scoring is active
                        scores: isScoringActive ? gridScores : [],
                        // Visual Cue for Viewer: Orange Header
                        headerColor: isVerifierView ? Colors.orange.withValues(alpha: 0.3) : null,
                      ),
                      
                      const SizedBox(height: 16),
            
                      // NEW Hole-by-Hole View (Stacked below)
                      HoleByHoleScoringWidget(
                        event: event,
                        targetScorecard: targetCard,
                        verifierScorecard: myCard,
                        targetEntryId: targetId, // Use the resolved targetId
                        isSelfMarking: _isSelfMarking,
                        selectedTab: _markerTab,
                        onTabChanged: (tab) {
                          setState(() => _markerTab = tab);
                        },
                      ),
                    ],
                  );
                }
              ),
              const SizedBox(height: 24),
                        
                        // Status Badge / Submit Action (Moved to Footer)
                        Center(
                child: GestureDetector(
                  onTap: onBadgeTap,
                  child: Container(
                    width: 140, // Fixed width
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: onBadgeTap != null ? 1.0 : 0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: badgeColor),
                      boxShadow: onBadgeTap != null ? [
                        BoxShadow(
                          color: badgeColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ) 
                      ] : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (onBadgeTap != null)
                           const Padding(
                             padding: EdgeInsets.only(right: 8.0),
                             child: Icon(Icons.check, size: 16, color: Colors.white),
                           ),
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: onBadgeTap != null ? Colors.white : badgeColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48), // Padding at bottom
            ],
            
            // Body Content (Banner or Actions)
            if (!isScoringActive)
               _buildInactiveBanner(event),
            
            if (fallbackScores != null) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Showing seeded scores for preview purposes.',
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
          ],
        );
      case 1: // Group Scores
        return _buildGroupScoresTab(event, comp);
      case 2: // Leaderboard
        final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));
        final membersAsync = ref.watch(allMembersProvider);
        
        return scorecardsAsync.when(
          data: (scorecards) {
            final membersList = membersAsync.value ?? [];
            
            // Building entries from scorecards
            final activeScorecards = scorecards.where((s) => 
               isScoringActive || s.status == ScorecardStatus.finalScore || s.status == ScorecardStatus.submitted
            ).toList();

            final allEntries = activeScorecards.map((s) {
                final isGuestScorecard = s.entryId.endsWith('_guest');
                final searchId = isGuestScorecard ? s.entryId.replaceFirst('_guest', '') : s.entryId;

                final reg = event.registrations.firstWhere(
                  (r) => r.memberId == searchId,
                  orElse: () => EventRegistration(memberId: '', memberName: 'Unknown', attendingGolf: true),
                );

                final name = isGuestScorecard ? (reg.guestName ?? 'Guest') : reg.memberName;
                
                // Calculate holes played
                final holesPlayedCount = s.holeScores.where((sc) => sc != null).length;
                
                // Find member handicap index
                double handicapIndex = 18.0;
                if (isGuestScorecard) {
                  handicapIndex = double.tryParse(reg.guestHandicap ?? '18') ?? 18.0;
                } else {
                  final member = membersList.where((m) => m.id == reg.memberId).firstOrNull;
                  handicapIndex = member?.handicap ?? 18.0;
                }

                // Calculate PHC if not present (logic matched from repo)
                final phc = HandicapCalculator.calculatePlayingHandicap(
                  handicapIndex: handicapIndex, 
                  rules: comp?.rules ?? const CompetitionRules(), 
                  courseConfig: event.courseConfig,
                );

                return LeaderboardEntry(
                  playerName: name,
                  score: s.points ?? 0,
                  handicap: handicapIndex.toInt(), 
                  playingHandicap: phc,
                  holesPlayed: isScoringActive ? holesPlayedCount : null,
                  isGuest: isGuestScorecard,
                  tieBreakDetails: _calculateTieBreakDetails(s, comp?.rules, event.courseConfig, phc),
                );
            }).toList();

            // Count occurrences of each score to identify ties
            final scoreCounts = <int, int>{};
            for (var e in allEntries) {
              scoreCounts[e.score] = (scoreCounts[e.score] ?? 0) + 1;
            }

            // Finalized entries with filtered tie-break details
            final finalizedEntries = allEntries.map((e) {
              if ((scoreCounts[e.score] ?? 0) <= 1) {
                return LeaderboardEntry(
                  playerName: e.playerName,
                  score: e.score,
                  handicap: e.handicap,
                  playingHandicap: e.playingHandicap,
                  holesPlayed: e.holesPlayed,
                  isGuest: e.isGuest,
                  tieBreakDetails: null, // Hide if not a tie
                );
              }
              return e;
            }).toList();

            // Sort logic: Score (desc), then tie break value (desc)
            finalizedEntries.sort((a, b) => b.score.compareTo(a.score));

            final members = finalizedEntries.where((e) => !e.isGuest).toList();
            final guests = finalizedEntries.where((e) => e.isGuest).toList();

            if (finalizedEntries.isEmpty) {
               return const Center(child: Padding(
                 padding: EdgeInsets.all(32.0),
                 child: Text('Standings will appear once scoring starts.', style: TextStyle(color: Colors.grey)),
               ));
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (members.isNotEmpty) ...[
                      const BoxyArtSectionTitle(title: 'MEMBERS LEADERBOARD'),
                      LeaderboardWidget(
                        entries: members, 
                        format: comp?.rules.format ?? CompetitionFormat.stableford,
                      ),
                    ],
                    if (guests.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const BoxyArtSectionTitle(title: 'GUEST LEADERBOARD'),
                      LeaderboardWidget(
                        entries: guests, 
                        format: comp?.rules.format ?? CompetitionFormat.stableford,
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          )),
          error: (e, s) => Center(child: Text('Error: $e')),
        );
      case 3: // Stats
        final userScorecard = ref.watch(userScorecardProvider(widget.eventId));
        
        if (userScorecard == null || !isScoringActive) {
          return const BoxyArtFloatingCard(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text('Stats will be available after scoring starts.', style: TextStyle(color: Colors.grey)),
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
            if (diff <= -2) {
              eagles++;
            } else if (diff == -1) {
              birdies++;
            } else if (diff == 0) {
              pars++;
            } else if (diff == 1) {
              bogeys++;
            } else if (diff == 2) {
              doubleBogeys++;
            } else {
              others++;
            }
          }
        }

        return Column(
          children: [
            BoxyArtSectionTitle(
              title: 'SCORE BREAKDOWN',
              isPeeking: ref.watch(impersonationProvider) != null,
            ),
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
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String? _calculateTieBreakDetails(Scorecard s, CompetitionRules? rules, Map<String, dynamic> courseConfig, int phc) {
    if (s.holeScores.every((hole) => hole == null)) return null;
    if (s.holeScores.where((hole) => hole != null).length < 18) return null; // Only for full scorecards

    final holes = courseConfig['holes'] as List?;
    if (holes == null || holes.length < 18) return null;

    // Basic Back 9 logic
    int back9Points = 0;
    int back9Gross = 0;

    for (int i = 9; i < 18; i++) {
       final score = s.holeScores[i];
       if (score == null) continue;

       final hole = holes[i] as Map<String, dynamic>;
       final par = hole['par'] as int? ?? 4;
       final si = hole['si'] as int? ?? 9;

       // Calculate Strokes Received
       final strokesReceived = (phc ~/ 18) + (si <= (phc % 18) ? 1 : 0);
       final netScore = score - strokesReceived;
       final points = (par - netScore + 2).clamp(0, 10);

       back9Points += points;
       back9Gross += score;
    }

    if (rules?.format == CompetitionFormat.stableford) {
      return "Back 9: $back9Points pts";
    } else {
      return "Back 9: $back9Gross";
    }
  }

  Widget _buildGroupScoresTab(GolfEvent event, Competition? comp) {
    final membersAsync = ref.watch(allMembersProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));
    final isStableford = comp?.rules.format == CompetitionFormat.stableford;

    return scorecardsAsync.when(
      data: (scorecards) {
        final groupsData = event.grouping['groups'] as List?;
        final List<TeeGroup> groups = groupsData != null 
            ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
            : [];

        if (groups.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Grouping is not yet available.', style: TextStyle(color: Colors.grey)),
          ));
        }

        // Create a map of scores for quick lookup
        final scoreMap = <String, String>{};
        for (var s in scorecards) {
          final val = isStableford ? (s.points ?? 0) : (s.grossTotal ?? 0);
          scoreMap[s.entryId] = val.toString();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final members = membersAsync.value ?? [];
            final memberMap = {for (var m in members) m.id: m};

            return GroupingCard(
              group: group,
              memberMap: memberMap,
              history: const [], // Not needed for score mode
              totalGroups: groups.length,
              rules: comp?.rules,
              courseConfig: event.courseConfig,
              isAdmin: false,
              isScoreMode: true,
              scoreMap: scoreMap,
            );
          },
        );
      },
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      )),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
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
              (event.scoringForceActive == true) 
                  ? 'Admin has forced scoring to be active for this event.'
                  : 'Scoring will open on ${DateFormat('EEEE, d MMMM').format(event.date)}.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
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
    }
  }

  String _formatHcp(double hcp) {
    return hcp.truncateToDouble() == hcp ? hcp.toInt().toString() : hcp.toStringAsFixed(1);
  }


  void _showMarkerSelectionSheet(GolfEvent event, bool isScoringActive) {
    if (!isScoringActive) return;

    final currentUser = ref.read(effectiveUserProvider);
    final groupsData = event.grouping['groups'] as List?;
    final List<dynamic> groups = groupsData ?? []; 
    
    List<String> groupMembers = [];
    for (var g in groups) {
      final players = (g['players'] as List?) ?? [];
      final hasMe = players.any((p) => p['id'] == currentUser.id);
      if (hasMe) {
        groupMembers = players.map((p) => p['id'] as String).toList();
        break;
      }
    }

    // FALLBACK: If no group found (e.g. testing, not published, or admin preview), 
    // allow selecting from ALL registrations to ensure feature is usable.
    if (groupMembers.isEmpty) {
       groupMembers = event.registrations
          .where((r) => r.memberId != currentUser.id)
          .map((r) => r.memberId)
          .toList();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40, 
                height: 4, 
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2)
                )
              ),
              const SizedBox(height: 24),
              Text(
                'Who are you marking?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Option 1: Myself
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                        ),
                        title: const Text('Myself'),
                        trailing: _isSelfMarking ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                        onTap: () {
                          setState(() {
                            _isSelfMarking = true;
                            _targetEntryId = null;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      
                      const Divider(height: 1),
                      
                      // Option 2: Group Members
                      ...groupMembers.where((id) => id != currentUser.id).map((id) {
                         final reg = event.registrations.firstWhere(
                           (r) => r.memberId == id, 
                           orElse: () => EventRegistration(memberId: id, memberName: 'Unknown')
                         );
                         final isSelected = !_isSelfMarking && _targetEntryId == id;
                         
                         return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.supervisor_account, color: Colors.orange),
                            ),
                            title: Text(reg.memberName),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.orange) : null,
                            onTap: () {
                              setState(() {
                                _isSelfMarking = false;
                                _targetEntryId = id;
                              });
                              Navigator.pop(context);
                            },
                         );
                      }),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> _submitScorecard(String scorecardId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Scorecard?'),
        content: const Text(
          'Are you sure you want to submit your scorecard? You will not be able to edit it afterwards.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(scorecardRepositoryProvider).updateScorecardStatus(
          scorecardId, 
          ScorecardStatus.submitted
        );
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Scorecard Submitted Successfully!'), backgroundColor: Colors.green),
           );
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _confirmUnsubmit(String scorecardId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsubmit Scorecard?'),
        content: const Text(
          'This will reopen your scorecard for editing. You will need to submit it again when finished.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unsubmit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(scorecardRepositoryProvider);
        await repo.updateScorecardStatus(scorecardId, ScorecardStatus.draft); // Revert to draft (scoring)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scorecard reopened for editing.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error reopening scorecard: $e')),
          );
        }
      }
    }
  }
}
