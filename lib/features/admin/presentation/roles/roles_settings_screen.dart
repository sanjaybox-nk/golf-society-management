import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/member.dart';

class RolesSettingsScreen extends ConsumerWidget {
  const RolesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Define descriptions for display
    final roleDescriptions = {
      MemberRole.superAdmin: 'Full access to all system features and settings.',
      MemberRole.admin: 'Can manage members, events, and results.',
      MemberRole.restrictedAdmin: 'Limited management rights (e.g., manage specific events).',
      MemberRole.viewer: 'Read-only access to all data.',
      MemberRole.member: 'Standard member access (App User).',
    };

    final roles = MemberRole.values;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: const BoxyArtAppBar(title: 'System Roles', showBack: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: roles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final role = roles[index];
          
          // Skip Standard Member (as requested)
          if (role == MemberRole.member) return const SizedBox.shrink();

          final description = roleDescriptions[role] ?? '';
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  // Navigate to role members screen with role index
                  context.push('/admin/settings/roles/members/${role.index}');
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Role Icon/Badge
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
                      
                      // Role Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getRoleDisplayName(role),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Chevron
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
