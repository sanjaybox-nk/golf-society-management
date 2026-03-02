import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';

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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: standings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final standing = standings[index];
        final isMe = standing.memberId == currentUserId;

        return BoxyArtCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 32,
                child: Text(
                  '${index + 1}',
                  style: AppTypography.displayHeading.copyWith(
                    fontSize: 18,
                    color: isMe ? AppColors.lime500 : (isDark ? AppColors.dark150 : AppColors.dark700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Avatar Placeholder
              CircleAvatar(
                radius: 18,
                backgroundColor: isMe ? AppColors.lime500 : (isDark ? AppColors.dark600 : AppColors.dark150),
                child: Text(
                  standing.memberName.isNotEmpty ? standing.memberName[0].toUpperCase() : '?',
                  style: AppTypography.label.copyWith(
                    color: isMe ? AppColors.actionText : (isDark ? AppColors.pureWhite : AppColors.dark900),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
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
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isMe ? AppColors.lime500 : (isDark ? AppColors.pureWhite : AppColors.dark900),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${standing.roundsPlayed} ROUNDS',
                      style: AppTypography.label.copyWith(
                        color: isDark ? AppColors.dark300 : AppColors.dark400,
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
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
                    style: AppTypography.displayHeading.copyWith(
                      color: isMe ? AppColors.lime500 : (isDark ? AppColors.pureWhite : AppColors.dark900),
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'PTS',
                    style: AppTypography.label.copyWith(
                      color: isDark ? AppColors.dark300 : AppColors.dark400,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
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
