import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';

import 'widgets/form_sections/event_type_section.dart';
import 'widgets/form_sections/event_basic_info_section.dart';
import 'widgets/form_sections/event_logistics_section.dart';
import 'widgets/form_sections/event_course_section.dart';
import 'widgets/form_sections/event_competition_section.dart';
import 'widgets/form_sections/event_content_section.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  final GolfEvent? event;
  final String? eventId;

  const EventFormScreen({super.key, this.event, this.eventId});

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventFormNotifierProvider.notifier).initialize((widget.event, widget.eventId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(eventFormNotifierProvider);

    return stateAsync.when(
      data: (state) => HeadlessScaffold(
        title: state.eventId != null ? 'Event Settings' : 'Create Event',
        subtitle: state.eventId != null ? (state.initialEvent?.title ?? 'Update Details') : 'Create a new society event',
        leadingWidth: 70,
        leading: Center(
          child: BoxyArtGlassIconButton(
            icon: state.eventId != null ? Icons.arrow_back_rounded : Icons.close_rounded,
            iconSize: 24,
            onPressed: () => context.go('/admin/events'),
          ),
        ),
        actions: [
          if (state.isSaving)
            const SizedBox(
              width: AppSpacing.x4l,
              height: AppSpacing.x4l,
              child: Center(
                child: SizedBox(
                  width: AppSpacing.xl,
                  height: AppSpacing.xl,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            BoxyArtGlassIconButton(
              icon: Icons.check_rounded,
              iconSize: 22,
              onPressed: () => ref.read(eventFormNotifierProvider.notifier).save().then((success) {
                if (success && context.mounted) {
                  context.pop();
                }
              }),
              tooltip: 'Save',
            ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EventTypeSection(isPeeking: true),
                  const EventLogisticsSection(), 
                  const EventBasicInfoSection(),
                  const EventCourseSection(),
                  const EventCompetitionSection(),
                  const EventContentSection(),
                  const SizedBox(height: AppSpacing.pageBottom),
                ],
              ),
            ),
          ),
        ],
      ),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, stack) => Scaffold(
        body: BoxyArtEmptyState(
          title: 'Error Loading Form',
          message: e.toString(),
          icon: Icons.error_outline,
          actionLabel: 'Go Back',
          onAction: () => context.pop(),
        ),
      ),
    );
  }
}
