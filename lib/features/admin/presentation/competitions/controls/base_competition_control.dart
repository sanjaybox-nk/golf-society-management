import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import '../../../../../models/competition.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
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

  @override
  void initState() {
    super.initState();
    // Initialize defaults or from existing competition
    final c = widget.competition;
    if (c != null) {
      name = c.name ?? '';
      startDate = c.startDate;
      endDate = c.endDate;
    } else {
      startDate = DateTime.now();
      endDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Common Header Inputs
          // Dates removed per user request (handled by Event or defaults)
          
          // Specific Fields
          BoxyArtFormField(
            label: 'COMPETITION NAME',
            initialValue: name,
            onChanged: (val) => name = val,
            hintText: 'e.g. Monthly Medal, Society Cup...',
            validator: (val) => (val == null || val.isEmpty) ? 'Please enter a name' : null,
          ),
          const SizedBox(height: 16),
          
          buildSpecificFields(context),
          
          const SizedBox(height: 40),
          // Save Button could also be common or driven by parent
          Center(
             child: BoxyArtButton(
               title: widget.competition == null ? "CREATE COMPETITION" : "SAVE CHANGES",
               isLoading: _isSaving,
               onTap: _isSaving ? null : _save,
             ),
          ),
        ],
      ),
    );
  }


  Future<void> _save() async {
    if (formKey.currentState!.validate()) {
       setState(() => _isSaving = true);
       final rules = buildRules();
       
       final newComp = Competition(
        id: widget.competitionId ?? const Uuid().v4(),
        name: name,
        type: widget.isTemplate ? CompetitionType.game : CompetitionType.event,
        status: CompetitionStatus.draft,
        rules: rules,
        startDate: widget.isTemplate ? DateTime(2099) : startDate, // Dummy for template
        endDate: widget.isTemplate ? DateTime(2099) : endDate,
        publishSettings: {},
        isDirty: true,
      );
       String? createdId;
       
       try {
        final repo = ref.read(competitionsRepositoryProvider);
        if (widget.competition == null) {
          if (widget.isTemplate) {
            createdId = await repo.addTemplate(newComp);
          } else {
            createdId = await repo.addCompetition(newComp);
          }
        } else {
          if (widget.isTemplate) {
            await repo.updateTemplate(newComp);
          } else {
            await repo.updateCompetition(newComp);
          }
          createdId = newComp.id;
        }
        
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
}
