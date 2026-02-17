import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/models/member.dart';

class RolesSettingsScreen extends ConsumerWidget {
  const RolesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleDescriptions = {
      MemberRole.superAdmin: 'Full access to all system features and settings.',
      MemberRole.admin: 'Can manage members, events, and results.',
      MemberRole.restrictedAdmin: 'Limited management rights (e.g., manage specific events).',
      MemberRole.viewer: 'Read-only access to all data.',
      MemberRole.member: 'Standard member access (App User).',
    };

    final roles = MemberRole.values;

    return HeadlessScaffold(
      title: 'System Roles',
      subtitle: 'View available administrative roles',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ...roles.map((role) {
                if (role == MemberRole.member) return const SizedBox.shrink();
                final description = roleDescriptions[role] ?? '';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ModernCard(
                    onTap: () => context.push('/admin/settings/roles/members/${role.index}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getRoleColor(role).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getRoleIcon(role),
                              color: _getRoleColor(role),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getRoleDisplayName(role),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ]),
          ),
        ),
      ],
    );
  }

  String _getRoleDisplayName(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return 'Super Admin';
      case MemberRole.admin: return 'Admin';
      case MemberRole.restrictedAdmin: return 'Restricted Admin';
      case MemberRole.viewer: return 'Viewer';
      case MemberRole.member: return 'Standard Member';
    }
  }

  IconData _getRoleIcon(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return Icons.admin_panel_settings;
      case MemberRole.admin: return Icons.security;
      case MemberRole.restrictedAdmin: return Icons.build_circle_outlined;
      case MemberRole.viewer: return Icons.visibility_outlined;
      case MemberRole.member: return Icons.person_outline;
    }
  }

  Color _getRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return Colors.deepPurple;
      case MemberRole.admin: return Colors.blue;
      case MemberRole.restrictedAdmin: return Colors.orange;
      case MemberRole.viewer: return Colors.teal;
      case MemberRole.member: return Colors.grey;
    }
  }
}
