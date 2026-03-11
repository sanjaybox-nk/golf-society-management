import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import '../../../matchplay/domain/match_definition.dart';
import 'package:golf_society/domain/models/course_config.dart';

class ModernScoringView extends StatelessWidget {
  final GolfEvent event;
  final Map<int, int> scores;
  final int currentHole;
  final List<CourseHole> holes;
  final int playerPhc;
  final String markingName; // [NEW] Clear identification
  final MatchResult? matchResult;
  final bool isTeam1;
  final ValueChanged<int> onHoleChanged;
  final Function(int hole, int score) onSetScore;
  final VoidCallback onShowFullCard;
  final CompetitionFormat format;
  final MaxScoreConfig? maxScoreConfig;
  final CompetitionRules? rules;
  // [NEW] Tab selection lifted from AppBar into keypad card
  final int selectedTab; // 0 = player, 1 = me/verifier
  final ValueChanged<int> onTabChanged;
  final bool isSelfMarking;
  final String? selectedTeeName;

  const ModernScoringView({
    super.key,
    required this.event,
    required this.scores,
    required this.currentHole,
    required this.holes,
    required this.playerPhc,
    required this.markingName,
    this.matchResult,
    required this.onHoleChanged,
    required this.onSetScore,
    required this.onShowFullCard,
    this.format = CompetitionFormat.stableford,
    this.maxScoreConfig,
    this.rules,
    this.isTeam1 = true,
    this.selectedTab = 1,
    required this.onTabChanged,
    this.isSelfMarking = true,
    this.selectedTeeName,
  });

  @override
  Widget build(BuildContext context) {
    final holeData = holes.length >= currentHole ? holes[currentHole - 1] : null;
    final par = holeData?.par ?? 4;
    final si = holeData?.si;
    final score = scores[currentHole] ?? par;
    final cap = ScoringCalculator.getMaxScoreCap(
      par: par,
      si: si ?? 18,
      playingHandicap: playerPhc.toDouble(),
      format: format,
      maxScoreConfig: maxScoreConfig,
    );

    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: double.infinity,
      height: double.infinity,
      child: Column(
      children: [
        // Hole Ribbon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: BoxyHoleSelector(
            currentHole: currentHole,
            scores: scores,
            onHoleChanged: onHoleChanged,
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),

        // Player + Tee Pills Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              BoxyArtPill.type(
                label: markingName,
                icon: Icons.person_outline,
              ),
              const Spacer(),
              _buildTeePill(context, selectedTeeName ?? event.selectedTeeName ?? 'White'),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Hero Card
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _buildHeroCard(context, par, si, score, cap),
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        _buildKeypad(context, par, score, cap),
      ],
    ),
  );
}


  Widget _buildHeroCard(BuildContext context, int par, int? si, int score, int? cap) {
    // 1. Calculate Stableford Points
    final int pts = si != null 
        ? ScoringCalculator.calculateHolePoints(
            grossScore: score,
            par: par,
            si: si,
            playingHandicap: playerPhc.toDouble(),
          )
        : 0;

    // 2. Determine Match Hole Status
    String matchHoleStatus = '-';
    if (matchResult != null && matchResult!.holeResults.length >= currentHole) {
      final res = matchResult!.holeResults[currentHole - 1];
      if (res == 1) {
        matchHoleStatus = isTeam1 ? 'WIN' : 'LOSS';
      } else if (res == -1) {
        matchHoleStatus = isTeam1 ? 'LOSS' : 'WIN';
      } else if (res == 0) {
        matchHoleStatus = 'HALVE';
      }
    }

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppShapes.x2l,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'HOLE $currentHole',
                style: AppTypography.label.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHalf),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Par $par${si != null ? ' • SI $si' : ''}',
                style: AppTypography.displaySection.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              // Large Score Display
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark700 : AppColors.pureWhite,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.lime500.withValues(alpha: AppColors.opacityMedium),
                    width: AppShapes.borderMedium,
                  ),
                  boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
                ),
                child: Text(
                  cap != null && score >= cap ? 'MAX' : '$score',
                  style: (cap != null && score >= cap 
                      ? AppTypography.displayTitle.copyWith(fontSize: AppTypography.sizeDisplayLarge) 
                      : AppTypography.displayHero).copyWith(
                    color: cap != null && score >= cap ? AppColors.coral500 : AppColors.lime500,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BoxyArtPill.format(
                    label: 'STABLEFORD: $pts pts',
                  ),
                  if (matchResult != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    BoxyArtPill.format(
                      label: 'MATCH: $matchHoleStatus',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildKeypad(BuildContext context, int par, int currentScore, int? cap) {
    // We'll show buttons for Par-1, Par, Par+1, Par+2, and 7+
    final options = [par - 1, par, par + 1, par + 2];
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppShapes.x2l,
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow),
          width: AppShapes.borderThin,
        ),
        boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full-width PLAYER / ME toggle
          _buildMarkerToggle(context),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              ...options.map((val) {
                final isSelected = val == currentScore;
                final isOverCap = cap != null && val > cap;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: _buildKeypadButton(context, '$val', val, isSelected, isDisabled: isOverCap),
                  ),
                );
              }),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: _buildKeypadButton(
                    context, 
                    cap != null ? 'MAX' : '7+', 
                    cap ?? (currentScore > par + 2 ? currentScore : 7), 
                    (cap != null && currentScore >= cap) || (cap == null && currentScore >= 7 && !options.contains(currentScore))
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: BoxyArtButton(
                  title: '',
                  icon: Icons.remove,
                  isSecondary: true,
                  onTap: currentScore > 1 ? () => onSetScore(currentHole, currentScore - 1) : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: BoxyArtButton(
                  title: currentHole < 18 ? 'NEXT HOLE' : 'FINISH CARD',
                  isPrimary: true,
                  onTap: currentHole < 18 ? () => onHoleChanged(currentHole + 1) : onShowFullCard,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: BoxyArtButton(
                  title: '',
                  icon: Icons.add,
                  isSecondary: true,
                  onTap: (cap == null || currentScore < cap) ? () => onSetScore(currentHole, currentScore + 1) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(BuildContext context, String label, int value, bool isSelected, {bool isDisabled = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: isDisabled ? null : () => onSetScore(currentHole, value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: AppShapes.borderMedium,
            ),
          ),
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppAnimations.fast,
            style: (isSelected ? AppTypography.displayLocker : AppTypography.displayLargeBody).copyWith(
              color: isSelected 
                  ? (isDark ? AppColors.pureWhite : AppColors.dark900) 
                  : theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityHalf),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  /// Full-width PLAYER / ME segmented toggle for the keypad card.
  Widget _buildMarkerToggle(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow),
            width: AppShapes.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildToggleTab(context, 0, 'PLAYER', icon: Icons.person_outline, isDisabled: isSelfMarking),
          _buildToggleTab(context, 1, 'ME', icon: Icons.account_circle_outlined),
        ],
      ),
    );
  }

  Widget _buildToggleTab(BuildContext context, int tab, String label, {required IconData icon, bool isDisabled = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: isDisabled ? null : () => onTabChanged(tab),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: AppShapes.borderMedium,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppShapes.iconSm,
                color: isSelected
                    ? (isDark ? AppColors.pureWhite : AppColors.dark900)
                    : (isDisabled
                        ? (isDark ? AppColors.dark400 : AppColors.dark200)
                        : (isDark ? AppColors.dark150 : AppColors.dark600)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontWeight: AppTypography.weightBlack,
                  letterSpacing: 0.5,
                  color: isSelected
                      ? (isDark ? AppColors.pureWhite : AppColors.dark900)
                      : (isDisabled
                          ? (isDark ? AppColors.dark400 : AppColors.dark200)
                          : (isDark ? AppColors.dark150 : AppColors.dark600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Builds a tee pill matching BoxyArtPill's exact style, with a coloured
  /// dot in place of the icon.
  Widget _buildTeePill(BuildContext context, String teeName) {
    final teeColor = _getTeeColor(teeName);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: teeColor.withValues(alpha: AppColors.opacityMedium),
        borderRadius: AppShapes.md,
        border: Border.all(
          color: teeColor.withValues(alpha: AppColors.opacityMuted),
          width: AppShapes.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: teeColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            teeName,
            style: AppTypography.micro.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTeeColor(String teeName) {
    final name = teeName.toLowerCase();
    if (name.contains('white')) return AppColors.dark400;
    if (name.contains('yellow')) return const Color(0xFFFFD700);
    if (name.contains('red')) return const Color(0xFFFF4D4D);
    if (name.contains('blue')) return const Color(0xFF1E90FF);
    if (name.contains('black')) return const Color(0xFF2F2F2F);
    if (name.contains('green')) return const Color(0xFF2ECC71);
    if (name.contains('gold')) return const Color(0xFFFFD700);
    if (name.contains('silver')) return const Color(0xFFC0C0C0);
    if (name.contains('orange')) return AppColors.amber500;
    if (name.contains('purple')) return AppColors.teamB;
    return AppColors.textSecondary;
  }
}
