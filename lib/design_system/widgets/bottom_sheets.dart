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
          const Divider(height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
              child: child,
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
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.96,
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
