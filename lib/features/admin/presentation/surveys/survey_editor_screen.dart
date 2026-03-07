import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/survey.dart';
import 'package:golf_society/features/surveys/presentation/surveys_provider.dart';

class SurveyEditorScreen extends ConsumerStatefulWidget {
  final String? surveyId;

  const SurveyEditorScreen({super.key, this.surveyId});

  @override
  ConsumerState<SurveyEditorScreen> createState() => _SurveyEditorScreenState();
}

class _SurveyEditorScreenState extends ConsumerState<SurveyEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _deadline;
  bool _isPublished = false;
  List<SurveyQuestion> _questions = [];
  final Map<String, TextEditingController> _questionControllers = {};
  final Map<String, List<TextEditingController>> _optionControllers = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _questionControllers.values) {
      c.dispose();
    }
    for (final list in _optionControllers.values) {
      for (final c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _initialize(Survey? survey) {
    if (_isInitialized) return;
    if (survey != null) {
      _titleController.text = survey.title;
      _descriptionController.text = survey.description ?? '';
      _deadline = survey.deadline;
      _isPublished = survey.isPublished;
      _questions = List.from(survey.questions);
    } else {
      _questions = [
        SurveyQuestion(
          id: const Uuid().v4(),
          question: '',
          type: SurveyQuestionType.singleChoice,
          options: ['Option 1', 'Option 2'],
        ),
      ];
    }

    // Initialize controllers for existing questions
    for (final q in _questions) {
      _questionControllers[q.id] = TextEditingController(text: q.question);
      _optionControllers[q.id] = q.options.map((opt) => TextEditingController(text: opt)).toList();
    }

    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final surveyAsync = widget.surveyId != null 
        ? ref.watch(surveyProvider(widget.surveyId!))
        : const AsyncValue<Survey?>.data(null);

    return surveyAsync.when(
      data: (survey) {
        _initialize(survey);
        return HeadlessScaffold(
          title: widget.surveyId == null ? 'New Survey' : 'Edit Survey',
          subtitle: 'Configure society feedback',
          actions: const [
            SizedBox(width: AppSpacing.lg),
          ],
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInfoSection(),
                        const SizedBox(height: AppSpacing.x3l),
                        const BoxyArtSectionTitle(title: 'Questions'),
                        const SizedBox(height: AppSpacing.lg),
                        ..._buildQuestionsList(),
                        const SizedBox(height: AppSpacing.x2l),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BoxyArtButton(
                              title: 'Add Question',
                              icon: Icons.add_rounded,
                              onTap: _addQuestion,
                            ),
                            BoxyArtButton(
                              title: 'Save Survey',
                              isPrimary: true,
                              icon: Icons.check_circle_outline_rounded,
                              onTap: _saveSurvey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildBasicInfoSection() {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'General Details'),
          const SizedBox(height: AppSpacing.lg),
          BoxyArtFormField(
            label: 'Survey Title',
            controller: _titleController,
            hintText: 'e.g., Annual Trip Preference',
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          BoxyArtFormField(
            label: 'Description (Optional)',
            controller: _descriptionController,
            hintText: 'Provide context for members...',
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.x2l),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Deadline', style: TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeLabelStrong)),
                    const SizedBox(height: AppSpacing.sm),
                    InkWell(
                      onTap: _pickDeadline,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.dark600,
                          borderRadius: AppShapes.md,
                          border: Border.all(color: AppColors.dark500),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: AppShapes.iconSm, color: AppColors.textSecondary),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              _deadline == null ? 'No deadline' : DateFormat('MMM d, yyyy ' 'at' ' h:mm a').format(_deadline!),
                              style: TextStyle(color: _deadline == null ? AppColors.textSecondary : AppColors.pureWhite, fontSize: AppTypography.sizeLabelStrong),
                            ),
                            if (_deadline != null) ...[
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() => _deadline = null),
                                child: const Icon(Icons.cancel_rounded, size: AppShapes.iconSm, color: AppColors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x2l),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Published', style: TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeLabelStrong)),
                  const SizedBox(height: AppSpacing.xs),
                  Switch.adaptive(
                    value: _isPublished,
                    activeThumbColor: AppColors.lime500,
                    onChanged: (val) => setState(() => _isPublished = val),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionsList() {
    return _questions.asMap().entries.map((entry) {
      final index = entry.key;
      final q = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
        child: BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Q${index + 1}', style: const TextStyle(fontWeight: AppTypography.weightBlack, color: AppColors.lime500)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral500, size: AppShapes.iconMd),
                    onPressed: () => _removeQuestion(index),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              BoxyArtFormField(
                label: 'Question Prompt',
                controller: _questionControllers[q.id],
                onChanged: (v) => _updateQuestion(index, q.copyWith(question: v)),
                hintText: 'What would you like to ask?',
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('Question Type', style: TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeLabelStrong)),
              const SizedBox(height: AppSpacing.sm),
              _buildTypeSelector(index, q.type),
              if (q.type != SurveyQuestionType.text) ...[
                const SizedBox(height: AppSpacing.x2l),
                const Text('Options', style: TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeLabelStrong)),
                const SizedBox(height: AppSpacing.sm),
                ..._buildOptionsList(index, q),
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: () => _addOption(index),
                  icon: const Icon(Icons.add_rounded, size: AppShapes.iconSm, color: AppColors.lime500),
                  label: const Text('Add Option', style: TextStyle(color: AppColors.lime500, fontSize: AppTypography.sizeLabel)),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTypeSelector(int qIndex, SurveyQuestionType currentType) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SurveyQuestionType.values.map((type) {
          final isSelected = type == currentType;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(_getTypeLabel(type)),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  _updateQuestion(qIndex, _questions[qIndex].copyWith(type: type));
                }
              },
              selectedColor: AppColors.lime500.withValues(alpha: AppColors.opacityMedium),
              side: BorderSide(color: isSelected ? AppColors.lime500 : AppColors.dark500),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildOptionsList(int qIndex, SurveyQuestion q) {
    final options = q.options;
    return options.asMap().entries.map((entry) {
      final optIndex = entry.key;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: BoxyArtFormField(
                label: 'Option ${optIndex + 1}',
                controller: _optionControllers[q.id]![optIndex],
                onChanged: (v) {
                  final newOptions = List<String>.from(options);
                  newOptions[optIndex] = v;
                  _updateQuestion(qIndex, _questions[qIndex].copyWith(options: newOptions));
                },
                hintText: 'Enter option text',
              ),
            ),
            if (options.length > 2)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.textSecondary, size: AppShapes.iconMd),
                onPressed: () => _removeOption(qIndex, optIndex),
              ),
          ],
        ),
      );
    }).toList();
  }

  String _getTypeLabel(SurveyQuestionType type) {
    switch (type) {
      case SurveyQuestionType.singleChoice: return 'Single Choice';
      case SurveyQuestionType.multipleChoice: return 'Multiple Choice';
      case SurveyQuestionType.text: return 'Text Response';
    }
  }

  void _addQuestion() {
    setState(() {
      final newId = const Uuid().v4();
      final newQ = SurveyQuestion(
        id: newId,
        question: '',
        type: SurveyQuestionType.singleChoice,
        options: ['Option 1', 'Option 2'],
      );
      _questions.add(newQ);
      _questionControllers[newId] = TextEditingController();
      _optionControllers[newId] = [
        TextEditingController(text: 'Option 1'),
        TextEditingController(text: 'Option 2'),
      ];
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      final qId = _questions[index].id;
      _questions.removeAt(index);
      _questionControllers.remove(qId)?.dispose();
      _optionControllers.remove(qId)?.map((c) => c.dispose()).toList();
    });
  }

  void _updateQuestion(int index, SurveyQuestion newQ) => setState(() => _questions[index] = newQ);

  void _addOption(int qIndex) {
    final q = _questions[qIndex];
    final newOptions = List<String>.from(q.options)..add('New Option');
    _optionControllers[q.id]!.add(TextEditingController(text: 'New Option'));
    _updateQuestion(qIndex, q.copyWith(options: newOptions));
  }

  void _removeOption(int qIndex, int optIndex) {
    final q = _questions[qIndex];
    final newOptions = List<String>.from(q.options)..removeAt(optIndex);
    _optionControllers[q.id]!.removeAt(optIndex).dispose();
    _updateQuestion(qIndex, q.copyWith(options: newOptions));
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: _deadline != null ? TimeOfDay.fromDateTime(_deadline!) : const TimeOfDay(hour: 17, minute: 0),
      );

      if (time != null) {
        setState(() {
          _deadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveSurvey() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(surveysRepositoryProvider);
    final survey = Survey(
      id: widget.surveyId ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      deadline: _deadline,
      isPublished: _isPublished,
      questions: _questions,
    );

    try {
      if (widget.surveyId == null) {
        await repo.addSurvey(survey);
      } else {
        await repo.updateSurvey(survey);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
