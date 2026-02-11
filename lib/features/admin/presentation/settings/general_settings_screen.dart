import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/theme/theme_controller.dart';



class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: beigeBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'General',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Manage app-wide defaults',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
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
                    const SizedBox(height: 100),
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
                        icon: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
                        onPressed: () => context.pop(),
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
