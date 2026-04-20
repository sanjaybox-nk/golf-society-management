import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/features/matchplay/domain/match_play_calculator.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final CompetitionFormat format;
  final Function(LeaderboardEntry)? onPlayerTap;

  final String? highlightEntryId;

  const LeaderboardWidget({
    super.key, 
    required this.entries, 
    required this.format,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

        Color rankColor = isDark ? AppColors.dark500 : AppColors.lightBorder;
        if (entry.position == 1) rankColor = AppColors.amber500;
        if (entry.position == 2) rankColor = isDark ? AppColors.dark200 : AppColors.dark600;
        if (entry.position == 3) rankColor = const Color(0xFFCD7F32);
        
        return LeaderboardCard(
          entry: entry,
          isStableford: isStableford,
          rankColor: rankColor,
          tieBreakLabel: differentiatorChain,
          onTap: () => onPlayerTap?.call(entry),
          showBottomSpacing: idx < entries.length - 1,
          isHighlighted: highlightEntryId != null && entry.entryId == highlightEntryId,
        );
      }).toList(),
    );
  }
}

class LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isStableford;
  final Color rankColor;
  final String? tieBreakLabel;
  final VoidCallback? onTap;

  final bool showBottomSpacing;
  final bool isHighlighted;

  const LeaderboardCard({
    super.key,
    required this.entry,
    required this.isStableford,
    required this.rankColor,
    this.tieBreakLabel,
    this.onTap,
    this.showBottomSpacing = true,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();
    final double vPadding = (spacing?.cardVerticalPadding ?? AppSpacing.lg) * 0.8;
    final double hPadding = (spacing?.cardHorizontalPadding ?? AppSpacing.lg) * 0.8;
    final double cardHeight = vPadding * 4.5; // Increased to 4.5 to ensure alignment and resolve overflow

    final bool hasScore = entry.scoringStatus == ScoringStatus.ok;
    final String rawScore = hasScore ? (entry.scoreLabel ?? '${entry.score}') : entry.scoringStatus.name.toUpperCase();

    return Padding(
      padding: EdgeInsets.only(bottom: showBottomSpacing ? (spacing?.cardToCard ?? AppSpacing.lg) : 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: theme.extension<AppShapeTokens>()?.card ?? AppShapes.lg,
        child: BoxyArtCard(
          isHighlighted: isHighlighted,
          padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Avatar Section (Compact 60x60)
                Container(
                  width: 60,
                  constraints: BoxConstraints(minHeight: cardHeight),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      BoxyArtAvatar(
                        url: entry.avatarUrl,
                        initials: entry.playerName.isNotEmpty ? entry.playerName[0] : '?',
                        radius: 30, // 20% reduction
                        isCircle: true,
                        borderColor: rankColor,
                        borderWidth: 1.5,
                      ),
                      // Host Badge (Bottom Left)
                      if (entry.hasGuest)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: BoxyArtIconBadge(
                            icon: Icons.person_add_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                            iconSize: 14,
                            useCircle: true,
                          ),
                        ),
                      // Rank Badge (Top Left)
                      Positioned(
                        top: -2,
                        left: -2,
                        child: BoxyArtNumberBadge(
                          number: entry.position,
                          size: 24,
                          isRanking: true,
                        ),
                      ),
                      if (entry.isGuest)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.amber500,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'G',
                              style: TextStyle(
                                color: AppColors.dark900,
                                fontSize: 12,
                                fontWeight: AppTypography.weightExtraBold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 2. Vertical Divider
                Container(
                  width: 1,
                  margin: EdgeInsets.symmetric(horizontal: hPadding),
                  color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySubtle),
                ),

              Expanded(
                child: Container(
                  constraints: BoxConstraints(minHeight: cardHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: vPadding / 4),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // [FIX] Use min size to avoid overflow
                    children: [
                      Text(
                        toTitleCase(entry.playerName),
                        style: AppTypography.memberName.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (entry.isGuest && entry.hostName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 1, bottom: 3),
                          child: Text(
                            'Guest of ${entry.hostName}',
                            style: AppTypography.label.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
                              fontWeight: AppTypography.weightRegular,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          BoxyArtPill.hc(label: entry.handicapIndex.toStringAsFixed(1), hasHorizontalMargin: false),
                          if (entry.playingHandicap != null)
                            BoxyArtPill.phc(
                              context: context, 
                              label: '${entry.playingHandicap}',
                              hasHorizontalMargin: false,
                            ),
                          if (entry.hasSocietyCut)
                            BoxyArtPill(
                              label: 'CUT',
                              color: AppColors.coral500,
                              hasHorizontalMargin: true,
                              fontSize: 10,
                              fontWeight: AppTypography.weightBold,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          // Left Side: Thru & Tie-break info
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (entry.thruLabel != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    entry.thruLabel!,
                                    style: AppTypography.helper.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
                                      fontStyle: FontStyle.italic,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              if (entry.thruLabel != null && hasScore && tieBreakLabel != null)
                                const SizedBox(width: AppSpacing.sm),
                              if (hasScore && tieBreakLabel != null)
                                Text(
                                  tieBreakLabel!,
                                  style: AppTypography.label.copyWith(
                                    fontSize: 10,
                                    fontWeight: AppTypography.weightBold,
                                    color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                            ],
                          ),

                          // Right Side: Score
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: rawScore,
                                  style: AppTypography.displayHeading.copyWith(
                                    fontSize: (rawScore.length > 5) ? 18 : 24, // Smaller font for "Won 3 & 2"
                                    fontWeight: AppTypography.weightBlack,
                                    color: hasScore ? theme.colorScheme.primary : AppColors.coral500,
                                    height: 1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (hasScore && isStableford && !rawScore.contains('UP') && !rawScore.contains('DN') && !rawScore.contains('AS') && !rawScore.contains('&'))
                                  TextSpan(
                                    text: ' pts',
                                    style: AppTypography.label.copyWith(
                                      fontSize: 12,
                                      fontWeight: AppTypography.weightMedium,
                                      color: theme.colorScheme.primary.withValues(alpha: AppColors.opacityMedium),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
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
    );
  }
}
