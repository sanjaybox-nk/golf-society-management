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

    return HeadlessScaffold(
      title: 'Admin Console',
      autoPrefix: false,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                      onTap: () => context.go('/admin/events/manage/${Uri.encodeComponent(nextEvent.id)}/home'),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => Text('Error loading events: $err'),
              ),

              const BoxyArtSectionTitle(
                title: 'Quick Actions',),

              // 3. Feature Action Grid (2x2)
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 16) / 2;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.add_circle_outline_rounded,
                        title: 'Create Event',
                        color: Colors.green,
                        onTap: () => context.push('/admin/events/new'),
                      ),
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.campaign_rounded,
                        title: 'Broadcasts',
                        color: Colors.pink,
                        onTap: () => _showBroadcastPicker(context, eventsAsync),
                      ),
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.person_add_alt_1_rounded,
                        title: 'Add Member',
                        color: Colors.blue,
                        onTap: () => context.push('/admin/members/new'),
                      ),
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.settings_suggest_rounded,
                        title: 'Settings',
                        color: Colors.orange,
                        onTap: () => context.push('/admin/settings'),
                      ),
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.poll_rounded,
                        title: 'Surveys',
                        color: Colors.amber,
                        onTap: () => context.go('/admin/surveys'),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // 4. Recent Activity Feed
              const BoxyArtSectionTitle(
                title: 'Recent Activity',),
              
              const _ActivityFeed(),

              const SizedBox(height: 100),
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
  final Color color;
  final VoidCallback onTap;

  const _FeatureGridItem({
    required this.width,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.label.copyWith(fontSize: 13),
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
          return const BoxyArtCard(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text('No recent activity', style: TextStyle(color: Colors.grey)),
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
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: appearance.$2.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          child: Icon(appearance.$1, color: appearance.$2, size: 18),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.message,
                                style: AppTypography.label.copyWith(fontSize: 13),
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
                    Divider(
                      height: 1, 
                      indent: 64, 
                      color: theme.dividerColor.withValues(alpha: 0.05),
                    ),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Event',
                  style: AppTypography.displayHeading.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
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
                final sortedEvents = events.sortedBy((e) => e.date).reversed.toList();
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: sortedEvents.length,
                  itemBuilder: (context, index) {
                    final event = sortedEvents[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/admin/events/manage/${Uri.encodeComponent(event.id)}/broadcast/new');
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        title: Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, yyyy').format(event.date),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
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

