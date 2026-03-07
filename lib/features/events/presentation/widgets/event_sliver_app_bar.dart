import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';


import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';


class EventSliverAppBar extends ConsumerWidget {
  final GolfEvent event;
  final String title;
  final String? subtitle;
  final bool isPreview;
  final VoidCallback? onCancel;

  const EventSliverAppBar({
    super.key,
    required this.event,
    required this.title,
    this.subtitle,
    this.isPreview = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {




    return SliverAppBar(
      backgroundColor: Theme.of(context).primaryColor,
      toolbarHeight: 100.0,
      pinned: true,
      automaticallyImplyLeading: false,
      centerTitle: true,
      leadingWidth: 70,
      leading: Center(
        child: IconButton(
          icon: const Icon(Icons.home, color: AppColors.pureWhite),
          onPressed: () => context.go('/home'),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.pureWhite,
              fontWeight: AppTypography.weightBold,
              fontSize: AppTypography.sizeDisplaySection,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: TextStyle(
                color: AppColors.pureWhite.withValues(alpha: 0.70),
                fontSize: AppTypography.sizeLabelStrong,
                fontWeight: AppTypography.weightMedium,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (isPreview)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Container(
              width: AppSpacing.x4l,
              height: AppSpacing.x4l,
              decoration: BoxDecoration(
                color: AppColors.pureWhite.withValues(alpha: AppColors.opacityLow),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.pureWhite.withValues(alpha: AppColors.opacityMedium),
                  width: AppShapes.borderThin,
                ),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    iconSize: 20,
                    color: AppColors.pureWhite,
                    onPressed: () => context.push('/admin/events/manage/${Uri.encodeComponent(event.id)}/event'),
                    padding: EdgeInsets.zero,
                    tooltip: 'Edit Event',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
