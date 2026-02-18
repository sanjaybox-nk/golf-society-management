import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../../features/debug/presentation/widgets/lab_control_panel.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/utils/handicap_calculator.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/scorecard.dart';
// REDACTED: unused member import
import '../../../../core/theme/app_theme.dart';
import 'package:golf_society/features/competitions/presentation/widgets/leaderboard_widget.dart';
import 'package:golf_society/models/competition.dart';
import '../../../members/presentation/members_provider.dart';
import '../widgets/grouping_widgets.dart';
import '../widgets/event_leaderboard.dart';
import '../widgets/scorecard_modal.dart';
import '../events_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../../core/theme/theme_controller.dart';
import '../widgets/course_info_card.dart';
import '../widgets/hole_by_hole_scoring_widget.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../../models/golf_event.dart';
// REDACTED: unused imports
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
import 'event_user_registration_tab.dart';


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
final eventFieldTabProvider = NotifierProvider<SelectedTabNotifier, int>(() => SelectedTabNotifier('event_field_tab'));

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
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) {
          return const Scaffold(body: Center(child: Text('Event not found')));
        }
        
        var effectiveEvent = event;
        // [LAB MODE] Apply Status Override
        if (statusOverride != null) {
          effectiveEvent = effectiveEvent.copyWith(status: statusOverride);
        }
        
        final bool isPublished = effectiveEvent.isGroupingPublished;
        final groupsData = effectiveEvent.grouping['groups'] as List?;
        final List<TeeGroup> groups = groupsData != null 
            ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
            : [];

        return HeadlessScaffold(
          title: event.title,
          subtitle: 'Field Hub',
          showBack: true,
          onBack: () => context.go('/events'),
          actions: const [],
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              sliver: SliverToBoxAdapter(
                child: _FieldHubToggle(),
              ),
            ),
            if (ref.watch(eventFieldTabProvider) == 0) ...[
              // Registrations View
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: membersAsync.when(
                    data: (members) => EventRegistrationUserTab.buildStaticContent(context, ref, event, members),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => const Text('Error loading member registrations'),
                  ),
                ),
              ),
            ] else ...[
              // Pairings View
              if (!isPublished)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 16),
                          Text('Grouping not yet published', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('The Admin will publish the tee sheet soon.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                    ),
                  ),
                )
              else 
                SliverPadding(
                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                   sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                         (context, index) {
                            if (index == 0) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: BoxyArtSectionTitle(title: 'Grouping'),
                              );
                            }
                            final group = groups[index - 1]; // Adjust index
                            // Prepare data for GroupingCard
                            final members = membersAsync.value ?? [];
                            final memberMap = {for (var m in members) m.id: m};
                            // History for variety calculation (same season, previous events)
                            final history = events.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
                            final comp = compAsync.value;
                            
                            return Padding(
                               padding: const EdgeInsets.only(bottom: 12),
                               child: GroupingCard(
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
                               ),
                            );
                         },
                         childCount: groups.length + 1, // Add 1 for title
                      ),
                   ),
                ),
            ],
          ],
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

class _FieldHubToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(eventFieldTabProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Expanded(
              child: _ToggleItem(
                label: 'Entries',
                icon: Icons.people_outline_rounded,
                isSelected: selectedTab == 0,
                onTap: () => ref.read(eventFieldTabProvider.notifier).set(0),
              ),
            ),
            Expanded(
              child: _ToggleItem(
                label: 'Groupings',
                icon: Icons.grid_view_rounded,
                isSelected: selectedTab == 1,
                onTap: () => ref.read(eventFieldTabProvider.notifier).set(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
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
    return eventsAsync.when(
      data: (events) {
        // [Lab Mode] Apply overrides
        final statusOverride = ref.watch(eventStatusOverrideProvider);
        final baseEvent = events.firstWhereOrNull((e) => e.id == widget.eventId);
        if (baseEvent == null) {
          return const Scaffold(body: Center(child: Text('Event not found')));
        }
        
        var event = baseEvent;
        if (statusOverride != null) {
          event = event.copyWith(status: statusOverride);
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


            return HeadlessScaffold(
              title: event.title,
              subtitle: 'Live Hub',
              showBack: true,
              onBack: () => context.go('/events'),
              actions: const [],
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  sliver: SliverToBoxAdapter(
                    child: _LiveHubToggle(event: event),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildTabContent(event, comp, leaderboardEntries, effectiveRules),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
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
    final bool isScoringActive = (forceActiveOverride == true) || (!isCompleted && ((effectiveStatus == EventStatus.inPlay) || (isSameDayOrPast && !isLocked)));
    final bool shouldShowCard = isSameDayOrPast || isCompleted || isLocked;

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
        
        // [FIX] Use list lookup instead of single provider to ensure consistency with loaded data
        // var userScorecard = ref.watch(scorecardByEntryIdProvider((competitionId: widget.eventId, entryId: effectiveEntryId)));
        
        final allScorecards = ref.watch(scorecardsListProvider(widget.eventId)).asData?.value ?? [];
        final userScorecard = allScorecards.firstWhereOrNull((s) => s.entryId == effectiveEntryId);

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
        
        // [TEAM SCORER AWARENESS]
        // If in a team game (Scramble/Pairs), check if a teammate is scoring
        Scorecard? partnerCard;
        String? partnerName;
        bool hasScoreConflict = false;
        
        if (effectiveRules.effectiveMode != CompetitionMode.singles && isSelfMarking) { // Only relevant for self-marking their own team
           final groupsData = event.grouping['groups'] as List?;
           if (groupsData != null) {
              // Find my group and team
              for (var g in groupsData) {
                 final players = (g['players'] as List).map((p) => TeeGroupParticipant.fromJson(p)).toList();
                 final myIndex = players.indexWhere((p) => (p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId) == effectiveEntryId);
                 
                 if (myIndex != -1) {
                    // Identify Team Members
                    final teamSize = effectiveRules.teamSize; // Default 4 if null
                    // If teamSize is 2 (Pairs), indices 0-1 are Team A, 2-3 are Team B
                    // If teamSize is 3/4 (Scramble), whole group (upto teamSize) is one team usually
                    
                    int teamStartIndex = (myIndex ~/ teamSize) * teamSize;
                    int teamEndIndex = teamStartIndex + teamSize;
                    if (teamEndIndex > players.length) teamEndIndex = players.length;
                    
                    final teamMembers = players.sublist(teamStartIndex, teamEndIndex);
                    
                    // Check their scorecards
                    for (var member in teamMembers) {
                       final memberId = member.isGuest ? '${member.registrationMemberId}_guest' : member.registrationMemberId;
                       if (memberId == effectiveEntryId) continue; // Skip myself
                       
                       final pCard = allScorecards.firstWhereOrNull((s) => s.entryId == memberId);
                       if (pCard != null && pCard.holeScores.any((s) => s != null)) {
                          // Found a teammate with scores
                          // Conflict Check: Do I also have scores?
                          if (userScorecard != null && userScorecard.holeScores.any((s) => s != null)) {
                             // potential conflict or just parallel scoring
                             // Check for specific hole mismatch
                             for (int i=0; i<18; i++) {
                                final myScore = userScorecard.holeScores.elementAtOrNull(i);
                                final theirScore = pCard.holeScores.elementAtOrNull(i);
                                if (myScore != null && theirScore != null && myScore != theirScore) {
                                   hasScoreConflict = true;
                                   partnerName = member.name; // Blame the first one found
                                   partnerCard = pCard;
                                   break;
                                }
                             }
                          } else {
                             // I have no scores (or empty), so they are the active scorer
                             if (partnerCard == null || (pCard.holeScores.where((s) => s != null).length > partnerCard.holeScores.where((s) => s != null).length)) {
                                partnerCard = pCard;
                                partnerName = member.name;
                             }
                          }
                       }
                       if (hasScoreConflict) break;
                    }
                    break; // Found my group
                 }
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
            
            // [TEAM SCORER AWARENESS UI]
            if (partnerCard != null && !hasScoreConflict)
               Padding(
                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                 child: Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: Colors.blue.withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                   ),
                   child: Row(
                     children: [
                       const Icon(Icons.info_outline, color: Colors.blue),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               'Partner Scoring Active',
                               style: TextStyle(
                                 fontSize: 12,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.blue.shade800,
                               ),
                             ),
                             Text(
                               '${partnerName ?? 'Teammate'} is keeping score.',
                               style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                             ),
                           ],
                         ),
                       ),
                       TextButton(
                         onPressed: () {
                           // "Take Over" / Copy Scores logic
                           _copyScoresFromPartner(partnerCard!);
                         },
                         style: TextButton.styleFrom(
                           visualDensity: VisualDensity.compact,
                           foregroundColor: Colors.blue.shade800,
                           textStyle: const TextStyle(fontWeight: FontWeight.bold),
                         ),
                         child: const Text('SYNC TO ME'),
                       ),
                     ],
                   ),
                 ),
               ),

            if (hasScoreConflict)
               Padding(
                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                 child: Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: Colors.orange.withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                   ),
                   child: Row(
                     children: [
                       const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text(
                               'Score Conflict Detected',
                               style: TextStyle(
                                 fontSize: 12,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.deepOrange,
                               ),
                             ),
                             Text(
                               'You and ${partnerName ?? 'Partner'} have different scores.',
                               style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
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
            
            if (fallbackScores != null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Showing seeded scores for preview purposes.',
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                ),
          ],
        );
      }
      case 1: { // Group Scores
        return _buildGroupScoresTab(event, effectiveRules, playerHoleLimits);
      }

      case 2: { // Leaderboard
        final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));
        final membersAsync = ref.watch(allMembersProvider);
        
        return scorecardsAsync.when(
          data: (scorecards) => EventLeaderboard(
            event: event,
            comp: comp,
            liveScorecards: scorecards,
            membersList: membersAsync.value ?? [],
            playerHoleLimits: playerHoleLimits,
            onPlayerTap: (entry) => ScorecardModal.show(
              context, 
              ref,
              entry: entry, 
              scorecards: scorecards, 
              event: event, 
              comp: comp,
              membersList: membersAsync.value ?? [],
              holeLimit: playerHoleLimits[entry.entryId] ?? simulationHoles,
            ),
          ),
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
        final holes = event.courseConfig['holes'] as List? ?? [];

        // [LAB MODE]
        final isTeamMode = rules.effectiveMode != CompetitionMode.singles;
        final teamSize = rules.teamSize;

        final Map<String, String> scoreMap = {};
        final Map<String, int> teamPhcMap = {}; // [NEW] Track Team PHCs
        final Map<String, bool> winnerMap = {};
        
        for (var group in groups) {
           // Partition group into teams if necessary
           final List<List<TeeGroupParticipant>> teams = [];
           if (isTeamMode) {
              for (int i = 0; i < group.players.length; i += teamSize) {
                 teams.add(group.players.skip(i).take(teamSize).toList());
              }
           } else {
              for (var p in group.players) { teams.add([p]); }
           }

           for (var team in teams) {
              if (team.isEmpty) continue;
              
              // 1. Calculate Team PHC
              int teamPhc = 0;
              if (isTeamMode) {
                 final List<double> indices = [];
                 for (var p in team) {
                    final member = membersAsync.value?.firstWhereOrNull((m) => m.id == p.registrationMemberId);
                    indices.add(member?.handicap ?? p.handicapIndex);
                 }
                 teamPhc = HandicapCalculator.calculateTeamHandicap(
                    individualIndices: indices, 
                    rules: rules, 
                    courseConfig: event.courseConfig,
                 );
              }

              // 2. Find Team Score (Try each member for a card)
              Scorecard? teamCard;
              for (var p in team) {
                 final playerId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                 final card = scorecards.firstWhereOrNull((s) => s.entryId == playerId);
                 if (card != null && card.holeScores.isNotEmpty) {
                    teamCard = card;
                    break;
                 }
              }

              // 3. Fallback to seeded result
              if (teamCard == null) {
                 for (var p in team) {
                    final playerId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                    final seeded = event.results.firstWhereOrNull((r) => r['playerId'] == playerId);
                    if (seeded != null && seeded['holeScores'] != null) {
                       teamCard = Scorecard(
                          id: 'seeded', 
                          competitionId: event.id, 
                          roundId: '1', 
                          entryId: playerId,
                          submittedByUserId: 'system',
                          holeScores: List<int?>.from(seeded['holeScores']),
                          status: ScorecardStatus.finalScore,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                       );
                       break;
                    }
                 }
              }

              // 4. Calculate Score using Team PHC
              String displayScore = '-';
              if (teamCard != null && teamCard.holeScores.isNotEmpty) {
                 final limit = playerHoleLimits[teamCard.entryId];
                 List<int?> scoresToUse = teamCard.holeScores;
                 if (limit != null) {
                    scoresToUse = teamCard.holeScores.take(limit).toList();
                 }

                 // Use Team PHC if in team mode, else individual
                 int effectivePhc = isTeamMode ? teamPhc : HandicapCalculator.calculatePlayingHandicap(
                    handicapIndex: membersAsync.value?.firstWhereOrNull((m) => m.id == team.first.registrationMemberId)?.handicap ?? team.first.handicapIndex,
                    rules: rules,
                    courseConfig: event.courseConfig,
                 );

                 if (isGross) {
                   effectivePhc = 0;
                 }

                 if (isStableford) {
                    int totalPoints = 0;
                    for (int i = 0; i < scoresToUse.length; i++) {
                       final score = scoresToUse[i];
                       if (score != null && i < holes.length) {
                          final par = holes[i]['par'] as int? ?? 4;
                          final si = holes[i]['si'] as int? ?? 18;
                          final shots = (effectivePhc ~/ 18) + (si <= (effectivePhc % 18) ? 1 : 0);
                          final points = (2 + (par - (score - shots))).clamp(0, 10).toInt();
                          totalPoints += points;
                       }
                    }
                    displayScore = totalPoints.toString();
                 } else {
                    int totalGross = 0;
                    int parTotal = 0;
                    int holesPlayed = 0;
                    for (int i = 0; i < scoresToUse.length; i++) {
                       final score = scoresToUse[i];
                       if (score != null && i < holes.length) {
                          totalGross += score;
                          parTotal += (holes[i]['par'] as int? ?? 4);
                          holesPlayed++;
                       }
                    }
                    if (holesPlayed > 0) {
                       final netDiff = totalGross - (effectivePhc * (holesPlayed / 18)) - parTotal;
                       final diff = netDiff.round();
                       if (diff == 0) {
                         displayScore = 'E';
                       } else if (diff > 0) {
                         displayScore = '+$diff';
                       } else {
                         displayScore = '$diff';
                       }
                    }
                 }
              }

              // 5. Apply to all team members
              for (var p in team) {
                 final playerId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                 scoreMap[playerId] = displayScore;
                 if (isTeamMode) teamPhcMap[playerId] = teamPhc;
              }
           }
        }

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0), // Consistent label spacing
              child: BoxyArtSectionTitle(title: 'Group Scores'),
            ),
            ListView.builder(
              padding: EdgeInsets.zero,
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
                  winnerMap: winnerMap,
                  phcMap: teamPhcMap,
                );
              },
            ),
          ],
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
    final forceActiveOverride = ref.watch(scoringForceActiveOverrideProvider);
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
              (forceActiveOverride == true) 
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



  // Define Format Helper
  Future<void> _copyScoresFromPartner(Scorecard partnerCard) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sync Scores?'),
        content: const Text(
          'This will copy all scores from your partner to your scorecard. Any existing scores on your card will be overwritten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sync'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(scorecardRepositoryProvider);
        final currentUser = ref.read(effectiveUserProvider);
        
        // precise target depends on if self-marking or not, but usually this button appears on "My Score" tab implying my card
        // We need to find MY card.
        final myCard = ref.read(scorecardsListProvider(widget.eventId)).asData?.value
            .firstWhereOrNull((s) => s.entryId == currentUser.id);

        if (myCard == null) {
           // Create new card with partner's scores
           final newCard = Scorecard(
              id: '', 
              competitionId: widget.eventId,
              roundId: 'round_1',
              entryId: currentUser.id,
              submittedByUserId: currentUser.id,
              holeScores: List.from(partnerCard.holeScores),
              status: ScorecardStatus.draft,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
           );
           await repo.addScorecard(newCard);
        } else {
           // Update existing
           final updated = myCard.copyWith(
              holeScores: List.from(partnerCard.holeScores),
              updatedAt: DateTime.now(),
           );
           await repo.updateScorecard(updated);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scores synced successfully!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error syncing scores: $e')),
          );
        }
      }
    }
  }


}

class EventStatsUserTab extends ConsumerWidget {
  final String eventId;
  const EventStatsUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
    final isPeeking = ref.watch(impersonationProvider) != null;

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) {
          return const Scaffold(body: Center(child: Text('Event not found')));
        }
        return HeadlessScaffold(
          title: event.title,
          subtitle: 'Advanced Stats',
          showBack: true,
          onBack: () => context.go('/events'),
          actions: [
            IconButton(
              icon: Icon(Icons.science, color: isPeeking ? Colors.orange : Colors.black),
              onPressed: () {
                showModalBottomSheet(
                  context: context, 
                  isScrollControlled: true,
                  builder: (context) => LabControlPanel(eventId: event.id)
                );
              },
            ),
          ],
          slivers: [
            SliverToBoxAdapter(
              child: compAsync.when(
                data: (comp) => scorecardsAsync.when(
                  data: (scorecards) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    child: EventStatsTab(
                      event: event,
                      comp: comp,
                      liveScorecards: scorecards,
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

// [HUB NAVIGATION] Modern Live Hub Toggle
class _LiveHubToggle extends ConsumerWidget {
  final GolfEvent event;

  const _LiveHubToggle({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(eventDetailsTabProvider);

    final List<({String label, int index, IconData icon})> tabs = [
      (label: 'My Score', index: 0, icon: Icons.assignment_outlined),
      (label: 'Group', index: 1, icon: Icons.groups_outlined),
      (label: 'Leaderboard', index: 2, icon: Icons.emoji_events_outlined),
    ];

    if (event.matches.isNotEmpty) {
      tabs.add((label: 'Matches', index: 4, icon: Icons.grid_view_outlined));
    }
    if (event.matches.any((m) => m.bracketId != null)) {
      tabs.add((label: 'Bracket', index: 5, icon: Icons.account_tree_outlined));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: tabs.map((tab) {
            final isSelected = selectedTab == tab.index;
            return Expanded(
              child: _ToggleItem(
                label: tab.label,
                icon: tab.icon,
                isSelected: isSelected,
                onTap: () => ref.read(eventDetailsTabProvider.notifier).set(tab.index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
