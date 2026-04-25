import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';

class CompetitionTypeSelectionScreen extends StatelessWidget {
  final bool isTemplate;
  final bool isPicker;
  final String? formatFilter;
  final String? eventId;

  const CompetitionTypeSelectionScreen({
    super.key, 
    this.isTemplate = false,
    this.isPicker = false,
    this.formatFilter,
    this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = (isTemplate || isPicker) ? 'Select Game Type' : 'New Template Type';

    return HeadlessScaffold(
      title: title,
      actions: [
        BoxyArtPill.committee(label: 'ADMIN'),
        const SizedBox(width: AppSpacing.md),
      ],
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Individual Formats
              if (formatFilter == null || 
                  ['stableford', 'stroke', 'maxScore'].any((f) => formatFilter == f)) ...[
                const BoxyArtSectionTitle(title: 'INDIVIDUAL FORMATS'),
                BoxyArtCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      if (formatFilter == null || formatFilter == 'stableford')
                        _ModernTypeTile(
                          title: 'Stableford',
                          subtitle: 'Points based on handicap. Best for mixed ability.',
                          icon: Icons.format_list_numbered_rounded,
                          onTap: () => _navigateToBuilder(context, CompetitionFormat.stableford),
                          showDivider: formatFilter == null || formatFilter == 'stableford',
                        ),
                      if (formatFilter == null || formatFilter == 'stroke')
                        _ModernTypeTile(
                          title: 'Stroke Play (Medal)',
                          subtitle: 'Count every shot. The pure test of golf.',
                          icon: Icons.golf_course_rounded,
                          onTap: () => _navigateToBuilder(context, CompetitionFormat.stroke),
                          showDivider: formatFilter == null,
                        ),
                      if (formatFilter == null || formatFilter == 'maxScore')
                        _ModernTypeTile(
                          title: 'Max Score',
                          subtitle: 'Stroke play with a cap per hole (e.g. Par + 3).',
                          icon: Icons.vertical_align_top_rounded,
                          onTap: () => _navigateToBuilder(context, CompetitionFormat.maxScore),
                          showDivider: false,
                        ),
                    ],
                  ),
                ),
              ],


              // 3. Pairs Formats
              if (formatFilter == null) ...[
                const BoxyArtSectionTitle(title: 'PAIRS FORMATS'),
                BoxyArtCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ModernTypeTile(
                        title: 'Fourball (Better Ball)',
                        subtitle: 'Pairs play own ball. Best score counts.',
                        icon: Icons.people_outline_rounded,
                        onTap: () => _navigateToBuilder(context, CompetitionSubtype.fourball),
                        showDivider: true,
                      ),
                      _ModernTypeTile(
                        title: 'Foursomes (Alternate Shot)',
                        subtitle: 'Partners alternate hitting one ball.',
                        icon: Icons.sync_alt_rounded,
                        onTap: () => _navigateToBuilder(context, CompetitionSubtype.foursomes),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ],

              // 4. Season Tournaments
              if (formatFilter == null) ...[
                const BoxyArtSectionTitle(title: 'SEASON TOURNAMENTS'),
                BoxyArtCard(
                  padding: EdgeInsets.zero,
                  child: _ModernTypeTile(
                    title: 'Season Match Play',
                    subtitle: 'Knockout brackets and season-long draws.',
                    icon: Icons.emoji_events_rounded,
                    onTap: () => _navigateToBuilder(context, CompetitionSubtype.matchPlaySeason),
                    showDivider: false,
                  ),
                ),
              ],
              
              // 5. Team Formats
              if (formatFilter == null) ...[
                const BoxyArtSectionTitle(title: 'TEAM FORMATS'),
                BoxyArtCard(
                  padding: EdgeInsets.zero,
                  child: _ModernTypeTile(
                    title: 'Scramble',
                    subtitle: 'Texas/Florida Scramble. Team aggregate play.',
                    icon: Icons.group_work_rounded,
                    onTap: () => _navigateToBuilder(context, CompetitionFormat.scramble),
                    showDivider: false,
                  ),
                ),
              ],
              
              const SizedBox(height: AppSpacing.x4l),
            ]),
          ),
        ),
      ],
    );
  }

  void _navigateToBuilder(BuildContext context, dynamic type) async {
    final typeName = type is CompetitionFormat ? type.name : (type as CompetitionSubtype).name;
    final base = isPicker ? '/admin/events/manage/$eventId/game-setup/gallery' : '/admin/settings/templates/gallery';
    final result = await context.push<String>('$base/$typeName');
    
    if (isPicker && result != null && context.mounted) {
      context.pop(result);
    }
  }
}

class _ModernTypeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool showDivider;

  const _ModernTypeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final parts = title.split(' (');
    final mainTitle = parts[0];
    final bracketText = parts.length > 1 ? '(${parts[1]}' : null;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                BoxyArtIconBadge(
                  icon: icon,
                  size: 44,
                  iconSize: 22,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            mainTitle.toUpperCase(),
                            style: AppTypography.labelStrong.copyWith(
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 1.0,
                            ),
                          ),
                          if (bracketText != null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              bracketText,
                              style: AppTypography.caption.copyWith(
                                color: isDark ? AppColors.dark300 : AppColors.dark400,
                                fontWeight: AppTypography.weightBold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.dark200 : AppColors.dark400,
                          fontWeight: AppTypography.weightMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded, 
                  color: isDark ? AppColors.dark400 : AppColors.dark200, 
                  size: AppShapes.iconXs,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const BoxyArtDivider(verticalPadding: 0),
      ],
    );
  }
}
