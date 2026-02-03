import 'package:flutter/material.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/competition.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final CompetitionFormat format;

  const LeaderboardWidget({super.key, required this.entries, required this.format});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isTop3 = index < 3;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isTop3 ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
            border: Border.all(color: isTop3 ? Theme.of(context).primaryColor.withValues(alpha: 0.3) : Colors.white10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isTop3 ? Theme.of(context).primaryColor : Colors.grey,
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
                    Text(
                      entry.playerName.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'HC: ${entry.handicap}',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              _buildScoreLabel(entry.score.toString(), isTop3 ? Theme.of(context).primaryColor : Colors.white),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreLabel(String score, Color color) {
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
  final String playerName;
  final int score;
  final int handicap;

  LeaderboardEntry({required this.playerName, required this.score, required this.handicap});
}
