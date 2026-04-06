import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';

class EventFinesWorkbenchScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventFinesWorkbenchScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventFinesWorkbenchScreen> createState() => _EventFinesWorkbenchScreenState();
}

class _EventFinesWorkbenchScreenState extends ConsumerState<EventFinesWorkbenchScreen> {
  late TextEditingController _charityController;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, TextEditingController> _controllers = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _charityController = TextEditingController();
  }

  @override
  void dispose() {
    _charityController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addFine(GolfEvent event, EventRegistration reg, double addAmount, String reason) {
    if (addAmount <= 0) return;
    
    final newList = List<EventRegistration>.from(event.registrations);
    final idx = newList.indexWhere((r) => r.memberId == reg.memberId);
    if (idx >= 0) {
      final newFine = EventFine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: addAmount,
        reason: reason,
        timestamp: DateTime.now(),
      );
      final updatedFines = List<EventFine>.from(reg.fines)..add(newFine);

      newList[idx] = reg.copyWith(
        fineAmount: reg.fineAmount + addAmount,
        fines: updatedFines,
      );
      ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(registrations: newList));
    }
  }

  void _showIssueFineModal(BuildContext context, GolfEvent event, EventRegistration reg) {
    String reason = '';
    String amountStr = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Use branch navigator so the global bottom nav bar stays visible behind the sheet.
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rXl)),
            ),
            padding: const EdgeInsets.all(AppSpacing.hero),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Issue Fine for ${reg.memberName}', style: AppTypography.displayLocker),
                const SizedBox(height: AppSpacing.x2l),
                BoxyArtInputField(
                  label: 'Amount',
                  hint: '£0.00',
                  keyboardType: TextInputType.number,
                  onChanged: (val) => amountStr = val,
                ),
                const SizedBox(height: AppSpacing.xl),
                BoxyArtInputField(
                  label: 'Reason',
                  hint: 'e.g. Late on tee, Lost ball',
                  onChanged: (val) => reason = val,
                ),
                const SizedBox(height: AppSpacing.x3l),
                SizedBox(
                  width: double.infinity,
                  child: BoxyArtButton(
                    title: 'Save fine',
                    onTap: () {
                      final amount = double.tryParse(amountStr) ?? 0.0;
                      if (amount > 0 && reason.trim().isNotEmpty) {
                        _addFine(event, reg, amount, reason.trim());
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateCharity(GolfEvent event, double amount) {
    ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(charityPot: amount));
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));

    return eventAsync.when(
      data: (event) {
        final membersAsync = ref.watch(allMembersProvider);
        if (_charityController.text.isEmpty && event.charityPot > 0) {
          _charityController.text = event.charityPot.toStringAsFixed(0);
        }

        final allPlayers = event.registrations
            .where((r) => r.statusOverride == 'confirmed' || (r.isConfirmed && r.statusOverride == null))
            .toList();
            
        final players = _searchQuery.isEmpty 
            ? allPlayers 
            : allPlayers.where((p) => p.displayName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        return HeadlessScaffold(
          title: 'Fine Workbench',
          subtitle: event.title,
          showBack: true,
          onBack: () => context.pop(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: BoxyArtInputField(
                      controller: _searchController,
                      label: '',
                      hint: 'Search members...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),

                  const BoxyArtSectionTitle(title: 'Individual member fines'),
                  BoxyArtCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        if (players.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Text('No members found matching search.', 
                              style: TextStyle(color: AppColors.textSecondary)),
                          ),
                        ...players.asMap().entries.map((entry) {
                          final reg = entry.value;
                          final isLast = entry.key == players.length - 1;
                          final member = membersAsync.value?.where((m) => m.id == reg.memberId).firstOrNull;
                          
                          _controllers[reg.memberId] ??= TextEditingController();

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppColors.dark500.withOpacity(0.1),
                                      backgroundImage: member?.avatarUrl != null && member!.avatarUrl!.isNotEmpty 
                                          ? NetworkImage(member.avatarUrl!) 
                                          : null,
                                      child: (member?.avatarUrl == null || member!.avatarUrl!.isEmpty)
                                          ? Text(
                                              reg.memberName.isNotEmpty ? reg.memberName[0].toUpperCase() : '?',
                                              style: const TextStyle(
                                                fontWeight: AppTypography.weightBold, 
                                                color: AppColors.dark400,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reg.memberName,
                                            style: AppTypography.body.copyWith(
                                              color: Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark900,
                                              fontWeight: AppTypography.weightBold,
                                              fontSize: AppTypography.sizeBody,
                                              letterSpacing: -0.4,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (reg.isGuest)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text('Guest', 
                                                style: AppTypography.micro.copyWith(color: AppColors.textSecondary)),
                                            ),
                                          if (reg.fines.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: AppSpacing.md),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ...reg.fines.map((f) => Text('• £${f.amount.toStringAsFixed(0)} - ${f.reason}', 
                                                    style: AppTypography.micro.copyWith(
                                                      color: AppColors.coral500, 
                                                      fontWeight: AppTypography.weightHeavy,
                                                      letterSpacing: AppTypography.lsMicro,
                                                    )
                                                  )),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    BoxyArtButton(
                                      title: 'Fine',
                                      icon: Icons.add_rounded,
                                      isSmall: true,
                                      isPrimary: true,
                                      onTap: () => _showIssueFineModal(context, event, reg),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast) const BoxyArtDivider(),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  const BoxyArtSectionTitle(title: 'Event collections'),
                  BoxyArtCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const BoxyArtIconBadge(
                              icon: Icons.favorite_rounded,
                              color: AppColors.guestPurple,
                              isTinted: true,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Charity pot collection', 
                                    style: AppTypography.body.copyWith(
                                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark900,
                                      fontWeight: AppTypography.weightBold,
                                      fontSize: AppTypography.sizeBody,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  Text(
                                    'General loose change / bucket collection', 
                                    style: AppTypography.label.copyWith(color: AppColors.dark300),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _charityController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  prefixText: '£',
                                  hintText: '0.00',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (v) {
                                  final amount = double.tryParse(v) ?? 0.0;
                                  _updateCharity(event, amount);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.hero),
                ]),
              ),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(title: 'Loading...', slivers: []),
      error: (err, st) => HeadlessScaffold(title: 'Error', slivers: [SliverFillRemaining(child: Center(child: Text(err.toString())))]),
    );
  }
}
