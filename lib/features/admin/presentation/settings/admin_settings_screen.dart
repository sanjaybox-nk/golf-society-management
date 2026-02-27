import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/services/seeding_service.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HeadlessScaffold(
      title: 'Settings',
      subtitle: 'App-wide configuration',
      showBack: true,
      onBack: () => context.go('/admin'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'Society Configurations', padding: EdgeInsets.zero),
              const SizedBox(height: 12),
              BoxyArtCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.badge_rounded,
                      title: 'Committee Roles',
                      subtitle: 'Manage society specific titles',
                      iconColor: const Color(0xFF1A237E),
                      onTap: () => context.push('/admin/settings/committee-roles'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.rule_folder_rounded,
                      title: 'Game Templates',
                      subtitle: 'Manage competition formats & rules',
                      iconColor: Colors.orange,
                      onTap: () => context.push('/admin/settings/templates'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.emoji_events_rounded,
                      title: 'Leaderboard Templates',
                      subtitle: 'Manage season point systems',
                      iconColor: Colors.amber,
                      onTap: () => context.push('/admin/settings/leaderboards'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.tune_rounded,
                      title: 'General',
                      subtitle: 'App basics and display settings',
                      iconColor: Colors.blueGrey,
                      onTap: () => context.push('/admin/settings/general'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.layers_rounded,
                      title: 'Manage Seasons',
                      subtitle: 'Archive and setup event seasons',
                      iconColor: Colors.teal,
                      onTap: () => context.push('/admin/settings/seasons'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      title: 'Notifications',
                      subtitle: 'Push notification preferences',
                      iconColor: Colors.indigo,
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.palette_rounded,
                      title: 'Society Branding',
                      subtitle: 'Customize colors and theme',
                      iconColor: Colors.pink,
                      onTap: () => context.push('/admin/settings/branding'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const BoxyArtSectionTitle(title: 'Access & Permissions', padding: EdgeInsets.zero),
              const SizedBox(height: 12),
              BoxyArtCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.shield_rounded,
                      title: 'System Roles',
                      subtitle: 'View available administrative roles',
                      iconColor: Colors.purple,
                      onTap: () => context.push('/admin/settings/roles'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.history_rounded,
                      title: 'Audit Logs',
                      subtitle: 'View recent administrative changes',
                      iconColor: Colors.blueGrey,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Audit Logs are coming soon!'))
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.delete_forever_rounded,
                      title: 'Clear Database',
                      subtitle: 'Remove all members and registrations',
                      iconColor: Colors.red,
                      onTap: () => _clearDatabase(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const BoxyArtSectionTitle(title: 'Initialization Tools', padding: EdgeInsets.zero),
              const SizedBox(height: 12),
              BoxyArtCard(
                child: _SettingsTile(
                  icon: Icons.auto_awesome_motion_rounded,
                  title: 'Seed Full Demo Data',
                  subtitle: 'Populate members, events, and results',
                  iconColor: Colors.pinkAccent,
                  onTap: () => _seedFullDemo(context, ref),
                ),
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _seedFullDemo(BuildContext context, WidgetRef ref) async {
    final confirm = await showBoxyArtDialog<bool>(
      context: context, 
      title: 'Initialize Lab?',
      message: 'This will seed 60 members (inc. Committee), 3 past events (Jan/Feb 2026), and 1 upcoming event (The Lab Open). All within the current 2026 season. Continue?',
      confirmText: 'Initialize',
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    );
    
    if (confirm != true) return;

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Building Lab foundation... (Members & Events)')));

    try {
      await ref.read(seedingServiceProvider).seedFullDemoData();
      messenger.showSnackBar(const SnackBar(
        content: Text('✅ Lab Ready! Check "Events" to see all 4 matches in the 2026 season.'),
        duration: Duration(seconds: 4),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }




  Future<void> _clearDatabase(BuildContext context, WidgetRef ref) async {
    // High-risk confirmation
    final confirm = await showBoxyArtDialog<bool>(
      context: context, 
      title: 'DANGER: Clear Database?',
      message: 'This will PERMANENTLY delete ALL society data (Members, Events, Scores, Standings). There is no undo. Continue?',
      confirmText: 'PURGE EVERYTHING',
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    );
    
    if (confirm != true) return;

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Starting full database purge... 🧹')));

    try {
      await ref.read(seedingServiceProvider).clearAllData();
      messenger.showSnackBar(const SnackBar(content: Text('✅ Clean Slate Achieved! All collections wiped.')));
    } catch (e) {
      debugPrint('❌ Error clearing database: $e');
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}


class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.3),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle, 
          style: TextStyle(
            fontSize: 13, 
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).dividerColor.withValues(alpha: 0.3), size: 14),
    );
  }
}
