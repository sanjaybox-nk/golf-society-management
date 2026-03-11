import 'package:golf_society/design_system/design_system.dart';

class HoleScoreCard extends StatelessWidget {
  final int holeNum;
  final int par;
  final int? si;
  final int score;
  final int? maxScore; // [NEW] Optional hint for max score capping
  final bool isReadOnly;
  final bool isDisabled;
  final bool hasConflict;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onNextHole;
  final VoidCallback? onPrevHole;
  final ValueChanged<int>? onScoreChanged;

  const HoleScoreCard({
    super.key,
    required this.holeNum,
    required this.par,
    this.si,
    required this.score,
    this.maxScore,
    this.isReadOnly = false,
    this.isDisabled = false,
    this.hasConflict = false,
    this.onIncrement,
    this.onDecrement,
    this.onNextHole,
    this.onPrevHole,
    this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: AbsorbPointer(
        absorbing: isDisabled,
        child: BoxyArtCard(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Far Left: Large Hole Identifier (Full Contrast & Navigation)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, size: AppShapes.iconLg, color: onPrevHole != null ? primaryColor : onSurface.withValues(alpha: AppColors.opacitySubtle)),
                    onPressed: onPrevHole,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'H$holeNum',
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: AppTypography.weightBlack,
                      color: onSurface,
                      letterSpacing: -2,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, size: AppShapes.iconLg, color: onNextHole != null ? primaryColor : onSurface.withValues(alpha: AppColors.opacitySubtle)),
                    onPressed: onNextHole,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              
              // 2. Vertical Stack of Detail Pills (Center-Left)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPremiumPill(context, 'PAR $par', Colors.blueGrey, width: 54),
                  if (si != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _buildPremiumPill(context, 'SI $si', primaryColor, width: 54),
                  ],
                ],
              ),

              const Spacer(),

              // 3. Score Entry (Far Right) with Bolder Controls
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isReadOnly)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.keyboard_arrow_left_rounded, size: AppShapes.iconXl, color: primaryColor),
                          onPressed: onDecrement ?? () {},
                        ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        child: _ScoreDisplay(
                          score: score,
                          hasConflict: hasConflict,
                          isReadOnly: isReadOnly || isDisabled, 
                          onChanged: onScoreChanged,
                          size: 64, // Slightly smaller to fit in card
                        ),
                      ),
        
                      if (!isReadOnly)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.keyboard_arrow_right_rounded, size: AppShapes.iconXl, color: primaryColor),
                          onPressed: onIncrement ?? () {},
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildScoreMetadata(score, par),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPill(BuildContext context, String text, Color baseColor, {double? width}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: AppShapes.xl,
        border: Border.all(
          color: baseColor.withValues(alpha: isDark ? 0.4 : 0.3),
          width: AppShapes.borderLight,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: baseColor == Colors.blueGrey ? (isDark ? AppColors.pureWhite.withValues(alpha: 0.70) : Colors.blueGrey) : baseColor,
          fontSize: AppTypography.sizeMicroSmall,
          fontWeight: AppTypography.weightBlack,
          letterSpacing: 0.5,
        ),
      ),
    );
  }


  Widget _buildScoreMetadata(int score, int par) {
    final diff = score - par;
    String label = 'Par';
    Color color = Colors.blueGrey;

    if (diff == -1) {
      label = 'Birdie';
      color = AppColors.coral500;
    } else if (diff <= -2) {
      label = 'Eagle';
      color = AppColors.amber500;
    } else if (diff == 1) {
      label = 'Bogey';
      color = AppColors.teamA;
    } else if (diff >= 2) {
      label = 'Dbl Bogey';
      color = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacityLow),
        borderRadius: AppShapes.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: AppTypography.sizeMicroSmall,
          fontWeight: AppTypography.weightBlack,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ScoreDisplay extends StatefulWidget {
  final int score;
  final bool hasConflict;
  final bool isReadOnly;
  final ValueChanged<int>? onChanged;
  final double size;

  const _ScoreDisplay({
    required this.score,
    required this.hasConflict,
    required this.isReadOnly,
    this.onChanged,
    this.size = 72,
  });

  @override
  State<_ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<_ScoreDisplay> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.score}');
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _handleCommit();
      }
    });
  }

  void _handleCommit() {
    final val = int.tryParse(_controller.text);
    if (val != null && val != widget.score) {
      widget.onChanged?.call(val);
    } else {
      _controller.text = '${widget.score}';
    }
  }

  @override
  void didUpdateWidget(_ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score && !_focusNode.hasFocus) {
      _controller.text = '${widget.score}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isReadOnly) {
       return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: AppShapes.lg,
          border: Border.all(
            color: widget.hasConflict ? AppColors.coral500 : AppColors.textSecondary.withValues(alpha: AppColors.opacitySubtle),
            width: AppShapes.borderMedium,
          ),
          boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
        ),
        alignment: Alignment.center,
        child: Text(
          '${widget.score}',
          style: TextStyle(
            fontSize: widget.size * 0.5,
            fontWeight: AppTypography.weightBlack,
            color: Colors.black,
            letterSpacing: -1,
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: AppAnimations.medium,
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: AppShapes.lg,
        border: Border.all(
          color: widget.hasConflict ? AppColors.coral500 : AppColors.textSecondary.withValues(alpha: AppColors.opacitySubtle),
          width: AppShapes.borderMedium,
        ),
        boxShadow: widget.hasConflict ? [
          BoxShadow(
            color: AppColors.coral500.withValues(alpha: AppColors.opacityLow),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppColors.opacitySubtle),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          ...Theme.of(context).extension<AppShadows>()?.softScale ?? [],
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onSubmitted: (_) => _handleCommit(),
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: widget.size * 0.5,
          fontWeight: AppTypography.weightBlack,
          color: Colors.black,
          letterSpacing: -1,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
