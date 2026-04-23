import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';

/// A premium, unified row for displaying members across the application.
/// Supports rankings, avatars, legend-style metadata, and trait badges.
class BoxyArtMemberRow extends StatelessWidget {
  final String name;
  final String? secondaryName;
  final String initials;
  final String? avatarUrl;
  
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
  final bool isCaptain;
  final bool hasMemberGuest; // [NEW] Member who has a guest in the group
  final bool needsBuggy;
  final RegistrationStatus? buggyStatus;
  final bool isWinner;
  final String? matchSide; // 'A' or 'B'
  
  // Custom Trailing
  final Widget? trailing; // [NEW] Optional custom trailing widget (e.g. for Admin toggles)
  
  // Variety Pillar for grouping behavior signaling
  final Color? varietyPillarColor;
  
  final VoidCallback? onTap;
  final bool isSelected;
  final int? ranking; // [NEW] For ranking overlay on avatar
  final bool useCard; // [NEW] Whether to wrap in a card or show as a flat row
  final bool showChevron; // [NEW] Control visibility of interaction chevron
  final bool showVerticalDivider; // [NEW] Shows vertical line between avatar and content
  final Color? accentColor; // [NEW] Master accent color for the left border
  final bool isStableford; // [NEW] Whether to show 'pts' suffix for scores

  const BoxyArtMemberRow({
    super.key,
    required this.name,
    this.secondaryName,
    required this.initials,
    this.avatarUrl,
    this.leading,
    this.handicapIndex,
    this.playingHandicap,
    this.tieBreakLabel,
    this.thruLabel,
    this.score,
    this.scoreColor,
    this.isGuest = false,
    this.isCaptain = false,
    this.hasMemberGuest = false,
    this.needsBuggy = false,
    this.buggyStatus,
    this.isWinner = false,
    this.matchSide,
    this.trailing,
    this.varietyPillarColor,
    this.hasSocietyCut = false,
    this.onTap,
    this.isSelected = false,
    this.ranking,
    this.useCard = true,
    this.showChevron = true,
    this.showVerticalDivider = true,
    this.accentColor,
    this.isStableford = true,
  });

  final bool hasSocietyCut;

  @override
  Widget build(BuildContext context) {
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
              
              // Captain Overlay
              if (isCaptain && !isGuest)
                const Positioned(
                  bottom: -4,
                  right: -4,
                  child: BoxyArtIconBadge(
                    icon: Icons.shield_rounded,
                    color: AppColors.amber500,
                    size: 22,
                    iconSize: 12,
                    useCircle: true,
                  ),
                ),
                
              // Guest Overlay
              if (isGuest)
                Positioned(
                  bottom: -4,
                  left: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.amber500,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.pureWhite, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: const Text('G', style: TextStyle(fontSize: 10, fontWeight: AppTypography.weightHeavy, color: AppColors.dark900)),
                  ),
                ),

              // Host Overlay (Has Guest in group)
              if (hasMemberGuest)
                Positioned(
                  bottom: -4,
                  left: -4,
                  child: BoxyArtIconBadge(
                    icon: Icons.person_add_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                    iconSize: 12,
                    useCircle: true,
                  ),
                ),
            ],
          ),

          if (showVerticalDivider) 
            Container(
              width: 1,
              height: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              color: varietyPillarColor ?? theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySubtle),
            )
          else
            const SizedBox(width: AppSpacing.md),

          // 2. Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  toTitleCase(name),
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
                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                        fontWeight: FontWeight.w500, // w500
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // 3. Trailing
          _buildTrailing(context),
        ],
    );

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double horizontalPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;
    final double verticalPadding = spacing?.cardVerticalPadding ?? 12.0;

    final cardContent = useCard
        ? IntrinsicHeight(
            child: Row(
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
                    child: content,
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: content,
          );

    if (!useCard) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        child: content,
      );
    }

    return BoxyArtCard(
      onTap: onTap,
      padding: EdgeInsets.zero, // Padding handled by internal container
      showShadow: false,
      backgroundColor: isSelected 
          ? primary.withValues(alpha: AppColors.opacityLow) 
          : (isDark ? AppColors.dark700 : AppColors.pureWhite),
      border: cardBorder,
      child: cardContent,
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double size = 48.0; // Increased to 48px for premium impact

    return Container(
      width: size + 8,
      height: size + 8,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: isCaptain && !isGuest
            ? AppColors.amber500
            : (isDark ? AppColors.dark600 : AppColors.dark60),
        backgroundImage: (avatarUrl != null && !isGuest)
            ? NetworkImage(avatarUrl!)
            : null,
        child: (avatarUrl == null || isGuest)
            ? Text(
                initials.isNotEmpty ? initials[0].toUpperCase() : '?',
                style: TextStyle(
                  color: (isCaptain && !isGuest)
                      ? AppColors.pureWhite 
                      : (isDark ? AppColors.dark100 : AppColors.dark900),
                  fontWeight: AppTypography.weightBlack,
                  fontSize: size * 0.4,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final metaStyle = AppTypography.subtext.copyWith(
      color: isDark ? AppColors.dark150 : AppColors.dark700,
      fontSize: 13,
      fontWeight: AppTypography.weightSemibold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // HC & PHC Unified Style
            if (handicapIndex != null || playingHandicap != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (handicapIndex != null)
                    BoxyArtIndicator.hc(
                      label: handicapIndex!.toStringAsFixed(1),
                      hasHorizontalMargin: false,
                    ),
                  if (handicapIndex != null && playingHandicap != null)
                    const SizedBox(width: AppSpacing.md),
                  if (playingHandicap != null)
                    BoxyArtIndicator.phc(
                      context: context,
                      label: '$playingHandicap${hasSocietyCut ? '*' : ''}',
                      hasHorizontalMargin: false,
                    ),
                ],
              ),
            
            if (thruLabel != null)
              _buildLegendItem(
                label: thruLabel!,
                color: AppColors.lime500,
                style: metaStyle,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem({required String label, required Color color, TextStyle? style}) {
    if (label.isEmpty) return const SizedBox.shrink();
    
    return Text(
      label,
      style: (style ?? AppTypography.caption).copyWith(
        color: color,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailing != null) ...[
          const SizedBox(width: 4),
          trailing!,
        ],
        if (score != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 40),
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.displaySection.copyWith(
                      color: scoreColor ?? (isDark ? AppColors.pureWhite : AppColors.dark900),
                      height: 1.0,
                    ),
                    children: [
                      TextSpan(
                        text: score!,
                        style: AppTypography.displaySection.copyWith(
                          color: scoreColor ?? (isDark ? AppColors.pureWhite : AppColors.dark900),
                          fontSize: (score!.length > 5) ? 16 : 18,
                          height: 1.0,
                        ),
                      ),
                      if (isStableford && score!.length <= 3 && !score!.contains('&'))
                        TextSpan(
                          text: ' pts',
                          style: AppTypography.label.copyWith(
                            fontSize: 12,
                            fontWeight: AppTypography.weightMedium,
                            color: (scoreColor ?? (isDark ? AppColors.pureWhite : AppColors.dark900)).withValues(alpha: AppColors.opacityMedium),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (tieBreakLabel != null)
                Text(
                  tieBreakLabel!,
                  textAlign: TextAlign.end,
                  style: AppTypography.label.copyWith(
                    fontSize: 10,
                    fontWeight: AppTypography.weightBold,
                    color: isDark ? AppColors.dark400 : AppColors.dark500,
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

  Widget _buildTraitBadge({required BuildContext context, required Widget child, Color? backgroundColor}) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: BoxyArtSquareBadge(
        size: 24,
        isTinted: true,
        backgroundColor: backgroundColor ?? primaryColor.withValues(alpha: 0.1),
        child: child,
      ),
    );
  }
}
