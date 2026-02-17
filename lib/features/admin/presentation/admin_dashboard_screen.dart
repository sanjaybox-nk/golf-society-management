import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';



import 'package:collection/collection.dart';
import 'widgets/dashboard_hero_card.dart';


class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final membersAsync = ref.watch(allMembersProvider);
    final eventsAsync = ref.watch(adminEventsProvider);
    final primary = Theme.of(context).primaryColor;

    return HeadlessScaffold(
      title: 'Admin Console',
      autoPrefix: false,
      subtitle: 'Command Center',
      leading: IconButton(
        icon: Icon(Icons.home_rounded, color: primary, size: 26),
        onPressed: () => context.go('/home'),
        tooltip: 'Exit to App',
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_rounded, color: primary, size: 24),
          onPressed: () => context.push('/admin/settings'),
          tooltip: 'Admin Settings',
        ),
      ],
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
                      onTap: () => context.push('/admin/events/edit/${nextEvent.id}', extra: nextEvent),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => Text('Error loading events: $err'),
              ),

              const BoxyArtSectionTitle(
                title: 'Quick Actions',
                padding: EdgeInsets.only(bottom: 16),
              ),

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
                        icon: Icons.person_add_alt_1_rounded,
                        title: 'Add Member',
                        color: Colors.blue,
                        onTap: () => context.push('/admin/members/new'),
                      ),
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.bar_chart_rounded,
                        title: 'Reports',
                        color: Colors.purple,
                        onTap: () => context.push('/admin/reports'),
                      ),
                      _FeatureGridItem(
                        width: cardWidth,
                        icon: Icons.settings_suggest_rounded,
                        title: 'Settings',
                        color: Colors.orange,
                        onTap: () => context.push('/admin/settings'),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // 4. Recent Activity Feed
              const BoxyArtSectionTitle(
                title: 'Recent Activity',
                padding: EdgeInsets.only(bottom: 16),
              ),
              
              const _ActivityFeed(),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
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
      child: ModernCard(
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        border: BorderSide(color: color.withValues(alpha: 0.05)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock activity items for now
    final activities = [
      ('John Doe registered for The Open', '2 mins ago', Icons.person_add_rounded, Colors.blue),
      ('Scorecard submitted for Sunset Classic', '15 mins ago', Icons.sports_score_rounded, Colors.green),
      ('Payment confirmed for Mike Smith', '1 hour ago', Icons.payments_rounded, Colors.orange),
      ('New event "Spring Scramble" published', '3 hours ago', Icons.campaign_rounded, Colors.purple),
    ];

    return ModernCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: activities.mapIndexed((index, item) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.$4.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.$3, color: item.$4, size: 18),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            item.$2,
                            style: TextStyle(
                              fontSize: 11,
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
                const Divider(height: 1, indent: 64),
            ],
          );
        }).toList(),
      ),
    );
  }
}
