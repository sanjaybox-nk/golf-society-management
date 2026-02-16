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
                
                // Avatar Placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarColor,
                    border: Border.all(
                      color: textColor.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      entry.playerName.isNotEmpty ? entry.playerName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entry.playerName + (entry.secondaryPlayerName != null ? ' / ${entry.secondaryPlayerName!}' : ''),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900, 
                                fontSize: 16,
                                letterSpacing: -0.4,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (entry.isGuest) 
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'HC: ${entry.handicap}${entry.playingHandicap != null ? " (${entry.playingHandicap})" : ""}',
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
  });
}
