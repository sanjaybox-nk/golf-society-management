import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  bool _attendingBreakfast = false;
  bool _attendingLunch = false;
  bool _attendingDinner = false;
  bool _hasPaid = false;
  
  bool _registerGuest = false;
  final _guestNameController = TextEditingController();
  final _guestHandicapController = TextEditingController();
  bool _guestAttendingBreakfast = false;
  bool _guestAttendingLunch = false;
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
      const memberId = 'current-user-id';
      const memberName = 'Current Member';

      double totalCost = 0;
      if (_attendingGolf) totalCost += event.memberCost ?? 0.0;
      if (_attendingBreakfast) totalCost += event.breakfastCost ?? 0.0;
      if (_attendingLunch) totalCost += event.lunchCost ?? 0.0;
      if (_attendingDinner) totalCost += event.dinnerCost ?? 0.0;
      if (_needsBuggy) totalCost += event.buggyCost ?? 0.0;

      if (_registerGuest) {
        totalCost += event.guestCost ?? 0.0;
        if (_guestAttendingBreakfast) totalCost += event.breakfastCost ?? 0.0;
        if (_guestAttendingLunch) totalCost += event.lunchCost ?? 0.0;
        if (_guestAttendingDinner) totalCost += event.dinnerCost ?? 0.0;
        if (_guestNeedsBuggy) totalCost += event.buggyCost ?? 0.0;
      }

      final newList = List<EventRegistration>.from(event.registrations);
      final existingIndex = newList.indexWhere((r) => r.memberId == memberId);
      final existingReg = existingIndex >= 0 ? newList[existingIndex] : null;

      final historyItem = RegistrationHistoryItem(
        timestamp: DateTime.now(),
        action: existingReg == null ? 'Registered' : 'Updated Details',
        description: existingReg == null ? 'Initial registration' : 'Member updated their registration details',
        actor: memberName,
      );

      final registration = EventRegistration(
        memberId: memberId,
        memberName: memberName,
        attendingGolf: _attendingGolf,
        needsBuggy: _needsBuggy,
        attendingBreakfast: _attendingBreakfast,
        attendingLunch: _attendingLunch,
        attendingDinner: _attendingDinner,
        hasPaid: _hasPaid,
        cost: totalCost,
        dietaryRequirements: _dietaryController.text.trim(),
        specialNeeds: _specialNeedsController.text.trim(),
        guestName: _registerGuest ? _guestNameController.text.trim() : null,
        guestHandicap: _registerGuest ? _guestHandicapController.text.trim() : null,
        guestAttendingBreakfast: _registerGuest && _guestAttendingBreakfast,
        guestAttendingLunch: _registerGuest && _guestAttendingLunch,
        guestAttendingDinner: _registerGuest && _guestAttendingDinner,
        guestNeedsBuggy: _registerGuest && _guestNeedsBuggy,
        registeredAt: existingReg?.registeredAt ?? DateTime.now(), // Preserve original time if updating
        isConfirmed: existingReg?.isConfirmed ?? false, // Preserve status
        guestIsConfirmed: existingReg?.guestIsConfirmed ?? false,
        statusOverride: existingReg?.statusOverride,
        buggyStatusOverride: existingReg?.buggyStatusOverride,
        guestBuggyStatusOverride: existingReg?.guestBuggyStatusOverride,
        history: [...(existingReg?.history ?? []), historyItem],
      );
      
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
        
        if (!_isInitialized) {
          const currentMemberId = 'current-user-id';
          final myReg = event.registrations.where((r) => r.memberId == currentMemberId).firstOrNull;
          
          if (myReg != null) {
            _attendingGolf = myReg.attendingGolf;
            _needsBuggy = myReg.needsBuggy;
            _attendingBreakfast = myReg.attendingBreakfast;
            _attendingLunch = myReg.attendingLunch;
            _attendingDinner = myReg.attendingDinner;
            _hasPaid = myReg.hasPaid;
            
            if (myReg.guestName != null) {
              _registerGuest = true;
              _guestNameController.text = myReg.guestName!;
              _guestHandicapController.text = myReg.guestHandicap ?? '';
              _guestAttendingBreakfast = myReg.guestAttendingBreakfast;
              _guestAttendingLunch = myReg.guestAttendingLunch;
              _guestAttendingDinner = myReg.guestAttendingDinner;
              _guestNeedsBuggy = myReg.guestNeedsBuggy;
            }
            
            _dietaryController.text = myReg.dietaryRequirements ?? '';
            _specialNeedsController.text = myReg.specialNeeds ?? '';
          }
          _isInitialized = true;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          'Registration',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BoxyArtSectionTitle(title: 'Your Attendance'),
                              const SizedBox(height: 12),
                              ModernCard(
                                child: Column(
                                  children: [
                                    _buildModernSwitchRow(
                                      context,
                                      'Playing Golf',
                                      _attendingGolf,
                                      (val) => setState(() => _attendingGolf = val),
                                      icon: Icons.golf_course_rounded,
                                    ),
                                    if (_attendingGolf) ...[
                                      const Divider(height: 24),
                                      _buildModernSwitchRow(
                                        context,
                                        'Buggy Needed',
                                        _needsBuggy,
                                        (val) => setState(() => _needsBuggy = val),
                                        icon: Icons.electric_rickshaw_rounded,
                                      ),
                                    ],
                                    if (event.hasBreakfast == true && event.breakfastCost != null) ...[
                                      const Divider(height: 24),
                                      _buildModernSwitchRow(
                                        context,
                                        'Attending Breakfast',
                                        _attendingBreakfast,
                                        (val) => setState(() => _attendingBreakfast = val),
                                        subtitle: event.breakfastCost == 0 ? 'Included' : null,
                                        icon: Icons.breakfast_dining_rounded,
                                      ),
                                    ],
                                    if (event.hasLunch == true && event.lunchCost != null) ...[
                                      const Divider(height: 24),
                                      _buildModernSwitchRow(
                                        context,
                                        'Attending Lunch',
                                        _attendingLunch,
                                        (val) => setState(() => _attendingLunch = val),
                                        subtitle: event.lunchCost == 0 ? 'Included' : null,
                                        icon: Icons.lunch_dining_rounded,
                                      ),
                                    ],
                                    if (event.hasDinner == true && event.dinnerCost != null) ...[
                                      const Divider(height: 24),
                                      _buildModernSwitchRow(
                                        context,
                                        'Attending Dinner',
                                        _attendingDinner,
                                        (val) => setState(() => _attendingDinner = val),
                                        subtitle: event.dinnerCost == 0 ? 'Included' : null,
                                        icon: Icons.restaurant_rounded,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
          
                              const SizedBox(height: 32),
                              const BoxyArtSectionTitle(title: 'Guest Registration'),
                              const SizedBox(height: 12),
                              ModernCard(
                                child: Column(
                                  children: [
                                    _buildModernSwitchRow(
                                      context,
                                      'Add a Guest',
                                      _registerGuest,
                                      (val) => setState(() => _registerGuest = val),
                                      icon: Icons.person_add_rounded,
                                    ),
                                    if (_registerGuest) ...[
                                      const SizedBox(height: 24),
                                      _buildModernTextField(
                                        label: 'Guest Name',
                                        controller: _guestNameController,
                                        hintText: 'Full name',
                                        icon: Icons.badge_outlined,
                                        validator: (val) => _registerGuest && (val == null || val.isEmpty) ? 'Required' : null,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildModernTextField(
                                        label: 'Guest Handicap',
                                        controller: _guestHandicapController,
                                        hintText: 'e.g. 18',
                                        icon: Icons.calculate_outlined,
                                      ),
                                      const Divider(height: 48),
                                      _buildModernSwitchRow(
                                        context,
                                        'Guest Buggy',
                                        _guestNeedsBuggy,
                                        (val) => setState(() => _guestNeedsBuggy = val),
                                        icon: Icons.electric_rickshaw_rounded,
                                      ),
                                      if (event.hasBreakfast == true && event.breakfastCost != null) ...[
                                        const Divider(height: 24),
                                        _buildModernSwitchRow(
                                          context,
                                          'Guest Breakfast',
                                          _guestAttendingBreakfast,
                                          (val) => setState(() => _guestAttendingBreakfast = val),
                                          icon: Icons.breakfast_dining_rounded,
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
          
                              const SizedBox(height: 32),
                              const BoxyArtSectionTitle(title: 'Notes & Requirements'),
                              const SizedBox(height: 12),
                              ModernCard(
                                child: Column(
                                  children: [
                                    _buildModernTextField(
                                      label: 'Dietary Requirements',
                                      controller: _dietaryController,
                                      hintText: 'Allergies, preferences...',
                                      icon: Icons.set_meal_rounded,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildModernTextField(
                                      label: 'Other Requests',
                                      controller: _specialNeedsController,
                                      hintText: 'Transportation, pairing requests...',
                                      icon: Icons.more_horiz_rounded,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
          
                              const SizedBox(height: 40),
                              if (_isSaving)
                                const Center(child: CircularProgressIndicator())
                              else
                                BoxyArtButton(
                                  title: 'Confirm Registration',
                                  isPrimary: true,
                                  onTap: () => _submit(event),
                                ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
              
              // Back Button top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
                            onPressed: () => context.pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildModernSwitchRow(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    String? subtitle,
    IconData? icon,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    IconData? icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
