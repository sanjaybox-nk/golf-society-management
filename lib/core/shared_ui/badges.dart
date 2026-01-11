import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
              decoration: const BoxDecoration(
                color: AppTheme.primaryYellow,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.black,
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
    final bgColor = widget.isPaid ? Colors.green.shade100 : Colors.orange.shade100;
    final textColor = widget.isPaid ? const Color(0xFF1B5E20) : const Color(0xFFE65100);
    final borderColor = widget.isPaid ? Colors.green.shade300 : Colors.orange.shade300;
    final label = widget.isPaid ? 'Fee Paid' : 'Fee Due';

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onToggle();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: ShapeDecoration(
            color: bgColor,
            shape: StadiumBorder(
              side: BorderSide(color: borderColor, width: 1.5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
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
          color: isMe ? AppTheme.primaryYellow : AppTheme.surfaceGrey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.black : Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (time != null) ...[
              const SizedBox(height: 4),
              Text(
                time!,
                style: TextStyle(
                  color: isMe ? Colors.black54 : Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
