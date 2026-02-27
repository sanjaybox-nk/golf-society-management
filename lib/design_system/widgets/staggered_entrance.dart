import "package:golf_society/design_system/design_system.dart";




class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? delay;

  const StaggeredEntrance({
    super.key,
    required this.child,
    required this.index,
    this.delay,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.entranceCurve,
      ),
    );

    _slide = Tween<Offset>(begin: AppAnimations.slideUp, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.entranceCurve,
      ),
    );

    Future.delayed(widget.delay ?? AppAnimations.stagger(widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
