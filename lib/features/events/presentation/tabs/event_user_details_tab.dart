import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import '../events_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../competitions/presentation/widgets/competition_shared_widgets.dart';
import '../widgets/event_info_sections.dart';
import '../widgets/event_notifications_feed.dart';
import '../widgets/event_course_data_editor.dart';

enum EventInfoSubTab { info, notifications }

class EventUserDetailsTab extends ConsumerWidget {
  final String eventId;
  final bool useScaffold;
  final bool isAdminMode;

  const EventUserDetailsTab({super.key, required this.eventId, this.useScaffold = true, this.isAdminMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));

    return eventAsync.when(
      data: (event) {
        final config = ref.watch(themeControllerProvider);
        final user = ref.watch(effectiveUserProvider);

        bool isPreview = false;
        try {
          isPreview = GoRouterState.of(context).uri.queryParameters['preview'] == 'true';
        } catch (_) {}

        return EventDetailsContent(
          event: event,
          currencySymbol: config.currencySymbol,
          isPreview: isPreview,
          isAdminMode: isAdminMode,
          onStatusChanged: (user.role != MemberRole.member)
              ? (newStatus) => ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(status: newStatus))
              : null,
        );
      },
      loading: () => HeadlessScaffold(
        title: 'Loading Event...',
        showBack: true,
        onBack: () => context.go('/events'),
        slivers: const [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))],
      ),
      error: (err, _) => HeadlessScaffold(
        title: 'Event Error',
        showBack: true,
        onBack: () => context.go('/events'),
        slivers: [
          SliverFillRemaining(
            child: BoxyArtEmptyState(
              title: 'Could not load event',
              message: err.toString(),
              icon: Icons.error_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailsContent extends ConsumerStatefulWidget {
  final GolfEvent event;
  final String currencySymbol;
  final bool isPreview;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;
  final ValueChanged<EventStatus>? onStatusChanged;
  final Widget? bottomNavigationBar;
  final bool useScaffold;
  final bool isAdminMode;
  final Competition? competition;

  const EventDetailsContent({
    super.key,
    required this.event,
    required this.currencySymbol,
    this.isPreview = false,
    this.onCancel,
    this.onEdit,
    this.onStatusChanged,
    this.bottomNavigationBar,
    this.useScaffold = true,
    this.isAdminMode = false,
    this.competition,
  });

  @override
  ConsumerState<EventDetailsContent> createState() => _EventDetailsContentState();
}

class _EventDetailsContentState extends ConsumerState<EventDetailsContent> {
  EventInfoSubTab _selectedTab = EventInfoSubTab.notifications;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final user = ref.watch(effectiveUserProvider);
    final isStaff = user.role != MemberRole.member;
    final event = widget.event;
    final sym = widget.currencySymbol;

    return HeadlessScaffold(
      title: event.title,
      subtitle: 'Event Info Hub',
      topPill: widget.isAdminMode ? BoxyArtPill.committee(label: 'ADMIN') : null,
      showAdminShortcut: false,
      leading: widget.isPreview
          ? Center(
              child: BoxyArtGlassIconButton(
                icon: Icons.close_rounded,
                iconSize: 24,
                onPressed: () => widget.onCancel != null ? widget.onCancel!() : Navigator.of(context).pop(),
              ),
            )
          : null,
      showBack: true,
      onBack: () {
        if (widget.isPreview && widget.onCancel != null) { widget.onCancel!(); return; }
        widget.isAdminMode ? context.go('/admin/events') : context.go('/events');
      },
      actions: [
        if (!widget.isPreview && widget.isAdminMode && isStaff && _selectedTab == EventInfoSubTab.info) ...[
          if (widget.onEdit != null)
            BoxyArtGlassIconButton(
              icon: Icons.edit_rounded,
              iconSize: 24,
              onPressed: widget.onEdit,
              tooltip: 'Edit Event Settings',
            )
          else
            BoxyArtGlassIconButton(
              icon: Icons.edit_rounded,
              iconSize: 24,
              onPressed: () => context.pushNamed('admin-event-edit', pathParameters: {'id': event.id}, extra: event),
              tooltip: 'Edit Event Basics',
            ),
        ],
      ],
      slivers: [
        SliverToBoxAdapter(
          child: ModernUnderlinedFilterBar<EventInfoSubTab>(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            isExpanded: true,
            tabs: const [
              ModernFilterTab(label: 'News updates', value: EventInfoSubTab.notifications, icon: Icons.newspaper_rounded),
              ModernFilterTab(label: 'Event Info',   value: EventInfoSubTab.info,          icon: Icons.info_outline_rounded),
            ],
            selectedValue: _selectedTab,
            onTabSelected: (tab) => setState(() => _selectedTab = tab),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: spacing?.tabToContent ?? AppSpacing.tabToContent),
              if (_selectedTab == EventInfoSubTab.info) ...[
                EventDateTimeSection(event: event),
                SizedBox(height: spacing?.cardToLabel ?? AppSpacing.sectionTitleTop),
                EventHeroSection(event: event),
                if (event.eventType == EventType.golf) ...[
                  EventCourseSelectionSection(event: event),
                  EventCourseDataEditor(event: event, showEditor: widget.onStatusChanged != null),
                ],
                if ((event.status == EventStatus.published ||
                     event.status == EventStatus.inPlay ||
                     event.status == EventStatus.completed) &&
                    event.eventType == EventType.golf)
                  CompetitionRulesCard(
                    eventId: event.id,
                    title: 'Competition Rules',
                    competition: widget.competition,
                  ),
                EventPlayingCostsSection(event: event, currencySymbol: sym),
                EventMealDetailsSection(event: event, currencySymbol: sym),
                EventFacilitiesSection(event: event),
                EventAwardsSection(event: event, currencySymbol: sym),
                EventNotesSection(event: event),
              ] else ...[
                EventNotificationsFeed(event: event),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}
