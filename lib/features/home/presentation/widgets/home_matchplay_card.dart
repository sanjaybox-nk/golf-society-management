part of '../member_home_screen.dart';

class _MatchPlayMatchupCard extends ConsumerWidget {
  final GolfEvent event;
  final MatchDefinition match;

  const _MatchPlayMatchupCard({required this.event, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveUser = ref.watch(effectiveUserProvider);
    final isPlayerA = match.playerAId == effectiveUser.id;
    final opponentName = isPlayerA ? match.playerBName : match.playerAName;
    
    DateTime? deadline;
    final roundCutoffs = event.grouping['roundCutoffs'] as Map<String, dynamic>?;
    if (roundCutoffs != null && roundCutoffs.containsKey(match.round.name)) {
      deadline = DateTime.parse(roundCutoffs[match.round.name]!);
    } else if (event.grouping['deadline'] != null) {
      deadline = DateTime.parse(event.grouping['deadline']);
    }

    return BoxyArtCard(
      onTap: () => context.go('/events/${event.id}'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      gradient: LinearGradient(
        colors: [
          AppColors.actionMidnight,
          AppColors.actionMidnight.withValues(alpha: 0.9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BoxyArtPill.status(
                label: 'MATCH PLAY',
                color: AppColors.lime500,
                isLegend: true,
              ),
              const Spacer(),
              if (deadline != null)
                Text(
                  'DEADLINE: ${DateFormat('d MMM').format(deadline).toUpperCase()}',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
                    fontWeight: AppTypography.weightBlack,
                    letterSpacing: 1.0,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            event.title.toUpperCase(),
            style: AppTypography.labelStrong.copyWith(
              color: AppColors.pureWhite.withValues(alpha: AppColors.opacityMuted),
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'VS',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.pureWhite,
                    fontWeight: AppTypography.weightBlack,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  opponentName.toUpperCase(),
                  style: AppTypography.displayLocker.copyWith(
                    color: AppColors.pureWhite,
                    fontSize: 24,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Round',
                      style: AppTypography.micro.copyWith(
                        color: AppColors.pureWhite.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      match.round.name.toUpperCase(),
                      style: AppTypography.labelStrong.copyWith(color: AppColors.pureWhite),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Venue',
                      style: AppTypography.micro.copyWith(
                        color: AppColors.pureWhite.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      event.courseName ?? 'Flexible Venue',
                      style: AppTypography.labelStrong.copyWith(color: AppColors.pureWhite),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          BoxyArtButton(
            title: 'VIEW TOURNAMENT HUB',
            isPrimary: true,
            isSmall: true,
            onTap: () => context.go('/events/${event.id}'),
          ),
        ],
      ),
    );
  }
}
