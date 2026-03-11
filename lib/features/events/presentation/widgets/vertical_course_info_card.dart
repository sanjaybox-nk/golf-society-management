import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/design_system/design_system.dart';

class VerticalCourseInfoCard extends StatelessWidget {
  final dynamic courseConfig;
  final String? selectedTeeName;
  final String distanceUnit;
  final bool isStableford;
  final int? playerHandicap;
  final List<int?>? scores;
  final CompetitionFormat? format;
  final MaxScoreConfig? maxScoreConfig;
  final int? holeLimit;
  final List<String>? matchPlayResults;

  const VerticalCourseInfoCard({
    super.key,
    required this.courseConfig,
    this.selectedTeeName,
    this.distanceUnit = 'yards',
    this.isStableford = false,
    this.playerHandicap,
    this.scores,
    this.format,
    this.maxScoreConfig,
    this.holeLimit,
    this.matchPlayResults,
  });

  @override
  Widget build(BuildContext context) {
    // Extract course data
    List<int> holePars = [];
    List<int> holeSIs = [];
    
    if (courseConfig is CourseConfig) {
      holePars = List<int>.from(courseConfig.holes.map((h) => h.par));
      holeSIs = List<int>.from(courseConfig.holes.map((h) => h.si));
    } else if (courseConfig is Map && courseConfig['holes'] != null) {
      final holes = courseConfig['holes'] as List<dynamic>;
      holePars = List<int>.from(holes.map((h) => (h['par'] as int?) ?? 4));
      holeSIs = List<int>.from(holes.map((h) => (h['si'] as int?) ?? 0));
    } else {
      holePars = List<int>.filled(18, 4);
      holeSIs = List<int>.generate(18, (i) => i + 1);
    }

    final int playingHcp = playerHandicap ?? 0;
    final bool isMaxScore = format == CompetitionFormat.maxScore && maxScoreConfig != null;

    // Calculate Totals
    int totalStrokes = 0;
    int totalAdjusted = 0;
    int totalPoints = 0;

    if (scores != null) {
      for (int i = 0; i < scores!.length; i++) {
        final score = scores![i];
        if (score == null) continue;
        if (holeLimit != null && i >= holeLimit!) continue;

        totalStrokes += score;

        // Adjusted Score
        int cap = 99;
        if (isMaxScore) {
          final par = holePars[i];
          final si = holeSIs[i];
          int shotsReceived = (playingHcp / 18).floor();
          if (playingHcp % 18 >= si) shotsReceived++;

          switch (maxScoreConfig!.type) {
            case MaxScoreType.fixed: cap = maxScoreConfig!.value; break;
            case MaxScoreType.parPlusX: cap = par + maxScoreConfig!.value; break;
            case MaxScoreType.netDoubleBogey: cap = par + 2 + shotsReceived; break;
          }
        }
        totalAdjusted += score > cap ? cap : score;

        // Points
        if (isStableford && i < holePars.length && i < holeSIs.length) {
          final par = holePars[i];
          final si = holeSIs[i];
          int shotsReceived = (playingHcp / 18).floor();
          if (playingHcp % 18 >= si) shotsReceived++;
          final net = score - shotsReceived;
          totalPoints += (par - net + 2).clamp(0, 10);
        }
      }
    }

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Front 9 (1-9)
              Expanded(
                child: Column(
                  children: [
                    _buildColumnHeader(context, 'FRONT NINE (1-9)'),
                    const SizedBox(height: AppSpacing.sm),
                    for (int i = 0; i < 9; i++)
                      _buildHoleRow(
                        context,
                        holeNumber: i + 1,
                        par: holePars[i],
                        si: holeSIs[i],
                        score: scores?[i],
                        hcp: playingHcp,
                        matchResult: matchPlayResults != null && i < matchPlayResults!.length ? matchPlayResults![i] : null,
                        isCapped: isMaxScore && scores != null && scores![i] != null,
                        maxScoreConfig: maxScoreConfig,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Column 2: Back 9 (10-18)
              Expanded(
                child: Column(
                  children: [
                    _buildColumnHeader(context, 'BACK NINE (10-18)'),
                    const SizedBox(height: AppSpacing.sm),
                    for (int i = 9; i < 18; i++)
                      _buildHoleRow(
                        context,
                        holeNumber: i + 1,
                        par: holePars[i],
                        si: holeSIs[i],
                        score: i < (scores?.length ?? 0) ? scores![i] : null,
                        hcp: playingHcp,
                        matchResult: matchPlayResults != null && i < matchPlayResults!.length ? matchPlayResults![i] : null,
                        isCapped: isMaxScore && scores != null && i < scores!.length && scores![i] != null,
                        maxScoreConfig: maxScoreConfig,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Total Summary row
          _buildSummaryRow(context, totalStrokes, totalPoints, totalAdjusted, isMaxScore),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context, String title) {
    return Text(
      title,
      style: AppTypography.label.copyWith(
        fontSize: AppTypography.sizeCaption,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildHoleRow(
    BuildContext context, {
    required int holeNumber,
    required int par,
    required int si,
    required int? score,
    required int hcp,
    String? matchResult,
    required bool isCapped,
    MaxScoreConfig? maxScoreConfig,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve Points for this hole
    int? points;
    if (isStableford && score != null) {
      int shotsReceived = (hcp / 18).floor();
      if (hcp % 18 >= si) shotsReceived++;
      final net = score - shotsReceived;
      points = (par - net + 2).clamp(0, 10);
    }

    // Resolve Scoring Bubble Color
    Color? bubbleBg;
    Color bubbleText = AppColors.pureWhite;
    final int? scoreDiff = score != null ? score - par : null;

    if (scoreDiff != null) {
      if (scoreDiff <= -2) {
        bubbleBg = AppColors.amber500;
        bubbleText = Colors.black;
      } else if (scoreDiff == -1) {
        bubbleBg = AppColors.lime500;
      } else if (scoreDiff == 0) {
        bubbleBg = isDark ? AppColors.dark400 : AppColors.dark150;
      } else if (scoreDiff == 1) {
        bubbleBg = AppColors.coral400;
      } else {
        bubbleBg = AppColors.coral500;
      }
    }

    // Max Score Adjustment Check
    bool wasAdjusted = false;
    if (isCapped && maxScoreConfig != null && score != null) {
      int shotsReceived = (hcp / 18).floor();
      if (hcp % 18 >= si) shotsReceived++;
      int cap = 99;
      switch (maxScoreConfig.type) {
        case MaxScoreType.fixed: cap = maxScoreConfig.value; break;
        case MaxScoreType.parPlusX: cap = par + maxScoreConfig.value; break;
        case MaxScoreType.netDoubleBogey: cap = par + 2 + shotsReceived; break;
      }
      if (score > cap) wasAdjusted = true;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacityLow),
        borderRadius: AppShapes.md,
        border: wasAdjusted ? Border.all(color: AppColors.amber500.withValues(alpha: AppColors.opacityMedium)) : null,
      ),
      child: Row(
        children: [
          // Hole Num
          SizedBox(
            width: 20,
            child: Text(
              '$holeNumber',
              style: AppTypography.labelStrong.copyWith(fontSize: 16),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Par/SI
          Expanded(
            child: Text(
              'P$par SI$si',
              style: AppTypography.caption.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
                fontSize: 13,
                fontWeight: AppTypography.weightBold,
              ),
            ),
          ),
          // Score Bubble
          if (score != null) ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: bubbleBg,
                shape: BoxShape.circle,
                boxShadow: scoreDiff != null && scoreDiff < 0 
                  ? [BoxShadow(color: bubbleBg!.withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 1)] 
                  : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '$score',
                style: TextStyle(
                  color: bubbleText,
                  fontSize: 15,
                  fontWeight: AppTypography.weightBlack,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ] else
             Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: Text('-', style: AppTypography.caption.copyWith(color: AppColors.dark400)),
            ),

          // Points
          if (isStableford) ...[
            SizedBox(
              width: 24,
              child: Center(
                child: Text(
                  '${points ?? '-'}',
                  style: AppTypography.labelStrong.copyWith(
                    fontSize: 15,
                    color: (points != null && points > 2) ? AppColors.lime500 : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Text(
              'pts',
              style: AppTypography.nano.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityLow)),
            ),
          ],
          
          // Match Result
          if (matchResult != null && matchResult.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.xs),
            _buildMatchIcon(matchResult),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchIcon(String result) {
    Color color = AppColors.dark400;
    if (result == 'W') color = AppColors.lime500;
    if (result == 'L') color = AppColors.coral500;
    
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        result,
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: AppTypography.weightBlack),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, int strokes, int points, int adjusted, bool isMaxScore) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: AppColors.opacityLow),
        borderRadius: AppShapes.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat('STROKES', strokes, isMaxScore ? adjusted : null),
          if (isStableford)
            _buildStat('POINTS', points, null, color: AppColors.lime500),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int val, int? adj, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.nano.copyWith(
            color: color?.withValues(alpha: AppColors.opacityHigh) ?? AppColors.dark300,
            letterSpacing: 1.0,
          ),
        ),
        Row(
          children: [
            Text(
              '$val',
              style: AppTypography.displayUI.copyWith(
                fontSize: AppTypography.sizeBody,
                color: color ?? AppColors.dark60,
              ),
            ),
            if (adj != null && adj != val) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                '($adj)',
                style: AppTypography.labelStrong.copyWith(
                  fontSize: AppTypography.sizeLabel,
                  color: AppColors.amber500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
