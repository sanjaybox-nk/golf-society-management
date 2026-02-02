import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/theme/theme_controller.dart';

import '../../../../core/theme/contrast_helper.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimary = ContrastHelper.getContrastingText(primaryColor);

    return Scaffold(
      appBar: BoxyArtAppBar(
        title: 'General Settings',
        subtitle: 'Manage app-wide defaults',
        isLarge: true,
        leadingWidth: 70,
        leading: Center(
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text('Back', style: TextStyle(color: onPrimary, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          const BoxyArtSectionTitle(
            title: 'Localisation',
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
          ),
          BoxyArtFloatingCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.currency_exchange,
                  title: 'Currency',
                  subtitle: '${config.currencyCode} (${config.currencySymbol})',
                  iconColor: Colors.green,
                  onTap: () => context.push('/admin/settings/general/currency'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          const BoxyArtSectionTitle(
            title: 'Competition Settings',
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
          ),
          BoxyArtFloatingCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.groups_3_outlined,
                  title: 'Grouping Strategy',
                  subtitle: _getStrategyLabel(config.groupingStrategy),
                  iconColor: Colors.indigo,
                  onTap: () => context.push('/admin/settings/general/grouping-strategy'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const BoxyArtSectionTitle(
            title: 'App Info',
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
          ),
          BoxyArtFloatingCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'Version',
                  subtitle: '1.0.0 (Build 61)',
                  iconColor: Colors.grey,
                ),
                _SettingsTile(
                  icon: Icons.devices,
                  title: 'Platform',
                  subtitle: Theme.of(context).platform.name.toUpperCase(),
                  iconColor: Colors.blueGrey,
                ),
              ],
            ),
          ),
        ],
      ),
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
      trailing: onTap != null ? const Icon(Icons.chevron_right, color: Colors.grey, size: 20) : null,
    );
  }
}
