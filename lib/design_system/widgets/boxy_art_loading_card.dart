import 'package:golf_society/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A premium, localized loading placeholder for Design 4.x ("Fairway").
/// Replaces legacy centered spinners with a top-aligned, card-based loading state
/// that maintains vertical rhythm and respects the page headers/titles.
class BoxyArtLoadingCard extends ConsumerWidget {
  final String title;
  final String? message;
  final bool isCompact;
  final EdgeInsets? padding;
  final bool useCard;

  const BoxyArtLoadingCard({
    super.key,
    this.title = 'Loading...',
    this.message,
    this.isCompact = false,
    this.padding,
    this.useCard = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final innerPadding = padding ?? (isCompact ? const EdgeInsets.all(AppSpacing.lg) : const EdgeInsets.all(AppSpacing.xl));
    final headerGap = isCompact ? AppSpacing.md : AppSpacing.lg;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Sleek Localized Spinner
        SizedBox(
          width: isCompact ? 24 : 32,
          height: isCompact ? 24 : 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
        
        SizedBox(height: headerGap),
        
        // 2. Headline
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.labelStrong.copyWith(
            fontSize: isCompact ? 14 : 16,
            letterSpacing: 0.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        if (message != null) ...[
          const SizedBox(height: 4),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.dark300 : AppColors.dark400,
              height: 1.4,
            ),
          ),
        ],
      ],
    );

    if (!useCard) return content;

    return BoxyArtCard(
      padding: innerPadding,
      child: content,
    );
  }
}
