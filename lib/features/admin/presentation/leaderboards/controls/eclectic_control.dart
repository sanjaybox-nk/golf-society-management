import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
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
          BoxyArtSectionTitle(title: 'ECLECTIC RULES'),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoxyArtDropdownField<EclecticMetric>(
                  label: 'Metric',
                  value: _metric,
                  items: EclecticMetric.values.map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(_formatEnum(v.name)),
                  )).toList(),
                  onChanged: (v) => setState(() => _metric = v!),
                ),
                
                if (_metric == EclecticMetric.strokes) ...[
                  const SizedBox(height: AppSpacing.x2l),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HANDICAP ALLOWANCE',
                        style: AppTypography.label.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark300,
                        ),
                      ),
                      Text(
                        '${_handicapPercentage.toInt()}%',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: AppTypography.weightExtraBold,
                          color: AppColors.lime500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  BoxyArtSlider(
                    value: _handicapPercentage,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${_handicapPercentage.toInt()}%',
                    onChanged: (v) => setState(() => _handicapPercentage = v),
                  ),
                  Text(
                    _handicapPercentage == 0 
                      ? 'Gross Score (No Handicap applied)' 
                      : 'Net Score (Gross - ${_handicapPercentage.toInt()}% of Final Handicap)',
                    style: AppTypography.label.copyWith(
                      color: AppColors.dark400,
                      fontSize: AppTypography.sizeCaption,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                _buildRuleDescription(),
              ],
            ),
          ),
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
