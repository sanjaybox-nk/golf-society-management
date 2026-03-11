import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/event_registration.dart';

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
      if (event.eventType == EventType.social) {
        totalCost += event.eventCost ?? 0.0;
      } else {
        if (_attendingGolf) totalCost += event.memberCost ?? 0.0;
        if (_needsBuggy) totalCost += event.buggyCost ?? 0.0;
      }
      if (_attendingBreakfast) totalCost += event.breakfastCost ?? 0.0;
      if (_attendingLunch) totalCost += event.lunchCost ?? 0.0;
      if (_attendingDinner) totalCost += event.dinnerCost ?? 0.0;

      if (_registerGuest) {
        if (event.eventType == EventType.social) {
          totalCost += event.eventCost ?? 0.0;
        } else {
          totalCost += event.guestCost ?? 0.0;
          if (_guestNeedsBuggy) totalCost += event.buggyCost ?? 0.0;
        }
        if (_guestAttendingBreakfast) totalCost += event.breakfastCost ?? 0.0;
        if (_guestAttendingLunch) totalCost += event.lunchCost ?? 0.0;
        if (_guestAttendingDinner) totalCost += event.dinnerCost ?? 0.0;
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

  double _calculateTotal(GolfEvent event) {
    double total = 0;
    if (event.eventType == EventType.social) {
      total += event.eventCost ?? 0.0;
    } else {
      if (_attendingGolf) total += event.memberCost ?? 0.0;
      if (_needsBuggy) total += event.buggyCost ?? 0.0;
    }
    if (_attendingBreakfast) total += event.breakfastCost ?? 0.0;
    if (_attendingLunch) total += event.lunchCost ?? 0.0;
    if (_attendingDinner) total += event.dinnerCost ?? 0.0;

    if (_registerGuest) {
      if (event.eventType == EventType.social) {
        total += event.eventCost ?? 0.0;
      } else {
        total += event.guestCost ?? 0.0;
        if (_guestNeedsBuggy) total += event.buggyCost ?? 0.0;
      }
      if (_guestAttendingBreakfast) total += event.breakfastCost ?? 0.0;
      if (_guestAttendingLunch) total += event.lunchCost ?? 0.0;
      if (_guestAttendingDinner) total += event.dinnerCost ?? 0.0;
    }
    return total;
  }

  String _formatPrice(double amount, WidgetRef ref) {
    final currency = ref.watch(themeControllerProvider).currencySymbol;
    return '$currency${amount.toStringAsFixed(2)}';
  }

  Widget _buildPriceBreakdownRow(BuildContext context, GolfEvent event) {
    return Column(
      children: [
        if (event.eventType == EventType.social) 
          _buildMiniCostRow('Event Entry', event.eventCost)
        else ...[
          if (_attendingGolf) _buildMiniCostRow('Member Golf', event.memberCost),
          if (_needsBuggy) _buildMiniCostRow('Buggy', event.buggyCost),
        ],
        if (_attendingBreakfast) _buildMiniCostRow('Breakfast', event.breakfastCost),
        if (_attendingLunch) _buildMiniCostRow('Lunch', event.lunchCost),
        if (_attendingDinner) _buildMiniCostRow('Dinner', event.dinnerCost),
        if (_registerGuest) ...[
          const Divider(height: AppSpacing.lg),
          if (event.eventType == EventType.social)
            _buildMiniCostRow('Guest Entry', event.eventCost, isGuest: true)
          else ...[
            _buildMiniCostRow('Guest Golf', event.guestCost, isGuest: true),
            if (_guestNeedsBuggy) _buildMiniCostRow('Guest Buggy', event.buggyCost, isGuest: true),
          ],
          if (_guestAttendingBreakfast) _buildMiniCostRow('Guest Breakfast', event.breakfastCost, isGuest: true),
          if (_guestAttendingLunch) _buildMiniCostRow('Guest Lunch', event.lunchCost, isGuest: true),
          if (_guestAttendingDinner) _buildMiniCostRow('Guest Dinner', event.dinnerCost, isGuest: true),
        ],
      ],
    );
  }

  Widget _buildMiniCostRow(String label, double? amount, {bool isGuest = false}) {
    final currency = ref.watch(themeControllerProvider).currencySymbol;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            amount == null ? 'TBA' : '$currency${amount.toStringAsFixed(2)}',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
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

        return HeadlessScaffold(
          title: 'Registration',
          subtitle: event.title,
          showBack: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BoxyArtSectionTitle(title: 'Your Attendance'),
                      const SizedBox(height: AppSpacing.md),
                      BoxyArtCard(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Column(
                          children: [
                            if (event.eventType == EventType.golf) ...[
                              BoxyArtSwitchTile(
                                icon: Icons.golf_course_rounded,
                                label: 'Playing Golf',
                                value: _attendingGolf,
                                iconColor: AppColors.lime500,
                                onChanged: (val) => setState(() => _attendingGolf = val),
                              ),
                              if (_attendingGolf)
                                BoxyArtSwitchTile(
                                  icon: Icons.electric_rickshaw_rounded,
                                  label: 'Buggy Needed',
                                  value: _needsBuggy,
                                  iconColor: AppColors.coral500,
                                  onChanged: (val) => setState(() => _needsBuggy = val),
                                ),
                            ],
                            if (event.hasBreakfast == true && event.breakfastCost != null)
                              BoxyArtSwitchTile(
                                icon: Icons.breakfast_dining_rounded,
                                label: 'Attending Breakfast',
                                subtitle: event.breakfastCost == 0 ? 'Included' : null,
                                value: _attendingBreakfast,
                                iconColor: AppColors.amber500,
                                onChanged: (val) => setState(() => _attendingBreakfast = val),
                              ),
                            if (event.hasLunch == true && event.lunchCost != null)
                              BoxyArtSwitchTile(
                                icon: Icons.lunch_dining_rounded,
                                label: 'Attending Lunch',
                                subtitle: event.lunchCost == 0 ? 'Included' : null,
                                value: _attendingLunch,
                                iconColor: AppColors.amber500,
                                onChanged: (val) => setState(() => _attendingLunch = val),
                              ),
                            if (event.hasDinner == true && event.dinnerCost != null)
                              BoxyArtSwitchTile(
                                icon: Icons.restaurant_rounded,
                                label: 'Attending Dinner',
                                subtitle: event.dinnerCost == 0 ? 'Included' : null,
                                value: _attendingDinner,
                                iconColor: AppColors.coral500,
                                onChanged: (val) => setState(() => _attendingDinner = val),
                              ),
                          ],
                        ),
                      ),
  
                      const SizedBox(height: AppSpacing.x3l),
                      const BoxyArtSectionTitle(title: 'Guest Registration'),
                      const SizedBox(height: AppSpacing.md),
                      BoxyArtCard(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Column(
                          children: [
                            BoxyArtSwitchTile(
                              icon: Icons.person_add_rounded,
                              label: 'Add a Guest',
                              value: _registerGuest,
                              iconColor: const Color(0xFF2ECC71), // Match vibrant green from design
                              onChanged: (val) => setState(() => _registerGuest = val),
                            ),
                            if (_registerGuest) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                                child: Text(
                                  'Guest Name',
                                  style: AppTypography.labelStrong.copyWith(color: AppColors.textSecondary),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                                child: BoxyArtInputField(
                                  label: '', // Empty label as we use external Text widget
                                  controller: _guestNameController,
                                  hint: 'Full name',
                                  prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.dark600),
                                  validator: (val) => _registerGuest && (val == null || val.isEmpty) ? 'Required' : null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                                child: Text(
                                  'Guest Handicap',
                                  style: AppTypography.labelStrong.copyWith(color: AppColors.textSecondary),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                                child: BoxyArtInputField(
                                  label: '', // Empty label as we use external Text widget
                                  controller: _guestHandicapController,
                                  hint: 'e.g. 18',
                                  prefixIcon: const Icon(Icons.calculate_outlined, color: AppColors.dark600),
                                ),
                              ),
                              if (event.eventType == EventType.golf)
                                BoxyArtSwitchTile(
                                  icon: Icons.electric_rickshaw_rounded,
                                  label: 'Guest Buggy',
                                  value: _guestNeedsBuggy,
                                  iconColor: const Color(0xFFFF5252), // Match red from design
                                  onChanged: (val) => setState(() => _guestNeedsBuggy = val),
                                ),
                              if (event.hasBreakfast == true && event.breakfastCost != null)
                                BoxyArtSwitchTile(
                                  icon: Icons.breakfast_dining_rounded,
                                  label: 'Guest Breakfast',
                                  value: _guestAttendingBreakfast,
                                  iconColor: const Color(0xFFFFC107), // Match yellow/amber from design
                                  onChanged: (val) => setState(() => _guestAttendingBreakfast = val),
                                ),
                              if (event.hasLunch == true && event.lunchCost != null)
                                BoxyArtSwitchTile(
                                  icon: Icons.lunch_dining_rounded,
                                  label: 'Guest Lunch',
                                  value: _guestAttendingLunch,
                                  iconColor: const Color(0xFFFF9800), 
                                  onChanged: (val) => setState(() => _guestAttendingLunch = val),
                                ),
                              if (event.hasDinner == true && event.dinnerCost != null)
                                BoxyArtSwitchTile(
                                  icon: Icons.restaurant_rounded,
                                  label: 'Guest Dinner',
                                  value: _guestAttendingDinner,
                                  iconColor: const Color(0xFF2980B9),
                                  onChanged: (val) => setState(() => _guestAttendingDinner = val),
                                ),
                            ],
                          ],
                        ),
                      ),
  
                      const SizedBox(height: AppSpacing.x3l),
                      const BoxyArtSectionTitle(title: 'Notes & Requirements'),
                      const SizedBox(height: AppSpacing.md),
                      BoxyArtCard(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                        child: Column(
                          children: [
                            BoxyArtInputField(
                              label: 'Dietary Requirements',
                              controller: _dietaryController,
                              hint: 'Allergies, preferences...',
                              prefixIcon: const Icon(Icons.set_meal_rounded),
                              maxLines: 2,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            BoxyArtInputField(
                              label: 'Other Requests',
                              controller: _specialNeedsController,
                              hint: 'Transportation, pairing requests...',
                              prefixIcon: const Icon(Icons.more_horiz_rounded),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
  
                      const SizedBox(height: AppSpacing.x3l),
                      const BoxyArtSectionTitle(title: 'Estimated Fees'),
                      const SizedBox(height: AppSpacing.md),
                      BoxyArtCard(
                        child: Column(
                          children: [
                            _buildPriceBreakdownRow(context, event),
                            const Divider(height: AppSpacing.x3l),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  Text(
                                    'Total to Pay',
                                    style: AppTypography.displayLargeBody.copyWith(
                                      fontSize: AppTypography.sizeBody,
                                    ),
                                  ),
                                Text(
                                  _formatPrice(_calculateTotal(event), ref),
                                  style: AppTypography.displaySection.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.x4l),
                      if (_isSaving)
                        const Center(child: CircularProgressIndicator())
                      else
                        BoxyArtButton(
                          title: 'Confirm Registration',
                          isPrimary: true,
                          onTap: () => _submit(event),
                        ),
                      const SizedBox(height: AppSpacing.x4l),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

