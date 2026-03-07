import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:uuid/uuid.dart';

class OrderOfMeritControl extends StatefulWidget {
  final LeaderboardConfig? existingConfig;
  final Function(LeaderboardConfig) onSave;

  const OrderOfMeritControl({super.key, this.existingConfig, required this.onSave});

  @override
  State<OrderOfMeritControl> createState() => _OrderOfMeritControlState();
}

class _OrderOfMeritControlState extends State<OrderOfMeritControl> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _appearancePointsController;
  
  // Local state for UI
  late OOMRankingBasis _metric; 
  late ScoringType _scoringType;

  late Map<int, int> _positionPoints;

  @override
  void initState() {
    super.initState();
    final config = widget.existingConfig as OrderOfMeritConfig?;
    _nameController = TextEditingController(text: config?.name ?? 'Order of Merit');
    _appearancePointsController = TextEditingController(text: (config?.appearancePoints ?? 0).toString());
    
    // Map existing config to UI state
    final source = config?.source ?? OOMSource.position;
    final basis = config?.rankingBasis ?? OOMRankingBasis.stableford;

    if (source == OOMSource.position) {
       _scoringType = ScoringType.position;
       _metric = basis; 
    } else if (source == OOMSource.stableford) {
       _scoringType = ScoringType.accumulative;
       _metric = OOMRankingBasis.stableford;
    } else { // Gross
       _scoringType = ScoringType.accumulative;
       _metric = OOMRankingBasis.gross;
    }
    
    // Initialize points map
    if (config?.positionPointsMap != null && config!.positionPointsMap.isNotEmpty) {
      _positionPoints = Map.from(config.positionPointsMap);
    } else {
      _positionPoints = {1: 100, 2: 75, 3: 60, 4: 50, 5: 40, 6: 30, 7: 20, 8: 10};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'LEADERBOARD DETAILS'),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                BoxyArtInputField(
                  label: 'Name',
                  controller: _nameController,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          const BoxyArtSectionTitle(title: 'SCORING RULES'),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoxyArtDropdownField<OOMRankingBasis>(
                  label: 'Metric',
                  value: _metric,
                  items: OOMRankingBasis.values.map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(_formatEnum(v.name)),
                  )).toList(),
                  onChanged: (v) => setState(() => _metric = v!),
                ),
                const SizedBox(height: AppSpacing.lg),
                BoxyArtDropdownField<ScoringType>(
                  label: 'Scoring Type',
                  value: _scoringType,
                  items: ScoringType.values.map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(_formatEnum(v.name)),
                  )).toList(),
                  onChanged: (v) => setState(() => _scoringType = v!),
                ),
                _buildRuleDescription(),
              ],
            ),
          ),
        
          if (_scoringType == ScoringType.position) ...[
            const SizedBox(height: AppSpacing.x2l),
            const BoxyArtSectionTitle(title: 'POINTS DISTRIBUTION'),
            BoxyArtCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  BoxyArtInputField(
                    label: 'Appearance Points (Bonus per event)',
                    controller: _appearancePointsController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow)),
                  const SizedBox(height: AppSpacing.lg),
                  ...(_positionPoints.entries.toList()..sort((a, b) => a.key.compareTo(b.key))).map((e) => _buildPointRow(e.key, e.value)),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: BoxyArtButton(
                      title: 'ADD NEXT POSITION',
                      onTap: _addNextPosition,
                      isSecondary: true,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.x2l),
          Center(
            child: BoxyArtButton(
              title: 'SAVE CHANGES',
              onTap: _save,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointRow(int position, int points) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_ordinal(position)} Place'.toUpperCase(),
              style: AppTypography.label.copyWith(
                color: isDark ? AppColors.dark150 : AppColors.dark400,
                fontWeight: AppTypography.weightBlack,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: points.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(fontWeight: AppTypography.weightBold),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
                fillColor: isDark ? AppColors.dark600 : AppColors.lightHeader,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: AppShapes.md,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppShapes.md,
                  borderSide: BorderSide(color: isDark ? AppColors.dark500 : AppColors.dark100),
                ),
              ),
              onChanged: (val) {
                final newValue = int.tryParse(val);
                if (newValue != null) {
                  setState(() {
                    _positionPoints[position] = newValue;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text('PTS', style: AppTypography.label.copyWith(fontSize: AppTypography.sizeCaption, color: AppColors.lime500, fontWeight: AppTypography.weightBlack)),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.close, size: AppShapes.iconSm, color: Colors.redAccent),
            onPressed: () => setState(() => _positionPoints.remove(position)),
            visualDensity: VisualDensity.compact,
          )
        ],
      ),
    );
  }

  void _addNextPosition() {
    int nextPos = 1;
    if (_positionPoints.isNotEmpty) {
      final maxPos = _positionPoints.keys.reduce((curr, next) => curr > next ? curr : next);
      nextPos = maxPos + 1;
    }
    setState(() {
      _positionPoints[nextPos] = 0;
    });
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  Widget _buildRuleDescription() {
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
        // Accumulative
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

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.x2l),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark600 : AppColors.lime500.withValues(alpha: AppColors.opacitySubtle),
        borderRadius: AppShapes.md,
      ),
      child: Column(
        children: [
           _buildInfoRow('Goal', goal),
           const SizedBox(height: AppSpacing.sm),
           _buildInfoRow('Scoring', scoring),
           const SizedBox(height: AppSpacing.sm),
           _buildInfoRow('Result', result),
           const SizedBox(height: AppSpacing.sm),
           _buildInfoRow('Tie-Break', tie),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80, 
          child: Text(
            '$label:', 
            style: AppTypography.label.copyWith(
              fontWeight: AppTypography.weightBlack, 
              color: AppColors.lime500,
              fontSize: AppTypography.sizeCaptionStrong,
            )
          )
        ),
        Expanded(
          child: Text(
            value, 
            style: AppTypography.label.copyWith(
              fontSize: AppTypography.sizeCaptionStrong,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark700,
            )
          )
        ),
      ],
    );
  }


  String _formatEnum(String val) {
    final RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    String result = val.replaceAllMapped(exp, (Match m) => ' ${m.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    // Convert Metric + Scoring Type -> Source + RankingBasis
    OOMSource source;
    OOMRankingBasis basis = _metric;

    if (_scoringType == ScoringType.position) {
      source = OOMSource.position;
    } else {
      source = (_metric == OOMRankingBasis.stableford) ? OOMSource.stableford : OOMSource.gross;
    }

    final config = LeaderboardConfig.orderOfMerit(
      id: widget.existingConfig?.id ?? const Uuid().v4(),
      name: _nameController.text,
      source: source,
      rankingBasis: basis,
      appearancePoints: int.tryParse(_appearancePointsController.text) ?? 0,
      positionPointsMap: _scoringType == ScoringType.position ? _positionPoints : {},
    );
    
    widget.onSave(config);
  }
}
