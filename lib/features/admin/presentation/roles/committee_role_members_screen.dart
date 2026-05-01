import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../members/presentation/members_provider.dart';


class CommitteeRoleMembersScreen extends ConsumerStatefulWidget {
  final String role; // e.g. "Captain"

  const CommitteeRoleMembersScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<CommitteeRoleMembersScreen> createState() => _CommitteeRoleMembersScreenState();
}

class _CommitteeRoleMembersScreenState extends ConsumerState<CommitteeRoleMembersScreen> {
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

    return HeadlessScaffold(
      title: widget.role,
      subtitle: 'Members currently serving as ${widget.role}.', // Design 4.1 Subtext
      showBack: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              // Candidates + Holders matching search
              displayList = members.where((m) {
                final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
                return name.contains(_searchQuery);
              }).toList();
            } else {
              // Holders Only
              displayList = members.where((m) {
                return m.societyRole?.toLowerCase() == widget.role.toLowerCase();
              }).toList();
            }

            // Sort: Role holders first, then alpha
            displayList.sort((a, b) {
              final aHasRole = a.societyRole?.toLowerCase() == widget.role.toLowerCase();
              final bHasRole = b.societyRole?.toLowerCase() == widget.role.toLowerCase();
              if (aHasRole && !bHasRole) return -1;
              if (!aHasRole && bHasRole) return 1;
              return a.lastName.compareTo(b.lastName);
            });

            if (displayList.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: BoxyArtEmptyCard(
                    title: isSearching ? 'No members found' : 'No members assigned',
                    message: isSearching 
                        ? 'Try a different search term.' 
                        : 'Search members above to assign them to this role.',
                    icon: isSearching ? Icons.search_off_rounded : Icons.person_add_rounded,
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.x4l, // Design 4.x: Standardized bottom breathing room
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final member = displayList[index];
                    final hasRole = member.societyRole?.toLowerCase() == widget.role.toLowerCase();

                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.atomic),
                      child: hasRole 
                        ? _buildActiveRoleTile(member) 
                        : _buildCandidateTile(member),
                    );
                  },
                  childCount: displayList.length,
                ),
              ),
            );
          },
          loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x4l)),
      ],
    );
  }

  // Tile for someone who CAN be added
  Widget _buildCandidateTile(Member member) {
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
                if (member.societyRole != null && member.societyRole!.isNotEmpty)
                  Text(
                    member.societyRole!,
                    style: AppTypography.caption.copyWith(
                      color: theme.primaryColor,
                      height: 1.0,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: theme.primaryColor, size: AppShapes.iconLg),
            onPressed: () {
              _updateRole(member, widget.role);
              _searchController.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRoleTile(Member member) {
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
                  label: widget.role,
                  color: theme.primaryColor,
                  fontSize: AppTypography.sizeMicro,
                  hasHorizontalMargin: false,
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            activeTrackColor: theme.primaryColor,
            thumbColor: const WidgetStatePropertyAll(AppColors.pureWhite),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            onChanged: (val) {
               if (!val) _updateRole(member, null);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateRole(Member member, String? newRole) async {
    final repo = ref.read(membersRepositoryProvider);
    // Note: This replaces any existing role. A member can only have ONE society role at a time currently.
    final updatedMember = member.copyWith(societyRole: newRole);
    try {
      await repo.updateMember(updatedMember);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
