import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'package:golf_society/features/events/presentation/state/marker_selection_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';


class ScoringEntryView extends ConsumerWidget {
  final GolfEvent event;
  final String targetEntryId;
  final String? activeEntryId;
  final ProcessedEventData scoringData;
  final int currentHoleIndex;
  final Map<int, int> localScores;
  final Map<int, int> verifierScores;
  final bool isReadOnly;
  final bool isMatchPlay;
  final bool isDriveAttributionEnabled;
  final Scorecard? activeScorecard;
  final Scorecard? localVerifierCard;
  
  final Function(int) onHoleChanged;
  final Function(int, int, {required bool isVerifier}) onScoreChanged;
  final Function(int, String?) onDriveAttributionChanged;
  final Function(Scorecard) onScorecardUpdated;

  const ScoringEntryView({
    super.key,
    required this.event,
    required this.targetEntryId,
    this.activeEntryId,
    required this.scoringData,
    required this.currentHoleIndex,
    required this.localScores,
    required this.verifierScores,
    required this.isReadOnly,
    required this.isMatchPlay,
    required this.isDriveAttributionEnabled,
    this.activeScorecard,
    this.localVerifierCard,
    required this.onHoleChanged,
    required this.onScoreChanged,
    required this.onDriveAttributionChanged,
    required this.onScorecardUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final String displayId = activeEntryId ?? targetEntryId;
    final members = ref.watch(allMembersProvider).value ?? [];
    final markerSelection = ref.watch(markerSelectionProvider);
    final manualTee = markerSelection.teeOverrides[displayId];
    
    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: displayId, 
      event: event, 
      membersList: members, 
      manualTeeName: manualTee,
    );
    
    final holes = playerTeeConfig.holes.isEmpty 
        ? List.generate(18, (i) => CourseHole(hole: i + 1, par: 4, si: i + 1)) 
        : playerTeeConfig.holes;

    if (currentHoleIndex >= holes.length) return const SizedBox.shrink();
    
    final currentHole = holes[currentHoleIndex];
    final currentHoleNum = currentHole.hole;
    final par = currentHole.par;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Hole Selector
        BoxyHoleSelector(
          currentHole: currentHoleNum,
          scores: localScores,
          onHoleChanged: onHoleChanged,
        ),
        
        const SizedBox(height: AppSpacing.lg),

        // 2. Main Scoring Area
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hole Info Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOLE $currentHoleNum',
                        style: AppTypography.displaySection.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'PAR $par • SI ${currentHole.si}',
                        style: AppTypography.micro.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: AppTypography.weightBlack,
                        ),
                      ),
                    ],
                  ),
                  _buildTagDetailsToggle(context, currentHoleNum),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xl),

              // Scoring Input
              if (isMatchPlay)
                _buildMatchDualRow(context, currentHoleNum, par)
              else
                _buildStandardScoringRow(context, currentHoleNum, par),

              // Drive Attribution (if enabled and par 4/5)
              if (isDriveAttributionEnabled && par >= 4) ...[
                const SizedBox(height: AppSpacing.xl),
                const BoxyArtSectionTitle(title: 'DRIVE ATTRIBUTION'),
                const SizedBox(height: AppSpacing.md),
                _buildDriveAttributionPicker(context, currentHoleNum),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagDetailsToggle(BuildContext context, int holeNum) {
    final card = activeScorecard;
    final tags = card?.holeTags[holeNum] ?? [];
    final hasTags = tags.any((t) => t == 'GIMME' || t.startsWith('PENALTY_'));
    
    return GestureDetector(
      onTap: isReadOnly ? null : () => _showHoleDetailsPicker(context, holeNum, false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasTags ? AppColors.amber500.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: AppShapes.md,
          border: Border.all(
            color: hasTags ? AppColors.amber500 : AppColors.dark700.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_motion_rounded, size: 16, color: hasTags ? AppColors.amber500 : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'STORY',
              style: AppTypography.micro.copyWith(
                color: hasTags ? AppColors.amber500 : AppColors.textSecondary,
                fontWeight: AppTypography.weightBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHoleDetailsPicker(BuildContext context, int holeNum, bool isVerifier) {
    final card = isVerifier ? localVerifierCard : activeScorecard;
    if (card == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final tags = card.holeTags[holeNum] ?? [];
          final bool isGimme = tags.contains('GIMME');
          final int penaltyCount = tags.where((t) => t.startsWith('PENALTY_')).length;

          return BoxyArtCard(
            margin: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BoxyArtSectionTitle(title: 'Hole Story'),
                const SizedBox(height: AppSpacing.md),
                _buildTagPill(
                  context,
                  label: 'GIMME',
                  icon: Icons.check_circle_outline_rounded,
                  isActive: isGimme,
                  activeColor: AppColors.lime500,
                  onTap: () {
                    _toggleTag(holeNum, 'GIMME', isVerifier);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTagPill(
                  context,
                  label: 'PENALTY${penaltyCount > 0 ? ' ($penaltyCount)' : ''}',
                  icon: Icons.warning_amber_rounded,
                  isActive: penaltyCount > 0,
                  activeColor: AppColors.amber500,
                  onTap: () {
                    _addPenaltyTag(holeNum, isVerifier);
                    setModalState(() {});
                  },
                  onLongPress: () {
                    _clearPenaltyTags(holeNum, isVerifier);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                BoxyArtButton(
                  title: 'Done',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildTagPill(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      onLongPress: isDisabled ? null : onLongPress,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: AppShapes.md,
          border: Border.all(
            color: isActive ? activeColor : (isDark ? AppColors.dark700 : AppColors.dark200),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? activeColor : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.micro.copyWith(
                color: isActive ? activeColor : AppColors.textSecondary,
                fontWeight: isActive ? AppTypography.weightBlack : AppTypography.weightBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTag(int holeNum, String tag, bool isVerifier) {
    final card = isVerifier ? localVerifierCard : activeScorecard;
    if (card == null) return;
    
    final currentTags = List<String>.from(card.holeTags[holeNum] ?? []);
    if (currentTags.contains(tag)) {
      currentTags.remove(tag);
    } else {
      currentTags.add(tag);
    }
    
    final updatedTags = Map<int, List<String>>.from(card.holeTags);
    updatedTags[holeNum] = currentTags;
    
    onScorecardUpdated(card.copyWith(holeTags: updatedTags));
  }

  void _addPenaltyTag(int holeNum, bool isVerifier) {
    final card = isVerifier ? localVerifierCard : activeScorecard;
    if (card == null) return;
    
    final currentTags = List<String>.from(card.holeTags[holeNum] ?? []);
    currentTags.add('PENALTY_${DateTime.now().millisecondsSinceEpoch}');
    
    final updatedTags = Map<int, List<String>>.from(card.holeTags);
    updatedTags[holeNum] = currentTags;
    
    onScorecardUpdated(card.copyWith(holeTags: updatedTags));
  }

  void _clearPenaltyTags(int holeNum, bool isVerifier) {
    final card = isVerifier ? localVerifierCard : activeScorecard;
    if (card == null) return;
    
    final currentTags = List<String>.from(card.holeTags[holeNum] ?? []);
    currentTags.removeWhere((t) => t.startsWith('PENALTY_'));
    
    final updatedTags = Map<int, List<String>>.from(card.holeTags);
    updatedTags[holeNum] = currentTags;
    
    onScorecardUpdated(card.copyWith(holeTags: updatedTags));
  }

  Widget _buildStandardScoringRow(BuildContext context, int currentHoleNum, int par) {
    final score = localScores[currentHoleNum] ?? par;
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildScoreModifierButton(
          context, 
          Icons.remove_rounded, 
          () => onScoreChanged(currentHoleNum, score - 1, isVerifier: false),
          isDisabled: isReadOnly || score <= 1,
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              Text(
                '$score',
                style: AppTypography.displayHeading.copyWith(
                  fontSize: 64,
                  height: 1,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                _getScoreLabel(score, par),
                style: AppTypography.micro.copyWith(
                  color: _getScoreColor(score, par),
                  fontWeight: AppTypography.weightBlack,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),

        _buildScoreModifierButton(
          context, 
          Icons.add_rounded, 
          () => onScoreChanged(currentHoleNum, score + 1, isVerifier: false),
          isDisabled: isReadOnly,
        ),
      ],
    );
  }

  Widget _buildMatchDualRow(BuildContext context, int currentHoleNum, int par) {
    final playerAScore = localScores[currentHoleNum] ?? par;
    final playerBScore = verifierScores[currentHoleNum] ?? par;

    return Column(
      children: [
        _buildDualParticipantRow(
          context, 
          'Player', 
          playerAScore, 
          (s) => onScoreChanged(currentHoleNum, s, isVerifier: false),
          isPrimary: true,
          holeNum: currentHoleNum,
          isVerifier: false,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDualParticipantRow(
          context, 
          'Me', 
          playerBScore, 
          (s) => onScoreChanged(currentHoleNum, s, isVerifier: true),
          isPrimary: false,
          holeNum: currentHoleNum,
          isVerifier: true,
        ),
      ],
    );
  }

  Widget _buildDualParticipantRow(
    BuildContext context, 
    String label, 
    int score, 
    Function(int) onChanged, {
    bool isPrimary = false,
    required int holeNum,
    required bool isVerifier,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppShapes.md,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTypography.micro.copyWith(
                    color: isPrimary ? theme.colorScheme.primary : AppColors.textSecondary,
                    fontWeight: AppTypography.weightBlack,
                  ),
                ),
                const SizedBox(width: 8),
                _buildTagDetailsToggleMini(context, holeNum, isVerifier),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMiniCircleButton(
                context, 
                Icons.remove, 
                () => onChanged(score - 1),
                isDisabled: isReadOnly || score <= 1,
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: AppTypography.displaySection.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              _buildMiniCircleButton(
                context, 
                Icons.add, 
                () => onChanged(score + 1),
                isDisabled: isReadOnly,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagDetailsToggleMini(BuildContext context, int holeNum, bool isVerifier) {
    final card = isVerifier ? localVerifierCard : activeScorecard;
    final tags = card?.holeTags[holeNum] ?? [];
    final hasTags = tags.isNotEmpty;
    
    return GestureDetector(
      onTap: isReadOnly ? null : () => _showHoleDetailsPicker(context, holeNum, isVerifier),
      child: Icon(
        Icons.auto_awesome_motion_rounded, 
        size: 16, 
        color: hasTags ? AppColors.amber500 : AppColors.textSecondary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildDriveAttributionPicker(BuildContext context, int holeNum) {
    final current = activeScorecard?.shotAttributions[holeNum];
    final options = ['LEFT', 'CENTER', 'RIGHT', 'ROUGH', 'BUNKER', 'HAZARD', 'OOB'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: options.map((attr) {
        final isSelected = current == attr;
        return GestureDetector(
          onTap: isReadOnly ? null : () => onDriveAttributionChanged(holeNum, attr),
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.getDriveColor(attr).withValues(alpha: 0.1) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.getDriveColor(attr) : AppColors.dark700.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              AppColors.getDriveIcon(attr),
              color: isSelected ? AppColors.getDriveColor(attr) : AppColors.textSecondary,
              size: 24,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScoreModifierButton(BuildContext context, IconData icon, VoidCallback onTap, {bool isDisabled = false}) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDisabled ? theme.dividerColor.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: isDisabled ? AppColors.textSecondary.withValues(alpha: 0.3) : theme.colorScheme.primary,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCircleButton(BuildContext context, IconData icon, VoidCallback onTap, {bool isDisabled = false}) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDisabled ? Colors.transparent : theme.colorScheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: isDisabled ? theme.dividerColor.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            icon,
            color: isDisabled ? AppColors.textSecondary.withValues(alpha: 0.3) : theme.colorScheme.primary,
            size: 16,
          ),
        ),
      ),
    );
  }

  String _getScoreLabel(int score, int par) {
    final diff = score - par;
    if (diff <= -2) return 'EAGLE';
    if (diff == -1) return 'BIRDIE';
    if (diff == 0) return 'PAR';
    if (diff == 1) return 'BOGEY';
    if (diff == 2) return 'DBL BOGEY';
    return 'OTHERS';
  }

  Color _getScoreColor(int score, int par) {
    final diff = score - par;
    if (diff < 0) return AppColors.coral500;
    if (diff == 0) return AppColors.lime500;
    return AppColors.textSecondary;
  }
}
