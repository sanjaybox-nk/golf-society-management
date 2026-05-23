import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member_group_config.dart';
import 'package:golf_society/features/admin/data/member_group_config_repository.dart';
import '../../../events/presentation/events_provider.dart';

final _groupConfigsProvider = StreamProvider<List<MemberGroupConfig>>((ref) {
  return ref.watch(memberGroupConfigRepositoryProvider).watchConfigs();
});

/// Gallery for browsing and selecting a member group config.
/// When [isPicker] is true, tapping a config pops with the selected config.
class DivisionTemplateGalleryScreen extends ConsumerWidget {
  final bool isPicker;

  const DivisionTemplateGalleryScreen({super.key, this.isPicker = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configsAsync = ref.watch(_groupConfigsProvider);
    final seasonsAsync = ref.watch(seasonsProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: isPicker ? 'Select Member Groups' : 'Member Groups',
      subtitle: isPicker
          ? 'Choose a group config for this season'
          : 'Manage how members are grouped',
      topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.xl,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.lg),
              configsAsync.when(
                data: (configs) {
                  final seasons = seasonsAsync.value ?? [];
                  if (configs.isEmpty) {
                    return BoxyArtEmptyCard(
                      title: 'No Group Configs',
                      message: isPicker
                          ? 'Create a member group config first.'
                          : 'Create your first member group config.',
                      icon: Icons.workspaces_outlined,
                    );
                  }
                  return Column(
                    children: configs.map((c) {
                      final usedIn = seasons
                          .where((s) => s.memberGroupConfigId == c.id)
                          .map((s) => s.name)
                          .toList();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.cardToCard),
                        child: BoxyArtCard(
                          onTap: isPicker
                              ? () => context.pop(c)
                              : () => _editConfig(context, ref, c,
                                  seasons.any((s) => s.memberGroupConfigId == c.id)),
                          child: Row(
                            children: [
                              BoxyArtIconBadge(
                                icon: _splitIcon(c.splitType),
                                color: AppColors.lime500,
                                isTinted: true,
                                size: AppShapes.iconHero,
                                iconSize: AppShapes.iconLg,
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name, style: AppTypography.labelStrong),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      _splitSummary(c),
                                      style: AppTypography.micro
                                          .copyWith(color: AppColors.dark400),
                                    ),
                                    if (usedIn.isNotEmpty) ...[
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'Used in: ${usedIn.join(', ')}',
                                        style: AppTypography.micro.copyWith(
                                          color: AppColors.dark300,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                isPicker
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.chevron_right_rounded,
                                color: AppColors.dark400,
                                size: AppShapes.iconSm,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const BoxyArtLoadingCard(),
                error: (e, _) => BoxyArtEmptyCard(
                  title: 'Error',
                  message: e.toString(),
                  icon: Icons.error_outline_rounded,
                ),
              ),
              if (!isPicker) ...[
                const SizedBox(height: AppSpacing.md),
                BoxyArtButton(
                  title: 'New Group Config',
                  icon: Icons.add_rounded,
                  isTinted: true,
                  fullWidth: true,
                  onTap: () => context.pushNamed('admin-division-template-new'),
                ),
              ],
              const SizedBox(height: AppSpacing.hero),
            ]),
          ),
        ),
      ],
    );
  }

  String _splitSummary(MemberGroupConfig config) {
    final groupNames = config.groups.map((g) => g.name).join(' · ');
    switch (config.splitType) {
      case GroupSplitType.handicap:
        return 'HC split ≤ ${config.handicapThreshold ?? 12.0} · $groupNames';
      case GroupSplitType.gender:
        return 'Gender split · $groupNames';
      case GroupSplitType.custom:
        return 'Custom · $groupNames';
    }
  }

  IconData _splitIcon(GroupSplitType type) {
    switch (type) {
      case GroupSplitType.handicap:
        return Icons.swap_vert_rounded;
      case GroupSplitType.gender:
        return Icons.people_rounded;
      case GroupSplitType.custom:
        return Icons.workspaces_rounded;
    }
  }

  void _editConfig(
      BuildContext context, WidgetRef ref, MemberGroupConfig config, bool isInUse) {
    context.pushNamed(
      'admin-division-template-edit',
      pathParameters: {'id': config.id},
      extra: {'config': config, 'isInUse': isInUse},
    );
  }
}
