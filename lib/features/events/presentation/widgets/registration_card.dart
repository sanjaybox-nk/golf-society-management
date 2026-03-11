import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../domain/registration_logic.dart';

class RegistrationCard extends StatelessWidget {
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
  
  // Interaction Callbacks
  final Function(RegistrationStatus)? onStatusChanged;
  final VoidCallback? onBuggyToggle;
  final VoidCallback? onBreakfastToggle;
  final VoidCallback? onLunchToggle;
  final VoidCallback? onDinnerToggle;

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
    this.onStatusChanged,
    this.onBuggyToggle,
    this.onBreakfastToggle,
    this.onLunchToggle,
    this.onDinnerToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isWithdrawn = status == RegistrationStatus.withdrawn;
    final Color avatarColor = isGuest ? AppColors.amber500.withValues(alpha: AppColors.opacityLow) : theme.primaryColor.withValues(alpha: AppColors.opacityLow);
    final Color textColor = isGuest ? AppColors.amber500 : theme.primaryColor;

    // Avatar Logic
    Widget avatarChild;
    if (memberProfile?.avatarUrl != null && !isGuest) {
      avatarChild = Container(
        width: AppSpacing.x4l,
        height: AppSpacing.x4l,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.primaryColor.withValues(alpha: AppColors.opacityLow), width: AppShapes.borderLight),
          image: DecorationImage(
            image: NetworkImage(memberProfile!.avatarUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      avatarChild = Container(
        width: AppSpacing.x4l,
        height: AppSpacing.x4l,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: avatarColor,
          border: Border.all(
            color: textColor.withValues(alpha: AppColors.opacityLow),
            width: AppShapes.borderLight,
          ),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: textColor,
              fontWeight: AppTypography.weightBlack,
              fontSize: AppTypography.sizeBody,
            ),
          ),
        ),
      );
    }

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Position Badge or Avatar
          if (!isDinnerOnly && position != null && position != 0 && !isWithdrawn) ...[
            BoxyArtNumberBadge(number: position!, size: 36, isRanking: false),
            const SizedBox(width: AppSpacing.md),
          ] else ...[
            // Avatar with optional Guest badge
          Stack(
            children: [
              avatarChild,
              // Guest badge overlay
              if (isGuest)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: AppSpacing.lg,
                    height: AppSpacing.lg,
                    decoration: BoxDecoration(
                      color: AppColors.amber500,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.pureWhite, width: AppShapes.borderLight),
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.pureWhite,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.body.copyWith(
                      fontWeight: AppTypography.weightBlack,
                      fontSize: AppTypography.sizeBody,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    label,
                    style: AppTypography.subtext.copyWith(
                      color: isDark ? AppColors.dark150 : AppColors.dark300,
                      fontSize: AppTypography.sizeLabel, // Keep the density sizing
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  if (onStatusChanged != null)
                    PopupMenuButton<RegistrationStatus>(
                      initialValue: status,
                      onSelected: onStatusChanged,
                      color: isDark ? AppColors.textSecondary : AppColors.pureWhite,
                      surfaceTintColor: Colors.transparent,
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: AppShapes.lg),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: RegistrationStatus.confirmed, 
                          child: Text('Confirmed', style: TextStyle(color: AppColors.lime500, fontWeight: AppTypography.weightBold))
                        ),
                        const PopupMenuItem(
                          value: RegistrationStatus.reserved, 
                          child: Text('Reserved', style: TextStyle(color: AppColors.amber500, fontWeight: AppTypography.weightBold))
                        ),
                        const PopupMenuItem(
                          value: RegistrationStatus.waitlist, 
                          child: Text('Waitlist', style: TextStyle(color: AppColors.coral500, fontWeight: AppTypography.weightBold))
                        ),
                        const PopupMenuItem(
                          value: RegistrationStatus.withdrawn, 
                          child: Text('Withdrawn', style: TextStyle(color: AppColors.dark400, fontWeight: AppTypography.weightBold))
                        ),
                      ],
                      child: _buildStatusPill(context, status),
                    )
                  else
                    _buildStatusPill(context, status),
                ],
              ),
            ),
          
          // Icon Grid Layout - Always 2x3 for consistent alignment
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Buggy, Breakfast, Guest
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   // Buggy Icon
                  _buildLargeIconContainer(
                    isActive: buggyStatus != RegistrationStatus.none && !isWithdrawn,
                    child: onBuggyToggle != null
                        ? InkWell(
                            onTap: onBuggyToggle,
                            borderRadius: AppShapes.md,
                            child: _buildBuggyIcon(context, buggyStatus, size: AppShapes.iconMd),
                          )
                        : _buildBuggyIcon(context, buggyStatus, size: AppShapes.iconMd),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Breakfast Icon
                  _buildLargeIconContainer(
                    isActive: attendingBreakfast && !isWithdrawn,
                    child: onBreakfastToggle != null
                        ? InkWell(
                            onTap: onBreakfastToggle,
                            borderRadius: AppShapes.md,
                            child: Icon(
                              Icons.local_cafe_rounded,
                              color: attendingBreakfast && !isWithdrawn
                                  ? _getIconActiveColor(context)
                                  : _getIconInactiveColor(context),
                              size: AppShapes.iconMd,
                            ),
                          )
                        : Icon(
                            Icons.local_cafe_rounded,
                            color: attendingBreakfast && !isWithdrawn
                                ? _getIconActiveColor(context)
                                : _getIconInactiveColor(context),
                            size: AppShapes.iconMd,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Guest indicator
                  _buildLargeIconContainer(
                    isActive: hasGuest && !isWithdrawn,
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: hasGuest && !isWithdrawn ? _getIconActiveColor(context) : _getIconInactiveColor(context),
                      size: AppShapes.iconMd,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              
              // Row 2: Lunch, Dinner, Payment
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lunch Icon
                  _buildLargeIconContainer(
                    isActive: attendingLunch && !isWithdrawn,
                    child: onLunchToggle != null
                        ? InkWell(
                            onTap: onLunchToggle,
                            borderRadius: AppShapes.md,
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              color: attendingLunch && !isWithdrawn
                                  ? _getIconActiveColor(context)
                                  : _getIconInactiveColor(context),
                              size: AppShapes.iconMd,
                            ),
                          )
                        : Icon(
                            Icons.restaurant_menu_rounded,
                            color: attendingLunch && !isWithdrawn
                                ? _getIconActiveColor(context)
                                : _getIconInactiveColor(context),
                            size: AppShapes.iconMd,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Dinner Icon
                  _buildLargeIconContainer(
                    isActive: attendingDinner && !isWithdrawn,
                    child: onDinnerToggle != null
                        ? InkWell(
                            onTap: onDinnerToggle,
                            borderRadius: AppShapes.md,
                            child: Icon(
                              Icons.restaurant_rounded,
                              color: attendingDinner && !isWithdrawn
                                  ? _getIconActiveColor(context)
                                  : _getIconInactiveColor(context),
                              size: AppShapes.iconMd,
                            ),
                          )
                        : Icon(
                            Icons.restaurant_rounded,
                            color: attendingDinner && !isWithdrawn
                                ? _getIconActiveColor(context)
                                : _getIconInactiveColor(context),
                            size: AppShapes.iconMd,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Payment indicator (Matches Tick in image)
                  _buildLargeIconContainer(
                    isActive: hasPaid && !isWithdrawn,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: hasPaid && !isWithdrawn ? _getIconActiveColor(context) : _getIconInactiveColor(context),
                      size: AppShapes.iconMd,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, RegistrationStatus status) {
    if (status == RegistrationStatus.none) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color color;
    String text;
    switch (status) {
      case RegistrationStatus.confirmed:
        color = AppColors.lime500;
        text = 'Confirmed';
        break;
      case RegistrationStatus.reserved:
        color = AppColors.amber500;
        text = 'Reserve';
        break;
      case RegistrationStatus.waitlist:
        color = AppColors.coral500;
        text = 'Waitlist';
        break;
      case RegistrationStatus.pendingGuest:
        color = isDark ? AppColors.dark150 : AppColors.dark500;
        text = 'Pending';
        break;
      case RegistrationStatus.withdrawn:
        color = isDark ? AppColors.dark150 : AppColors.dark500;
        text = 'Withdrawn';
        break;
      case RegistrationStatus.dinner:
        color = AppColors.teamA; 
        text = 'Dinner';
        break;
      case RegistrationStatus.none:
        return const SizedBox.shrink();
    }

    return BoxyArtPill.status(label: text, color: color, hasHorizontalMargin: false);
  }


  Widget _buildBuggyIcon(BuildContext context, RegistrationStatus status, {double size = 20.0}) {
    final inactiveColor = _getIconInactiveColor(context);
    final activeColor = _getIconActiveColor(context);

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
      width: 44,
      height: 44,
      color: Colors.transparent,
      child: Center(child: child),
    );
  }

  Color _getIconActiveColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.pureWhite : AppColors.dark800;
  }

  Color _getIconInactiveColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // v3.1 Refining contrast: lighter/fainter inactive states
    return isDark ? AppColors.dark500 : AppColors.dark150;
  }
}

