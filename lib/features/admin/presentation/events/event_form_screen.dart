import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import '../../../../core/shared_ui/headless_scaffold.dart';
import '../../../events/presentation/tabs/event_user_details_tab.dart';


import '../../../events/presentation/events_provider.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/season.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/services/storage_service.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../models/competition.dart'; // Added
import '../../../competitions/presentation/competitions_provider.dart'; // Added
import '../../../../models/course.dart';
import '../../../courses/presentation/courses_provider.dart';


class EventFormScreen extends ConsumerStatefulWidget {
  final GolfEvent? event; // Null = New Event
  final String? eventId; // Used if event object is missing (e.g. deep link)

  const EventFormScreen({super.key, this.event, this.eventId});

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class NoteItemController {
  final TextEditingController titleController;
  final QuillController quillController;
  String? imageUrl;

  NoteItemController({String? title, String? content, this.imageUrl})
      : titleController = TextEditingController(text: title),
        quillController = QuillController(
          document: content != null && content.isNotEmpty
              ? Document.fromJson(jsonDecode(content))
              : Document(),
          selection: const TextSelection.collapsed(offset: 0),
        );

  void dispose() {
    titleController.dispose();
    quillController.dispose();
  }
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  // New Controllers
  late TextEditingController _courseNameController;
  late TextEditingController _courseDetailsController;
  late TextEditingController _dressCodeController;
  late TextEditingController _buggiesController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _memberCostController;
  late TextEditingController _guestCostController;
  late TextEditingController _breakfastCostController;
  late TextEditingController _lunchCostController;
  late TextEditingController _dinnerCostController;
  late TextEditingController _dinnerLocationController;
  late TextEditingController _buggyCostController;
  late TextEditingController _intervalController;
  
  late List<NoteItemController> _notesControllers = [];
  late List<TextEditingController> _facilitiesControllers = [];
  
  // Default values
  late DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  late TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  late TimeOfDay _registrationTime = const TimeOfDay(hour: 8, minute: 30);
  
  DateTime? _deadlineDate;
  TimeOfDay? _deadlineTime;
  
  bool _hasBreakfast = false;
  bool _hasLunch = false;
  bool _hasDinner = true;
  bool _showRegistrationButton = true;
  bool _isSaving = false;
  String? _selectedSeasonId;
  
  // New Event Config
  bool _isMultiDay = false;
  DateTime? _endDate;
  String? _selectedTemplateId;
  String? _initialTemplateId;
  bool _isCustomized = false;
  
  // Track the event being edited (either passed or fetched)
  GolfEvent? _editingEvent;
  Competition? _eventCompetition;
  String? _selectedCourseId;
  String? _secondaryTemplateId;
  Competition? _secondaryCompetition;
  bool _isSecondaryCustomized = false;
  bool _isInvitational = false;

  // Hole Configuration
  late List<TextEditingController> _holeParsControllers;
  late List<TextEditingController> _holeSIsControllers;
  late List<FocusNode> _holeSIsFocusNodes;
  late TextEditingController _slopeController;
  late TextEditingController _ratingController;
  late List<TextEditingController> _holeYardagesControllers;
  late FocusNode _slopeFocusNode;
  late FocusNode _ratingFocusNode;
  String? _selectedTeeName;
  List<TeeConfig> _availableTees = [];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _populateForm(widget.event!);
      // Fetch competition for state restoration
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCompetition(widget.event!.id));
    } else if (widget.eventId != null && widget.eventId != 'new') {
      _isLoading = true;
      // Fetch event after build
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchEvent());
       // Initialize with defaults temporarily to avoid late initialization errors
       _initializeDefaults();
    } else {
      _initializeDefaults();
    }
  }

  void _initializeDefaults() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _courseNameController = TextEditingController();
    _courseDetailsController = TextEditingController();
    _dressCodeController = TextEditingController();
    _buggiesController = TextEditingController();
    _maxParticipantsController = TextEditingController();
    _memberCostController = TextEditingController();
    _guestCostController = TextEditingController();
    _breakfastCostController = TextEditingController();
    _lunchCostController = TextEditingController();
    _dinnerCostController = TextEditingController();
    _dinnerLocationController = TextEditingController();
    _buggyCostController = TextEditingController();
    _intervalController = TextEditingController(text: '10');
    _facilitiesControllers = [TextEditingController()];
    
    _holeParsControllers = List.generate(18, (i) => TextEditingController(text: '4'));
    _holeSIsControllers = List.generate(18, (i) => TextEditingController(text: (i + 1).toString()));
    _holeYardagesControllers = List.generate(18, (i) => TextEditingController(text: '0'));
    _holeSIsFocusNodes = List.generate(18, (i) => FocusNode());
    _slopeController = TextEditingController(text: '113');
    _ratingController = TextEditingController(text: '72.0');
    _slopeFocusNode = FocusNode();
    _ratingFocusNode = FocusNode();
    _selectedTeeName = null;
    _availableTees = [];
    
    // Set default selected season if available in provider (handled in build via listen)
  }

  Future<void> _fetchEvent() async {
    try {
      final repo = ref.read(eventsRepositoryProvider);
      final event = await repo.getEvent(widget.eventId!);
      
      if (mounted && event != null) {
        setState(() => _populateForm(event));
        await _fetchCompetition(event.id);
        if (mounted) setState(() => _isLoading = false);
      } else if (mounted) {
         setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event not found')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading event: $e')));
      }
    }
  }

  Future<void> _fetchCompetition(String eventId) async {
    try {
      final compRepo = ref.read(competitionsRepositoryProvider);
      final comp = await compRepo.getCompetition(eventId);
      if (mounted && comp != null) {
        setState(() {
          _eventCompetition = comp;
          _selectedTemplateId = comp.templateId;
          _initialTemplateId = comp.templateId;
          // Detection: if computeVersion > 0, it means it was edited in the builder
          _isCustomized = comp.computeVersion != null && comp.computeVersion! > 0;
        });
        _fetchSecondaryCompetition(eventId);
      }
    } catch (e) {
      debugPrint('Error fetching competition: $e');
    }
  }

  Future<void> _fetchSecondaryCompetition(String eventId) async {
    try {
      final compRepo = ref.read(competitionsRepositoryProvider);
      final comp = await compRepo.getCompetition('${eventId}_secondary');
      if (mounted && comp != null) {
        setState(() {
          _secondaryCompetition = comp;
          _isSecondaryCustomized = comp.computeVersion != null && comp.computeVersion! > 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching secondary competition: $e');
    }
  }

  void _populateForm(GolfEvent e) {
    _editingEvent = e;
    _selectedCourseId = e.courseId;
    _titleController = TextEditingController(text: e.title);
    _descriptionController = TextEditingController(text: e.description);
    
    _courseNameController = TextEditingController(text: e.courseName);
    _courseDetailsController = TextEditingController(text: e.courseDetails);
    _dressCodeController = TextEditingController(text: e.dressCode);
    _buggiesController = TextEditingController(text: e.availableBuggies?.toString() ?? '');
    _maxParticipantsController = TextEditingController(text: e.maxParticipants?.toString() ?? '');
    _memberCostController = TextEditingController(text: e.memberCost?.toString() ?? '');
    _guestCostController = TextEditingController(text: e.guestCost?.toString() ?? '');
    _breakfastCostController = TextEditingController(text: e.breakfastCost?.toString() ?? '');
    _lunchCostController = TextEditingController(text: e.lunchCost?.toString() ?? '');
    _dinnerCostController = TextEditingController(text: e.dinnerCost?.toString() ?? '');
    _dinnerLocationController = TextEditingController(text: e.dinnerLocation);
    _buggyCostController = TextEditingController(text: e.buggyCost?.toString() ?? '');
    _intervalController = TextEditingController(text: e.teeOffInterval.toString());
    
    _notesControllers = (e.notes).map((n) => NoteItemController(
      title: n.title,
      content: n.content,
      imageUrl: n.imageUrl,
    )).toList();
    _facilitiesControllers = (e.facilities).map((f) => TextEditingController(text: f)).toList();

      if (e.courseConfig['holes'] != null) {
        final List<dynamic> holes = e.courseConfig['holes'];
        _holeParsControllers = holes.map((h) => TextEditingController(text: (h['par'] as num).toInt().toString())).toList();
        _holeSIsControllers = holes.map((h) => TextEditingController(text: (h['si'] as num).toInt().toString())).toList();
        _holeYardagesControllers = holes.map((h) => TextEditingController(text: (h['yardage'] as num?)?.toInt().toString() ?? '0')).toList();
        _holeSIsFocusNodes = List.generate(18, (i) => FocusNode());
        _slopeController = TextEditingController(text: ((e.courseConfig['slope'] as num?)?.toInt() ?? 113).toString());
        _ratingController = TextEditingController(text: ((e.courseConfig['rating'] as num?)?.toDouble() ?? 72.0).toString());
      } else {
        _holeParsControllers = List.generate(18, (i) => TextEditingController(text: '4'));
        _holeSIsControllers = List.generate(18, (i) => TextEditingController(text: (i + 1).toString()));
        _holeYardagesControllers = List.generate(18, (i) => TextEditingController(text: '0'));
        _holeSIsFocusNodes = List.generate(18, (i) => FocusNode());
        _slopeController = TextEditingController(text: '113');
        _ratingController = TextEditingController(text: '72.0');
      }
      
      _slopeFocusNode = FocusNode();
      _ratingFocusNode = FocusNode();
      _selectedTeeName = e.selectedTeeName;
    if (_facilitiesControllers.isEmpty) _facilitiesControllers.add(TextEditingController());

    _selectedDate = e.date;
    _selectedTime = TimeOfDay.fromDateTime(e.teeOffTime ?? DateTime.now());
    _registrationTime = TimeOfDay.fromDateTime(e.regTime ?? DateTime.now());
    _deadlineDate = e.registrationDeadline;
    _deadlineTime = e.registrationDeadline != null ? TimeOfDay.fromDateTime(e.registrationDeadline!) : null;
    _hasBreakfast = e.hasBreakfast;
    _hasLunch = e.hasLunch;
    _hasDinner = e.hasDinner;
    _showRegistrationButton = e.showRegistrationButton;
    _selectedSeasonId = e.seasonId;
    _selectedCourseId = e.courseId;
    _isMultiDay = e.isMultiDay == true;
    _endDate = e.endDate;
    _secondaryTemplateId = e.secondaryTemplateId;
    _isInvitational = e.isInvitational;

    // Fetch secondary competition if exists
    if (e.id.isNotEmpty && _secondaryTemplateId != null) {
      _fetchSecondaryCompetition(e.id);
    }

    // Fetch tees if courseId exists
    if (_selectedCourseId != null) {
      ref.read(coursesProvider).whenData((courses) {
        final course = courses.where((c) => c.id == _selectedCourseId).firstOrNull;
        if (course != null && mounted) {
          setState(() {
            _availableTees = course.tees;
            // If the selected tee is in the list, we're good. 
            // If not (e.g. course changed), we keep the current _selectedTeeName
          });
        }
      });
    }
  }

  void _onCourseSelected(Course course) {
    setState(() {
      _selectedCourseId = course.id;
      _courseNameController.text = course.name;
      _courseDetailsController.text = course.address;
      _availableTees = course.tees;
      if (_availableTees.isNotEmpty) {
        _applyTeeConfig(_availableTees.first);
      }
    });
  }

  void _applyTeeConfig(TeeConfig tee) {
    setState(() {
      _selectedTeeName = tee.name;
      _slopeController.text = tee.slope.toString();
      _ratingController.text = tee.rating.toString();
      for (int i = 0; i < 18; i++) {
        _holeParsControllers[i].text = tee.holePars[i].toString();
        _holeSIsControllers[i].text = tee.holeSIs[i].toString();
        _holeYardagesControllers[i].text = tee.yardages[i].toString();
      }
    });
  }


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _courseNameController.dispose();
    _courseDetailsController.dispose();
    _dressCodeController.dispose();
    _buggiesController.dispose();
    _maxParticipantsController.dispose();
    _memberCostController.dispose();
    _guestCostController.dispose();
    _breakfastCostController.dispose();
    _lunchCostController.dispose();
    _dinnerCostController.dispose();
    _dinnerLocationController.dispose();
    _buggyCostController.dispose();
    _intervalController.dispose();
    _slopeController.dispose();
    _ratingController.dispose();
    _slopeFocusNode.dispose();
    _ratingFocusNode.dispose();
    for (var controller in _holeParsControllers) {
      controller.dispose();
    }
    for (var controller in _holeSIsControllers) {
      controller.dispose();
    }
    for (var node in _holeSIsFocusNodes) {
      node.dispose();
    }
    for (var note in _notesControllers) {
      note.dispose();
    }
    for (var controller in _facilitiesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isTeeOff}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isTeeOff ? _selectedTime : _registrationTime,
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isTeeOff) {
          _selectedTime = picked;
        } else {
          _registrationTime = picked;
        }
      });
    }
  }

  Future<void> _pickDeadline() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _deadlineDate ?? _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: child!,
          ),
        );
      },
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _deadlineTime ?? const TimeOfDay(hour: 17, minute: 0),
      );
      if (pickedTime != null) {
        setState(() {
          _deadlineDate = pickedDate;
          _deadlineTime = pickedTime;
        });
      }
    }
  }

  void _addNote() {
    setState(() => _notesControllers.add(NoteItemController()));
  }

  void _addNoteWithPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
       setState(() => _notesControllers.add(NoteItemController(imageUrl: picked.path)));
    } else {
       setState(() => _notesControllers.add(NoteItemController()));
    }
  }

  void _addFacility() {
    setState(() => _facilitiesControllers.add(TextEditingController()));
  }

  Future<void> _save({bool shouldPop = true}) async {
    if (!_formKey.currentState!.validate()) return;

    // Validate SI uniqueness
    final sis = _holeSIsControllers.map((c) => int.tryParse(c.text)).whereType<int>().toList();
    if (sis.length < 18) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All Hole SIs must be valid numbers')));
      return;
    }
    final uniqueSis = sis.toSet();
    if (uniqueSis.length < 18) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hole SIs must be unique (1-18)')));
       return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(eventsRepositoryProvider);
      final newEvent = await _constructEventFromForm();
      final isEditing = _editingEvent != null || widget.event != null;
      
      String finalEventId;
      if (!isEditing) {
        finalEventId = await repo.addEvent(newEvent);
      } else {
        await repo.updateEvent(newEvent);
        finalEventId = newEvent.id;
      }
      
      // AUTO-CREATE OR UPDATE COMPETITION
      final compRepo = ref.read(competitionsRepositoryProvider);
      final hasTemplate = _selectedTemplateId != null;
      final templateChanged = _selectedTemplateId != _initialTemplateId;
      
      if (hasTemplate && templateChanged) {
          // USER SELECTED A NEW TEMPLATE - Apply template rules
          final templates = ref.read(templatesListProvider).value;
          final template = templates?.firstWhere((t) => t.id == _selectedTemplateId, orElse: () => throw Exception("Template not found"));
          
          if (template != null) {
             final newComp = Competition(
               id: finalEventId, 
               templateId: _selectedTemplateId, 
               type: CompetitionType.event,
               status: CompetitionStatus.draft,
               rules: template.rules, 
               startDate: newEvent.date,
               endDate: _isMultiDay && _endDate != null ? _endDate! : newEvent.date,
               publishSettings: {},
               isDirty: true,
             );
             await compRepo.addCompetition(newComp);
          }
      } else if (_eventCompetition != null) {
          // EXISTING OR CUSTOMIZED COMPETITION - Sync dates
          final updatedComp = _eventCompetition!.copyWith(
             startDate: newEvent.date,
             endDate: _isMultiDay && _endDate != null ? _endDate! : newEvent.date,
          );
          await compRepo.updateCompetition(updatedComp);
      } else if (!hasTemplate && _eventCompetition == null) {
          // NO GAME SELECTED - Clear remnant
          await compRepo.deleteCompetition(finalEventId);
      }

      // SECONDARY COMPETITION (MATCH PLAY OVERLAY)
      if (_secondaryTemplateId != null) {
         final secondaryId = '${finalEventId}_secondary';
         if (_secondaryCompetition == null) {
            final templates = ref.read(templatesListProvider).value;
            final template = templates?.where((t) => t.id == _secondaryTemplateId).firstOrNull;
            if (template != null) {
               final newSecondary = Competition(
                 id: secondaryId,
                 templateId: _secondaryTemplateId,
                 type: CompetitionType.event,
                 status: CompetitionStatus.draft,
                 rules: template.rules,
                 startDate: newEvent.date,
                 endDate: _isMultiDay && _endDate != null ? _endDate! : newEvent.date,
                 publishSettings: {},
                 isDirty: true,
               );
               await compRepo.addCompetition(newSecondary);
            }
         } else {
            final updatedSecondary = _secondaryCompetition!.copyWith(
              startDate: newEvent.date,
              endDate: _isMultiDay && _endDate != null ? _endDate! : newEvent.date,
            );
            await compRepo.updateCompetition(updatedSecondary);
         }
      } else {
         // Clear secondary if removed
         await compRepo.deleteCompetition('${finalEventId}_secondary');
      }

      // Update _editingEvent after save so subsequent operations have access to the event ID
      if (!isEditing && mounted) {
        final savedEvent = await repo.getEvent(finalEventId);
        if (savedEvent != null) {
          setState(() {
            _editingEvent = savedEvent;
          });
        }
      }

      if (mounted && shouldPop) {
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(seasonsProvider, (previous, next) {
      next.whenData((seasons) {
        final activeSeasons = seasons.where((s) => s.status == SeasonStatus.active).toList();
        if (activeSeasons.isNotEmpty && _selectedSeasonId == null) {
          final current = activeSeasons.any((s) => s.isCurrent)
              ? activeSeasons.firstWhere((s) => s.isCurrent)
              : activeSeasons.first;
          setState(() => _selectedSeasonId = current.id);
        }
      });
    });

    // Initialize seasonId if null (for new events)
    final societyConfig = ref.watch(themeControllerProvider);
    final currency = societyConfig.currencySymbol;

    if (_selectedSeasonId == null) {
      final activeSeason = ref.watch(activeSeasonProvider).value;
      if (activeSeason != null) {
        _selectedSeasonId = activeSeason.id;
      }
    }

    final isEditing = _editingEvent != null || widget.event != null;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return HeadlessScaffold(
      title: isEditing ? 'Edit Event Settings' : 'Create Event',
      subtitle: isEditing ? (widget.event?.title ?? 'Update Details') : 'Create a new society event',
      leadingWidth: 70,
      leading: Center(
        child: BoxyArtGlassIconButton(
          icon: isEditing ? Icons.arrow_back_rounded : Icons.close_rounded,
          iconSize: 24,
          onPressed: () {
            if (isEditing) {
              final id = widget.eventId ?? widget.event?.id;
              context.go('/admin/events/manage/$id/event');
            } else {
              context.go('/admin/events');
            }
          },
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _isSaving 
            ? const SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : BoxyArtGlassIconButton(
                icon: Icons.check_rounded,
                iconSize: 22,
                onPressed: _save,
              ),
        ),
      ],
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Lift above bottom menu
        child: FloatingActionButton(
          onPressed: _showPreview,
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.visibility, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Seasonal context is handled automatically via listeners

                const BoxyArtSectionTitle(title: 'Basic Info'),
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      BoxyArtFormField(
                        key: const ValueKey('event_title'),
                        label: 'Event Title',
                        controller: _titleController,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      BoxyArtFormField(
                        key: const ValueKey('event_description'),
                        label: 'Description',
                        controller: _descriptionController,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                const BoxyArtSectionTitle(title: 'DateTime & Registration'),
                const SizedBox(height: 12),
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      BoxyArtDatePickerField(
                        label: _isMultiDay ? 'Start Date' : 'Date',
                        value: DateFormat.yMMMd().format(_selectedDate),
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 16),
                      BoxyArtSwitchField(
                        label: 'Multi-Day Event', 
                        value: _isMultiDay, 
                        onChanged: (v) => setState(() => _isMultiDay = v),
                      ),
                      if (_isMultiDay) ...[
                        const SizedBox(height: 16),
                         BoxyArtDatePickerField(
                          label: 'End Date',
                          value: _endDate != null ? DateFormat.yMMMd().format(_endDate!) : 'Select End Date',
                          onTap: () async {
                              final picked = await showDatePicker(
                                context: context, 
                                initialDate: _endDate ?? _selectedDate, 
                                firstDate: _selectedDate, 
                                lastDate: DateTime(2030)
                              );
                              if (picked != null) setState(() => _endDate = picked);
                          },
                        ),
                      ],
                      const Divider(height: 32),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: BoxyArtDatePickerField(
                              label: 'Registration',
                              value: _registrationTime.format(context),
                              onTap: () => _pickTime(isTeeOff: false),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: BoxyArtDatePickerField(
                              label: 'Tee-off',
                              value: _selectedTime.format(context),
                              onTap: () => _pickTime(isTeeOff: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BoxyArtFormField(
                        label: 'Group Tee-off Interval (minutes)',
                        controller: _intervalController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      BoxyArtDatePickerField(
                        label: 'Registration Deadline',
                        value: (_deadlineDate == null || _deadlineTime == null) 
                            ? 'No deadline set' 
                            : '${DateFormat.yMMMd().format(_deadlineDate!)} @ ${_deadlineTime!.format(context)}',
                        onTap: _pickDeadline,
                      ),
                      const SizedBox(height: 16),
                      BoxyArtSwitchField(
                        label: 'Show Registration Button',
                        value: _showRegistrationButton,
                        onChanged: (v) => setState(() => _showRegistrationButton = v),
                      ),
                      const SizedBox(height: 16),
                      ModernSwitchRow(
                        label: 'Invitational / Non-Scoring',
                        subtitle: "Exclude this event's scores from all season leaderboards.",
                        icon: Icons.star_border_rounded,
                        value: _isInvitational,
                        onChanged: (v) => setState(() => _isInvitational = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const BoxyArtSectionTitle(title: 'Course Selection'),
                const SizedBox(height: 12),
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      // Course Lookup field
                      Consumer(
                        builder: (context, ref, child) {
                          final coursesAsync = ref.watch(coursesProvider);
                          
                          return coursesAsync.when(
                            data: (allCourses) {
                              return Autocomplete<Course>(
                                initialValue: TextEditingValue(text: _courseNameController.text),
                                optionsBuilder: (textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<Course>.empty();
                                  }
                                  final query = textEditingValue.text.toLowerCase();
                                  final matches = allCourses.where((course) {
                                    return course.name.toLowerCase().contains(query) ||
                                           course.address.toLowerCase().contains(query);
                                  }).toList();

                                  if (matches.isEmpty) {
                                    // Return a dummy course to show "No results"
                                    return [
                                      Course(
                                        id: 'none',
                                        name: 'No courses found',
                                        address: 'Tap below to define a new course',
                                        tees: [],
                                      )
                                    ];
                                  }
                                  return matches;
                                },
                                displayStringForOption: (course) => course.name,
                                onSelected: (course) {
                                  if (course.id == 'none') return;
                                  _onCourseSelected(course);
                                },
                                fieldViewBuilder: (context, controller, focus, onSubmitted) {
                                  return BoxyArtFormField(
                                    label: 'Course Name (Search)',
                                    controller: controller,
                                    focusNode: focus,
                                    hintText: 'Type to search courses...',
                                    prefixIcon: Icons.search,
                                    onChanged: (val) {
                                      _courseNameController.text = val;
                                    },
                                  );
                                },
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Material(
                                        elevation: 8,
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        clipBehavior: Clip.antiAlias,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width - 64,
                                          constraints: const BoxConstraints(maxHeight: 250),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade200),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: options.length,
                                            itemBuilder: (context, index) {
                                              final course = options.elementAt(index);
                                              final isNone = course.id == 'none';
                                              
                                              return ListTile(
                                                title: Text(
                                                  course.name, 
                                                  style: TextStyle(
                                                    fontWeight: isNone ? FontWeight.normal : FontWeight.bold,
                                                    color: isNone ? Colors.grey : Colors.black87,
                                                    fontSize: 14,
                                                    fontStyle: isNone ? FontStyle.italic : FontStyle.normal,
                                                  )
                                                ),
                                                subtitle: Text(
                                                  course.address, 
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade600,
                                                  )
                                                ),
                                                onTap: isNone ? null : () => onSelected(course),
                                                dense: true,
                                                hoverColor: Colors.grey.shade100,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (err, _) => Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('Error loading courses: $err', style: const TextStyle(color: Colors.red, fontSize: 12)),
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 16),
                      BoxyArtFormField(
                        key: const ValueKey('event_course_details'),
                        label: 'Course Location (Auto-filled)',
                        controller: _courseDetailsController,
                        readOnly: true,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      if (_availableTees.isNotEmpty)
                        BoxyArtDropdownField<String>(
                          label: 'Tee Position',
                          value: _selectedTeeName,
                          items: _availableTees.map((t) => DropdownMenuItem(
                            value: t.name,
                            child: Text(t.name),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final tee = _availableTees.firstWhere((t) => t.name == val);
                              _applyTeeConfig(tee);
                            }
                          },
                        )
                      else if (_selectedTeeName != null || _courseNameController.text.isNotEmpty)
                        BoxyArtFormField(
                          label: 'Tee Position (Manual)',
                          controller: TextEditingController(text: _selectedTeeName),
                          onChanged: (val) => _selectedTeeName = val,
                        ),
                      const SizedBox(height: 16),
                      BoxyArtFormField(
                        key: const ValueKey('event_dress_code'),
                        label: 'Dress Code',
                        controller: _dressCodeController,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: BoxyArtFormField(
                              label: 'Available Buggies',
                              controller: _buggiesController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: BoxyArtFormField(
                              label: 'Buggy Cost ($currency)',
                              controller: _buggyCostController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                        BoxyArtFormField(
                          label: 'Available Spaces',
                          controller: _maxParticipantsController,
                          keyboardType: TextInputType.number,
                          hintText: 'Max players (multiples of 4)',
                          validator: (v) {
                            if (v == null || v.isEmpty) return null;
                            final val = int.tryParse(v);
                            if (val == null) return 'Invalid number';
                            if (val % 4 != 0) return 'Must be a multiple of 4';
                            return null;
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const BoxyArtSectionTitle(
                  title: 'COMPETITION RULES',
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                BoxyArtFloatingCard(
                  padding: const EdgeInsets.all(16),
                  child: Consumer(
                    builder: (context, ref, child) {
                            final templatesAsync = ref.watch(templatesListProvider);
                            final templates = templatesAsync.value ?? [];
                            final selectedTemplate = templates.where((t) => t.id == _selectedTemplateId).firstOrNull;
                            
                            // Source of truth: We have a game if a template is selected OR we already have an event competition
                            final hasGame = _selectedTemplateId != null || _eventCompetition != null;
                            final displayComp = _eventCompetition ?? selectedTemplate;

                            if (!hasGame || displayComp == null) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'NO RULES APPLIED',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: BoxyArtButton(
                                      title: 'ADD GAME FORMAT',
                                      onTap: () async {
                                        final result = await context.push<String>('/admin/events/competitions/new');
                                        if (result != null) {
                                          setState(() {
                                            _selectedTemplateId = result;
                                            _isCustomized = false;
                                            _eventCompetition = null;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final result = await context.push<String>('/admin/events/competitions/new');
                                          if (result != null) {
                                            setState(() {
                                              _selectedTemplateId = result;
                                              _isCustomized = false;
                                              _eventCompetition = null;
                                            });
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                              child: Icon(Icons.golf_course, color: Theme.of(context).primaryColor),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (_isCustomized && _eventCompetition?.name != null && _eventCompetition!.name!.isNotEmpty)
                                                        ? _eventCompetition!.name!.toUpperCase()
                                                        : (displayComp.name?.toUpperCase() ?? displayComp.rules.gameName),
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 4,
                                                    children: [
                                                      BoxyArtStatusPill(
                                                        text: displayComp.rules.gameName,
                                                        baseColor: Colors.black87,
                                                      ),
                                                      BoxyArtStatusPill(
                                                        text: displayComp.rules.scoringType.toUpperCase(),
                                                        baseColor: displayComp.rules.scoringType == 'GROSS' ? Colors.redAccent : Colors.teal,
                                                      ),
                                                      BoxyArtStatusPill(
                                                        text: displayComp.rules.defaultAllowanceLabel,
                                                        baseColor: Theme.of(context).primaryColor,
                                                      ),
                                                      BoxyArtStatusPill(
                                                        text: displayComp.rules.mode.name.toUpperCase(),
                                                        baseColor: Colors.blueGrey,
                                                      ),
                                                      if (displayComp.rules.minDrivesPerPlayer > 0)
                                                        BoxyArtStatusPill(
                                                          text: '${displayComp.rules.minDrivesPerPlayer} DRIVES',
                                                          baseColor: Colors.orange,
                                                        ),
                                                      if (displayComp.rules.applyCapToIndex)
                                                        BoxyArtStatusPill(
                                                          text: 'CAP: ${displayComp.rules.handicapCap}',
                                                          baseColor: Colors.deepPurple,
                                                        ),
                                                      if (displayComp.rules.roundsCount > 1 && displayComp.rules.aggregation != AggregationMethod.totalSum)
                                                        BoxyArtStatusPill(
                                                          text: displayComp.rules.aggregation.name.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}').toUpperCase(),
                                                          baseColor: Colors.blue,
                                                        ),
                                                      if (displayComp.rules.tieBreak != TieBreakMethod.back9 && displayComp.rules.tieBreak != TieBreakMethod.playoff)
                                                        BoxyArtStatusPill(
                                                          text: 'TB: ${displayComp.rules.tieBreak.name.toUpperCase()}',
                                                          baseColor: Colors.brown,
                                                        ),
                                                      if (displayComp.rules.format == CompetitionFormat.maxScore && displayComp.rules.maxScoreConfig != null)
                                                        BoxyArtStatusPill(
                                                          text: displayComp.rules.maxScoreConfig!.type == MaxScoreType.parPlusX 
                                                              ? 'CAP: PAR + ${displayComp.rules.maxScoreConfig!.value}' 
                                                              : 'CAP: ${displayComp.rules.maxScoreConfig!.value}',
                                                          baseColor: Colors.deepOrange,
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => setState(() {
                                        _selectedTemplateId = null;
                                        _isCustomized = false;
                                        _eventCompetition = null;
                                      }),
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const Divider(height: 1, indent: 56),
                                Row(
                                  children: [
                                    const SizedBox(width: 56),
                                    TextButton.icon(
                                      onPressed: () async {
                                        // Ensure we have an event ID (save if needed)
                                        String? eventId = _editingEvent?.id ?? widget.event?.id;
                                        
                                        if (eventId == null) {
                                          // New event - must save first to get an ID
                                          bool? proceed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text("Save Event First?"),
                                              content: const Text("To customize rules, we need to save the basic event details first."),
                                              actions: [
                                                TextButton(onPressed: () => context.pop(false), child: const Text("Cancel")),
                                                TextButton(
                                                  onPressed: () => context.pop(true), 
                                                  child: const Text("Save & Customize"),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (proceed != true) return;
                                          await _save(shouldPop: false);
                                          if (!mounted) return;
                                          eventId = _editingEvent?.id ?? widget.event?.id;
                                          if (eventId == null) return; // Still no ID, abort
                                        }

                                        // Create competition on-the-fly if template is selected but competition doesn't exist
                                        final compRepo = ref.read(competitionsRepositoryProvider);
                                        if (_selectedTemplateId != null && _eventCompetition == null) {
                                          final templates = ref.read(templatesListProvider).value;
                                          final template = templates?.firstWhere(
                                            (t) => t.id == _selectedTemplateId, 
                                            orElse: () => throw Exception("Template not found")
                                          );
                                          
                                          if (template != null) {
                                            final newComp = Competition(
                                              id: eventId, 
                                              templateId: _selectedTemplateId, 
                                              type: CompetitionType.event,
                                              status: CompetitionStatus.draft,
                                              rules: template.rules, 
                                              startDate: _selectedDate,
                                              endDate: _isMultiDay && _endDate != null ? _endDate! : _selectedDate,
                                              publishSettings: {},
                                              isDirty: true,
                                            );
                                            await compRepo.addCompetition(newComp);
                                            if (mounted) {
                                              setState(() {
                                                _eventCompetition = newComp;
                                                _initialTemplateId = _selectedTemplateId; // Mark template as applied
                                              });
                                            }
                                          }
                                        }
                                        
                                        if (!mounted) return;

                                        // Navigate to competition editor
                                        // ignore: use_build_context_synchronously
                                        final router = GoRouter.of(context);
                                        await router.push('/admin/events/competitions/edit/$eventId');
                                        if (mounted) _fetchCompetition(eventId);
                                      },
                                      icon: Icon(_isCustomized ? Icons.edit_note : Icons.tune, size: 18),
                                      label: Text(_isCustomized ? 'CUSTOMIZED' : 'CUSTOMIZE RULES'),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 36),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                    },
                  ),
                ),
                
                // SECONDARY GAME (MATCH PLAY OVERLAY)
                Consumer(
                  builder: (context, ref, child) {
                    final templates = ref.watch(templatesListProvider).value ?? [];
                    final displayComp = _eventCompetition ?? templates.where((t) => t.id == _selectedTemplateId).firstOrNull;
                    
                    if (displayComp == null) return const SizedBox.shrink();
                    
                    final format = displayComp.rules.format;
                    final isStableford = format == CompetitionFormat.stableford;
                    final isStroke = format == CompetitionFormat.stroke;
                    
                    if (!isStableford && !isStroke) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const BoxyArtSectionTitle(title: 'SECONDARY GAME (OVERLAY)'),
                        const SizedBox(height: 12),
                        BoxyArtFloatingCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_secondaryTemplateId == null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'NO OVERLAY ACTIVE',
                                      style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: BoxyArtButton(
                                        title: 'ADD MATCH PLAY OVERLAY',
                                        onTap: () async {
                                          final result = await context.push<String>('/admin/events/competitions/new?format=matchPlay');
                                          if (result != null) {
                                            setState(() => _secondaryTemplateId = result);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.orange.withValues(alpha: 0.1),
                                          child: const Icon(Icons.compare_arrows, color: Colors.orange),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('MATCH PLAY OVERLAY', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              Text(
                                                (_isSecondaryCustomized && _secondaryCompetition?.name != null && _secondaryCompetition!.name!.isNotEmpty)
                                                    ? _secondaryCompetition!.name!.toUpperCase()
                                                    : (_secondaryCompetition?.name ?? templates.where((t) => t.id == _secondaryTemplateId).firstOrNull?.name ?? 'Match Play'),
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              if (_secondaryCompetition != null || templates.any((t) => t.id == _secondaryTemplateId)) ...[
                                                const SizedBox(height: 8),
                                                Consumer(
                                                  builder: (context, ref, child) {
                                                    final rules = _secondaryCompetition?.rules ?? templates.firstWhere((t) => t.id == _secondaryTemplateId).rules;
                                                    return Wrap(
                                                      spacing: 8,
                                                      runSpacing: 4,
                                                      children: [
                                                        BoxyArtStatusPill(
                                                          text: rules.gameName,
                                                          baseColor: Colors.black87,
                                                        ),
                                                        BoxyArtStatusPill(
                                                          text: rules.scoringType.toUpperCase(),
                                                          baseColor: Colors.orangeAccent,
                                                        ),
                                                        BoxyArtStatusPill(
                                                          text: rules.defaultAllowanceLabel,
                                                          baseColor: Theme.of(context).primaryColor,
                                                        ),
                                                        BoxyArtStatusPill(
                                                          text: rules.mode.name.toUpperCase(),
                                                          baseColor: Colors.blueGrey,
                                                        ),
                                                        if (rules.applyCapToIndex)
                                                          BoxyArtStatusPill(
                                                            text: 'CAP: ${rules.handicapCap}',
                                                            baseColor: Colors.deepPurple,
                                                          ),
                                                        if (rules.tieBreak != TieBreakMethod.back9 && rules.tieBreak != TieBreakMethod.playoff)
                                                          BoxyArtStatusPill(
                                                            text: 'TB: ${rules.tieBreak.name.toUpperCase()}',
                                                            baseColor: Colors.brown,
                                                          ),
                                                      ],
                                                    );
                                                  }
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => setState(() {
                                            _secondaryTemplateId = null;
                                            _secondaryCompetition = null;
                                            _isSecondaryCustomized = false;
                                          }),
                                          icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 1, indent: 56),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const SizedBox(width: 56),
                                        TextButton.icon(
                                          onPressed: () async {
                                            String? eventId = _editingEvent?.id ?? widget.event?.id;
                                            if (eventId == null) {
                                              bool? proceed = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text("Save Event First?"),
                                                  content: const Text("To customize rules, we need to save the basic event details first."),
                                                  actions: [
                                                    TextButton(onPressed: () => context.pop(false), child: const Text("Cancel")),
                                                    TextButton(onPressed: () => context.pop(true), child: const Text("Save & Customize")),
                                                  ],
                                                ),
                                              );
                                              if (proceed != true) return;
                                              await _save(shouldPop: false);
                                              if (!mounted) return;
                                              eventId = _editingEvent?.id ?? widget.event?.id;
                                            }
                                            if (eventId == null) return;
                                            
                                            final secondaryId = '${eventId}_secondary';
                                            if (_secondaryCompetition == null) {
                                               final template = templates.where((t) => t.id == _secondaryTemplateId).firstOrNull;
                                               if (template != null) {
                                                   final newComp = Competition(
                                                     id: secondaryId,
                                                     templateId: _secondaryTemplateId,
                                                     type: CompetitionType.event,
                                                     status: CompetitionStatus.draft,
                                                     rules: template.rules,
                                                     startDate: _selectedDate,
                                                     endDate: _isMultiDay && _endDate != null ? _endDate! : _selectedDate,
                                                     publishSettings: {},
                                                     isDirty: true,
                                                   );
                                                   await ref.read(competitionsRepositoryProvider).addCompetition(newComp);
                                                   if (mounted) _fetchSecondaryCompetition(eventId);
                                               }
                                            }

                                            if (!mounted) return;
                                            if (mounted) {
                                              context.push('/admin/events/competitions/edit/$secondaryId');
                                            }
                                            if (mounted) _fetchSecondaryCompetition(eventId);
                                          },
                                          icon: Icon(_isSecondaryCustomized ? Icons.edit_note : Icons.tune, size: 18),
                                          label: Text(_isSecondaryCustomized ? 'CUSTOMIZED' : 'CUSTOMIZE RULES'),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 36),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                ),

                const SizedBox(height: 24),
                const BoxyArtSectionTitle(title: 'Playing Costs'),
                const SizedBox(height: 12),
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: BoxyArtFormField(
                              label: 'Member Cost ($currency)',
                              controller: _memberCostController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: BoxyArtFormField(
                              label: 'Guest Cost ($currency)',
                              controller: _guestCostController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const BoxyArtSectionTitle(title: 'Meal Options & Costs'),
                const SizedBox(height: 12),
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      BoxyArtSwitchField(
                        label: 'Offer Breakfast',
                        value: _hasBreakfast,
                        onChanged: (v) => setState(() => _hasBreakfast = v),
                      ),
                      if (_hasBreakfast) ...[
                        const SizedBox(height: 16),
                        BoxyArtFormField(
                          label: 'Breakfast Cost ($currency)',
                          controller: _breakfastCostController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                      const Divider(height: 32),
                      BoxyArtSwitchField(
                        label: 'Offer Lunch',
                        value: _hasLunch,
                        onChanged: (v) => setState(() => _hasLunch = v),
                      ),
                      if (_hasLunch) ...[
                        const SizedBox(height: 16),
                        BoxyArtFormField(
                          label: 'Lunch Cost ($currency)',
                          controller: _lunchCostController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                      const Divider(height: 32),
                      BoxyArtSwitchField(
                        label: 'Offer Dinner',
                        value: _hasDinner,
                        onChanged: (v) => setState(() => _hasDinner = v),
                      ),
                      if (_hasDinner) ...[
                        const SizedBox(height: 16),
                        BoxyArtFormField(
                          label: 'Dinner Cost ($currency)',
                          controller: _dinnerCostController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const BoxyArtSectionTitle(title: 'Dinner Info'),
                const SizedBox(height: 12),
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      BoxyArtFormField(
                        label: 'Dinner Location',
                        controller: _dinnerLocationController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const BoxyArtSectionTitle(title: 'Facilities'),
                const SizedBox(height: 12),
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      ..._facilitiesControllers.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: BoxyArtFormField(
                            label: 'Facility ${entry.key + 1}',
                            controller: entry.value,
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _addFacility,
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text('Add Facility', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const BoxyArtSectionTitle(title: 'Notes & Content'),
                const SizedBox(height: 12),
                ..._notesControllers.asMap().entries.map((entry) {
                   return _buildRichNoteItem(entry.key, entry.value);
                }),
                
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _addNote,
                      icon: const Icon(Icons.add_comment_outlined, color: Colors.black, size: 20),
                      label: const Text(
                        'Add Note',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 24),
                    TextButton.icon(
                      onPressed: _addNoteWithPhoto,
                      icon: const Icon(Icons.add_a_photo_outlined, color: Colors.black, size: 20),
                      label: const Text(
                        'Add Photo',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRichNoteItem(int index, NoteItemController note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: BoxyArtFloatingCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: note.titleController,
                    decoration: const InputDecoration(
                      hintText: 'Note Title (Optional)',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () => setState(() => _notesControllers.removeAt(index)),
                ),
              ],
            ),
            const Divider(),
            if (note.imageUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: note.imageUrl!.startsWith('http') 
                  ? Image.network(
                      note.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    )
                  : Image.file(
                      File(note.imageUrl!),
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
              ),
              const SizedBox(height: 16),
            ],
            QuillSimpleToolbar(
              controller: note.quillController,
              config: QuillSimpleToolbarConfig(
                showFontFamily: false,
                showFontSize: false,
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: false,
                showInlineCode: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: true,
                showAlignmentButtons: false,
                showLeftAlignment: false,
                showCenterAlignment: false,
                showRightAlignment: false,
                showJustifyAlignment: false,
                showDirection: false,
                showListNumbers: true,
                showListBullets: true,
                showListCheck: false,
                showCodeBlock: false,
                showQuote: true,
                showIndent: false,
                showLink: false,
                showUndo: true,
                showRedo: true,
                multiRowsDisplay: false,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(minHeight: 100),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: QuillEditor.basic(
                controller: note.quillController,
                config: QuillEditorConfig(
                  padding: EdgeInsets.zero,
                  autoFocus: false,
                  expands: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<GolfEvent> _constructEventFromForm() async {
    // FALLBACK: If seasonId is null (e.g. initial load of new event), pick active season
    String? finalSeasonId = _selectedSeasonId;
    if (finalSeasonId == null) {
      final activeSeason = ref.read(activeSeasonProvider).value;
      finalSeasonId = activeSeason?.id;
    }

    if (finalSeasonId == null || finalSeasonId.isEmpty) {
      throw Exception('No active season found. Please create or activate a season first.');
    }
    
    final teeOffDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final regDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _registrationTime.hour,
      _registrationTime.minute,
    );

    DateTime? deadlineFull;
    if (_deadlineDate != null && _deadlineTime != null) {
      deadlineFull = DateTime(
        _deadlineDate!.year,
        _deadlineDate!.month,
        _deadlineDate!.day,
        _deadlineTime!.hour,
        _deadlineTime!.minute,
      );
    }

    final storage = ref.read(storageServiceProvider);
    final List<EventNote> finalizeNotes = [];

    for (var n in _notesControllers) {
      String? finalUrl = n.imageUrl;
      // If it's a local file, upload it
      if (n.imageUrl != null && n.imageUrl!.startsWith('/')) {
         finalUrl = await storage.uploadImage(
           path: 'events/notes',
           file: File(n.imageUrl!),
         );
      }

      final content = jsonEncode(n.quillController.document.toDelta().toJson());
      finalizeNotes.add(EventNote(
        title: n.titleController.text.trim(),
        content: content,
        imageUrl: finalUrl,
      ));
    }

    return GolfEvent(
      id: _editingEvent?.id ?? widget.event?.id ?? '', 
      title: _titleController.text.trim(),
      seasonId: finalSeasonId,
      date: _selectedDate,
      teeOffTime: teeOffDateTime,
      regTime: regDateTime,
      registrationDeadline: deadlineFull,
      description: _descriptionController.text.trim(),
      courseName: _courseNameController.text.trim(),
      courseDetails: _courseDetailsController.text.trim(),
      dressCode: _dressCodeController.text.trim(),
      availableBuggies: int.tryParse(_buggiesController.text),
      maxParticipants: int.tryParse(_maxParticipantsController.text),
      memberCost: double.tryParse(_memberCostController.text),
      guestCost: double.tryParse(_guestCostController.text),
      breakfastCost: double.tryParse(_breakfastCostController.text),
      lunchCost: double.tryParse(_lunchCostController.text),
      dinnerCost: double.tryParse(_dinnerCostController.text),
      buggyCost: double.tryParse(_buggyCostController.text),
      hasBreakfast: _hasBreakfast,
      hasLunch: _hasLunch,
      hasDinner: _hasDinner,
      dinnerLocation: _dinnerLocationController.text.trim(),
      teeOffInterval: int.tryParse(_intervalController.text) ?? 10,
      showRegistrationButton: _showRegistrationButton,
      notes: finalizeNotes,
      isMultiDay: _isMultiDay,
      endDate: _isMultiDay ? _endDate : null,
      isInvitational: _isInvitational,
      facilities: _facilitiesControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
      status: _editingEvent?.status ?? widget.event?.status ?? EventStatus.draft,
      registrations: _editingEvent?.registrations ?? widget.event?.registrations ?? [], // Preserve existing registrations!
      // CRITICAL: Preserve published event data (groupings, scores, leaderboards)
      isGroupingPublished: _editingEvent?.isGroupingPublished ?? widget.event?.isGroupingPublished ?? false,
      grouping: _editingEvent?.grouping ?? widget.event?.grouping ?? {},
      results: _editingEvent?.results ?? widget.event?.results ?? [],
      flashUpdates: _editingEvent?.flashUpdates ?? widget.event?.flashUpdates ?? [],
      courseId: _selectedCourseId,
      selectedTeeName: _selectedTeeName,
      secondaryTemplateId: _secondaryTemplateId,
      courseConfig: {
        'holes': List.generate(18, (i) => {
          'hole': i + 1,
          'par': int.tryParse(_holeParsControllers[i].text) ?? 4,
          'si': int.tryParse(_holeSIsControllers[i].text) ?? (i + 1),
          'yardage': int.tryParse(_holeYardagesControllers[i].text) ?? 0,
        }),
        'par': _holeParsControllers.fold(0, (sum, c) => sum + (int.tryParse(c.text) ?? 4)),
        'slope': int.tryParse(_slopeController.text) ?? 113,
        'rating': double.tryParse(_ratingController.text) ?? 72.0,
      },
    );
  }

  void _showPreview() async {
    // We don't need to validate the whole form for preview, but let's at least construct the object
    try {
      final mockEvent = await _constructEventFromForm();
      if (!mounted) return;
      
      final config = ref.read(themeControllerProvider);

      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) {
          return EventDetailsContent(
            event: mockEvent,
            currencySymbol: config.currencySymbol,
            isPreview: true,
            onCancel: () => Navigator.pop(context),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preview Error: $e')));
    }
  }
}
