import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';

/// Admin-only warning banner + inline form for fixing missing slope/rating/par
/// data. Returns [SizedBox.shrink] for non-admin viewers and social events.
///
/// Visibility is controlled by the caller passing [showEditor]. Typically this
/// is `true` when `onStatusChanged != null` (i.e. the viewer has staff rights).
class EventCourseDataEditor extends ConsumerWidget {
  const EventCourseDataEditor({super.key, required this.event, this.showEditor = false});
  final GolfEvent event;
  final bool showEditor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showEditor || event.eventType == EventType.social) return const SizedBox.shrink();

    final config = event.courseConfig;
    final isMissing = ((config.slope ?? 0) <= 0) || ((config.rating ?? 0) <= 0) || ((config.par ?? 0) <= 0);
    if (!isMissing) return const SizedBox.shrink();

    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return Padding(
      padding: EdgeInsets.only(top: spacing?.cardToCard ?? AppSpacing.standard),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.coral500.withValues(alpha: AppColors.opacitySubtle),
          borderRadius: AppShapes.xl,
          border: Border.all(color: AppColors.coral500.withValues(alpha: AppColors.opacityMedium)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.coral500, size: AppShapes.iconLg),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Missing Course Data',
                        style: TextStyle(
                          fontWeight: AppTypography.weightExtraBold,
                          fontSize: AppTypography.sizeBody,
                          color: AppColors.coral500,
                        ),
                      ),
                      Text(
                        'Handicaps cannot be accurately calculated.',
                        style: TextStyle(
                          fontSize: AppTypography.sizeLabelStrong,
                          color: AppColors.coral500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _CourseDataForm(event: event),
          ],
        ),
      ),
    );
  }
}

class _CourseDataForm extends ConsumerWidget {
  const _CourseDataForm({required this.event});
  final GolfEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = event.courseConfig;
    final slopeCtrl  = TextEditingController(text: config.slope?.toString() ?? '');
    final ratingCtrl = TextEditingController(text: config.rating?.toString() ?? '');
    final parCtrl    = TextEditingController(text: config.par?.toString() ?? '');

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MiniInput(label: 'Slope',  controller: slopeCtrl)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _MiniInput(label: 'Rating', controller: ratingCtrl)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _MiniInput(label: 'Par',    controller: parCtrl)),
          ],
        ),
        const SizedBox(height: AppSpacing.standard),
        BoxyArtButton(
          title: 'Apply Course Updates',
          isPrimary: true,
          onTap: () async {
            final updatedConfig = event.courseConfig.copyWith(
              slope:  (double.tryParse(slopeCtrl.text)  ?? 113).toInt(),
              rating:  double.tryParse(ratingCtrl.text) ?? 72.0,
              par:    (double.tryParse(parCtrl.text)    ?? 72).toInt(),
            );
            await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(courseConfig: updatedConfig));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Course data updated! Scroll to Grouping to Recalculate HCPs.')),
              );
            }
          },
        ),
      ],
    );
  }
}

class _MiniInput extends StatelessWidget {
  const _MiniInput({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTypography.sizeCaption,
            fontWeight: AppTypography.weightBold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: AppShapes.md,
            border: Border.all(color: AppColors.dark300),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontWeight: AppTypography.weightBold,
              fontSize: AppTypography.sizeBody,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }
}
