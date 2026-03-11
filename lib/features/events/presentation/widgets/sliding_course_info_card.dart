import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/design_system/design_system.dart';

class SlidingCourseInfoCard extends StatefulWidget {
  final dynamic courseConfig;
  final String? selectedTeeName;
  final String distanceUnit;
  final bool isStableford;
  final int? playerHandicap;
  final List<int?>? scores;
  final Color? headerColor;
  final CompetitionFormat? format;
  final MaxScoreConfig? maxScoreConfig;
  final int? holeLimit;
  final List<String>? matchPlayResults;

  const SlidingCourseInfoCard({
    super.key,
    required this.courseConfig,
    this.selectedTeeName,
    this.distanceUnit = 'yards',
    this.isStableford = false,
    this.playerHandicap,
    this.scores,
    this.headerColor,
    this.format,
    this.maxScoreConfig,
    this.holeLimit,
    this.matchPlayResults,
  });

  @override
  State<SlidingCourseInfoCard> createState() => _SlidingCourseInfoCardState();
}

class _SlidingCourseInfoCardState extends State<SlidingCourseInfoCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract course data - standardise to lists
    List<int> holePars = [];
    List<int> holeSIs = [];
    
    if (widget.courseConfig is CourseConfig) {
      holePars = List<int>.from(widget.courseConfig.holes.map((h) => h.par));
      holeSIs = List<int>.from(widget.courseConfig.holes.map((h) => h.si));
    } else if (widget.courseConfig is Map && widget.courseConfig['holes'] != null) {
      final holes = widget.courseConfig['holes'] as List<dynamic>;
      holePars = List<int>.from(holes.map((h) => (h['par'] as int?) ?? 4));
      holeSIs = List<int>.from(holes.map((h) => (h['si'] as int?) ?? 0));
    } else {
      holePars = List<int>.filled(18, 4);
      holeSIs = List<int>.generate(18, (i) => i + 1);
    }

    // Extract Distances based on tee
    List<int> holeDistances = [];
    if (widget.courseConfig is CourseConfig) {
      final course = widget.courseConfig as CourseConfig;
      if (course.tees.isNotEmpty) {
        final tee = course.tees.firstWhere(
          (t) => t.name == widget.selectedTeeName,
          orElse: () => course.tees.first,
        );
        holeDistances = tee.yardages;
      }
    } else if (widget.courseConfig is Map) {
      final tees = widget.courseConfig['tees'] as List<dynamic>?;
      if (tees != null && tees.isNotEmpty) {
        final tee = tees.firstWhere(
          (t) => t['name'] == widget.selectedTeeName,
          orElse: () => tees.first,
        );
        // Try 'yardages' directly first, then map from 'holes' if available
        if (tee['yardages'] != null) {
          holeDistances = List<int>.from(tee['yardages'] as List<dynamic>);
        } else if (tee['holes'] != null) {
          final holes = tee['holes'] as List<dynamic>;
          holeDistances = List<int>.from(holes.map((h) => (h['distance'] as int?) ?? 0));
        }
      }
    }
    
    if (holeDistances.length < 18) {
      holeDistances = List<int>.filled(18, 0);
    }

    // Totals for the summary row
    final front9Pars = holePars.take(9).fold<int>(0, (a, b) => a + b);
    final back9Pars = holePars.skip(9).take(9).fold<int>(0, (a, b) => a + b);
    final totalPar = front9Pars + back9Pars;

    int totalStrokes = 0;
    int totalPoints = 0;
    int holesPlayed = 0;
    
    if (widget.scores != null) {
      for (int i = 0; i < widget.scores!.length; i++) {
        final s = widget.scores![i];
        if (s != null) {
          totalStrokes += s;
          holesPlayed++;
          
          if (widget.isStableford && widget.playerHandicap != null && i < holePars.length) {
            final par = holePars[i];
            final si = holeSIs[i];
            int shots = (widget.playerHandicap! / 18).floor();
            if (widget.playerHandicap! % 18 >= si) shots++;
            totalPoints += (par - (s - shots) + 2).clamp(0, 10);
          }
        }
      }
    }

    // Calculate dynamic height based on row count
    final bool isStrokePlay = !widget.isStableford && widget.matchPlayResults == null;
    final bool showNet = isStrokePlay && widget.playerHandicap != null;
    
    int rowCount = 5; // HOLE, DIS, PAR, SI, SCR
    if (widget.isStableford) rowCount++;
    if (widget.matchPlayResults != null) rowCount++;
    if (showNet) rowCount++;
    
    final double totalViewHeight = (rowCount * 32.0) + (rowCount - 1);

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header / Tab row
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.actionGreen,
              // Removed AppShapes.rLg to rely on parent BoxyArtCard clipping
              borderRadius: BorderRadius.zero, 
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: _currentPage == 1 ? 1.0 : 0.3,
                  child: const Icon(Icons.chevron_left_rounded, color: Colors.black, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildTab(context, 'FRONT 9', 0),
                const SizedBox(width: AppSpacing.lg),
                _buildTab(context, 'BACK 9', 1),
                const SizedBox(width: AppSpacing.sm),
                Opacity(
                  opacity: _currentPage == 0 ? 1.0 : 0.3,
                  child: const Icon(Icons.chevron_right_rounded, color: Colors.black, size: 20),
                ),
              ],
            ),
          ),

          // Main PageView area
          SizedBox(
            height: totalViewHeight, 
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              children: [
                _buildNineView(
                  context, 
                  'OUT', 
                  holePars.take(9).toList(), 
                  holeSIs.take(9).toList(), 
                  holeDistances.take(9).toList(),
                  front9Pars, 1
                ),
                _buildNineView(
                  context, 
                  'IN', 
                  holePars.skip(9).take(9).toList(), 
                  holeSIs.skip(9).take(9).toList(), 
                  holeDistances.skip(9).take(9).toList(),
                  back9Pars, 10
                ),
              ],
            ),
          ),

          // Totals Footer (Constant)
          _buildTotalsFooter(context, totalPar, totalStrokes, totalPoints, holesPlayed),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index) {
    final bool isActive = _currentPage == index;
    return GestureDetector(
      onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelStrong.copyWith(
              fontSize: 12,
              color: Colors.black.withValues(alpha: isActive ? 1.0 : 0.5),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 20 : 0,
            height: 2,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildNineView(BuildContext context, String label, List<int> pars, List<int> sis, List<int> distances, int ninePar, int startHole) {
    final String distLabel = widget.distanceUnit.toUpperCase().contains('METRE') ? 'MTR' : 'YDS';
    final int nineDist = distances.fold<int>(0, (a, b) => a + b);
    final bool isStrokePlay = !widget.isStableford && widget.matchPlayResults == null;
    final bool showNet = isStrokePlay && widget.playerHandicap != null;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(), // Handled by PageView
      child: Column(
        children: [
          // Horizontal numbers row
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
                Expanded(child: _buildValueCell(context, distances[i] > 0 ? '${distances[i]}' : '-', isDimmed: true, fontSize: 13, fontWeight: FontWeight.w300)),
              _buildTotalCell(context, nineDist > 0 ? '$nineDist' : '-', isDimmed: true, fontSize: 13, fontWeight: FontWeight.w300),
            ],
          ),
          const Divider(height: 1),
          // Par Row
          (() {
            final teeColor = AppColors.getTeeColor(widget.selectedTeeName);
            final teeTextColor = teeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
            return Container(
              color: teeColor,
              child: Row(
                children: [
                  _buildSideLabel(context, 'PAR', color: teeTextColor),
                  for (int i = 0; i < 9; i++)
                    Expanded(child: _buildValueCell(context, '${pars[i]}', isBold: true, color: teeTextColor)),
                  _buildTotalCell(context, '$ninePar', isBold: true, color: teeTextColor, bgColor: Colors.transparent),
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
                Expanded(child: _buildValueCell(context, '${sis[i]}', isDimmed: true, fontSize: 13)),
              _buildTotalCell(context, '', isDimmed: true, fontSize: 13),
            ],
          ),
          const Divider(height: 1),
          // Score Row
          Row(
            children: [
              _buildSideLabel(context, 'STR'),
              for (int i = 0; i < 9; i++)
                (() {
                  final idx = startHole - 1 + i;
                  final s = (widget.scores != null && idx < widget.scores!.length) ? widget.scores![idx] : null;
                  return Expanded(child: _buildScoreCell(context, s, pars[i]));
                })(),
              _buildTotalCell(context, _calcNineTotal(startHole), isBold: true),
            ],
          ),
          if (widget.isStableford) ...[
            const Divider(height: 1),
            // Points Row
            Row(
              children: [
                _buildSideLabel(context, 'PTS'),
                for (int i = 0; i < 9; i++)
                  (() {
                    final idx = startHole - 1 + i;
                    final s = (widget.scores != null && idx < widget.scores!.length) ? widget.scores![idx] : null;
                    final p = _calcPoints(s, pars[i], sis[i]);
                    return Expanded(child: _buildPointsCell(context, p));
                  })(),
                _buildTotalCell(context, _calcNinePointsTotal(startHole, pars, sis), isBold: true),
              ],
            ),
          ],
          if (widget.matchPlayResults != null) ...[
            const Divider(height: 1),
            // Match Status Row
            Row(
              children: [
                _buildSideLabel(context, 'MATCH'),
                for (int i = 0; i < 9; i++)
                  (() {
                    final idx = startHole - 1 + i;
                    final token = idx < widget.matchPlayResults!.length ? widget.matchPlayResults![idx] : '-';
                    return Expanded(child: _buildMatchTokenCell(context, token));
                  })(),
                _buildTotalCell(context, '', isBold: true),
              ],
            ),
          ],
          if (showNet) ...[
            const Divider(height: 1),
            // Net Score Row
            Row(
              children: [
                _buildSideLabel(context, 'NET'),
                for (int i = 0; i < 9; i++)
                  (() {
                    final idx = startHole - 1 + i;
                    final s = (widget.scores != null && idx < widget.scores!.length) ? widget.scores![idx] : null;
                    final n = _calcNet(s, sis[i]);
                    return Expanded(child: _buildValueCell(context, n != null ? '$n' : '-', isDimmed: true));
                  })(),
                _buildTotalCell(context, _calcNineNetTotal(startHole, sis), isDimmed: true, isBold: true),
              ],
            ),
          ],
        ],
      ),
    );
  }

  int? _calcNet(int? score, int si) {
    if (score == null || widget.playerHandicap == null) return null;
    int shots = (widget.playerHandicap! / 18).floor();
    if (widget.playerHandicap! % 18 >= si) shots++;
    return score - shots;
  }

  String _calcNineNetTotal(int startHole, List<int> sis) {
    if (widget.scores == null || widget.playerHandicap == null) return '-';
    int total = 0;
    bool hasAny = false;
    for (int i = 0; i < 9; i++) {
      final idx = startHole - 1 + i;
      final s = (idx < widget.scores!.length) ? widget.scores![idx] : null;
      if (s != null) {
        hasAny = true;
        total += _calcNet(s, sis[i]) ?? 0;
      }
    }
    return hasAny ? total.toString() : '-';
  }

  Widget _buildMatchTokenCell(BuildContext context, String token) {
    Color? bg;
    Color fg = Colors.white;
    
    if (token == 'W') {
      bg = AppColors.lime500;
    } else if (token == 'L') {
      bg = AppColors.coral500;
    } else if (token == 'H') {
      bg = AppColors.dark300;
    }
    
    return Container(
      height: 32,
      alignment: Alignment.center,
      child: bg != null 
        ? Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              token,
              style: AppTypography.labelStrong.copyWith(fontSize: 10, color: fg),
            ),
          )
        : Text('-', style: AppTypography.labelStrong.copyWith(fontSize: 14, color: AppColors.dark400)),
    );
  }

  int? _calcPoints(int? score, int par, int si) {
    if (score == null || widget.playerHandicap == null) return null;
    int shots = (widget.playerHandicap! / 18).floor();
    if (widget.playerHandicap! % 18 >= si) shots++;
    return (par - (score - shots) + 2).clamp(0, 10);
  }

  String _calcNinePointsTotal(int startHole, List<int> pars, List<int> sis) {
    if (widget.scores == null || widget.playerHandicap == null) return '-';
    int total = 0;
    bool hasAny = false;
    for (int i = 0; i < 9; i++) {
      final idx = startHole - 1 + i;
      final s = (idx < widget.scores!.length) ? widget.scores![idx] : null;
      if (s != null) {
        hasAny = true;
        total += _calcPoints(s, pars[i], sis[i]) ?? 0;
      }
    }
    return hasAny ? total.toString() : '-';
  }

  Widget _buildPointsCell(BuildContext context, int? points) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      child: Text(
        points?.toString() ?? '-',
        style: AppTypography.labelStrong.copyWith(
          fontSize: 14,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  String _calcNineTotal(int startHole) {
    if (widget.scores == null) return '-';
    final slice = widget.scores!.skip(startHole - 1).take(9).where((s) => s != null).cast<int>();
    if (slice.isEmpty) return '-';
    return slice.fold<int>(0, (a, b) => a + b).toString();
  }

  Widget _buildSideLabel(BuildContext context, String text, {Color? color}) {
    return Container(
      width: 50,
      height: 32,
      padding: const EdgeInsets.only(left: AppSpacing.md),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTypography.labelStrong.copyWith(
          fontSize: 9, 
          color: color ?? AppColors.dark300, 
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildValueCell(BuildContext context, String text, {bool isHeader = false, bool isDimmed = false, bool isBold = false, double? fontSize, FontWeight? fontWeight, Color? color}) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTypography.labelStrong.copyWith(
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? (isBold ? AppTypography.weightBlack : (isHeader ? AppTypography.weightBold : AppTypography.weightSemibold)),
          color: color ?? (isHeader ? AppColors.dark200 : (isDimmed ? AppColors.dark300 : theme.colorScheme.onSurface)),
        ),
      ),
    );
  }

  Widget _buildTotalCell(BuildContext context, String text, {bool isHeader = false, bool isDimmed = false, bool isBold = false, Color? color, double? fontSize, FontWeight? fontWeight, Color? bgColor}) {
    return Container(
      width: 45,
      height: 32,
      alignment: Alignment.center,
      color: bgColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacityLow),
      child: Text(
        text,
        style: AppTypography.labelStrong.copyWith(
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? (isBold ? FontWeight.w900 : FontWeight.normal),
          color: color ?? (isHeader ? AppColors.dark200 : (isDimmed ? AppColors.dark300 : theme.colorScheme.onSurface)),
        ),
      ),
    );
  }

  Widget _buildScoreCell(BuildContext context, int? score, int par) {
    if (score == null) return _buildValueCell(context, '-');
    
    final diff = score - par;
    
    Color? bg;
    Color fg = Colors.white;
    
    if (diff <= -2) {
      bg = AppColors.amber500; // Eagle - keep achievement amber
      fg = Colors.black;
    } else if (diff == -1) {
      bg = AppColors.coral500; // Birdie - Red
    } else if (diff == 0) {
      bg = AppColors.dark300; // Par - Light Grey
    } else if (diff == 1) {
      bg = AppColors.dark900; // Bogey - Blue/Black
    } else {
      bg = AppColors.dark600; // Double Bogey+ - Dark Grey
    }

    return Container(
      height: 32,
      alignment: Alignment.center,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          '$score',
          style: AppTypography.labelStrong.copyWith(
            fontSize: 14,
            color: fg,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalsFooter(BuildContext context, int totalPar, int totalStrokes, int totalPoints, int holesPlayed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: AppColors.opacityLow),
        // Removed AppShapes.rLg to rely on parent BoxyArtCard clipping
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('TOTAL', totalStrokes.toString(), sub: 'THRU $holesPlayed'),
          if (widget.isStableford)
            _buildStatItem('POINTS', totalPoints.toString()),
          _buildStatItem('PAR', totalPar.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {String? sub, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.nano.copyWith(color: AppColors.dark300, letterSpacing: 1.0),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTypography.labelStrong.copyWith(
                fontSize: 17,
                color: color ?? theme.colorScheme.onSurface,
              ),
            ),
            if (sub != null) ...[
              const SizedBox(width: 4),
              Text(
                sub,
                style: AppTypography.nano.copyWith(color: AppColors.dark400, fontSize: 8),
              ),
            ],
          ],
        ),
      ],
    );
  }

  ThemeData get theme => Theme.of(context);
}
