
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:intl/intl.dart';

/// A stylized date badge for event lists.
class BoxyArtDateBadge extends ConsumerWidget {
  final DateTime date;
  final DateTime? endDate;
  final Color? highlightColor;

  const BoxyArtDateBadge({
    super.key, 
    required this.date,
    this.endDate,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isMultiDay = endDate != null && !DateUtils.isSameDay(date, endDate);
    final config = ref.watch(themeControllerProvider);

    // Design 4.x: Use branding tokens for the date badge background
    final Color effectiveBg = Color(config.iconBadgeFillColor).withValues(alpha: config.iconBadgeOpacity);
    final Color effectiveTextColor = Color(config.iconBadgeTextColor);

    return Container(
      width: 60,
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(config.accentRadius),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: AppSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: AppTypography.caption.copyWith(
              fontSize: AppTypography.sizeMicroSmall,
              color: effectiveTextColor,
              fontWeight: AppTypography.weightBold,
              height: 1.0,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isMultiDay 
                ? '${date.day}-${endDate!.day}'
                : DateFormat('d').format(date),
              style: AppTypography.displayHero.copyWith(
                fontSize: 24, 
                height: 1.0,
                color: effectiveTextColor,
              ),
            ),
          ),
          Text(
            DateFormat('yyyy').format(date),
            style: AppTypography.micro.copyWith(
              color: effectiveTextColor,
              fontWeight: AppTypography.weightSemibold,
            ),
          ),
        ],
      ),
    );
  }
}
