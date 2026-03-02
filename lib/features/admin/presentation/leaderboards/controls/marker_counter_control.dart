import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:uuid/uuid.dart';

class MarkerCounterControl extends StatefulWidget {
  final LeaderboardConfig? existingConfig;
  final Function(LeaderboardConfig) onSave;

  const MarkerCounterControl({super.key, this.existingConfig, required this.onSave});

  @override
  State<MarkerCounterControl> createState() => _MarkerCounterControlState();
}

class _MarkerCounterControlState extends State<MarkerCounterControl> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late Set<MarkerType> _targetTypes;
  late HoleFilter _holeFilter;
  late MarkerRankingMethod _rankingMethod;
  late TextEditingController _bestNController;

  @override
  void initState() {
    super.initState();
    final config = widget.existingConfig as MarkerCounterConfig?;
    _nameController = TextEditingController(text: config?.name ?? 'Birdie Tree');
    _targetTypes = config?.targetTypes ?? {MarkerType.birdie, MarkerType.eagle, MarkerType.holeInOne};
    _holeFilter = config?.holeFilter ?? HoleFilter.all;
    _rankingMethod = config?.rankingMethod ?? MarkerRankingMethod.count;
    _bestNController = TextEditingController(text: (config?.bestN ?? 0).toString());
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'LEADERBOARD DETAILS'),
          BoxyArtCard(
            padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 24),
          const BoxyArtSectionTitle(title: 'TRACKING RULES'),
          BoxyArtCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TARGET MARKERS',
                  style: AppTypography.label.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark300,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MarkerType.values.map((type) {
                    final isSelected = _targetTypes.contains(type);
                    return ChoiceChip(
                      label: Text(_formatEnum(type.name).toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _targetTypes.add(type);
                          } else {
                            if (_targetTypes.length > 1) {
                              _targetTypes.remove(type);
                            }
                          }
                        });
                      },
                      selectedColor: AppColors.lime500,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.dark600 : AppColors.lightHeader,
                      labelStyle: AppTypography.label.copyWith(
                        color: isSelected ? AppColors.actionText : (Theme.of(context).brightness == Brightness.dark ? AppColors.dark200 : AppColors.dark400),
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                BoxyArtDropdownField<HoleFilter>(
                  label: 'Hole Filter',
                  value: _holeFilter,
                  items: HoleFilter.values.map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(_formatEnum(v.name)),
                  )).toList(),
                  onChanged: (v) => setState(() => _holeFilter = v!),
                ),
                const SizedBox(height: 24),
                BoxyArtDropdownField<MarkerRankingMethod>(
                  label: 'Ranking Basis',
                  value: _rankingMethod,
                  items: MarkerRankingMethod.values.map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(_formatEnum(v.name)),
                  )).toList(),
                  onChanged: (v) => setState(() => _rankingMethod = v!),
                ),
                const SizedBox(height: 24),
                BoxyArtInputField(
                  label: 'Best N Rounds',
                  controller: _bestNController,
                  keyboardType: TextInputType.number,
                  hint: '0 = All rounds counted',
                ),
                const SizedBox(height: 8),
                Text(
                  'Only markers from the best N Stableford rounds will be counted.',
                  style: AppTypography.label.copyWith(
                    color: AppColors.dark400,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                _buildRuleDescription(),
              ],
            ),
          ),
          const SizedBox(height: 24),
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


  String _formatEnum(String val) {
    if (val == 'holeInOne') return 'Hole In One';
    final RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    String result = val.replaceAllMapped(exp, (Match m) => ' ${m.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
  }

  Widget _buildRuleDescription() {
    String goal = '';
    String scoring = '';
    String result = '';

    final typeNames = _targetTypes.map((e) => _formatEnum(e.name)).join(', ');
    final holeDesc = _holeFilter == HoleFilter.all ? 'all holes' : 'only ${_formatEnum(_holeFilter.name)}s';
    
    goal = 'Collect the most $typeNames.';
    scoring = 'Count markers on $holeDesc.';
    if (int.tryParse(_bestNController.text) != null && int.parse(_bestNController.text) > 0) {
      scoring += ' (Best ${_bestNController.text} rounds only)';
    }
    
    result = _rankingMethod == MarkerRankingMethod.count 
       ? 'Player with highest total count wins.'
       : 'Player with highest Stableford points from these markers wins.';

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark600 : AppColors.lime500.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
           _buildInfoRow('Goal', goal),
           const SizedBox(height: 8),
           _buildInfoRow('Scoring', scoring),
           const SizedBox(height: 8),
           _buildInfoRow('Result', result),
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
              fontWeight: FontWeight.w900, 
              color: AppColors.lime500,
              fontSize: 11,
            )
          )
        ),
        Expanded(
          child: Text(
            value, 
            style: AppTypography.label.copyWith(
              fontSize: 11,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark700,
            )
          )
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    final config = LeaderboardConfig.markerCounter(
      id: widget.existingConfig?.id ?? const Uuid().v4(),
      name: _nameController.text,
      targetTypes: _targetTypes,
      holeFilter: _holeFilter,
      rankingMethod: _rankingMethod,
      bestN: int.tryParse(_bestNController.text) ?? 0,
    );
    
    widget.onSave(config);
  }
}
