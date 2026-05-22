import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:uuid/uuid.dart';
import 'base_leaderboard_control.dart';

class EclecticControl extends StatefulWidget {
  final LeaderboardConfig? existingConfig;
  final Function(LeaderboardConfig) onSave;

  const EclecticControl({super.key, this.existingConfig, required this.onSave});

  @override
  State<EclecticControl> createState() => _EclecticControlState();
}

class _EclecticControlState extends State<EclecticControl>
    with BaseLeaderboardControlMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late EclecticMetric _metric;
  double _handicapPercentage = 0;
  late LeaderboardScope _scope;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final config = widget.existingConfig as EclecticConfig?;
    _nameController = TextEditingController(text: config?.name ?? 'Eclectic');
    _metric = config?.metric ?? EclecticMetric.strokes;
    _handicapPercentage = (config?.handicapPercentage ?? 0).toDouble();
    _scope = config?.scope ?? LeaderboardScope.seasonOnly;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                  hint: 'e.g. Eclectic',
                  prefixIcon: Icon(Icons.grid_on_rounded),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                buildScopeSelector(
                  value: _scope,
                  onChanged: (v) => setState(() => _scope = v as LeaderboardScope),
                ),
              ],
            ),
          ),

          // ── ECLECTIC RULES ────────────────────────────────────
          const BoxyArtSectionTitle(
            title: 'ECLECTIC RULES',
            isPeeking: true,
            followsCard: true,
          ),
          BoxyArtCard(
            child: BoxyArtFormColumn(
              children: [
                BoxyArtDropdownField<EclecticMetric>(
                  label: 'Metric',
                  prefixIcon: const Icon(Icons.show_chart_rounded),
                  value: _metric,
                  items: EclecticMetric.values
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(formatEnum(v.name)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _metric = v!),
                ),

                if (_metric == EclecticMetric.strokes) ...[
                  BoxyArtFormColumn(
                    spacing: AppSpacing.sm,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'HANDICAP ALLOWANCE',
                            style: AppTypography.labelStrong.copyWith(
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 1.0,
                            ),
                          ),
                          BoxyArtPill.format(
                            label: _handicapPercentage == 0
                                ? 'None'
                                : '${_handicapPercentage.toInt()}%',
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      BoxyArtSlider(
                        value: _handicapPercentage,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: '${_handicapPercentage.toInt()}%',
                        isNeutral: true,
                        onChanged: (v) => setState(() => _handicapPercentage = v),
                      ),
                      buildInfoBubble(
                        _handicapPercentage == 0
                            ? 'Gross Score — no handicap applied.'
                            : 'Net Score — Gross minus ${_handicapPercentage.toInt()}% of Final Handicap.',
                      ),
                    ],
                  ),
                ],

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
    String goal = '';
    String scoring = '';
    String result = '';

    if (_metric == EclecticMetric.strokes) {
      if (_handicapPercentage > 0) {
        goal = 'Lowest Net Composite Score.';
        scoring = 'Best Gross holes − ${_handicapPercentage.toInt()}% Handicap.';
      } else {
        goal = 'Lowest Gross Composite Score.';
        scoring = 'Best Gross score on each hole.';
      }
      result = 'Lowest total wins.';
    } else {
      goal = 'Highest Composite Points.';
      scoring = 'Best Stableford points on each hole.';
      result = 'Highest total points wins.';
    }

    return [('Goal', goal), ('Scoring', scoring), ('Result', result)];
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final config = LeaderboardConfig.eclectic(
      id: widget.existingConfig?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      scope: _scope,
      metric: _metric,
      handicapPercentage: _handicapPercentage.toInt(),
    );

    widget.onSave(config);
  }
}
