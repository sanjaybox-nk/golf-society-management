import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(allMembersProvider);
    final eventsAsync = ref.watch(adminEventsProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: beigeBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        const Text(
                          'Admin Console',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.settings_rounded, color: primary, size: 24),
                          onPressed: () => context.push('/admin/settings'),
                        ),
                      ],
                    ),
                    Text(
                      'Command Center',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: ModernMetricStat(
                            label: 'MEMBERS',
                            value: membersAsync.when(
                              data: (members) => members.length.toString(),
                              loading: () => '...',
                              error: (err, stack) => '!',
                            ),
                            icon: Icons.people_rounded,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernMetricStat(
                            label: 'EVENTS',
                            value: eventsAsync.when(
                              data: (events) => events.length.toString(),
                              loading: () => '...',
                              error: (err, stack) => '!',
                            ),
                            icon: Icons.calendar_month_rounded,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    const BoxyArtSectionTitle(
                      title: 'Quick Actions',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    
                    ModernCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _DashboardActionTile(
                            icon: Icons.add_circle_outline_rounded,
                            title: 'Create New Event',
                            subtitle: 'Schedule a future society day',
                            color: Colors.green,
                            onTap: () => context.push('/admin/events/new'),
                          ),
                          const Divider(height: 24, indent: 56),
                          _DashboardActionTile(
                            icon: Icons.person_add_alt_1_rounded,
                            title: 'Add New Member',
                            subtitle: 'Onboard a new society member',
                            color: Colors.blue,
                            onTap: () => context.push('/admin/members/new'),
                          ),
                          const Divider(height: 24, indent: 56),
                          _DashboardActionTile(
                            icon: Icons.bar_chart_rounded,
                            title: 'Global Reports',
                            subtitle: 'Financials and participation overview',
                            color: Colors.purple,
                            onTap: () {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Global Reports is coming soon'))
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          
          // Back Button sticky
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.home_rounded, size: 20, color: Colors.black87),
                        onPressed: () => context.go('/home'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _DashboardActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 20),
        ],
      ),
    );
  }
}
