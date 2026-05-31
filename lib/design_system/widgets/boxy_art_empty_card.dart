import 'package:golf_society/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A premium, card-based empty state for Design 4.x ("Fairway").
/// Uses a brand-tinted icon and BoxyArtCard for a high-impact but focused "Clean Slate" look.
class BoxyArtEmptyCard extends ConsumerWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets? padding;
  final bool isCompact;

  const BoxyArtEmptyCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.padding,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = Color(ref.watch(themeControllerProvider).primaryColor);

    final badgeSize = isCompact ? 40.0 : 48.0;
    final innerIconSize = isCompact ? 20.0 : 24.0;
    final internalPadding = padding ?? (isCompact ? const EdgeInsets.all(AppSpacing.lg) : const EdgeInsets.all(AppSpacing.xl));
    final headerGap = isCompact ? AppSpacing.md : AppSpacing.lg;

    return BoxyArtCard(
      padding: internalPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BoxyArtIconBadge(
            icon: icon,
            color: primaryColor,
            size: badgeSize,
            iconSize: innerIconSize,
          ),
          
          SizedBox(height: headerGap),
          
          // 2. Headline
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.displayLocker.copyWith(
              fontSize: isCompact ? 16 : 18,
              color: theme.colorScheme.onSurface,
              fontWeight: AppTypography.weightExtraBold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // 3. Narrative
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          
          // 4. Action
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: isCompact ? AppSpacing.lg : AppSpacing.xl),
            BoxyArtButton(
              title: actionLabel!,
              onTap: onAction!,
              isSecondary: true,
              isSmall: true,
            ),
          ],
        ],
      ),
    );
  }
}
