import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/survey.dart';
import 'surveys_provider.dart';
import 'package:uuid/uuid.dart';

class SurveyFormScreen extends ConsumerStatefulWidget {
  final Survey? existingSurvey;

  const SurveyFormScreen({super.key, this.existingSurvey});

  @override
  ConsumerState<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends ConsumerState<SurveyFormScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<_QuestionController> _questionControllers = [];
  bool _isPublished = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingSurvey != null) {
      _titleController.text = widget.existingSurvey!.title;
      _descriptionController.text = widget.existingSurvey!.description ?? '';
      _isPublished = widget.existingSurvey!.isPublished;
      for (final q in widget.existingSurvey!.questions) {
        _questionControllers.add(_QuestionController.fromQuestion(q));
      }
    } else {
      _questionControllers.add(_QuestionController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final q in _questionControllers) {
      q.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Survey title is required.')));
      return;
    }

    setState(() => _isSaving = true);

    final survey = Survey(
      id: widget.existingSurvey?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      createdAt: widget.existingSurvey?.createdAt ?? DateTime.now(),
      isPublished: _isPublished,
      questions: _questionControllers.map((c) => c.toQuestion()).toList(),
      responses: widget.existingSurvey?.responses ?? {},
    );

    if (widget.existingSurvey != null) {
      ref.read(surveysProvider.notifier).updateSurvey(survey);
    } else {
      ref.read(surveysProvider.notifier).addSurvey(survey);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.existingSurvey != null ? 'Survey updated' : 'Survey created'),
        behavior: SnackBarBehavior.floating,
        shape: AppShapes.pillShape,
        backgroundColor: AppColors.lime600,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return HeadlessScaffold(
      title: widget.existingSurvey == null ? 'Create Survey' : 'Edit Survey',
      useScaffold: true,
      showBack: true,
      actions: [
        if (_isSaving)
          const Center(child: Padding(padding: EdgeInsets.only(right: 20), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
        else
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BoxyArtGlassIconButton(
              icon: Icons.check_rounded,
              onPressed: _save,
              tooltip: 'Save Survey',
            ),
          ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'General Information'),
              const SizedBox(height: AppTheme.sectionSpacing),
              BoxyArtCard(
                child: Column(
                  children: [
                    BoxyArtInputField(
                      label: 'Survey Title',
                      controller: _titleController,
                      hint: 'e.g., Seasonal Feedback',
                    ),
                    const SizedBox(height: 16),
                    BoxyArtInputField(
                      label: 'Description',
                      controller: _descriptionController,
                      hint: 'Optional context for members...',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.cardSpacing),
              
              const BoxyArtSectionTitle(title: 'Visibility'),
              const SizedBox(height: AppTheme.sectionSpacing),
              BoxyArtCard(
                padding: const EdgeInsets.all(8),
                child: BoxyArtSwitchField(
                  label: 'Published (Visible to Members)',
                  value: _isPublished,
                  onChanged: (val) => setState(() => _isPublished = val),
                ),
              ),
              const SizedBox(height: AppTheme.cardSpacing),

              const BoxyArtSectionTitle(title: 'Questions'),
              const SizedBox(height: AppTheme.sectionSpacing),
              ..._questionControllers.asMap().entries.map((entry) {
                return _QuestionEditor(
                  controller: entry.value,
                  onRemove: _questionControllers.length > 1 
                      ? () => setState(() => _questionControllers.removeAt(entry.key))
                      : null,
                );
              }),
              const SizedBox(height: 12),
              BoxyArtButton(
                title: 'ADD QUESTION',
                onTap: () => setState(() => _questionControllers.add(_QuestionController())),
                isGhost: true,
                icon: Icons.add_rounded,
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

class _QuestionController {
  final String id;
  final TextEditingController questionController;
  SurveyQuestionType type;
  final List<TextEditingController> optionControllers;
  bool isRequired;

  _QuestionController({
    String? id,
    String? question,
    this.type = SurveyQuestionType.singleChoice,
    List<String>? options,
    this.isRequired = true,
  })  : id = id ?? const Uuid().v4(),
        questionController = TextEditingController(text: question),
        optionControllers = (options ?? ['Option 1', 'Option 2'])
            .map((o) => TextEditingController(text: o))
            .toList();

  factory _QuestionController.fromQuestion(SurveyQuestion q) {
    return _QuestionController(
      id: q.id,
      question: q.question,
      type: q.type,
      options: q.options,
      isRequired: q.isRequired,
    );
  }

  SurveyQuestion toQuestion() {
    return SurveyQuestion(
      id: id,
      question: questionController.text.trim(),
      type: type,
      options: type == SurveyQuestionType.text ? [] : optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
      isRequired: isRequired,
    );
  }

  void dispose() {
    questionController.dispose();
    for (final c in optionControllers) {
      c.dispose();
    }
  }
}

class _QuestionEditor extends StatefulWidget {
  final _QuestionController controller;
  final VoidCallback? onRemove;

  const _QuestionEditor({required this.controller, this.onRemove});

  @override
  State<_QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<_QuestionEditor> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question Details',
                    style: AppTypography.label.copyWith(color: AppColors.lime500),
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            BoxyArtInputField(
              label: 'The Question',
              controller: widget.controller.questionController,
              hint: 'e.g., What is your favorite course?',
            ),
            const SizedBox(height: 16),
            const Text('Question Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.dark150)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeButton('Choice', SurveyQuestionType.singleChoice, Icons.radio_button_checked_rounded),
                const SizedBox(width: 8),
                _buildTypeButton('Multi', SurveyQuestionType.multipleChoice, Icons.check_box_rounded),
                const SizedBox(width: 8),
                _buildTypeButton('Text', SurveyQuestionType.text, Icons.text_fields_rounded),
              ],
            ),
            if (widget.controller.type != SurveyQuestionType.text) ...[
              const SizedBox(height: 16),
              const Text('Options', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.dark150)),
              const SizedBox(height: 8),
              ...widget.controller.optionControllers.asMap().entries.map((entry) {
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 8),
                   child: Row(
                     children: [
                       Expanded(
                         child: BoxyArtInputField(
                           label: 'Option ${entry.key + 1}',
                           controller: entry.value,
                           hint: 'Enter option text...',
                         ),
                       ),
                       if (widget.controller.optionControllers.length > 2)
                         IconButton(
                           icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: Colors.redAccent),
                           onPressed: () => setState(() => widget.controller.optionControllers.removeAt(entry.key)),
                         ),
                     ],
                   ),
                 );
              }),
              BoxyArtButton(
                title: 'Add Option',
                onTap: () => setState(() => widget.controller.optionControllers.add(TextEditingController())),
                isGhost: true,
                icon: Icons.add_rounded,
              ),
            ],
            const SizedBox(height: 8),
            BoxyArtSwitchField(
              label: 'Required',
              value: widget.controller.isRequired,
              onChanged: (val) => setState(() => widget.controller.isRequired = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, SurveyQuestionType type, IconData icon) {
    final isSelected = widget.controller.type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => widget.controller.type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lime500.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(color: isSelected ? AppColors.lime500 : AppColors.dark400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? AppColors.lime500 : AppColors.dark150),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? AppColors.lime500 : AppColors.dark150)),
            ],
          ),
        ),
      ),
    );
  }
}
