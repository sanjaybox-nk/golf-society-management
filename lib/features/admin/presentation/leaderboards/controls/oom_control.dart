import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:uuid/uuid.dart';
import 'base_leaderboard_control.dart';

class OrderOfMeritControl extends StatefulWidget {
  final LeaderboardConfig? existingConfig;
  final Function(LeaderboardConfig) onSave;

  const OrderOfMeritControl({super.key, this.existingConfig, required this.onSave});

  @override
  State<OrderOfMeritControl> createState() => _OrderOfMeritControlState();
}

class _OrderOfMeritControlState extends State<OrderOfMeritControl>
    with BaseLeaderboardControlMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _appearancePointsController;

  late OOMRankingBasis _metric;
  late ScoringType _scoringType;
  late Map<int, int> _positionPoints;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final config = widget.existingConfig as OrderOfMeritConfig?;
    _nameController = TextEditingController(text: config?.name ?? 'Order of Merit');
    _appearancePointsController =
        TextEditingController(text: (config?.appearancePoints ?? 0).toString());

    final source = config?.source ?? OOMSource.position;
    final basis = config?.rankingBasis ?? OOMRankingBasis.stableford;

    if (source == OOMSource.position) {
      _scoringType = ScoringType.position;
      _metric = basis;
    } else if (source == OOMSource.stableford) {
      _scoringType = ScoringType.accumulative;
      _metric = OOMRankingBasis.stableford;
    } else {
      _scoringType = ScoringType.accumulative;
      _metric = OOMRankingBasis.gross;
    }

    if (config?.positionPointsMap != null && config!.positionPointsMap.isNotEmpty) {
      _positionPoints = Map.from(config.positionPointsMap);
    } else {
      _positionPoints = {1: 100, 2: 75, 3: 60, 4: 50, 5: 40, 6: 30, 7: 20, 8: 10};
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _appearancePointsController.dispose();
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
              hint: 'e.g. Order of Merit',
              prefixIcon: Icon(Icons.emoji_events_rounded),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
          ),

          // ── SCORING RULES ─────────────────────────────────────
          const BoxyArtSectionTitle(title: 'SCORING RULES'),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoxyArtDropdownField<OOMRankingBasis>(
                  label: 'Metric',
                  value: _metric,
                  items: OOMRankingBasis.values
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(formatEnum(v.name)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _metric = v!),
                ),
                const SizedBox(height: AppSpacing.lg),
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
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxyArtInputField(
                    label: 'Appearance Points (bonus per event)',
                    controller: _appearancePointsController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.star_outline_rounded),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Divider(
                      color: theme.dividerColor
                          .withValues(alpha: AppColors.opacityLow)),
                  const SizedBox(height: AppSpacing.lg),
                  ...(_positionPoints.entries.toList()
                      ..sort((a, b) => a.key.compareTo(b.key)))
                      .map((e) => buildPointRow(
                            position: e.key,
                            points: e.value,
                            onChanged: (pos, val) =>
                                setState(() => _positionPoints[pos] = val),
                            onRemove: (pos) =>
                                setState(() => _positionPoints.remove(pos)),
                          )),
                  const SizedBox(height: AppSpacing.lg),
                  buildAddButton(
                    label: 'Add next position',
                    onTap: _addNextPosition,
                  ),
                ],
              ),
            ),
          ],

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
    String goal = '';
    String scoring = '';
    String result = '';
    String tie = '';

    if (_scoringType == ScoringType.position) {
      if (_metric == OOMRankingBasis.gross) {
        goal = 'Finish with lowest total strokes (Gross).';
        scoring = 'Points awarded based on final position.';
        result = 'Highest total points wins.';
        tie = 'Countback (Back 9, Last 6, 3, 1).';
      } else {
        goal = 'Finish with highest Stableford points.';
        scoring = 'Points awarded based on final position.';
        result = 'Highest total points wins.';
        tie = 'Lower Gross Score wins position.';
      }
    } else {
      if (_metric == OOMRankingBasis.stableford) {
        goal = 'Accumulate Stableford points.';
        scoring = 'Sum of all round points.';
        result = 'Highest total points wins.';
        tie = 'Lower Gross Total.';
      } else {
        goal = 'Accumulate strokes.';
        scoring = 'Sum of all strokes (NR = DQ).';
        result = 'Lowest total strokes wins.';
        tie = 'Countback.';
      }
    }

    return [
      ('Goal', goal),
      ('Scoring', scoring),
      ('Result', result),
      ('Tie-Break', tie),
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

    OOMSource source;
    final OOMRankingBasis basis = _metric;

    if (_scoringType == ScoringType.position) {
      source = OOMSource.position;
    } else {
      source = (_metric == OOMRankingBasis.stableford)
          ? OOMSource.stableford
          : OOMSource.gross;
    }

    setState(() => _isSaving = true);

    final config = LeaderboardConfig.orderOfMerit(
      id: widget.existingConfig?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      source: source,
      rankingBasis: basis,
      appearancePoints: int.tryParse(_appearancePointsController.text) ?? 0,
      positionPointsMap:
          _scoringType == ScoringType.position ? _positionPoints : {},
    );

    widget.onSave(config);
  }
}
