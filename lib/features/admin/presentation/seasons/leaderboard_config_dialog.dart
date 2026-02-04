import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/leaderboard_config.dart';

class LeaderboardConfigDialog extends StatefulWidget {
  final LeaderboardConfig? existingConfig;

  const LeaderboardConfigDialog({super.key, this.existingConfig});

  @override
  State<LeaderboardConfigDialog> createState() => _LeaderboardConfigDialogState();
}

class _LeaderboardConfigDialogState extends State<LeaderboardConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late LeaderboardType _selectedType;
  
  // OOM Fields
  late OOMSource _oomSource;
  late TextEditingController _appearancePointsController;
  // BestOf Fields
  late TextEditingController _bestNController;
  late BestOfMetric _bestOfMetric;
  late TiePolicy _tiePolicy;
  // Eclectic Fields
  late EclecticMetric _eclecticMetric;
  // Marker Fields
  late Set<MarkerType> _targetMarkers;

  @override
  void initState() {
    super.initState();
    final config = widget.existingConfig;
    
    _nameController = TextEditingController(text: config?.name ?? '');
    
    // Determine type from config or default
    if (config is OrderOfMeritConfig) {
      _selectedType = LeaderboardType.orderOfMerit;
    } else if (config is BestOfSeriesConfig) {
      _selectedType = LeaderboardType.bestOfSeries;
    } else if (config is EclecticConfig) {
      _selectedType = LeaderboardType.eclectic;
    } else if (config is MarkerCounterConfig) {
      _selectedType = LeaderboardType.markerCounter;
    } else {
      _selectedType = LeaderboardType.orderOfMerit;
    }

    // Initialize fields
    _oomSource = (config is OrderOfMeritConfig) ? config.source : OOMSource.position;
    _appearancePointsController = TextEditingController(
      text: (config is OrderOfMeritConfig ? config.appearancePoints : 0).toString()
    );
    
    _bestNController = TextEditingController(
      text: (config is BestOfSeriesConfig ? config.bestN : 8).toString()
    );
    _bestOfMetric = (config is BestOfSeriesConfig) ? config.metric : BestOfMetric.stableford;
    _tiePolicy = (config is BestOfSeriesConfig) ? config.tiePolicy : TiePolicy.countback;
    
    _eclecticMetric = (config is EclecticConfig) ? config.metric : EclecticMetric.strokes;
    
    _targetMarkers = (config is MarkerCounterConfig) ? config.targetTypes : {MarkerType.birdie};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _appearancePointsController.dispose();
    _bestNController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Container( // Constraint wrapper
        constraints: BoxConstraints(
          maxWidth: 500, // Reasonable max width for tablet/desktop
          maxHeight: MediaQuery.of(context).size.height * 0.9, // Avoid overflow
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONFIGURE LEADERBOARD',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  
                  // Common Fields
                  _buildTypeSelector(),
                  const SizedBox(height: 16),
                  BoxyArtFormField(
                    label: 'Leaderboard Name',
                    controller: _nameController,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),
                  
                  // Dynamic Fields
                  if (_selectedType == LeaderboardType.orderOfMerit) _buildOOMFields(),
                  if (_selectedType == LeaderboardType.bestOfSeries) _buildBestOfFields(),
                  if (_selectedType == LeaderboardType.eclectic) _buildEclecticFields(),
                  if (_selectedType == LeaderboardType.markerCounter) _buildMarkerFields(),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TYPE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<LeaderboardType>(
              value: _selectedType,
              isExpanded: true,
              dropdownColor: Colors.grey.shade900,
              style: const TextStyle(color: Colors.white),
              onChanged: widget.existingConfig != null ? null : (v) => setState(() => _selectedType = v!),
              items: LeaderboardType.values.map((t) => DropdownMenuItem(
                value: t,
                child: Text(_formatEnum(t.name)),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOOMFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'SCORING RULES', padding: EdgeInsets.zero),
        const SizedBox(height: 16),
        _buildEnumDropdown('Source', OOMSource.values, _oomSource, (v) => setState(() => _oomSource = v!)),
        const SizedBox(height: 16),
        BoxyArtFormField(
          label: 'Appearance Points (Bonus per event)',
          controller: _appearancePointsController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildBestOfFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'LEAGUE RULES', padding: EdgeInsets.zero),
        const SizedBox(height: 16),
        BoxyArtFormField(
          label: 'Best N Rounds (e.g. 6)',
          controller: _bestNController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildEnumDropdown('Metric', BestOfMetric.values, _bestOfMetric, (v) => setState(() => _bestOfMetric = v!)),
        const SizedBox(height: 16),
        _buildEnumDropdown('Tie Break', TiePolicy.values, _tiePolicy, (v) => setState(() => _tiePolicy = v!)),
      ],
    );
  }

  Widget _buildEclecticFields() {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'ECLECTIC RULES', padding: EdgeInsets.zero),
        const SizedBox(height: 16),
         _buildEnumDropdown('Metric', EclecticMetric.values, _eclecticMetric, (v) => setState(() => _eclecticMetric = v!)),
      ],
     );
  }

  Widget _buildMarkerFields() {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'TARGET EVENTS', padding: EdgeInsets.zero),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MarkerType.values.map((type) {
            final isSelected = _targetMarkers.contains(type);
            return FilterChip(
              label: Text(_formatEnum(type.name)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _targetMarkers.add(type);
                  } else {
                    _targetMarkers.remove(type);
                  }
                });
              },
              backgroundColor: Colors.white10,
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
            );
          }).toList(),
        ),
      ],
     );
  }



  Widget _buildEnumDropdown<T>(String label, List<T> values, T currentValue, Function(T?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
         Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: currentValue,
              isExpanded: true,
              dropdownColor: Colors.grey.shade900,
              style: const TextStyle(color: Colors.white),
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
    // Convert camelCase to Title Case (e.g., orderOfMerit -> Order Of Merit)
    final RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    String result = val.replaceAllMapped(exp, (Match m) => ' ${m.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    final id = widget.existingConfig?.id ?? const Uuid().v4();
    final name = _nameController.text;
    
    LeaderboardConfig config;
    
    switch (_selectedType) {
      case LeaderboardType.orderOfMerit:
        config = LeaderboardConfig.orderOfMerit(
          id: id,
          name: name,
          source: _oomSource,
          appearancePoints: int.parse(_appearancePointsController.text),
        );
        break;
      case LeaderboardType.bestOfSeries:
        config = LeaderboardConfig.bestOfSeries(
          id: id,
          name: name,
          bestN: int.parse(_bestNController.text),
          metric: _bestOfMetric,
          tiePolicy: _tiePolicy,
        );
        break;
      case LeaderboardType.eclectic:
        config = LeaderboardConfig.eclectic(
          id: id,
          name: name,
          metric: _eclecticMetric,
        );
        break;
      case LeaderboardType.markerCounter:
        config = LeaderboardConfig.markerCounter(
          id: id,
          name: name,
          targetTypes: _targetMarkers,
        );
        break;
    }
    
    Navigator.of(context).pop(config);
  }
}
