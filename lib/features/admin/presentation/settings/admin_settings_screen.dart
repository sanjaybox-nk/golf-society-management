import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: const BoxyArtAppBar(title: 'Settings', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SettingsGroup(
            title: 'ACCESS & PERMISSIONS',
            children: [
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'System Roles',
                subtitle: 'View available administrative roles',
                iconColor: Colors.purple,
                onTap: () => context.push('/admin/settings/roles'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _SettingsGroup(
            title: 'APP CONFIGURATION',
            children: [
              _SettingsTile(
                icon: Icons.tune,
                title: 'General',
                subtitle: 'App basics and display settings',
                iconColor: Colors.grey,
                // onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                subtitle: 'Push notification preferences',
                iconColor: Colors.grey,
                // onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.badge_outlined,
                title: 'Committee Roles',
                subtitle: 'Manage society specific titles',
                iconColor: const Color(0xFF1A237E), // Navy
                onTap: () => context.push('/admin/settings/committee-roles'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast) 
                    Divider(height: 1, indent: 56, color: Colors.grey.shade100),
                ],
              );
            }).toList(),
          ),
        ),
      ],
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
        child: Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }
}
