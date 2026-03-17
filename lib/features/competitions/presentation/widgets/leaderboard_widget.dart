import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/scorecard.dart';

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
      children: entries.map((entry) {

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: BoxyArtMemberRow(
            onTap: () => onPlayerTap?.call(entry),
            name: entry.playerName,
            secondaryName: entry.secondaryPlayerName,
            initials: (entry.teamMemberNames != null && entry.teamMemberNames!.isNotEmpty)
                ? entry.teamMemberNames!.first
                : entry.playerName,
            ranking: entry.position,
            isWinner: entry.position == 1,
            handicapIndex: entry.handicapIndex,
            playingHandicap: entry.playingHandicap,
            hasSocietyCut: entry.hasSocietyCut,
            scoreColor: entry.scoringStatus != ScoringStatus.ok ? AppColors.coral500 : null,
            score: entry.scoringStatus != ScoringStatus.ok 
                ? entry.scoringStatus.name.toUpperCase() 
                : (entry.scoreLabel ?? '${entry.score}'),
            tieBreakLabel: entry.tieBreakLabel ?? entry.tieBreakDetails,
            thruLabel: entry.thruLabel ?? ((entry.holesPlayed != null && entry.holesPlayed! < 18 && entry.holesPlayed! > 0)
                ? 'Thru ${entry.holesPlayed}'
                : null),
            isGuest: entry.isGuest,
          ),
        );
      }).toList(),
    );
  }
}

class LeaderboardEntry {
  final String entryId;
  final String playerName;
  final int score;
  final String? scoreLabel; // [NEW] For Matchplay like "2 & 1"
  final int handicap;
  final double handicapIndex; // [NEW] Precise index for Hc: label
  final int? playingHandicap;
  final int? holesPlayed;
  final String? tieBreakDetails;
  final String? tieBreakLabel;
  final String? thruLabel;
  final ScoringStatus scoringStatus; // [NEW] WD, DQ, NR
  final bool isGuest;
  final String? secondaryPlayerName; // [NEW] For Pairs/Teams
  final List<String>? teamMemberNames; // [NEW] For larger teams (Scramble etc)
  final List<String>? teamMemberIds; // [NEW] For linking to multiple scorecards
  final CompetitionMode mode; // [NEW] To distinguish UI
  final Map<int, String>? countingMemberIds; // [NEW] Hole Index -> Member ID of counting score
  final int? adjustedGrossScore; // [NEW] Capped at Net Double Bogey for WHS
  final List<int>? tieBreakMetrics; // [NEW] Pre-calculated values for sorting ties (Back 9, 6, 3, 1)
  final List<int?>? holeScores; // [NEW] Raw scores for direct modal display
  final List<int?>? holeNetScores; // [NEW] Pre-calculated net scores
  final List<int?>? holePoints; // [NEW] Pre-calculated points
  final int? teamIndex; // [NEW] For resolving team scorecards
  final List<double>? individualHandicaps; // [UPDATED] Support decimals for Index
  final List<int>? individualPlayingHandicaps;
  final List<List<int?>>? individualHoleScores; // [NEW]
  final List<List<int?>>? individualHoleNetScores; // [NEW]
  final List<List<int?>>? individualHolePoints; // [NEW]
  final bool hasSocietyCut; // [NEW] Track for display notation (*)
  final int position;

  LeaderboardEntry({
    required this.entryId,
    required this.playerName, 
    required this.score, 
    this.scoreLabel,
    required this.handicap,
    this.handicapIndex = 0.0,
    this.playingHandicap,
    this.holesPlayed,
    this.tieBreakDetails,
    this.tieBreakLabel,
    this.thruLabel,
    this.isGuest = false,
    this.secondaryPlayerName,
    this.teamMemberNames,
    this.teamMemberIds,
    this.mode = CompetitionMode.singles,
    this.countingMemberIds,
    this.adjustedGrossScore,
    this.tieBreakMetrics,
    this.holeScores,
    this.holeNetScores,
    this.holePoints,
    this.teamIndex,
    this.individualHandicaps,
    this.individualPlayingHandicaps,
    this.individualHoleScores,
    this.individualHoleNetScores,
    this.individualHolePoints,
    this.hasSocietyCut = false,
    this.position = 0,
    this.scoringStatus = ScoringStatus.ok,
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
    String? tieBreakLabel,
    String? thruLabel,
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
    bool? hasSocietyCut,
    int? position,
    double? handicapIndex,
    ScoringStatus? scoringStatus,
    List<int?>? holeNetScores,
    List<int?>? holePoints,
    List<List<int?>>? individualHoleScores,
    List<List<int?>>? individualHoleNetScores,
    List<List<int?>>? individualHolePoints,
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
      tieBreakLabel: tieBreakLabel ?? this.tieBreakLabel,
      thruLabel: thruLabel ?? this.thruLabel,
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
      handicapIndex: handicapIndex ?? this.handicapIndex,
      individualPlayingHandicaps: individualPlayingHandicaps ?? this.individualPlayingHandicaps,
      hasSocietyCut: hasSocietyCut ?? this.hasSocietyCut,
      position: position ?? this.position,
      scoringStatus: scoringStatus ?? this.scoringStatus,
      holeNetScores: holeNetScores ?? this.holeNetScores,
      holePoints: holePoints ?? this.holePoints,
      individualHoleScores: individualHoleScores ?? this.individualHoleScores,
      individualHoleNetScores: individualHoleNetScores ?? this.individualHoleNetScores,
      individualHolePoints: individualHolePoints ?? this.individualHolePoints,
    );
  }
}
