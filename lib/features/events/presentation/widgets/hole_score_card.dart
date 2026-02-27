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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Far Left: Large Hole Identifier (Full Contrast & Navigation)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, size: 32, color: onPrevHole != null ? primaryColor : onSurface.withValues(alpha: 0.05)),
                    onPressed: onPrevHole,
                  ),
                  Text(
                    'H$holeNum',
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: onSurface, // Full solid contrast
                      letterSpacing: -2,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, size: 32, color: onNextHole != null ? primaryColor : onSurface.withValues(alpha: 0.05)),
                    onPressed: onNextHole,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              
              // 2. Vertical Stack of Detail Pills (Center-Left)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPremiumPill(context, 'PAR $par', Colors.blueGrey, width: 60),
                  if (si != null) ...[
                    const SizedBox(height: 4),
                    _buildPremiumPill(context, 'SI $si', primaryColor, width: 60),
                  ],
                  if (maxScore != null) ...[
                    const SizedBox(height: 4),
                    _buildPremiumPill(context, 'MAX $maxScore', Colors.orange, width: 60),
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
                          icon: Icon(Icons.keyboard_arrow_left_rounded, size: 40, color: primaryColor),
                          onPressed: onDecrement ?? () {},
                        ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _ScoreDisplay(
                          score: score,
                          hasConflict: hasConflict,
                          isReadOnly: isReadOnly || isDisabled, 
                          onChanged: onScoreChanged,
                          size: 64, 
                        ),
                      ),
        
                      if (!isReadOnly)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.keyboard_arrow_right_rounded, size: 40, color: primaryColor),
                          onPressed: onIncrement ?? () {},
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: baseColor.withValues(alpha: isDark ? 0.4 : 0.3),
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: baseColor == Colors.blueGrey ? (isDark ? Colors.white70 : Colors.blueGrey.shade800) : baseColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }


  Widget _buildScoreMetadata(int score, int par) {
    final diff = score - par;
    String label = 'Par';
    Color color = Colors.blueGrey.shade700;

    if (diff == -1) {
      label = 'Birdie';
      color = Colors.red;
    } else if (diff <= -2) {
      label = 'Eagle';
      color = Colors.amber;
    } else if (diff == 1) {
      label = 'Bogey';
      color = Colors.blue;
    } else if (diff >= 2) {
      label = 'Dbl Bogey';
      color = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.hasConflict ? Colors.red : Colors.grey.withValues(alpha: 0.05),
            width: 2,
          ),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            ...AppShadows.softScale,
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '${widget.score}',
          style: TextStyle(
            fontSize: widget.size * 0.5,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: -1,
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.hasConflict ? Colors.red : Colors.grey.withValues(alpha: 0.05),
          width: 2,
        ),
        boxShadow: widget.hasConflict ? [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          ...AppShadows.softScale,
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
          fontWeight: FontWeight.w900,
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
