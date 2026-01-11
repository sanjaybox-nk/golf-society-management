import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/admin/presentation/events/event_admin_scaffold.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BoxyArtAppBar(title: 'Admin Console', showBack: true),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(24),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _AdminCard(
            title: 'Manage Events',
            subtitle: 'Schedule and results',
            icon: Icons.calendar_month,
            color: Colors.orange,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EventAdminScaffold()),
            ),
          ),
          _AdminCard(
            title: 'Manage Members',
            subtitle: 'Directory and roles',
            icon: Icons.people,
            color: Colors.blue,
            onTap: () => context.push('/admin/members'),
          ),
          _AdminCard(
            title: 'Audit Logs',
            subtitle: 'Recent changes',
            icon: Icons.history,
            color: Colors.purple,
            onTap: () {}, // Future
          ),
          _AdminCard(
            title: 'Settings',
            subtitle: 'App configuration',
            icon: Icons.settings,
            color: Colors.grey,
            onTap: () => context.push('/admin/settings'),
          ),
          _AdminCard(
            title: 'Communications',
            subtitle: 'Broadcast alerts',
            icon: Icons.notification_add,
            color: Colors.redAccent,
            onTap: () => context.push('/admin/communications'),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtFloatingCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
