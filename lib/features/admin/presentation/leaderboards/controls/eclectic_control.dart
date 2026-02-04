import 'package:flutter/material.dart';
import '../../../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../../../models/leaderboard_config.dart';
import 'package:uuid/uuid.dart';

class EclecticControl extends StatefulWidget {
  final LeaderboardConfig? existingConfig;
  final Function(LeaderboardConfig) onSave;

  const EclecticControl({super.key, this.existingConfig, required this.onSave});

  @override
  State<EclecticControl> createState() => _EclecticControlState();
}

class _EclecticControlState extends State<EclecticControl> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late EclecticMetric _metric;
  double _handicapPercentage = 0;

  @override
  void initState() {
    super.initState();
    final config = widget.existingConfig as EclecticConfig?;
    _nameController = TextEditingController(text: config?.name ?? 'Eclectic');
    _metric = config?.metric ?? EclecticMetric.strokes;
    _handicapPercentage = (config?.handicapPercentage ?? 0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoxyArtSectionTitle(title: 'LEADERBOARD DETAILS'),
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
          BoxyArtSectionTitle(title: 'ECLECTIC RULES'),
          BoxyArtFloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnumDropdown('Metric', EclecticMetric.values, _metric, (v) => setState(() => _metric = v!)),
                
                if (_metric == EclecticMetric.strokes) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HANDICAP ALLOWANCE',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        '${_handicapPercentage.toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _handicapPercentage,
                    min: 0,
                    max: 100,
                    divisions: 20, // 5% increments? 20 divisions = 5%. 4 divisions = 25%.
                    // Let's typically do 0, 25, 50, 75, 85, 95, 100...
                    // Standard divisions:
                    // 0, 5, 10 ... 100 (20 steps)
                    label: '${_handicapPercentage.toInt()}%',
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (v) => setState(() => _handicapPercentage = v),
                  ),
                  Text(
                    _handicapPercentage == 0 
                      ? 'Gross Score (No Handicap applied)' 
                      : 'Net Score (Gross - ${_handicapPercentage.toInt()}% of Final Handicap)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],

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
    final RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    String result = val.replaceAllMapped(exp, (Match m) => ' ${m.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
  }

  Widget _buildRuleDescription() {
    String goal = '';
    String scoring = '';
    String result = '';

    if (_metric == EclecticMetric.strokes) {
      if (_handicapPercentage > 0) {
         goal = 'Lowest Net Composite Score.';
         scoring = 'Best Gross holes - ${_handicapPercentage.toInt()}% Handicap.';
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
    
    final config = LeaderboardConfig.eclectic(
      id: widget.existingConfig?.id ?? const Uuid().v4(),
      name: _nameController.text,
      metric: _metric,
      handicapPercentage: _handicapPercentage.toInt(),
    );
    
    widget.onSave(config);
  }
}
