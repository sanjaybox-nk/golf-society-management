import 'package:flutter/material.dart';
import '../../../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../../../models/leaderboard_config.dart';
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
          BoxyArtFloatingCard(
            child: Column(
              children: [
                BoxyArtFormField(
                  label: 'Name',
                  controller: _nameController,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const BoxyArtSectionTitle(title: 'TRACKING RULES'),
          BoxyArtFloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TARGET MARKERS', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MarkerType.values.map((type) {
                    final isSelected = _targetTypes.contains(type);
                    return FilterChip(
                      label: Text(_formatEnum(type.name)),
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
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white10,
                      checkmarkColor: Colors.black,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _buildEnumDropdown('Hole Filter', HoleFilter.values, _holeFilter, (v) => setState(() => _holeFilter = v!)),
                const SizedBox(height: 24),
                _buildEnumDropdown('Ranking Basis', MarkerRankingMethod.values, _rankingMethod, (v) => setState(() => _rankingMethod = v!)),
                const SizedBox(height: 24),
                BoxyArtFormField(
                  label: 'Best N Rounds',
                  controller: _bestNController,
                  keyboardType: TextInputType.number,
                  hintText: '0 = All rounds counted',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Only markers from the best N Stableford rounds will be counted.',
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
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

  Widget _buildEnumDropdown<T>(String label, List<T> values, T currentValue, Function(T?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: currentValue,
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              onChanged: onChanged,
              items: values.map((v) => DropdownMenuItem(
                value: v,
                child: Text(_formatEnum(v.toString().split('.').last)),
              )).toList(),
            ),
          ),
        ),
      ],
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
        color: Theme.of(context).scaffoldBackgroundColor, 
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
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: Theme.of(context).primaryColor,
              fontSize: 13
            )
          )
        ),
        Expanded(
          child: Text(
            value, 
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color
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
