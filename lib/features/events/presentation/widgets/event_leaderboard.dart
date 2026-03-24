import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../logic/event_scoring_controller.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';

class EventLeaderboard extends ConsumerStatefulWidget {
  final GolfEvent event;
  final Competition? comp;
  final List<Scorecard> liveScorecards;
  final List<Member> membersList;
  final Map<String, int> playerHoleLimits;
  final Function(LeaderboardEntry)? onPlayerTap;
  final bool showTitles;
  final Map<String, String>? teeOverrides;

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
  });

  @override
  ConsumerState<EventLeaderboard> createState() => _EventLeaderboardState();
}

class _EventLeaderboardState extends ConsumerState<EventLeaderboard> {
  @override
  Widget build(BuildContext context) {
    // 1. Subscribe to the Central Scoring Brain
    final data = ref.watch(eventScoringControllerProvider(widget.event.id));

    final currentFormat = widget.comp?.rules.format ?? CompetitionFormat.stableford;
    final isGuestLeaderboardActive = widget.event.isInvitational;

    final memberMap = {for (final m in widget.membersList) m.id: m};

    // 2. Map Processed Data to UI-friendly LeaderboardEntry
    final List<LeaderboardEntry> finalEntries = data.leaderboard.map((e) {
      final String? playerId = e.teamMemberIds.firstOrNull;
      final member = playerId != null ? memberMap[playerId] : null;

      String? hostName;
      bool hasGuest = false;

      if (e.isGuest) {
        // Find the registration that includes this guest
        final reg = widget.event.registrations.where((r) => r.guestName == e.playerName).firstOrNull;
        hostName = reg?.memberName;
      } else if (playerId != null) {
        // Check if this member has brought a guest
        hasGuest = widget.event.registrations.any((r) => r.memberId == playerId && r.guestName != null);
      }

      return LeaderboardEntry(
        entryId: e.entryId,
        playerName: e.playerName,
        score: e.score,
        scoreLabel: e.scoreLabel,
        handicap: (e.handicapIndex ?? 0.0).round(), // Legacy integer handicap mapping
        handicapIndex: e.handicapIndex ?? 0.0,
        playingHandicap: e.individualPlayingHandicaps.firstOrNull,
        holesPlayed: e.holesPlayed,
        isGuest: e.isGuest,
        hasGuest: hasGuest,
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
        tieBreakDetails: e.tieBreakLabel,
        tieBreakMetrics: e.tieBreakMetrics,
        scoringStatus: e.scoringStatus,
      );
    }).toList();

    if (finalEntries.isEmpty) {
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
    final guestEntries = finalEntries.where((e) => e.isGuest).toList();
    final memberEntries = finalEntries.where((e) => !e.isGuest).toList();
    final bool hasGuests = guestEntries.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (memberEntries.isNotEmpty) ...[
          if (widget.showTitles) ...[
            BoxyArtSectionTitle(
              title: hasGuests ? 'Society Members' : 'Live Standings',
              count: hasGuests ? memberEntries.length : null,
            ),
          ],
          LeaderboardWidget(
            entries: memberEntries,
            format: currentFormat,
            onPlayerTap: widget.onPlayerTap,
          ),
        ],
        if (guestEntries.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.x3l),
          if (widget.showTitles) ...[
            BoxyArtSectionTitle(
              title: 'Guests',
              count: guestEntries.length,
            ),
          ],
          LeaderboardWidget(
            entries: guestEntries,
            format: currentFormat,
            onPlayerTap: widget.onPlayerTap,
          ),
        ],
      ],
    );
  }
}
