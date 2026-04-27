import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../members/presentation/members_provider.dart';



class CommitteeRolesScreen extends ConsumerStatefulWidget {
  const CommitteeRolesScreen({super.key});

  @override
  ConsumerState<CommitteeRolesScreen> createState() => _CommitteeRolesScreenState();
}

class _CommitteeRolesScreenState extends ConsumerState<CommitteeRolesScreen> {
  final List<String> _standardRoles = [
    'Chairman',      // Matches seeds
    'President',
    'Captain',
    'Vice Captain',
    'Secretary',
    'Treasurer',
    'Handicap Secretary',
    'Social Secretary',
  ];

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Committee Roles',
      subtitle: 'Society specific titles',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      actions: const [],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        membersAsync.when(
          data: (members) {
            final activeCustomRoles = members
                .map((m) => m.societyRole)
                .where((r) => r != null && r.isNotEmpty && !_standardRoles.any((sr) => sr.toLowerCase() == r.toLowerCase()))
                .cast<String>()
                .toSet()
                .toList();

            activeCustomRoles.sort();
            final allRoles = [..._standardRoles, ...activeCustomRoles];

            // Count members per role (case-insensitive)
            final Map<String, int> roleCounts = {};
            for (final m in members) {
              if (m.societyRole != null) {
                final matchingStandardRole = _standardRoles.firstWhereOrNull(
                  (sr) => sr.toLowerCase() == m.societyRole!.toLowerCase()
                );
                final roleKey = matchingStandardRole ?? m.societyRole!;
                roleCounts[roleKey] = (roleCounts[roleKey] ?? 0) + 1;
              }
            }

            return SliverPadding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.x4l, // Design 4.x: Standardized bottom breathing room
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const BoxyArtSectionTitle(title: 'Society Titles', isPeeking: true),
                  ...allRoles.map((role) {
                    final count = roleCounts[role] ?? 0;
                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.atomic),
                      child: _buildRoleCard(context, role, count),
                    );
                  }),
                  const SizedBox(height: AppSpacing.lg),
                  _buildCreateButton(context),
                ]),
              ),
            );
          },
          loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
        ),
      ],
    );
  }

  Widget _buildRoleCard(BuildContext context, String role, int memberCount) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final description = _getRoleDescription(role);
    final icon = _getRoleIcon(role);

    return BoxyArtCard(
      onTap: () {
        context.pushNamed('admin-committee-role-members', pathParameters: {'role': role});
      },
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          // Parity with Admin Hub and Competition Templates: Square 44px Badge
          BoxyArtIconBadge(
            icon: icon,
            size: 44,
            iconSize: 22,
            useCircle: false,
          ),
          const SizedBox(width: AppSpacing.lg),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      role.toUpperCase(),
                      style: AppTypography.labelStrong.copyWith(
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (memberCount > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      BoxyArtPill(
                        label: '$memberCount',
                        color: theme.primaryColor,
                        fontSize: AppTypography.sizeMicroSmall,
                        hasHorizontalMargin: false,
                      ),
                    ],
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.dark200 : AppColors.dark400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded, 
            color: isDark ? AppColors.dark400 : AppColors.dark200, 
            size: AppShapes.iconXs,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return BoxyArtButton(
      title: 'Create Custom Role',
      icon: Icons.add_circle_outline_rounded,
      isPrimary: false,
      onTap: () => _showCreateRoleDialog(),
    );
  }

  // --- Dialogs ---

  void _showCreateRoleDialog() {
    final controller = TextEditingController();
    showBoxyArtDialog(
      context: context,
      title: 'New Role Title',
      content: BoxyArtFormField(
        label: 'Role Title',
        hintText: 'e.g. Tour Manager',
        controller: controller,
      ),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      onConfirm: () {
        if (controller.text.trim().isNotEmpty) {
          final newRole = controller.text.trim();
          Navigator.of(context, rootNavigator: true).pop();
          context.push('/admin/settings/committee-roles/members/${Uri.encodeComponent(newRole)}');
        }
      },
      confirmText: 'Create Role',
    );
  }

  // --- Helpers ---


  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'President': return Icons.gavel;
      case 'Captain': return Icons.sports_golf;
      case 'Vice Captain': return Icons.flag;
      case 'Secretary': return Icons.library_books; // changed from edit_document for compatibility
      case 'Treasurer': return Icons.account_balance;
      default: return Icons.stars; // Default badge
    }
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case 'Chairman': return 'Overall leader of the society committee.';
      case 'President': return 'Honorary head of the society.';
      case 'Captain': return 'Leads the team and manages golf events.';
      case 'Vice Captain': return 'Supports the Captain and deputizes when needed.';
      case 'Secretary': return 'Manages administration, minutes, and membership.';
      case 'Treasurer': return 'Manages finances, payments, and accounts.';
      case 'Handicap Secretary': return 'Maintains member handicaps and WHS compliance.';
      case 'Social Secretary': return 'Organizes social events and non-golf gatherings.';
      default: return 'Custom Role';
    }
  }
}
