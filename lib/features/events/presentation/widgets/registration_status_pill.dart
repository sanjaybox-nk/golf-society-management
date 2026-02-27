import 'package:flutter/material.dart';
import 'package:golf_society/core/shared_ui/badges.dart';

enum RegistrationStatusType {
  open,
  closed,
  closingSoon,
}

class RegistrationStatusPill extends StatelessWidget {
  final RegistrationStatusType type;
  final String? labelOverride;

  const RegistrationStatusPill({
    super.key,
    required this.type,
    this.labelOverride,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor;
    final IconData icon;
    final String label;

    switch (type) {
      case RegistrationStatusType.open:
        baseColor = const Color(0xFF27AE60);
        icon = Icons.timer_outlined;
        label = labelOverride ?? 'Registration Open';
        break;
      case RegistrationStatusType.closed:
        baseColor = const Color(0xFFC0392B);
        icon = Icons.lock_outline_rounded;
        label = labelOverride ?? 'Registration Closed';
        break;
      case RegistrationStatusType.closingSoon:
        baseColor = const Color(0xFFF39C12);
        icon = Icons.hourglass_bottom_rounded;
        label = labelOverride ?? 'Closing Soon';
        break;
    }

    return BoxyArtPill(
      label: label, // Restore original casing preferred by user
      color: baseColor,
      icon: icon,
    );
  }
}
