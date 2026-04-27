import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final CompetitionFormat format;
  final bool isMatchPlay;
  final Function(LeaderboardEntry)? onPlayerTap;

  final String? highlightEntryId;

  const LeaderboardWidget({
    super.key, 
    required this.entries, 
    required this.format,
    this.isMatchPlay = false,
    this.onPlayerTap,
    this.highlightEntryId,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final Map<int, List<LeaderboardEntry>> tiedGroups = {};
    for (final e in entries) {
      if (e.scoringStatus == ScoringStatus.ok) {
        tiedGroups[e.score] = (tiedGroups[e.score] ?? []);
        tiedGroups[e.score]!.add(e);
      }
    }
    final isStableford = format == CompetitionFormat.stableford;

    return Column(
      children: entries.asMap().entries.map((mapEntry) {
        final idx = mapEntry.key;
        final entry = mapEntry.value;
        String? differentiatorChain;
        final tiedWith = tiedGroups[entry.score] ?? [];
        
        if (tiedWith.length > 1) {
          // CHAIN OF DECIDERS LOGIC
          // 1. Get segments for neighbors with same score
          List<String> getSegments(LeaderboardEntry e) => 
              (e.tieBreakDetails ?? e.tieBreakLabel ?? '').split(RegExp(r'[,•]')).map((s) => s.trim()).toList();
          
          final mySegments = getSegments(entry);
          
          int findFirstDiff(List<String> a, List<String> b) {
            int k = 0;
            while (k < a.length && k < b.length && a[k] == b[k]) {
              k++;
            }
            return k; // index of first difference (or end of list)
          }

          int maxDiffNeeded = 0;
          
          // Check neighbor above
          if (idx > 0 && entries[idx-1].score == entry.score) {
             maxDiffNeeded = findFirstDiff(mySegments, getSegments(entries[idx-1]));
          }
          
          // Check neighbor below
          if (idx < entries.length - 1 && entries[idx+1].score == entry.score) {
             final belowDiff = findFirstDiff(mySegments, getSegments(entries[idx+1]));
             if (belowDiff > maxDiffNeeded) maxDiffNeeded = belowDiff;
          }

          // Show chain up to maxDiffNeeded
          if (maxDiffNeeded < mySegments.length) {
            differentiatorChain = mySegments.take(maxDiffNeeded + 1).join(' • ');
          } else {
            differentiatorChain = mySegments.join(' • ');
          }
        }

        final bool hasScore = entry.scoringStatus == ScoringStatus.ok;
        final String baseScore = hasScore ? (entry.scoreLabel ?? '${entry.score}') : entry.scoringStatus.name.toUpperCase();
        final String rawScore = baseScore
            .replaceAll('WIN', 'Won')
            .replaceAll('LOSS', 'Lost')
            .replaceAll('HALVED', 'Halved');
            
        final theme = Theme.of(context);
        final spacing = theme.extension<AppSpacingTokens>();

        return Padding(
          padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.md),
          child: BoxyArtMemberRow(
            name: entry.playerName,
            teamNames: (entry.teamMemberNames != null && entry.teamMemberNames!.length > 1) 
                ? entry.teamMemberNames 
                : null,
            secondaryName: (entry.teamMemberNames != null && entry.teamMemberNames!.length > 1)
                ? null // Handled by teamNames
                : ((entry.isGuest && entry.hostName != null) ? 'Guest of ${entry.hostName}' : null),
            initials: entry.initials ?? entry.playerName,
            avatarUrl: entry.avatarUrl,
            handicapIndex: entry.handicapIndex,
            playingHandicap: entry.playingHandicap,
            score: rawScore,
            scoreColor: null,
            tieBreakLabel: isMatchPlay ? null : differentiatorChain,
            thruLabel: entry.thruLabel,
            ranking: entry.position,
            isGuest: entry.isGuest,
            isCaptain: entry.isCaptain,
            hasMemberGuest: entry.hasGuest,
            isStableford: isStableford,
            teeName: entry.teeName,
            teeColor: entry.teeColor,
            useCard: true,
            showChevron: false,
            isSelected: highlightEntryId != null && entry.entryId == highlightEntryId,
            onTap: () => onPlayerTap?.call(entry),
          ),
        );
      }).toList(),
    );
  }
}

class LeaderboardEntry {
  final String entryId;
  final String playerName;
  final String? initials; // [NEW] For avatar display
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
  final bool hasGuest; // [NEW] Member who brought a guest
  final String? avatarUrl; // [NEW] Profile Picture Link
  final String? hostName; // [NEW] Member who brought this guest
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
  final bool isCaptain; // [NEW] For captain indicator
  final String? teeName; // [NEW]
  final Color? teeColor; // [NEW]
  final int position;

  LeaderboardEntry({
    required this.entryId,
    required this.playerName, 
    this.initials,
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
    this.hasGuest = false,
    this.avatarUrl,
    this.hostName,
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
    this.isCaptain = false,
    this.teeName,
    this.teeColor,
    this.position = 0,
    this.scoringStatus = ScoringStatus.ok,
  });

  LeaderboardEntry copyWith({
    String? entryId,
    String? playerName,
    String? initials,
    int? score,
    String? scoreLabel,
    int? handicap,
    int? playingHandicap,
    int? holesPlayed,
    String? tieBreakDetails,
    String? tieBreakLabel,
    String? thruLabel,
    bool? isGuest,
    bool? hasGuest,
    String? avatarUrl,
    String? hostName,
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
    bool? isCaptain,
    String? teeName,
    Color? teeColor,
  }) {
    return LeaderboardEntry(
      entryId: entryId ?? this.entryId,
      playerName: playerName ?? this.playerName,
      initials: initials ?? this.initials,
      score: score ?? this.score,
      scoreLabel: scoreLabel ?? this.scoreLabel,
      handicap: handicap ?? this.handicap,
      playingHandicap: playingHandicap ?? this.playingHandicap,
      holesPlayed: holesPlayed ?? this.holesPlayed,
      tieBreakDetails: tieBreakDetails ?? this.tieBreakDetails,
      tieBreakLabel: tieBreakLabel ?? this.tieBreakLabel,
      thruLabel: thruLabel ?? this.thruLabel,
      isGuest: isGuest ?? this.isGuest,
      hasGuest: hasGuest ?? this.hasGuest,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hostName: hostName ?? this.hostName,
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
      isCaptain: isCaptain ?? this.isCaptain,
      teeName: teeName ?? this.teeName,
      teeColor: teeColor ?? this.teeColor,
    );
  }
}
