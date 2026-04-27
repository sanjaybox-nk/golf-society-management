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
  bool hasMatchPlayOverlay = false;
  
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
    
    if (c != null) {
      hasMatchPlayOverlay = c.rules.hasMatchPlayOverlay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: BoxyArtFormColumn(
        children: [
          // ── IDENTITY ──────────────────────────────────────────
          BoxyArtCard(
            child: ModernTextField(
              label: widget.isTemplate ? 'Template Name' : 'Game Name (Custom)',
              initialValue: name,
              onChanged: (val) => name = val,
              hintText: widget.isTemplate 
                  ? 'e.g. Standard Stableford'
                  : 'e.g. Memorial Trophy',
              validator: (val) => (widget.isTemplate && (val == null || val.isEmpty)) ? 'Please enter a name' : null,
              icon: Icons.edit_note_rounded,
            ),
          ),

          // ── SPECIFIC FIELDS (IMPLEMENTATIONS) ─────────────────
          buildSpecificFields(context),

          BoxyArtButton(
            title: widget.isTemplate
              ? (widget.competition == null ? 'Create template' : 'Save template')
              : (widget.competition == null ? 'Create competition' : 'Save changes'),
            onTap: _isSaving ? null : _save,
            isLoading: _isSaving,
            fullWidth: true,
            backgroundColor: Theme.of(context).primaryColor,
            textColor: AppColors.pureWhite,
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
    String label = 'Handicap allowance',
    String hint = "Fraction of each player's course handicap used in scoring.",
    bool disabled = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (allowance * 100).round();

    return BoxyArtFormColumn(
      spacing: AppSpacing.sm,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.micro.copyWith(
                fontWeight: AppTypography.weightBold,
                color: isDark ? AppColors.dark200 : AppColors.dark400,
                letterSpacing: 1.0,
              ),
            ),
            BoxyArtPill.format(
              label: pct == 0 ? 'None' : '$pct%',
              color: isDark ? AppColors.dark150 : AppColors.dark600,
            ),
          ],
        ),
        AbsorbPointer(
          absorbing: disabled,
          child: Opacity(
            opacity: disabled ? 0.3 : 1.0,
            child: BoxyArtSlider(
              value: allowance,
              divisions: 20,
              label: '$pct%',
              isNeutral: true,
              onChanged: onChanged,
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxyArtFormColumn(
      spacing: AppSpacing.sm,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.micro.copyWith(
                fontWeight: AppTypography.weightBold,
                color: isDark ? AppColors.dark200 : AppColors.dark400,
                letterSpacing: 1.0,
              ),
            ),
            BoxyArtPill.format(
              label: valueLabel,
              color: isDark ? AppColors.dark150 : AppColors.dark600,
            ),
          ],
        ),
        BoxyArtSlider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          isNeutral: true,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Standardized monochromatic minimalist metadata tip.
  Widget buildInfoBubble(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.micro.copyWith(
          color: isDark ? AppColors.dark200 : AppColors.dark400,
          height: 1.4,
          fontWeight: AppTypography.weightRegular,
        ),
      ),
    );
  }

  /// Tinted info card with a list of (label, description) rows.
  Widget buildInfoCard(List<(String, String)> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacityLow),
        borderRadius: AppShapes.md,
      ),
      child: BoxyArtFormColumn(
        spacing: AppSpacing.sm,
        children: rows.map((r) => buildInfoRow(r.$1, r.$2)).toList(),
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
            label.toUpperCase(),
            style: AppTypography.micro.copyWith(
              fontWeight: AppTypography.weightBold,
              color: theme.colorScheme.primary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.label.copyWith(
              height: 1.3,
              fontWeight: isBold ? AppTypography.weightBold : AppTypography.weightRegular,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }
  
  /// Standardised Match Play overlay toggle.
  Widget buildOverlaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'GAME FEATURES'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: BoxyArtSwitchField(
            label: 'Match Play Overlay',
            subtitle: 'Adds a side-by-side "Match Result" to the leaderboard.',
            value: hasMatchPlayOverlay,
            onChanged: (val) => setState(() => hasMatchPlayOverlay = val),
          ),
        ),
      ],
    );
  }
}

