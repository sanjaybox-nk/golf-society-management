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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x3l),
          child: Text(
            'No standings available yet.',
            style: TextStyle(color: AppColors.pureWhite.withValues(alpha: 0.54)),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: standings.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final standing = standings[index];
        final isMe = standing.memberId == currentUserId;

        return BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: AppSpacing.x3l,
                child: Text(
                  '${index + 1}',
                  style: AppTypography.displayHeading.copyWith(
                    fontSize: AppTypography.sizeLargeBody,
                    color: isMe ? AppColors.lime500 : (isDark ? AppColors.dark150 : AppColors.dark700),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Avatar Placeholder
              CircleAvatar(
                radius: 18,
                backgroundColor: isMe ? AppColors.lime500 : (isDark ? AppColors.dark600 : AppColors.dark150),
                child: Text(
                  standing.memberName.isNotEmpty ? standing.memberName[0].toUpperCase() : '?',
                  style: AppTypography.label.copyWith(
                    color: isMe ? AppColors.actionText : (isDark ? AppColors.pureWhite : AppColors.dark900),
                    fontSize: AppTypography.sizeBodySmall,
                    fontWeight: AppTypography.weightBlack,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      standing.memberName,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: AppTypography.weightExtraBold,
                        color: isMe ? AppColors.lime500 : (isDark ? AppColors.pureWhite : AppColors.dark900),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${standing.roundsPlayed} ROUNDS',
                      style: AppTypography.label.copyWith(
                        color: isDark ? AppColors.dark300 : AppColors.dark400,
                        fontSize: AppTypography.sizeCaption,
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
                      fontSize: AppTypography.sizeLargeBody,
                    ),
                  ),
                  Text(
                    'PTS',
                    style: AppTypography.label.copyWith(
                      color: isDark ? AppColors.dark300 : AppColors.dark400,
                      fontSize: AppTypography.sizeCaption,
                      fontWeight: AppTypography.weightBlack,
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
