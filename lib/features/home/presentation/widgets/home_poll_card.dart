part of '../member_home_screen.dart';

class _GlobalPollCard extends ConsumerWidget {
  final GolfEvent event;
  final EventFeedItem item;

  const _GlobalPollCard({required this.event, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = (item.pollData['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final votes = (item.pollData['votes'] as Map?)?.cast<String, String>() ?? {};
    final user = ref.watch(effectiveUserProvider);
    final userVote = votes[user.id];
    final hasVoted = userVote != null;
    
    // Calculate percentages
    final totalVotes = votes.length;
    final Map<String, int> counts = {};
    for (var opt in options) {
      counts[opt] = votes.values.where((v) => v == opt).length;
    }

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BoxyArtIconBadge(
                icon: Icons.poll_rounded,
                isSecondary: true,
                size: AppShapes.iconLg,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.dark600,
                        borderRadius: AppShapes.sm,
                        border: Border.all(color: AppColors.dark500),
                      ),
                      child: Text(
                        'POLL QUESTION',
                        style: AppTypography.micro.copyWith(
                          color: AppColors.lime500,
                          fontWeight: AppTypography.weightHeavy,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title ?? 'Quick Question',
                      style: AppTypography.displayHeading.copyWith(
                        fontSize: 18,
                        fontWeight: AppTypography.weightExtraBold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isLast = index == options.length - 1;
            final count = counts[option] ?? 0;
            final percent = totalVotes == 0 ? 0.0 : count / totalVotes;
            final isSelected = userVote == option;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: GestureDetector(
                onTap: hasVoted ? null : () => _vote(ref, option),
                child: Stack(
                  children: [
                    // Design 4.x Standardized Option Container
                    AnimatedContainer(
                      duration: AppAnimations.fast,
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.dark600,
                        borderRadius: AppShapes.md,
                        border: Border.all(
                          color: isSelected ? AppColors.lime500 : AppColors.dark500,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                    ),
                    // Glassmorphic Percentage Fill (v4.0)
                    if (hasVoted)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedContainer(
                            duration: AppAnimations.medium,
                            curve: Curves.easeOutQuart,
                            height: 56,
                            width: constraints.maxWidth * percent,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.lime500.withValues(alpha: AppColors.opacityLow) 
                                  : AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle),
                              borderRadius: AppShapes.md,
                            ),
                          );
                        },
                      ),
                    // Label Content with Standardized Toggles
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Row(
                          children: [
                            Icon(
                              isSelected 
                                  ? Icons.radio_button_checked_rounded 
                                  : (hasVoted ? Icons.radio_button_off_rounded : Icons.radio_button_off_rounded),
                              color: isSelected ? AppColors.lime500 : AppColors.dark400,
                              size: 22,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                option,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isSelected ? AppColors.lime500 : AppColors.pureWhite,
                                  fontWeight: isSelected ? AppTypography.weightBold : AppTypography.weightRegular,
                                ),
                              ),
                            ),
                            if (hasVoted) ...[
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                '${(percent * 100).round()}%',
                                style: AppTypography.labelStrong.copyWith(
                                  color: isSelected ? AppColors.lime500 : AppColors.dark300,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalVotes vote${totalVotes == 1 ? '' : 's'}',
                style: AppTypography.micro.copyWith(color: AppColors.dark300, letterSpacing: 0.5),
              ),
              if (hasVoted)
                Text(
                  'VOTE CAST',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.lime500,
                    fontWeight: AppTypography.weightHeavy,
                    letterSpacing: 1.0,
                  ),
                )
              else
                Text(
                  'NOT VOTED',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.dark400,
                    fontWeight: AppTypography.weightHeavy,
                    letterSpacing: 1.0,
                  ),
                ),
            ],
          ),
          const BoxyArtDivider(verticalPadding: AppSpacing.lg),
          Text(
            'From ${event.title}',
            style: AppTypography.micro.copyWith(color: AppColors.dark300),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _vote(WidgetRef ref, String option) async {
    final user = ref.read(effectiveUserProvider);
    final votes = Map<String, String>.from(item.pollData['votes'] ?? {});
    votes[user.id] = option;

    final updatedItem = item.copyWith(
      pollData: {
        ...item.pollData,
        'votes': votes,
      },
    );

    final List<EventFeedItem> updatedItems = List.from(event.feedItems);
    final index = updatedItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      updatedItems[index] = updatedItem;
      final updatedEvent = event.copyWith(feedItems: updatedItems);
      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
    }
  }
}

