import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_state.dart';

import 'widgets/form_sections/event_type_section.dart';
import 'widgets/form_sections/event_basic_info_section.dart';
import 'widgets/form_sections/event_logistics_section.dart';
import 'widgets/form_sections/event_course_section.dart';
import 'widgets/form_sections/event_competition_section.dart';
import 'widgets/form_sections/event_content_section.dart';
import 'widgets/form_sections/event_pricing_section.dart';
import 'widgets/form_sections/event_awards_section.dart';

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
      data: (state) {
        final spacing = Theme.of(context).extension<AppSpacingTokens>();
        return HeadlessScaffold(
        title: state.eventId != null ? 'Event Settings' : 'Create Event',
        subtitle: state.eventId != null ? (state.initialEvent?.title ?? 'Update Details') : 'Create a new society event',
        titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
        leadingWidth: 70,
        leading: Center(
          child: BoxyArtGlassIconButton(
            icon: state.eventId != null ? Icons.arrow_back_rounded : Icons.close_rounded,
            iconSize: 24,
            onPressed: () => context.go('/admin/events'),
          ),
        ),
        actions: [
          const SizedBox(width: AppSpacing.md),
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
              padding: EdgeInsets.symmetric(horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.lg),
              child: AnimatedSwitcher(
                duration: AppAnimations.medium,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: state.eventType == EventType.golf 
                  ? _GolfFormBody(key: const ValueKey('golf'), state: state)
                  : _SocialFormBody(key: const ValueKey('social'), state: state),
              ),
            ),
          ),
        ],
      );
    },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: BoxyArtEmptyCard(
              title: 'Error Loading Form',
              message: e.toString(),
              icon: Icons.error_outline,
              actionLabel: 'Go Back',
              onAction: () => context.pop(),
            ),
          ),
        ),
      ),
    );
  }
}

class _GolfFormBody extends StatelessWidget {
  final EventFormState state;

  const _GolfFormBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return const BoxyArtFormColumn(
      children: [
        EventTypeSection(isPeeking: true),
        EventLogisticsSection(),
        EventBasicInfoSection(),
        EventCourseSection(),
        EventCompetitionSection(),
        EventPricingSection(),
        EventAwardsSection(),
        EventContentSection(),
      ],
    );
  }
}

class _SocialFormBody extends StatelessWidget {
  final EventFormState state;

  const _SocialFormBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return const BoxyArtFormColumn(
      children: [
        EventTypeSection(isPeeking: true),
        // Social events often prioritize the concept/info and costs
        EventBasicInfoSection(),
        EventPricingSection(),
        EventLogisticsSection(),
        EventContentSection(),
      ],
    );
  }
}
