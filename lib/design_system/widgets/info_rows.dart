import 'package:golf_society/design_system/design_system.dart';

/// A structured row for displaying info within a BoxyArtCard.
class ModernInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const ModernInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;
    final primary = Theme.of(context).primaryColor;

    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.dark700.withValues(alpha: 0.8) 
                  : (iconColor ?? primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withValues(alpha: 0.15) 
                    : (iconColor ?? primary).withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              icon,
              color: iconColor ?? (Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : primary),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary?.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
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
          const SizedBox(width: 12),
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
