import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/division_config.dart';
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
  Division? _divisionFilter;
  bool _isSaving = false;
  bool _showMarkersError = false;

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
    _divisionFilter = config?.divisionFilter;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bestNController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                buildScopeSelector(
                  value: _scope,
                  onChanged: (v) => setState(() => _scope = v as LeaderboardScope),
                ),
                buildDivisionFilterSelector(
                  value: _divisionFilter,
                  onChanged: (v) => setState(() => _divisionFilter = v),
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
                  onChanged: (v) => setState(() {
                    _rankingMethod = v!;
                    _showMarkersError = false;
                  }),
                ),
                if (_rankingMethod == MarkerRankingMethod.count)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TARGET MARKERS',
                        style: AppTypography.micro.copyWith(
                          color: isDarkMode ? AppColors.dark200 : AppColors.dark400,
                          fontWeight: AppTypography.weightBold,
                          letterSpacing: AppTypography.lsLabel,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _markerGrid(AppSpacing.xs),
                      if (_showMarkersError) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Select at least one marker type.',
                          style: AppTypography.micro.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
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

  Widget _markerGrid(double gap) {
    final types = MarkerType.values;
    final rows = <Widget>[];
    for (int i = 0; i < types.length; i += 2) {
      if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
      final slice = types.sublist(i, (i + 2).clamp(0, types.length));
      final cells = <Widget>[];
      for (int j = 0; j < 2; j++) {
        if (j > 0) cells.add(SizedBox(width: gap));
        if (j < slice.length) {
          final type = slice[j];
          final isSelected = _targetTypes.contains(type);
          cells.add(Expanded(
            child: BoxyArtButton(
              title: type == MarkerType.two ? "TWO'S" : formatEnum(type.name),
              isTinted: isSelected,
              isGhost: !isSelected,
              isSmall: true,
              onTap: () => setState(() {
                if (isSelected) {
                  _targetTypes = {..._targetTypes}..remove(type);
                } else {
                  _targetTypes = {..._targetTypes, type};
                  _showMarkersError = false;
                }
              }),
            ),
          ));
        } else {
          cells.add(const Expanded(child: SizedBox.shrink()));
        }
      }
      rows.add(Row(children: cells));
    }
    return Column(children: rows);
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
    final isCountMode = _rankingMethod == MarkerRankingMethod.count;
    if (isCountMode && _targetTypes.isEmpty) {
      setState(() => _showMarkersError = true);
      return;
    }

    setState(() => _isSaving = true);

    final config = LeaderboardConfig.markerCounter(
      id: widget.existingConfig?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      scope: _scope,
      targetTypes: isCountMode ? _targetTypes : MarkerType.values.toSet(),
      holeFilter: _holeFilter,
      rankingMethod: _rankingMethod,
      bestN: int.tryParse(_bestNController.text) ?? 0,
      divisionFilter: _divisionFilter,
    );

    widget.onSave(config);
  }
}
