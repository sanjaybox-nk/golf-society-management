import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/services/seeding_service.dart';
import '../../../../features/competitions/presentation/competitions_provider.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: BoxyArtAppBar(
        title: 'Settings',
        subtitle: 'App-wide configuration',
        isLarge: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white, size: 28),
          onPressed: () => context.go('/home'),
        ),
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          const BoxyArtSectionTitle(
            title: 'Society Configurations',
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
          ),
          BoxyArtFloatingCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.badge_outlined,
                  title: 'Committee Roles',
                  subtitle: 'Manage society specific titles',
                  iconColor: const Color(0xFF1A237E), // Navy
                  onTap: () => context.push('/admin/settings/committee-roles'),
                ),
                _SettingsTile(
                  icon: Icons.rule_folder_outlined,
                  title: 'Game Templates',
                  subtitle: 'Manage competition formats & rules',
                  iconColor: Colors.orange,
                  onTap: () => context.push('/admin/settings/templates'),
                ),
                _SettingsTile(
                  icon: Icons.emoji_events_outlined,
                  title: 'Leaderboard Templates',
                  subtitle: 'Manage season point systems',
                  iconColor: Colors.amber,
                  onTap: () => context.push('/admin/settings/leaderboards'),
                ),
                _SettingsTile(
                  icon: Icons.tune,
                  title: 'General',
                  subtitle: 'App basics and display settings',
                  iconColor: Colors.grey,
                  onTap: () => context.push('/admin/settings/general'),
                ),
                _SettingsTile(
                  icon: Icons.layers_outlined,
                  title: 'Manage Seasons',
                  subtitle: 'Archive and setup event seasons',
                  iconColor: Colors.teal,
                  onTap: () => context.push('/admin/settings/seasons'),
                ),
                _SettingsTile(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  subtitle: 'Push notification preferences',
                  iconColor: Colors.grey,
                ),
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Society Branding',
                  subtitle: 'Customize colors and theme',
                  iconColor: Colors.pink,
                  onTap: () => context.push('/admin/settings/branding'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const BoxyArtSectionTitle(
            title: 'Access & Permissions',
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
          ),
          BoxyArtFloatingCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: 'System Roles',
                  subtitle: 'View available administrative roles',
                  iconColor: Colors.purple,
                  onTap: () => context.push('/admin/settings/roles'),
                ),
                _SettingsTile(
                  icon: Icons.history_outlined,
                  title: 'Audit Logs',
                  subtitle: 'View recent administrative changes',
                  iconColor: Colors.blueGrey,
                  onTap: () {
                    // Placeholder for now
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Audit Logs are coming soon!'))
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Clear Database',
                  subtitle: 'Remove all members and registrations',
                  iconColor: Colors.red,
                  onTap: () => _clearDatabase(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          
          const BoxyArtSectionTitle(
            title: 'Testing Lab',
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
          ),
          BoxyArtFloatingCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.auto_awesome_motion_outlined,
                  title: 'Seed Full Demo Data',
                  subtitle: 'Members, events, and historical scores',
                  iconColor: Colors.pinkAccent,
                  onTap: () => _seedFullDemo(context, ref),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ref.watch(templatesListProvider).when(
                    data: (templates) => BoxyArtDropdownField<String>(
                      label: 'Swap Lab Format',
                      items: templates.map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.rules.format.name.toUpperCase()),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) _swapLabFormat(context, ref, val);
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
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
      await ref.read(seedingServiceProvider).seedStableFoundation();
      messenger.showSnackBar(const SnackBar(
        content: Text('✅ Lab Ready! Check "Events" to see all 4 matches in the 2026 season.'),
        duration: Duration(seconds: 4),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }


  Future<void> _swapLabFormat(BuildContext context, WidgetRef ref, String templateId) async {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Swapping game format...')));

    try {
      await ref.read(seedingServiceProvider).swapLabEventFormat(templateId);
      messenger.showSnackBar(const SnackBar(content: Text('✅ Format Swapped! Recalculating...')));
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(subtitle, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade600)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }
}
