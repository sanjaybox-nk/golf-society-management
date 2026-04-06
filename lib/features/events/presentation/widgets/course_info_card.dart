import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/design_system/design_system.dart';

class CourseInfoCard extends StatelessWidget {
  final dynamic courseConfig;
  final String? selectedTeeName;
  final String distanceUnit;
  final bool isStableford;
  final List<int?>? holeScores; // Main raw scores
  final List<int?>? holeNetScores; // Pre-calculated net
  final List<int?>? holePoints; // Pre-calculated points
  final List<int>? holeDistances;
  final List<int>? holePars;
  final List<int>? holeSIs;
  final Color? headerColor; // [NEW] Optional override for header row background
  final CompetitionFormat? format; // [NEW] Current competition format
  final MaxScoreConfig? maxScoreConfig; // [NEW] Configuration for Max Score capping
  final bool isNet; // [NEW] Whether to show Net scores/totals
  final int? holeLimit;
  final List<CourseScoreRow>? additionalRows;
  final String? mainRowLabel; 
  final int? overrideTotalPoints;
  final List<String>? matchPlayResults;

  const CourseInfoCard({
    super.key,
    required this.courseConfig,
    this.selectedTeeName,
    this.distanceUnit = 'yards',
    this.isStableford = false,
    this.holeScores,
    this.holeNetScores,
    this.holePoints,
    this.holeDistances,
    this.holePars,
    this.holeSIs,
    this.headerColor,
    this.format,
    this.maxScoreConfig,
    this.holeLimit, 
    this.additionalRows, 
    this.mainRowLabel, 
    this.isNet = true, 
    this.overrideTotalPoints,
    this.matchPlayResults,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Resolve Course Data
    final List<int> pars = holePars ?? (courseConfig is CourseConfig ? (courseConfig as CourseConfig).holes.map((h) => h.par).toList() : List.filled(18, 4));
    final List<int> sis = holeSIs ?? (courseConfig is CourseConfig ? (courseConfig as CourseConfig).holes.map((h) => h.si).toList() : List.generate(18, (i) => i + 1));
    final List<int> dists = holeDistances ?? (courseConfig is CourseConfig ? (courseConfig as CourseConfig).holes.map((h) => (h.yardage ?? 0)).toList() : List.filled(18, 0));

    // 2. Totals Calculation (Simple sum of pre-calculated data)
    final int holesPlayed = (holeScores ?? []).where((s) => s != null).length;
    final int totalStrokes = (holeScores ?? []).whereType<int>().fold<int>(0, (a, b) => a + b);
    final int totalNetStrokes = (holeNetScores ?? []).whereType<int>().fold<int>(0, (a, b) => a + b);
    final int totalPoints = overrideTotalPoints ?? (holePoints ?? []).whereType<int>().fold<int>(0, (a, b) => a + b);
    final int totalPar = pars.fold<int>(0, (a, b) => a + b);

    // To Par calculation
    int? toParDiff;
    if (holesPlayed > 0) {
      if (isStableford) {
        toParDiff = totalPoints - (holesPlayed * 2);
      } else {
        final playedPar = pars.take(holesPlayed).fold<int>(0, (a, b) => a + b);
        toParDiff = totalNetStrokes - playedPar;
      }
    }

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildHeaderRow(context, 'FRONT 9'),
          _buildNineHoles(context, 'OUT', 1, pars, sis, dists, holeScores, holeNetScores, holePoints),
          const SizedBox(height: AppSpacing.sm),
          _buildHeaderRow(context, 'BACK 9'),
          _buildNineHoles(context, 'IN', 10, pars, sis, dists, holeScores, holeNetScores, holePoints),
          _buildTotalsFooter(context, totalStrokes, totalNetStrokes, totalPoints, totalPar, holesPlayed, toParDiff),
        ],
      ),
    );
  }

  Widget _buildNineHoles(
    BuildContext context, 
    String label, 
    int startHole,
    List<int> pars,
    List<int> sis,
    List<int> dists,
    List<int?>? scores,
    List<int?>? nets,
    List<int?>? points,
  ) {
    final startIdx = startHole - 1;
    final ninePars = pars.skip(startIdx).take(9).toList();
    final nineSIs = sis.skip(startIdx).take(9).toList();
    final nineDists = dists.skip(startIdx).take(9).toList();
    final nineScores = (scores ?? List.filled(18, null)).skip(startIdx).take(9).toList();
    final ninePoints = (points ?? List.filled(18, null)).skip(startIdx).take(9).toList();

    final String distLabel = distanceUnit.toUpperCase().contains('METRE') ? 'MTR' : 'YDS';
    final int nineDistTotal = nineDists.fold<int>(0, (a, b) => a + b);
    final int nineParTotal = ninePars.fold<int>(0, (a, b) => a + b);
    final int nineScoreTotal = nineScores.whereType<int>().fold<int>(0, (a, b) => a + b);

    return Column(
      children: [
        // Hole Row
        Row(
          children: [
            _buildSideLabel(context, 'HOLE'),
            for (int i = 0; i < 9; i++)
              Expanded(child: _buildValueCell(context, '${startHole + i}', isHeader: true)),
            _buildTotalCell(context, label, isHeader: true),
          ],
        ),
        const Divider(height: 1),

        // Distance Row
        Row(
          children: [
            _buildSideLabel(context, distLabel),
            for (int i = 0; i < 9; i++)
              Expanded(child: _buildValueCell(context, nineDists[i] > 0 ? '${nineDists[i]}' : '-', isDimmed: true, fontSize: 12, fontWeight: FontWeight.w300)),
            _buildTotalCell(context, nineDistTotal > 0 ? '$nineDistTotal' : '-', isDimmed: true, fontSize: 12, fontWeight: FontWeight.w300),
          ],
        ),
        const Divider(height: 1),

        // Par Row (Yellow/Tee styled)
        (() {
          final teeColor = AppColors.getTeeColor(selectedTeeName);
          final teeTextColor = teeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
          return Container(
            color: teeColor,
            child: Row(
              children: [
                _buildSideLabel(context, 'PAR', color: teeTextColor),
                for (int i = 0; i < 9; i++)
                  Expanded(child: _buildValueCell(context, '${ninePars[i]}', color: teeTextColor, isBold: true)),
                _buildTotalCell(context, '$nineParTotal', color: teeTextColor, isBold: true, bgColor: teeColor),
              ],
            ),
          );
        })(),
        const Divider(height: 1),

        // SI Row
        Row(
          children: [
            _buildSideLabel(context, 'SI'),
            for (int i = 0; i < 9; i++)
              Expanded(child: _buildValueCell(context, '${nineSIs[i]}')),
            _buildTotalCell(context, ''),
          ],
        ),
        const Divider(height: 1),

        // Main Score Row (STR)
        Row(
          children: [
            _buildSideLabel(context, mainRowLabel ?? 'STR'),
            for (int i = 0; i < 9; i++)
              Expanded(child: _buildScoreCell(context, nineScores[i], ninePars[i])),
            _buildTotalCell(context, nineScoreTotal > 0 ? '$nineScoreTotal' : '-', isBold: true),
          ],
        ),
        const Divider(height: 1),

        // Partner Rows
        if (additionalRows != null) ...[
          for (var row in additionalRows!)
            _buildPartnerScoreRow(context, row, startIdx, ninePars),
        ],

        // PTS Row (Stableford only)
        if (isStableford) ...[
          Row(
            children: [
              _buildSideLabel(context, 'PTS'),
              for (int i = 0; i < 9; i++)
                Expanded(child: _buildValueCell(context, ninePoints[i] != null || nineScores[i] != null ? (ninePoints[i]?.toString() ?? '-') : '-', isDimmed: true)),
              _buildTotalCell(context, ninePoints.whereType<int>().fold<int>(0, (a, b) => a + b).toString(), isDimmed: true, isBold: true),
            ],
          ),
          const Divider(height: 1),
        ],
      ],
    );
  }

  Widget _buildPartnerScoreRow(BuildContext context, CourseScoreRow row, int startIdx, List<int> pars) {
    final nineScores = row.scores.skip(startIdx).take(9).toList();
    final total = nineScores.whereType<int>().fold<int>(0, (a, b) => a + b);

    return Column(
      children: [
        Row(
          children: [
            _buildSideLabel(context, row.playerName.toUpperCase()),
            for (int i = 0; i < 9; i++)
              Expanded(child: _buildScoreCell(context, nineScores[i], pars[i])),
            _buildTotalCell(context, total > 0 ? '$total' : '-', isBold: true),
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildTotalsFooter(BuildContext context, int strokes, int nets, int points, int par, int thru, int? toPar) {
    final toParColor = (toPar ?? 0) < 0 ? AppColors.coral500 : ((toPar ?? 0) > 0 ? AppColors.dark900 : AppColors.dark900);
    final toParString = toPar == null ? '-' : (toPar == 0 ? 'E' : (toPar > 0 ? '+$toPar' : '$toPar'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(AppColors.opacityLow),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('TOTAL', strokes.toString(), sub: 'THRU $thru'),
          if (isStableford)
            _buildStatItem('POINTS', points.toString())
          else if (thru > 0) ...[
            if (isNet) _buildStatItem('NET', nets.toString()),
            _buildStatItem('TO PAR', toParString, color: toParColor),
          ],
          _buildStatItem('PAR', par.toString()),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeaderRow(BuildContext context, String text) {
    return Container(
      height: 28,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(AppColors.opacityLow),
      ),
      child: Center(
        child: Text(text, style: AppTypography.labelStrong.copyWith(fontSize: 10, color: AppColors.dark900, fontWeight: AppTypography.weightExtraBold, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildSideLabel(BuildContext context, String text, {Color? color}) {
    return Container(
      width: 50, height: 28, padding: const EdgeInsets.only(left: 8), alignment: Alignment.centerLeft,
      child: Text(text, style: AppTypography.labelStrong.copyWith(fontSize: 9, color: color ?? AppColors.dark200, fontWeight: AppTypography.weightExtraBold, letterSpacing: 0.5)),
    );
  }

  Widget _buildValueCell(BuildContext context, String text, {bool isHeader = false, bool isDimmed = false, bool isBold = false, Color? color, double? fontSize, FontWeight? fontWeight}) {
    return Container(
      height: 28, alignment: Alignment.center,
      child: Text(text, style: AppTypography.labelStrong.copyWith(fontSize: fontSize ?? 13, fontWeight: fontWeight ?? (isBold ? AppTypography.weightBlack : (isHeader ? AppTypography.weightBold : AppTypography.weightSemibold)), color: color ?? (isHeader ? AppColors.dark200 : (isDimmed ? AppColors.dark300 : AppColors.dark900)))),
    );
  }

  Widget _buildTotalCell(BuildContext context, String text, {bool isHeader = false, bool isDimmed = false, bool isBold = false, Color? color, double? fontSize, FontWeight? fontWeight, Color? bgColor}) {
    return Container(
      width: 45, height: 28, alignment: Alignment.center,
      color: bgColor ?? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(AppColors.opacityLow),
      child: Text(text, style: AppTypography.labelStrong.copyWith(fontSize: fontSize ?? 13, fontWeight: fontWeight ?? (isBold ? FontWeight.w900 : FontWeight.normal), color: color ?? (isHeader ? AppColors.dark200 : (isDimmed ? AppColors.dark300 : AppColors.dark900)))),
    );
  }

  Widget _buildScoreCell(BuildContext context, int? score, int par) {
    if (score == null) return _buildValueCell(context, '-');
    final diff = score - par;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color? bg; Color fg = Colors.white; BoxBorder? border;
    if (diff <= -2) { bg = AppColors.amber500; fg = Colors.black; }
    else if (diff == -1) { bg = AppColors.coral500; }
    else if (diff == 0) { bg = Colors.transparent; fg = isDark ? AppColors.pureWhite : AppColors.dark900; border = Border.all(color: isDark ? AppColors.dark500 : AppColors.lightBorder, width: 1); }
    else if (diff == 1) { bg = AppColors.dark900; }
    else { bg = AppColors.dark600; }

    return Container(height: 28, alignment: Alignment.center,
      child: Container(
        width: 22, 
        height: 22, 
        decoration: BoxDecoration(
          color: bg, 
          shape: diff < 0 ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: diff < 0 ? null : BorderRadius.circular(4), 
          border: border,
        ), 
        alignment: Alignment.center,
        child: Text('$score', style: AppTypography.labelStrong.copyWith(fontSize: 13, color: fg))),
    );
  }

  Widget _buildStatItem(String label, String value, {String? sub, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.nano.copyWith(color: AppColors.dark900, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: AppTypography.labelStrong.copyWith(fontSize: 16, color: color ?? AppColors.dark900)),
            if (sub != null) ...[const SizedBox(width: 4), Text(sub, style: AppTypography.nano.copyWith(color: AppColors.dark400, fontSize: 8))],
          ],
        ),
      ],
    );
  }
}

class CourseScoreRow {
  final String? id;
  final String playerName;
  final List<int?> scores;
  final List<int?>? netScores;
  final List<int?>? points;
  final int? handicap;
  final Color? color;
  final Set<int>? countingHoles;

  const CourseScoreRow({
    this.id,
    required this.playerName,
    required this.scores,
    this.netScores,
    this.points,
    this.handicap,
    this.color,
    this.countingHoles,
  });
}
