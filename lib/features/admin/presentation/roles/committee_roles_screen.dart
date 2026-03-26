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

    return HeadlessScaffold(
      title: 'Committee Roles', // Retained original title as widget.role is not defined here
      subtitle: 'Society specific titles', // Retained original subtitle as widget.role is not defined here
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
                // Find matching standard role or use actual role if custom
                final matchingStandardRole = _standardRoles.firstWhereOrNull(
                  (sr) => sr.toLowerCase() == m.societyRole!.toLowerCase()
                );
                final roleKey = matchingStandardRole ?? m.societyRole!;
                roleCounts[roleKey] = (roleCounts[roleKey] ?? 0) + 1;
              }
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const BoxyArtSectionTitle(title: 'SOCIETY TITLES'),
                  ...allRoles.map((role) {
                    final count = roleCounts[role] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _buildRoleCard(context, role, count),
                    );
                  }),
                  const SizedBox(height: AppSpacing.x3l),
                  _buildCreateButton(context),
                  const SizedBox(height: 100),
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
    const identityColor = Colors.cyan; 
    final bgColor = identityColor.withValues(alpha: AppColors.opacityLow);

    return BoxyArtCard(
      onTap: () {
        context.pushNamed('admin-committee-role-members', pathParameters: {'role': role});
      },
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md), // Design 4.1 Refining: Borders removed from member cards
      child: Row(
        children: [
          // Circular Icon Container (56x56)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon, 
                color: identityColor, 
                size: AppShapes.iconLg,
              ),
            ),
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
                      style: TextStyle(
                        fontSize: AppTypography.sizeButton,
                        fontWeight: AppTypography.weightExtraBold,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                      ),
                    ),
                    if (memberCount > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      // Branding 4.x Token Badge
                      BoxyArtPill(
                        label: '$memberCount',
                        color: AppColors.scoreEagle,
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
                    style: TextStyle(
                      fontSize: AppTypography.sizeLabelStrong,
                      color: isDark ? AppColors.dark300 : AppColors.dark400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded, 
            color: AppColors.textSecondary, 
            size: AppShapes.iconMd,
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
