import 'package:flutter_riverpod/flutter_riverpod.dart';


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
      leading: null,
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
                color: AppColors.pureWhite.withOpacity(0.70),
                fontSize: AppTypography.sizeLabelStrong,
                fontWeight: AppTypography.weightMedium,
              ),
            ),
          ],
        ],
      ),
      actions: const [],
    );
  }
}
