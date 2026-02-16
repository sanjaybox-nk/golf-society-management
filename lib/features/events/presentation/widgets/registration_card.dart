import 'package:flutter/material.dart';
import '../../../../models/member.dart';
import '../../domain/registration_logic.dart';
import '../../../../core/shared_ui/modern_cards.dart';

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
          color: isWithdrawn ? Colors.grey[200] : avatarColor,
          border: Border.all(
            color: (isWithdrawn ? Colors.grey : textColor).withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: isWithdrawn ? Colors.grey : textColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ModernCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      backgroundColor: isWithdrawn ? (isDark ? Colors.white10 : Colors.grey[50]) : null,
      child: Row(
        children: [
          // Position Badge
          if (!isDinnerOnly && position != null && position != 0 && !isWithdrawn) ...[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$position',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
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
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Opacity(
              opacity: isWithdrawn ? 0.6 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                          child: Text('Confirmed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                        ),
                        const PopupMenuItem(
                          value: RegistrationStatus.reserved, 
                          child: Text('Reserved', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
                        ),
                        const PopupMenuItem(
                          value: RegistrationStatus.waitlist, 
                          child: Text('Waitlist', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                        ),
                        const PopupMenuItem(
                          value: RegistrationStatus.withdrawn, 
                          child: Text('Withdrawn', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                        ),
                      ],
                      child: _buildStatusPill(status),
                    )
                  else
                    _buildStatusPill(status),
                ],
              ),
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
                    child: onBuggyToggle != null
                        ? InkWell(
                            onTap: onBuggyToggle,
                            borderRadius: BorderRadius.circular(8),
                            child: _buildBuggyIcon(buggyStatus, size: 16),
                          )
                        : _buildBuggyIcon(buggyStatus, size: 16),
                  ),
                  const SizedBox(width: 8),
                  _buildLargeIconContainer(
                    child: onBreakfastToggle != null
                        ? InkWell(
                            onTap: onBreakfastToggle,
                            borderRadius: BorderRadius.circular(8),
                            child: Icon(
                              Icons.coffee,
                              color: attendingBreakfast
                                  ? (isWithdrawn ? Colors.grey : _getStatusColor(status))
                                  : Colors.grey[300],
                              size: 16,
                            ),
                          )
                        : Icon(
                            Icons.coffee,
                            color: attendingBreakfast
                                ? (isWithdrawn ? Colors.grey : _getStatusColor(status))
                                : Colors.grey[300],
                            size: 16,
                          ),
                  ),
                  const SizedBox(width: 8),
                  // Guest indicator (always present for alignment)
                  _buildLargeIconContainer(
                    child: Icon(
                      Icons.person_add,
                      color: hasGuest && !isWithdrawn ? Colors.deepPurple : Colors.grey[300],
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Row 2: Lunch, Dinner, Payment
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLargeIconContainer(
                    child: onLunchToggle != null
                        ? InkWell(
                            onTap: onLunchToggle,
                            borderRadius: BorderRadius.circular(8),
                            child: Icon(
                              Icons.restaurant_menu,
                              color: attendingLunch
                                  ? (isWithdrawn ? Colors.grey : _getStatusColor(status))
                                  : Colors.grey[300],
                              size: 16,
                            ),
                          )
                        : Icon(
                            Icons.restaurant_menu,
                            color: attendingLunch
                                ? (isWithdrawn ? Colors.grey : _getStatusColor(status))
                                : Colors.grey[300],
                            size: 16,
                          ),
                  ),
                  const SizedBox(width: 8),
                  _buildLargeIconContainer(
                    child: onDinnerToggle != null
                        ? InkWell(
                            onTap: onDinnerToggle,
                            borderRadius: BorderRadius.circular(8),
                            child: Icon(
                              Icons.restaurant,
                              color: attendingDinner
                                  ? (isWithdrawn ? Colors.grey : _getStatusColor(status))
                                  : Colors.grey[300],
                              size: 16,
                            ),
                          )
                        : Icon(
                            Icons.restaurant,
                            color: attendingDinner
                                ? (isWithdrawn ? Colors.grey : _getStatusColor(status))
                                : Colors.grey[300],
                            size: 16,
                          ),
                  ),
                  const SizedBox(width: 8),
                  // Payment indicator (always present for alignment)
                  _buildLargeIconContainer(
                    child: Icon(
                      Icons.check_circle,
                      color: isAdmin && hasPaid ? Colors.green : Colors.grey[300],
                      size: 16,
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

  Widget _buildStatusPill(RegistrationStatus status) {
    if (status == RegistrationStatus.none) return const SizedBox.shrink();

    Color color;
    String text;
    switch (status) {
      case RegistrationStatus.confirmed:
        color = Colors.green;
        text = 'CONFIRMED';
        break;
      case RegistrationStatus.reserved:
        color = Colors.orange;
        text = 'RESERVE';
        break;
      case RegistrationStatus.waitlist:
        color = Colors.red;
        text = 'WAITLIST';
        break;
      case RegistrationStatus.pendingGuest:
        color = Colors.grey;
        text = 'PENDING';
        break;
      case RegistrationStatus.withdrawn:
        color = Colors.grey;
        text = 'WITHDRAWN';
        break;
      case RegistrationStatus.dinner:
        color = Colors.blue; 
        text = 'DINNER';
        break;
      case RegistrationStatus.none:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }


  Widget _buildBuggyIcon(RegistrationStatus status, {double size = 20.0}) {
    // Always show grey icon if no buggy
    if (status == RegistrationStatus.none) {
      return Icon(Icons.electric_rickshaw_outlined, color: Colors.grey[300], size: size);
    }

    Color color;
    switch (status) {
      case RegistrationStatus.confirmed: color = Colors.green; break;
      case RegistrationStatus.reserved: color = Colors.orange; break;
      case RegistrationStatus.waitlist: color = Colors.red; break;
      case RegistrationStatus.pendingGuest: color = Colors.grey; break;
      default: color = Colors.grey;
    }
    return Icon(Icons.electric_rickshaw, color: color, size: size);
  }

  Widget _buildLargeIconContainer({required Widget child}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: child),
    );
  }

  Color _getStatusColor(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.confirmed: return Colors.green;
      case RegistrationStatus.reserved: return Colors.orange;
      case RegistrationStatus.waitlist: return Colors.red;
      default: return Colors.grey[800]!;
    }
  }
}
