import 'package:golf_society/design_system/design_system.dart';

/// A structured row for displaying info within a BoxyArtCard.
class ModernInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color? labelColor;
  final Color? valueColor;
  final double? fontSize;

  const ModernInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.labelColor,
    this.valueColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;

    return Row(
      children: [
        if (icon != null) ...[
          BoxyArtIconBadge(
            icon: icon!,
            color: iconColor ?? AppColors.actionGreen,
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  fontWeight: AppTypography.weightBold,
                  color: labelColor ?? textSecondary?.withValues(alpha: AppColors.opacityHigh),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.displayMedium.copyWith(
                  fontSize: fontSize ?? 16.5,
                  fontWeight: AppTypography.weightExtraBold,
                  color: valueColor ?? textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A standardized bulleted row for metadata (Format: Label: Value).
class ModernRuleItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? accentColor;

  const ModernRuleItem({
    super.key,
    required this.label,
    required this.value,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = accentColor ?? Theme.of(context).primaryColor;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: BoxyArtSectionTitle(
              title: label,
              isLevel2: true,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTypography.sizeLabelStrong,
              fontWeight: AppTypography.weightSemibold,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A dedicated row for financial data or key-value pairs with prominence.
class ModernCostRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isTotal;
  final Color? color;

  const ModernCostRow({
    super.key,
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 15,
                color: color ?? (isTotal ? textPrimary : textSecondary),
                fontWeight: isTotal ? AppTypography.weightExtraBold : AppTypography.weightSemibold,
              ),
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? AppTypography.weightBlack : AppTypography.weightBold,
              color: color ?? textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
