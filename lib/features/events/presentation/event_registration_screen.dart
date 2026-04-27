import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/notifications/domain/notification_broadcast_service.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';

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
  String? _partnerId;
  String? _partnerName;

  // Form fields
  bool _attendingGolf = true;
  bool _needsBuggy = false;
  bool _attendingBreakfast = false;
  bool _attendingLunch = false;
  bool _attendingDinner = false;
  bool _hasPaid = false;
  bool _useVoucher = false;
  double _availableCredit = 0.0;
  
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
      final memberRepo = ref.read(membersRepositoryProvider);
      
      final currentMember = ref.read(effectiveUserProvider);
      final memberId = currentMember.id;
      final memberName = '${currentMember.firstName} ${currentMember.lastName}';
      
      // [NEW] Resolve correct default tee based on gender
      final isFemale = currentMember.gender?.toLowerCase() == 'female';
      final defaultTee = isFemale 
          ? (event.selectedFemaleTeeName ?? event.selectedTeeName) 
          : event.selectedTeeName;

      double totalCost = 0;
      if (event.eventType == EventType.social) {
        totalCost += event.eventCost ?? 0.0;
      } else {
        if (_attendingGolf) totalCost += event.memberCost ?? 0.0;
        // Buggy cost is indicative and paid to pro shop directly, so we exclude it from totalCost
      }
      if (_attendingBreakfast) totalCost += event.breakfastCost ?? 0.0;
      if (_attendingLunch) totalCost += event.lunchCost ?? 0.0;
      if (_attendingDinner) totalCost += event.dinnerCost ?? 0.0;

      if (_registerGuest) {
        if (event.eventType == EventType.social) {
          totalCost += event.eventCost ?? 0.0;
        } else {
          totalCost += event.guestCost ?? 0.0;
          // Buggy cost is indicative and paid to pro shop directly, so we exclude it from totalCost
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
        creditApplied: 0.0, // Default, will update below
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
        partnerId: _partnerId,
        partnerName: _partnerName,
        teeName: existingReg?.teeName ?? defaultTee, // Use default if first time
        guestTeeName: existingReg?.guestTeeName ?? event.selectedTeeName, // Guest defaults to main tee
        history: [...(existingReg?.history ?? []), historyItem],
      );

      // Handle Voucher Credit Application
      EventRegistration finalRegistration = registration;
      if (_useVoucher && _availableCredit > 0) {
        final applied = totalCost > _availableCredit ? _availableCredit : totalCost;
        finalRegistration = registration.copyWith(
          creditApplied: applied,
          hasPaid: applied >= totalCost,
        );
        
        // Update Member Balance
        final allMembers = ref.read(allMembersProvider).value ?? [];
        final member = allMembers.firstWhereOrNull((m) => m.id == memberId);
        if (member != null) {
          await memberRepo.updateMember(member.copyWith(accountCredit: member.accountCredit - applied));
        }
      }
      
      if (existingIndex >= 0) {
        newList[existingIndex] = finalRegistration;
      } else {
        newList.add(finalRegistration);
      }

      final result = GroupingService.handleWithdrawal(
        event: event,
        memberId: memberId,
        isGuest: false, 
        allMembers: ref.read(allMembersProvider).value ?? [],
        useWhs: ref.read(themeControllerProvider).useWhsHandicaps,
        rules: ref.read(competitionDetailProvider(event.id)).value?.rules,
      );

      if (_attendingGolf) {
          // If they ARE still attending golf (just updating details), use standard update
          final newList = List<EventRegistration>.from(event.registrations);
          if (existingIndex >= 0) {
            newList[existingIndex] = finalRegistration;
          } else {
            newList.add(finalRegistration);
          }
          await repo.updateEvent(event.copyWith(registrations: newList));
      } else {
          // If they withdrew from golf, use the result
          await repo.updateEvent(result.event);
          
          // Broadcast Notifications
          final notificationService = ref.read(renewalNudgeServiceProvider);
          final allMembers = ref.read(allMembersProvider).value ?? [];
          
          await notificationService.notifyCommitteeOfWithdrawal(
            event: result.event, 
            playerName: result.playerName, 
            allMembers: allMembers,
          );

          if (result.promotedPlayerId != null) {
            final promotedMember = allMembers.firstWhereOrNull((m) => m.id == result.promotedPlayerId);
            if (promotedMember != null) {
              await notificationService.notifyPlayerOfPromotion(
                event: result.event, 
                member: promotedMember, 
                groupIndex: 0, 
              );
            }
          }
      }

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
      // Buggy cost is indicative and paid to pro shop directly, so we exclude it from total
    }
    if (_attendingBreakfast) total += event.breakfastCost ?? 0.0;
    if (_attendingLunch) total += event.lunchCost ?? 0.0;
    if (_attendingDinner) total += event.dinnerCost ?? 0.0;

    if (_registerGuest) {
      if (event.eventType == EventType.social) {
        total += event.eventCost ?? 0.0;
      } else {
        total += event.guestCost ?? 0.0;
        // Buggy cost is indicative and paid to pro shop directly, so we exclude it from total
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
          if (_needsBuggy) _buildMiniCostRow('Buggy (Paid to Pro Shop)', event.buggyCost),
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
            if (_guestNeedsBuggy) _buildMiniCostRow('Guest Buggy (Paid to Pro Shop)', event.buggyCost, isGuest: true),
          ],
          if (_guestAttendingBreakfast) _buildMiniCostRow('Guest Breakfast', event.breakfastCost, isGuest: true),
          if (_guestAttendingLunch) _buildMiniCostRow('Guest Lunch', event.lunchCost, isGuest: true),
          if (_guestAttendingDinner) _buildMiniCostRow('Guest Dinner', event.dinnerCost, isGuest: true),
        ],
      ],
    );
  }

  Widget _buildMiniCostRow(String label, double? amount, {bool isGuest = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = ref.watch(themeControllerProvider).currencySymbol;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.dark400,
            ),
          ),
          Text(
            amount == null ? 'TBA' : '$currency${amount.toStringAsFixed(2)}',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.dark900,
              fontWeight: AppTypography.weightBold,
            ),
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final spacing = Theme.of(context).extension<AppSpacingTokens>();
        
        if (!_isInitialized) {
          final currentMemberId = ref.read(effectiveUserProvider).id;
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
          _partnerId = myReg.partnerId;
          _partnerName = myReg.partnerName;
        }

          // Initialize available credit from member data
          final allMembers = ref.read(allMembersProvider).value ?? [];
          final member = allMembers.firstWhereOrNull((m) => m.id == currentMemberId);
          if (member != null) {
            _availableCredit = member.accountCredit;
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
                child: BoxyArtFormColumn(
                    spacing: spacing?.cardToLabel ?? AppSpacing.cardToLabel,
                    children: [
                      const BoxyArtSectionTitle(title: 'Your Attendance'),
                      BoxyArtCard(
                        child: BoxyArtFormColumn(
                          children: [
                            if (event.eventType == EventType.golf) ...[
                              BoxyArtSwitchTile(
                                icon: Icons.golf_course_rounded,
                                label: 'Playing Golf',
                                value: _attendingGolf,
                                onChanged: (val) => setState(() => _attendingGolf = val),
                              ),
                              if (_attendingGolf)
                                BoxyArtSwitchTile(
                                  icon: Icons.electric_rickshaw_rounded,
                                  label: 'Buggy Needed',
                                  value: _needsBuggy,
                                  onChanged: (val) => setState(() => _needsBuggy = val),
                                ),
                            ],
                            if (event.hasBreakfast == true && event.breakfastCost != null)
                              BoxyArtSwitchTile(
                                icon: Icons.breakfast_dining_rounded,
                                label: 'Attending Breakfast',
                                subtitle: event.breakfastCost == 0 ? 'Included' : null,
                                value: _attendingBreakfast,
                                onChanged: (val) => setState(() => _attendingBreakfast = val),
                              ),
                            if (event.hasLunch == true && event.lunchCost != null)
                              BoxyArtSwitchTile(
                                icon: Icons.lunch_dining_rounded,
                                label: 'Attending Lunch',
                                subtitle: event.lunchCost == 0 ? 'Included' : null,
                                value: _attendingLunch,
                                onChanged: (val) => setState(() => _attendingLunch = val),
                              ),
                            if (event.hasDinner == true && event.dinnerCost != null)
                              BoxyArtSwitchTile(
                                icon: Icons.restaurant_rounded,
                                label: 'Attending Dinner',
                                subtitle: event.dinnerCost == 0 ? 'Included' : null,
                                value: _attendingDinner,
                                onChanged: (val) => setState(() => _attendingDinner = val),
                              ),
                          ],
                        ),
                      ),
  
                      if (event.allowGuests)
                        BoxyArtFormColumn(
                          spacing: spacing?.cardToLabel ?? AppSpacing.cardToLabel,
                          children: [
                            const BoxyArtSectionTitle(title: 'Guest Registration'),
                            BoxyArtCard(
                              child: BoxyArtFormColumn(
                                children: [
                                  BoxyArtSwitchTile(
                                    icon: Icons.person_add_rounded,
                                    label: 'Add a Guest',
                                    value: _registerGuest,
                                    onChanged: (val) => setState(() => _registerGuest = val),
                                  ),
                                  if (_registerGuest) ...[
                                    BoxyArtFormColumn(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                          child: BoxyArtInputField(
                                            label: 'Guest Name',
                                            controller: _guestNameController,
                                            hint: 'Full name',
                                            validator: (val) => _registerGuest && (val == null || val.isEmpty) ? 'Required' : null,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                          child: BoxyArtInputField(
                                            label: 'Guest Handicap',
                                            controller: _guestHandicapController,
                                            hint: 'e.g. 18',
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (event.eventType == EventType.golf)
                                      BoxyArtSwitchTile(
                                        icon: Icons.electric_rickshaw_rounded,
                                        label: 'Guest Buggy',
                                        value: _guestNeedsBuggy,
                                        onChanged: (val) => setState(() => _guestNeedsBuggy = val),
                                      ),
                                    if (event.hasBreakfast == true && event.breakfastCost != null)
                                      BoxyArtSwitchTile(
                                        icon: Icons.breakfast_dining_rounded,
                                        label: 'Guest Breakfast',
                                        value: _guestAttendingBreakfast,
                                        onChanged: (val) => setState(() => _guestAttendingBreakfast = val),
                                      ),
                                    if (event.hasLunch == true && event.lunchCost != null)
                                      BoxyArtSwitchTile(
                                        icon: Icons.lunch_dining_rounded,
                                        label: 'Guest Lunch',
                                        value: _guestAttendingLunch,
                                        onChanged: (val) => setState(() => _guestAttendingLunch = val),
                                      ),
                                    if (event.hasDinner == true && event.dinnerCost != null)
                                      BoxyArtSwitchTile(
                                        icon: Icons.restaurant_rounded,
                                        label: 'Guest Dinner',
                                        value: _guestAttendingDinner,
                                        onChanged: (val) => setState(() => _guestAttendingDinner = val),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
  
                      BoxyArtFormColumn(
                        spacing: spacing?.cardToLabel ?? AppSpacing.cardToLabel,
                        children: [
                          const BoxyArtSectionTitle(title: 'Notes & Requirements'),
                          BoxyArtCard(
                            child: BoxyArtFormColumn(
                              children: [
                                BoxyArtInputField(
                                  label: 'Dietary Requirements',
                                  controller: _dietaryController,
                                  hint: 'Allergies, preferences...',
                                  maxLines: 2,
                                ),
                                BoxyArtInputField(
                                  label: 'Other Requests',
                                  controller: _specialNeedsController,
                                  hint: 'Transportation, pairing requests...',
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
  
                      // ── PARTNER SELECTION (Season Match Play Pairs) ────────
                      if (ref.watch(competitionDetailProvider(widget.eventId)).value?.rules.subtype == CompetitionSubtype.matchPlaySeason &&
                          ref.watch(competitionDetailProvider(widget.eventId)).value?.rules.mode == CompetitionMode.pairs)
                        BoxyArtFormColumn(
                          spacing: spacing?.cardToLabel ?? AppSpacing.cardToLabel,
                          children: [
                            const BoxyArtSectionTitle(title: 'Choose Partner'),
                            BoxyArtCard(
                              child: BoxyArtFormColumn(
                                spacing: spacing?.labelToCard ?? AppSpacing.sm,
                                children: [
                                  ref.watch(allMembersProvider).when(
                                    data: (members) {
                                      // Exclude self
                                      final currentMemberId = 'current-user-id';
                                      final availablePartners = members.where((m) => m.id != currentMemberId).toList();
                                      
                                      return BoxyArtDropdownField<String>(
                                        label: 'Select Partner (Optional)',
                                        value: _partnerId,
                                        hint: 'Choose from members...',
                                        items: [
                                          const DropdownMenuItem(value: null, child: Text('No partner selected')),
                                          ...availablePartners.map((m) => DropdownMenuItem(
                                            value: m.id,
                                            child: Text('${m.firstName} ${m.lastName}'),
                                          )),
                                        ],
                                        onChanged: (val) {
                                          setState(() {
                                            _partnerId = val;
                                            if (val != null) {
                                              final p = availablePartners.firstWhere((m) => m.id == val);
                                              _partnerName = '${p.firstName} ${p.lastName}';
                                            } else {
                                              _partnerName = null;
                                            }
                                          });
                                        },
                                      );
                                    },
                                    loading: () => const LinearProgressIndicator(),
                                    error: (_, __) => const Text('Could not load members'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                    child: Text(
                                      'If you don\'t choose a partner now, the Admin can assign one later.',
                                      style: AppTypography.micro.copyWith(
                                        color: isDark ? AppColors.dark300 : AppColors.dark400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
  
                      BoxyArtSectionTitle(
                        title: 'Estimated Fees',
                        trailing: _availableCredit > 0 
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Use Voucher (£${_availableCredit.toStringAsFixed(0)})',
                                    style: AppTypography.micro.copyWith(color: AppColors.lime500),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Switch.adaptive(
                                    value: _useVoucher,
                                    activeTrackColor: AppColors.lime500,
                                    activeThumbColor: AppColors.pureWhite,
                                    onChanged: (val) => setState(() => _useVoucher = val),
                                  ),
                                ],
                              )
                            : null,
                      ),
                      BoxyArtCard(
                        child: BoxyArtFormColumn(
                          children: [
                            _buildPriceBreakdownRow(context, event),
                            if (_useVoucher)
                               Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Voucher Credit Applied',
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.lime500),
                                  ),
                                  Text(
                                    '-${_formatPrice(_calculateTotal(event) > _availableCredit ? _availableCredit : _calculateTotal(event), ref)}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.lime500,
                                      fontWeight: AppTypography.weightBold,
                                    ),
                                  ),
                                ],
                              ),
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
                                  _formatPrice(
                                    _useVoucher 
                                      ? (_calculateTotal(event) - _availableCredit).clamp(0, double.infinity)
                                      : _calculateTotal(event), 
                                    ref
                                  ),
                                  style: AppTypography.displaySection.copyWith(
                                    color: isDark ? AppColors.lime500 : AppColors.dark900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.x2l),
                      if (_isSaving)
                        const Center(child: CircularProgressIndicator())
                      else
                        BoxyArtButton(
                          title: 'Confirm Registration',
                          fullWidth: true,
                          backgroundColor: Color(ref.read(themeControllerProvider).primaryColor),
                          textColor: ContrastHelper.getContrastingText(Color(ref.read(themeControllerProvider).primaryColor)),
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

