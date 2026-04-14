import 'package:golf_society/design_system/design_system.dart';

class BoxyArtSearchInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final String? label;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? margin;
  final String? initialValue;
  final TextEditingController? controller;

  const BoxyArtSearchInput({
    super.key,
    required this.onChanged,
    this.hintText = 'Search...',
    this.label,
    this.focusNode,
    this.margin,
    this.initialValue,
    this.controller,
  });

  @override
  State<BoxyArtSearchInput> createState() => _BoxyArtSearchInputState();
}

class _BoxyArtSearchInputState extends State<BoxyArtSearchInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  void didUpdateWidget(BoxyArtSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && widget.initialValue != oldWidget.initialValue && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.labelToCard),
              child: Text(
                widget.label!,
                style: AppTypography.label.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                  fontWeight: AppTypography.weightBold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _controller.text.isNotEmpty ? _clear : null,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _controller.text.isNotEmpty ? Icons.close_rounded : Icons.search_rounded,
                      key: ValueKey(_controller.text.isNotEmpty),
                      color: _controller.text.isNotEmpty 
                          ? StatusColors.negative 
                          : Theme.of(context).primaryColor,
                      size: AppShapes.iconMd,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: widget.focusNode,
                    onChanged: (v) {
                      // Internal update handled by controller listener
                      widget.onChanged(v);
                    },
                    style: AppTypography.body.copyWith(
                      fontSize: 18,
                      height: 1.2,
                      fontWeight: AppTypography.weightSemibold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: AppTypography.body.copyWith(
                        fontSize: 18,
                        height: 1.2,
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
