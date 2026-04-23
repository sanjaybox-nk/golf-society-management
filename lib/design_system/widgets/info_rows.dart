import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A structured row for displaying info within a BoxyArtCard.
class ModernInfoRow extends ConsumerWidget {
  final String label;
  final String? subtitle;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color? labelColor;
  final Color? valueColor;
  final double? fontSize;
  final Widget? trailing;
  final bool showFill;
  final int? maxLines;

  const ModernInfoRow({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    this.icon,
    this.iconColor,
    this.labelColor,
    this.valueColor,
    this.fontSize,
    this.trailing,
    this.showFill = true,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodySmall?.color;
    final config = ref.watch(themeControllerProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          BoxyArtIconBadge(
            icon: icon!,
            iconColor: iconColor,
            showFill: showFill,
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.micro.copyWith(
                  fontWeight: AppTypography.weightBold,
                  color: labelColor ?? textSecondary?.withValues(alpha: AppColors.opacityHigh),
                  letterSpacing: 1.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  style: AppTypography.micro.copyWith(
                    color: textSecondary?.withValues(alpha: AppColors.opacityHigh),
                  ),
                ),
              ],
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: maxLines,
                overflow: maxLines != null ? TextOverflow.ellipsis : null,
                style: AppTypography.body.copyWith(
                  color: valueColor ?? textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
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
          BoxyArtIndicator(
            label: '',
            dotColor: primary,
            hasHorizontalMargin: false,
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
            style: AppTypography.body.copyWith(
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
              label.toUpperCase(),
              style: (isTotal ? AppTypography.label : AppTypography.micro).copyWith(
                color: color ?? (isTotal ? textPrimary : textSecondary),
                fontWeight: AppTypography.weightBold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: (isTotal ? AppTypography.body.copyWith(fontWeight: AppTypography.weightBold) : AppTypography.body).copyWith(
              color: color ?? textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
