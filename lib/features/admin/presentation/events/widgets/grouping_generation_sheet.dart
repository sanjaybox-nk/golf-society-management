import 'package:golf_society/design_system/design_system.dart';

/// Bottom-sheet overlay for configuring and triggering tee group auto-generation.
/// Manages its own strategy/preference selection state.
class GroupingGenerationSheet extends StatefulWidget {
  const GroupingGenerationSheet({
    super.key,
    required this.initialStrategy,
    required this.onGenerate,
    required this.onDismiss,
  });

  final String initialStrategy;

  /// Called when the user confirms generation. Receives the selected strategy
  /// key and whether buggy-pairing is requested.
  final void Function(String strategy, bool pairBuggies) onGenerate;

  final VoidCallback onDismiss;

  @override
  State<GroupingGenerationSheet> createState() => _GroupingGenerationSheetState();
}

class _GroupingGenerationSheetState extends State<GroupingGenerationSheet> {
  late String _selectedStrategy;
  bool _pairBuggies = false;

  @override
  void initState() {
    super.initState();
    _selectedStrategy = widget.initialStrategy;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onDismiss,
          child: Container(
            color: Colors.black.withValues(alpha: AppColors.opacityHalf),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rPill)),
              boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x2l),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: AppSpacing.x4l,
                          height: AppSpacing.xs,
                          margin: const EdgeInsets.only(bottom: AppSpacing.x2l),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withValues(alpha: AppColors.opacityMuted),
                            borderRadius: AppShapes.grabber,
                          ),
                        ),
                      ),
                      Text(
                        'Generate Groups',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: AppTypography.weightBlack,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Configure how players are sorted into groups.',
                        style: TextStyle(color: AppColors.dark600, fontSize: AppTypography.sizeBodySmall),
                      ),
                      const SizedBox(height: AppSpacing.x3l),
                      const BoxyArtSectionTitle(title: 'STRATEGY', isLevel2: true),
                      Column(
                        children: [
                          _RadioOption(value: 'balanced',    title: 'Balanced Teams',   subtitle: 'Balances total handicap.',   groupValue: _selectedStrategy, onChanged: (v) => setState(() => _selectedStrategy = v)),
                          _RadioOption(value: 'progressive', title: 'Progressive',       subtitle: 'Low handicap first.',        groupValue: _selectedStrategy, onChanged: (v) => setState(() => _selectedStrategy = v)),
                          _RadioOption(value: 'similar',     title: 'Similar Ability',  subtitle: 'Group by skill level.',      groupValue: _selectedStrategy, onChanged: (v) => setState(() => _selectedStrategy = v)),
                          _RadioOption(value: 'random',      title: 'Random',            subtitle: 'Mix everything up.',         groupValue: _selectedStrategy, onChanged: (v) => setState(() => _selectedStrategy = v)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.x2l),
                      const BoxyArtSectionTitle(title: 'PREFERENCES', isLevel2: true),
                      ModernSwitchRow(
                        label: 'Pair Buggy Users',
                        subtitle: 'Prioritize putting buggy users together.',
                        icon: Icons.electric_rickshaw_rounded,
                        value: _pairBuggies,
                        onChanged: (val) => setState(() => _pairBuggies = val),
                      ),
                      const SizedBox(height: AppSpacing.x3l),
                      Row(
                        children: [
                          Expanded(
                            child: BoxyArtButton(
                              title: 'Cancel',
                              isGhost: true,
                              onTap: widget.onDismiss,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: BoxyArtButton(
                              title: 'Generate',
                              onTap: () => widget.onGenerate(_selectedStrategy, _pairBuggies),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  const _RadioOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.groupValue,
    required this.onChanged,
  });

  final String value;
  final String title;
  final String subtitle;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return BoxyArtCard(
      onTap: () => onChanged(value),
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      border: isSelected
          ? Border.fromBorderSide(BorderSide(color: Theme.of(context).primaryColor, width: AppShapes.borderMedium))
          : null,
      backgroundColor: isSelected ? Theme.of(context).primaryColor.withValues(alpha: AppColors.opacitySubtle) : null,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeButton)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.dark600)),
              ],
            ),
          ),
          Icon(
            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: isSelected ? Theme.of(context).primaryColor : AppColors.dark300,
          ),
        ],
      ),
    );
  }
}
