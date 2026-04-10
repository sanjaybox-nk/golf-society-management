import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../../domain/scoring/scoring_calculator.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../../domain/grouping/grouping_service.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/features/competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../members/presentation/members_provider.dart';
import '../widgets/grouping_widgets.dart';
import '../widgets/event_leaderboard.dart';
import '../widgets/scorecard_modal.dart';
import '../events_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../widgets/sliding_course_info_card.dart';
import '../widgets/hole_by_hole_scoring_widget.dart';
import '../../../competitions/presentation/competitions_provider.dart';
// REDACTED: unused imports
// REDACTED: unused imports
import 'package:golf_society/services/persistence_service.dart';
import '../../../matchplay/presentation/widgets/matches_list_widget.dart';
import '../../../matchplay/presentation/widgets/matches_bracket_widget.dart';
import '../../../matchplay/presentation/widgets/match_group_standings_widget.dart';
import '../../../matchplay/domain/golf_event_match_extensions.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../logic/event_scoring_controller.dart';
import '../../domain/models/processed_event_data.dart';

import 'event_stats_tab.dart';
import 'event_user_registration_tab.dart';
import '../../../matchplay/presentation/state/match_play_providers.dart'; // [NEW] Added for Match Play row in My Score tab
import '../state/marker_selection_provider.dart';





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

final eventMyCardTabProvider = NotifierProvider<SelectedTabNotifier, int>(() => SelectedTabNotifier('event_my_card_tab'));
final eventScoresHubTabProvider = NotifierProvider<SelectedTabNotifier, int>(() => SelectedTabNotifier('event_scores_hub_tab'));
class SimpleTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int val) => state = val;
}
final eventFieldTabProvider = NotifierProvider<SimpleTabNotifier, int>(() => SimpleTabNotifier());

class EventGroupingUserTab extends ConsumerWidget {
  final String eventId;
  final bool isAdminMode;
  const EventGroupingUserTab({super.key, required this.eventId, this.isAdminMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final membersAsync = ref.watch(allMembersProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) {
          return const HeadlessScaffold(
            title: 'Not Found',
            showBack: true,
            slivers: [
              SliverFillRemaining(
                child: BoxyArtEmptyCard(
                  title: 'Event Not Found',
                  message: 'The requested event could not be located on the fairway.',
                  icon: Icons.error_outline_rounded,
                ),
              ),
            ],
          );
        }
        
        var effectiveEvent = event;
        
        final bool isPublished = effectiveEvent.isGroupingPublished;
        final bool isSocial = effectiveEvent.eventType == EventType.social;
        
        final groupsData = effectiveEvent.grouping['groups'] as List?;
        final List<TeeGroup> groups = groupsData != null 
            ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
            : [];

        final user = ref.watch(effectiveUserProvider);
        final isStaff = user.role != MemberRole.member;

        return HeadlessScaffold(
          title: event.title,
          subtitle: 'Event Field and Tee Time',
          showAdminShortcut: false, // Explicitly removed as per user preference
          showBack: true,
          onBack: () => context.go('/events'),

          actions: [
            if (isAdminMode && isStaff)
              BoxyArtGlassIconButton(
                icon: Icons.edit_rounded,
                tooltip: 'Manage Pairings',
                onPressed: () => context.push('/admin/events/manage/${event.id}/event/grouping'),
              ),
          ],
          slivers: [
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -16.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: _FieldHubToggle(),
                ),
              ),
            ),
            if (ref.watch(eventFieldTabProvider) == 0)
              // Registrations View (Entries)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: membersAsync.when(
                    data: (members) => EventRegistrationUserTab.buildStaticContent(context, ref, event, members, isAdminMode: isAdminMode),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => BoxyArtEmptyState(
                      title: 'Loading Error',
                      message: 'Error loading member registrations: $error',
                      icon: Icons.error_outline_rounded,
                      isCompact: true,
                    ),
                  ),
                ),
              )
            else
              // Pairings View (Tee Time)
              if (isSocial)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: BoxyArtEmptyCard(
                    title: 'No Pairings',
                    message: 'Social events typically favor a relaxed atmosphere without formal tee times.',
                    icon: Icons.favorite_border_rounded,
                  ),
                )
              else if (!isPublished || groups.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: BoxyArtEmptyCard(
                    title: 'Tee Time Not Published',
                    message: 'Official pairings are currently being finalized. Keep an eye on the clubhouse!',
                    icon: Icons.schedule_rounded,
                  ),
                )
              else
                SliverPadding(
                   padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.pageBottom),
                   sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                         (context, index) {
                             final group = groups[index];
                             final members = membersAsync.value ?? [];
                             final memberMap = {for (var m in members) m.id: m};
                            final history = events.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
                            final comp = compAsync.value;
                            
                            // Authoritative score/PHC data from central engine
                            final scoringData = ref.watch(eventScoringControllerProvider(eventId));
                             final Map<String, String> scoreMap = { for (var s in scoringData.individualScores) s.playerId : s.result.label };
                             final Map<String, int> phcMap = { for (var s in scoringData.individualScores) s.playerId : s.playingHandicap.round() };
                             final Map<String, String> thruMap = { for (var s in scoringData.individualScores) if (s.thruLabel != null) s.playerId : s.thruLabel! };
                             final Map<String, String> tieBreakMap = { for (var s in scoringData.individualScores) if (s.tieBreakLabel != null) s.playerId : s.tieBreakLabel! };
                             final Map<String, ScoringStatus> statusMap = { for (var s in scoringData.individualScores) s.playerId : s.scoringStatus };
                             final Map<String, bool> winnerMap = { for (var e in scoringData.leaderboard) e.entryId : e.position == 1 };
                             final allScorecards = scorecardsAsync.asData?.value ?? [];
                             final Map<String, Scorecard> scorecardMap = { for (var s in allScorecards) s.entryId : s };
 
                            final spacing = Theme.of(context).extension<AppSpacingTokens>();

                            return Padding(
                               padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.md),
                               child: GroupingCard(
                                  group: group,
                                  memberMap: memberMap,
                                  history: history,
                                  totalGroups: groups.length,
                                  rules: comp?.rules,
                                  courseConfig: event.courseConfig,
                                  isAdmin: false,
                                  isScoreMode: false,
                                  scoreMap: scoreMap,
                                  phcMap: phcMap,
                                  hcMap: { for (var s in scoringData.individualScores) s.playerId : s.handicapIndex },
                                   scorecardMap: scorecardMap,
                                   tieBreakMap: tieBreakMap,
                                   thruMap: thruMap,
                                   statusMap: statusMap,
                                   winnerMap: winnerMap,
                                   showScoring: event.isGroupingPublished, // Surface results once groups are public
                                ),
                            );
                         },
                         childCount: groups.length,
                      ),
                   ),
                ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(
        title: 'Loading...',
        slivers: [
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (err, stack) => HeadlessScaffold(
        title: 'Error',
        showBack: true,
        slivers: [
          SliverFillRemaining(
            child: BoxyArtEmptyState(
              title: 'Unexpected Error',
              message: err.toString(),
              icon: Icons.warning_amber_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldHubToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(eventFieldTabProvider);

    return ModernUnderlinedFilterBar<int>(
      selectedValue: selectedTab,
      isExpanded: true,
      onTabSelected: (val) => ref.read(eventFieldTabProvider.notifier).set(val),
      tabs: const [
        ModernFilterTab(label: 'Entries', value: 0),
        ModernFilterTab(label: 'Tee Time', value: 1),
      ],
    );
  }
}


class EventScoresUserTab extends ConsumerStatefulWidget {
  final String eventId;
  final bool isAdminMode;
  const EventScoresUserTab({super.key, required this.eventId, this.isAdminMode = false});

  @override
  ConsumerState<EventScoresUserTab> createState() => _EventScoresUserTabState();
}

class _EventScoresUserTabState extends ConsumerState<EventScoresUserTab> {
  // Local state for tabs and markers removed to use providers below
  Map<int, int>? _optimisticScores; // [Optimistic UI]
  bool _optimisticIsVerifier = false;
  
  // TRACK SELECTED TAB (Lifted State from HoleByHole)
  MarkerTab _selectedMarkerTab = MarkerTab.player;

  void _onScoresChanged(Map<int, int> scores, bool isVerifier) {
    setState(() {
      _optimisticScores = scores;
      _optimisticIsVerifier = isVerifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final compAsync = ref.watch(competitionDetailProvider(widget.eventId));
    final scoringData = ref.watch(eventScoringControllerProvider(widget.eventId));

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == widget.eventId);
        if (event == null) {
          return const HeadlessScaffold(
            title: 'Not Found',
            showBack: true,
            slivers: [
              SliverFillRemaining(
                child: BoxyArtEmptyState(
                  title: 'Event Not Found',
                  message: 'The requested event could not be located.',
                  icon: Icons.error_outline_rounded,
                ),
              ),
            ],
          );
        }

        return compAsync.when(
          data: (comp) {
            final effectiveRules = comp?.rules ?? const CompetitionRules();

            // --- Calculation for Header Badge ---
            final currentUser = ref.watch(effectiveUserProvider);
            final markerSelection = ref.watch(markerSelectionProvider);
            final bool isSelfMarking = markerSelection.isSelfMarking;
            final String? targetEntryId = markerSelection.targetEntryId;
            final String effectiveEntryId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);

            final allScorecards = ref.watch(scorecardsListProvider(widget.eventId)).asData?.value ?? [];
            final userScorecard = allScorecards.firstWhereOrNull((s) => s.entryId == effectiveEntryId);
            
            String? headerBadgeText;
            Color? headerBadgeColor;
            VoidCallback? headerOnBadgeTap;
            
            final effectiveStatus = event.status;
            final bool isLocked = event.isScoringLocked == true;
            final bool isCompleted = effectiveStatus == EventStatus.completed;
            
            final now = DateTime.now();
            final isSameDayOrPast = now.year == event.date.year && 
                                     now.month == event.date.month && 
                                     now.day == event.date.day || 
                                     now.isAfter(event.date);

            final bool isScoringActive = !isCompleted && ((effectiveStatus == EventStatus.inPlay) || (isSameDayOrPast && !isLocked));
            final bool isCardFull = userScorecard?.holeScores.length == 18 && userScorecard!.holeScores.every((s) => s != null && s > 0);

            if (isLocked) {
              headerBadgeText = "Final Score";
              headerBadgeColor = AppColors.lime600;
            } else if (isCompleted) {
              headerBadgeText = null;
              headerBadgeColor = Colors.transparent;
            } else if (!isScoringActive) {
              headerBadgeText = "Not Active";
              headerBadgeColor = AppColors.dark300;
            } else if (userScorecard != null) {
              if (userScorecard.status == ScorecardStatus.draft && isCardFull) {
                headerBadgeText = "Submit";
                headerBadgeColor = AppColors.amber500; 
                headerOnBadgeTap = () => _submitScorecard(userScorecard.id);
              } else {
                if (userScorecard.status == ScorecardStatus.submitted) {
                  headerBadgeText = "Submitted";
                  headerOnBadgeTap = () => _confirmUnsubmit(userScorecard.id);
                } else if (userScorecard.status == ScorecardStatus.reviewed || 
                           userScorecard.status == ScorecardStatus.finalScore) {
                  headerBadgeText = "Confirmed";
                } else {
                  headerBadgeText = "Scoring";
                }
                headerBadgeColor = _getStatusColor(userScorecard.status);
              }
            } else {
              headerBadgeText = "Active";
              headerBadgeColor = AppColors.lime400;
            }

            final isStaff = currentUser.role != MemberRole.member;

            return HeadlessScaffold(
              title: event.title,
              subtitle: 'My Event Card',
              showAdminShortcut: false, // Explicitly removed as per user preference
              showBack: true,
              onBack: () => context.go('/events'),

              actions: [
                if (widget.isAdminMode && isStaff)
                  BoxyArtGlassIconButton(
                    icon: Icons.edit_rounded,
                    tooltip: 'Manage Scores',
                    onPressed: () => context.push('/admin/events/manage/${event.id}/event/scores'),
                  ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: headerOnBadgeTap,
                      child: headerBadgeText == null 
                        ? const SizedBox.shrink()
                        : BoxyArtPill.status(
                            label: headerBadgeText,
                            color: headerBadgeColor,
                            hasHorizontalMargin: false,
                          ),
                    ),
                  ),
                ),
              ],
              pinnedBottom: _buildPinnedScoring(event, comp, scoringData, effectiveRules),
              pinnedBottomPadding: AppSpacing.md,
              slivers: [
                if (event.matches.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -16.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        child: _LiveHubToggle(event: event),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  sliver: SliverToBoxAdapter(
                     child: _buildTabContent(event, comp, [], effectiveRules, scoringData),
                  ),
                ),
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
  
  Widget? _buildPinnedScoring(GolfEvent event, Competition? comp, ProcessedEventData? scoringData, CompetitionRules effectiveRules) {
    final activeIndex = ref.watch(eventMyCardTabProvider);
    if (activeIndex != 0) return null;
    
    final currentUser = ref.watch(effectiveUserProvider);
    final markerSelection = ref.watch(markerSelectionProvider);
    final bool isSelfMarking = markerSelection.isSelfMarking;
    final String? targetEntryId = markerSelection.targetEntryId;
    final String effectiveEntryId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);
    
    final allScorecards = ref.watch(scorecardsListProvider(event.id)).asData?.value ?? [];
    final userScorecard = allScorecards.firstWhereOrNull((s) => s.entryId == effectiveEntryId);
    final myCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id);

    final now = DateTime.now();
    final isSameDayOrPast = now.year == event.date.year && 
                             now.month == event.date.month && 
                             now.day == event.date.day || 
                             now.isAfter(event.date);
    
    final effectiveStatus = event.status;
    final bool isLocked = event.isScoringLocked == true;
    final bool isCompleted = effectiveStatus == EventStatus.completed;
    final bool shouldShowCard = isSameDayOrPast || isCompleted || isLocked;
    
    if (!shouldShowCard) return null;
    
    return HoleByHoleScoringWidget(
      event: event,
      targetScorecard: userScorecard,
      verifierScorecard: myCard,
      targetEntryId: effectiveEntryId,
      isSelfMarking: isSelfMarking,
      selectedTab: _selectedMarkerTab,
      onTabChanged: (tab) {
        setState(() {
          _selectedMarkerTab = tab;
          _optimisticScores = null;
        });
      },
      onScoresChanged: _onScoresChanged,
    );
  }

  Widget _buildTabContent(GolfEvent event, Competition? comp, List<LeaderboardEntry> mockEntries, CompetitionRules effectiveRules, ProcessedEventData? scoringData) {
    final config = ref.watch(themeControllerProvider);
    final currentUser = ref.watch(effectiveUserProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(event.id));
    final members = ref.watch(allMembersProvider).asData?.value ?? [];
    
    final currentFormat = comp?.rules.format ?? CompetitionFormat.stableford;
    final isStableford = currentFormat == CompetitionFormat.stableford;
    final isFourballOrPairs = effectiveRules.subtype == CompetitionSubtype.fourball || 
                              effectiveRules.mode == CompetitionMode.pairs ||
                              effectiveRules.subtype == CompetitionSubtype.foursomes;

    final now = DateTime.now();
    final isSameDayOrPast = now.year == event.date.year && 
                             now.month == event.date.month && 
                             now.day == event.date.day || 
                             now.isAfter(event.date);
    
    final effectiveStatus = event.status;

    final bool isLocked = event.isScoringLocked == true;
    final bool isCompleted = effectiveStatus == EventStatus.completed;
    // [FIX] Allow Force Active override removed (Lab only)
    final bool isScoringActive = !isCompleted && ((effectiveStatus == EventStatus.inPlay) || (isSameDayOrPast && !isLocked));
    final bool shouldShowCard = isSameDayOrPast || isCompleted || isLocked;

    final Map<String, int> playerHoleLimits = {};
    
    // Default Values for My Score hub
    final markerSelection = ref.watch(markerSelectionProvider);
    final bool isSelfMarking = markerSelection.isSelfMarking;
    final String? targetEntryId = markerSelection.targetEntryId;
    final String effectiveEntryId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);
    final allScorecards = ref.watch(scorecardsListProvider(widget.eventId)).asData?.value ?? [];
    final userScorecard = allScorecards.firstWhereOrNull((s) => s.entryId == effectiveEntryId);
    final myCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id);
    
    List<int?> displayScores = [];
    int playingHcpValue = 0;
    double baseHcp = currentUser.handicap;
    int? limit;
    Scorecard? partnerCard;
    String? partnerName;
    bool hasScoreConflict = false;

    // Calculate My Score Hub data (re-used for default case)
    {
      List<int?>? fallbackScores;
      var seededResultForSelf = event.results.firstWhere(
        (r) => r['playerId'] == effectiveEntryId,
        orElse: () => {},
      );
      if (seededResultForSelf.isEmpty) {
        seededResultForSelf = event.results.firstWhere(
          (r) => (r['playerId'] as String?)?.contains(effectiveEntryId) == true ||
                 effectiveEntryId.contains(r['playerId'] as String? ?? '___'),
          orElse: () => {},
        );
      }
      if (seededResultForSelf.isNotEmpty && seededResultForSelf['holeScores'] != null) {
        fallbackScores = List<int?>.from(seededResultForSelf['holeScores']);
      }

      List<int?> rawDisplayScores;
      if (userScorecard != null && userScorecard.holeScores.any((s) => s != null)) {
        rawDisplayScores = List.generate(18, (i) {
          final live = i < userScorecard.holeScores.length ? userScorecard.holeScores[i] : null;
          final seed = (fallbackScores != null && i < fallbackScores.length) ? fallbackScores[i] : null;
          return live ?? seed;
        });
      } else {
        rawDisplayScores = fallbackScores?.cast<int?>() ?? [];
      }

      limit = playerHoleLimits[effectiveEntryId];
      if (limit != null) {
        for (int i = 0; i < rawDisplayScores.length; i++) {
          displayScores.add(i < limit ? rawDisplayScores[i] : null);
        }
      } else {
        displayScores.addAll(rawDisplayScores);
      }

      final bool shouldShowTargetHcp = !isSelfMarking && _selectedMarkerTab == MarkerTab.player && targetEntryId != null;
      if (shouldShowTargetHcp) {
         final guestSuffix = '_guest';
         if (targetEntryId.endsWith(guestSuffix)) {
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
         } else if (members.isNotEmpty) {
            final targetMember = members.firstWhereOrNull((m) => m.id == targetEntryId);
            if (targetMember != null) {
              baseHcp = targetMember.handicap;
            } else {
              final groupsData = event.grouping['groups'] as List?;
              if (groupsData != null) {
                 for (var g in groupsData) {
                    final players = g['players'] as List?;
                    final found = players?.firstWhereOrNull((p) => p['registrationMemberId'] == targetEntryId);
                    if (found != null) {
                       baseHcp = (found['handicapIndex'] as num?)?.toDouble() ?? 28.0;
                       break;
                    }
                 }
              }
            }
         }
      }

      final bool shouldCheckConflict = isScoringActive && !isLocked;
      if (shouldCheckConflict && effectiveRules.effectiveMode != CompetitionMode.singles && isSelfMarking && !isFourballOrPairs) {
         final groupsData = event.grouping['groups'] as List?;
         if (groupsData != null) {
            for (var g in groupsData) {
               final players = (g['players'] as List).map((p) => TeeGroupParticipant.fromJson(p)).toList();
               final myIndex = players.indexWhere((p) => (p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId) == effectiveEntryId);
               if (myIndex != -1) {
                  final teamSize = effectiveRules.teamSize;
                  int teamStartIndex = (myIndex ~/ teamSize) * teamSize;
                  int teamEndIndex = teamStartIndex + teamSize;
                  if (teamEndIndex > players.length) teamEndIndex = players.length;
                  final teamMembers = players.sublist(teamStartIndex, teamEndIndex);
                  for (var member in teamMembers) {
                     final memberId = member.isGuest ? '${member.registrationMemberId}_guest' : member.registrationMemberId;
                     if (memberId == effectiveEntryId) continue;
                     final pCard = allScorecards.firstWhereOrNull((s) => s.entryId == memberId);
                     if (pCard != null && pCard.holeScores.any((s) => s != null)) {
                        if (userScorecard != null && userScorecard.holeScores.any((s) => s != null)) {
                           for (int i=0; i<18; i++) {
                              final myScore = userScorecard.holeScores.elementAtOrNull(i);
                              final theirScore = pCard.holeScores.elementAtOrNull(i);
                              if (myScore != null && theirScore != null && myScore != theirScore) {
                                 hasScoreConflict = true;
                                 partnerName = member.name;
                                 partnerCard = pCard;
                                 break;
                              }
                           }
                        } else {
                           if (partnerCard == null || (pCard.holeScores.where((s) => s != null).length > partnerCard.holeScores.where((s) => s != null).length)) {
                              partnerCard = pCard;
                              partnerName = member.name;
                           }
                        }
                     }
                     if (hasScoreConflict) break;
                  }
                  break;
               }
            }
         }
      }
      // SINGLE SOURCE OF TRUTH: Resolve PHC and Scores from Central Engine
      final playerScoring = scoringData?.individualScores.firstWhereOrNull((s) => s.playerId == effectiveEntryId);
      
      if (playerScoring != null) {
        playingHcpValue = playerScoring.playingHandicap;
        baseHcp = playerScoring.handicapIndex;
        displayScores = playerScoring.holeScores;
      } else {
        // Fallback for initialization phase
        final member = members.firstWhereOrNull((m) => m.id == effectiveEntryId.replaceFirst('_guest', ''));
        final double handicapIndex = member?.handicap ?? 18.0;
        final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
          memberId: effectiveEntryId, 
          event: event, 
          membersList: members, 
          manualTeeName: markerSelection.teeOverrides[effectiveEntryId],
        );

        playingHcpValue = HandicapCalculator.calculatePlayingHandicap(
          handicapIndex: handicapIndex, 
          rules: effectiveRules, 
          courseConfig: playerTeeConfig,
          societyCut: event.manualCuts[effectiveEntryId] ?? 0.0,
        );
      }
    }
    // Use eventMyCardTabProvider for My Card Hub (0: My Score, 4: Matches, 5: Bracket)
    final activeIndex = ref.watch(eventMyCardTabProvider);
    
    switch (activeIndex) {
      case 0: { // My Score
        return _buildMyScoreView(
          context: context,
          event: event,
          comp: comp,
          config: config,
          isScoringActive: isScoringActive,
          shouldShowCard: shouldShowCard,
          displayScores: displayScores,
          playingHcpValue: playingHcpValue,
          baseHcp: baseHcp,
          limit: limit,
          isStableford: isStableford,
          userScorecard: userScorecard,
          myCard: myCard,
          partnerCard: partnerCard,
          partnerName: partnerName,
          hasScoreConflict: hasScoreConflict,
          targetEntryId: targetEntryId,
          effectiveRules: effectiveRules,
          scoringData: scoringData,
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
      default: {
         // Default to My Score (0) if the shared index doesn't apply to this hub
         return _buildMyScoreRedirect(event, comp, displayScores, isScoringActive, shouldShowCard, playingHcpValue, baseHcp, limit, isStableford, userScorecard, myCard, partnerCard, partnerName, hasScoreConflict, targetEntryId, config, effectiveRules);
      }
    }
  }

  // Safety helper to force-render My Score logic if switch fails
  Widget _buildMyScoreRedirect(GolfEvent event, Competition? comp, List<int?> displayScores, bool isScoringActive, bool shouldShowCard, int playingHcpValue, double baseHcp, int? limit, bool isStableford, Scorecard? userScorecard, Scorecard? myCard, Scorecard? partnerCard, String? partnerName, bool hasScoreConflict, String? targetEntryId, SocietyConfig config, CompetitionRules effectiveRules) {
    return _buildMyScoreView(
      context: context,
      event: event,
      comp: comp,
      config: config,
      isScoringActive: isScoringActive,
      shouldShowCard: shouldShowCard,
      displayScores: displayScores,
      playingHcpValue: playingHcpValue,
      baseHcp: baseHcp,
      limit: limit,
      isStableford: isStableford,
      userScorecard: userScorecard,
      myCard: myCard,
      partnerCard: partnerCard,
      partnerName: partnerName,
      hasScoreConflict: hasScoreConflict,
      targetEntryId: targetEntryId,
      effectiveRules: effectiveRules,
    );
  }


  Widget _buildMyScoreView({
    required BuildContext context,
    required GolfEvent event,
    required Competition? comp,
    required SocietyConfig config,
    required bool isScoringActive,
    required bool shouldShowCard,
    required List<int?> displayScores,
    required int playingHcpValue,
    required double baseHcp,
    required int? limit,
    required bool isStableford,
    required Scorecard? userScorecard,
    required Scorecard? myCard,
    required Scorecard? partnerCard,
    required String? partnerName,
    required bool hasScoreConflict,
    required String? targetEntryId,
    required CompetitionRules effectiveRules,
    ProcessedEventData? scoringData,
  }) {
    final markerSelection = ref.watch(markerSelectionProvider);
    final bool isSelfMarking = markerSelection.isSelfMarking;
    final currentUser = ref.watch(effectiveUserProvider);
    
    // Resolve who we are MARKING (The Target)
    final String targetId = (isSelfMarking || targetEntryId == null) 
        ? currentUser.id
        : targetEntryId;
    
    final allScorecards = ref.watch(scorecardsListProvider(event.id)).asData?.value ?? [];

    // [NEW] Resolve which player's data to display on the GRID (Target or Me)
    final bool isMeView = !isSelfMarking && _selectedMarkerTab == MarkerTab.verifier;
    final String displayId = isMeView ? currentUser.id : targetId;
    
    final members = ref.watch(allMembersProvider).value ?? [];
    final manualTee = markerSelection.teeOverrides[displayId];
    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: displayId, 
      event: event, 
      membersList: members, 
      manualTeeName: manualTee,
    );
    
    // Resolve the display name for the tee
    final memberProfile = members.firstWhereOrNull((m) => m.id == displayId);
    final String playerTeeName = manualTee ?? (
      (memberProfile?.gender?.toLowerCase() == 'female')
        ? (event.selectedFemaleTeeName ?? 'Red')
        : (event.selectedTeeName ?? 'Yellow')
    );

    // SINGLE SOURCE OF TRUTH: Resolve PHC and Scores from Central Engine
    final displayScoring = scoringData?.individualScores.firstWhereOrNull((s) => s.playerId == displayId);
    final double displayBaseHcp = displayScoring?.handicapIndex ?? (isMeView ? currentUser.handicap : baseHcp);
    final displayCard = allScorecards.firstWhereOrNull((s) => s.entryId == displayId);
    
    final int displayPlayingHcp = displayScoring?.playingHandicap ?? (
      HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: displayBaseHcp, 
        rules: effectiveRules, 
        courseConfig: playerTeeConfig,
        societyCut: event.manualCuts[displayId] ?? 0.0,
      )
    );

    // Track if a society cut is applied for the marker/label
    final bool hasSocietyCutActual = (displayScoring?.appliedSocietyCut ?? (event.manualCuts[displayId] ?? 0.0)) != 0;

    // [FIX] Always look up seeded data as a baseline layer, even when a live scorecard exists.
    List<int?>? displaySeededScores;
    var displaySeededResult = event.results.firstWhere(
       (r) => r['playerId'] == displayId,
       orElse: () => {},
    );
    if (displaySeededResult.isEmpty) {
       displaySeededResult = event.results.firstWhere(
         (r) => (r['playerId'] as String?)?.contains(displayId) == true ||
                displayId.contains(r['playerId'] as String? ?? '___'),
         orElse: () => {},
       );
    }
    if (displaySeededResult.isNotEmpty && displaySeededResult['holeScores'] != null) {
       displaySeededScores = List<int?>.from(displaySeededResult['holeScores']);
    }

    // Determine what to show on the Grid (CourseInfoCard)
    // We favor the engine's hole scores, but fall back to local merge for verifier support.
    List<int?> gridScores = displayScoring?.holeScores ?? List.generate(18, (i) {
       final live = (displayCard != null && i < displayCard.holeScores.length) ? displayCard.holeScores[i] : null;
       final seed = (displaySeededScores != null && i < displaySeededScores.length) ? displaySeededScores[i] : null;
       
       if (!isMeView && displayId == targetId) {
          final myVerifier = myCard?.playerVerifierScores ?? [];
          final mine = i < myVerifier.length ? myVerifier[i] : null;
          return live ?? seed ?? mine;
       }
       
       return live ?? seed;
    });

    // Apply Optimistic Updates to Grid
    if (_optimisticScores != null && _optimisticIsVerifier == (_selectedMarkerTab == MarkerTab.verifier)) {
      gridScores = List.generate(18, (i) {
        return _optimisticScores![i + 1] ?? (i < gridScores.length ? gridScores[i] : null);
      });
    }

    // [FEATURE] Compute Match Play Tokens row if event is Match Play
    List<String>? matchTokens;
    final matchDataAsync = ref.watch(currentMatchControllerProvider(event.id));
    final matchData = matchDataAsync.asData?.value;
    
    if (matchData != null) {
      final currentMatch = matchData.match;
      final matchResult = matchData.result;
      
      final cleanId = targetId.replaceFirst('_guest', '');
      final isTeam1 = currentMatch.team1Ids.contains(targetId) || currentMatch.team1Ids.contains(cleanId);
      
      matchTokens = List.generate(18, (i) {
         if (i >= matchResult.holeResults.length) return '';
         final r = matchResult.holeResults[i];
         if (r == 0) return 'H';
         if (r == 1) return isTeam1 ? 'W' : 'L';
         return isTeam1 ? 'L' : 'W';
      });
    }


    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: Theme.of(context).extension<AppSpacingTokens>()?.labelToCard ?? AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Marker Toggle (Left)
              Expanded(
                child: GestureDetector(
                  onTap: () => _showMarkerSelectionSheet(event, isScoringActive),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.lime500, // Action Emerald
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            isSelfMarking 
                                ? 'Marking: Self' 
                                : (targetEntryId != null 
                                    ? 'Marking: ${toTitleCase(_getDisplayName(event, targetEntryId).split(' ').first)}' 
                                    : 'Marking: Select'),
                            style: AppTypography.label.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: AppTypography.weightStrong,
                              letterSpacing: AppTypography.lsLabel,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.keyboard_arrow_down_rounded, 
                          size: 16, 
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // 2. Handicap Info (Right)
              Row(
                children: [
                  BoxyArtPill.hc(label: _formatHcp(displayBaseHcp)),
                  const SizedBox(width: AppSpacing.xs),
                  BoxyArtPill.phc(context: context, label: '$displayPlayingHcp${hasSocietyCutActual ? '*' : ''}'),
                ],
              ),
            ],
          ),
        ),
        
        // Status Badge / Conflict Banner moved above

        if (partnerCard != null && !hasScoreConflict)
           Padding(
             padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
             child: Container(
               padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.teamA.withValues(alpha: AppColors.opacityLow),
                  borderRadius: AppShapes.md,
                  border: Border.all(color: AppColors.teamA.withValues(alpha: AppColors.opacityMuted)),
                ),
               child: Row(
                 children: [
                   const Icon(Icons.info_outline, color: AppColors.teamA),
                   const SizedBox(width: AppSpacing.md),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Partner Scoring Active',
                           style: TextStyle(
                             fontSize: AppTypography.sizeLabel,
                             fontWeight: AppTypography.weightBold,
                             color: AppColors.teamA,
                           ),
                         ),
                         Text(
                           '${partnerName ?? 'Teammate'} is keeping score.',
                           style: TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.teamA),
                         ),
                       ],
                     ),
                   ),
                   TextButton(
                     onPressed: () => _copyScoresFromPartner(partnerCard),
                     style: TextButton.styleFrom(
                       visualDensity: VisualDensity.compact,
                       foregroundColor: AppColors.teamA,
                       textStyle: const TextStyle(fontWeight: AppTypography.weightBold),
                     ),
                     child: const Text('SYNC TO ME'),
                   ),
                 ],
               ),
             ),
           ),

         if (hasScoreConflict)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.amber500.withValues(alpha: AppColors.opacityLow),
                  borderRadius: AppShapes.md,
                  border: Border.all(color: AppColors.amber500.withValues(alpha: AppColors.opacityHalf)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Score Conflict Detected',
                            style: TextStyle(
                              fontSize: AppTypography.sizeLabel,
                              fontWeight: AppTypography.weightBold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          Text(
                            'You and ${partnerName ?? 'Partner'} have different scores.',
                            style: TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.amber500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

        if (shouldShowCard) ...[
          SlidingCourseInfoCard(
            courseConfig: playerTeeConfig,
            selectedTeeName: playerTeeName,
            distanceUnit: config.distanceUnit,
            isStableford: isStableford,
            playerHandicap: displayPlayingHcp,
            scores: gridScores,
            headerColor: isMeView ? AppColors.amber500.withValues(alpha: AppColors.opacityMuted) : null,
            format: comp?.rules.format ?? CompetitionFormat.stableford, 
            maxScoreConfig: comp?.rules.maxScoreConfig,
            holeLimit: limit,
            matchPlayResults: matchTokens, 
            handicapAllowance: effectiveRules.handicapAllowance,
          ),
        ],
        
        if (!shouldShowCard)
           _buildInactiveBanner(event),
      ],
    );
  }


  Widget _buildInactiveBanner(GolfEvent event) {
    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          children: [
            const Icon(Icons.lock_clock_outlined, size: AppShapes.iconHero, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'GAME NOT ACTIVE',
              style: TextStyle(fontSize: AppTypography.sizeLargeBody, fontWeight: AppTypography.weightBold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Scoring will open on ${DateFormat('EEEE, d MMMM').format(event.date)}.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                fontWeight: AppTypography.weightMedium,
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
        return AppColors.dark300;
      case ScorecardStatus.submitted:
        return AppColors.amber500;
      case ScorecardStatus.reviewed:
      case ScorecardStatus.finalScore:
        return AppColors.lime500;
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
    // final statusOverride = ref.read(eventStatusOverrideProvider);
    // final forceActiveOverride = ref.read(scoringForceActiveOverrideProvider);
    // final isTesting = statusOverride != null || forceActiveOverride != null;

    // [Refinement] Allow sheet to open even if game is complete (for Read-Only review)
    // if (!isScoringActive && !isTesting) {
    //   return;
    // }

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
    if (groupMembers.isEmpty) {
       // Do nothing - user sees only "Myself"
    }

    BoxyArtBottomSheet.showPersistent(
      context: context,
      title: 'Marker & Tee Selection',
      child: Consumer(
        builder: (context, ref, _) {
          final markerSelection = ref.watch(markerSelectionProvider);
          final bool isSelfMarking = markerSelection.isSelfMarking;
          final String? targetEntryId = markerSelection.targetEntryId;
          final tees = event.courseConfig.tees;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Text(
                      'Select Player To Mark',
                      style: AppTypography.label.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: AppTypography.weightHeavy,
                        letterSpacing: AppTypography.lsLabel,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Option 1: Myself
              buildSelectionRow(
                context, 
                ref,
                isSelected: isSelfMarking,
                name: 'Myself (Me)',
                entryId: currentUser.id,
                tees: tees,
                overrides: markerSelection.teeOverrides,
                onSelect: () {
                  ref.read(markerSelectionProvider.notifier).selectSelf();
                  // Instead of immediate setState, let the Notifier propagate
                  setState(() { _selectedMarkerTab = MarkerTab.verifier; });
                },
                defaultTeeName: event.selectedTeeName ?? 'White',
              ),
              
              // Option 2: Group Members
              ...groupPlayersRaw.where((p) {
                 final pid = p['id'] ?? p['registrationMemberId'];
                 final id = (p['isGuest'] == true || pid.toString().contains('_guest')) ? (pid.toString().contains('_guest') ? pid : '${pid}_guest') : pid;
                 return id != currentUser.id;
              }).map((p) {
                 final pid = p['id'] ?? p['registrationMemberId'];
                 final id = (p['isGuest'] == true || pid.toString().contains('_guest')) ? (pid.toString().contains('_guest') ? pid : '${pid}_guest') : pid;
                 final name = p['name'] ?? 'Unknown';
                 final isSelected = !isSelfMarking && targetEntryId == id;
                  
                 return buildSelectionRow(
                   context,
                   ref,
                   isSelected: isSelected,
                   name: name,
                   entryId: id ?? '',
                   tees: tees,
                   overrides: markerSelection.teeOverrides,
                   onSelect: () {
                     if (id != null) {
                       ref.read(markerSelectionProvider.notifier).selectTarget(id);
                     }
                   },
                   defaultTeeName: event.selectedTeeName ?? 'White',
                 );
              }),

              const SizedBox(height: AppSpacing.lg),
              
              // Tip logic
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04), // Design 4.x Soft Tint
                    borderRadius: AppShapes.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded, 
                        size: 16, 
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacityMedium),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Tee overrides update the scorecard immediately for that player.',
                          style: AppTypography.micro.copyWith(
                            fontSize: AppTypography.sizeMicro,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          );
        },
      ),
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
             const SnackBar(content: Text('Scorecard Submitted Successfully!'), backgroundColor: AppColors.lime500),
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
            const SnackBar(content: Text('Scores synced successfully!'), backgroundColor: AppColors.lime500),
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

  // Resolution logic removed. Using ScoringCalculator.resolvePlayerCourseConfig instead.

  Widget buildSelectionRow(
    BuildContext context, 
    WidgetRef ref, {
    required bool isSelected,
    required String name,
    required String entryId,
    required List<dynamic> tees,
    required Map<String, String> overrides,
    required VoidCallback onSelect,
    required String defaultTeeName,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Left Col (Player)
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: onSelect,
                  borderRadius: AppShapes.md,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: AppSpacing.xl,
                          height: AppSpacing.xl,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onSurface 
                                  : AppColors.dark400,
                              width: isSelected ? 2 : 1.5,
                            ),
                          ),
                          child: isSelected 
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              fontSize: AppTypography.sizeBodySmall,
                              fontWeight: isSelected ? AppTypography.weightHeavy : AppTypography.weightSemibold,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onSurface 
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: AppSpacing.md),
              
              // Right Col (Tee Dropdown)
              Expanded(
                flex: 1,
                child: buildTeeDropdown(context, ref, entryId, tees, overrides, defaultTeeName),
              ),
            ],
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow)),
        ],
      ),
    );
  }

  Widget buildTeeDropdown(BuildContext context, WidgetRef ref, String entryId, List<dynamic> tees, Map<String, String> overrides, String defaultTeeName) {
     final String? persistedTee = overrides[entryId];
     
     // The current selection could be null (Auto) or a specific tee name.
     // If the persisted tee matches the default tee, map it to null (Auto)
     // because the default tee is intentionally excluded from the manual list.
     String? currentTeeValue = persistedTee;
     if (currentTeeValue != null && currentTeeValue.toLowerCase().trim() == defaultTeeName.toLowerCase().trim()) {
       currentTeeValue = null;
     }
     
     return Container(
       height: 36,
       padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
       decoration: BoxDecoration(
         color: Colors.transparent, // True Minimal Dropdown
         borderRadius: AppShapes.sm,
         border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow)),
       ),
       child: DropdownButtonHideUnderline(
         child: DropdownButton<String?>(
           value: currentTeeValue,
           isExpanded: true,
           borderRadius: BorderRadius.circular(AppShapes.rLg),
           icon: const Icon(Icons.arrow_drop_down, size: AppShapes.iconMd),
           onChanged: (String? newValue) {
             if (newValue == null) {
               ref.read(markerSelectionProvider.notifier).clearManualTee(entryId);
             } else {
               ref.read(markerSelectionProvider.notifier).setManualTee(entryId, newValue);
             }
           },
           items: [
             // "Auto" (Default) Option
             DropdownMenuItem<String?>(
               value: null,
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: _parseTeeColor(defaultTeeName),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                   const SizedBox(width: AppSpacing.sm),
                   Expanded(
                     child: Text(
                       defaultTeeName,
                       overflow: TextOverflow.ellipsis,
                       style: AppTypography.caption.copyWith(
                         fontSize: AppTypography.sizeLabelStrong, 
                         fontWeight: AppTypography.weightHeavy,
                         color: Theme.of(context).colorScheme.onSurface,
                       ),
                     ),
                   ),
                 ],
               ),
             ),
            // List of available tees
            ...tees.where((t) {
              final name = t.name.toString();
              return name.toLowerCase().trim() != defaultTeeName.toLowerCase().trim();
            }).map((t) {
              final name = t.name.toString();
               return DropdownMenuItem<String?>(
                 value: name,
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: _parseTeeColor(name),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                     const SizedBox(width: AppSpacing.sm),
                     Expanded(
                       child: Text(
                         name,
                         overflow: TextOverflow.ellipsis,
                         style: AppTypography.caption.copyWith(
                           fontSize: AppTypography.sizeLabelStrong, 
                           fontWeight: AppTypography.weightHeavy,
                           color: Theme.of(context).colorScheme.onSurface,
                         ),
                       ),
                     ),
                   ],
                 ),
               );
            }),
           ],
         ),
       ),
     );
  }

  Color _parseTeeColor(String teeName) {
    final name = teeName.toLowerCase();
    if (name.contains('white')) return AppColors.pureWhite;
    if (name.contains('yellow')) return const Color(0xFFFFD700);
    if (name.contains('red')) return const Color(0xFFFF4D4D);
    if (name.contains('blue')) return const Color(0xFF1E90FF);
    if (name.contains('black')) return const Color(0xFF2F2F2F);
    if (name.contains('green')) return const Color(0xFF2ECC71);
    if (name.contains('gold')) return const Color(0xFFFFD700);
    if (name.contains('silver')) return const Color(0xFFC0C0C0);
    if (name.contains('orange')) return AppColors.amber500;
    if (name.contains('purple')) return AppColors.teamB;
    return AppColors.dark600;
  }
} // End of _EventScoresUserTabState

class EventStatsUserTab extends ConsumerWidget {
  final String eventId;
  const EventStatsUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) {
          return const Scaffold(body: Center(child: Text('Event not found')));
        }
        final user = ref.watch(effectiveUserProvider);
        final isStaff = user.role != MemberRole.member;

        return HeadlessScaffold(
          title: event.title,
          subtitle: 'Event Stats',
          showAdminShortcut: false, // Explicitly removed as per user preference
          showBack: true,
          onBack: () => context.go('/events'),

          actions: [
            if (isStaff)
              BoxyArtGlassIconButton(
                icon: Icons.edit_rounded,
                tooltip: 'Manage Stats',
                onPressed: () => context.push('/admin/events/manage/${event.id}/broadcast'), // Or dedicated stats edit if it exists
              ),
          ],
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
            SliverToBoxAdapter(
              child: compAsync.when(
                data: (comp) => scorecardsAsync.when(
                  data: (scorecards) => Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.pageBottom),
                    child: EventStatsTab(
                      eventId: event.id,
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
    final selectedTab = ref.watch(eventMyCardTabProvider);

    final tabs = <ModernFilterTab<int>>[
      const ModernFilterTab(label: 'My Score', value: 0),
    ];

    if (event.matches.isNotEmpty) {
      tabs.add(const ModernFilterTab(label: 'Matches', value: 4));
    }
    if (event.matches.any((m) => m.bracketId != null)) {
      tabs.add(const ModernFilterTab(label: 'Bracket', value: 5));
    }

    return ModernUnderlinedFilterBar<int>(
      selectedValue: (selectedTab == 0 || selectedTab == 4 || selectedTab == 5) ? selectedTab : 0,
      isExpanded: true,
      onTabSelected: (val) => ref.read(eventMyCardTabProvider.notifier).set(val),
      tabs: tabs,
    );
  }
}

// [NEW] Scores Hub Toggle
class _ScoresHubToggle extends ConsumerWidget {
  final GolfEvent event;

  const _ScoresHubToggle({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(eventScoresHubTabProvider);

    final tabs = <ModernFilterTab<int>>[
      const ModernFilterTab(label: 'Group', value: 1),
      const ModernFilterTab(label: 'Leaderboard', value: 2),
    ];

    return ModernUnderlinedFilterBar<int>(
      selectedValue: (selectedTab == 1 || selectedTab == 2) ? selectedTab : 1,
      isExpanded: true,
      onTabSelected: (val) => ref.read(eventScoresHubTabProvider.notifier).set(val),
      tabs: tabs,
    );
  }
}
class TournamentScoresUserTab extends ConsumerWidget {
  final String eventId;
  const TournamentScoresUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final currentTab = ref.watch(eventScoresHubTabProvider);

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) return const Scaffold(body: Center(child: Text('Event not found')));

        return compAsync.when(
          data: (comp) {
            final rules = comp?.rules ?? const CompetitionRules();
            final effectiveRules = rules;
            
            // Ensure activeTab is always valid for this screen (1 or 2)
            final int activeTab = (currentTab == 1 || currentTab == 2) ? currentTab : 1;
            
            return HeadlessScaffold(
              title: event.title,
              subtitle: 'Event Scores',
              showBack: true,
              onBack: () => context.go('/events'),

              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                  sliver: SliverToBoxAdapter(
                    child: _ScoresHubToggle(event: event),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  sliver: SliverToBoxAdapter(
                    child: Builder(builder: (context) {
                      switch (activeTab) {
                        case 1: // Group Views
                           final markerSelection = ref.watch(markerSelectionProvider);
                           return _TournamentGroupScoresView(event: event, rules: effectiveRules, markerSelection: markerSelection);
                        default: // Leaderboard (case 2)
                          final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
                          final membersAsync = ref.watch(allMembersProvider);
                          return scorecardsAsync.when(
                            data: (scorecards) => EventLeaderboard(
                                event: event, 
                                comp: comp, 
                                liveScorecards: scorecards, 
                                membersList: membersAsync.value ?? [], 
                                playerHoleLimits: const {},
                                onPlayerTap: (entry) => ScorecardModal.show(
                                  context, ref, 
                                  entry: entry, 
                                  scorecards: scorecards, 
                                  event: event, 
                                  comp: comp, 
                                  membersList: membersAsync.value ?? [], 
                                  holeLimit: null, 
                                  teeOverrides: ref.read(markerSelectionProvider).teeOverrides,
                                ),
                            ),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, s) => Center(child: Text('Error: $e')),
                          );
                      }
                    }),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error loading competition: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading event: $e')),
    );
  }
}

class _TournamentGroupScoresView extends ConsumerStatefulWidget {
  final GolfEvent event;
  final CompetitionRules rules;
  final MarkerSelection markerSelection;

  const _TournamentGroupScoresView({
    required this.event,
    required this.rules,
    required this.markerSelection,
  });

  @override
  ConsumerState<_TournamentGroupScoresView> createState() => __TournamentGroupScoresViewState();
}

class __TournamentGroupScoresViewState extends ConsumerState<_TournamentGroupScoresView> {
  @override
  Widget build(BuildContext context) {
    // This is a wrapper to call the existing _buildGroupScoresTab properly
    // Since _buildGroupScoresTab is in _EventScoresUserTabState, I should probably 
    // refactor it to a standalone helper.
    // However, for this phase I will duplicate it or use a shared mixin/helper if possible.
    // For simplicity in this large file, I'll use the one in the parent state if I can access it,
    // but better to just pull out the logic into a shared method.
    
    // I will refactor _buildGroupScoresTab to be a static-like helper below.
    return SharedTournamentLogic.buildGroupScoresTab(
      ref: ref,
      eventId: widget.event.id,
      event: widget.event,
      rules: widget.rules,
      playerHoleLimits: const {},
      teeOverrides: widget.markerSelection.teeOverrides,
    );
  }
}

class SharedTournamentLogic {
  static Widget buildGroupScoresTab({
    required WidgetRef ref,
    required String eventId,
    required GolfEvent event,
    required CompetitionRules rules,
    required Map<String, int> playerHoleLimits,
    required Map<String, String> teeOverrides,
  }) {
    final membersAsync = ref.watch(allMembersProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));

    return scorecardsAsync.when(
      data: (scorecards) {
        final groupsData = event.grouping['groups'] as List?;
        final List<TeeGroup> groups = groupsData != null 
            ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
            : [];

        return GroupScoresView(
          event: event,
          rules: rules,
          groups: groups,
          scorecards: scorecards,
          members: membersAsync.value ?? [],
          playerHoleLimits: playerHoleLimits,
          teeOverrides: teeOverrides,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class GroupScoresView extends ConsumerStatefulWidget {
  final GolfEvent event;
  final CompetitionRules rules;
  final List<TeeGroup> groups;
  final List<Scorecard> scorecards;
  final List<Member> members;
  final Map<String, int> playerHoleLimits;
  final Map<String, String> teeOverrides;

  const GroupScoresView({
    super.key,
    required this.event,
    required this.rules,
    required this.groups,
    required this.scorecards,
    required this.members,
    required this.playerHoleLimits,
    required this.teeOverrides,
  });

  @override
  ConsumerState<GroupScoresView> createState() => GroupScoresViewState();
}

class GroupScoresViewState extends ConsumerState<GroupScoresView> {
  late List<GlobalKey> _cardKeys;

  @override
  void initState() {
    super.initState();
    _cardKeys = List.generate(widget.groups.length, (index) => GlobalKey(debugLabel: 'GroupCard_$index'));
  }

  @override
  void didUpdateWidget(GroupScoresView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groups.length != oldWidget.groups.length) {
      _cardKeys = List.generate(widget.groups.length, (index) => GlobalKey(debugLabel: 'GroupCard_$index'));
    }
  }

  void _scrollToGroup(int groupIndex) {
    if (groupIndex < 0 || groupIndex >= _cardKeys.length) return;
    final key = _cardKeys[groupIndex];
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1, // Scroll so it's a bit from the top
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.x3l),
          child: Text('Grouping is not yet available.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final data = ref.watch(eventScoringControllerProvider(widget.event.id));

    final Map<String, String> scoreMap = {};
    final Map<String, int> teamPhcMap = {};
    final Map<String, bool> winnerMap = {};
    final Map<String, String> betterBallMap = {};
    final Map<String, String> tieBreakMap = {};
    final Map<String, String> thruMap = {};
    final Map<String, double> hcMap = {};
    final Map<String, ScoringStatus> statusMap = {};
    final memberMapForAll = {for (var m in widget.members) m.id: m};

    // 1. Map individual scores for easy lookup in cards
    // First pass: build score frequency map so we can determine who is tied.
    final scoreFrequency = <int, int>{};
    for (var e in data.leaderboard) {
      if (e.scoringStatus == ScoringStatus.ok && e.holesPlayed > 0) {
        scoreFrequency[e.score] = (scoreFrequency[e.score] ?? 0) + 1;
      }
    }
    final tiedScores = scoreFrequency.entries
        .where((kv) => kv.value > 1)
        .map((kv) => kv.key)
        .toSet();
    final tiedPlayerIds = data.leaderboard
        .where((e) => tiedScores.contains(e.score) && e.scoringStatus == ScoringStatus.ok)
        .map((e) => e.entryId)
        .toSet();

    for (var p in data.individualScores) {
      scoreMap[p.playerId] = p.result.label;
      teamPhcMap[p.playerId] = p.playingHandicap;
      // Only populate tieBreakMap for players whose score is actually tied.
      if (tiedPlayerIds.contains(p.playerId) && (p.tieBreakLabel?.isNotEmpty ?? false)) {
        tieBreakMap[p.playerId] = p.tieBreakLabel!;
      }
      thruMap[p.playerId] = p.thruLabel ?? '';
      hcMap[p.playerId] = p.handicapIndex;

      // Find the status from the leaderboard for official rank-bottoming logic
      final leaderEntry = data.leaderboard.firstWhereOrNull((e) => e.entryId == p.playerId);
      if (leaderEntry != null) {
        statusMap[p.playerId] = leaderEntry.scoringStatus;
      }
    }

    // 2. Map group/team labels (Better Ball etc.)
    if (widget.rules.subtype == CompetitionSubtype.fourball) {
        final teamSize = widget.rules.teamSize;
        for (var group in widget.groups) {
           for (int i = 0; i < group.players.length; i += teamSize) {
              final teamPlayers = group.players.skip(i).take(teamSize).toList();
              final teamIdKey = teamPlayers.map((p) => p.registrationMemberId).join('_');
              final entryId = teamPlayers.map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId).join('_');
              
              final lEntry = data.leaderboard.firstWhereOrNull((e) => e.entryId == entryId);
              if (lEntry != null) {
                betterBallMap[teamIdKey] = lEntry.scoreLabel;
              }
           }
        }
    }

    // 3. Populate Winner Map & Podium (Top 3 Groups)
    final List<PodiumEntry> podiumEntries = [];
    final bool isSingles = widget.rules.effectiveMode == CompetitionMode.singles;

    if (isSingles) {
       // In Singles, mark only the individual leaders (Rank 1) as winners
       for (var entry in data.leaderboard) {
          if (entry.position == 1 && entry.holesPlayed > 0) {
             winnerMap[entry.entryId] = true;
          }
       }
    } else if (data.groupRankings.isNotEmpty) {
       // In Team/Group modes, mark only the members of the winning group as winners
       final topG = data.groupRankings.first;
       final winningGroup = widget.groups.firstWhereOrNull((g) => g.index == topG.groupIndex);
       if (winningGroup != null) {
          for (var p in winningGroup.players) {
             winnerMap[p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId] = true;
          }
       }
    }

    // Populate Podium (Top 3 Groups)
    final topGRankings = data.groupRankings.take(3).toList();
    final Map<int, List<int>> scoreFreqGrp = {};
    for (var g in topGRankings) {
       scoreFreqGrp[g.totalScore] = (scoreFreqGrp[g.totalScore] ?? []);
       scoreFreqGrp[g.totalScore]!.add(g.groupIndex);
    }

    for (int i = 0; i < topGRankings.length; i++) {
        final gRes = topGRankings[i];
        final group = widget.groups.firstWhereOrNull((g) => g.index == gRes.groupIndex);
        
        if (group != null) {
           String? tieLabel;
           final tiedWithSameScore = scoreFreqGrp[gRes.totalScore] ?? [];
           
           if (tiedWithSameScore.length > 1) {
              // Find first differing metric
              final others = topGRankings.where((g) => g.totalScore == gRes.totalScore && g.groupIndex != gRes.groupIndex).toList();
              final metrics = gRes.tieBreakMetrics;
              
              int diffIdx = -1;
              for (int m = 0; m < metrics.length; m++) {
                 final val = metrics[m];
                 final anyDiff = others.any((o) => m >= o.tieBreakMetrics.length || o.tieBreakMetrics[m] != val);
                 if (anyDiff) {
                    diffIdx = m;
                    break;
                 }
              }
              
              if (diffIdx != -1 && diffIdx < metrics.length) {
                 final mNames = ['B9', 'B6', 'B3', 'B1'];
                 final name = diffIdx < mNames.length ? mNames[diffIdx] : 'Metric';
                 tieLabel = '$name: ${metrics[diffIdx]}';
              }
           }

           podiumEntries.add(PodiumEntry(
             name: 'Group ${group.index + 1}',
             score: gRes.label,
             rank: i + 1,
             groupIndex: group.index,
             tieBreakLabel: tieLabel,
           ));
        }
    }

    return Column(
      children: [
        if (podiumEntries.isNotEmpty)
          GroupingPodiumHeader(
            entries: podiumEntries,
            onTap: _scrollToGroup,
          ),
        const BoxyArtSectionTitle(title: 'Group Scores'),
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.groups.length,
          itemBuilder: (context, index) {
            final group = widget.groups[index];

            return Padding(
              key: _cardKeys[index],
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: GroupingCard(
                group: group,
                memberMap: memberMapForAll,
                history: const [], // TODO: Add history if needed
                totalGroups: widget.groups.length,
                rules: widget.rules,
                courseConfig: widget.event.courseConfig,
                isAdmin: false,
                isScoreMode: true,
                scoreMap: scoreMap,
                scorecardMap: {for (var s in widget.scorecards) s.entryId: s},
                winnerMap: winnerMap,
                phcMap: teamPhcMap,
                tieBreakMap: tieBreakMap,
                thruMap: thruMap,
                hcMap: hcMap,
                statusMap: statusMap,
                matchPlayMode: widget.rules.format == CompetitionFormat.matchPlay || widget.rules.subtype == CompetitionSubtype.fourball,
                betterBallMap: betterBallMap,
                groupIndex: index,
              ),
            );
          },
        ),
      ],
    );
  }
}

// Helper functions moved from string_utils for stability
String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

String toSentenceCase(String text) {
  if (text.isEmpty) return text;
  final lower = text.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}
