import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';

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
      autoPrefix: false,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ...roles.map((role) {
                if (role == MemberRole.member) return const SizedBox.shrink();
                final description = roleDescriptions[role] ?? '';
                final isDark = Theme.of(context).brightness == Brightness.dark;
                const identityColor = Colors.purple;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BoxyArtCard(
                    onTap: () => context.push('/admin/settings/roles/members/${role.index}'),
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        // High Impact Circular Icon Container (56x56)
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: identityColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getRoleIcon(role),
                            color: identityColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getRoleDisplayName(role).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: isDark ? AppColors.pureWhite : AppColors.dark900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.dark300 : AppColors.dark400,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded, 
                          color: isDark ? AppColors.dark400 : AppColors.dark300,
                          size: 20,
                        ),
                      ],
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
}
