import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member_group_config.dart';
import 'package:golf_society/domain/groups/member_group_helper.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/matchplay/domain/golf_event_match_extensions.dart';
import '../../logic/event_scoring_controller.dart';
import '../../../admin/data/member_group_config_repository.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../events/presentation/events_provider.dart';
import 'package:collection/collection.dart';

final _eventMemberGroupConfigProvider = FutureProvider.autoDispose
    .family<MemberGroupConfig?, String>((ref, id) =>
        ref.read(memberGroupConfigRepositoryProvider).getConfig(id));

class EventLeaderboard extends ConsumerStatefulWidget {
  final GolfEvent event;
  final Competition? comp;
  final List<Scorecard> liveScorecards;
  final List<Member> membersList;
  final Map<String, int> playerHoleLimits;
  final Function(LeaderboardEntry)? onPlayerTap;
  final bool showTitles;
  final Map<String, String>? teeOverrides;
  final bool followsCard;
 
  const EventLeaderboard({
    super.key,
    required this.event,
    this.comp,
    required this.liveScorecards,
    required this.membersList,
    this.playerHoleLimits = const {},
    this.onPlayerTap,
    this.showTitles = true,
    this.teeOverrides,
    this.followsCard = true,
  });

  @override
  ConsumerState<EventLeaderboard> createState() => _EventLeaderboardState();
}

class _EventLeaderboardState extends ConsumerState<EventLeaderboard> {
  String? _selectedGroupId;

  @override
  Widget build(BuildContext context) {
    final activeSeason = ref.watch(activeSeasonProvider).value;
    final memberGroupConfig = activeSeason?.memberGroupConfigId != null
        ? ref.watch(
            _eventMemberGroupConfigProvider(activeSeason!.memberGroupConfigId!),
          ).value
        : null;

    // 1. Subscribe to the Central Scoring Brain
    final data = ref.watch(eventScoringControllerProvider(widget.event.id));

    final currentFormat = widget.comp?.rules.format ?? CompetitionFormat.stableford;


    final memberMap = {for (final m in widget.membersList) m.id: m};

    final isMatchPlay = (widget.comp?.rules.isMatchPlay ?? false) || widget.event.matches.isNotEmpty;
    final bool isCompleted = widget.event.status == EventStatus.completed;

    // 2. Map Processed Data to UI-friendly LeaderboardEntry
    final List<LeaderboardEntry> finalEntries = data.leaderboard.map<LeaderboardEntry>((e) {
      final String? playerId = e.teamMemberIds.firstOrNull;
      final member = playerId != null ? memberMap[playerId] : null;

      String? hostName;
      bool hasGuest = false;

      if (e.isGuest) {
        final reg = widget.event.registrations.where((r) => r.guestName == e.playerName).firstOrNull;
        hostName = reg?.memberName;
      } else if (playerId != null) {
        hasGuest = widget.event.registrations.any((r) => r.memberId == playerId && r.guestName != null);
      }

      String? matchStatus = e.matchStatus;
      int matchLead = e.matchScore ?? 0;

      final isUnified = widget.comp?.rules.isUnifiedTeamFormat ?? false;
      final String displayName = e.playerName;

      return LeaderboardEntry(
        entryId: e.entryId,
        playerName: displayName,
        score: isMatchPlay ? matchLead : e.score,
        scoreLabel: isMatchPlay ? matchStatus : e.scoreLabel,
        handicap: (e.handicapIndex ?? 0.0).round(),
        handicapIndex: e.handicapIndex ?? 0.0,
        playingHandicap: e.individualPlayingHandicaps.firstOrNull,
        holesPlayed: e.holesPlayed,
        isGuest: e.isGuest,
        hasGuest: hasGuest,
        initials: isUnified ? (e.teamMemberNames.firstOrNull ?? displayName) : displayName,
        avatarUrl: member?.avatarUrl,
        hostName: hostName,
        hasSocietyCut: e.hasSocietyCut,
        holeScores: e.holeScores,
        holeNetScores: e.holeNetScores,
        holePoints: e.holePoints,
        individualHoleScores: e.individualHoleScores,
        individualHoleNetScores: e.individualHoleNetScores,
        individualHolePoints: e.individualHolePoints,
        teamMemberIds: e.teamMemberIds,
        teamMemberNames: e.teamMemberNames,
        position: e.position,
        thruLabel: isCompleted ? null : e.thruLabel,
        tieBreakLabel: (isCompleted || currentFormat == CompetitionFormat.stableford) ? e.tieBreakLabel : null,
        tieBreakDetails: (isCompleted || currentFormat == CompetitionFormat.stableford) ? e.tieBreakLabel : null,
        tieBreakMetrics: e.tieBreakMetrics,
        scoringStatus: e.scoringStatus,
        mode: widget.comp?.rules.mode ?? CompetitionMode.singles,
        isCaptain: isUnified,
        teeName: e.teeName,
        teeColor: AppColors.getTeeColor(e.teeName, widget.event.courseConfig.tees),
        absoluteScore: e.absoluteScore,
        absoluteScoreLabel: e.absoluteScoreLabel,
      );
    }).toList();

    // 2.5 Sort by Margin if Matchplay
    if (isMatchPlay) {
      finalEntries.sort((a, b) => b.score.compareTo(a.score));
    }

    final bool hasAnyScores = finalEntries.any((e) => e.holesPlayed != null && e.holesPlayed! > 0);

    if (finalEntries.isEmpty || (!hasAnyScores && !isCompleted)) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.x3l),
          child: Text(
            'Standings will appear once scoring starts.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // 3. Handle Guest/Member Separation
    final bool isUnified = widget.comp?.rules.isUnifiedTeamFormat ?? false;
    final societySeparate = ref.watch(themeControllerProvider).separateGuestLeaderboard;
    final bool shouldSeparate = (widget.event.separateGuests ?? societySeparate) && !isUnified;
    
    if (!shouldSeparate) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            if (widget.showTitles)
               BoxyArtSectionTitle(
                 title: 'Live Standings',
                 followsCard: widget.followsCard,
                 horizontalPadding: 0,
               ),
            LeaderboardWidget(
               entries: finalEntries,
               format: currentFormat,
               isMatchPlay: isMatchPlay,
               onPlayerTap: widget.onPlayerTap,
            ),
         ],
       );
    }

    final allMemberEntries = _recalculatePositions(finalEntries.where((e) => !e.isGuest && memberMap.containsKey(e.teamMemberIds?.firstOrNull ?? e.entryId)).toList(), currentFormat);
    // Apply group filter when active.
    final memberEntries = (_selectedGroupId == null || memberGroupConfig == null)
        ? allMemberEntries
        : _recalculatePositions(
            allMemberEntries.where((e) {
              final memberId = e.teamMemberIds?.firstOrNull ?? e.entryId;
              final member = memberMap[memberId];
              if (member == null) return false;
              return MemberGroupHelper.memberBelongsToGroup(
                memberId, _selectedGroupId!, memberGroupConfig, widget.membersList,
              );
            }).toList(),
            currentFormat,
          );
    final guestEntries = _recalculatePositions(finalEntries.where((e) => !allMemberEntries.any((me) => me.entryId == e.entryId)).toList(), currentFormat);
    final bool hasGuests = guestEntries.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (memberGroupConfig != null) ...[
          BoxyArtTabBar<String?>(
            selectedValue: _selectedGroupId,
            onTabSelected: (v) => setState(() => _selectedGroupId = v),
            tabs: [
              const ModernFilterTab(value: null, label: 'All'),
              for (final g in memberGroupConfig.groups)
                ModernFilterTab(value: g.id, label: g.name),
            ],
          ),
          const SizedBox(height: AppSpacing.standard),
        ],
        if (memberEntries.isNotEmpty) ...[
          if (widget.showTitles) ...[
            BoxyArtSectionTitle(
              title: hasGuests ? 'Members' : 'Live Standings',
              count: hasGuests ? memberEntries.length : null,
              followsCard: widget.followsCard,
              horizontalPadding: 0,
            ),
          ],
          LeaderboardWidget(
            entries: memberEntries,
            format: currentFormat,
            isMatchPlay: isMatchPlay,
            onPlayerTap: widget.onPlayerTap,
          ),
        ],
        if (guestEntries.isNotEmpty) ...[
          if (widget.showTitles) ...[
            BoxyArtSectionTitle(
              title: 'Guests',
              count: guestEntries.length,
              isPeeking: false,
              followsCard: true,
              horizontalPadding: 0,
            ),
          ],
          LeaderboardWidget(
            entries: guestEntries,
            format: currentFormat,
            isMatchPlay: isMatchPlay,
            onPlayerTap: widget.onPlayerTap,
          ),
        ],
      ],
    );
  }

  /// Recalculates relative positions (1, 2, 3...) for a sub-list.
  /// Stroke/medal: tied on score = shared position — no countback splitting.
  /// Stableford: countback metrics must also match to share a position.
  List<LeaderboardEntry> _recalculatePositions(
      List<LeaderboardEntry> entries, CompetitionFormat format) {
    if (entries.isEmpty) return [];

    final bool isStroke = format == CompetitionFormat.stroke;
    final List<LeaderboardEntry> reRanked = [];
    int currentPos = 1;

    for (int i = 0; i < entries.length; i++) {
      if (i > 0) {
        final prev = entries[i - 1];
        final curr = entries[i];

        final bool isTied = isStroke
            ? curr.score == prev.score
            : curr.score == prev.score &&
                _areMetricsEqual(curr.tieBreakMetrics, prev.tieBreakMetrics);

        if (!isTied) {
          currentPos = i + 1;
        }
      }

      reRanked.add(entries[i].copyWith(position: currentPos));
    }

    return reRanked;
  }

  bool _areMetricsEqual(List<int>? m1, List<int>? m2) {
    if (m1 == null && m2 == null) return true;
    if (m1 == null || m2 == null) return false;
    if (m1.length != m2.length) return false;
    for (int i = 0; i < m1.length; i++) {
      if (m1[i] != m2[i]) return false;
    }
    return true;
  }
}
