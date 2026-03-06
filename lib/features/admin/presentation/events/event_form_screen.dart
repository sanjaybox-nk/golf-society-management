import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_state.dart';
import 'package:golf_society/features/events/presentation/tabs/event_user_details_tab.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:collection/collection.dart';

import 'widgets/form_sections/event_basic_info_section.dart';
import 'widgets/form_sections/event_logistics_section.dart';
import 'widgets/form_sections/event_course_section.dart';
import 'widgets/form_sections/event_competition_section.dart';
import 'widgets/form_sections/event_pricing_section.dart';
import 'widgets/form_sections/event_awards_section.dart';
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
          BoxyArtGlassIconButton(
            icon: Icons.visibility_rounded,
            iconSize: 22,
            onPressed: () => _showPreview(context, ref, state),
            tooltip: 'Preview',
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: state.isSaving 
              ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : BoxyArtGlassIconButton(
                  icon: Icons.check_rounded,
                  iconSize: 22,
                  onPressed: () => ref.read(eventFormNotifierProvider.notifier).save().then((success) {
                    if (success && context.mounted) {
                      context.pop();
                    }
                  }),
                  tooltip: 'Save',
                ),
          ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EventBasicInfoSection(),
                  const EventLogisticsSection(),
                  const EventCourseSection(),
                  const EventCompetitionSection(),
                  const EventPricingSection(),
                  const EventAwardsSection(),
                  const EventContentSection(),
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

  void _showPreview(BuildContext context, WidgetRef ref, EventFormState state) {
    // Construct a temporary event object from state for preview
    final notifier = ref.read(eventFormNotifierProvider.notifier);
    final mockEvent = notifier.constructPreviewEvent(); // I need to add this method
    
    final templates = ref.read(templatesListProvider).value;
    final selectedTemplate = templates?.firstWhereOrNull((t) => t.id == state.selectedTemplateId);
    final mockComp = state.eventCompetition ?? selectedTemplate;

    final config = ref.read(themeControllerProvider);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return EventDetailsContent(
          event: mockEvent,
          currencySymbol: config.currencySymbol,
          isPreview: true,
          competition: mockComp,
          onCancel: () => Navigator.pop(context),
        );
      },
    );
  }
}
