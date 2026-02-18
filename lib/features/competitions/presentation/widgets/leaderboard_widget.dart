import 'package:flutter/material.dart';
import '../../../../models/competition.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';

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
    final theme = Theme.of(context);

    return Column(
      children: entries.asMap().entries.map((item) {
        final index = item.key;
        final entry = item.value;
        final isTop3 = index < 3;
        final isTeam = entry.mode == CompetitionMode.teams;
        
        final Color avatarColor = entry.isGuest ? Colors.orange.withValues(alpha: 0.1) : theme.primaryColor.withValues(alpha: 0.1);
        final Color textColor = entry.isGuest ? Colors.orange : theme.primaryColor;

        return ModernCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          backgroundColor: isTop3 
              ? theme.primaryColor.withValues(alpha: 0.05) 
              : null,
          child: InkWell(
            onTap: () => onPlayerTap?.call(entry),
            child: Row(
              children: [
                // Rank Indicator Badge
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isTop3 ? theme.primaryColor : theme.primaryColor.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isTop3 ? Colors.white : theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Avatar / Avatar Stack
                SizedBox(
                  width: 44,
                  height: 40,
                  child: Stack(
                    children: [
                      if (isTeam && entry.teamMemberNames != null && entry.teamMemberNames!.length > 1)
                        ...entry.teamMemberNames!.take(2).toList().asMap().entries.map((item) {
                          final i = item.key;
                          final name = item.value;
                          return Positioned(
                            left: i * 14.0,
                            top: 0,
                            child: _buildAvatar(context, name, avatarColor, textColor, size: 30),
                          );
                        })
                      else
                        Center(child: _buildAvatar(context, entry.playerName, avatarColor, textColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name(s) Rows
                      if (entry.teamMemberNames != null && entry.teamMemberNames!.isNotEmpty)
                        ...entry.teamMemberNames!.map((name) => Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900, 
                                fontSize: 15,
                                height: 1.2,
                                letterSpacing: -0.4,
                              ),
                            ))
                      else
                        Text(
                          entry.playerName + (entry.secondaryPlayerName != null ? '\n${entry.secondaryPlayerName!}' : ''),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 15, 
                            height: 1.2,
                            letterSpacing: -0.4,
                          ),
                        ),

                      // GUEST Badge
                      if (entry.isGuest) 
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'GUEST',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.orange,
                            ),
                          ),
                        ),

                      // TEAM/PAIR Badge
                      if (isTeam)
                        Container(
                          margin: const EdgeInsets.only(top: 4, bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            entry.mode == CompetitionMode.pairs ? 'PAIR' : 'TEAM',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),

                      // Metadata Row (HC, THRU)
                      Row(
                        children: [
                          Text(
                            () {
                              final baseHc = entry.handicap;
                              final phc = entry.playingHandicap;
                              final label = isTeam ? "Team HC" : "HC";
                              
                              if (baseHc == 0 && phc != null) {
                                return '$label: $phc';
                              }
                              return '$label: $baseHc${phc != null ? " ($phc)" : ""}';
                            }(),
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color, 
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (entry.holesPlayed != null && entry.holesPlayed! < 18 && entry.holesPlayed! > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'THRU ${entry.holesPlayed}',
                                style: const TextStyle(color: Colors.blue, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (entry.tieBreakDetails != null)
                        Text(
                          entry.tieBreakDetails!,
                          style: TextStyle(
                            color: theme.primaryColor.withValues(alpha: 0.7),
                            fontSize: 9,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildScoreLabel(
                  context,
                  entry.scoreLabel ?? entry.score.toString(), 
                  isTop3 ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvatar(BuildContext context, String name, Color backgroundColor, Color textColor, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreLabel(BuildContext context, String score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        score,
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16),
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
    );
  }
}
