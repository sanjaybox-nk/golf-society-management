import 'package:flutter/material.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/shared_ui/badges.dart';
import '../../../../core/shared_ui/buttons.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),
              
              if (!isReadOnly) ...[
                 const Spacer(),
              ],
    
              // Center Row: Singular Input
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isReadOnly) ...[
                    _buildThemedControl(context, Icons.remove, onDecrement),
                    const SizedBox(width: 24),
                  ],
                  
                  // Score Display/Input
                  _ScoreDisplay(
                    score: score,
                    hasConflict: hasConflict,
                    isReadOnly: isReadOnly || isDisabled, // Treat as read-only if disabled
                    onChanged: onScoreChanged,
                  ),
    
                  if (!isReadOnly) ...[
                    const SizedBox(width: 24),
                    _buildThemedControl(context, Icons.add, onIncrement),
                  ],
                ],
              ),
              
              if (!isReadOnly) ...[
                const Spacer(),
              ],
              
              const SizedBox(height: 12),
              
              // Bottom Row: Hole Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HOLE $holeNum',
                    style: textTheme.labelSmall?.copyWith(
                      color: onSurface.withValues(alpha: 0.3),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    children: [
                      BoxyArtStatusPill(
                        text: 'PAR $par',
                        baseColor: Colors.grey,
                        backgroundColorOverride: onSurface.withValues(alpha: 0.05),
                      ),
                      if (si != null) ...[
                        const SizedBox(width: 6),
                        BoxyArtStatusPill(
                          text: 'SI $si',
                          baseColor: primaryColor,
                        ),
                      ],
                      if (maxScore != null) ...[
                        const SizedBox(width: 6),
                        BoxyArtStatusPill(
                          text: 'MAX $maxScore',
                          baseColor: Colors.orange,
                          backgroundColorOverride: Colors.orange.withValues(alpha: 0.1),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemedControl(BuildContext context, IconData icon, VoidCallback? onTap) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return BoxyArtCircularIconBtn(
      icon: icon,
      onTap: onTap ?? () {},
      backgroundColor: onSurface.withValues(alpha: 0.05),
      iconColor: Theme.of(context).primaryColor,
      iconSize: 24,
      padding: 12,
      shadowOverride: AppShadows.inputSoft, 
    );
  }
}

class _ScoreDisplay extends StatefulWidget {
  final int score;
  final bool hasConflict;
  final bool isReadOnly;
  final ValueChanged<int>? onChanged;

  const _ScoreDisplay({
    required this.score,
    required this.hasConflict,
    required this.isReadOnly,
    this.onChanged,
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
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.hasConflict ? Colors.red : Colors.grey.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: AppShadows.softScale,
        ),
        alignment: Alignment.center,
        child: Text(
          '${widget.score}',
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.hasConflict ? Colors.red : Colors.grey.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: AppShadows.softScale,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onSubmitted: (_) => _handleCommit(),
        style: const TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w900,
          color: Colors.black,
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
