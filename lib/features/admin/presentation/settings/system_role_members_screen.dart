import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';

class SystemRoleMembersScreen extends ConsumerStatefulWidget {
  final MemberRole role;

  const SystemRoleMembersScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<SystemRoleMembersScreen> createState() => _SystemRoleMembersScreenState();
}

class _SystemRoleMembersScreenState extends ConsumerState<SystemRoleMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final theme = Theme.of(context);
    final roleColor = theme.primaryColor;

    return HeadlessScaffold(
      title: widget.role.displayName,
      subtitle: 'Members assigned to the ${widget.role.displayName} tier.',
      showBack: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.x2l, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Design 4.1 Search Bar (Image 2)
                BoxyArtSearchInput(
                  label: 'Search Members',
                  hintText: 'Search to assign...',
                  controller: _searchController,
                  onChanged: (val) {}, // State updated via listener
                ),
              ],
            ),
          ),
        ),

        // Member List
        membersAsync.when(
          data: (members) {
            List<Member> displayList;
            final isSearching = _searchQuery.isNotEmpty;

            if (isSearching) {
              displayList = members.where((m) {
                final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
                return name.contains(_searchQuery);
              }).toList();
            } else {
              displayList = members.where((m) {
                return m.role == widget.role;
              }).toList();
            }

            // Sort: Current holders first, then alpha
            displayList.sort((a, b) {
              final aHasRole = a.role == widget.role;
              final bHasRole = b.role == widget.role;
              if (aHasRole && !bHasRole) return -1;
              if (!aHasRole && bHasRole) return 1;
              return a.lastName.compareTo(b.lastName);
            });

            if (displayList.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: BoxyArtEmptyState(
                    title: 'No members found',
                    message: 'Try a different search term.',
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final member = displayList[index];
                    final hasRole = member.role == widget.role;

                    if (!hasRole) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildCandidateTile(member, roleColor),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildActiveRoleTile(member, roleColor),
                      );
                    }
                  },
                  childCount: displayList.length,
                ),
              ),
            );
          },
          loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildCandidateTile(Member member, Color roleColor) {
    return BoxyArtCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppColors.pureWhite,
          backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
          child: member.avatarUrl == null
              ? Text(
                  member.firstName.isNotEmpty ? member.firstName[0] : '',
                  style: TextStyle(color: Colors.black.withOpacity(0.54)),
                )
              : null,
        ),
        title: Text('${member.firstName} ${member.lastName}', style: const TextStyle(fontWeight: AppTypography.weightBold)),
        subtitle: Text(member.role.displayName, style: TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.textSecondary)),
        trailing: IconButton(
          icon: Icon(Icons.add_circle, color: roleColor, size: AppShapes.iconXl),
          onPressed: () {
            _updateRole(member, widget.role);
            _searchController.clear();
          },
        ),
      ),
    );
  }

  Widget _buildActiveRoleTile(Member member, Color roleColor) {
    return BoxyArtCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.pureWhite,
            backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
            child: member.avatarUrl == null
                ? Text(
                    member.firstName.isNotEmpty ? member.firstName[0] : '',
                    style: TextStyle(fontWeight: AppTypography.weightBold, color: Colors.black.withOpacity(0.54)),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${member.firstName} ${member.lastName}',
                  style: const TextStyle(
                    fontWeight: AppTypography.weightBold, 
                    fontSize: AppTypography.sizeBody,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.12),
                    borderRadius: AppShapes.xs,
                  ),
                  child: Text(
                    widget.role.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: AppTypography.sizeMicro,
                      fontWeight: AppTypography.weightBold,
                      color: roleColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            activeTrackColor: roleColor,
            thumbColor: const WidgetStatePropertyAll(AppColors.pureWhite),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            onChanged: (val) {
               // Revert to 'member' role if unchecked, unless it's already 'member'
               if (!val && widget.role != MemberRole.member) {
                 _updateRole(member, MemberRole.member);
               }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateRole(Member member, MemberRole newRole) async {
    final repo = ref.read(membersRepositoryProvider);
    final updatedMember = member.copyWith(role: newRole);
    try {
      await repo.updateMember(updatedMember);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
