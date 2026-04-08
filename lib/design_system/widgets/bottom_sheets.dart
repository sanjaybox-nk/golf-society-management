import 'package:golf_society/design_system/design_system.dart';

/// Standard branded bottom sheet for Golf Society v3.1.
class BoxyArtBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final ScrollController? scrollController;

  const BoxyArtBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.r2xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          // Grab Handle
          Container(
            width: AppSpacing.x4l,
            height: AppSpacing.xs,
            decoration: BoxDecoration(
              color: AppColors.dark400.withValues(alpha: AppColors.opacityMedium),
              borderRadius: AppShapes.grabber,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.displayHeading.copyWith(
                      fontSize: AppTypography.sizeDisplaySection,
                      color: isDark ? AppColors.pureWhite : AppColors.dark600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: AppShapes.iconLg),
                  onPressed: () => Navigator.pop(context),
                  color: isDark ? AppColors.dark200 : AppColors.dark400,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Content
          Flexible(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.x2l,
                AppSpacing.xl,
                AppSpacing.x2l, // Standard bottom breathing room (SafeArea handles device inset)
              ),
              child: SafeArea(
                top: false,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to show the bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    bool isScrollControlled = true,
    // Default to false so the Global bottom nav bar remains visible behind the sheet.
    // Set to true only if the sheet must appear above everything (e.g. root-level alerts).
    bool useRootNavigator = false,
    double initialChildSize = 0.68,
    double minChildSize = 0.5,
    double maxChildSize = 0.80,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        builder: (context, scrollController) => BoxyArtBottomSheet(
          title: title,
          scrollController: scrollController,
          child: child,
        ),
      ),
    );
  }
}
