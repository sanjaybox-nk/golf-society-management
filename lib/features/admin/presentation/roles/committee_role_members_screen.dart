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
  Color get _roleColor => Theme.of(context).primaryColor;
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

    return HeadlessScaffold(
      title: widget.role,
      subtitle: 'Members currently serving as ${widget.role}.', // Design 4.1 Subtext
      showBack: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    isSearching ? 'No members found.' : 'No members have this position.',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
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
                    final hasRole = member.societyRole?.toLowerCase() == widget.role.toLowerCase();

                    if (!hasRole) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildCandidateTile(member),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildActiveRoleTile(member),
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

  // Tile for someone who CAN be added
  Widget _buildCandidateTile(Member member) {
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
                  style: TextStyle(color: Colors.black.withValues(alpha: 0.54)),
                )
              : null,
        ),
        title: Text('${member.firstName} ${member.lastName}', style: const TextStyle(fontWeight: AppTypography.weightBold)),
        subtitle: member.societyRole != null && member.societyRole!.isNotEmpty 
            ? Text(member.societyRole!, style: TextStyle(fontSize: AppTypography.sizeLabel, color: _roleColor)) 
            : null,
        trailing: IconButton(
          icon: Icon(Icons.add_circle, color: _roleColor, size: AppShapes.iconXl),
          onPressed: () {
            _updateRole(member, widget.role);
            _searchController.clear();
          },
        ),
      ),
    );
  }

  // Tile for someone who HAS the role (Premium 3.1 Style - Image 1)
  Widget _buildActiveRoleTile(Member member) {
    return BoxyArtCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      // Design 4.1 Refining: Borders removed from member cards
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.pureWhite,
            backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
            child: member.avatarUrl == null
                ? Text(
                    member.firstName.isNotEmpty ? member.firstName[0] : '',
                    style: TextStyle(fontWeight: AppTypography.weightBold, color: Colors.black.withValues(alpha: 0.54)),
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
                // Labeled Badge (Image 1 Style)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: _roleColor.withValues(alpha: 0.12),
                    borderRadius: AppShapes.xs,
                  ),
                  child: Text(
                    widget.role,
                    style: TextStyle(
                      fontSize: AppTypography.sizeMicro,
                      fontWeight: AppTypography.weightBold,
                      color: _roleColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            activeTrackColor: _roleColor,
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
