import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:golf_society/design_system/design_system.dart';

/// Single source of truth for all scorecard grid rendering.
/// Use [paged] = true for the sliding My Card view (one nine at a time).
/// Use [paged] = false (default) for the full modal view (both nines stacked).
class CourseInfoCard extends ConsumerStatefulWidget {
  final dynamic courseConfig;
  final String? selectedTeeName;
  final String distanceUnit;
  final bool isStableford;
  final bool isNet;
  final bool paged;

  final List<int?>? holeScores;
  final List<int?>? holeNetScores;
  final List<int?>? holePoints;
  final List<int>? holePars;
  final List<int>? holeSIs;
  final List<int>? holeDistances;

  final int? playerHandicap;
  final double? handicapAllowance;

  final CompetitionFormat? format;
  final MaxScoreConfig? maxScoreConfig;
  final List<String>? matchPlayResults;
  final int? conclusionHole;
  final int? overrideTotalPoints;

  final String? mainRowLabel;
  final String? tieBreakLabel;
  final Set<int> conflictedHoles;
  final Map<int, List<String>>? holeTags;
  final List<CourseScoreRow>? additionalRows;
  final Widget? personPicker;
  final bool markerVerified;
  final List<int?>? verifierScores;
  final bool showYardage;

  const CourseInfoCard({
    super.key,
    required this.courseConfig,
    this.selectedTeeName,
    this.distanceUnit = 'yards',
    this.isStableford = false,
    this.isNet = true,
    this.paged = false,
    this.holeScores,
    this.holeNetScores,
    this.holePoints,
    this.holePars,
    this.holeSIs,
    this.holeDistances,
    this.playerHandicap,
    this.handicapAllowance,
    this.format,
    this.maxScoreConfig,
    this.matchPlayResults,
    this.conclusionHole,
    this.overrideTotalPoints,
    this.mainRowLabel,
    this.tieBreakLabel,
    this.conflictedHoles = const {},
    this.holeTags,
    this.additionalRows,
    this.personPicker,
    this.markerVerified = false,
    this.verifierScores,
    this.showYardage = false,
  });

  @override
  ConsumerState<CourseInfoCard> createState() => _CourseInfoCardState();
}

class _CourseInfoCardState extends ConsumerState<CourseInfoCard> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double get _cellH => widget.paged ? 32.0 : 28.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);
    final pointsColor = Color(config.effectivePointsColor);

    // Resolve course arrays
    final List<int> pars = widget.holePars ??
        (widget.courseConfig is CourseConfig
            ? (widget.courseConfig as CourseConfig).holes.map((h) => h.par).toList()
            : List.filled(18, 4));
    final List<int> sis = widget.holeSIs ??
        (widget.courseConfig is CourseConfig
            ? (widget.courseConfig as CourseConfig).holes.map((h) => h.si).toList()
            : List.generate(18, (i) => i + 1));
    final List<int> dists = widget.holeDistances ??
        (widget.courseConfig is CourseConfig
            ? (widget.courseConfig as CourseConfig).holes.map((h) => h.yardage ?? 0).toList()
            : _extractDistancesFromConfig());

    // Compute net scores if not pre-supplied
    final bool isGross = (widget.handicapAllowance ?? (widget.isNet ? 1.0 : 0.0)) == 0;
    final bool showNet = widget.isNet && !widget.isStableford && !isGross;

    List<int?> netScores = widget.holeNetScores ?? [];
    List<int?> pts = widget.holePoints ?? [];

    if ((netScores.isEmpty || pts.isEmpty) &&
        !isGross && widget.playerHandicap != null && (widget.holeScores?.isNotEmpty ?? false)) {
      final result = ScoringCalculator.calculate(
        holeScores: widget.holeScores!,
        holes: widget.courseConfig is CourseConfig
            ? (widget.courseConfig as CourseConfig).holes
            : [],
        playingHandicap: widget.playerHandicap!.toDouble(),
        format: widget.format ??
            (widget.isStableford ? CompetitionFormat.stableford : CompetitionFormat.stroke),
        maxScoreConfig: widget.maxScoreConfig,
      );
      if (netScores.isEmpty) netScores = result.holeNetScores;
      if (pts.isEmpty) pts = result.holePoints;
    }

    // Totals
    bool notPlayedIdx(int idx) {
      if (widget.holeTags?[idx + 1]?.contains('NOT_PLAYED') == true) return true;
      return widget.matchPlayResults != null &&
          widget.matchPlayResults!.length > idx &&
          widget.matchPlayResults![idx].isEmpty;
    }

    final int totalStrokes = (widget.holeScores ?? [])
        .asMap()
        .entries
        .where((e) => e.value != null && !notPlayedIdx(e.key))
        .fold(0, (s, e) => s + (e.value as int));
    final int totalNet =
        netScores.whereType<int>().fold(0, (a, b) => a + b);
    final int totalPoints = widget.overrideTotalPoints ??
        pts.whereType<int>().fold(0, (a, b) => a + b);
    final int totalPar = pars.fold(0, (a, b) => a + b);
    final int holesPlayed = (widget.holeScores ?? [])
        .asMap()
        .entries
        .where((e) => e.value != null && !notPlayedIdx(e.key))
        .length;

    int? toParDiff;
    if (holesPlayed > 0) {
      if (widget.isStableford) {
        toParDiff = totalPoints - (holesPlayed * 2);
      } else {
        final playedPar = pars.take(holesPlayed).fold<int>(0, (a, b) => a + b);
        toParDiff = (isGross ? totalStrokes : totalNet) - playedPar;
      }
    }

    final teeColor = AppColors.getTeeColor(widget.selectedTeeName);
    final teeTextColor =
        teeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    final footer = _buildFooter(context, isDark, totalStrokes, totalNet,
        totalPoints, totalPar, holesPlayed, toParDiff, isGross, pointsColor);

    Widget body;
    if (widget.paged) {
      final hasVerifierRow = widget.verifierScores != null &&
          widget.verifierScores!.any((s) => s != null && s > 0);
      final rowCount = 5 +
          (showNet ? 1 : 0) +
          (widget.isStableford ? 1 : 0) +
          (widget.matchPlayResults != null ? 1 : 0) +
          (hasVerifierRow ? 1 : 0);
      final gridH = rowCount * _cellH + (rowCount - 1).toDouble();

      body = Column(children: [
        // Paged header
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: AppColors.opacityLow),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _currentPage == 1
                    ? () => _pageController.animateToPage(0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut)
                    : null,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Icon(Icons.chevron_left_rounded,
                      size: 20,
                      color: (isDark ? AppColors.pureWhite : Colors.black)
                          .withValues(alpha: _currentPage == 1 ? 0.6 : 0.1)),
                ),
              ),
              Text(_currentPage == 0 ? 'FRONT 9' : 'BACK 9',
                  style: AppTypography.label.copyWith(
                      fontWeight: AppTypography.weightHeavy,
                      letterSpacing: 1.0,
                      color: isDark ? AppColors.dark60 : AppColors.dark900)),
              GestureDetector(
                onTap: _currentPage == 0
                    ? () => _pageController.animateToPage(1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut)
                    : null,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 20,
                      color: (isDark ? AppColors.pureWhite : Colors.black)
                          .withValues(alpha: _currentPage == 0 ? 0.6 : 0.1)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: gridH,
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _buildNineGrid(context, isDark, pars.take(9).toList(),
                  sis.take(9).toList(), dists.take(9).toList(), netScores, pts,
                  1, teeColor, teeTextColor, showNet, pointsColor),
              _buildNineGrid(context, isDark, pars.skip(9).take(9).toList(),
                  sis.skip(9).take(9).toList(), dists.skip(9).take(9).toList(),
                  netScores, pts, 10, teeColor, teeTextColor, showNet, pointsColor),
            ],
          ),
        ),
      ]);
    } else {
      body = Column(children: [
        _buildSectionHeader(context, 'Front 9'),
        _buildNineGrid(context, isDark, pars.take(9).toList(),
            sis.take(9).toList(), dists.take(9).toList(), netScores, pts, 1,
            teeColor, teeTextColor, showNet, pointsColor),
        const SizedBox(height: AppSpacing.sm),
        _buildSectionHeader(context, 'Back 9'),
        _buildNineGrid(context, isDark, pars.skip(9).take(9).toList(),
            sis.skip(9).take(9).toList(), dists.skip(9).take(9).toList(),
            netScores, pts, 10, teeColor, teeTextColor, showNet, pointsColor),
      ]);
    }

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        body,
        footer,
        if (widget.holeTags != null &&
            widget.holeTags!.values.any((t) => t.isNotEmpty))
          _buildTagsSummary(context),
      ]),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityLow),
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: AppTypography.label.copyWith(
              fontWeight: AppTypography.weightHeavy, letterSpacing: 1.0)),
    );
  }

  Widget _buildNineGrid(
    BuildContext context,
    bool isDark,
    List<int> pars,
    List<int> sis,
    List<int> dists,
    List<int?> netScores,
    List<int?> pts,
    int startHole,
    Color teeColor,
    Color teeTextColor,
    bool showNet,
    Color pointsColor,
  ) {
    final distLabel =
        widget.distanceUnit.toUpperCase().contains('METRE') ? 'MTR' : 'YDS';
    final nineTotal = dists.fold<int>(0, (a, b) => a + b);
    final ninePar = pars.fold<int>(0, (a, b) => a + b);
    final outLabel = startHole == 1 ? 'OUT' : 'IN';

    bool isPickUp(int holeNum) => widget.holeTags?[holeNum]?.contains('PICK_UP') == true;

    bool notPlayed(int holeNum) {
      if (widget.holeTags?[holeNum]?.contains('NOT_PLAYED') == true) return true;
      final idx = holeNum - 1;
      return widget.matchPlayResults != null &&
          widget.matchPlayResults!.length > idx &&
          widget.matchPlayResults![idx].isEmpty;
    }

    return Column(children: [
      // Hole numbers
      _row([
        _label(context, 'HOLE'),
        for (int i = 0; i < 9; i++)
          Expanded(child: _cell(context, isDark, '${startHole + i}', isHeader: true,
              isConclusion: widget.conclusionHole == startHole + i)),
        _total(context, isDark, outLabel, isHeader: true),
      ]),
      const Divider(height: 1),
      // Distances — only shown in active scoring view
      if (widget.showYardage) ...[
        _row([
          _label(context, distLabel),
          for (int i = 0; i < 9; i++)
            Expanded(child: _cell(context, isDark,
                dists[i] > 0 ? '${dists[i]}' : '-',
                isDimmed: true, fontSize: 12, fontWeight: FontWeight.w300)),
          _total(context, isDark, nineTotal > 0 ? '$nineTotal' : '-',
              isDimmed: true, fontSize: 12, fontWeight: FontWeight.w300),
        ]),
        const Divider(height: 1),
      ],
      // Par row (tee-coloured)
      Container(
        color: teeColor,
        child: _row([
          _label(context, 'PAR', color: teeTextColor),
          for (int i = 0; i < 9; i++)
            Expanded(child: _cell(context, isDark, '${pars[i]}',
                isBold: true, color: teeTextColor)),
          _total(context, isDark, '$ninePar',
              isBold: true, color: teeTextColor, bgColor: Colors.transparent),
        ]),
      ),
      const Divider(height: 1),
      // SI row (de-emphasised)
      _row([
        _label(context, 'SI', color: AppColors.dark300),
        for (int i = 0; i < 9; i++)
          Expanded(child: _cell(context, isDark, '${sis[i]}',
              isDimmed: true, fontSize: 12, fontWeight: FontWeight.w300)),
        _total(context, isDark, '', isDimmed: true),
      ]),
      const Divider(height: 1),
      // Score row
      _row([
        _label(context, widget.mainRowLabel ?? 'STR'),
        for (int i = 0; i < 9; i++) (() {
          final holeNum = startHole + i;
          final idx = holeNum - 1;
          final s = (widget.holeScores != null && idx < widget.holeScores!.length)
              ? widget.holeScores![idx]
              : null;
          if (notPlayed(holeNum)) {
            if (s != null) return Expanded(child: _notPlayedCell(context, isDark, s, pars[i]));
            return Expanded(child: _cell(context, isDark, 'NP', isDimmed: true, fontSize: 11));
          }
          if (isPickUp(holeNum)) {
            if (s != null) return Expanded(child: _pickUpCell(context, isDark, s, pars[i]));
            return Expanded(child: _cell(context, isDark, 'P', isDimmed: true, fontSize: 11, color: AppColors.amber500));
          }
          return Expanded(child: _scoreCell(context, isDark, s, pars[i],
              hasConflict: widget.conflictedHoles.contains(holeNum)));
        })(),
        _total(context, isDark,
            _nineSum(widget.holeScores, startHole, 9) ?? '-', isBold: true),
      ]),
      // Marker comparison row — only when card is full and verifier scores exist
      if (widget.verifierScores != null &&
          widget.verifierScores!.any((s) => s != null && s > 0)) ...[
        const Divider(height: 1),
        _row([
          _label(context, 'MKR', color: AppColors.dark400),
          for (int i = 0; i < 9; i++) (() {
            final holeNum = startHole + i;
            final idx = holeNum - 1;
            final mv = idx < widget.verifierScores!.length ? widget.verifierScores![idx] : null;
            final pv = (widget.holeScores != null && idx < widget.holeScores!.length)
                ? widget.holeScores![idx]
                : null;
            final differs = mv != null && pv != null && mv != pv;
            return Expanded(
              child: differs
                  ? _scoreCell(context, isDark, mv, pars[i], hasConflict: true)
                  : _cell(context, isDark, mv != null ? '$mv' : '-',
                      isDimmed: true, fontSize: 12),
            );
          })(),
          _total(context, isDark,
              _nineSum(widget.verifierScores, startHole, 9)?.toString() ?? '-',
              isBold: false),
        ]),
      ],
      // Additional partner rows (non-paged only)
      if (widget.additionalRows != null)
        for (final row in widget.additionalRows!)
          _buildPartnerRow(context, isDark, row, startHole, pars),
      // Match play row
      if (widget.matchPlayResults != null) ...[
        const Divider(height: 1),
        _row([
          _label(context, 'MATCH'),
          for (int i = 0; i < 9; i++) (() {
            final idx = startHole - 1 + i;
            final token = idx < widget.matchPlayResults!.length
                ? widget.matchPlayResults![idx]
                : '-';
            return Expanded(child: _matchCell(context, token));
          })(),
          _total(context, isDark, ''),
        ]),
      ],
      // Net row
      if (showNet) ...[
        const Divider(height: 1),
        _row([
          _label(context, 'NET'),
          for (int i = 0; i < 9; i++) (() {
            final holeNum = startHole + i;
            final idx = holeNum - 1;
            final n = idx < netScores.length ? netScores[idx] : null;
            if (notPlayed(holeNum)) {
              return Expanded(child: n != null
                  ? _cell(context, isDark, '$n', isDimmed: true)
                  : _cell(context, isDark, 'NP', isDimmed: true, fontSize: 11));
            }
            return Expanded(
                child: _cell(context, isDark, n != null ? '$n' : '-',
                    isDimmed: true));
          })(),
          _total(context, isDark,
              netScores.skip(startHole - 1).take(9).whereType<int>().fold(0, (a, b) => a + b).toString(),
              isDimmed: true, isBold: true),
        ]),
      ],
      // Points row (Stableford)
      if (widget.isStableford) ...[
        const Divider(height: 1),
        _row([
          _label(context, 'PTS', color: pointsColor),
          for (int i = 0; i < 9; i++) (() {
            final holeNum = startHole + i;
            if (notPlayed(holeNum)) return Expanded(child: _cell(context, isDark, 'NP', isDimmed: true, fontSize: 11));
            if (isPickUp(holeNum)) return Expanded(child: _cell(context, isDark, '0', isDimmed: true, fontSize: 11));
            final idx = holeNum - 1;
            final p = idx < pts.length ? pts[idx] : null;
            return Expanded(
                child: _cell(context, isDark, p != null ? '$p' : '-',
                    color: p != null ? pointsColor : null, isBold: true));
          })(),
          _total(context, isDark,
              pts.skip(startHole - 1).take(9).whereType<int>().fold(0, (a, b) => a + b).toString(),
              isBold: true, color: pointsColor),
        ]),
      ],
    ]);
  }

  Widget _buildPartnerRow(BuildContext context, bool isDark, CourseScoreRow row,
      int startHole, List<int> pars) {
    final nineScores = row.scores.skip(startHole - 1).take(9).toList();
    final total = nineScores.whereType<int>().fold<int>(0, (a, b) => a + b);
    return Column(children: [
      const Divider(height: 1),
      _row([
        _label(context, row.playerName.toUpperCase()),
        for (int i = 0; i < 9; i++)
          Expanded(child: _scoreCell(context, isDark, nineScores[i], pars[i])),
        _total(context, isDark, total > 0 ? '$total' : '-', isBold: true),
      ]),
    ]);
  }

  Widget _buildFooter(
    BuildContext context,
    bool isDark,
    int strokes,
    int net,
    int points,
    int par,
    int thru,
    int? toPar,
    bool isGross,
    Color pointsColor,
  ) {
    final toParColor = (toPar ?? 0) < 0
        ? AppColors.coral500
        : ((toPar ?? 0) == 0 ? AppColors.amber500 : AppColors.dark900);
    final toParString = toPar == null
        ? '-'
        : (toPar == 0 ? 'E' : (toPar > 0 ? '+$toPar' : '$toPar'));
    final subLabel = thru >= 18
        ? (widget.tieBreakLabel != null ? 'F / ${widget.tieBreakLabel}' : 'F')
        : 'THRU $thru';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityLow),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statItem('PAR', '$par'),
          _statItem(isGross ? 'TOTAL' : 'GROSS', '$strokes', sub: subLabel),
          if (widget.isStableford)
            _statItem('POINTS', '$points', color: pointsColor)
          else if (thru > 0) ...[
            _statItem('TO PAR', toParString, color: toParColor),
            if (!isGross) _statItem('NET', '$net'),
          ],
        ],
      ),
    );
  }

  Widget _buildTagsSummary(BuildContext context) {
    int penalties = 0, gimmes = 0, notPlayed = 0;
    widget.holeTags?.forEach((_, tags) {
      penalties += tags.where((t) => t.startsWith('PENALTY_')).length;
      if (tags.contains('GIMME')) gimmes++;
      if (tags.contains('NOT_PLAYED')) notPlayed++;
    });
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.02),
        border: Border(
            top: BorderSide(
                color:
                    Theme.of(context).dividerColor.withValues(alpha: 0.1))),
      ),
      child: Row(children: [
        if (penalties > 0) ...[
          _tagChip(Icons.warning_amber_rounded, 'PENALTIES: $penalties', AppColors.amber500),
          const SizedBox(width: AppSpacing.md),
        ],
        if (gimmes > 0) ...[
          _tagChip(Icons.check_circle_outline_rounded, 'GIMMES: $gimmes', AppColors.lime500),
          const SizedBox(width: AppSpacing.md),
        ],
        if (notPlayed > 0) ...[
          _tagChip(Icons.remove_circle_outline_rounded, 'NP: $notPlayed', AppColors.dark400),
          const SizedBox(width: AppSpacing.md),
        ],
        if (widget.markerVerified) ...[
          const Spacer(),
          _tagChip(Icons.verified_rounded, 'MARKER SIGNED', AppColors.lime500),
        ],
      ]),
    );
  }

  // ── Cell helpers ────────────────────────────────────────────────────────────

  Widget _row(List<Widget> children) => Row(children: children);

  Widget _label(BuildContext context, String text, {Color? color}) =>
      Container(
        width: 50,
        height: _cellH,
        padding: const EdgeInsets.only(left: 8),
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: AppTypography.labelStrong.copyWith(
                fontSize: 9,
                color: color ?? AppColors.dark300,
                fontWeight: AppTypography.weightExtraBold,
                letterSpacing: 0.5)),
      );

  Widget _cell(BuildContext context, bool isDark, String text,
      {bool isHeader = false,
      bool isDimmed = false,
      bool isBold = false,
      Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      bool isConclusion = false}) {
    final bg = isConclusion ? AppColors.dark900 : null;
    final fg = isConclusion
        ? Colors.white
        : color ??
            (isHeader
                ? AppColors.dark200
                : isDimmed
                    ? AppColors.dark300
                    : AppColors.dark900);
    return Container(
      height: _cellH,
      alignment: Alignment.center,
      color: bg,
      child: Text(text,
          style: AppTypography.labelStrong.copyWith(
              fontSize: fontSize ?? 13,
              fontWeight: fontWeight ??
                  (isBold
                      ? AppTypography.weightBlack
                      : isHeader
                          ? AppTypography.weightBold
                          : AppTypography.weightSemibold),
              color: fg)),
    );
  }

  Widget _total(BuildContext context, bool isDark, String text,
      {bool isHeader = false,
      bool isDimmed = false,
      bool isBold = false,
      Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      Color? bgColor}) =>
      Container(
        width: 45,
        height: _cellH,
        alignment: Alignment.center,
        color: bgColor ??
            Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: AppColors.opacityLow),
        child: Text(text,
            style: AppTypography.labelStrong.copyWith(
                fontSize: fontSize ?? 13,
                fontWeight: fontWeight ??
                    (isBold ? FontWeight.w900 : FontWeight.normal),
                color: color ??
                    (isHeader
                        ? AppColors.dark200
                        : isDimmed
                            ? AppColors.dark300
                            : AppColors.dark900))),
      );

  Widget _scoreCell(BuildContext context, bool isDark, int? score, int par,
      {bool hasConflict = false}) {
    if (score == null) {
      return hasConflict
          ? Container(
              height: _cellH,
              alignment: Alignment.center,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border:
                        Border.all(color: AppColors.coral500, width: 1.5)),
                alignment: Alignment.center,
                child: Text('-',
                    style: AppTypography.labelStrong
                        .copyWith(fontSize: 13, color: AppColors.coral500)),
              ))
          : _cell(context, isDark, '-');
    }

    final diff = score - par;
    Color? bg;
    Color fg = Colors.white;
    BoxBorder? border;

    if (diff <= -2) {
      bg = AppColors.amber500; fg = Colors.black;
    } else if (diff == -1) {
      bg = AppColors.coral500;
    } else if (diff == 0) {
      bg = Colors.transparent;
      fg = isDark ? AppColors.pureWhite : AppColors.dark900;
      border = Border.all(
          color: isDark ? AppColors.dark500 : AppColors.lightBorder, width: 1);
    } else if (diff == 1) {
      bg = AppColors.dark900;
    } else {
      bg = AppColors.dark600;
    }

    final pip = Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
          color: bg,
          shape: diff < 0 ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: diff < 0 ? null : BorderRadius.circular(4),
          border: border),
      alignment: Alignment.center,
      child: Text('$score',
          style: AppTypography.labelStrong.copyWith(fontSize: 13, color: fg)),
    );

    return Container(
      height: _cellH,
      alignment: Alignment.center,
      child: hasConflict
          ? Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.coral500, width: 1.5)),
              padding: const EdgeInsets.all(2),
              child: pip)
          : pip,
    );
  }

  /// Score cell for a not-played hole with a max score applied: stroke pip + small grey "NP" badge.
  Widget _notPlayedCell(BuildContext context, bool isDark, int score, int par) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _scoreCell(context, isDark, score, par),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            height: 10,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(minWidth: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.dark400,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'NP',
              style: AppTypography.micro.copyWith(
                color: AppColors.pureWhite,
                fontWeight: AppTypography.weightHeavy,
                fontSize: 5,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Score cell for a max-score pick-up: shows the stroke pip + small amber "P" badge.
  Widget _pickUpCell(BuildContext context, bool isDark, int score, int par) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _scoreCell(context, isDark, score, par),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 10,
            height: 10,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.amber500,
              shape: BoxShape.circle,
            ),
            child: Text(
              'P',
              style: AppTypography.micro.copyWith(
                color: AppColors.pureWhite,
                fontWeight: AppTypography.weightHeavy,
                fontSize: 5,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _matchCell(BuildContext context, String token) {
    Color? bg;
    if (token == 'W') { bg = AppColors.lime500; }
    else if (token == 'L') { bg = AppColors.coral500; }
    else if (token == 'H') { bg = AppColors.dark300; }
    return Container(
      height: _cellH,
      alignment: Alignment.center,
      child: bg != null
          ? Container(
              width: 20, height: 20,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(token,
                  style: AppTypography.labelStrong
                      .copyWith(fontSize: 10, color: Colors.white)))
          : Text('-',
              style: AppTypography.labelStrong
                  .copyWith(fontSize: 13, color: AppColors.dark400)),
    );
  }

  Widget _statItem(String label, String value,
      {String? sub, Color? color}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AppTypography.nano.copyWith(
                color: AppColors.dark900,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0)),
        Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: AppTypography.labelStrong.copyWith(
                      fontSize: 17, color: color ?? AppColors.dark900)),
              if (sub != null) ...[
                const SizedBox(width: 4),
                Text(sub,
                    style: AppTypography.nano.copyWith(
                        color: AppColors.dark900,
                        fontSize: 8,
                        fontWeight: FontWeight.w600)),
              ],
            ]),
      ]);

  Widget _tagChip(IconData icon, String label, Color color) => Row(children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: AppTypography.nano
                .copyWith(color: color, fontWeight: AppTypography.weightBlack)),
      ]);

  String? _nineSum(List<int?>? scores, int startHole, int count) {
    if (scores == null) return null;
    final slice = scores.skip(startHole - 1).take(count).whereType<int>();
    if (slice.isEmpty) return null;
    return slice.fold(0, (a, b) => a + b).toString();
  }

  List<int> _extractDistancesFromConfig() {
    if (widget.courseConfig is Map) {
      final tees = widget.courseConfig['tees'] as List<dynamic>?;
      if (tees != null && tees.isNotEmpty) {
        final tee = tees.firstWhere(
            (t) => t['name'] == widget.selectedTeeName,
            orElse: () => tees.first);
        if (tee['yardages'] != null) {
          return List<int>.from(tee['yardages'] as List);
        }
        if (tee['holes'] != null) {
          return List<int>.from(
              (tee['holes'] as List).map((h) => (h['distance'] as int?) ?? 0));
        }
      }
    }
    return List<int>.filled(18, 0);
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
