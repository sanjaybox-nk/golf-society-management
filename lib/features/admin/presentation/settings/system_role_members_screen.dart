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
    final spacing = theme.extension<AppSpacingTokens>();
    final roleColor = theme.primaryColor;

    return HeadlessScaffold(
      title: widget.role.displayName,
      subtitle: 'Manage assignments',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      actions: const [],
      showBack: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
                child: BoxyArtSearchInput(
                  label: 'Search Members',
                  hintText: 'Search to assign...',
                  controller: _searchController,
                  onChanged: (val) {}, 
                ),
              ),
              // Standardized search-to-card rhythm
              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),
            ],
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
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: BoxyArtEmptyCard(
                    title: 'No members found',
                    message: 'Try a different search term or check the clubhouse roster.',
                    icon: Icons.search_off_rounded,
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final member = displayList[index];
                    final hasRole = member.role == widget.role;

                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.atomic),
                      child: hasRole 
                        ? _buildActiveRoleTile(member, roleColor)
                        : _buildCandidateTile(member, roleColor),
                    );
                  },
                  childCount: displayList.length,
                ),
              ),
            );
          },
          loading: () => const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtLoadingCard(title: 'Loading membership...'),
            ),
          ),
          error: (err, stack) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtEmptyCard(
                title: 'Data Unavailable',
                message: 'Error fetching members: $err',
                icon: Icons.error_outline_rounded,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.pageBottom)),
      ],
    );
  }

  Widget _buildCandidateTile(Member member, Color roleColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isDark ? AppColors.dark600 : AppColors.dark100,
            backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
            child: member.avatarUrl == null
                ? Text(
                    member.firstName.isNotEmpty ? member.firstName[0] : '',
                    style: AppTypography.label.copyWith(color: AppColors.textTertiary),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.displayName,
                  style: AppTypography.label.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: AppTypography.weightBold,
                    height: 1.2,
                  ),
                ),
                Text(
                  member.role.displayName,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.dark300 : AppColors.dark500,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: roleColor, size: AppShapes.iconLg),
            onPressed: () {
              _updateRole(member, widget.role);
              _searchController.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRoleTile(Member member, Color roleColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isDark ? AppColors.dark600 : AppColors.dark100,
            backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
            child: member.avatarUrl == null
                ? Text(
                    member.firstName.isNotEmpty ? member.firstName[0] : '',
                    style: AppTypography.label.copyWith(color: AppColors.textTertiary),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.displayName,
                  style: AppTypography.label.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: AppTypography.weightBold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                BoxyArtPill(
                  label: widget.role.displayName,
                  color: roleColor,
                  fontSize: AppTypography.sizeMicro,
                  hasHorizontalMargin: false,
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
