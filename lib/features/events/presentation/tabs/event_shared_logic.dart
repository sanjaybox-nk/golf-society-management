import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../logic/event_scoring_controller.dart';
import '../../domain/models/processed_event_data.dart';
import '../state/marker_selection_provider.dart';
import '../widgets/grouping_widgets.dart';
import '../widgets/scorecard_modal.dart';
import '../../../matchplay/domain/golf_event_match_extensions.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';

class SharedTournamentLogic {
  static Widget buildGroupScoresTab({
    Key? key,
    required WidgetRef ref,
    required String eventId,
    required GolfEvent event,
    required CompetitionRules rules,
    required Map<String, int> playerHoleLimits,
    required Map<String, String> teeOverrides,
    bool isAdmin = false,
    Function(TeeGroupParticipant p, TeeGroup g)? onTapParticipant,
    Function(String entryId, String markerEntryId, String playerName, String markerName)? onUnlockCard,
    bool followsCard = true,
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
          key: key,
          event: event,
          rules: rules,
          groups: groups,
          scorecards: scorecards,
          members: membersAsync.value ?? [],
          playerHoleLimits: playerHoleLimits,
          teeOverrides: teeOverrides,
          isAdmin: isAdmin,
          onTapParticipant: onTapParticipant,
          onUnlockCard: onUnlockCard,
          followsCard: followsCard,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  static void handleParticipantTap({
    required BuildContext context,
    required WidgetRef ref,
    required GolfEvent event,
    required TeeGroupParticipant participant,
  }) {
    final scoringData = ref.read(eventScoringControllerProvider(event.id));
    final entryId = participant.isGuest ? '${participant.registrationMemberId}_guest' : participant.registrationMemberId;
    final processedEntry = scoringData.leaderboard.firstWhereOrNull((e) => e.entryId == entryId);

    if (processedEntry != null) {
      final scorecards = ref.read(scorecardsListProvider(event.id)).value ?? [];
      final members = ref.read(allMembersProvider).value ?? [];
      final comp = ref.read(competitionDetailProvider(event.id)).value;
      
      final memberMap = {for (final m in members) m.id: m};
      final isMatchPlay = (comp?.rules.isMatchPlay ?? false) || event.matches.isNotEmpty;
      
      final String? playerId = processedEntry.teamMemberIds.firstOrNull;
      final member = playerId != null ? memberMap[playerId] : null;

      String? hostName;
      bool hasGuest = false;

      if (processedEntry.isGuest) {
        final reg = event.registrations.where((r) => r.guestName == processedEntry.playerName).firstOrNull;
        hostName = reg?.memberName;
      } else if (playerId != null) {
        hasGuest = event.registrations.any((r) => r.memberId == playerId && r.guestName != null);
      }

      final entry = LeaderboardEntry(
        entryId: processedEntry.entryId,
        playerName: processedEntry.playerName,
        score: isMatchPlay ? (processedEntry.matchScore ?? 0) : processedEntry.score,
        scoreLabel: isMatchPlay ? processedEntry.matchStatus : processedEntry.scoreLabel,
        handicap: (processedEntry.handicapIndex ?? 0.0).round(),
        handicapIndex: processedEntry.handicapIndex ?? 0.0,
        playingHandicap: processedEntry.individualPlayingHandicaps.firstOrNull,
        holesPlayed: processedEntry.holesPlayed,
        isGuest: processedEntry.isGuest,
        hasGuest: hasGuest,
        initials: (comp?.rules.isUnifiedTeamFormat ?? false) ? (processedEntry.teamMemberNames.firstOrNull ?? processedEntry.playerName) : processedEntry.playerName,
        avatarUrl: member?.avatarUrl,
        hostName: hostName,
        hasSocietyCut: processedEntry.hasSocietyCut,
        holeScores: processedEntry.holeScores,
        holeNetScores: processedEntry.holeNetScores,
        holePoints: processedEntry.holePoints,
        individualHoleScores: processedEntry.individualHoleScores,
        individualHoleNetScores: processedEntry.individualHoleNetScores,
        individualHolePoints: processedEntry.individualHolePoints,
        teamMemberIds: processedEntry.teamMemberIds,
        teamMemberNames: processedEntry.teamMemberNames,
        position: processedEntry.position,
        tieBreakDetails: processedEntry.tieBreakLabel,
        tieBreakMetrics: processedEntry.tieBreakMetrics,
        scoringStatus: processedEntry.scoringStatus,
        mode: comp?.rules.mode ?? CompetitionMode.singles,
        isCaptain: comp?.rules.isUnifiedTeamFormat ?? false,
        teeName: processedEntry.teeName,
        teeColor: AppColors.getTeeColor(processedEntry.teeName, event.courseConfig.tees),
      );
      
      ScorecardModal.show(
        context, 
        ref,
        entry: entry,
        scorecards: scorecards,
        event: event,
        comp: comp,
        membersList: members,
        teeOverrides: ref.read(markerSelectionProvider).teeOverrides,
      );
    }
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
  final bool isAdmin;
  final Function(TeeGroupParticipant p, TeeGroup g)? onTapParticipant;
  final Function(String entryId, String markerEntryId, String playerName, String markerName)? onUnlockCard;
  final bool followsCard;
 
  const GroupScoresView({
    super.key,
    required this.event,
    required this.rules,
    required this.groups,
    required this.scorecards,
    required this.members,
    required this.playerHoleLimits,
    required this.teeOverrides,
    this.isAdmin = false,
    this.onTapParticipant,
    this.onUnlockCard,
    this.followsCard = true,
  });

  @override
  ConsumerState<GroupScoresView> createState() => _GroupScoresViewState();
}

class _GroupScoresViewState extends ConsumerState<GroupScoresView> {
  final Map<int, GlobalKey> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.groups.length; i++) {
      _cardKeys[i] = GlobalKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoringData = ref.watch(eventScoringControllerProvider(widget.event.id));
    final data = scoringData;
    
    final Map<String, String> scoreMap = { for (var s in data.individualScores) s.playerId : s.result.label };
    final Map<String, int> teamPhcMap = { for (var s in data.individualScores) s.playerId : s.playingHandicap.round() };
    final Map<String, String> thruMap = { for (var s in data.individualScores) if (s.thruLabel != null) s.playerId : s.thruLabel! };

    // For stableford: build full B9→B6 chain for tied players
    final isStableford = widget.rules.format == CompetitionFormat.stableford;
    final Map<String, String> tieBreakMap;
    if (isStableford) {
      const mNames = ['B9', 'B6', 'B3', 'B1'];
      // Group leaderboard entries by total score to find ties
      final scoreGroups = <int, List<ProcessedLeaderboardEntry>>{};
      for (final e in data.leaderboard) {
        scoreGroups.putIfAbsent(e.score, () => []).add(e);
      }
      final built = <String, String>{};
      for (final e in data.leaderboard) {
        final tied = (scoreGroups[e.score] ?? [])
            .where((other) => other.entryId != e.entryId)
            .toList();
        if (tied.isEmpty) continue;
        final myMetrics = e.tieBreakMetrics;
        int maxDepth = 0;
        for (final other in tied) {
          int k = 0;
          while (k < myMetrics.length && k < other.tieBreakMetrics.length &&
              myMetrics[k] == other.tieBreakMetrics[k]) k++;
          if (k > maxDepth) maxDepth = k;
        }
        final parts = <String>[];
        for (int i = 0; i <= maxDepth && i < myMetrics.length && i < mNames.length; i++) {
          parts.add('${mNames[i]}: ${myMetrics[i]}');
        }
        if (parts.isNotEmpty) built[e.entryId] = parts.join(' • ');
      }
      tieBreakMap = built;
    } else {
      tieBreakMap = { for (var s in data.individualScores) if (s.tieBreakLabel != null) s.playerId : s.tieBreakLabel! };
    }
    final Map<String, ScoringStatus> statusMap = { for (var s in data.individualScores) s.playerId : s.scoringStatus };
    final Map<String, double> hcMap = { for (var s in data.individualScores) s.playerId : s.handicapIndex };
    final Map<String, bool> winnerMap = { for (var e in data.leaderboard) e.entryId : e.position == 1 };
    
    // Better ball map for Fourball
    final Map<String, List<int?>> betterBallMap = {};
    if (widget.rules.subtype == CompetitionSubtype.fourball) {
       for (var entry in data.leaderboard) {
          betterBallMap[entry.entryId] = entry.holeScores ?? [];
       }
    }

    final memberMapForAll = {for (var m in widget.members) m.id: m};

    // Calculate Podium Headers for groups
    final List<PodiumEntry> podiumEntries = [];
    if (data.groupRankings.isNotEmpty) {
        for (int i=0; i<3 && i<data.groupRankings.length; i++) {
           final gRes = data.groupRankings[i];
           final group = widget.groups.firstWhereOrNull((g) => g.index == gRes.groupIndex);
           if (group == null) continue;

           String? tieLabel;
           final bool isTied = (i > 0 && data.groupRankings[i].totalScore == data.groupRankings[i-1].totalScore) || 
                               (i < data.groupRankings.length - 1 && data.groupRankings[i].totalScore == data.groupRankings[i+1].totalScore);
           if (isTied) {
              final metrics = gRes.tieBreakMetrics;
              final diffIdx = metrics.indexWhere((m) => m != 0);
              if (diffIdx != -1) {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.groups.length,
          itemBuilder: (context, index) {
            final group = widget.groups[index];

            return GroupingCard(
              key: _cardKeys[index],
              group: group,
              memberMap: memberMapForAll,
              history: const [], 
              totalGroups: widget.groups.length,
              rules: widget.rules,
              courseConfig: widget.event.courseConfig,
                isAdmin: widget.isAdmin,
                isScoreMode: true,
                scoreMap: scoreMap,
                scorecardMap: {for (var s in widget.scorecards) s.entryId: s},
                winnerMap: winnerMap,
                phcMap: teamPhcMap,
                tieBreakMap: tieBreakMap,
                thruMap: thruMap,
                hcMap: hcMap,
                statusMap: statusMap,
                matchPlayMode: widget.rules.isMatchPlay || widget.rules.subtype == CompetitionSubtype.fourball,
                matches: widget.event.matches,
                betterBallMap: betterBallMap,
                groupIndex: index,
                showScoring: true,
                computedEntries: { for (var e in data.leaderboard) e.entryId : e },
                computedGroupResults: { for (var g in data.groupRankings) g.groupIndex : g },
                isEventClosed: widget.event.isClosed,
                onTapParticipant: widget.onTapParticipant,
                onUnlockCard: widget.onUnlockCard,
              );
            },
        ),
      ],
    );
  }
}
