import 'package:flutter/material.dart';
import '../../../../models/competition.dart';

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
        
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return GestureDetector(
          onTap: () => onPlayerTap?.call(entry),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
            color: isTop3 
                ? Theme.of(context).primaryColor.withValues(alpha: 0.05) 
                : Theme.of(context).cardColor,
            border: Border.all(
              color: isTop3 
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.3) 
                  : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isTop3 ? Theme.of(context).primaryColor : (isDark ? Colors.white38 : Colors.grey),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.playerName.toUpperCase() + (entry.secondaryPlayerName != null ? ' / ${entry.secondaryPlayerName!.toUpperCase()}' : ''),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 13,
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
                            color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey, 
                            fontSize: 10,
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
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
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
                isTop3 ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),);
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
