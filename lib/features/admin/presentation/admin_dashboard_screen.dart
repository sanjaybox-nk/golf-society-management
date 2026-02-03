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
    
    // Check for errors or loading states if needed, but the UI handles it below

    return Scaffold(
      appBar: BoxyArtAppBar(
        title: 'Admin Console',
        isLarge: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white, size: 28),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.push('/admin/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoxyArtSectionTitle(
              title: 'Command Center',
              padding: EdgeInsets.only(bottom: 16),
            ),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Members',
                    value: membersAsync.when(
                      data: (members) => members.length.toString(),
                      loading: () => '...',
                      error: (err, stack) => '!',
                    ),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Events',
                    value: eventsAsync.when(
                      data: (events) => events.length.toString(),
                      loading: () => '...',
                      error: (err, stack) => '!',
                    ),
                    icon: Icons.calendar_month,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const BoxyArtSectionTitle(
              title: 'Quick Insights',
              padding: EdgeInsets.only(bottom: 16),
            ),
            
            BoxyArtFloatingCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DashboardActionTile(
                      icon: Icons.add_circle_outline,
                      title: 'Create New Event',
                      subtitle: 'Schedule a future society day',
                      color: Colors.green,
                      onTap: () => context.push('/admin/events/new'),
                    ),
                    const Divider(height: 32),
                    _DashboardActionTile(
                      icon: Icons.person_add_alt_1_outlined,
                      title: 'Add New Member',
                      subtitle: 'Onboard a new society member',
                      color: Colors.blue,
                      onTap: () => context.push('/admin/members/new'),
                    ),
                    const Divider(height: 32),
                    _DashboardActionTile(
                      icon: Icons.bar_chart,
                      title: 'Global Reports',
                      subtitle: 'Coming Soon: Financials and participation overview',
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
            ),
            
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
              shape: BoxShape.circle,
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
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }
}
