import 'package:golf_society/design_system/design_system.dart';

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
        baseColor = AppColors.lime500;
        icon = Icons.timer_outlined;
        label = labelOverride ?? 'Registration Open';
        break;
      case RegistrationStatusType.closed:
        baseColor = AppColors.dark400;
        icon = Icons.lock_outline_rounded;
        label = labelOverride ?? 'Registration Closed';
        break;
      case RegistrationStatusType.closingSoon:
        baseColor = AppColors.coral400;
        icon = Icons.hourglass_bottom_rounded;
        label = labelOverride ?? 'Closing Soon';
        break;
    }

    return BoxyArtPill.status(
      label: label,
      color: baseColor,
      icon: icon,
    );
  }
}
