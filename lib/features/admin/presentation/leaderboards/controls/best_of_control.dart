import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:uuid/uuid.dart';
import 'base_leaderboard_control.dart';

class BestOfSeriesControl extends StatefulWidget {
  final LeaderboardConfig? existingConfig;
  final Function(LeaderboardConfig) onSave;

  const BestOfSeriesControl({super.key, this.existingConfig, required this.onSave});

  @override
  State<BestOfSeriesControl> createState() => _BestOfSeriesControlState();
}

class _BestOfSeriesControlState extends State<BestOfSeriesControl>
    with BaseLeaderboardControlMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bestNController;
  late TextEditingController _appearancePointsController;
  late BestOfMetric _metric;
  late ScoringType _scoringType;
  late TiePolicy _tiePolicy;
  late Map<int, int> _positionPoints;
  late LeaderboardScope _scope;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final config = widget.existingConfig as BestOfSeriesConfig?;
    _nameController = TextEditingController(text: config?.name ?? 'Best Of Series');
    _bestNController = TextEditingController(text: (config?.bestN ?? 8).toString());
    _appearancePointsController =
        TextEditingController(text: (config?.appearancePoints ?? 0).toString());
    _scope = config?.scope ?? LeaderboardScope.seasonOnly;

    _metric = config?.metric ?? BestOfMetric.stableford;
    if (_metric == BestOfMetric.position) {
      _metric = BestOfMetric.stableford;
      _scoringType = ScoringType.position;
    } else {
      _scoringType = config?.scoringType ?? ScoringType.accumulative;
    }

    _tiePolicy = config?.tiePolicy ?? TiePolicy.countback;

    if (config?.positionPointsMap != null && config!.positionPointsMap.isNotEmpty) {
      _positionPoints = Map.from(config.positionPointsMap);
    } else {
      _positionPoints = {1: 100, 2: 75, 3: 60, 4: 50, 5: 40, 6: 30, 7: 20, 8: 10};
    }

    _bestNController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bestNController.dispose();
    _appearancePointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayMetrics =
        BestOfMetric.values.where((m) => m != BestOfMetric.position).toList();

    return Form(
      key: _formKey,
      child: BoxyArtFormColumn(
        children: [
          // ── IDENTITY ─────────────────────────────────────────
          const BoxyArtSectionTitle(title: 'LEADERBOARD DETAILS', isPeeking: true),
          BoxyArtCard(
            child: BoxyArtFormColumn(
              children: [
                BoxyArtInputField(
                  label: 'Name',
                  controller: _nameController,
                  hint: 'e.g. Best of Series',
                  prefixIcon: Icon(Icons.list_alt_rounded),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                buildScopeSelector(
                  value: _scope,
                  onChanged: (v) => setState(() => _scope = v as LeaderboardScope),
                ),
              ],
            ),
          ),

          // ── LEAGUE RULES ──────────────────────────────────────
          const BoxyArtSectionTitle(title: 'LEAGUE RULES'),
          BoxyArtCard(
            child: BoxyArtFormColumn(
              children: [
                BoxyArtInputField(
                  label: 'Count Best N Rounds',
                  controller: _bestNController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(Icons.filter_list_rounded),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return (n == null || n < 1) ? 'Enter a number ≥ 1' : null;
                  },
                ),
                buildInfoBubble('Only the top N scores will count toward the final total.'),
                BoxyArtDropdownField<BestOfMetric>(
                  label: 'Metric',
                  value: _metric,
                  items: displayMetrics
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(formatEnum(v.name)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _metric = v!),
                ),
                BoxyArtDropdownField<ScoringType>(
                  label: 'Scoring Type',
                  value: _scoringType,
                  items: ScoringType.values
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(formatEnum(v.name)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _scoringType = v!),
                ),
                buildInfoCard(_ruleRows()),
              ],
            ),
          ),

          // ── POINTS DISTRIBUTION ───────────────────────────────
          if (_scoringType == ScoringType.position) ...[
            const BoxyArtSectionTitle(title: 'POINTS DISTRIBUTION'),
            BoxyArtCard(
              child: BoxyArtFormColumn(
                children: [
                  BoxyArtInputField(
                    label: 'Appearance Points (bonus per event)',
                    controller: _appearancePointsController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.star_outline_rounded),
                  ),
                  Divider(
                      color: theme.dividerColor
                          .withValues(alpha: AppColors.opacityLow)),
                  BoxyArtFormColumn(
                    spacing: AppSpacing.md,
                    children: (_positionPoints.entries.toList()
                        ..sort((a, b) => a.key.compareTo(b.key)))
                        .map((e) => buildPointRow(
                              position: e.key,
                              points: e.value,
                              onChanged: (pos, val) =>
                                  setState(() => _positionPoints[pos] = val),
                              onRemove: (pos) =>
                                  setState(() => _positionPoints.remove(pos)),
                            )).toList(),
                  ),
                  buildAddButton(
                    label: 'Add next position',
                    onTap: _addNextPosition,
                  ),
                ],
              ),
            ),
          ],

          BoxyArtButton(
            title: widget.existingConfig == null ? 'Create leaderboard' : 'Save changes',
            onTap: _isSaving ? null : _save,
            isLoading: _isSaving,
            fullWidth: true,
            backgroundColor: Theme.of(context).primaryColor,
            textColor: AppColors.pureWhite,
          ),
        ],
      ),
    );
  }

  List<(String, String)> _ruleRows() {
    final bestN = _bestNController.text;
    String goal = '';
    String scoring = '';
    String result = '';

    if (_scoringType == ScoringType.position) {
      final basis = _metric == BestOfMetric.stableford ? 'Stableford rank' : 'Gross rank';
      goal = 'Highest Position Points (Best $bestN) — based on $basis.';
      scoring = 'Sum of points from best $bestN finishes.';
      result = 'Highest total points wins.';
    } else {
      switch (_metric) {
        case BestOfMetric.stableford:
          goal = 'Highest Stableford points (Best $bestN).';
          scoring = 'Sum of best $bestN rounds.';
          result = 'Highest total wins.';
          break;
        case BestOfMetric.gross:
          goal = 'Lowest Gross Score (Best $bestN).';
          scoring = 'Sum of lowest $bestN gross scores.';
          result = 'Lowest total wins.';
          break;
        case BestOfMetric.net:
          goal = 'Lowest Net Score (Best $bestN).';
          scoring = 'Sum of lowest $bestN net scores.';
          result = 'Lowest total wins.';
          break;
        default:
          break;
      }
    }

    final tieText = _tiePolicy == TiePolicy.countback
        ? 'Countback on last card.'
        : _tiePolicy == TiePolicy.shared
            ? 'Position shared.'
            : 'Playoff required.';

    return [
      ('Goal', goal),
      ('Scoring', scoring),
      ('Result', result),
      ('Tie-Break', tieText),
    ];
  }

  void _addNextPosition() {
    int nextPos = 1;
    if (_positionPoints.isNotEmpty) {
      final maxPos =
          _positionPoints.keys.reduce((curr, next) => curr > next ? curr : next);
      nextPos = maxPos + 1;
    }
    setState(() => _positionPoints[nextPos] = 0);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final config = LeaderboardConfig.bestOfSeries(
      id: widget.existingConfig?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      scope: _scope,
      bestN: int.parse(_bestNController.text),
      metric: _metric,
      scoringType: _scoringType,
      tiePolicy: TiePolicy.shared,
      positionPointsMap:
          _scoringType == ScoringType.position ? _positionPoints : {},
      appearancePoints:
          int.tryParse(_appearancePointsController.text) ?? 0,
    );

    widget.onSave(config);
  }
}
