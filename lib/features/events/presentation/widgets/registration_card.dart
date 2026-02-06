import 'package:flutter/material.dart';
import '../../../../models/member.dart';
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
    final bool isWithdrawn = status == RegistrationStatus.withdrawn;
    final Color avatarColor = isGuest ? Colors.orange.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1);
    final Color textColor = isGuest ? Colors.orange : Theme.of(context).primaryColor;

    // Avatar Logic
    Widget avatarChild;
    if (memberProfile?.avatarUrl != null && !isGuest) {
      avatarChild = CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(memberProfile!.avatarUrl!),
      );
    } else {
      avatarChild = CircleAvatar(
        radius: 20,
        backgroundColor: isWithdrawn ? Colors.grey[200] : avatarColor,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(color: isWithdrawn ? Colors.grey : textColor, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isWithdrawn ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWithdrawn ? BorderSide(color: Colors.grey[300]!) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            // Position Badge (Hide for Dinner Only or Withdrawn)
            if (!isDinnerOnly && position != null && position != 0 && !isWithdrawn) ...[
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Text('$position', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
            ],
            
            avatarChild,
            const SizedBox(width: 12),
            Expanded(
              child: Opacity(
                opacity: isWithdrawn ? 0.6 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 4),
                    if (onStatusChanged != null)
                      PopupMenuButton<RegistrationStatus>(
                        initialValue: status,
                        onSelected: onStatusChanged,
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            
            // Fixed Width Icon Slots for Vertical Alignment
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Golf & Guest Column (Left of Grid)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top Row: Golf Ball (Payment Status)
                    Container(
                      width: 28,
                      height: 28, // Match height of grid row
                      alignment: Alignment.center,
                       child: isAdmin && !isGuest && !isDinnerOnly 
                        ? Icon(
                            Icons.sports_golf, 
                            color: (status == RegistrationStatus.confirmed || status == RegistrationStatus.waitlist)
                                ? Colors.green
                                : (hasPaid 
                                    ? (isWithdrawn ? Colors.grey : Colors.amber) 
                                    : Colors.grey[300]), 
                            size: 18
                          )
                        : const SizedBox.shrink(),
                    ),
                    
                    // Bottom Row: Guest Indicator
                    Container(
                      width: 28, 
                      height: 28, // Match height of grid row
                      alignment: Alignment.center,
                      child: hasGuest && !isWithdrawn 
                        ? const Icon(
                            Icons.person_add,
                            color: Colors.deepPurple,
                            size: 20,
                          )
                        : const SizedBox.shrink(),
                    ),
                  ],
                ),
                
                const SizedBox(width: 4),

                // 2x2 Grid for Resources (Buggy, Breakfast, Lunch, Dinner)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Row 1: Buggy, Breakfast
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 28,
                          alignment: Alignment.center,
                          child: onBuggyToggle != null
                              ? InkWell(
                                  onTap: onBuggyToggle,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: _buildBuggyIcon(buggyStatus, size: 18),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: _buildBuggyIcon(buggyStatus, size: 18),
                                ),
                        ),
                        Container(
                          width: 32,
                          height: 28,
                          alignment: Alignment.center,
                          child: onBreakfastToggle != null
                              ? InkWell(
                                  onTap: onBreakfastToggle,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.coffee, 
                                      color: attendingBreakfast 
                                          ? (isWithdrawn ? Colors.grey : _getStatusColor(status)) 
                                          : Colors.grey[300], 
                                      size: 18
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.coffee, 
                                    color: attendingBreakfast 
                                        ? (isWithdrawn ? Colors.grey : _getStatusColor(status)) 
                                        : Colors.grey[300], 
                                    size: 18
                                  ),
                                ),
                        ),
                      ],
                    ),
                    
                    // Row 2: Lunch, Dinner
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 28,
                          alignment: Alignment.center,
                          child: onLunchToggle != null
                              ? InkWell(
                                  onTap: onLunchToggle,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.restaurant_menu, 
                                      color: attendingLunch 
                                          ? (isWithdrawn ? Colors.grey : _getStatusColor(status)) 
                                          : Colors.grey[300], 
                                      size: 18
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.restaurant_menu, 
                                    color: attendingLunch 
                                        ? (isWithdrawn ? Colors.grey : _getStatusColor(status)) 
                                        : Colors.grey[300], 
                                    size: 18
                                  ),
                                ),
                        ),
                        Container(
                          width: 32,
                          height: 28,
                          alignment: Alignment.center,
                          child: onDinnerToggle != null
                              ? InkWell(
                                  onTap: onDinnerToggle,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.restaurant, 
                                      color: attendingDinner 
                                          ? (isWithdrawn ? Colors.grey : _getStatusColor(status)) 
                                          : Colors.grey[300], 
                                      size: 18
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.restaurant, 
                                    color: attendingDinner 
                                        ? (isWithdrawn ? Colors.grey : _getStatusColor(status)) 
                                        : Colors.grey[300], 
                                    size: 18
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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

  Color _getStatusColor(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.confirmed: return Colors.green;
      case RegistrationStatus.reserved: return Colors.orange;
      case RegistrationStatus.waitlist: return Colors.red;
      default: return Colors.grey[800]!;
    }
  }
}
