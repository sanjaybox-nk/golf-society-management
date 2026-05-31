import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/notification.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/home/presentation/home_providers.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:intl/intl.dart';

/// Bottom sheet for controlling event registration visibility.
///
/// Three modes:
///   Open      — showRegistrationButton: true, targetedRegistrationIds: []
///   Targeted  — showRegistrationButton: false, targetedRegistrationIds: [...]
///   Closed    — showRegistrationButton: false, targetedRegistrationIds: []
class RegistrationControlSheet extends ConsumerStatefulWidget {
  final GolfEvent event;

  const RegistrationControlSheet({super.key, required this.event});

  static Future<void> show(BuildContext context, GolfEvent event) {
    return BoxyArtBottomSheet.show(
      context: context,
      title: 'Registration Access',
      addNavBarPadding: true,
      child: RegistrationControlSheet(event: event),
    );
  }

  @override
  ConsumerState<RegistrationControlSheet> createState() => _RegistrationControlSheetState();
}

class _RegistrationControlSheetState extends ConsumerState<RegistrationControlSheet> {
  late _Mode _mode;
  late List<String> _selectedIds;
  String _search = '';

  @override
  void initState() {
    super.initState();
    if (widget.event.showRegistrationButton) {
      _mode = _Mode.open;
    } else if (widget.event.targetedRegistrationIds.isNotEmpty) {
      _mode = _Mode.targeted;
    } else {
      _mode = _Mode.closed;
    }
    _selectedIds = List<String>.from(widget.event.targetedRegistrationIds);
  }

  Future<void> _save() async {
    final repo = ref.read(eventsRepositoryProvider);
    switch (_mode) {
      case _Mode.open:
        await repo.updateEvent(widget.event.copyWith(
          showRegistrationButton: true,
          targetedRegistrationIds: [],
        ));
      case _Mode.targeted:
        await repo.updateEvent(widget.event.copyWith(
          showRegistrationButton: false,
          targetedRegistrationIds: _selectedIds,
        ));
        await _notifyNewlyTargeted();
      case _Mode.closed:
        await repo.updateEvent(widget.event.copyWith(
          showRegistrationButton: false,
          targetedRegistrationIds: [],
        ));
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _notifyNewlyTargeted() async {
    final previousIds = widget.event.targetedRegistrationIds.toSet();
    final newlyAdded = _selectedIds.where((id) => !previousIds.contains(id)).toList();
    if (newlyAdded.isEmpty) return;

    final notifRepo = ref.read(notificationsRepositoryProvider);
    final deadline = widget.event.registrationDeadline;
    final deadlineText = deadline != null
        ? 'Registration closes on ${DateFormat('d MMM').format(deadline)}.'
        : 'Registration will close in 3 days.';

    for (final memberId in newlyAdded) {
      await notifRepo.sendNotification(AppNotification(
        id: '',
        recipientId: memberId,
        title: 'Registration Opened for You',
        message: 'Registration for ${widget.event.title} has been opened for you. $deadlineText',
        timestamp: DateTime.now(),
        category: 'Registration',
        eventId: widget.event.id,
        actionUrl: '/events/${widget.event.id}',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(allMembersProvider).value ?? [];
    final registered = widget.event.registrations.map((r) => r.memberId).toSet();
    final selectedMembers = members.where((m) => _selectedIds.contains(m.id)).toList();
    final searchResults = _search.isEmpty
        ? <Member>[]
        : members
            .where((m) => !registered.contains(m.id) && !_selectedIds.contains(m.id))
            .where((m) => m.displayName.toLowerCase().contains(_search.toLowerCase()))
            .toList()
          ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode selector
        BoxyArtSelectCard(
          icon: Icons.public_rounded,
          label: 'Open to all members',
          description: 'Registration button visible on the member home screen.',
          isSelected: _mode == _Mode.open,
          onTap: () => setState(() { _mode = _Mode.open; _selectedIds = []; }),
        ),
        BoxyArtSelectCard(
          icon: Icons.people_outline_rounded,
          label: 'Selected members only',
          description: 'Only the members you choose below can see the registration button.',
          isSelected: _mode == _Mode.targeted,
          onTap: () => setState(() => _mode = _Mode.targeted),
        ),
        BoxyArtSelectCard(
          icon: Icons.lock_outline_rounded,
          label: 'Closed',
          description: 'Registration button hidden from all members.',
          isSelected: _mode == _Mode.closed,
          onTap: () => setState(() { _mode = _Mode.closed; _selectedIds = []; }),
        ),

        // Member picker — shown only in targeted mode
        if (_mode == _Mode.targeted) ...[
          const SizedBox(height: AppSpacing.standard),

          // Selected members summary
          if (selectedMembers.isNotEmpty) ...[
            BoxyArtCard(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: selectedMembers.asMap().entries.map((entry) {
                  final m = entry.value;
                  final isLast = entry.key == selectedMembers.length - 1;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MemberRow(
                        member: m,
                        isSelected: true,
                        onTap: () => setState(() => _selectedIds.remove(m.id)),
                      ),
                      if (!isLast) const BoxyArtDivider(),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.atomic),
          ],

          BoxyArtSearchInput(
            hintText: 'Search to add members…',
            onChanged: (v) => setState(() => _search = v),
          ),

          // Search results — only when typing
          if (_search.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.atomic),
            if (searchResults.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.standard),
                child: Center(
                  child: Text(
                    'No members found',
                    style: AppTypography.label.copyWith(color: AppColors.dark400),
                  ),
                ),
              )
            else
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: searchResults.asMap().entries.map((entry) {
                      final m = entry.value;
                      final isLast = entry.key == searchResults.length - 1;
                      final isSelected = _selectedIds.contains(m.id);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MemberRow(
                            member: m,
                            isSelected: isSelected,
                            onTap: () => setState(() {
                              if (isSelected) {
                                _selectedIds.remove(m.id);
                              } else {
                                _selectedIds.add(m.id);
                              }
                            }),
                          ),
                          if (!isLast) const BoxyArtDivider(),
                        ],
                      );
                    }).toList(),
                ),
              ),
          ],
        ],

        const SizedBox(height: AppSpacing.standard),
        BoxyArtButton(
          title: 'Save',
          icon: Icons.check_rounded,
          fullWidth: true,
          onTap: _save,
        ),
      ],
    );
  }
}

enum _Mode { open, targeted, closed }

class _MemberRow extends StatelessWidget {
  final Member member;
  final bool isSelected;
  final VoidCallback onTap;

  const _MemberRow({
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.standard,
          vertical: AppSpacing.atomic,
        ),
        child: Row(
          children: [
            BoxyArtAvatar(
              url: member.avatarUrl,
              initials: '${member.firstName[0]}${member.lastName[0]}',
              radius: 20,
              isCircle: true,
            ),
            const SizedBox(width: AppSpacing.standard),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.displayName, style: AppTypography.body.copyWith(fontWeight: AppTypography.weightStrong)),
                  Text('HC: ${member.handicap}', style: AppTypography.label.copyWith(color: AppColors.dark400)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: AppShapes.iconSm)
            else
              Icon(Icons.circle_outlined, color: AppColors.dark300, size: AppShapes.iconSm),
          ],
        ),
      ),
    );
  }
}
