
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A standardized subtle divider for the Boxy Art design system.
class BoxyArtDivider extends ConsumerWidget {
  final double verticalPadding;

  const BoxyArtDivider({
    super.key,
    this.verticalPadding = AppSpacing.xs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Divider(
        height: config.dividerThickness,
        thickness: config.dividerThickness,
        color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow),
      ),
    );
  }
}

/// A standardized subtle vertical divider for the Boxy Art design system.
class BoxyArtVerticalDivider extends ConsumerWidget {
  final double horizontalPadding;
  final double? height;

  const BoxyArtVerticalDivider({
    super.key,
    this.horizontalPadding = AppSpacing.xs,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        width: config.dividerThickness,
        height: height,
        color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow),
      ),
    );
  }
}
