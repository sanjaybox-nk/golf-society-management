import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/society_config.dart';

class HomeWelcomeHero extends ConsumerWidget {
  final SocietyConfig config;
  final Member member;

  const HomeWelcomeHero({
    super.key,
    required this.config,
    required this.member,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAdmin = member.role == MemberRole.admin || member.role == MemberRole.superAdmin;
    final primaryColor = Color(config.primaryColor);

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.x2l),
      gradient: AppGradients.brandPrimary(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BoxyArtSquareBadge(
                size: 64,
                backgroundColor: AppColors.pureWhite.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.sports_golf_rounded,
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
                      'Welcome to',
                      style: AppTypography.labelStrong.copyWith(
                        color: AppColors.pureWhite.withValues(alpha: 0.8),
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      config.societyName,
                      style: AppTypography.displayLocker.copyWith(
                        color: AppColors.pureWhite,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            isAdmin 
              ? 'The fairways are quiet... start your season by scheduling your first fixture or adding your founding members.'
              : 'Welcome a board! Your society is currently preparing for the next season. Check back soon for upcoming events and standings.',
            style: AppTypography.body.copyWith(
              color: AppColors.pureWhite.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          
          if (isAdmin) ...[
            const SizedBox(height: AppSpacing.x2l),
            Row(
              children: [
                Expanded(
                  child: BoxyArtButton(
                    title: 'Create Event',
                    icon: Icons.add_rounded,
                    onTap: () => context.push('/admin/events/new'),
                    isSmall: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: BoxyArtButton(
                    title: 'Add Members',
                    icon: Icons.group_add_rounded,
                    onTap: () => context.push('/admin/members'),
                    isSecondary: true,
                    isSmall: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
