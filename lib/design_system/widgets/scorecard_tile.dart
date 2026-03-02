import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import 'card.dart';

/// A standardized tile for displaying scorecard information, 
/// primarily used in administrative lists.
class BoxyArtScorecardTile extends StatelessWidget {
  final String playerName;
  final String? secondaryPlayerName;
  final Widget? status;
  final String? score;
  final Widget? leading;
  final Widget? trailingActions;
  final VoidCallback? onTap;
  final bool isConfirmed;
  final List<String>? avatarNames; // For avatar stack

  const BoxyArtScorecardTile({
    super.key,
    required this.playerName,
    this.secondaryPlayerName,
    this.status,
    this.score,
    this.leading,
    this.trailingActions,
    this.onTap,
    this.isConfirmed = false,
    this.avatarNames,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          // 1. Leading Section (Ranking Badge or Avatar)
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          
          // Avatar Stack if provided
          if (avatarNames != null && avatarNames!.isNotEmpty) ...[
            _buildAvatarStack(context, avatarNames!),
            const SizedBox(width: AppSpacing.md),
          ],

          // 2. Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  playerName,
                  style: AppTypography.displayHeading.copyWith(
                    fontSize: 14,
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondaryPlayerName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      secondaryPlayerName!,
                      style: AppTypography.displayHeading.copyWith(
                        fontSize: 14,
                        color: AppColors.pureWhite,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (status != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  status!,
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 3. Trailing Section (Score + Actions)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (score != null)
                Text(
                  score!,
                  style: AppTypography.displayHeading.copyWith(
                    fontSize: 20,
                    color: isConfirmed 
                        ? AppColors.lime500 
                        : AppColors.pureWhite,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              
              if (trailingActions != null) ...[
                const SizedBox(width: 12),
                trailingActions!,
              ],
              
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded, 
                color: AppColors.dark400.withValues(alpha: 0.3), 
                size: 16
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(BuildContext context, List<String> names) {
    final size = 32.0;
    return SizedBox(
      width: size + (names.length > 1 ? 14 : 0),
      height: size,
      child: Stack(
        children: names.take(2).toList().asMap().entries.map((e) {
          final i = e.key;
          final name = e.value;
          return Positioned(
            left: i * 14.0,
            child: _buildAvatar(context, name, size: size),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String name, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.dark600,
        border: Border.all(
          color: AppColors.dark900,
          width: 2.0,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTypography.displayHeading.copyWith(
            color: AppColors.dark300,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.45,
          ),
        ),
      ),
    );
  }
}
