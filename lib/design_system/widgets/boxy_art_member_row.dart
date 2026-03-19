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
  
  // Variety border for grouping
  final Color? varietyBorderColor;
  
  final VoidCallback? onTap;
  final bool isSelected;
  final int? ranking; // [NEW] For ranking overlay on avatar
  final bool useCard; // [NEW] Whether to wrap in a card or show as a flat row (for GroupingCard integration)
  final bool showChevron; // [NEW] Control visibility of interaction chevron
  final Color? accentColor; // [NEW] Master accent color for the left border (Phase 46)

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
    this.varietyBorderColor,
    this.hasSocietyCut = false,
    this.onTap,
    this.isSelected = false,
    this.ranking,
    this.useCard = true,
    this.showChevron = true,
    this.accentColor,
  });

  final bool hasSocietyCut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    BoxBorder? cardBorder;
    if (isSelected) {
      cardBorder = Border.all(color: primaryColor, width: AppShapes.borderMedium);
    } else if (matchSide != null) {
      cardBorder = Border.all(
        color: matchSide == 'A' ? AppColors.teamA : AppColors.teamB,
        width: AppShapes.borderMedium,
      );
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
            ],
          ),
          const SizedBox(width: AppSpacing.md),

          // 2. Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  toTitleCase(name),
                  style: AppTypography.body.copyWith(
                    color: isDark ? AppColors.pureWhite : AppColors.dark900,
                    fontWeight: AppTypography.weightExtraBold,
                    fontSize: AppTypography.sizeBody,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondaryName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      toTitleCase(secondaryName!),
                      style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.dark150 : AppColors.dark700,
                        fontWeight: AppTypography.weightBlack,
                        fontSize: AppTypography.sizeBody,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                _buildMetadata(context),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // 3. Trailing
          _buildTrailing(context),
        ],
    );

    final cardContent = useCard
        ? IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: accentColor ?? Colors.transparent, // Always reserve space
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                    child: content,
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            child: content,
          );

    if (!useCard) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        child: content,
      );
    }

    return BoxyArtCard(
      onTap: onTap,
      padding: EdgeInsets.zero, // Padding handled by internal container
      showShadow: false,
      backgroundColor: isSelected 
          ? primaryColor.withValues(alpha: AppColors.opacityLow) 
          : (isDark ? AppColors.dark700 : AppColors.pureWhite),
      border: cardBorder,
      child: cardContent,
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = 36.0;

    return Container(
      width: size + 8,
      height: size + 8,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: varietyBorderColor ?? Colors.transparent,
          width: AppShapes.borderSemi,
        ),
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
    final metaColor = Theme.of(context).brightness == Brightness.dark 
        ? AppColors.dark150 
        : AppColors.dark300;

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
              Text.rich(
                TextSpan(
                  style: metaStyle,
                  children: [
                    if (handicapIndex != null)
                      TextSpan(text: 'HC: ${handicapIndex!.toStringAsFixed(1)}'),
                    if (handicapIndex != null && playingHandicap != null)
                      TextSpan(
                        text: '  •  ',
                        style: TextStyle(color: metaColor.withValues(alpha: 0.5)),
                      ),
                    if (playingHandicap != null)
                      TextSpan(text: 'PHC: $playingHandicap${hasSocietyCut ? '*' : ''}'),
                  ],
                ),
              ),
            
            if (thruLabel != null)
              _buildLegendItem(
                label: thruLabel!,
                color: AppColors.lime500,
                style: metaStyle,
              ),
          ],
        ),
        if (tieBreakLabel != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _buildLegendItem(
            label: tieBreakLabel!,
            color: metaColor,
            style: metaStyle,
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Traits
        if (isGuest)
          _buildTraitBadge(
            child: Text(
              'G',
              style: AppTypography.micro.copyWith(
                color: AppColors.actionGreen,
                fontWeight: AppTypography.weightBlack,
                fontSize: 12,
              ),
            ),
          ),
        if (isWinner)
          _buildTraitBadge(
            child: const Icon(Icons.emoji_events_rounded, size: 14, color: AppColors.actionGreen),
          ),
        if (needsBuggy)
          _buildTraitBadge(
            child: Icon(Icons.electric_rickshaw, size: 14, color: AppColors.actionGreen),
          ),
        if (isCaptain && !isGuest)
          _buildTraitBadge(
            backgroundColor: AppColors.amber500.withValues(alpha: 0.15),
            child: const Icon(Icons.shield, size: 14, color: AppColors.amber500),
          ),
        if (hasMemberGuest)
          _buildTraitBadge(
            child: const Icon(Icons.person_add, size: 14, color: AppColors.actionGreen),
          ),
          
        if (trailing != null) ...[
          const SizedBox(width: 4),
          trailing!,
        ],
        if (score != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            alignment: Alignment.centerRight,
            child: Text(
              score!,
              style: AppTypography.displaySection.copyWith(
                color: scoreColor ?? (isDark ? AppColors.pureWhite : AppColors.dark900),
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
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

  Widget _buildTraitBadge({required Widget child, Color? backgroundColor}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: BoxyArtSquareBadge(
        size: 24,
        isTinted: true,
        backgroundColor: backgroundColor ?? AppColors.actionGreen.withValues(alpha: 0.1),
        child: child,
      ),
    );
  }
}
