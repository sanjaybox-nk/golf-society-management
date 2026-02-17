import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/core/theme/theme_controller.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/models/handicap_system.dart';
import 'package:golf_society/core/services/demo_seeding_service.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);

    return HeadlessScaffold(
      title: 'General',
      subtitle: 'Manage app-wide defaults',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'Localisation', padding: EdgeInsets.zero),
              const SizedBox(height: 12),
              ModernCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.currency_exchange_rounded,
                      title: 'Currency',
                      subtitle: '${config.currencyCode} (${config.currencySymbol})',
                      iconColor: Colors.green,
                      onTap: () => context.push('/admin/settings/general/currency'),
                    ),
                    const Divider(height: 1, indent: 68),
                    _SettingsTile(
                      icon: Icons.public_rounded,
                      title: 'Handicap Provider',
                      subtitle: config.handicapSystem.shortName,
                      iconColor: Colors.blue,
                      onTap: () => context.push('/admin/settings/general/handicap-system'),
                    ),
                    const Divider(height: 1, indent: 68),
                    _SettingsTile(
                      icon: Icons.auto_graph_rounded,
                      title: 'Society Cuts',
                      subtitle: (config.enableSocietyCuts == true) ? 'Active' : 'Disabled',
                      iconColor: Colors.orange,
                      onTap: () => context.push('/admin/settings/general/society-cuts'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const BoxyArtSectionTitle(title: 'Competition Settings', padding: EdgeInsets.zero),
              const SizedBox(height: 12),
              ModernCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.groups_3_rounded,
                      title: 'Grouping Strategy',
                      subtitle: _getStrategyLabel(config.groupingStrategy),
                      iconColor: Colors.indigo,
                      onTap: () => context.push('/admin/settings/general/grouping-strategy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const BoxyArtSectionTitle(title: 'App Info', padding: EdgeInsets.zero),
              const SizedBox(height: 12),
              ModernCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Version',
                      subtitle: '1.0.0 (Build 61)',
                      iconColor: Colors.grey,
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.devices_rounded,
                      title: 'Platform',
                      subtitle: Theme.of(context).platform.name.toUpperCase(),
                      iconColor: Colors.blueGrey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const BoxyArtSectionTitle(title: 'Developer Tools', padding: EdgeInsets.zero),
              const SizedBox(height: 12),
              ModernCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.data_usage_rounded,
                      title: 'Initialize Demo Season',
                      subtitle: 'Generate 60 members & 10 full events',
                      iconColor: Colors.deepPurple,
                      onTap: () => _showSeedingDialog(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  String _getStrategyLabel(String key) {
    switch (key) {
      case 'progressive': return 'Progressive (Low HC First)';
      case 'similar': return 'Similar Ability';
      case 'random': return 'Random Draw';
      case 'balanced': default: return 'Balanced Teams';
    }
  }

  // _getStrategyDescription not needed here anymore as it's in the selection screen.
  // Picker methods removed.

  void _showSeedingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initialize Demo Season?'),
        content: const Text(
          'This will create a new "Demo Season 2026" with 60 high-fidelity members, 11 unique courses, and 10 full events. \n\nThis may take 30-60 seconds to populate Firestore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Trigger Seeding
              try {
                final seedingService = ref.read(demoSeedingServiceProvider);
                await seedingService.seedDemoSeason();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo Season Initialized Successfully!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Initialize'),
          ),
        ],
      ),
    );
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
      trailing: onTap != null ? Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).dividerColor.withValues(alpha: 0.3), size: 14) : null,
    );
  }
}
