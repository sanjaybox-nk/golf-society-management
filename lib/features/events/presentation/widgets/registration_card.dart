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
    final Color avatarColor = isGuest ? Colors.orange.withValues(alpha: 0.1) : theme.primaryColor.withValues(alpha: 0.1);
    final Color textColor = isGuest ? Colors.orange : theme.primaryColor;

    // Avatar Logic
    Widget avatarChild;
    if (memberProfile?.avatarUrl != null && !isGuest) {
      avatarChild = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1), width: 1.5),
          image: DecorationImage(
            image: NetworkImage(memberProfile!.avatarUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      avatarChild = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: avatarColor,
          border: Border.all(
            color: textColor.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
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
            const SizedBox(width: 12),
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
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    label,
                    style: AppTypography.subtext.copyWith(
                      color: isDark ? AppColors.dark150 : AppColors.dark300,
                      fontSize: 12, // Keep the density sizing
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  if (onStatusChanged != null)
                    PopupMenuButton<RegistrationStatus>(
                      initialValue: status,
                      onSelected: onStatusChanged,
                      color: isDark ? Colors.grey[900] : Colors.white,
                      surfaceTintColor: Colors.transparent,
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: RegistrationStatus.confirmed, 
                          child: Text('Confirmed', style: TextStyle(color: AppColors.lime500, fontWeight: FontWeight.bold))
                        ),
                        const PopupMenuItem(
                          value: RegistrationStatus.reserved, 
                          child: Text('Reserved', style: TextStyle(color: AppColors.amber500, fontWeight: FontWeight.bold))
                        ),
                        const PopupMenuItem(
                          value: RegistrationStatus.waitlist, 
                          child: Text('Waitlist', style: TextStyle(color: AppColors.coral500, fontWeight: FontWeight.bold))
                        ),
                        const PopupMenuItem(
                          value: RegistrationStatus.withdrawn, 
                          child: Text('Withdrawn', style: TextStyle(color: AppColors.dark400, fontWeight: FontWeight.bold))
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
                  _buildLargeIconContainer(
                    isActive: buggyStatus == RegistrationStatus.confirmed || 
                              buggyStatus == RegistrationStatus.reserved || 
                              buggyStatus == RegistrationStatus.waitlist,
                    child: onBuggyToggle != null
                        ? InkWell(
                            onTap: onBuggyToggle,
                            borderRadius: BorderRadius.circular(12),
                            child: _buildBuggyIcon(context, buggyStatus, size: 20),
                          )
                        : _buildBuggyIcon(context, buggyStatus, size: 20),
                  ),
                  const SizedBox(width: 4),
                  _buildLargeIconContainer(
                    isActive: attendingBreakfast && !isWithdrawn,
                    child: onBreakfastToggle != null
                        ? InkWell(
                            onTap: onBreakfastToggle,
                            borderRadius: BorderRadius.circular(12),
                            child: Icon(
                              Icons.local_cafe_rounded,
                              color: attendingBreakfast
                                  ? (isWithdrawn ? (isDark ? AppColors.dark300 : Colors.grey) : _getStatusColor(context, status))
                                  : (isDark ? AppColors.dark400 : AppColors.dark300),
                              size: 20,
                            ),
                          )
                        : Icon(
                            Icons.local_cafe_rounded,
                            color: attendingBreakfast
                                ? (isWithdrawn ? (isDark ? AppColors.dark300 : Colors.grey) : _getStatusColor(context, status))
                                : (isDark ? AppColors.dark400 : AppColors.dark300),
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 4),
                  // Guest indicator (always present for alignment)
                  _buildLargeIconContainer(
                    isActive: hasGuest && !isWithdrawn,
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: hasGuest && !isWithdrawn ? (isDark ? Colors.white : AppColors.dark800) : (isDark ? AppColors.dark400 : AppColors.dark300),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Row 2: Lunch, Dinner, Payment
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLargeIconContainer(
                    isActive: attendingLunch && !isWithdrawn,
                    child: onLunchToggle != null
                        ? InkWell(
                            onTap: onLunchToggle,
                            borderRadius: BorderRadius.circular(12),
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              color: attendingLunch
                                  ? (isWithdrawn ? (isDark ? AppColors.dark300 : Colors.grey) : _getStatusColor(context, status))
                                  : (isDark ? AppColors.dark400 : AppColors.dark300),
                              size: 20,
                            ),
                          )
                        : Icon(
                            Icons.restaurant_menu_rounded,
                            color: attendingLunch
                                ? (isWithdrawn ? (isDark ? AppColors.dark300 : Colors.grey) : _getStatusColor(context, status))
                                : (isDark ? AppColors.dark400 : AppColors.dark300),
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 4),
                  _buildLargeIconContainer(
                    isActive: attendingDinner && !isWithdrawn,
                    child: onDinnerToggle != null
                        ? InkWell(
                            onTap: onDinnerToggle,
                            borderRadius: BorderRadius.circular(12),
                            child: Icon(
                              Icons.restaurant_rounded,
                              color: attendingDinner
                                  ? (isWithdrawn ? (isDark ? AppColors.dark300 : Colors.grey) : _getStatusColor(context, status))
                                  : (isDark ? AppColors.dark400 : AppColors.dark300),
                              size: 20,
                            ),
                          )
                        : Icon(
                            Icons.restaurant_rounded,
                            color: attendingDinner
                                ? (isWithdrawn ? (isDark ? AppColors.dark300 : Colors.grey) : _getStatusColor(context, status))
                                : (isDark ? AppColors.dark400 : AppColors.dark300),
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 4),
                  // Payment indicator (always present for alignment)
                  _buildLargeIconContainer(
                    isActive: isAdmin && hasPaid,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: isAdmin && hasPaid ? (isDark ? Colors.white : AppColors.dark800) : (isDark ? AppColors.dark400 : AppColors.dark300),
                      size: 20,
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
        color = Colors.blue; 
        text = 'Dinner';
        break;
      case RegistrationStatus.none:
        return const SizedBox.shrink();
    }

    return BoxyArtPill.status(label: text.toUpperCase(), color: color);
  }


  Widget _buildBuggyIcon(BuildContext context, RegistrationStatus status, {double size = 20.0}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppColors.dark400 : AppColors.dark300;
    final activeColor = isDark ? Colors.white : AppColors.dark800;

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

  Color _getStatusColor(BuildContext context, RegistrationStatus status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : AppColors.dark800;

    switch (status) {
      case RegistrationStatus.confirmed: return activeColor;
      case RegistrationStatus.reserved: return activeColor;
      case RegistrationStatus.waitlist: return activeColor;
      default: return isDark ? AppColors.dark400 : AppColors.dark300;
    }
  }
}
