import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:uuid/uuid.dart';
import 'base_leaderboard_control.dart';

class MarkerCounterControl extends ConsumerStatefulWidget {
  final LeaderboardConfig? existingConfig;
  final Function(LeaderboardConfig) onSave;

  const MarkerCounterControl({
    super.key,
    this.existingConfig,
    required this.onSave,
  });

  @override
  ConsumerState<MarkerCounterControl> createState() => _MarkerCounterControlState();
}

class _MarkerCounterControlState extends ConsumerState<MarkerCounterControl>
    with BaseLeaderboardControlMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late Set<MarkerType> _targetTypes;
  late HoleFilter _holeFilter;
  late MarkerRankingMethod _rankingMethod;
  late TextEditingController _bestNController;
  late LeaderboardScope _scope;
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
    _scope = config?.scope ?? LeaderboardScope.seasonOnly;
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── IDENTITY ─────────────────────────────────────────
          const BoxyArtSectionTitle(title: 'LEADERBOARD DETAILS', isPeeking: true),
          BoxyArtCard(
            child: BoxyArtFormColumn(
              children: [
                BoxyArtInputField(
                  label: 'Name',
                  controller: _nameController,
                  hint: 'e.g. Birdie Tree',
                  prefixIcon: Icon(Icons.park_rounded),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const BoxyArtDivider(),
                buildScopeSelector(
                  value: _scope,
                  onChanged: (v) => setState(() => _scope = v as LeaderboardScope),
                ),
              ],
            ),
          ),

          // ── TRACKING RULES ────────────────────────────────────
          const BoxyArtSectionTitle(
            title: 'TRACKING RULES',
            isPeeking: true,
            followsCard: true,
          ),
          BoxyArtCard(
            child: BoxyArtFormColumn(
              children: [
                // Target marker chips
                BoxyArtFormColumn(
                  spacing: AppSpacing.md,
                  children: [
                    Text(
                      'TARGET MARKERS',
                      style: AppTypography.labelStrong.copyWith(
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: MarkerType.values.map((type) {
                        final isSelected = _targetTypes.contains(type);
                        final labelText = formatEnum(type.name);
                        
                        return ChoiceChip(
                          label: Text(labelText),
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
                          backgroundColor: isDarkMode ? AppColors.dark600 : AppColors.lightHeader,
                          labelStyle: AppTypography.label.copyWith(
                            color: isSelected
                                ? AppColors.pureWhite
                                : (isDarkMode ? AppColors.dark200 : AppColors.dark500),
                            fontWeight: isSelected ? AppTypography.weightBlack : AppTypography.weightBold,
                            fontSize: AppTypography.sizeLabel,
                          ),
                          side: isSelected
                              ? BorderSide.none
                              : BorderSide(
                                  color: isDarkMode ? AppColors.dark500 : AppColors.dark100,
                                  width: 1,
                                ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ref.watch(themeControllerProvider).pillRadius),
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 3,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const BoxyArtDivider(),
                BoxyArtDropdownField<HoleFilter>(
                  label: 'Hole Filter',
                  prefixIcon: const Icon(Icons.adjust_rounded),
                  value: _holeFilter,
                  items: HoleFilter.values
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(formatEnum(v.name)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _holeFilter = v!),
                ),
                const BoxyArtDivider(),
                BoxyArtDropdownField<MarkerRankingMethod>(
                  label: 'Ranking Basis',
                  prefixIcon: const Icon(Icons.sort_rounded),
                  value: _rankingMethod,
                  items: MarkerRankingMethod.values
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(formatEnum(v.name)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _rankingMethod = v!),
                ),
                const BoxyArtDivider(),
                BoxyArtFormColumn(
                  spacing: AppSpacing.sm,
                  children: [
                    BoxyArtInputField(
                      label: 'Best N Rounds',
                      controller: _bestNController,
                      keyboardType: TextInputType.number,
                      hint: '0 = All rounds counted',
                      prefixIcon: const Icon(Icons.filter_list_rounded),
                    ),
                    buildInfoBubble(
                        'Only markers from the best N Stableford rounds will be counted.'),
                  ],
                ),

                buildInfoCard(_ruleRows()),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.x2l, bottom: AppSpacing.xl),
            child: BoxyArtButton(
              title: widget.existingConfig == null ? 'Create leaderboard' : 'Save changes',
              onTap: _isSaving ? null : _save,
              isLoading: _isSaving,
              fullWidth: true,
            ),
          ),
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
      scope: _scope,
      targetTypes: _targetTypes,
      holeFilter: _holeFilter,
      rankingMethod: _rankingMethod,
      bestN: int.tryParse(_bestNController.text) ?? 0,
    );

    widget.onSave(config);
  }
}
