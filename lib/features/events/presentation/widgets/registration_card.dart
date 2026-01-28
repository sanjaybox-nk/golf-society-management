import 'package:flutter/material.dart';
import '../../../../models/event_registration.dart';
import '../../../../models/member.dart';
import '../../domain/registration_logic.dart';

class RegistrationCard extends StatelessWidget {
  final String name;
  final String label;
  final int? position;
  final RegistrationStatus status;
  final RegistrationStatus buggyStatus;
  final bool attendingDinner;
  final bool hasGuest;
  final Member? memberProfile;
  final bool isGuest;
  final bool isDinnerOnly;
  
  // Interaction Callbacks (Admin)
  final VoidCallback? onStatusToggle;
  final VoidCallback? onBuggyToggle;
  final VoidCallback? onDinnerToggle;
  final VoidCallback? onGolfToggle;

  const RegistrationCard({
    super.key,
    required this.name,
    required this.label,
    this.position,
    required this.status,
    required this.buggyStatus,
    required this.attendingDinner,
    this.hasGuest = false,
    this.memberProfile,
    this.isGuest = false,
    this.isDinnerOnly = false,
    this.onStatusToggle,
    this.onBuggyToggle,
    this.onDinnerToggle,
    this.onGolfToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWithdrawn = status == RegistrationStatus.withdrawn;
    final Color? avatarColor = isGuest ? Colors.orange.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1);
    final Color? textColor = isGuest ? Colors.orange : Theme.of(context).primaryColor;

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
                    GestureDetector(
                      onTap: onStatusToggle,
                      child: _buildStatusPill(status),
                    ),
                  ],
                ),
              ),
            ),
            
            // Fixed Width Icon Slots for Vertical Alignment
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Golf Slot (Admin only)
                if (onGolfToggle != null)
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: onGolfToggle,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.sports_golf, 
                        color: !isWithdrawn && !isDinnerOnly ? Colors.green : Colors.grey[300], 
                        size: 20
                      ),
                    ),
                  ),
                ),

                // Guest Slot
                Container(
                  width: 32, 
                  alignment: Alignment.center,
                  child: hasGuest && !isWithdrawn ? Container(
                     width: 20, 
                     height: 20,
                     alignment: Alignment.center,
                     decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                     child: const Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange)),
                   ) : null,
                ),
                
                // Buggy Slot
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: onBuggyToggle,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildBuggyIcon(buggyStatus),
                    ),
                  ),
                ),

                // Dinner Slot
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: onDinnerToggle,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.restaurant, 
                        color: attendingDinner ? (isWithdrawn ? Colors.grey : Colors.grey[800]) : Colors.grey[300], 
                        size: 20
                      ),
                    ),
                  ),
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
        text = 'RESERVED';
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

  Widget _buildBuggyIcon(RegistrationStatus status) {
    if (status == RegistrationStatus.none && onBuggyToggle == null) {
       return const SizedBox.shrink();
    }
    
    // If Admin (onBuggyToggle != null), show an outlined icon if none
    if (status == RegistrationStatus.none) {
      return Icon(Icons.electric_car_outlined, color: Colors.grey[300], size: 20);
    }

    Color color;
    switch (status) {
      case RegistrationStatus.confirmed: color = Colors.green; break;
      case RegistrationStatus.reserved: color = Colors.orange; break;
      case RegistrationStatus.waitlist: color = Colors.red; break;
      case RegistrationStatus.pendingGuest: color = Colors.grey; break;
      default: color = Colors.grey;
    }
    return Icon(Icons.electric_car, color: color, size: 20);
  }
}
