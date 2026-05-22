import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';

/// A premium, unified row for displaying members across the application.
/// Supports rankings, avatars, legend-style metadata, and trait badges.
class BoxyArtMemberRow extends ConsumerWidget {
  final String name;
  final String? secondaryName;
  final String initials;
  final String? avatarUrl;
  final List<String>? teamNames; 
  
  // Leading element type
  final Widget? leading;
  
  // Metadata
  final double? handicapIndex;
  final int? playingHandicap;
  final String? tieBreakLabel;
  final String? thruLabel;
  
  // Trailing
  final String? score;
  final Color? scoreColor;
  
  // Status/Traits
  final bool isGuest;
  final bool isSocialMember;
  final bool isCaptain;
  final bool hasMemberGuest; 
  final bool needsBuggy;
  final RegistrationStatus? buggyStatus;
  final bool isWinner;
  final String? matchSide; // 'A' or 'B'
  final bool hasSocietyCut;
  final bool isFoundingMember;
  
  // Custom Slots
  final Widget? trailing; 
  final Widget? footer; // [NEW] Bottom-aligned content to free up horizontal space
  
  // Variety Pillar for grouping behavior signaling
  final Color? varietyPillarColor;
  final String? teeName; 
  final Color? teeColor; 
  final VoidCallback? onTeeTap; 
  
  final VoidCallback? onTap;
  final bool isSelected;
  final int? ranking; 
  final bool useCard; 
  final bool showChevron; 
  final bool showVerticalDivider; 
  final Color? accentColor; 
  final bool isStableford; 
  final bool showTee; 

  const BoxyArtMemberRow({
    super.key,
    required this.name,
    this.teamNames,
    this.secondaryName,
    required this.initials,
    this.avatarUrl,
    this.handicapIndex,
    this.playingHandicap,
    this.score,
    this.scoreColor,
    this.tieBreakLabel,
    this.thruLabel,
    this.ranking,
    this.isGuest = false,
    this.isSocialMember = false,
    this.isCaptain = false,
    this.hasMemberGuest = false,
    this.isWinner = false,
    this.isStableford = true,
    this.matchSide,
    this.varietyPillarColor,
    this.hasSocietyCut = false,
    this.isFoundingMember = false,
    this.onTap,
    this.isSelected = false,
    this.useCard = true,
    this.showVerticalDivider = true,
    this.showChevron = false,
    this.accentColor,
    this.leading,
    this.trailing,
    this.footer,
    this.teeName,
    this.teeColor,
    this.onTeeTap,
    this.showTee = true,
    this.needsBuggy = false,
    this.buggyStatus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final pointsColor = Color(config.effectivePointsColor);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    BoxBorder? cardBorder;
    if (isSelected) {
      cardBorder = Border.all(color: primary, width: AppShapes.borderMedium);
    } else {
      cardBorder = Border.all(
        color: isDark ? AppColors.dark500 : AppColors.lightBorder,
        width: AppShapes.borderThin,
      );
    }

    final content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Leading
          Stack(
            clipBehavior: Clip.none,
            children: [
              leading ?? _buildAvatar(context),
              if (ranking != null)
                Positioned(
                  top: -2,
                  left: -2,
                  child: BoxyArtNumberBadge(
                    number: ranking!,
                    size: 20,
                    isRanking: true,
                    isFilled: true,
                  ),
                ),
              
                  // Captain — top left
              if (isCaptain && !isGuest)
                const Positioned(top: -4, left: -4, child: _MemberBadge(icon: Icons.shield_rounded, color: AppColors.amber500)),

              // Host (brought a guest) — bottom left
              if (hasMemberGuest)
                const Positioned(bottom: -4, left: -4, child: _MemberBadge(icon: Icons.person_add_rounded, color: AppColors.dark400)),

              // Guest — bottom right
              if (isGuest)
                const Positioned(bottom: -4, right: -4, child: BoxyArtGuestBadge(size: 18)),

              // Social member — bottom right
              if (isSocialMember && !isGuest)
                const Positioned(bottom: -4, right: -4, child: _MemberBadge(icon: Icons.people_rounded, color: AppColors.guestPurple)),
            ],
          ),

          if (showVerticalDivider)
            Container(
              width: 1,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              color: varietyPillarColor ?? theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySubtle),
            )
          else
            const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (teamNames != null && teamNames!.isNotEmpty)
                  ...teamNames!.map((tName) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      toTitleCase(tName),
                      style: AppTypography.memberName.copyWith(
                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                        fontSize: teamNames!.length > 2 ? 14 : 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
                else
                  Text(
                    toTitleCase(cleanGuestName(name)),
                    style: AppTypography.memberName.copyWith(
                      color: isDark ? AppColors.pureWhite : AppColors.dark900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: AppSpacing.xs),
                _buildMetadata(context),
                if (secondaryName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      toTitleCase(secondaryName!),
                      style: AppTypography.micro.copyWith(
                        color: isDark ? AppColors.dark200 : AppColors.dark300,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: footer!,
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // 3. Trailing
          _buildTrailing(context, pointsColor),
        ],
    );

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double horizontalPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;
    final double verticalPadding = spacing?.cardVerticalPadding ?? 12.0;

    final rowContent = IntrinsicHeight(child: content);

    final cardContent = useCard
        ? Row(
              children: [
                Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: Colors.transparent, // Always reserve space
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.sm, // 8px (combined with 4px bar = 12px start gap)
                      right: horizontalPadding,
                      top: verticalPadding,
                      bottom: verticalPadding,
                    ),
                    child: rowContent,
                  ),
                ),
              ],
            )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: rowContent,
          );

    if (!useCard) {
      return cardContent;
    }

    return BoxyArtCard(
      onTap: onTap,
      padding: EdgeInsets.zero, // Padding handled by internal container
      showShadow: true,
      backgroundColor: isSelected 
          ? primary.withValues(alpha: AppColors.opacityLow) 
          : (isDark ? AppColors.dark700 : AppColors.pureWhite),
      border: cardBorder,
      child: cardContent,
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return BoxyArtAvatar(
      url: avatarUrl,
      initials: extractInitials(initials),
      radius: 24,
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (handicapIndex != null)
              BoxyArtIndicator.hc(
                label: handicapIndex!.toStringAsFixed(1),
                hasHorizontalMargin: false,
              ),
            if (playingHandicap != null)
              BoxyArtIndicator.phc(
                context: context,
                label: '$playingHandicap${hasSocietyCut ? '*' : ''}',
                hasHorizontalMargin: false,
              ),
            if (teeName != null && showTee)
              BoxyArtIndicator.tee(
                label: teeName!,
                teeColor: teeColor ?? AppColors.textSecondary,
                onTap: onTeeTap,
                hasHorizontalMargin: false,
              ),
          ],
        ),
      ],
    );
  }


  Widget _buildTrailing(BuildContext context, Color pointsColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final metaStyle = AppTypography.label.copyWith(
      fontSize: 10,
      fontWeight: AppTypography.weightSemibold,
      color: isDark ? AppColors.dark400 : AppColors.dark600,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailing != null) ...[
          const SizedBox(width: 4),
          trailing!,
        ],
        if (score != null || thruLabel != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (score != null)
                Container(
                  constraints: const BoxConstraints(minWidth: 40),
                  alignment: Alignment.centerRight,
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.displaySection.copyWith(
                        color: scoreColor ?? pointsColor,
                        height: 1.0,
                      ),
                      children: [
                        TextSpan(
                          text: score!,
                          style: AppTypography.displaySection.copyWith(
                            color: scoreColor ?? pointsColor,
                            fontSize: isStableford ? 24 : ((score!.length > 5) ? 18 : 20),
                            fontWeight: isStableford ? AppTypography.weightBlack : AppTypography.weightBold,
                            height: 1.0,
                          ),
                        ),
                        if (isStableford && score!.length <= 3 && !score!.contains('&'))
                          TextSpan(
                            text: ' pts',
                            style: AppTypography.label.copyWith(
                              fontSize: 13,
                              fontWeight: AppTypography.weightExtraBold,
                              color: (scoreColor ?? pointsColor).withValues(alpha: AppColors.opacityHigh),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
              // Thru Status / Finished
              if (thruLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    thruLabel!,
                    textAlign: TextAlign.end,
                    style: metaStyle.copyWith(
                      color: isDark ? AppColors.pureWhite : AppColors.dark900,
                      fontWeight: AppTypography.weightExtraBold,
                    ),
                  ),
                ),
              // Tie-break (B9) — below F so F position is always consistent
              if (tieBreakLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    tieBreakLabel!,
                    textAlign: TextAlign.end,
                    style: metaStyle,
                  ),
                ),
            ],
          ),
        ],

        if (showChevron) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.chevron_right_rounded, 
            color: AppColors.dark400.withValues(alpha: AppColors.opacityMuted), 
            size: 16,
          ),
        ],
      ],
    );
  }

}

class _MemberBadge extends StatelessWidget {
  final IconData? icon;
  final Color color;
  const _MemberBadge({this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: 10, color: AppColors.pureWhite)
          : const Text('', style: TextStyle(color: AppColors.pureWhite, fontSize: 8, fontWeight: FontWeight.w800)),
    );
  }
}
