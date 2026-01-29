import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';

import '../../../events/presentation/events_provider.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/season.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/services/storage_service.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  final GolfEvent? event; // Null = New Event

  const EventFormScreen({super.key, this.event});

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
  late TextEditingController _dinnerCostController;
  late TextEditingController _dinnerLocationController;
  late TextEditingController _intervalController;
  
  late List<NoteItemController> _notesControllers;
  late List<TextEditingController> _facilitiesControllers;
  
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TimeOfDay _registrationTime;
  
  late DateTime? _deadlineDate;
  late TimeOfDay? _deadlineTime;
  
  bool _showRegistrationButton = true;
  bool _isSaving = false;
  String? _selectedSeasonId;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    
    _courseNameController = TextEditingController(text: e?.courseName ?? '');
    _courseDetailsController = TextEditingController(text: e?.courseDetails ?? '');
    _dressCodeController = TextEditingController(text: e?.dressCode ?? '');
    _buggiesController = TextEditingController(text: e?.availableBuggies?.toString() ?? '');
    _maxParticipantsController = TextEditingController(text: e?.maxParticipants?.toString() ?? '');
    _memberCostController = TextEditingController(text: e?.memberCost?.toString() ?? '');
    _guestCostController = TextEditingController(text: e?.guestCost?.toString() ?? '');
    _dinnerCostController = TextEditingController(text: e?.dinnerCost?.toString() ?? '');
    _dinnerLocationController = TextEditingController(text: e?.dinnerLocation ?? '');
    _intervalController = TextEditingController(text: e?.teeOffInterval.toString() ?? '10');
    
    _notesControllers = (e?.notes ?? []).map((n) => NoteItemController(
      title: n.title,
      content: n.content,
      imageUrl: n.imageUrl,
    )).toList();
    
    _facilitiesControllers = (e?.facilities ?? []).map((f) => TextEditingController(text: f)).toList();
    if (_facilitiesControllers.isEmpty) _facilitiesControllers.add(TextEditingController());

    _selectedDate = e?.date ?? DateTime.now().add(const Duration(days: 1));
    _selectedTime = TimeOfDay.fromDateTime(e?.teeOffTime ?? DateTime.now().add(const Duration(hours: 9)));
    _registrationTime = TimeOfDay.fromDateTime(e?.regTime ?? DateTime.now().add(const Duration(hours: 8, minutes: 30)));
    _deadlineDate = e?.registrationDeadline;
    _deadlineTime = e?.registrationDeadline != null ? TimeOfDay.fromDateTime(e!.registrationDeadline!) : null;
    _showRegistrationButton = e?.showRegistrationButton ?? true;
    _selectedSeasonId = e?.seasonId;
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
    _dinnerCostController.dispose();
    _dinnerLocationController.dispose();
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
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isTeeOff}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isTeeOff ? _selectedTime : _registrationTime,
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

      final newEvent = GolfEvent(
        id: widget.event?.id ?? '', 
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
        dinnerCost: double.tryParse(_dinnerCostController.text),
        dinnerLocation: _dinnerLocationController.text.trim(),
        teeOffInterval: int.tryParse(_intervalController.text) ?? 10,
        showRegistrationButton: _showRegistrationButton,
        notes: finalizeNotes,
        facilities: _facilitiesControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
        status: widget.event?.status ?? EventStatus.draft,
      );

      if (widget.event == null) {
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
    if (_selectedSeasonId == null) {
      final activeSeason = ref.watch(activeSeasonProvider).value;
      if (activeSeason != null) {
        _selectedSeasonId = activeSeason.id;
      }
    }

    final isEditing = widget.event != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: BoxyArtAppBar(
        title: isEditing ? 'Edit Event' : 'New Event',
        showBack: true,
        onBack: () => context.go('/admin/events'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF233D5E), // Premium dark blue
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

                _buildSectionTitle('Basic Info'),
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
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle('DateTime & Registration'),
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

                _buildSectionTitle('Course Details'),
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
                      BoxyArtFormField(
                        label: 'Available Buggies',
                        controller: _buggiesController,
                        keyboardType: TextInputType.number,
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

                _buildSectionTitle('Costs'),
                BoxyArtFloatingCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: BoxyArtFormField(
                              label: 'Member Cost (£)',
                              controller: _memberCostController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: BoxyArtFormField(
                              label: 'Guest Cost (£)',
                              controller: _guestCostController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BoxyArtFormField(
                        label: 'Dinner Cost (£)',
                        controller: _dinnerCostController,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('Dinner Info'),
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

                _buildSectionTitle('Facilities'),
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

                _buildSectionTitle('Notes & Content'),
                ..._notesControllers.asMap().entries.map((entry) {
                   return _buildRichNoteItem(entry.key, entry.value);
                }),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: BoxyArtButton(
                        title: 'Add Note',
                        onTap: _addNote,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BoxyArtButton(
                        title: 'Add Photo',
                        onTap: _addNoteWithPhoto,
                        isGhost: true,
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
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(note.imageUrl!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
              height: 150,
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
                  expands: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }
}
