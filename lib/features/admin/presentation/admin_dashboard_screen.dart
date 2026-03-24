import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/features/admin/presentation/audit_provider.dart';
import 'package:golf_society/domain/models/audit_activity.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';



import 'package:collection/collection.dart';
import 'widgets/dashboard_hero_card.dart';


class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final membersAsync = ref.watch(allMembersProvider);
    final eventsAsync = ref.watch(adminEventsProvider);

    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Admin Console',
      subtitle: 'Command Center',
      leading: Center(
        child: BoxyArtGlassIconButton(
          icon: Icons.home_rounded,
          onPressed: () => context.go('/home'),
          tooltip: 'Exit to App',
        ),
      ),
      actions: const [],
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: spacing?.labelToCard ?? AppSpacing.standard),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Next Event Hero
              eventsAsync.when(
                data: (events) {
                  final now = DateTime.now();
                  final nextEvent = events
                      .where((e) => e.date.isAfter(now) || DateUtils.isSameDay(e.date, now))
                      .sortedBy((e) => e.date)
                      .firstOrNull;
                  
                  if (nextEvent != null) {
                    return DashboardHeroCard(
                      event: nextEvent,
                      onTap: () => context.go('/admin/events/manage/${Uri.encodeComponent(nextEvent.id)}/event'),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => Text('Error loading events: $err'),
              ),


              // 1.5 Active Polls Aggregator (Relocated Phase 3)
              eventsAsync.when(
                data: (events) {
                  final activePolls = events.expand((e) => e.feedItems.where((i) => i.type == FeedItemType.poll && i.isPublished).map((item) => (e, item))).toList();
                  if (activePolls.isEmpty) return const SizedBox.shrink();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BoxyArtSectionTitle(title: 'Active Event Polls', isPeeking: true),
                      ...activePolls.asMap().entries.map((entry) {
                        final index = entry.key;
                        final pair = entry.value;
                        final event = pair.$1;
                        final poll = pair.$2;
                        return Padding(
                          padding: EdgeInsets.only(bottom: (index == activePolls.length - 1) ? 0 : (spacing?.cardToCard ?? AppSpacing.standard)),
                          child: BoxyArtCard(
                            onTap: () => context.go('/admin/events/manage/${event.id}/event'),
                            child: Row(
                              children: [
                                const Icon(Icons.poll_rounded, color: AppColors.lime500),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(poll.title ?? 'Poll', style: AppTypography.labelStrong),
                                      Text('From: ${event.title}', style: AppTypography.bodySmall),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              const BoxyArtSectionTitle(
                title: 'Quick Actions'),

              // 3. Feature Action Grid (2x2)
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 16) / 2;
                  return Wrap(
                    spacing: spacing?.labelToCard ?? AppSpacing.standard,
                    runSpacing: spacing?.labelToCard ?? AppSpacing.standard,
                    children: [
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.add_circle_outline_rounded,
                        title: 'Create Event',
                        onTap: () => context.push('/admin/events/new'),
                      ),
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.campaign_rounded,
                        title: 'Broadcasts',
                        onTap: () => _showBroadcastPicker(context, eventsAsync),
                      ),
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.person_add_alt_1_rounded,
                        title: 'Add Member',
                        onTap: () => context.push('/admin/members/new'),
                      ),
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.settings_suggest_rounded,
                        title: 'Settings',
                        onTap: () => context.push('/admin/settings'),
                      ),
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.poll_rounded,
                        title: 'Surveys',
                        onTap: () => context.go('/admin/surveys'),
                      ),
                    ],
                  );
                },
              ),

              // 4. Recent Activity Feed
              
              const _ActivityFeed(),
            ]),
          ),
        ),
      ],
    );
  }

  void _showBroadcastPicker(BuildContext context, AsyncValue<List<GolfEvent>> eventsAsync) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BroadcastEventPicker(eventsAsync: eventsAsync),
    );
  }
}

// Removed _MetricsCarousel and _PremiumMetricCard as they moved to AdminReportsScreen

class _FeatureGridItem extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _FeatureGridItem({
    required this.width,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    return SizedBox(
      width: width,
      child: BoxyArtCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.dark300.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: AppColors.dark600, size: AppShapes.iconLg),
            ),
            SizedBox(height: spacing?.labelToCard ?? AppSpacing.atomic),
            Text(
              title,
              style: AppTypography.labelStrong,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}



class _ActivityFeed extends ConsumerWidget {
  const _ActivityFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activitiesAsync = ref.watch(auditActivitiesProvider(5));

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return BoxyArtCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'No recent activity', 
                  style: AppTypography.label.copyWith(color: AppColors.textTertiary),
                ),
              ),
            ),
          );
        }

        return BoxyArtCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: activities.mapIndexed((index, activity) {
              final appearance = AuditActivity.getAppearance(activity.type);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.dark300.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(appearance.$1, color: AppColors.dark600, size: AppShapes.iconSm),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.message,
                                style: AppTypography.labelStrong,
                              ),
                              Text(
                                timeago.format(activity.timestamp),
                                style: AppTypography.bodySmall.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < activities.length - 1)
                    const BoxyArtDivider(),
                ],
              );
            }).toList(),
          ),
        );
      },
      loading: () => const BoxyArtCard(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => BoxyArtCard(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _BroadcastEventPicker extends StatelessWidget {
  final AsyncValue<List<GolfEvent>> eventsAsync;

  const _BroadcastEventPicker({required this.eventsAsync});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.r2xl)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.atomic),
          Center(
            child: Container(
              width: AppSpacing.x4l,
              height: AppSpacing.xs,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: AppColors.opacityMuted),
                borderRadius: AppShapes.grabber,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.x2l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Event',
                  style: AppTypography.displayLocker,
                ),
                SizedBox(height: AppSpacing.atomic),
                Text(
                  'Choose an event to post an update or newsletter.',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                final filteredEvents = events.where((e) {
                  return e.status != EventStatus.completed && 
                         e.status != EventStatus.cancelled &&
                         e.status != EventStatus.draft;
                }).toList();
                final sortedEvents = filteredEvents.sortedBy((e) => e.date).reversed.toList();
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, 
                    vertical: spacing?.labelToCard ?? AppSpacing.standard
                  ),
                  itemCount: sortedEvents.length,
                  itemBuilder: (context, index) {
                    final event = sortedEvents[index];
                    return BoxyArtCard(
                      margin: EdgeInsets.only(bottom: spacing?.labelToCard ?? AppSpacing.standard),
                      padding: EdgeInsets.zero,
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/admin/events/manage/${Uri.encodeComponent(event.id)}/broadcast/new');
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl, 
                          vertical: spacing?.labelToCard ?? AppSpacing.standard
                        ),
                        title: Text(
                          event.title,
                          style: AppTypography.displayLargeBody.copyWith(
                            fontSize: AppTypography.sizeBody,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, yyyy').format(event.date),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

