import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final CompetitionFormat format;
  final Function(LeaderboardEntry)? onPlayerTap;

  const LeaderboardWidget({
    super.key, 
    required this.entries, 
    required this.format,
    this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      children: entries.asMap().entries.map((item) {
        final index = item.key;
        final entry = item.value;
        final isTop3 = index < 3;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: BoxyArtScorecardTile(
            onTap: () => onPlayerTap?.call(entry),
            playerName: entry.playerName,
            secondaryPlayerName: entry.secondaryPlayerName,
            avatarNames: entry.teamMemberNames,
            leading: BoxyArtNumberBadge(
              number: index + 1,
              size: 40,
              isRanking: true,
              isFilled: isTop3,
            ),
            score: entry.scoreLabel ?? '${entry.score}',
            status: _buildMetadataRow(context, entry),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetadataRow(BuildContext context, LeaderboardEntry entry) {
    final isTeam = entry.mode == CompetitionMode.teams || entry.mode == CompetitionMode.pairs;
    final showThru = entry.holesPlayed != null && entry.holesPlayed! < 18 && entry.holesPlayed! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isTeam) ...[
              BoxyArtPill.type(label: entry.mode == CompetitionMode.pairs ? 'PAIR' : 'TEAM'),
              const SizedBox(width: 8),
            ],
            if (entry.isGuest) ...[
              BoxyArtPill.status(label: 'GUEST', color: AppColors.amber500),
              const SizedBox(width: 8),
            ],
            if (showThru)
              _buildProMaxLabel('THRU ${entry.holesPlayed}', AppColors.lime500),
          ],
        ),
        if (entry.playingHandicap != null)
           Padding(
             padding: const EdgeInsets.only(top: 6),
             child: Row(
               children: [
                 _buildProMaxLabel('HC: ${entry.handicap}', AppColors.dark150),
                 const SizedBox(width: 8),
                 _buildProMaxLabel('PHC: ${entry.playingHandicap}', AppColors.lime500),
               ],
             ),
           ),
        if (entry.tieBreakDetails != null)
          _buildProMaxLabel(entry.tieBreakDetails!.toUpperCase(), AppColors.dark60),
      ],
    );
  }

  Widget _buildProMaxLabel(String text, Color color) {
    return Text(
      text,
      style: AppTypography.label.copyWith(
        fontSize: 10,
        color: color,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
    );
  }
}

class LeaderboardEntry {
  final String entryId;
  final String playerName;
  final int score;
  final String? scoreLabel; // [NEW] For Matchplay like "2 & 1"
  final int handicap;
  final int? playingHandicap;
  final int? holesPlayed;
  final String? tieBreakDetails;
  final bool isGuest;
  final String? secondaryPlayerName; // [NEW] For Pairs/Teams
  final List<String>? teamMemberNames; // [NEW] For larger teams (Scramble etc)
  final List<String>? teamMemberIds; // [NEW] For linking to multiple scorecards
  final CompetitionMode mode; // [NEW] To distinguish UI
  final Map<int, String>? countingMemberIds; // [NEW] Hole Index -> Member ID of counting score
  final int? adjustedGrossScore; // [NEW] Capped at Net Double Bogey for WHS
  final List<int>? tieBreakMetrics; // [NEW] Pre-calculated values for sorting ties (Back 9, 6, 3, 1)
  final List<int?>? holeScores; // [NEW] Raw scores for direct modal display
  final int? teamIndex; // [NEW] For resolving team scorecards
  final List<double>? individualHandicaps; // [UPDATED] Support decimals for Index
  final List<int>? individualPlayingHandicaps;

  LeaderboardEntry({
    required this.entryId,
    required this.playerName, 
    required this.score, 
    this.scoreLabel,
    required this.handicap,
    this.playingHandicap,
    this.holesPlayed,
    this.tieBreakDetails,
    this.isGuest = false,
    this.secondaryPlayerName,
    this.teamMemberNames,
    this.teamMemberIds,
    this.mode = CompetitionMode.singles,
    this.countingMemberIds,
    this.adjustedGrossScore,
    this.tieBreakMetrics,
    this.holeScores,
    this.teamIndex,
    this.individualHandicaps,
    this.individualPlayingHandicaps,
  });

  LeaderboardEntry copyWith({
    String? entryId,
    String? playerName,
    int? score,
    String? scoreLabel,
    int? handicap,
    int? playingHandicap,
    int? holesPlayed,
    String? tieBreakDetails,
    bool? isGuest,
    String? secondaryPlayerName,
    List<String>? teamMemberNames,
    List<String>? teamMemberIds,
    CompetitionMode? mode,
    Map<int, String>? countingMemberIds,
    int? adjustedGrossScore,
    List<int>? tieBreakMetrics,
    List<int?>? holeScores,
    int? teamIndex,
    List<double>? individualHandicaps,
    List<int>? individualPlayingHandicaps,
  }) {
    return LeaderboardEntry(
      entryId: entryId ?? this.entryId,
      playerName: playerName ?? this.playerName,
      score: score ?? this.score,
      scoreLabel: scoreLabel ?? this.scoreLabel,
      handicap: handicap ?? this.handicap,
      playingHandicap: playingHandicap ?? this.playingHandicap,
      holesPlayed: holesPlayed ?? this.holesPlayed,
      tieBreakDetails: tieBreakDetails ?? this.tieBreakDetails,
      isGuest: isGuest ?? this.isGuest,
      secondaryPlayerName: secondaryPlayerName ?? this.secondaryPlayerName,
      teamMemberNames: teamMemberNames ?? this.teamMemberNames,
      teamMemberIds: teamMemberIds ?? this.teamMemberIds,
      mode: mode ?? this.mode,
      countingMemberIds: countingMemberIds ?? this.countingMemberIds,
      adjustedGrossScore: adjustedGrossScore ?? this.adjustedGrossScore,
      tieBreakMetrics: tieBreakMetrics ?? this.tieBreakMetrics,
      holeScores: holeScores ?? this.holeScores,
      teamIndex: teamIndex ?? this.teamIndex,
      individualHandicaps: individualHandicaps ?? this.individualHandicaps,
      individualPlayingHandicaps: individualPlayingHandicaps ?? this.individualPlayingHandicaps,
    );
  }
}
