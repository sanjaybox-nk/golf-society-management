import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/status_colors.dart';
import '../theme/contrast_helper.dart';
import '../utils/string_utils.dart';

/// A centralized icon badge for small indicators (location, time, etc.)
class BoxyArtIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const BoxyArtIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 20,
    this.iconSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all((size - iconSize) / 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: color,
      ),
    );
  }
}

/// A centralized number/position badge.
class BoxyArtNumberBadge extends StatelessWidget {
  final int number;
  final Color? color;
  final double size;

  const BoxyArtNumberBadge({
    super.key,
    required this.number,
    this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.primaryColor;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w900,
          color: effectiveColor,
        ),
      ),
    );
  }
}

/// A centralized square-ish container for icons and mini-stats.
class BoxyArtSquareBadge extends StatelessWidget {
  final Widget child;
  final double size;
  final Color? color;

  const BoxyArtSquareBadge({
    super.key,
    required this.child,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: child),
    );
  }
}

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
        child: BoxyArtPill(
          label: widget.isPaid ? 'Fee Paid' : 'Fee Due',
          color: widget.isPaid ? StatusColors.positive : StatusColors.warning,
        ),
      ),
    );
  }
}


/// A standardized high-fidelity pill for status badges and tags.
class BoxyArtPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final Color? textColor;

  const BoxyArtPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color), // Slightly larger icon to match larger text
            const SizedBox(width: 6),
          ],
          Text(
            toTitleCase(label),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor ?? color,
              letterSpacing: -0.2, // Tighter spacing for a modern look
            ),
          ),
        ],
      ),
    );
  }
}

/// A centralized colored circle indicator for golf tees.
class BoxyTeeIndicator extends StatelessWidget {
  final Color color;
  final double size;
  final bool hasShadow;

  const BoxyTeeIndicator({
    super.key,
    required this.color,
    this.size = 14,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: hasShadow ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ] : null,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 0.5,
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
  final DateTime? endDate;

  const BoxyArtDateBadge({
    super.key, 
    required this.date,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    final hasRange = endDate != null && endDate!.day != date.day;
    final dayText = hasRange 
        ? '${date.day}-${endDate!.day}'
        : DateFormat('d').format(date);

    return Container(
      width: 58,
      height: 74,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withValues(alpha: 0.35),
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
              fontWeight: FontWeight.bold,
              color: primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                dayText,
                style: TextStyle(
                  fontSize: hasRange ? 16 : 22,
                  fontWeight: FontWeight.bold,
                  color: primary,
                  height: 1.1,
                ),
              ),
            ),
          ),
          Text(
            DateFormat('yyyy').format(date),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: primary.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
