import 'package:flutter/material.dart';
import '../../../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../../../models/leaderboard_config.dart';
import 'package:uuid/uuid.dart';

class BestOfSeriesControl extends StatefulWidget {
  final LeaderboardConfig? existingConfig;
  final Function(LeaderboardConfig) onSave;

  const BestOfSeriesControl({super.key, this.existingConfig, required this.onSave});

  @override
  State<BestOfSeriesControl> createState() => _BestOfSeriesControlState();
}

class _BestOfSeriesControlState extends State<BestOfSeriesControl> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bestNController;
  late TextEditingController _appearancePointsController;
  late BestOfMetric _metric;
  late ScoringType _scoringType;
  late TiePolicy _tiePolicy;
  late Map<int, int> _positionPoints;

  @override
  void initState() {
    super.initState();
    final config = widget.existingConfig as BestOfSeriesConfig?;
    _nameController = TextEditingController(text: config?.name ?? 'Best Of Series');
    _bestNController = TextEditingController(text: (config?.bestN ?? 8).toString());
    _appearancePointsController = TextEditingController(text: (config?.appearancePoints ?? 0).toString());
    
    _metric = config?.metric ?? BestOfMetric.stableford;
    // Map existing 'position' metric to new ScoringType if needed, otherwise default
    if (_metric == BestOfMetric.position) {
       _metric = BestOfMetric.stableford; // Default to Stableford base
       _scoringType = ScoringType.position;
    } else {
       _scoringType = config?.scoringType ?? ScoringType.accumulative;
    }

    _tiePolicy = config?.tiePolicy ?? TiePolicy.countback;

    // Initialize points map
    if (config?.positionPointsMap != null && config!.positionPointsMap.isNotEmpty) {
      _positionPoints = Map.from(config.positionPointsMap);
    } else {
      _positionPoints = {1: 100, 2: 75, 3: 60, 4: 50, 5: 40, 6: 30, 7: 20, 8: 10};
    }

    _bestNController.addListener(() {
      setState(() {});
    });
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
    // Filter out 'position' from Metric values to hide it, since we use ScoringType now
    final displayMetrics = BestOfMetric.values.where((m) => m != BestOfMetric.position).toList();

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
          const BoxyArtSectionTitle(title: 'LEAGUE RULES'),
          BoxyArtFloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoxyArtFormField(
                  label: 'Count Best N Rounds',
                  controller: _bestNController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildEnumDropdown('Metric', displayMetrics, _metric, (v) => setState(() => _metric = v!)),
                const SizedBox(height: 16),
                _buildEnumDropdown('Scoring Type', ScoringType.values, _scoringType, (v) => setState(() => _scoringType = v!)),
                
                if (_scoringType == ScoringType.position) ...[
                   // Moved to Points Distribution
                ],

                _buildRuleDescription(),
              ],
            ),
          ),

          if (_scoringType == ScoringType.position) ...[
            const SizedBox(height: 24),
            const BoxyArtSectionTitle(title: 'POINTS DISTRIBUTION'),
            BoxyArtFloatingCard(
              child: Column(
                children: [
                   BoxyArtFormField(
                    label: 'Appearance Points (Bonus per event)',
                    controller: _appearancePointsController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  ..._positionPoints.entries.map((e) => _buildPointRow(e.key, e.value)),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: _addNextPosition,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('ADD NEXT POSITION', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],

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

  Widget _buildPointRow(int position, int points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_ordinal(position)} Place',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: points.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
          const SizedBox(width: 8),
          Text('pts', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.grey),
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
    final bestN = _bestNController.text;

    if (_scoringType == ScoringType.position) {
       goal = 'Highest Position Points (Best $bestN).';
       scoring = 'Sum of points from best $bestN finishes.';
       if (_metric == BestOfMetric.stableford) {
           goal += ' (Based on Stableford rank)';
       } else if (_metric == BestOfMetric.gross) {
           goal += ' (Based on Gross rank)';
       }
       result = 'Highest total points wins.';
    } else {
        // Accumulative
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

    // Tie policy text
    if (_tiePolicy == TiePolicy.countback) {
      tie = 'Countback on last card.';
    } else if (_tiePolicy == TiePolicy.shared) {
      tie = 'Position shared.';
    } else {
      tie = 'Playoff required.';
    }

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
           const SizedBox(height: 8),
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
    final RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    String result = val.replaceAllMapped(exp, (Match m) => ' ${m.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    final config = LeaderboardConfig.bestOfSeries(
      id: widget.existingConfig?.id ?? const Uuid().v4(),
      name: _nameController.text,
      bestN: int.parse(_bestNController.text),
      metric: _metric,
      scoringType: _scoringType,
      tiePolicy: TiePolicy.shared,
      positionPointsMap: _scoringType == ScoringType.position ? _positionPoints : {},
      appearancePoints: int.tryParse(_appearancePointsController.text) ?? 0,
    );
    
    widget.onSave(config);
  }
}
