import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../../features/debug/presentation/widgets/lab_control_panel.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/scorecard.dart';
import '../../../../models/member.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:golf_society/features/competitions/presentation/widgets/leaderboard_widget.dart';
import 'package:golf_society/models/competition.dart';
import '../../../members/presentation/members_provider.dart';
import '../widgets/grouping_widgets.dart';
import '../events_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../../core/theme/theme_controller.dart';
import '../widgets/course_info_card.dart';
import '../widgets/hole_by_hole_scoring_widget.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/event_registration.dart';
import '../../../../core/utils/handicap_calculator.dart';
// REDACTED: unused imports
import '../../../../core/services/persistence_service.dart';
// REDACTED: unused math import
import '../../../matchplay/presentation/widgets/matches_list_widget.dart';
import '../../../matchplay/presentation/widgets/matches_bracket_widget.dart';
import '../../../matchplay/presentation/widgets/match_group_standings_widget.dart';
import '../../../matchplay/domain/golf_event_match_extensions.dart';
import '../../../matchplay/domain/match_definition.dart';

import '../../../debug/presentation/state/debug_providers.dart';
import 'event_stats_tab.dart';

// [LAB MODE] Persistence for Marker Selection
class MarkerSelection {
  final bool isSelfMarking;
  final String? targetEntryId;
  MarkerSelection({required this.isSelfMarking, this.targetEntryId});
}

class MarkerSelectionNotifier extends Notifier<MarkerSelection> {
  static const _keySelf = 'lab_marker_self';
  static const _keyTarget = 'lab_marker_target';
  
  @override
  MarkerSelection build() {
    final prefs = ref.watch(persistenceServiceProvider);
    return MarkerSelection(
      isSelfMarking: prefs.getBool(_keySelf) ?? true,
      targetEntryId: prefs.getString(_keyTarget),
    );
  }
  
  void selectSelf() {
    state = MarkerSelection(isSelfMarking: true, targetEntryId: null);
    ref.read(persistenceServiceProvider).setBool(_keySelf, true);
    ref.read(persistenceServiceProvider).remove(_keyTarget);
  }
  
  void selectTarget(String targetId) {
    state = MarkerSelection(isSelfMarking: false, targetEntryId: targetId);
    ref.read(persistenceServiceProvider).setBool(_keySelf, false);
    ref.read(persistenceServiceProvider).setString(_keyTarget, targetId);
  }
}
final markerSelectionProvider = NotifierProvider<MarkerSelectionNotifier, MarkerSelection>(MarkerSelectionNotifier.new);

// Tab Notifier for event scoring tabs

// Actually I'll use a String key for tab index to handle more than 2
class SelectedTabNotifier extends Notifier<int> {
  final String key;
  SelectedTabNotifier(this.key);
  @override
  int build() => int.tryParse(ref.watch(persistenceServiceProvider).getString(key) ?? '0') ?? 0;
  void set(int val) {
    state = val;
    ref.read(persistenceServiceProvider).setString(key, val.toString());
  }
}

final eventDetailsTabProvider = NotifierProvider<SelectedTabNotifier, int>(() => SelectedTabNotifier('event_details_tab'));

class EventGroupingUserTab extends ConsumerWidget {
  final String eventId;
  const EventGroupingUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final membersAsync = ref.watch(allMembersProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
    final statusOverride = ref.watch(eventStatusOverrideProvider);

    return eventsAsync.when(
      data: (events) {
        var event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        
        // [LAB MODE] Apply Status Override
        if (statusOverride != null) {
          event = event.copyWith(status: statusOverride);
        }
        
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
            isPeeking: ref.watch(impersonationProvider) != null,
            actions: [
              IconButton(
                icon: const Icon(Icons.science, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context, 
                    isScrollControlled: true,
                    builder: (context) => LabControlPanel(eventId: event.id)
                  );
                },
              ),
            ],
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
                          rules: comp?.rules.copyWith(
                            format: ref.watch(gameFormatOverrideProvider) ?? comp.rules.format,
                            mode: ref.watch(gameModeOverrideProvider) ?? comp.rules.mode,
                            handicapAllowance: ref.watch(handicapAllowanceOverrideProvider) ?? comp.rules.handicapAllowance,
                            teamBestXCount: ref.watch(teamBestXCountOverrideProvider) ?? comp.rules.teamBestXCount,
                            aggregation: ref.watch(aggregationMethodOverrideProvider) == 'betterBall' 
                                ? AggregationMethod.singleBest 
                                : (ref.watch(aggregationMethodOverrideProvider) == 'combined' ? AggregationMethod.totalSum : comp.rules.aggregation),
                          ),
                          courseConfig: event.courseConfig,
                          isAdmin: false,
                          scorecardMap: scorecardsAsync.asData?.value != null 
                              ? {for (var s in scorecardsAsync.asData!.value) s.entryId: s}
                              : null,
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
  // Local state for tabs and markers removed to use providers below
  MarkerTab _markerTab = MarkerTab.player;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final compAsync = ref.watch(competitionDetailProvider(widget.eventId));
    final formatOverride = ref.watch(gameFormatOverrideProvider);

    return eventsAsync.when(
      data: (events) {
        // [Lab Mode] Apply overrides
        final statusOverride = ref.watch(eventStatusOverrideProvider);
        var event = events.firstWhere((e) => e.id == widget.eventId, orElse: () => throw 'Event not found');
        
        if (statusOverride != null) {
          event = event.copyWith(status: statusOverride);
        }

        final forceActiveOverride = ref.watch(scoringForceActiveOverrideProvider);
        if (forceActiveOverride != null) {
          event = event.copyWith(scoringForceActive: forceActiveOverride);
        }

        final forceLockedOverride = ref.watch(isScoringLockedOverrideProvider);
        if (forceLockedOverride != null) {
          event = event.copyWith(isScoringLocked: forceLockedOverride);
        }

        final statsReleasedOverride = ref.watch(isStatsReleasedOverrideProvider);
        if (statsReleasedOverride != null) {
          event = event.copyWith(isStatsReleased: statsReleasedOverride);
        }
        
        return compAsync.when(
          data: (comp) {
            // [Lab Mode] Merged Rules with overrides
            final rules = comp?.rules ?? const CompetitionRules();
            final handicapCapOverride = ref.watch(handicapCapOverrideProvider);
            final scoringType = ref.watch(scoringTypeOverrideProvider);
            
            final effectiveRules = rules.copyWith(
              format: ref.watch(gameFormatOverrideProvider) ?? rules.format,
              mode: ref.watch(gameModeOverrideProvider) ?? rules.mode,
              handicapAllowance: ref.watch(handicapAllowanceOverrideProvider) ?? rules.handicapAllowance,
              teamBestXCount: ref.watch(teamBestXCountOverrideProvider) ?? rules.teamBestXCount,
              aggregation: ref.watch(aggregationMethodOverrideProvider) == 'betterBall' 
                  ? AggregationMethod.singleBest 
                  : (ref.watch(aggregationMethodOverrideProvider) == 'combined' ? AggregationMethod.totalSum : rules.aggregation),
              handicapCap: handicapCapOverride ?? rules.handicapCap,
            );

            // Force Gross Scoring check
            final isGross = scoringType == ScoringType.gross;

            final currentFormat = effectiveRules.format;
            final currentMode = effectiveRules.mode;
            
            final isStableford = currentFormat == CompetitionFormat.stableford;
            final results = event.results;
            
            final List<LeaderboardEntry> leaderboardEntries = [];
            
            if (currentMode == CompetitionMode.singles) {
              leaderboardEntries.addAll(results.map((r) {
                // Gross Scoring Check
                final score = isStableford 
                    ? (isGross ? (r['grossPoints'] as int? ?? 0) : (r['points'] as int? ?? 0))
                    : (isGross ? (r['grossTotal'] as int? ?? 0) : (r['netTotal'] as int? ?? 0));
                
                final entryId = (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString();
                final bool isGuest = event.registrations.any((reg) => reg.memberId == entryId && reg.isGuest);

                return LeaderboardEntry(
                  entryId: entryId,
                  playerName: r['playerName'] ?? 'Unknown',
                  score: score,
                  scoreLabel: currentFormat == CompetitionFormat.matchPlay 
                      ? (score > 0 ? '+$score' : (score < 0 ? '$score' : 'AS')) 
                      : null,
                  handicap: (r['handicap'] as num?)?.toInt() ?? 0,
                  playingHandicap: isGross ? 0 : (r['playingHandicap'] as num?)?.toInt(),
                  isGuest: isGuest,
                );
              }));
            } else {
              // Grouped Mode (Pairs/Teams) - Lab Mode heuristic grouping
              final groupSize = currentMode == CompetitionMode.pairs ? 2 : 4;
              for (int i = 0; i < results.length; i += groupSize) {
                if (i + 1 >= results.length) {
                  break;
                }
                
                final r1 = results[i];
                final r2 = results[i + 1];
                
                final score = isStableford 
                    ? (isGross ? (r1['grossPoints'] as int? ?? 0) : (r1['points'] as int? ?? 0))
                    : (isGross ? (r1['grossTotal'] as int? ?? 0) : (r1['netTotal'] as int? ?? 0));

                final entryId = (r1['memberId'] ?? 'grp_$i').toString();
                // For groups, check if any member is a guest? Or just main player?
                final bool isGuest = event.registrations.any((reg) => reg.memberId == entryId && reg.isGuest);

                leaderboardEntries.add(LeaderboardEntry(
                  entryId: entryId,
                  playerName: r1['playerName'] ?? 'Unknown',
                  secondaryPlayerName: r2['playerName'] ?? 'Unknown',
                  score: score,
                  handicap: (r1['handicap'] as num?)?.toInt() ?? 0,
                  playingHandicap: isGross ? 0 : (r1['playingHandicap'] as num?)?.toInt(),
                  isGuest: isGuest,
                ));
              }
            }

            // If no results, show the original mock or empty?
            // For now, if results are empty, we keep the empty state or show a placeholder.

            return Scaffold(
              appBar: BoxyArtAppBar(
                title: 'Scores',
                subtitle: event.title,
                isLarge: true,
                showBack: true,
                isPeeking: ref.watch(impersonationProvider) != null,
                actions: [
                  IconButton(
                    icon: Icon(Icons.science, color: formatOverride != null ? Colors.orange : Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context, 
                        isScrollControlled: true,
                        builder: (context) => LabControlPanel(eventId: widget.eventId),
                      );
                    },
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      children: [
                        _buildTabButton('My Score', 0),
                        _buildTabButton('Groups', 1),
                        _buildTabButton('Leaderboard', 2),
                        if (event.matches.isNotEmpty) _buildTabButton('Matches', 4),
                        if (event.matches.any((m) => m.bracketId != null)) _buildTabButton('Bracket', 5),
                        _buildTabButton('Stats', 3),
                      ],
                    ),
                  ),
                ),
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                   // Refresh both events and competition details
                   ref.invalidate(eventsProvider);
                   ref.invalidate(competitionDetailProvider(widget.eventId));
                   // also refresh seeding controller if needed, but eventsProvider should cover it
                   await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: _buildTabContent(event, comp, leaderboardEntries, effectiveRules),
                ),
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
    final selectedTab = ref.watch(eventDetailsTabProvider);
    final isSelected = selectedTab == index;
    
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
      case 4:
        icon = Icons.grid_view_outlined; // Or something for matches
        break;
      case 5:
        icon = Icons.account_tree_outlined; 
        break;
      default:
        icon = Icons.help_outline;
    }
    
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(eventDetailsTabProvider.notifier).set(index),
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

  Widget _buildTabContent(GolfEvent event, Competition? comp, List<LeaderboardEntry> mockEntries, CompetitionRules effectiveRules) {
    final config = ref.watch(themeControllerProvider);
    final currentUser = ref.watch(effectiveUserProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(event.id));
    
    // Respect Lab Mode override
    // [Force Reload]
    final formatOverride = ref.watch(gameFormatOverrideProvider);
    final currentFormat = formatOverride ?? (comp?.rules.format ?? CompetitionFormat.stableford);
    final isStableford = currentFormat == CompetitionFormat.stableford;

    final now = DateTime.now();
    final isSameDayOrPast = now.year == event.date.year && 
                             now.month == event.date.month && 
                             now.day == event.date.day || 
                             now.isAfter(event.date);
    
    final statusOverride = ref.watch(eventStatusOverrideProvider);
    final effectiveStatus = statusOverride ?? event.status;

    final bool isLocked = event.isScoringLocked == true;
    final bool isCompleted = effectiveStatus == EventStatus.completed;
    final forceActiveOverride = ref.watch(scoringForceActiveOverrideProvider);
    // [FIX] Allow Force Active override to bypass 'Completed' status for testing
    final bool isScoringActive = (forceActiveOverride == true) || (!isCompleted && ((effectiveStatus == EventStatus.inPlay) || (event.scoringForceActive == true) || (isSameDayOrPast && !isLocked)));
    final bool shouldShowCard = isSameDayOrPast || event.scoringForceActive == true || isCompleted || isLocked;

    final simulationHoles = ref.watch(simulationHoleCountOverrideProvider);
    final Map<String, int> playerHoleLimits = {};
    // [FIX] Only apply simulation if the event is 'In Play'
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

    switch (ref.watch(eventDetailsTabProvider)) {
      case 0: { // My Score
        final markerSelection = ref.watch(markerSelectionProvider);
        final bool isSelfMarking = markerSelection.isSelfMarking;
        final String? targetEntryId = markerSelection.targetEntryId;
        
        final String effectiveEntryId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);
        var userScorecard = ref.watch(scorecardByEntryIdProvider((competitionId: widget.eventId, entryId: effectiveEntryId)));
        List<int>? fallbackScores;
        ScorecardStatus? fallbackStatus;

        if (userScorecard == null) {
          final seededResult = event.results.firstWhere(
            (r) => r['playerId'] == effectiveEntryId,
            orElse: () => {},
          );
          if (seededResult.isNotEmpty && seededResult['holeScores'] != null) {
            fallbackScores = List<int>.from(seededResult['holeScores']);
            fallbackStatus = ScorecardStatus.values.firstWhereOrNull(
              (s) => s.name == seededResult['status'],
            ) ?? ScorecardStatus.finalScore;
          }
        }

        final emptyData = ref.watch(simulateEmptyDataProvider);
        List<int?> rawDisplayScores = emptyData 
            ? [] 
            : (userScorecard != null && userScorecard.holeScores.any((s) => s != null)
                ? userScorecard.holeScores 
                : (fallbackScores ?? []));

        // APPLY SIMULATION LIMIT
        final List<int?> displayScores = [];
        final limit = playerHoleLimits[effectiveEntryId];
        if (limit != null) {
          for (int i = 0; i < rawDisplayScores.length; i++) {
            if (i < limit) {
              displayScores.add(rawDisplayScores[i]);
            } else {
              // Nullify scores beyond simulation limit to hide them on the card
              displayScores.add(null);
            }
          }
        } else {
          displayScores.addAll(rawDisplayScores);
        }

        final displayStatus = userScorecard?.status ?? (isScoringActive ? null : fallbackStatus);

        // Calculate playing handicap (Hoisted)
        // Dynamic HC Source:
        // - Self Marking: Current User
        // - Marking Other (Player Tab): Target User
        // - Marking Other (Verifier Tab): Current User (My HC)
        double baseHcp = currentUser.handicap;

        // Fetch members to lookup dynamic handicap
        final allMembersAsync = ref.watch(allMembersProvider);
        
        if (!isSelfMarking && _markerTab == MarkerTab.player && targetEntryId != null) {
           final guestSuffix = '_guest';
           if (targetEntryId.endsWith(guestSuffix)) {
              // Look up guest handicap in grouping data
              final groupsData = event.grouping['groups'] as List?;
              if (groupsData != null) {
                final hostId = targetEntryId.replaceFirst(guestSuffix, '');
                for (var g in groupsData) {
                  final players = g['players'] as List?;
                  final guest = players?.firstWhere((p) => p['registrationMemberId'] == hostId && p['isGuest'] == true, orElse: () => null);
                  if (guest != null) {
                    baseHcp = (guest['handicapIndex'] as num?)?.toDouble() ?? 28.0;
                    break;
                  }
                }
              }
           } else if (allMembersAsync.hasValue) {
              try {
                final targetMember = allMembersAsync.value!.firstWhere((m) => m.id == targetEntryId);
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
            
            // Allow Unsubmit ONLY if Submitted (and not locked by event)
            if (!isLocked && displayStatus == ScorecardStatus.submitted) {
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
                  Consumer(
                    builder: (context, ref, _) {
                      final markerSelection = ref.watch(markerSelectionProvider);
                      final bool isSelfMarking = markerSelection.isSelfMarking;
                      final String? targetEntryId = markerSelection.targetEntryId;
                      
                      return GestureDetector(
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
                                isSelfMarking ? Icons.person : Icons.supervisor_account, 
                                size: 14, 
                                color: Theme.of(context).primaryColor
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSelfMarking 
                                    ? 'Marking: SELF' 
                                    : (targetEntryId != null 
                                        ? 'Marking: ${_getDisplayName(event, targetEntryId).split(' ').first.toUpperCase()}' 
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
                      );
                    }
                  ),
                ],
              ),
            ),
            if (shouldShowCard) ...[
              // NEW Hole-by-Hole View (Stacked below)
              Consumer(
                builder: (context, ref, _) {
                  final currentUser = ref.watch(effectiveUserProvider);
                  final markerSelection = ref.watch(markerSelectionProvider);
                  final bool isSelfMarking = markerSelection.isSelfMarking;
                  final String? targetEntryId = markerSelection.targetEntryId;
                  final myCard = ref.watch(userScorecardProvider(widget.eventId));
                  
                  // Target Card (Official)
                  final targetId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);
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
                  if (isSelfMarking) {
                     gridScores = displayScores;
                  } else {
                     if (_markerTab == MarkerTab.player) {
                       if (targetCard != null && targetCard.holeScores.isNotEmpty) {
                         gridScores = targetCard.holeScores;
                       } else {
                         // Fallback: Check for seeded result for the target player
                         final targetSeed = event.results.firstWhere(
                           (r) => r['playerId'] == targetId,
                           orElse: () => {},
                         );
                         if (targetSeed.isNotEmpty && targetSeed['holeScores'] != null) {
                           gridScores = List<int>.from(targetSeed['holeScores']);
                         }
                       }
                     } else {
                       gridScores = myCard?.playerVerifierScores ?? [];
                     }
                  }

                  final isVerifierView = !isSelfMarking && _markerTab == MarkerTab.verifier;

                  // Resolve effective rules/format for card
                  final maxTypeOverride = ref.watch(maxScoreTypeOverrideProvider);
                  final maxValueOverride = ref.watch(maxScoreValueOverrideProvider);
                  final formatOverride = ref.watch(gameFormatOverrideProvider);
                  final currentFormat = formatOverride ?? (comp?.rules.format ?? CompetitionFormat.stableford);
                  
                  MaxScoreConfig? effectiveMaxScore = comp?.rules.maxScoreConfig;
                  if (currentFormat == CompetitionFormat.maxScore) {
                    if (maxTypeOverride != null) {
                       effectiveMaxScore = MaxScoreConfig(
                         type: maxTypeOverride,
                         value: maxValueOverride ?? (effectiveMaxScore?.value ?? 2),
                       );
                    }
                  }

                  return Column(
                    children: [
                      CourseInfoCard(
                        courseConfig: event.courseConfig,
                        selectedTeeName: event.selectedTeeName,
                        distanceUnit: config.distanceUnit,
                        isStableford: isStableford,
                        playerHandicap: playingHcpValue,
                        // Show scores if scoring is active OR it's a past/completed event
                        scores: shouldShowCard ? gridScores : [],
                        // Visual Cue for Viewer: Orange Header
                        headerColor: isVerifierView ? Colors.orange.withValues(alpha: 0.3) : null,
                        format: currentFormat,
                        maxScoreConfig: effectiveMaxScore,
                        holeLimit: limit, // [FIX] Apply simulation limit
                      ),
                      
                      const SizedBox(height: 16),
            
                      // NEW Hole-by-Hole View (Stacked below)
                      HoleByHoleScoringWidget(
                        event: event,
                        targetScorecard: targetCard,
                        verifierScorecard: myCard,
                        targetEntryId: targetId, // Use the resolved targetId
                        isSelfMarking: isSelfMarking,
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
            if (!shouldShowCard)
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
      }
      case 1: { // Group Scores
        return _buildGroupScoresTab(event, effectiveRules, playerHoleLimits);
      }

      case 2: { // Leaderboard
        final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));
        final membersAsync = ref.watch(allMembersProvider);
        // simulationHoles handled above
        
        return scorecardsAsync.when(
          data: (scorecards) {
            final membersList = membersAsync.value ?? [];
            
            // 1. Merge Live Scorecards with Seeded Results (if any missing from live)
            // This ensures mixed state (some players live, some seeded) works correctly
            final Map<String, dynamic> mergedData = {};
            
            // First, populate with seeded results
            // If results are empty, use fallback mockEntries for testing
            final sourceResults = event.results.isNotEmpty ? event.results : mockEntries.map((e) => {
               'memberId': e.entryId,
               'playerName': e.playerName,
               'handicap': e.handicap,
               'points': e.score, // Simple mapping for mock
               'netTotal': e.score,
            }).toList();

            for (var r in sourceResults) {
              final id = (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString();
              mergedData[id] = {
                'type': 'seeded',
                'data': r,
              };
            }
            
            // Overlay with Live Scorecards
            for (var s in scorecards) {
               mergedData[s.entryId] = {
                 'type': 'live',
                 'data': s,
               };
            }
            
            List<LeaderboardEntry> finalEntries = [];
            
            // playerHoleLimits already calculated at top of _buildTabContent

            for (var reg in event.registrations) {
               // Process Member
               if (mergedData.containsKey(reg.memberId)) {
                 finalEntries.add(_buildEntry(
                   id: reg.memberId, 
                   reg: reg, 
                   source: mergedData[reg.memberId]!, 
                   event: event, 
                   effectiveRules: effectiveRules,
                   membersList: membersList,
                   currentFormat: currentFormat,
                   holeLimit: playerHoleLimits[reg.memberId] ?? simulationHoles, // [FIX] Fallback for ungrouped
                 ));
               }
               
               // Process Guest (if exists and has data)
               final guestId = '${reg.memberId}_guest';
               // 3. Remove incorrect "attendingDinner" check
               if (reg.guestName != null && mergedData.containsKey(guestId)) {
                  finalEntries.add(_buildEntry(
                   id: guestId, 
                   reg: reg, 
                   source: mergedData[guestId]!, 
                   event: event, 
                   effectiveRules: effectiveRules,
                   membersList: membersList,
                   currentFormat: currentFormat,
                   isGuest: true,
                   holeLimit: playerHoleLimits[guestId] ?? simulationHoles, // [FIX] Fallback
                 ));
               }
            }
            
            // Fallback: If no registrations matched but we have data (e.g. pure seeded/mock)
            if (finalEntries.isEmpty && mergedData.isNotEmpty) {
               mergedData.forEach((key, value) {
                  finalEntries.add(_buildEntry(
                     id: key,
                     reg: EventRegistration(memberId: key, memberName: value['data']['playerName'] ?? 'Unknown', attendingGolf: true),
                     source: value,
                     event: event,
                     effectiveRules: effectiveRules,
                     membersList: membersList,
                     currentFormat: currentFormat,
                     holeLimit: playerHoleLimits[key] ?? simulationHoles, // [FIX] Fallback
                  ));
               });
            }

            // Count occurrences of each score to identify ties
            final scoreCounts = <int, int>{};
            for (var e in finalEntries) {
              scoreCounts[e.score] = (scoreCounts[e.score] ?? 0) + 1;
            }
 
            // Finalized entries with filtered tie-break details
            final finalizedEntries = finalEntries.map((e) {
              if ((scoreCounts[e.score] ?? 0) <= 1) {
                return LeaderboardEntry(
                  entryId: e.entryId,
                  playerName: e.playerName,
                  score: e.score,
                  scoreLabel: e.scoreLabel,
                  handicap: e.handicap,
                  playingHandicap: e.playingHandicap,
                  holesPlayed: e.holesPlayed,
                  isGuest: e.isGuest,
                  tieBreakDetails: null, // Hide if not a tie
                );
              }
              return e;
            }).toList();
 
            // Sort logic: Format-aware (Desc for points, Asc for strokes)
            final isStableford = currentFormat == CompetitionFormat.stableford;
            if (isStableford) {
              finalizedEntries.sort((a, b) => b.score.compareTo(a.score));
            } else {
              finalizedEntries.sort((a, b) => a.score.compareTo(b.score));
            }
 
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
                        format: currentFormat,
                        onPlayerTap: (entry) => _showPlayerScorecard(context, entry, scorecards, event, comp, holeLimit: playerHoleLimits[entry.entryId] ?? simulationHoles),
                      ),
                    ],
                    if (guests.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const BoxyArtSectionTitle(title: 'GUEST LEADERBOARD'),
                      LeaderboardWidget(
                        entries: guests, 
                        format: currentFormat,
                        onPlayerTap: (entry) => _showPlayerScorecard(context, entry, scorecards, event, comp, holeLimit: playerHoleLimits[entry.entryId] ?? simulationHoles),
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
      }
      case 3: { // Stats
        final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));

        return scorecardsAsync.when(
          data: (liveScorecards) => EventStatsTab(
            event: event,
            comp: comp,
            liveScorecards: liveScorecards,
            playerHoleLimits: playerHoleLimits,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error loading stats: $e')),
        );
      }
      case 4: { // Matches
        return scorecardsAsync.when(
          data: (scorecards) => Column(
            children: [
              if (event.matches.any((m) => m.round == MatchRoundType.group))
                MatchGroupStandingsWidget(event: event, scorecards: scorecards),
              MatchesListWidget(eventId: widget.eventId),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        );
      }
      case 5: { // Bracket
        return MatchesBracketWidget(eventId: widget.eventId);
      }
      default:
        return const SizedBox.shrink();
    }
  }

  String? _calculateTieBreakDetails(List<int?> holeScores, CompetitionRules? rules, Map<String, dynamic> courseConfig, int phc) {
    if (holeScores.every((hole) => hole == null)) {
      return null;
    }
    if (holeScores.where((hole) => hole != null).length < 18) {
      return null; // Only for full scorecards
    }

    final holes = courseConfig['holes'] as List?;
    if (holes == null || holes.length < 18) {
      return null;
    }

    // Basic Back 9 logic
    int back9Points = 0;
    int back9Gross = 0;

    for (int i = 9; i < 18; i++) {
       final score = holeScores[i];
       if (score == null) {
         continue;
       }

       final hole = holes[i] as Map<String, dynamic>;
       final par = hole['par'] as int? ?? 4;
       final si = hole['si'] as int? ?? 9;

       // Calculate Strokes Received
       final strokesReceived = (phc ~/ 18) + (si <= (phc % 18) ? 1 : 0);
       final netScore = (holeScores[i] ?? 0) - strokesReceived;
       final points = (par - netScore + 2).clamp(0, 10);

       back9Points += points;
       back9Gross += score!;
    }

    // Respect Lab Mode override
    final formatOverride = ref.read(gameFormatOverrideProvider);
    final currentFormat = formatOverride ?? (rules?.format ?? CompetitionFormat.stableford);

    if (currentFormat == CompetitionFormat.stableford) {
      return "Back 9: $back9Points pts";
    } else {
      // For Strokeplay, show Net Back 9 relative to Par
      int back9Par = 0;
      for (int i = 9; i < 18; i++) {
        back9Par += (holes[i]['par'] as int? ?? 4);
      }
      final diff = back9Gross - (phc ~/ 2) - back9Par; // Simplified net back 9
      final label = diff == 0 ? "E" : (diff > 0 ? "+$diff" : "$diff");
      return "Back 9: $label";
    }
  }

  Widget _buildGroupScoresTab(GolfEvent event, CompetitionRules rules, Map<String, int> playerHoleLimits) {
    final membersAsync = ref.watch(allMembersProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));
    
    // Use effective rules
    final currentFormat = rules.format;
    final isStableford = currentFormat == CompetitionFormat.stableford;
    
    // [Lab Mode]
    // [FIX] Removed inconsistent score override check to match Leaderboard
    final isGross = rules.subtype == CompetitionSubtype.grossStableford;

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
        final holes = event.courseConfig['holes'] as List? ?? [];

        // [LAB MODE]
        final emptyData = ref.watch(simulateEmptyDataProvider);

        // Identify all players in groups to ensure we check everyone
        final allGroupPlayers = groups.expand((g) => g.players).toList();

        for (var p in allGroupPlayers) {
           final playerId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;

           if (emptyData) {
              scoreMap[playerId] = '-';
              continue;
           }

           // 1. Try to find live scorecard
           final scorecard = scorecards.firstWhere(
              (s) => s.entryId == playerId,
              orElse: () => Scorecard(
                 id: 'temp', 
                 competitionId: event.id,  // Correct parameter
                 roundId: 'round_1', // Required param
                 submittedByUserId: 'system', // Required param
                 createdAt: DateTime.now(), // Required param
                 updatedAt: DateTime.now(), // Required param
                 entryId: playerId, 
                 holeScores: [],
                 status: ScorecardStatus.draft // Dummy
              ),
           );

            List<int?>? rawScores = scorecard.holeScores.isNotEmpty ? scorecard.holeScores : null;
            List<int?>? scoresToUse;

           // 2. Fallback to seeded results if no live scores
           if (rawScores == null || rawScores.isEmpty) {
              final seededResult = event.results.firstWhere(
                 (r) => r['playerId'] == playerId || (p.isGuest && r['playerId'] == p.registrationMemberId),
                 orElse: () => {},
              );
              if (seededResult.isNotEmpty && seededResult['holeScores'] != null) {
                 rawScores = List<int?>.from(seededResult['holeScores']);
                 // If format is Stableford, we might need pre-calculated points from result?
                 // Or recalculate them here. Seeded results usually have 'points' total too.
                 if (isStableford && seededResult['points'] != null) {
                    // If a limit is present, we must recalculate, so don't skip.
                    if (playerHoleLimits[playerId] == null) {
                       scoreMap[playerId] = seededResult['points'].toString();
                       continue; // Skip calculation
                    }
                 }
              }
           }

            if (rawScores == null || rawScores.isEmpty) {
               scoreMap[playerId] = '-';
               continue;
            }

            // APPLY SIMULATION LIMIT
            final limit = playerHoleLimits[playerId];
            if (limit != null) {
               scoresToUse = [];
               for (int i = 0; i < rawScores.length; i++) {
                 if (i < limit) scoresToUse.add(rawScores[i]);
               }
            } else {
               scoresToUse = List<int?>.from(rawScores);
            }

           // Calculate Display Value based on Format
           if (isStableford) {
              // If we have a live scorecard or re-calculated points
              if (scorecard.points != null && scorecard.holeScores.isNotEmpty && !isGross && limit == null) {
                  scoreMap[playerId] = scorecard.points.toString();
              } else {
                  // Recalculate points for fallback scores OR if Gross override is active
                  // If Gross, PHC = 0.
                  final phc = isGross ? 0 : p.playingHandicap.round();

                 int totalPoints = 0;
                 int holesPlayed = 0;
                 
                 for (int i = 0; i < scoresToUse.length; i++) {
                    final score = scoresToUse[i];
                    if (score != null && i < holes.length) {
                       final par = holes[i]['par'] as int? ?? 4;
                       final si = holes[i]['si'] as int? ?? 18;
                       
                       // Calculate shots received on this hole
                       int shots = (phc ~/ 18);
                       if (si <= (phc % 18)) {
                         shots++;
                       }
                       
                       final netScore = score - shots;
                       // Stableford: 2 points for net par
                       final points = (2 + (par - netScore)).clamp(0, 10).toInt(); 
                       totalPoints += points;
                       holesPlayed++;
                    }
                 }
                 
                 if (holesPlayed > 0) {
                    scoreMap[playerId] = totalPoints.toString();
                 } else {
                    scoreMap[playerId] = '-';
                 }
             }
           } else {
            // Strokeplay: Calculate Net/Gross Differential
            int totalGross = 0;
            int holesPlayed = 0;

            for (int i = 0; i < scoresToUse.length; i++) {
              final score = scoresToUse[i];
              if (score != null) {
                totalGross += score;
                holesPlayed++;
              }
            }
            
            if (holesPlayed == 0) {
               scoreMap[playerId] = '-';
            } else {
               // Get Player's PHC
               final reg = event.registrations.firstWhere(
                  (r) => r.memberId == (playerId.endsWith('_guest') ? playerId.replaceFirst('_guest', '') : playerId),
                  orElse: () => EventRegistration(memberId: '', memberName: 'Unknown', attendingGolf: true),
               );
               final phc = isGross ? 0 : (reg.playingHandicap ?? 0);
               
               // Get Par for holes played
               int parForPlayed = 0;
               for (int i = 0; i < holesPlayed && i < holes.length; i++) {
                 parForPlayed += (holes[i]['par'] as int? ?? 4);
               } 

               // Calculate shots received for holes played (Standard SI match)
               int shotsReceived = 0;
               if (!isGross) {
                 for (int i = 0; i < holesPlayed && i < holes.length; i++) {
                    final si = holes[i]['si'] as int? ?? 18;
                    int shots = (phc ~/ 18);
                    if (si <= (phc % 18)) {
                      shots++;
                    }
                    shotsReceived += shots;
                 }
               }

               final netScore = totalGross - shotsReceived;
               final differential = netScore - parForPlayed;
               
               if (differential == 0) {
                  scoreMap[playerId] = 'E';
               } else if (differential > 0) {
                  scoreMap[playerId] = '+$differential';
               } else {
                  scoreMap[playerId] = '$differential';
               }
            }
           }
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
              rules: rules,
              courseConfig: event.courseConfig,
              isAdmin: false,
              isScoreMode: true,
              scoreMap: scoreMap,
              scorecardMap: {for (var s in scorecards) s.entryId: s},
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

  String _getDisplayName(GolfEvent event, String entryId) {
    // 1. Check registrations (Members)
    final reg = event.registrations.where((r) => r.memberId == entryId).firstOrNull;
    if (reg != null) {
      return reg.memberName;
    }

    // 2. Check grouping data (Guests)
    final groupsData = event.grouping['groups'] as List?;
    if (groupsData != null) {
      for (var g in groupsData) {
        final players = g['players'] as List?;
        final guest = players?.firstWhere((p) {
          final pid = p['id'] ?? p['registrationMemberId'];
          final id = p['isGuest'] == true ? '${pid}_guest' : pid;
          return id == entryId;
        }, orElse: () => null);
        if (guest != null) {
          return guest['name'] ?? 'Guest';
        }
      }
    }

    return 'OTHER';
  }

  String _formatHcp(double hcp) {
    return hcp.truncateToDouble() == hcp ? hcp.toInt().toString() : hcp.toStringAsFixed(1);
  }


  void _showMarkerSelectionSheet(GolfEvent event, bool isScoringActive) {
    // [Lab Mode] Allow sheet even if not technically active

    // [Lab Mode] Allow sheet even if not technically active if an override is providing a "Live" test state
    final statusOverride = ref.read(eventStatusOverrideProvider);
    final forceActiveOverride = ref.read(scoringForceActiveOverrideProvider);
    final isTesting = statusOverride != null || forceActiveOverride != null;

    if (!isScoringActive && !isTesting) {
      return;
    }

    final currentUser = ref.read(effectiveUserProvider);
    final groupsData = event.grouping['groups'] as List?;
    final List<dynamic> groups = groupsData ?? []; 
    
    List<String> groupMembers = [];
    List<Map<String, dynamic>> groupPlayersRaw = [];
    for (var g in groups) {
      final players = (g['players'] as List?) ?? [];
      final hasMe = players.any((p) {
        final pid = p['id'] ?? p['registrationMemberId'];
        return pid == currentUser.id;
      });
      
      if (hasMe) {
        groupPlayersRaw = List<Map<String, dynamic>>.from(players);
        break;
      }
    }

    // [Refinement] Only show members of the actual group
    // If no group is found, the list remains empty (except for "Myself")
    if (groupMembers.isEmpty) {
       // Do nothing - user sees only "Myself"
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final markerSelection = ref.watch(markerSelectionProvider);
        final bool isSelfMarking = markerSelection.isSelfMarking;
        final String? targetEntryId = markerSelection.targetEntryId;

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
                        trailing: isSelfMarking ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                        onTap: () {
                          ref.read(markerSelectionProvider.notifier).selectSelf();
                          Navigator.of(context).pop();
                        },
                      ),
                      
                      const Divider(height: 1),
                      
                      // Option 2: Group Members
                      ...groupPlayersRaw.where((p) {
                         final pid = p['id'] ?? p['registrationMemberId'];
                         final id = p['isGuest'] == true ? '${pid}_guest' : pid;
                         return id != currentUser.id;
                      }).map((p) {
                         final pid = p['id'] ?? p['registrationMemberId'];
                         final id = p['isGuest'] == true ? '${pid}_guest' : pid;
                         final name = p['name'] ?? 'Unknown';
                         final isSelected = !isSelfMarking && targetEntryId == id;
                          
                          return ListTile(
                             leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(p['isGuest'] == true ? Icons.person_outline : Icons.person, color: Theme.of(context).primaryColor),
                             ),
                             title: Text(name),
                             trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                             onTap: () {
                                ref.read(markerSelectionProvider.notifier).selectTarget(id!);
                                Navigator.of(context).pop();
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


  void _showPlayerScorecard(BuildContext context, LeaderboardEntry entry, List<Scorecard> scorecards, GolfEvent event, Competition? comp, {int? holeLimit}) {
    // 1. Try to find a live scorecard
    Scorecard? scorecard = scorecards.firstWhereOrNull((s) => s.entryId == entry.entryId);
    
    // 2. Fallback: Reconstruct from seeded results if live scorecard is missing
    if (scorecard == null) {
        final seededResult = event.results.firstWhere(
          (r) => (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString() == entry.entryId,
          orElse: () => {},
        );
        
        if (seededResult.isNotEmpty && seededResult['holeScores'] != null) {
            // Reconstruct temporary scorecard object
            scorecard = Scorecard(
              id: 'temp_${entry.entryId}',
              competitionId: widget.eventId,
              roundId: '1',
              entryId: entry.entryId,
              submittedByUserId: 'system',
              status: ScorecardStatus.finalScore,
              holeScores: List<int?>.from(seededResult['holeScores']),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              points: seededResult['points'] is num ? (seededResult['points'] as num).toInt() : null,
              netTotal: seededResult['netTotal'] is num ? (seededResult['netTotal'] as num).toInt() : null,
            );
        }
    }

    // 3. Final Bail if truly missing
    if (scorecard == null) return;

    final actualScorecard = scorecard;
    
    // Respect Lab Mode override
    final formatOverride = ref.read(gameFormatOverrideProvider);
    final currentFormat = formatOverride ?? (comp?.rules.format ?? CompetitionFormat.stableford);
    final isStableford = currentFormat == CompetitionFormat.stableford;
    
    final config = ref.read(themeControllerProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.playerName.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        Text(
                          'hc: ${_formatHcp(entry.handicap.toDouble())} | phc: ${entry.playingHandicap ?? "-"}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  child: Builder(
                    builder: (context) {
                      // final holes = event.courseConfig['holes'] as List? ?? []; // Unused
                      
                      // Resolve effective rules/format for modal
                      final maxTypeOverride = ref.watch(maxScoreTypeOverrideProvider);
                      final maxValueOverride = ref.watch(maxScoreValueOverrideProvider);
                      
                      MaxScoreConfig? effectiveMaxScore = comp?.rules.maxScoreConfig;
                      if (currentFormat == CompetitionFormat.maxScore) {
                        if (maxTypeOverride != null) {
                           effectiveMaxScore = MaxScoreConfig(
                             type: maxTypeOverride,
                             value: maxValueOverride ?? (effectiveMaxScore?.value ?? 2),
                           );
                        }
                      }

                      return CourseInfoCard(
                        courseConfig: event.courseConfig,
                        selectedTeeName: event.selectedTeeName,
                        distanceUnit: config.distanceUnit,
                        isStableford: isStableford,
                        playerHandicap: entry.playingHandicap,
                        scores: actualScorecard.holeScores,
                        format: currentFormat,
                        maxScoreConfig: effectiveMaxScore,
                        holeLimit: holeLimit, // [FIX] Apply simulation limit
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Define Format Helper

  LeaderboardEntry _buildEntry({
    required String id,
    required EventRegistration reg,
    required Map<String, dynamic> source,
    required GolfEvent event,
    required CompetitionRules effectiveRules,
    required List<dynamic> membersList,
    required CompetitionFormat currentFormat,
    int? holeLimit,
    bool isGuest = false,
  }) {
    // final type = source['type'] as String; // Unused
    final data = source['data'];
    final holes = event.courseConfig['holes'] as List? ?? [];
    
    // 1. Resolve Handicap Index
    double? handicapIndex;
    if (data is Map && data.containsKey('handicap')) {
       final raw = data['handicap'];
       if (raw is num) handicapIndex = raw.toDouble();
       else if (raw is String) handicapIndex = double.tryParse(raw);
    } 

    if (handicapIndex == null || (handicapIndex == 0.0 && !isGuest)) {
      if (isGuest) {
        handicapIndex = double.tryParse(reg.guestHandicap ?? '18') ?? 18.0;
      } else {
        final member = membersList.where((m) => m is Member && m.id == reg.memberId).firstOrNull as Member?;
        if (member != null && member.handicap != 0.0) {
           handicapIndex = member.handicap;
        } else if (handicapIndex == null) {
           handicapIndex = 18.0; 
        }
      }
    }

    // 2. Calculate Playing Handicap
    final phc = HandicapCalculator.calculatePlayingHandicap(
      handicapIndex: handicapIndex, 
      rules: effectiveRules, 
      courseConfig: event.courseConfig,
    );

    // 3. Extract Raw Hole Scores
    List<int?> rawScores = [];
    if (data is Scorecard) {
      rawScores = data.holeScores;
    } else if (data is Map) {
      final r = data;
      if (r['holeScores'] != null) {
        rawScores = List<int?>.from(r['holeScores']);
      }
    }

    // 4. Filter by Hole Limit (Simulation Mode)
    final List<int?> scoresToCalculate = [];
    for (int i = 0; i < rawScores.length; i++) {
      if (holeLimit != null && i >= holeLimit) break;
      scoresToCalculate.add(rawScores[i]);
    }
    
    final int holesPlayed = scoresToCalculate.where((sc) => sc != null).length;

    // 5. UNIFIED CALCULATION
    int displayScore = 0;
    String? scoreLabel;

    if (currentFormat == CompetitionFormat.stableford) {
      int totalPoints = 0;
      for (int i = 0; i < scoresToCalculate.length; i++) {
         final score = scoresToCalculate[i];
         if (score != null && i < holes.length) {
           final par = holes[i]['par'] as int? ?? 4;
           final si = holes[i]['si'] as int? ?? 18;
           
           final strokes = phc.round();
           final freeShots = (strokes ~/ 18) + (si <= (strokes % 18) ? 1 : 0);
           final netScore = score - freeShots;
           final points = (par - netScore + 2).clamp(0, 10);
           totalPoints += points;
         }
      }
      displayScore = totalPoints;
      scoreLabel = displayScore.toString();
    } else if (currentFormat == CompetitionFormat.matchPlay) {
      // Net Matchplay vs Par (Bogey Competition)
      int holesUp = 0;
      for (int i = 0; i < scoresToCalculate.length; i++) {
        final score = scoresToCalculate[i];
        if (score != null && i < holes.length) {
           final par = holes[i]['par'] as int? ?? 4;
           final si = holes[i]['si'] as int? ?? 18;
           final strokes = phc.round();
           final freeShots = (strokes ~/ 18) + (si <= (strokes % 18) ? 1 : 0);
           final netScore = score - freeShots;
           
           if (netScore < par) holesUp++;
           else if (netScore > par) holesUp--;
        }
      }
      displayScore = holesUp;
      if (displayScore == 0) scoreLabel = 'AS';
      else if (displayScore > 0) scoreLabel = '+$displayScore';
      else scoreLabel = '$displayScore';
    } else {
      // Strokeplay / Max Score
      final maxTypeOverride = ref.read(maxScoreTypeOverrideProvider);
      final maxValueOverride = ref.read(maxScoreValueOverrideProvider);
      MaxScoreConfig? effectiveMaxScore = effectiveRules.maxScoreConfig;
      
      if (currentFormat == CompetitionFormat.maxScore && maxTypeOverride != null) {
         effectiveMaxScore = MaxScoreConfig(
           type: maxTypeOverride,
           value: maxValueOverride ?? (effectiveMaxScore?.value ?? 2),
         );
      }

      int grossTotal = 0;
      int parTotal = 0;

      for (int i = 0; i < scoresToCalculate.length; i++) {
         int? score = scoresToCalculate[i];
         if (score != null && i < holes.length) {
            final par = holes[i]['par'] as int? ?? 4;
            final si = holes[i]['si'] as int? ?? 18;
            
            if (currentFormat == CompetitionFormat.maxScore && effectiveMaxScore != null) {
               int cap;
               if (effectiveMaxScore.type == MaxScoreType.fixed) {
                 cap = effectiveMaxScore.value;
               } else if (effectiveMaxScore.type == MaxScoreType.parPlusX) {
                 cap = par + effectiveMaxScore.value;
               } else {
                 // Net Double Bogey
                 final strokes = phc.round();
                 final holeStrokes = (strokes ~/ 18) + (si <= (strokes % 18) ? 1 : 0);
                 cap = par + 2 + holeStrokes;
               }
               if (score > cap) score = cap;
            }

            grossTotal += score;
            parTotal += par;
         }
      }
      
      if (holesPlayed > 0) {
         final partialPhc = (phc * (holesPlayed / 18));
         final netScore = grossTotal - partialPhc;
         final toPar = netScore - parTotal;
         
         displayScore = toPar.round();
         
         if (displayScore == 0) scoreLabel = 'E';
         else if (displayScore > 0) scoreLabel = '+$displayScore';
         else scoreLabel = '$displayScore';
         
      } else {
        displayScore = 999;
        scoreLabel = '-';
      }
    }

    return LeaderboardEntry(
      entryId: id,
      playerName: isGuest ? (reg.guestName ?? 'Guest') : reg.memberName,
      score: displayScore,
      scoreLabel: scoreLabel,
      handicap: handicapIndex.toInt(),
      playingHandicap: phc,
      holesPlayed: holesPlayed,
      isGuest: isGuest,
      tieBreakDetails: _calculateTieBreakDetails(scoresToCalculate, effectiveRules, event.courseConfig, phc),
    );
  }

}

// [LAB MODE] Master Control Panel
// [LAB MODE Master Control Panel] - Moved to lib/features/events/presentation/widgets/lab_control_panel.dart
