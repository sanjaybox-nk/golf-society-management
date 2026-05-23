import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
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
  final Map<String, quill.QuillController> _questionQuillControllers = {};
  final Map<String, List<TextEditingController>> _optionControllers = {};
  final Map<String, List<String>> _optionIds = {};
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
    for (final c in _questionQuillControllers.values) {
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

    // Initialize controllers and IDs for existing questions
    for (final q in _questions) {
      _questionQuillControllers[q.id] = _createQuillController(q.question);
      _optionControllers[q.id] = q.options.map((opt) => TextEditingController(text: opt)).toList();
      _optionIds[q.id] = q.options.map((_) => const Uuid().v4()).toList();
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
        final spacing = Theme.of(context).extension<AppSpacingTokens>();

        return HeadlessScaffold(
          title: widget.surveyId == null ? 'New survey' : 'Edit survey',
          topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
          subtitle: 'Configure society feedback',
          showBack: true, // [NEW] Enable back navigation
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
                        const BoxyArtSectionTitle(
                          title: 'General details',
                        ),
                        _buildBasicInfoSection(),
                        
                        const BoxyArtSectionTitle(
                          title: 'Questions',
                        ),
                        
                        ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          proxyDecorator: (child, index, animation) => Opacity(opacity: 0.8, child: child),
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final q = _questions.removeAt(oldIndex);
                              _questions.insert(newIndex, q);
                            });
                          },
                          children: _buildQuestionsList(spacing),
                        ),
                        
                        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BoxyArtButton(
                              title: 'Add question',
                              icon: Icons.add_rounded,
                              onTap: _addQuestion,
                            ),
                            BoxyArtButton(
                              title: 'Save survey',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoxyArtFormField(
            label: 'Survey title',
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
          const SizedBox(height: AppSpacing.lg),
          BoxyArtDatePickerField(
            label: 'Deadline',
            value: _deadline == null ? 'No deadline' : DateFormat('MMM d, yyyy ' 'at' ' h:mm a').format(_deadline!),
            onTap: _pickDeadline,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionsList(AppSpacingTokens? spacing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _questions.asMap().entries.map((entry) {
      final index = entry.key;
      final q = entry.value;

      return Padding(
        key: ValueKey(q.id),
        padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard),
        child: BoxyArtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_indicator_rounded, 
                          color: isDark ? AppColors.dark400 : AppColors.dark300,
                          size: AppShapes.iconSmall,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Question ${index + 1}', 
                        style: AppTypography.micro.copyWith(
                          fontWeight: AppTypography.weightHeavy,
                          color: isDark ? AppColors.dark300 : AppColors.dark400,
                          letterSpacing: AppTypography.lsLabel,
                        ),
                      ),
                    ],
                  ),
                  BoxyArtGlassIconButton(
                    icon: Icons.delete_outline_rounded, 
                    iconColor: AppColors.coral500, 
                    onPressed: () => _removeQuestion(index),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              BoxyArtRichEditor(
                label: 'Question prompt',
                controller: _questionQuillControllers[q.id]!,
                placeholder: 'What would you like to ask?',
                minHeight: 120,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Question type'.toUpperCase(), 
                style: AppTypography.label.copyWith(
                  fontWeight: AppTypography.weightHeavy, 
                  letterSpacing: AppTypography.lsLabel,
                  color: isDark ? AppColors.dark200 : AppColors.dark400,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildTypeSelector(index, q.type),
              if (q.type != SurveyQuestionType.text) ...[
                const SizedBox(height: AppSpacing.x2l),
                Text(
                  'Options'.toUpperCase(), 
                  style: AppTypography.label.copyWith(
                    fontWeight: AppTypography.weightHeavy, 
                    letterSpacing: AppTypography.lsLabel,
                    color: isDark ? AppColors.dark200 : AppColors.dark400,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildOptionsList(index, q),
                const SizedBox(height: AppSpacing.md),
                BoxyArtButton(
                  title: 'Add option',
                  onTap: () => _addOption(index),
                  isSmall: true,
                  isGhost: true,
                  icon: Icons.add_rounded,
                  textColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTypeSelector(int qIndex, SurveyQuestionType currentType) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dark700 : AppColors.dark50,
        borderRadius: AppShapes.pill,
        border: Border.all(color: isDark ? AppColors.dark500 : AppColors.dark200),
      ),
      child: Row(
        children: SurveyQuestionType.values.asMap().entries.map((entry) {
          final type = entry.value;
          final isSelected = type == currentType;

          return Expanded(
            child: GestureDetector(
              onTap: () => _updateQuestion(qIndex, _questions[qIndex].copyWith(type: type)),
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: AppShapes.pill,
                  boxShadow: null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      size: AppShapes.iconSmall,
                      color: isSelected ? theme.colorScheme.onPrimary : (isDark ? AppColors.dark300 : AppColors.dark600),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _getTypeLabel(type).split(' ').first.toUpperCase(), 
                      style: AppTypography.micro.copyWith(
                        fontWeight: AppTypography.weightHeavy,
                        color: isSelected ? theme.colorScheme.onPrimary : (isDark ? AppColors.dark200 : AppColors.dark800),
                        letterSpacing: AppTypography.lsLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getTypeIcon(SurveyQuestionType type) {
    switch (type) {
      case SurveyQuestionType.singleChoice: return Icons.radio_button_checked_rounded;
      case SurveyQuestionType.multipleChoice: return Icons.check_box_rounded;
      case SurveyQuestionType.text: return Icons.short_text_rounded;
    }
  }

  Widget _buildOptionsList(int qIndex, SurveyQuestion q) {
    final options = q.options;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final optionIds = _optionIds[q.id]!;

    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      proxyDecorator: (child, index, animation) => Opacity(opacity: 0.8, child: child),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          
          final newOptions = List<String>.from(q.options);
          final opt = newOptions.removeAt(oldIndex);
          newOptions.insert(newIndex, opt);
          _questions[qIndex] = _questions[qIndex].copyWith(options: newOptions);
          
          final controllers = _optionControllers[q.id]!;
          final ctrl = controllers.removeAt(oldIndex);
          controllers.insert(newIndex, ctrl);

          final ids = _optionIds[q.id]!;
          final id = ids.removeAt(oldIndex);
          ids.insert(newIndex, id);
        });
      },
      children: options.asMap().entries.map((entry) {
        final optIndex = entry.key;
        final optionId = optionIds[optIndex];

        return Padding(
          key: ValueKey('${q.id}_opt_$optionId'),
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: optIndex,
                child: Icon(
                  Icons.drag_indicator_rounded, 
                  color: isDark ? AppColors.dark400 : AppColors.dark300,
                  size: AppShapes.iconSmall,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: BoxyArtFormField(
                  label: 'Option ${optIndex + 1}',
                  controller: _optionControllers[q.id]![optIndex],
                  onChanged: (v) {
                    final newOptions = List<String>.from(_questions[qIndex].options);
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
      }).toList(),
    );
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
      _questionQuillControllers[newId] = quill.QuillController.basic();
      _optionControllers[newId] = [
        TextEditingController(text: 'Option 1'),
        TextEditingController(text: 'Option 2'),
      ];
      _optionIds[newId] = [
        const Uuid().v4(),
        const Uuid().v4(),
      ];
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      final qId = _questions[index].id;
      _questions.removeAt(index);
      _questionQuillControllers.remove(qId)?.dispose();
      _optionControllers.remove(qId)?.map((c) => c.dispose()).toList();
      _optionIds.remove(qId);
    });
  }

  void _updateQuestion(int index, SurveyQuestion newQ) => setState(() => _questions[index] = newQ);

  quill.QuillController _createQuillController(String content) {
    if (content.isEmpty) {
      return quill.QuillController.basic();
    }
    
    try {
      final json = jsonDecode(content);
      return quill.QuillController(
        document: quill.Document.fromJson(json),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // Fallback if not valid JSON
      final doc = quill.Document()..insert(0, content);
      return quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  void _addOption(int qIndex) {
    final q = _questions[qIndex];
    final newOptions = List<String>.from(q.options)..add('New option');
    _optionControllers[q.id]!.add(TextEditingController(text: 'New option'));
    _optionIds[q.id]!.add(const Uuid().v4());
    _updateQuestion(qIndex, q.copyWith(options: newOptions));
  }

  void _removeOption(int qIndex, int optIndex) {
    final q = _questions[qIndex];
    final newOptions = List<String>.from(q.options)..removeAt(optIndex);
    _optionControllers[q.id]!.removeAt(optIndex).dispose();
    _optionIds[q.id]!.removeAt(optIndex);
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

    // Update all questions from their quill controllers
    final updatedQuestions = _questions.map((q) {
      final updatedQuestionText = jsonEncode(_questionQuillControllers[q.id]!.document.toDelta().toJson());
      return q.copyWith(question: updatedQuestionText);
    }).toList();

    final repo = ref.read(surveysRepositoryProvider);
    final survey = Survey(
      id: widget.surveyId ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      deadline: _deadline,
      isPublished: _isPublished,
      questions: updatedQuestions,
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
