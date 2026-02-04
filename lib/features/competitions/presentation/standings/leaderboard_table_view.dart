import 'package:flutter/material.dart';
import '../../../../models/leaderboard_standing.dart';

class LeaderboardTableView extends StatelessWidget {
  final List<LeaderboardStanding> standings;
  final String currentUserId;

  const LeaderboardTableView({
    super.key,
    required this.standings,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (standings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No standings available yet.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: standings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final standing = standings[index];
        final isMe = standing.memberId == currentUserId;

        return Container(
          decoration: BoxDecoration(
            color: isMe 
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1) 
                : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: isMe 
                ? Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.5))
                : Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 32,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Avatar Placeholder
              CircleAvatar(
                radius: 16,
                backgroundColor: isMe ? Theme.of(context).primaryColor : Colors.grey[800],
                child: Text(
                  standing.memberName.isNotEmpty ? standing.memberName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),

              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      standing.memberName,
                      style: TextStyle(
                        color: isMe ? Theme.of(context).primaryColor : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${standing.roundsPlayed} Rounds',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Points/Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    standing.points.toStringAsFixed(standing.points.truncateToDouble() == standing.points ? 0 : 1),
                    style: TextStyle(
                      color: isMe ? Theme.of(context).primaryColor : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'PTS',
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
