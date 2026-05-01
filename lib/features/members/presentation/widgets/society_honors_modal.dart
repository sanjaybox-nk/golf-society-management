import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import '../members_provider.dart';
import '../profile_provider.dart';
import '../member_details_modal.dart';

class SocietyHonorsModal extends ConsumerWidget {
  final Member currentUser;

  const SocietyHonorsModal({
    super.key,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(allMembersProvider);
    final theme = Theme.of(context);
    
    return BoxyArtBottomSheet(
      title: 'Society Honors',
      child: membersAsync.when(
        data: (members) {
          final founders = members.where((m) => m.isFoundingMember).toList()
            ..sort((a, b) => a.lastName.compareTo(b.lastName));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Your Honors Section
              if (currentUser.isFoundingMember) ...[
                const BoxyArtSectionTitle(
                  title: 'Your Recognition', 
                  isPeeking: true,
                  horizontalPadding: 0,
                ),
                BoxyArtCard(
                  gradient: AppGradients.brandPrimary(context),
                  isHero: true,
                  padding: const EdgeInsets.all(AppSpacing.x2l),
                  child: Row(
                    children: [
                      BoxyArtSquareBadge(
                        size: 64,
                        backgroundColor: AppColors.pureWhite.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.pureWhite,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FOUNDING MEMBER',
                              style: AppTypography.displayLocker.copyWith(
                                color: AppColors.pureWhite,
                                fontSize: 20,
                                fontWeight: AppTypography.weightStrong,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'One of the original architects of the society.',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.pureWhite.withValues(alpha: 0.8),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 2. Hall of Fame Section
              const BoxyArtSectionTitle(
                title: 'Society Founders', 
                followsCard: true,
                horizontalPadding: 0,
              ),
              if (founders.isEmpty)
                const BoxyArtEmptyCard(
                  title: 'No Founders',
                  message: 'No founders registered yet.',
                  icon: Icons.history_edu_rounded,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: founders.length,
                  separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final founder = founders[index];
                    final bool isMe = founder.id == currentUser.id;
                    final bool hasLeft = founder.status == MemberStatus.left || founder.status == MemberStatus.archived;
                    final isAdmin = ref.watch(currentUserProvider).role == MemberRole.admin || 
                                    ref.watch(currentUserProvider).role == MemberRole.superAdmin;

                    return GestureDetector(
                      onTap: () => MemberDetailsModal.show(context, founder, isAdminContext: isAdmin),
                      child: BoxyArtCard(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                        child: Row(
                          children: [
                            BoxyArtAvatar(
                              url: founder.avatarUrl,
                              initials: founder.firstName[0] + founder.lastName[0],
                              radius: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${founder.firstName} ${founder.lastName}${isMe ? ' (You)' : ''}',
                                    style: AppTypography.labelStrong.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (hasLeft)
                                    Text(
                                      'Honorary Member (Alumni)',
                                      style: AppTypography.micro.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
        loading: () => const BoxyArtLoadingCard(),
        error: (e, s) => Text('Error loading honors: $e'),
      ),
    );
  }
}
