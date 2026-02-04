import 'package:flutter/material.dart';
import '../../../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../../../models/leaderboard_config.dart';
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
          const BoxyArtSectionTitle(title: 'SCORING RULES'),
          BoxyArtFloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnumDropdown('Metric', OOMRankingBasis.values, _metric, (v) => setState(() => _metric = v!)),
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
