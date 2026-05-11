part of 'vertical_hole_scoring_list.dart';

class _PlayerScoringCard extends ConsumerStatefulWidget {
  final String label;
  final String name;
  final double hc;
  final int phc;
  final String? teeName;
  final String? teeColorStr;
  final int? score;
  final int? hint;
  final String? thru;
  final int? points;
  final String? matchStatus;
  final int? par;
  final int? si;
  final String? markerName;
  final bool isMe;
  final ValueChanged<int> onChanged;
  final bool isStableford;
  final bool isLocked;
  final List<String> holeTags;
  final VoidCallback? onStoryTap;
  final bool hasConflict;

  const _PlayerScoringCard({
    required this.label,
    required this.name,
    required this.hc,
    required this.phc,
    this.teeName,
    this.teeColorStr,
    this.score,
    this.hint,
    this.thru,
    this.points,
    this.matchStatus,
    this.par,
    this.si,
    this.markerName,
    this.isMe = false,
    required this.onChanged,
    this.isStableford = true,
    this.isLocked = false,
    this.holeTags = const [],
    this.onStoryTap,
    this.hasConflict = false,
  });

  @override
  ConsumerState<_PlayerScoringCard> createState() => _PlayerScoringCardState();
}

class _PlayerScoringCardState extends ConsumerState<_PlayerScoringCard> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.score == null || widget.score == 0 ? '' : '${widget.score}',
    );
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });
  }

  @override
  void didUpdateWidget(_PlayerScoringCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score && !_focusNode.hasFocus) {
      _controller.text = widget.score == null || widget.score == 0 ? '' : '${widget.score}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Color _getScoreColor() {
    final config = ref.watch(themeControllerProvider);
    return Color(config.effectivePointsColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shapes = theme.extension<AppShapeTokens>();
    final spacing = theme.extension<AppSpacingTokens>();

    return Container(
      padding: EdgeInsets.all(spacing?.cardVerticalPadding ?? AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dark800 : theme.cardColor,
        borderRadius: shapes?.card,
        border: Border.all(
          color: isDark ? AppColors.dark700 : AppColors.lightBorder,
          width: 1.0,
        ),
        boxShadow: theme.extension<AppShadows>()?.softScale,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onLongPress: widget.isLocked ? null : widget.onStoryTap,
                behavior: HitTestBehavior.translucent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.label.isNotEmpty)
                      Text(
                        widget.label,
                        style: AppTypography.micro.copyWith(
                          color: AppColors.dark300,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    if (widget.label.isNotEmpty) const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.name,
                            style: AppTypography.memberName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        BoxyArtIndicator.hc(label: widget.hc.toStringAsFixed(1), hasHorizontalMargin: false),
                        BoxyArtIndicator.phc(context: context, label: '${widget.phc}'),
                      ],
                    ),
                    if (widget.isMe && widget.markerName != null) ...[
                      const Spacer(),
                      const SizedBox(height: 8),
                      Text(
                        'MARKED BY: ${widget.markerName!.toUpperCase()}',
                        style: AppTypography.micro.copyWith(
                          fontSize: 10,
                          color: AppColors.dark400,
                          fontWeight: FontWeight.w100,
                          letterSpacing: 0.5,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.par != null || widget.si != null || widget.teeName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _buildHoleMetaRow(context, isDark),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._buildScoreArea(context, isDark, shapes),
                    if (!widget.isLocked && widget.onStoryTap != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        onTap: widget.onStoryTap,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Icon(Icons.more_vert_rounded, size: 18, color: AppColors.dark300),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoleMetaRow(BuildContext context, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.par != null)
          Text('P${widget.par}', style: AppTypography.micro.copyWith(color: AppColors.dark500, fontWeight: FontWeight.w800, fontSize: 10)),
        if (widget.par != null && widget.si != null)
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('•', style: TextStyle(color: AppColors.dark200, fontSize: 10))),
        if (widget.si != null)
          Text('SI ${widget.si}', style: AppTypography.micro.copyWith(color: AppColors.dark500, fontWeight: FontWeight.w800, fontSize: 10)),
        if (widget.teeName != null) ...[
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('•', style: TextStyle(color: AppColors.dark200, fontSize: 10))),
          Builder(builder: (context) {
            final teeColor = AppColors.getTeeColor(widget.teeColorStr ?? widget.teeName);
            final isWhite = widget.teeName?.toUpperCase().contains('WHITE') == true ||
                widget.teeColorStr?.toUpperCase().contains('WHITE') == true;
            return Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: teeColor,
                shape: BoxShape.circle,
                border: isWhite ? Border.all(color: AppColors.dark200, width: 0.5) : null,
              ),
            );
          }),
        ],
      ],
    );
  }

  List<Widget> _buildScoreArea(BuildContext context, bool isDark, AppShapeTokens? shapes) {
    if (widget.holeTags.contains('NOT_PLAYED') && widget.score == null) {
      return [
        Container(
          width: 48, height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.dark400.withValues(alpha: AppColors.opacityLow),
            borderRadius: shapes?.input,
            border: Border.all(color: AppColors.dark400, width: 1.5),
          ),
          child: Text('NP', style: AppTypography.display.copyWith(
            color: AppColors.dark400, fontWeight: AppTypography.weightHeavy, fontSize: 16, height: 1.0)),
        ),
      ];
    }

    if (widget.holeTags.contains('NOT_PLAYED') && widget.score != null) {
      return [
        _StepperIcon(icon: Icons.remove_rounded, onTap: () {
          final s = widget.score ?? 4;
          if (s > 1) widget.onChanged(s - 1);
        }),
        const SizedBox(width: AppSpacing.xs),
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 48, height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.dark700 : AppColors.dark50,
              borderRadius: shapes?.input,
              border: Border.all(color: AppColors.dark400, width: 1.5),
            ),
            child: Text('${widget.score}', style: AppTypography.display.copyWith(
              color: _getScoreColor(), fontWeight: AppTypography.weightHeavy, fontSize: 32, height: 1.0)),
          ),
          Positioned(top: -4, right: -4, child: _TagBadge(label: 'NP', color: AppColors.dark400)),
        ]),
        const SizedBox(width: AppSpacing.xs),
        _StepperIcon(icon: Icons.add_rounded, onTap: () {
          final s = widget.score ?? 4;
          widget.onChanged(s + 1);
        }),
      ];
    }

    if (widget.holeTags.contains('PICK_UP') && widget.score == null) {
      return [
        Container(
          width: 48, height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.amber500.withValues(alpha: AppColors.opacityLow),
            borderRadius: shapes?.input,
            border: Border.all(color: AppColors.amber500, width: 1.5),
          ),
          child: Text('P', style: AppTypography.display.copyWith(
            color: AppColors.amber500, fontWeight: AppTypography.weightHeavy, fontSize: 28, height: 1.0)),
        ),
      ];
    }

    if (widget.holeTags.contains('PICK_UP') && widget.score != null) {
      return [
        _StepperIcon(icon: Icons.remove_rounded, onTap: () {
          final s = widget.score ?? 4;
          if (s > 1) widget.onChanged(s - 1);
        }),
        const SizedBox(width: AppSpacing.xs),
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 48, height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.dark700 : AppColors.dark50,
              borderRadius: shapes?.input,
              border: Border.all(color: AppColors.amber500, width: 1.5),
            ),
            child: Text('${widget.score}', style: AppTypography.display.copyWith(
              color: _getScoreColor(), fontWeight: AppTypography.weightHeavy, fontSize: 32, height: 1.0)),
          ),
          Positioned(top: -4, right: -4, child: _TagBadge(label: 'P', color: AppColors.amber500)),
        ]),
        const SizedBox(width: AppSpacing.xs),
        _StepperIcon(icon: Icons.add_rounded, onTap: () {
          final s = widget.score ?? 4;
          widget.onChanged(s + 1);
        }),
      ];
    }

    // Normal score input
    return [
      _StepperIcon(icon: Icons.remove_rounded, onTap: () {
        final s = widget.score ?? 4;
        if (s > 1) widget.onChanged(s - 1);
      }),
      const SizedBox(width: AppSpacing.xs),
      Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 48, height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.hasConflict
                ? AppColors.coral500.withValues(alpha: AppColors.opacityLow)
                : (isDark ? AppColors.dark900.withValues(alpha: AppColors.opacityHalf) : AppColors.dark50.withValues(alpha: AppColors.opacityHalf)),
            borderRadius: shapes?.input,
            border: Border.all(
              color: widget.hasConflict
                  ? AppColors.coral500
                  : (isDark ? AppColors.dark700 : AppColors.lightBorder),
              width: widget.hasConflict ? AppShapes.borderMedium : 1.0,
            ),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            readOnly: widget.isLocked,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: '-',
              filled: false,
              fillColor: Colors.transparent,
            ),
            style: AppTypography.display.copyWith(
              color: _getScoreColor(),
              fontWeight: AppTypography.weightHeavy,
              fontSize: 32,
              height: 1.0,
            ),
            onSubmitted: (v) {
              final val = int.tryParse(v);
              if (val != null) widget.onChanged(val);
            },
          ),
        ),
        if (widget.holeTags.contains('GIMME'))
          Positioned(top: -4, right: -4, child: _TagBadge(label: 'G', color: AppColors.lime600))
        else if (widget.holeTags.isNotEmpty && !widget.holeTags.contains('NOT_PLAYED'))
          Positioned(
            top: 3, right: 3,
            child: Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(color: AppColors.amber500, shape: BoxShape.circle),
            ),
          ),
      ]),
      const SizedBox(width: AppSpacing.xs),
      _StepperIcon(icon: Icons.add_rounded, onTap: () {
        final s = widget.score ?? 4;
        widget.onChanged(s + 1);
      }),
    ];
  }
}
