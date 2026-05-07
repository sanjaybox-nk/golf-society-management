import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

class AchievementTile extends StatelessWidget {
  final String title;
  final String playerName;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AchievementTile({
    super.key,
    required this.title,
    required this.playerName,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.standard;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.standard;

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: shapes?.card ?? AppShapes.lg,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: AppShapes.borderMedium)),
          ),
          child: Row(
            children: [
              BoxyArtIconBadge(
                icon: icon,
                color: color,
                iconSize: AppShapes.iconLg,
                isTinted: true,
              ),
              SizedBox(width: spacing?.cardHorizontalPadding ?? AppSpacing.standard),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.label.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: AppTypography.weightBold,
                        letterSpacing: AppTypography.lsLabel,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      toTitleCase(playerName),
                      style: AppTypography.body.copyWith(
                        fontWeight: AppTypography.weightStrong,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      value,
                      style: AppTypography.label.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: AppColors.dark100, size: AppShapes.iconMd),
            ],
          ),
        ),
      ),
    );
  }
}

class SocietyQuoteCard extends StatelessWidget {
  const SocietyQuoteCard({super.key});

  static const List<Map<String, String>> _quotes = [
    {'headline': 'What a day for the society!', 'subtitle': 'See you at the 19th hole.'},
    {'headline': 'Fairways and greens!', 'subtitle': 'The society is looking sharp today.'},
    {'headline': 'The best walk in the world!', 'subtitle': 'Great round, everyone.'},
    {'headline': 'Drive for show, putt for dough!', 'subtitle': 'Time to settle the bets at the bar.'},
    {'headline': 'Golf is a game of misses!', 'subtitle': 'But we missed in style today.'},
    {'headline': 'A bad day at golf...', 'subtitle': '...beats a good day at the office!'},
    {'headline': 'A slice is just a power fade in disguise!', 'subtitle': 'Aim left and hope for the best.'},
  ];

  @override
  Widget build(BuildContext context) {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final quote = _quotes[dayOfYear % _quotes.length];

    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.section, horizontal: AppSpacing.standard),
        child: Column(
          children: [
            Icon(
              Icons.format_quote_rounded,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacityMedium),
              size: AppShapes.iconXl,
            ),
            const SizedBox(height: AppSpacing.standard),
            Text(
              quote['headline']!.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.displaySubPage.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightBlack,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.atomic),
            Text(
              quote['subtitle']!,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityStrong),
                fontStyle: FontStyle.italic,
                fontWeight: AppTypography.weightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
