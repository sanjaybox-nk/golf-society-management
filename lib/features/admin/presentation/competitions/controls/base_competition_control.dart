import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../../competitions/presentation/competitions_provider.dart';

abstract class BaseCompetitionControl extends ConsumerStatefulWidget {
  final Competition? competition;
  final String? competitionId;
  final VoidCallback? onSaved;
  final bool isTemplate;

  const BaseCompetitionControl({
    super.key,
    this.competition,
    this.competitionId,
    this.onSaved,
    this.isTemplate = false,
  });
}

abstract class BaseCompetitionControlState<T extends BaseCompetitionControl> extends ConsumerState<T> {
  final formKey = GlobalKey<FormState>();

  // Common Fields
  late DateTime startDate;
  late DateTime endDate;
  String? selectedSeasonId;
  String name = '';
  bool _isSaving = false;
  
  // To be implemented by subclasses
  CompetitionFormat get format;
  Widget buildSpecificFields(BuildContext context);
  CompetitionRules buildRules();
  Future<void> onBeforeSave() async {} // Optional hook for subclasses

  @override
  void initState() {
    super.initState();
    // Initialize defaults or from existing competition
    final c = widget.competition;
    if (c != null) {
      name = c.name ?? c.rules.gameName;
      startDate = c.startDate;
      endDate = c.endDate;
    } else {
      startDate = DateTime.now();
      endDate = DateTime.now().add(const Duration(days: 1));
      // For new ones, we can use the format's default name
      name = CompetitionRules(format: format).gameName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoxyArtCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernTextField(
                  label: widget.isTemplate ? 'Template Name' : 'Game Name (Custom)',
                  initialValue: name,
                  onChanged: (val) => name = val,
                  hintText: widget.isTemplate 
                      ? 'e.g. Standard Stableford'
                      : 'e.g. Memorial Trophy',
                  validator: (val) => (widget.isTemplate && (val == null || val.isEmpty)) ? 'Please enter a name' : null,
                  icon: Icons.edit_note_rounded,
                ),
                const SizedBox(height: 24),
                buildSpecificFields(context),
              ],
            ),
          ),
          const SizedBox(height: 24),
          BoxyArtButton(
            title: widget.isTemplate
              ? (widget.competition == null ? 'CREATE TEMPLATE' : 'SAVE TEMPLATE')
              : (widget.competition == null ? 'CREATE COMPETITION' : 'SAVE CHANGES'),
            onTap: _isSaving ? null : _save,
            isLoading: _isSaving,
            fullWidth: true,
            backgroundColor: Theme.of(context).primaryColor,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }


  Future<void> _save() async {
    if (formKey.currentState!.validate()) {
       setState(() => _isSaving = true);
       await onBeforeSave();
       final rules = buildRules();
       
       final existingComp = widget.competition;
       final newComp = Competition(
        id: existingComp?.id ?? widget.competitionId ?? const Uuid().v4(),
        name: name,
        templateId: existingComp?.templateId, // Preserve template link
        type: widget.isTemplate ? CompetitionType.game : CompetitionType.event,
        status: CompetitionStatus.draft,
        rules: rules,
        startDate: widget.isTemplate ? DateTime(2099) : startDate, // Dummy for template
        endDate: widget.isTemplate ? DateTime(2099) : endDate,
        publishSettings: {},
        isDirty: true,
        // If it's an event competition (not a template), we increment the version to flag it as customized
        computeVersion: widget.isTemplate ? 0 : (existingComp?.computeVersion ?? 0) + 1,
      );
       String? createdId;
       
       try {
        final repo = ref.read(competitionsRepositoryProvider);
        
        debugPrint('🎮 Saving competition: ID=${newComp.id}, Name=${newComp.name}, Ver=${newComp.computeVersion}, Allowance=${newComp.rules.handicapAllowance}');
        
        if (widget.competition == null) {
          debugPrint('  → Creating NEW competition');
          if (widget.isTemplate) {
            createdId = await repo.addTemplate(newComp);
          } else {
            createdId = await repo.addCompetition(newComp);
          }
        } else {
          debugPrint('  → Updating EXISTING competition');
          if (widget.isTemplate) {
            await repo.updateTemplate(newComp);
          } else {
            await repo.updateCompetition(newComp);
          }
          createdId = newComp.id;
        }
        
        debugPrint('  ✅ Save complete! ID=$createdId');
        
        // Invalidate the cache so fresh data is loaded next time
        ref.invalidate(competitionDetailProvider(createdId));
        
        if (mounted) {
           ScaffoldMessenger.of(context).clearSnackBars();
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               key: UniqueKey(), // Resolve Hero tag duplication
               content: Text(widget.isTemplate ? "Template saved" : "Competition saved"),
               duration: const Duration(seconds: 2),
             ),
           );
           context.pop(createdId); 
        }
      } catch (e) {
        if (mounted) {
           setState(() => _isSaving = false);
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving: $e")));
        }
      }
    }
  }

  // ─────────────────────────────────────────────
  // SHARED HELPERS — available to all subclasses
  // ─────────────────────────────────────────────

  /// Standardised handicap allowance slider (0–100%).
  Widget buildAllowanceSlider(
    double allowance,
    ValueChanged<double> onChanged, {
    String label = 'HANDICAP ALLOWANCE',
    String hint = "Fraction of each player's course handicap used in scoring.",
    bool disabled = false,
  }) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (allowance * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pct == 0 ? 'None' : '$pct%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AbsorbPointer(
          absorbing: disabled,
          child: Opacity(
            opacity: disabled ? 0.4 : 1.0,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: primary,
                inactiveTrackColor: primary.withValues(alpha: 0.15),
                thumbColor: primary,
                overlayColor: primary.withValues(alpha: 0.12),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                valueIndicatorColor: primary,
                valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              child: Slider(
                value: allowance.clamp(0.0, 1.0),
                min: 0,
                max: 1.0,
                divisions: 20,
                label: '$pct%',
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        Row(
          children: [
            Text('0%', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('100%', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
        if (hint.isNotEmpty) buildInfoBubble(hint),
      ],
    );
  }

  /// Handicap cap slider (0 = no cap, 1–54 = cap value).
  Widget buildCapSlider(int cap, ValueChanged<int> onChanged) {
    return buildSliderField(
      label: 'Handicap Cap',
      valueLabel: cap == 0 ? 'None' : '$cap',
      value: cap.toDouble(),
      min: 0,
      max: 54,
      divisions: 54,
      onChanged: (v) => onChanged(v.round()),
    );
  }

  /// Generic labelled slider with a value badge.
  Widget buildSliderField({
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                valueLabel,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: primaryColor),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: primaryColor,
            inactiveTrackColor: primaryColor.withValues(alpha: 0.15),
            thumbColor: primaryColor,
            overlayColor: primaryColor.withValues(alpha: 0.12),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(value: value, min: min, max: max, divisions: divisions, onChanged: onChanged),
        ),
      ],
    );
  }

  /// Italic help text displayed beneath a field.
  Widget buildInfoBubble(String text) => Padding(
    padding: const EdgeInsets.only(top: 6, left: 4, bottom: 2),
    child: Text(
      text,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.75),
        fontSize: 11.5,
        fontStyle: FontStyle.italic,
        height: 1.4,
      ),
    ),
  );

  /// Tinted info card with a list of (label, description) rows.
  Widget buildInfoCard(List<(String, String)> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows.expand((r) => [
          buildInfoRow(r.$1, r.$2),
          if (r != rows.last) const SizedBox(height: 8),
        ]).toList(),
      ),
    );
  }

  /// Single label + description row inside an info card.
  Widget buildInfoRow(String label, String value, {bool isBold = false}) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.primary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }
}

