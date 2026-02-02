import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import '../../../events/presentation/tabs/event_user_details_tab.dart';

import '../../../events/presentation/events_provider.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/season.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/services/storage_service.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme_controller.dart';

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
  
  // Track the event being edited (either passed or fetched)
  GolfEvent? _editingEvent;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _populateForm(widget.event!);
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
    
    // Set default selected season if available in provider (handled in build via listen)
  }

  Future<void> _fetchEvent() async {
    try {
      final repo = ref.read(eventsRepositoryProvider);
      final event = await repo.getEvent(widget.eventId!);
      if (mounted) {
        if (event != null) {
          setState(() {
            _populateForm(event);
            _isLoading = false;
          });
        } else {
          // Event not found
           setState(() => _isLoading = false);
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event not found')));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading event: $e')));
      }
    }
  }

  void _populateForm(GolfEvent e) {
    _editingEvent = e;
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(eventsRepositoryProvider);
      final newEvent = await _constructEventFromForm();
      final isEditing = _editingEvent != null || widget.event != null;

      if (!isEditing) {
        await repo.addEvent(newEvent);
      } else {
        await repo.updateEvent(newEvent);
      }

      if (mounted) {
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        onPressed: _showPreview,
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.visibility, color: Colors.white),
      ),
      appBar: BoxyArtAppBar(
        title: isEditing ? 'Edit Event' : 'New Event',
        centerTitle: true,
        isLarge: true,
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => context.go('/admin/events'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 12),
            alignment: Alignment.centerLeft,
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
              ),
              child: _isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                        label: 'Event Title',
                        controller: _titleController,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      BoxyArtFormField(
                        label: 'Description',
                        controller: _descriptionController,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                const BoxyArtSectionTitle(title: 'DateTime & Registration'),
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      BoxyArtDatePickerField(
                        label: 'Event Date',
                        value: DateFormat.yMMMd().format(_selectedDate),
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 16),
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
                      SwitchListTile(
                        title: const Text('Show Registration Button'),
                        value: _showRegistrationButton,
                        onChanged: (v) => setState(() => _showRegistrationButton = v),
                        activeThumbColor: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const BoxyArtSectionTitle(title: 'Course Details'),
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      BoxyArtFormField(
                        label: 'Course Name',
                        controller: _courseNameController,
                      ),
                      const SizedBox(height: 16),
                      BoxyArtFormField(
                        label: 'Course Details',
                        controller: _courseDetailsController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      BoxyArtFormField(
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
                        hintText: 'Max players (leave empty for unlimited)',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const BoxyArtSectionTitle(title: 'Meal Options & Costs'),
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      BoxyArtSwitchField(
                        label: 'Offer Breakfast',
                        value: _hasBreakfast,
                        onChanged: (v) => setState(() => _hasBreakfast = v),
                      ),
                      if (_hasBreakfast)
                        BoxyArtFormField(
                          label: 'Breakfast Cost ($currency)',
                          controller: _breakfastCostController,
                          keyboardType: TextInputType.number,
                        ),
                      const Divider(height: 32),
                      const SizedBox(height: 12),
                      BoxyArtSwitchField(
                        label: 'Offer Lunch',
                        value: _hasLunch,
                        onChanged: (v) => setState(() => _hasLunch = v),
                      ),
                      if (_hasLunch)
                        BoxyArtFormField(
                          label: 'Lunch Cost ($currency)',
                          controller: _lunchCostController,
                          keyboardType: TextInputType.number,
                        ),
                      const Divider(height: 32),
                      const SizedBox(height: 12),
                      BoxyArtSwitchField(
                        label: 'Offer Dinner',
                        value: _hasDinner,
                        onChanged: (v) => setState(() => _hasDinner = v),
                      ),
                      if (_hasDinner)
                        BoxyArtFormField(
                          label: 'Dinner Cost ($currency)',
                          controller: _dinnerCostController,
                          keyboardType: TextInputType.number,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const BoxyArtSectionTitle(title: 'Other Costs'),
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

                const BoxyArtSectionTitle(title: 'Dinner Info'),
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
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      ..._facilitiesControllers.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: BoxyArtFormField(
                            label: 'Facility ${entry.key + 1}',
                            controller: entry.value,
                          ),
                        );
                      }),
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
      facilities: _facilitiesControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
      status: widget.event?.status ?? EventStatus.draft,
      registrations: widget.event?.registrations ?? [], // Preserve existing registrations!
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
