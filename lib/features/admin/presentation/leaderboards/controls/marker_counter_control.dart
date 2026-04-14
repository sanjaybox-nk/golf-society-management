import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:uuid/uuid.dart';
import 'base_leaderboard_control.dart';

class MarkerCounterControl extends StatefulWidget {
  final LeaderboardConfig? existingConfig;
  final Function(LeaderboardConfig) onSave;

  const MarkerCounterControl({
    super.key,
    this.existingConfig,
    required this.onSave,
  });

  @override
  State<MarkerCounterControl> createState() => _MarkerCounterControlState();
}

class _MarkerCounterControlState extends State<MarkerCounterControl>
    with BaseLeaderboardControlMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late Set<MarkerType> _targetTypes;
  late HoleFilter _holeFilter;
  late MarkerRankingMethod _rankingMethod;
  late TextEditingController _bestNController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final config = widget.existingConfig as MarkerCounterConfig?;
    _nameController = TextEditingController(text: config?.name ?? 'Birdie Tree');
    _targetTypes = config?.targetTypes ??
        {MarkerType.birdie, MarkerType.eagle, MarkerType.holeInOne};
    _holeFilter = config?.holeFilter ?? HoleFilter.all;
    _rankingMethod = config?.rankingMethod ?? MarkerRankingMethod.count;
    _bestNController = TextEditingController(
        text: (config?.bestN ?? 0).toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bestNController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── IDENTITY ─────────────────────────────────────────
          const BoxyArtSectionTitle(title: 'LEADERBOARD DETAILS', isPeeking: true),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: BoxyArtInputField(
              label: 'Name',
              controller: _nameController,
              hint: 'e.g. Birdie Tree',
              prefixIcon: Icon(Icons.park_rounded),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
          ),

          // ── TRACKING RULES ────────────────────────────────────
          const BoxyArtSectionTitle(title: 'TRACKING RULES'),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target marker chips
                Text(
                  'TARGET MARKERS',
                  style: AppTypography.labelStrong.copyWith(
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: MarkerType.values.map((type) {
                    final isSelected = _targetTypes.contains(type);
                    return ChoiceChip(
                      label: Text(formatEnum(type.name)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _targetTypes.add(type);
                          } else if (_targetTypes.length > 1) {
                            _targetTypes.remove(type);
                          }
                        });
                      },
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: isDarkMode
                          ? AppColors.dark600
                          : AppColors.lightHeader,
                      labelStyle: AppTypography.label.copyWith(
                        color: isSelected
                            ? AppColors.pureWhite
                            : (isDarkMode
                                ? AppColors.dark200
                                : AppColors.dark400),
                        fontSize: AppTypography.sizeCaption,
                        fontWeight: isSelected
                            ? AppTypography.weightBlack
                            : AppTypography.weightBold,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppShapes.md,
                      ),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.xl),
                BoxyArtDropdownField<HoleFilter>(
                  label: 'Hole Filter',
                  value: _holeFilter,
                  items: HoleFilter.values
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(formatEnum(v.name)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _holeFilter = v!),
                ),

                const SizedBox(height: AppSpacing.lg),
                BoxyArtDropdownField<MarkerRankingMethod>(
                  label: 'Ranking Basis',
                  value: _rankingMethod,
                  items: MarkerRankingMethod.values
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(formatEnum(v.name)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _rankingMethod = v!),
                ),

                const SizedBox(height: AppSpacing.lg),
                BoxyArtInputField(
                  label: 'Best N Rounds',
                  controller: _bestNController,
                  keyboardType: TextInputType.number,
                  hint: '0 = All rounds counted',
                  prefixIcon: Icon(Icons.filter_list_rounded),
                ),
                buildInfoBubble(
                    'Only markers from the best N Stableford rounds will be counted.'),

                buildInfoCard(_ruleRows()),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.x4l),
          BoxyArtButton(
            title: widget.existingConfig == null ? 'Create leaderboard' : 'Save changes',
            onTap: _isSaving ? null : _save,
            isLoading: _isSaving,
            fullWidth: true,
            backgroundColor: Theme.of(context).primaryColor,
            textColor: AppColors.pureWhite,
          ),
          const SizedBox(height: AppSpacing.x4l),
        ],
      ),
    );
  }

  List<(String, String)> _ruleRows() {
    final typeNames = _targetTypes.map((e) => formatEnum(e.name)).join(', ');
    final holeDesc = _holeFilter == HoleFilter.all
        ? 'all holes'
        : 'only ${formatEnum(_holeFilter.name)}s';

    String scoring = 'Count markers on $holeDesc.';
    final bestN = int.tryParse(_bestNController.text) ?? 0;
    if (bestN > 0) scoring += ' (Best $bestN rounds only)';

    final result = _rankingMethod == MarkerRankingMethod.count
        ? 'Player with highest total count wins.'
        : 'Player with highest Stableford points from these markers wins.';

    return [
      ('Goal', 'Collect the most $typeNames.'),
      ('Scoring', scoring),
      ('Result', result),
    ];
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final config = LeaderboardConfig.markerCounter(
      id: widget.existingConfig?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      targetTypes: _targetTypes,
      holeFilter: _holeFilter,
      rankingMethod: _rankingMethod,
      bestN: int.tryParse(_bestNController.text) ?? 0,
    );

    widget.onSave(config);
  }
}
