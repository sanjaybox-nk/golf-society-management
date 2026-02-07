import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/core/services/seeding_service.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart'; // Added this import

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void _showMemberPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(24),
                child: BoxyArtSectionTitle(title: 'Select Member to Peek'),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final membersAsync = ref.watch(allMembersProvider);
                    return membersAsync.when(
                      data: (members) => ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: members.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              child: Text(
                                member.firstName[0],
                                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(member.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('HC: ${member.handicap}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ref.read(impersonationProvider.notifier).set(member);
                              Navigator.pop(context); // Close picker
                              context.go('/home'); // High-level navigation
                            },
                          );
                        },
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                    const Divider(height: 32),
                    _DashboardActionTile(
                      icon: Icons.visibility_outlined,
                      title: 'Peek as Member',
                      subtitle: 'Experience the app as a regular member',
                      color: Colors.amber,
                      onTap: () => _showMemberPicker(context, ref),
                    ),
                    const Divider(height: 32),
                    _DashboardActionTile(
                      icon: Icons.auto_awesome_motion_outlined,
                      title: 'Seed Full Demo Data',
                      subtitle: 'Re-populate society with members, events, and scores',
                      color: Colors.pinkAccent,
                      onTap: () async {
                        try {
                          final seeding = ref.read(seedingServiceProvider);
                          await seeding.seedStableFoundation();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Society seeded with full demo data!'))
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Seeding failed: $e'))
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 32),
                    _DashboardActionTile(
                      icon: Icons.cloud_download_outlined,
                      title: 'Initialize Core Data',
                      subtitle: 'Seed courses and templates only',
                      color: Colors.teal,
                      onTap: () async {
                        try {
                          final seeding = ref.read(seedingServiceProvider);
                          await seeding.seedInitialData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Core data initialized successfully!'))
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Initialization failed: $e'))
                            );
                          }
                        }
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
