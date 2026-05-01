import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import '../../domain/registration_logic.dart';

class RegistrationCard extends ConsumerWidget {
  final String name;
  final String label;
  final int? position;
  final RegistrationStatus status;
  final RegistrationStatus buggyStatus;
  final bool attendingBreakfast;
  final bool attendingLunch;
  final bool attendingDinner;
  final bool hasGuest;
  final bool hasPaid;
  final Member? memberProfile;
  final bool isGuest;
  final bool isDinnerOnly;
  final bool isAdmin;
  final double? handicap;
  final int? playingHandicap;
  final bool hasSocietyCut;
  
  // Interaction Callbacks
  final Function(RegistrationStatus)? onStatusChanged;
  final VoidCallback? onBuggyToggle;
  final VoidCallback? onBreakfastToggle;
  final VoidCallback? onLunchToggle;
  final VoidCallback? onDinnerToggle;
  final VoidCallback? onPaidToggle; // [NEW]

  const RegistrationCard({
    super.key,
    required this.name,
    required this.label,
    this.position,
    required this.status,
    required this.buggyStatus,
    this.attendingBreakfast = false,
    this.attendingLunch = false,
    required this.attendingDinner,
    this.hasGuest = false,
    this.hasPaid = false,
    this.memberProfile,
    this.isGuest = false,
    this.isDinnerOnly = false,
    this.isAdmin = false,
    this.handicap,
    this.playingHandicap,
    this.hasSocietyCut = false,
    this.onStatusChanged,
    this.onBuggyToggle,
    this.onBreakfastToggle,
    this.onLunchToggle,
    this.onDinnerToggle,
    this.onPaidToggle, // [NEW]
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final theme = Theme.of(context);
    final bool isWithdrawn = status == RegistrationStatus.withdrawn;
    // Avatar Logic
    final Widget avatarChild = BoxyArtAvatar(
      url: (memberProfile?.avatarUrl != null && !isGuest) ? memberProfile!.avatarUrl : null,
      initials: extractInitials(name),
      radius: 36, // 72 diameter
      isCircle: true,
      color: isGuest ? AppColors.amber500 : theme.primaryColor,
    );

    final spacing = theme.extension<AppSpacingTokens>();

    return BoxyArtCard(
      padding: EdgeInsets.symmetric(
        vertical: spacing?.cardVerticalPadding ?? AppSpacing.lg,
        horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Centered vertically as requested
        children: [
          // 1. Left Section: Avatar & Rank
          Stack(
            clipBehavior: Clip.none,
            children: [
              avatarChild,
              // Rank icon at the top left of the avatar
              if (position != null && position != 0)
                Positioned(
                  top: -6,
                  left: -6,
                  child: BoxyArtNumberBadge(
                    number: position!,
                    size: 24,
                    isRanking: false,
                    isFilled: true,
                  ),
                ),
              if (isGuest)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.amber500,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.pureWhite, width: 2.0),
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: AppTypography.micro.copyWith(
                          color: AppColors.pureWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 2. Vertical Divider
          BoxyArtVerticalDivider(
            horizontalPadding: spacing?.cardHorizontalPadding ?? AppSpacing.lg,
            height: (spacing?.cardVerticalPadding ?? AppSpacing.lg) * 4.5,
          ),

          // 3. Right Section: Content
          Expanded(
            child: SizedBox(
              height: (spacing?.cardVerticalPadding ?? AppSpacing.lg) * 4.5, // Matches divider
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 3a. Name & Subtext
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              toTitleCase(cleanGuestName(name)),
                              style: AppTypography.memberName.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Status pill removed from here to move under name
                        ],
                      ),
                      if (isGuest)
                        Text(
                          label, // "Guest of Host Name"
                          style: AppTypography.caption.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                            fontSize: AppTypography.sizeMicro,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      // Metadata Row: [Status] [PHC]
                      Builder(
                        builder: (context) {
                          final statusIndicator = _buildStatusPill(context, config, status);
                          final hasStatus = statusIndicator is! SizedBox;
                          final hasPHC = playingHandicap != null;

                          if (!hasStatus && !hasPHC) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Row(
                              children: [
                                if (hasStatus) statusIndicator,
                                if (hasStatus && hasPHC) const SizedBox(width: AppSpacing.md),
                                if (hasPHC) 
                                  BoxyArtIndicator.phc(
                                    context: context,
                                    label: '$playingHandicap${hasSocietyCut ? '*' : ''}',
                                    hasHorizontalMargin: false,
                                    fontSize: 11.0,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // 3b. Icon Row (Persistent Icons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Buggy
                      _buildLargeIconContainer(
                      isActive: buggyStatus != RegistrationStatus.none && !isWithdrawn,
                      child: onBuggyToggle != null
                          ? InkWell(
                              onTap: onBuggyToggle,
                              borderRadius: AppShapes.md,
                              child: _buildBuggyIcon(context, config, buggyStatus, size: AppShapes.iconMd),
                            )
                          : _buildBuggyIcon(context, config, buggyStatus, size: AppShapes.iconMd),
                    ),
                    // Breakfast
                    _buildLargeIconContainer(
                      isActive: attendingBreakfast && !isWithdrawn,
                      child: (onBreakfastToggle != null)
                          ? InkWell(
                              onTap: onBreakfastToggle,
                              borderRadius: AppShapes.md,
                              child: Icon(Icons.local_cafe_rounded, color: attendingBreakfast && !isWithdrawn ? Color(config.secondaryColor) : _getIconInactiveColor(context), size: AppShapes.iconMd),
                            )
                          : Icon(Icons.local_cafe_rounded, color: attendingBreakfast && !isWithdrawn ? Color(config.secondaryColor) : _getIconInactiveColor(context), size: AppShapes.iconMd),
                    ),
                    // Lunch
                    _buildLargeIconContainer(
                      isActive: attendingLunch && !isWithdrawn,
                      child: (onLunchToggle != null)
                          ? InkWell(
                              onTap: onLunchToggle,
                              borderRadius: AppShapes.md,
                              child: Icon(Icons.restaurant_menu_rounded, color: attendingLunch && !isWithdrawn ? Color(config.secondaryColor) : _getIconInactiveColor(context), size: AppShapes.iconMd),
                            )
                          : Icon(Icons.restaurant_menu_rounded, color: attendingLunch && !isWithdrawn ? Color(config.secondaryColor) : _getIconInactiveColor(context), size: AppShapes.iconMd),
                    ),
                    // Dinner
                    _buildLargeIconContainer(
                      isActive: attendingDinner && !isWithdrawn,
                      child: (onDinnerToggle != null)
                          ? InkWell(
                              onTap: onDinnerToggle,
                              borderRadius: AppShapes.md,
                              child: Icon(Icons.restaurant_rounded, color: attendingDinner && !isWithdrawn ? Color(config.secondaryColor) : _getIconInactiveColor(context), size: AppShapes.iconMd),
                            )
                          : Icon(Icons.restaurant_rounded, color: attendingDinner && !isWithdrawn ? Color(config.secondaryColor) : _getIconInactiveColor(context), size: AppShapes.iconMd),
                    ),
                    // Guest (Always there now)
                    _buildLargeIconContainer(
                      isActive: hasGuest && !isWithdrawn,
                      child: Icon(Icons.person_add_alt_1_rounded, color: hasGuest && !isWithdrawn ? Color(config.secondaryColor) : _getIconInactiveColor(context), size: AppShapes.iconMd),
                    ),

                    // Payment Check
                    _buildLargeIconContainer(
                      isActive: hasPaid && !isWithdrawn,
                      child: (isAdmin && onPaidToggle != null)
                          ? InkWell(
                              onTap: onPaidToggle,
                              borderRadius: AppShapes.md,
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: hasPaid && !isWithdrawn ? Color(config.secondaryColor) : _getIconInactiveColor(context),
                                size: AppShapes.iconMd,
                              ),
                            )
                          : Icon(
                              Icons.check_circle_rounded,
                              color: hasPaid && !isWithdrawn ? Color(config.secondaryColor) : _getIconInactiveColor(context),
                              size: AppShapes.iconMd,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildStatusPill(BuildContext context, SocietyConfig config, RegistrationStatus status) {
    if (status == RegistrationStatus.none) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color color;
    String text;
    switch (status) {
      case RegistrationStatus.confirmed:
        return const SizedBox.shrink();
      case RegistrationStatus.reserved:
        color = Color(config.statusReservedColor);
        text = 'Reserve';
        break;
      case RegistrationStatus.waitlist:
        color = Color(config.statusWaitlistColor);
        text = 'Waitlist';
        break;
      case RegistrationStatus.pendingGuest:
        color = isDark ? AppColors.dark150 : AppColors.dark500;
        text = 'Pending';
        break;
      case RegistrationStatus.withdrawn:
        color = Color(config.statusWithdrawnColor);
        text = 'Withdrawn';
        break;
      case RegistrationStatus.dinner:
        color = Color(config.statusDinnerColor);
        text = 'Dinner';
        break;
      case RegistrationStatus.none:
        return const SizedBox.shrink();
    }

    return BoxyArtIndicator(
      label: text,
      dotColor: color,
      hasHorizontalMargin: false,
      fontSize: 11.0,
    );
  }


  Widget _buildBuggyIcon(BuildContext context, SocietyConfig config, RegistrationStatus status, {double size = 20.0}) {
    final inactiveColor = _getIconInactiveColor(context);
    final activeColor = Color(config.secondaryColor);

    // Always show grey icon if no buggy
    if (status == RegistrationStatus.none) {
      return Icon(Icons.electric_rickshaw_rounded, color: inactiveColor, size: size);
    }

    Color color;
    switch (status) {
      case RegistrationStatus.confirmed: color = activeColor; break;
      case RegistrationStatus.reserved: color = activeColor; break;
      case RegistrationStatus.waitlist: color = activeColor; break;
      case RegistrationStatus.pendingGuest: color = inactiveColor; break;
      default: color = inactiveColor;
    }
    return Icon(Icons.electric_rickshaw_rounded, color: color, size: size);
  }

  Widget _buildLargeIconContainer({required Widget child, bool isActive = false}) {
    return Container(
      width: 32, // Reduced from 36 to prevent overflow on small screens
      height: 32,
      color: Colors.transparent,
      alignment: Alignment.bottomCenter, // v3.2 Align to bottom to match divider
      child: child,
    );
  }


  Color _getIconInactiveColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // v3.1 Refining contrast: lighter/fainter inactive states
    return isDark ? AppColors.dark500 : AppColors.dark150;
  }
}

