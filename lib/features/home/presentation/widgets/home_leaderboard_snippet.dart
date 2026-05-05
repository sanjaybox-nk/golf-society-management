part of '../member_home_screen.dart';

class _LeaderboardSnippet extends StatelessWidget {
  final List<Map<String, dynamic>> topPlayers;
  final LeaderboardStanding? personalStanding;
  final int? personalRank;

  const _LeaderboardSnippet({required this.topPlayers, this.personalStanding, this.personalRank});

  @override
  Widget build(BuildContext context) {
    final isPersonalInSnippet = topPlayers.any((p) => p['name'] == personalStanding?.memberName);

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topPlayers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                   Icon(Icons.info_outline_rounded, size: AppShapes.iconSm, color: AppColors.dark400),
                   const SizedBox(width: AppSpacing.sm),
                   Text(
                     'No standings recorded yet.',
                     style: AppTypography.labelStrong.copyWith(
                       color: AppColors.dark500,
                     ),
                   ),
                ],
              ),
            ),

          ...topPlayers.map((player) {
            final position = player['position'] as int;
            final isFirst = position == 1;
            final isMe = player['name'] == personalStanding?.memberName;
            final name = player['name'] as String;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  BoxyArtNumberBadge(
                    number: position,
                    size: AppShapes.iconLg,
                    textColor: isMe ? AppColors.teamA : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Standard Avatar
                  Container(
                    width: AppSpacing.x3l,
                    height: AppSpacing.x3l,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.dark600,
                      border: Border.all(color: AppColors.dark900, width: AppShapes.borderMedium),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.dark300,
                          fontWeight: AppTypography.weightExtraBold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.button.copyWith(
                        color: isMe ? AppColors.teamA : AppColors.pureWhite,
                        fontWeight: AppTypography.weightExtraBold,
                      ),
                    ),
                  ),
                  Text(
                    '${player['points']}',
                    style: AppTypography.displayLargeBody.copyWith(
                      color: isMe ? AppColors.teamA : (isFirst ? AppColors.lime500 : AppColors.pureWhite),
                      fontWeight: AppTypography.weightExtraBold,
                    ),
                  ),
                ],
              ),
            );
          }),
          
          if (!isPersonalInSnippet && personalStanding != null) ...[
                const BoxyArtDivider(),
            Row(
              children: [
                BoxyArtNumberBadge(
                  number: personalRank ?? 0,
                  size: AppShapes.iconLg,
                  textColor: AppColors.teamA,
                  color: AppColors.teamA.withValues(alpha: AppColors.opacityLow),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: AppSpacing.x3l,
                  height: AppSpacing.x3l,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.dark600,
                    border: Border.all(color: AppColors.dark900, width: AppShapes.borderMedium),
                  ),
                  child: Center(
                    child: Text(
                      (personalStanding!.memberName.isNotEmpty) ? personalStanding!.memberName[0].toUpperCase() : '?',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.dark300,
                        fontWeight: AppTypography.weightExtraBold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Your Standing',
                    style: AppTypography.displayHeading.copyWith(
                      fontSize: AppTypography.sizeButton, 
                      fontWeight: AppTypography.weightExtraBold, 
                      color: AppColors.teamA,
                    ),
                  ),
                ),
                Text(
                  '${personalStanding?.points.toInt()}',
                  style: AppTypography.displayLargeBody.copyWith(
                    fontWeight: AppTypography.weightExtraBold, 
                    color: AppColors.teamA,
                  ),
                ),
              ],
            ),
          ],

          if (topPlayers.isNotEmpty || personalStanding != null) ...[
            const SizedBox(height: AppSpacing.md),
            const BoxyArtDivider(verticalPadding: AppSpacing.xs),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => context.push('/locker/standings'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Full Season Standings',
                    style: AppTypography.label.copyWith(
                      color: AppColors.lime500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.arrow_forward_rounded, size: AppShapes.iconSm, color: AppColors.lime500),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Ready for the green,';
  if (hour < 17) return 'Perfect day for a round,';
  return 'Fore! Welcome back,';
}


