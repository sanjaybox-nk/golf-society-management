
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/distribution_list.dart';
import 'distribution_list_provider.dart';
import 'firestore_distribution_lists_repository.dart';
import 'distribution_list_modal.dart';

class AdminAudienceHubScreen extends ConsumerWidget {
  const AdminAudienceHubScreen({super.key});

  void _showCreateListDialog(BuildContext context, WidgetRef ref, {DistributionList? listToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      builder: (context) => DistributionListModal(listToEdit: listToEdit),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(distributionListProvider);
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Audience Manager',
      subtitle: 'Manage segments & templates',
      titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      leading: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xl),
          child: BoxyArtGlassIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.go('/admin'),
            tooltip: 'Back to Dashboard',
          ),
        ),
      ),
      actions: [
        BoxyArtGlassIconButton(
          icon: Icons.add_rounded,
          onPressed: () => _showCreateListDialog(context, ref),
          tooltip: 'New Audience Group',
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: BoxyArtSectionTitle(
              title: 'Mailing lists',
              isPeeking: true,
            ),
          ),
        ),
        
        listsAsync.when(
          data: (lists) {
            if (lists.isEmpty) {
              return const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: BoxyArtEmptyCard(
                    title: 'No Audience Groups',
                    message: 'Create targeted mailing lists to reach specific segments of your society (e.g. Committee, Social Members).',
                    icon: Icons.group_work_rounded,
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final list = lists[index];
                    final isLast = index == lists.length - 1;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.standard)),
                      child: Dismissible(
                        key: Key(list.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: AppColors.coral500,
                            borderRadius: AppShapes.md,
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSpacing.x2l),
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.pureWhite, size: AppShapes.iconLg),
                        ),
                        confirmDismiss: (direction) async {
                          return await showBoxyArtDialog<bool>(
                            context: context,
                            title: 'Delete Group?',
                            message: 'Are you sure you want to delete "${list.name}"?',
                            confirmText: 'Delete',
                            isDangerous: true,
                          );
                        },
                        onDismissed: (_) {
                          ref.read(distributionListsRepositoryProvider).deleteList(list.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deleted ${list.name}')),
                          );
                        },
                        child: BoxyArtCard(
                          onTap: () => _showCreateListDialog(context, ref, listToEdit: list),
                          child: Row(
                            children: [
                              BoxyArtIconBadge(
                                icon: Icons.group_rounded,
                                color: theme.primaryColor,
                                showFill: true,
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      list.name, 
                                      style: AppTypography.bodySmall.copyWith(fontWeight: AppTypography.weightExtraBold),
                                    ),
                                    Text(
                                      '${list.memberIds.length} members', 
                                      style: AppTypography.label.copyWith(
                                        color: AppColors.textTertiary,
                                        fontSize: AppTypography.sizeCaptionStrong,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: AppShapes.iconXs),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: lists.length,
                ),
              ),
            );
          },
          loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
        ),
        
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.section),
        ),
      ],
    );
  }
}
