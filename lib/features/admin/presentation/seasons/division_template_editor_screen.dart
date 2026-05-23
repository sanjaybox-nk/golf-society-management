import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member_group_config.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/groups/member_group_helper.dart';
import 'package:golf_society/features/admin/data/member_group_config_repository.dart';
import '../../../members/presentation/members_provider.dart';

class DivisionTemplateEditorScreen extends ConsumerStatefulWidget {
  final MemberGroupConfig config;
  final bool isNew;
  final bool isInUse;

  const DivisionTemplateEditorScreen({
    super.key,
    required this.config,
    required this.isNew,
    this.isInUse = false,
  });

  @override
  ConsumerState<DivisionTemplateEditorScreen> createState() =>
      _DivisionTemplateEditorScreenState();
}

class _DivisionTemplateEditorScreenState
    extends ConsumerState<DivisionTemplateEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _thresholdController;
  late TextEditingController _searchController;
  late GroupSplitType _splitType;
  late List<MemberGroup> _groups;
  late List<TextEditingController> _groupNameControllers;
  late List<String> _voluntaryIds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.config.name);
    _thresholdController = TextEditingController(
      text: widget.config.handicapThreshold?.toString() ?? '12.0',
    );
    _searchController = TextEditingController();
    _splitType = widget.config.splitType;
    _groups = widget.config.groups.isEmpty
        ? _defaultGroups(widget.config.splitType)
        : List.from(widget.config.groups);
    _voluntaryIds = List.from(widget.config.voluntaryFirstGroupMemberIds);
    _groupNameControllers = _groups
        .map((g) => TextEditingController(text: g.name))
        .toList();
  }

  List<MemberGroup> _defaultGroups(GroupSplitType type) {
    switch (type) {
      case GroupSplitType.handicap:
        return [
          const MemberGroup(id: 'group_a', name: 'Division 1'),
          const MemberGroup(id: 'group_b', name: 'Division 2'),
        ];
      case GroupSplitType.gender:
        return [
          const MemberGroup(id: 'male', name: 'Male'),
          const MemberGroup(id: 'female', name: 'Female'),
        ];
      case GroupSplitType.custom:
        return [
          const MemberGroup(id: 'group_a', name: 'Group A'),
          const MemberGroup(id: 'group_b', name: 'Group B'),
        ];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _thresholdController.dispose();
    _searchController.dispose();
    for (final c in _groupNameControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final hPad = spacing?.cardHorizontalPadding ?? AppSpacing.xl;

    return HeadlessScaffold(
      title: widget.isNew ? 'New Member Groups' : 'Edit Member Groups',
      subtitle: widget.isInUse ? 'Active — changes apply immediately' : null,
      topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (widget.isInUse) ...[
                const SizedBox(height: AppSpacing.cardToCard),
                BoxyArtCard(
                  backgroundColor: AppColors.amber500.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.amber500.withValues(alpha: 0.35)),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.dark900, size: 18),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'This config is active. Saving will immediately update group assignments.',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.dark900,
                            fontWeight: AppTypography.weightRegular,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              BoxyArtSectionTitle(
                title: 'Config details',
                isPeeking: true,
                followsCard: widget.isInUse,
              ),
              BoxyArtCard(
                child: BoxyArtFormColumn(
                  children: [
                    BoxyArtInputField(
                      label: 'Config name',
                      hint: 'e.g. Standard Divisions',
                      controller: _nameController,
                    ),
                  ],
                ),
              ),

              const BoxyArtSectionTitle(
                title: 'Split type',
                isPeeking: true,
                followsCard: true,
              ),
              _buildSplitTypePicker(),

              if (_splitType == GroupSplitType.handicap) ...[
                const BoxyArtSectionTitle(
                  title: 'Handicap threshold',
                  isPeeking: true,
                  followsCard: true,
                ),
                BoxyArtCard(
                  child: BoxyArtFormColumn(
                    children: [
                      BoxyArtInputField(
                        label: 'First group HC ≤ this value',
                        hint: 'e.g. 12.0',
                        controller: _thresholdController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ],

              const BoxyArtSectionTitle(
                title: 'Group names',
                isPeeking: true,
                followsCard: true,
              ),
              _buildGroupNameFields(),

              if (_splitType == GroupSplitType.handicap) ...[
                const BoxyArtSectionTitle(
                  title: 'Voluntary first group upgrades',
                  isPeeking: true,
                  followsCard: true,
                ),
                _buildVoluntaryUpgrades(),
              ],

              if (_splitType == GroupSplitType.custom) ...[
                const BoxyArtSectionTitle(
                  title: 'Member assignments',
                  isPeeking: true,
                  followsCard: true,
                ),
                _buildCustomAssignments(),
              ],

              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.x3l, bottom: AppSpacing.xl),
                child: BoxyArtButton(
                  title: widget.isNew ? 'Create Config' : 'Save Changes',
                  isLoading: _isSaving,
                  fullWidth: true,
                  onTap: () => _save(context),
                ),
              ),
              if (!widget.isNew && !widget.isInUse)
                BoxyArtButton(
                  title: 'Delete Config',
                  isDangerous: true,
                  fullWidth: true,
                  onTap: () => _delete(context),
                ),
              const SizedBox(height: AppSpacing.hero),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitTypePicker() {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final cardGap = spacing?.cardToCard ?? AppSpacing.atomic;
    return Column(
      children: [
        BoxyArtSelectCard(
          icon: Icons.swap_vert_rounded,
          label: 'Handicap',
          description: 'Split by handicap index threshold. Supports voluntary upgrades.',
          isSelected: _splitType == GroupSplitType.handicap,
          cardGap: cardGap,
          onTap: () => _setSplitType(GroupSplitType.handicap),
        ),
        BoxyArtSelectCard(
          icon: Icons.people_rounded,
          label: 'Gender',
          description: 'Automatically splits using each member\'s gender field.',
          isSelected: _splitType == GroupSplitType.gender,
          cardGap: cardGap,
          onTap: () => _setSplitType(GroupSplitType.gender),
        ),
        BoxyArtSelectCard(
          icon: Icons.workspaces_rounded,
          label: 'Custom',
          description: 'Admin manually assigns members to named groups.',
          isSelected: _splitType == GroupSplitType.custom,
          cardGap: cardGap,
          onTap: () => _setSplitType(GroupSplitType.custom),
        ),
      ],
    );
  }

  void _setSplitType(GroupSplitType type) {
    for (final c in _groupNameControllers) c.dispose();
    final newGroups = _defaultGroups(type);
    setState(() {
      _splitType = type;
      _groups = newGroups;
      _voluntaryIds = [];
      _groupNameControllers = newGroups
          .map((g) => TextEditingController(text: g.name))
          .toList();
    });
  }

  Widget _buildGroupNameFields() {
    final isGender = _splitType == GroupSplitType.gender;
    return BoxyArtCard(
      child: BoxyArtFormColumn(
        children: [
          for (int i = 0; i < _groups.length; i++)
            BoxyArtInputField(
              label: 'Group ${i + 1} name',
              hint: _groups[i].name,
              readOnly: isGender,
              controller: _groupNameControllers[i],
              onChanged: (v) {
                _groups[i] = MemberGroup(
                  id: _groups[i].id,
                  name: v,
                  manualMemberIds: _groups[i].manualMemberIds,
                );
              },
            ),
          if (_splitType == GroupSplitType.custom)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: BoxyArtButton(
                title: 'Add Group',
                icon: Icons.add_rounded,
                isTinted: true,
                fullWidth: true,
                onTap: _groups.length < 8
                    ? () => setState(() {
                          final idx = _groups.length + 1;
                          final newGroup = MemberGroup(
                            id: 'group_${String.fromCharCode(96 + idx)}',
                            name: 'Group ${String.fromCharCode(64 + idx)}',
                          );
                          _groups.add(newGroup);
                          _groupNameControllers.add(
                            TextEditingController(text: newGroup.name),
                          );
                        })
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoluntaryUpgrades() {
    final allMembers = ref.watch(allMembersProvider).value ?? [];
    final query = _searchController.text.toLowerCase();
    final threshold =
        double.tryParse(_thresholdController.text) ?? 12.0;
    final previewConfig = MemberGroupConfig(
      id: widget.config.id,
      name: '',
      splitType: GroupSplitType.handicap,
      handicapThreshold: threshold,
      groups: _groups,
    );

    final eligiblePool = allMembers.where((m) {
      final groupId = MemberGroupHelper.assignGroupId(m, previewConfig);
      return groupId == _groups.last.id;
    }).toList();

    final members = query.isEmpty
        ? eligiblePool.where((m) => _voluntaryIds.contains(m.id)).toList()
        : eligiblePool.where((m) {
            final name = '${m.firstName} ${m.lastName}'.toLowerCase();
            return name.contains(query);
          }).toList();

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: BoxyArtInputField(
              label: 'Search members',
              hint: 'Filter by name…',
              controller: _searchController,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const BoxyArtDivider(),
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: BoxyArtEmptyCard(
                title: query.isEmpty ? 'No upgrades yet' : 'No results',
                message: query.isEmpty
                    ? 'Search for a member above to grant them first-group access.'
                    : 'No members match "$query".',
                icon: Icons.person_pin_rounded,
                isCompact: true,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (context, i) {
                final m = members[i];
                final isGranted = _voluntaryIds.contains(m.id);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          BoxyArtAvatar(
                            url: m.avatarUrl,
                            initials: '${m.firstName[0]}${m.lastName[0]}',
                            radius: 18,
                            isCircle: true,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${m.firstName} ${m.lastName}',
                                  style: AppTypography.labelStrong,
                                ),
                                Text(
                                  'HC ${m.handicap.toStringAsFixed(1)}',
                                  style: AppTypography.micro
                                      .copyWith(color: AppColors.dark400),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isGranted,
                            onChanged: (v) => setState(() {
                              if (v) {
                                _voluntaryIds.add(m.id);
                              } else {
                                _voluntaryIds.remove(m.id);
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    if (i < members.length - 1) const BoxyArtDivider(),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCustomAssignments() {
    final allMembers = ref.watch(allMembersProvider).value ?? [];
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final cardGap = spacing?.cardToCard ?? AppSpacing.atomic;

    return Column(
      children: _groups.asMap().entries.map((entry) {
        final i = entry.key;
        final group = entry.value;
        final assigned = allMembers
            .where((m) => group.manualMemberIds.contains(m.id))
            .toList();

        return Padding(
          padding: EdgeInsets.only(bottom: i < _groups.length - 1 ? cardGap : 0),
          child: BoxyArtCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                  child: Text(group.name, style: AppTypography.labelStrong),
                ),
                const BoxyArtDivider(),
                if (assigned.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                    child: Text(
                      'No members assigned',
                      style: AppTypography.micro.copyWith(color: AppColors.dark400),
                    ),
                  )
                else
                  ...assigned.asMap().entries.map((e) {
                    final m = e.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              BoxyArtAvatar(
                                url: m.avatarUrl,
                                initials: '${m.firstName[0]}${m.lastName[0]}',
                                radius: 16,
                                isCircle: true,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  '${m.firstName} ${m.lastName}',
                                  style: AppTypography.label,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded,
                                    size: 20),
                                color: AppColors.coral500,
                                onPressed: () => setState(() {
                                  _groups[i] = MemberGroup(
                                    id: group.id,
                                    name: group.name,
                                    manualMemberIds: List.from(group.manualMemberIds)
                                      ..remove(m.id),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        if (e.key < assigned.length - 1) const BoxyArtDivider(),
                      ],
                    );
                  }),
                const BoxyArtDivider(),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: BoxyArtButton(
                    title: 'Add member to ${group.name}',
                    icon: Icons.add_rounded,
                    isTinted: true,
                    fullWidth: true,
                    onTap: () => _pickMemberForGroup(i),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickMemberForGroup(int groupIndex) async {
    final allMembers = ref.read(allMembersProvider).value ?? [];
    final alreadyAssigned = _groups.expand((g) => g.manualMemberIds).toSet();
    final available = allMembers
        .where((m) => !alreadyAssigned.contains(m.id))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All members are already assigned')),
      );
      return;
    }

    final picked = await showDialog<List<String>>(
      context: context,
      useSafeArea: false,
      barrierDismissible: true,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: _MemberPickerScreen(
          groupName: _groups[groupIndex].name,
          available: available,
        ),
      ),
    );

    if (picked != null && picked.isNotEmpty) {
      setState(() {
        final g = _groups[groupIndex];
        _groups[groupIndex] = MemberGroup(
          id: g.id,
          name: g.name,
          manualMemberIds: List.from(g.manualMemberIds)..addAll(picked),
        );
      });
    }
  }

  Future<void> _save(BuildContext context) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Config name is required')),
      );
      return;
    }

    if (!widget.isNew && widget.isInUse) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => BoxyArtDialog(
          title: 'Update Config?',
          message:
              'This config is active. Changes will apply immediately to group assignments.',
          confirmText: 'Save Changes',
          cancelText: 'Cancel',
          onConfirm: () => Navigator.of(ctx).pop(true),
          onCancel: () => Navigator.of(ctx).pop(false),
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isSaving = true);

    final updated = MemberGroupConfig(
      id: widget.config.id,
      name: name,
      splitType: _splitType,
      handicapThreshold: _splitType == GroupSplitType.handicap
          ? double.tryParse(_thresholdController.text) ?? 12.0
          : null,
      groups: [
        for (int i = 0; i < _groups.length; i++)
          MemberGroup(
            id: _groups[i].id,
            name: _groupNameControllers[i].text.trim().isEmpty
                ? _groups[i].name
                : _groupNameControllers[i].text.trim(),
            manualMemberIds: _groups[i].manualMemberIds,
          ),
      ],
      voluntaryFirstGroupMemberIds:
          _splitType == GroupSplitType.handicap ? _voluntaryIds : [],
    );

    final repo = ref.read(memberGroupConfigRepositoryProvider);
    if (widget.isNew) {
      await repo.addConfig(updated);
    } else {
      await repo.updateConfig(updated);
    }

    if (mounted) context.pop();
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => BoxyArtDialog(
        title: 'Delete Config?',
        message: 'This will permanently remove the config. It cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDangerous: true,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(memberGroupConfigRepositoryProvider)
        .deleteConfig(widget.config.id);
    if (mounted) context.pop();
  }
}

// ---------------------------------------------------------------------------
// Multi-select member picker (shown as Dialog.fullscreen — avoids go_router
// Navigator conflicts that prevent HeadlessScaffold from working in dialogs)
// ---------------------------------------------------------------------------

class _MemberPickerScreen extends StatefulWidget {
  final String groupName;
  final List<Member> available;

  const _MemberPickerScreen({
    required this.groupName,
    required this.available,
  });

  @override
  State<_MemberPickerScreen> createState() => _MemberPickerScreenState();
}

class _MemberPickerScreenState extends State<_MemberPickerScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selected = {};
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Member> get _filtered {
    if (_query.isEmpty) return widget.available;
    final q = _query.toLowerCase();
    return widget.available.where((m) {
      final name = '${m.firstName} ${m.lastName}'.toLowerCase();
      final hc = m.handicap.toStringAsFixed(1);
      return name.contains(q) || hc.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();
    final hPad = spacing?.cardHorizontalPadding ?? AppSpacing.xl;
    final cardGap = spacing?.cardToCard ?? AppSpacing.atomic;
    final count = _selected.length;
    final filtered = _filtered;

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, hPad, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: theme.colorScheme.onSurface,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add to ${widget.groupName}',
                          style: AppTypography.displaySection,
                        ),
                        Text(
                          count == 0 ? 'Select members' : '$count selected',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.dark400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.standard),

            // Search + list
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, cardGap),
                    sliver: SliverToBoxAdapter(
                      child: BoxyArtCard(
                        child: BoxyArtInputField(
                          label: 'Search',
                          hint: 'Name or handicap…',
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                    ),
                  ),
                  if (filtered.isEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      sliver: const SliverToBoxAdapter(
                        child: BoxyArtEmptyCard(
                          title: 'No members found',
                          message: 'Try a different name or handicap.',
                          icon: Icons.person_search_rounded,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final m = filtered[index];
                            final isSelected = _selected.contains(m.id);
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < filtered.length - 1 ? cardGap : 0,
                              ),
                              child: BoxyArtCard(
                                isHighlighted: isSelected,
                                onTap: () => setState(() {
                                  if (isSelected) {
                                    _selected.remove(m.id);
                                  } else {
                                    _selected.add(m.id);
                                  }
                                }),
                                child: Row(
                                  children: [
                                    BoxyArtAvatar(
                                      url: m.avatarUrl,
                                      initials: '${m.firstName[0]}${m.lastName[0]}',
                                      radius: 18,
                                      isCircle: true,
                                    ),
                                    const SizedBox(width: AppSpacing.standard),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${m.firstName} ${m.lastName}',
                                            style: AppTypography.labelStrong,
                                          ),
                                          Text(
                                            'HC ${m.handicap.toStringAsFixed(1)}',
                                            style: AppTypography.micro.copyWith(
                                              color: AppColors.dark400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: theme.colorScheme.primary,
                                        size: AppShapes.iconMd,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.section)),
                ],
              ),
            ),

            // Confirm button
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.standard),
              child: BoxyArtButton(
                title: count == 0
                    ? 'Select members'
                    : 'Add $count member${count == 1 ? '' : 's'}',
                fullWidth: true,
                onTap: count > 0 ? () => Navigator.of(context).pop(_selected.toList()) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
