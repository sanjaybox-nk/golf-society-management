import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/status_colors.dart';
import '../theme/contrast_helper.dart';

/// A simple status chip created with a solid black background.
class StatusChip extends StatelessWidget {
  final String label;
  const StatusChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A wrapper that adds a red/yellow notification dot.
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const NotificationBadge({super.key, required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: ContrastHelper.getContrastingText(Theme.of(context).primaryColor),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// An interactive Fee Paid/Due toggle with animation.
class BoxyArtFeePill extends StatefulWidget {
  final bool isPaid;
  final VoidCallback onToggle;

  const BoxyArtFeePill({
    super.key,
    required this.isPaid,
    required this.onToggle,
  });

  @override
  State<BoxyArtFeePill> createState() => _BoxyArtFeePillState();
}

class _BoxyArtFeePillState extends State<BoxyArtFeePill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onToggle();
        },
        onTapCancel: () => _controller.reverse(),
        child: BoxyArtStatusPill(
          text: widget.isPaid ? 'Fee Paid' : 'Fee Due',
          baseColor: widget.isPaid ? StatusColors.positive : StatusColors.warning,
        ),
      ),
    );
  }
}

/// A semantic status pill that adapts to Light/Dark modes.
class BoxyArtStatusPill extends StatelessWidget {
  final String text;
  final Color baseColor;
  final Color? backgroundColorOverride;

  const BoxyArtStatusPill({
    super.key,
    required this.text,
    required this.baseColor,
    this.backgroundColorOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColorOverride ??
            (Theme.of(context).brightness == Brightness.light
                ? baseColor.withValues(alpha: 0.1)
                : baseColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: baseColor == Colors.grey ? Colors.black.withValues(alpha: 0.6) : baseColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A chat bubble styled according to the BoxyArt theme.
class BoxyArtChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String? time;

  const BoxyArtChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
          ),
        ),
        child: Builder(
          builder: (context) {
            final backgroundColor = isMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor;
            final textColor = ContrastHelper.getContrastingText(backgroundColor);
            final subtleTextColor = textColor.withValues(alpha: 0.6);
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (time != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    time!,
                    style: TextStyle(
                      color: subtleTextColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A stylized date badge for event lists.
class BoxyArtDateBadge extends StatelessWidget {
  final DateTime date;

  const BoxyArtDateBadge({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 58,
      height: 74,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.3 : 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('d').format(date),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primary,
              height: 1.1,
            ),
          ),
          Text(
            DateFormat('yyyy').format(date),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: primary.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
