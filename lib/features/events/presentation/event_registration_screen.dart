import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/boxy_art_widgets.dart';
import '../../../models/golf_event.dart';
import '../../../models/event_registration.dart';
import 'events_provider.dart';

class EventRegistrationScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventRegistrationScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventRegistrationScreen> createState() => _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends ConsumerState<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isInitialized = false;

  // Form fields
  bool _attendingGolf = true;
  bool _needsBuggy = false;
  bool _attendingDinner = false;
  bool _hasPaid = false;
  
  bool _registerGuest = false;
  final _guestNameController = TextEditingController();
  final _guestHandicapController = TextEditingController();
  bool _guestAttendingDinner = false;
  bool _guestNeedsBuggy = false;


  final _dietaryController = TextEditingController();
  final _specialNeedsController = TextEditingController();

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestHandicapController.dispose();
    _dietaryController.dispose();
    _specialNeedsController.dispose();
    super.dispose();
  }

  Future<void> _submit(GolfEvent event) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(eventsRepositoryProvider);
      
      // For now, we'll assume the user is a mock member or we'd get their ID from auth
      // In a real app, we'd use ref.read(authProvider).user.id
      const memberId = 'current-user-id';
      const memberName = 'Current Member';

      final registration = EventRegistration(
        memberId: memberId,
        memberName: memberName,
        attendingGolf: _attendingGolf,
        needsBuggy: _needsBuggy,
        attendingDinner: _attendingDinner,
        hasPaid: _hasPaid,
        dietaryRequirements: _dietaryController.text.trim(),
        specialNeeds: _specialNeedsController.text.trim(),
        guestName: _registerGuest ? _guestNameController.text.trim() : null,
        guestHandicap: _registerGuest ? _guestHandicapController.text.trim() : null,
        guestAttendingDinner: _registerGuest && _guestAttendingDinner,
        guestNeedsBuggy: _registerGuest && _guestNeedsBuggy,
        registeredAt: DateTime.now(),
      );

      // Create a new list with this registration
      // If the member already registered, we should probably update it instead of adding
      final newList = List<EventRegistration>.from(event.registrations);
      final existingIndex = newList.indexWhere((r) => r.memberId == memberId);
      
      if (existingIndex >= 0) {
        newList[existingIndex] = registration;
      } else {
        newList.add(registration);
      }

      final updatedEvent = event.copyWith(registrations: newList);
      await repo.updateEvent(updatedEvent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider);
    
    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == widget.eventId, orElse: () => throw 'Event not found');
        
        // Initialize with existing registration data if not already done
        if (!_isInitialized) {
          const currentMemberId = 'current-user-id';
          final myReg = event.registrations.where((r) => r.memberId == currentMemberId).firstOrNull;
          
          if (myReg != null) {
            _attendingGolf = myReg.attendingGolf;
            _needsBuggy = myReg.needsBuggy;
            _attendingDinner = myReg.attendingDinner;
            _hasPaid = myReg.hasPaid;
            
            if (myReg.guestName != null) {
              _registerGuest = true;
              _guestNameController.text = myReg.guestName!;
              _guestHandicapController.text = myReg.guestHandicap ?? '';
              _guestAttendingDinner = myReg.guestAttendingDinner;
              _guestNeedsBuggy = myReg.guestNeedsBuggy;
            }
            
            _dietaryController.text = myReg.dietaryRequirements ?? '';
            _specialNeedsController.text = myReg.specialNeeds ?? '';
          }
          _isInitialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Register for Event'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSectionTitle('Your Attendance'),
                   BoxyArtFloatingCard(
                     child: Column(
                       children: [
                         _buildSwitchTile(
                           'I am playing golf', 
                           _attendingGolf, 
                           (val) => setState(() => _attendingGolf = val),
                         ),
                         if (_attendingGolf) ...[
                           _buildSwitchTile(
                             'I need a buggy', 
                             _needsBuggy, 
                             (val) => setState(() => _needsBuggy = val),
                           ),
                         ],
                         _buildSwitchTile(
                           'I will attend dinner', 
                           _attendingDinner, 
                           (val) => setState(() => _attendingDinner = val),
                         ),
                         _buildSwitchTile(
                           'I have paid', 
                           _hasPaid, 
                           (val) => setState(() => _hasPaid = val),
                         ),
                       ],
                     ),
                   ),

                   const SizedBox(height: 24),
                   _buildSectionTitle('Guest Registration'),
                   BoxyArtFloatingCard(
                     child: Column(
                       children: [
                         _buildSwitchTile(
                           'Register a guest', 
                           _registerGuest, 
                           (val) => setState(() => _registerGuest = val),
                         ),
                         if (_registerGuest) ...[
                           const Padding(
                             padding: EdgeInsets.symmetric(vertical: 8.0),
                             child: Divider(),
                           ),
                            _buildTextFieldWithLabel(
                              label: 'Guest Name',
                              controller: _guestNameController,
                              hintText: 'Enter guest full name',
                              validator: (val) => _registerGuest && (val == null || val.isEmpty) ? 'Please enter guest name' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldWithLabel(
                              label: 'Guest Handicap',
                              controller: _guestHandicapController,
                              hintText: 'e.g. 18',
                            ),
                            const SizedBox(height: 8),
                            _buildSwitchTile(
                              'Guest will attend dinner', 
                              _guestAttendingDinner, 
                              (val) => setState(() => _guestAttendingDinner = val),
                            ),
                            _buildSwitchTile(
                              'Guest needs a buggy', 
                              _guestNeedsBuggy, 
                              (val) => setState(() => _guestNeedsBuggy = val),
                            ),
                          ],
                       ],
                     ),
                   ),

                   const SizedBox(height: 24),
                   _buildSectionTitle('Additional Information'),
                   BoxyArtFloatingCard(
                     child: Column(
                       children: [
                          _buildTextFieldWithLabel(
                            label: 'Dietary Requirements',
                            controller: _dietaryController,
                            hintText: 'Any allergies or preferences',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFieldWithLabel(
                            label: 'Special Needs',
                            controller: _specialNeedsController,
                            hintText: 'Anything else we should know?',
                            maxLines: 2,
                          ),
                       ],
                     ),
                   ),

                   const SizedBox(height: 32),
                   if (_isSaving)
                     const Center(child: CircularProgressIndicator())
                   else
                     BoxyArtButton(
                       title: 'Submit Registration',
                       onTap: () => _submit(event),
                     ),
                   const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
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

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeThumbColor: Theme.of(context).primaryColor,
      activeTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
    );
  }

  Widget _buildTextFieldWithLabel({
    required String label,
    required TextEditingController controller,
    String? hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
