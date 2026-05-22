import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

import 'package:golf_society/domain/models/season.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/division_config.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../utils/leaderboard_rule_translator.dart';

class SeasonFormScreen extends ConsumerStatefulWidget {
  final Season? season;
  final String? seasonId;

  const SeasonFormScreen({super.key, this.season, this.seasonId});

  @override
  ConsumerState<SeasonFormScreen> createState() => _SeasonFormScreenState();
}

class _SeasonFormScreenState extends ConsumerState<SeasonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _yearController;
  
  late DateTime _startDate;
  late DateTime _endDate;
  late SeasonStatus _status;
  late List<LeaderboardConfig> _leaderboards;
  bool _isSaving = false;
  bool _isCurrent = false;

  // Divisions
  bool _divisionsEnabled = false;
  late TextEditingController _thresholdController;
  bool _genderSeparated = false;
  late List<String> _voluntaryDiv1MemberIds;

  @override
  void initState() {
    super.initState();
    final s = widget.season;
    _nameController = TextEditingController(text: s?.name ?? '');
    _yearController = TextEditingController(text: (s?.year ?? DateTime.now().year).toString());
    _startDate = s?.startDate ?? DateTime(DateTime.now().year, 1, 1);
    _endDate = s?.endDate ?? DateTime(DateTime.now().year, 12, 31);
    _status = s?.status ?? SeasonStatus.active;
    _isCurrent = s?.isCurrent ?? false;
    _leaderboards = List.from(s?.leaderboards ?? []);
    final dc = s?.divisionConfig;
    _divisionsEnabled = dc != null;
    _thresholdController = TextEditingController(text: (dc?.threshold ?? 12.0).toString());
    _genderSeparated = dc?.genderSeparated ?? false;
    _voluntaryDiv1MemberIds = List.from(dc?.voluntaryDiv1MemberIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeadlessScaffold(
      title: widget.season == null ? 'Create Season' : 'Edit Season',
      subtitle: (widget.season?.name != null) ? widget.season!.name : 'Configure season properties',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      actions: const [],
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.x2l,
          ),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BoxyArtSectionTitle(title: 'Basic info', isPeeking: true),
                BoxyArtCard(
                  child: BoxyArtFormColumn(
                    children: [
                      BoxyArtInputField(
                        label: 'Season name',
                        controller: _nameController,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: BoxyArtInputField(
                              label: 'Year',
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: BoxyArtDropdownField<SeasonStatus>(
                              label: 'Status',
                              value: _status,
                              items: SeasonStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(toSentenceCase(s.name)))).toList(),
                              onChanged: (v) => setState(() => _status = v!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const BoxyArtSectionTitle(title: 'Dates', isPeeking: true, followsCard: true),
                BoxyArtCard(
                  child: BoxyArtFormColumn(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: BoxyArtDatePickerField(
                              label: 'Starts',
                              value: DateFormat.yMMMd().format(_startDate),
                              onTap: () => _pickDate(isStart: true),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: BoxyArtDatePickerField(
                              label: 'Ends',
                              value: DateFormat.yMMMd().format(_endDate),
                              onTap: () => _pickDate(isStart: false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const BoxyArtSectionTitle(title: 'Settings', isPeeking: true, followsCard: true),
                BoxyArtCard(
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: BoxyArtSwitchTile(
                      icon: Icons.star_rounded,
                      label: 'Current Season',
                      subtitle: 'Make this the active season for the society',
                      value: _isCurrent,
                      onChanged: (v) => setState(() => _isCurrent = v),
                    ),
                  ),
                ),
                const BoxyArtSectionTitle(title: 'Divisions', isPeeking: true, followsCard: true),
                _buildDivisionsSection(),
                const BoxyArtSectionTitle(title: 'Assigned Leaderboards', isPeeking: true, followsCard: true),
                _buildLeaderboardsList(),
                const SizedBox(height: AppSpacing.standard),
                BoxyArtButton(
                  title: 'Add Leaderboard Templates',
                  isTinted: true,
                  icon: Icons.add_to_photos_rounded,
                  fullWidth: true,
                  onTap: _showTemplateSelector,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.x3l, bottom: AppSpacing.xl),
                  child: BoxyArtButton(
                    title: 'Save Season',
                    isLoading: _isSaving,
                    onTap: _save,
                    fullWidth: true,
                  ),
                ),
                if (widget.season != null && _status == SeasonStatus.active) ...[
                  const BoxyArtSectionTitle(title: 'Danger Zone', followsCard: true),
                  BoxyArtCard(
                    backgroundColor: AppColors.coral500.withValues(alpha: 0.06),
                    border: Border.all(color: AppColors.coral500.withValues(alpha: 0.2)),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Close & Archive Season',
                          style: AppTypography.labelStrong.copyWith(
                            color: AppColors.coral500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Moves this season and all its events to the archive. This cannot be undone.',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.dark400,
                            fontWeight: AppTypography.weightRegular,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.standard),
                        BoxyArtButton(
                          title: 'Close & Archive Season',
                          icon: Icons.lock_outline_rounded,
                          fullWidth: true,
                          isDangerous: true,
                          onTap: _closeSeasonDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.pageBottom),
                ],
              ],
            ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivisionsSection() {
    final members = ref.watch(allMembersProvider).value ?? [];
    final threshold = double.tryParse(_thresholdController.text) ?? 12.0;
    final voluntaryMembers = members.where((m) => _voluntaryDiv1MemberIds.contains(m.id)).toList();

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          BoxyArtSwitchTile(
            icon: Icons.workspaces_rounded,
            label: 'Enable Divisions',
            subtitle: 'Split members into Div 1 and Div 2 based on handicap.',
            value: _divisionsEnabled,
            onChanged: (v) => setState(() => _divisionsEnabled = v),
          ),
          if (_divisionsEnabled) ...[
            const BoxyArtDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: BoxyArtFormColumn(
                children: [
                  BoxyArtInputField(
                    label: 'Handicap threshold (Div 1 ≤ this)',
                    controller: _thresholdController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                  ),
                  BoxyArtSwitchField(
                    label: 'Separate by gender',
                    subtitle: 'Creates Div 1 Men, Div 2 Men, Div 1 Ladies, Div 2 Ladies.',
                    value: _genderSeparated,
                    onChanged: (v) => setState(() => _genderSeparated = v),
                  ),
                ],
              ),
            ),
            const BoxyArtDivider(),
            // Voluntary Div 1 upgrades
            if (voluntaryMembers.isNotEmpty)
              Column(
                children: voluntaryMembers.asMap().entries.map((entry) {
                  final m = entry.value;
                  final isLast = entry.key == voluntaryMembers.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
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
                                    'Plays in Div 1 · HC capped at $threshold',
                                    style: AppTypography.micro.copyWith(
                                      color: AppColors.dark400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            BoxyArtGlassIconButton(
                              icon: Icons.remove_circle_outline_rounded,
                              iconSize: 18,
                              onPressed: () => setState(() =>
                                  _voluntaryDiv1MemberIds.remove(m.id)),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast) const BoxyArtDivider(),
                    ],
                  );
                }).toList(),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: BoxyArtButton(
                title: 'Grant Div 1 Voluntary Upgrade',
                icon: Icons.person_add_rounded,
                isTinted: true,
                fullWidth: true,
                onTap: () => _showVoluntaryUpgradePicker(members, threshold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showVoluntaryUpgradePicker(List members, double threshold) {
    final eligible = members.where((m) =>
        m.handicap > threshold && !_voluntaryDiv1MemberIds.contains(m.id)).toList();

    BoxyArtBottomSheet.show(
      context: context,
      title: 'Grant Div 1 Upgrade',
      child: eligible.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'All Div 2 members have already been granted an upgrade.',
                style: AppTypography.body.copyWith(color: AppColors.dark400),
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: eligible.map<Widget>((m) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: BoxyArtAvatar(
                  url: m.avatarUrl,
                  initials: '${m.firstName[0]}${m.lastName[0]}',
                  radius: 22,
                  isCircle: true,
                ),
                title: Text(
                  '${m.firstName} ${m.lastName}',
                  style: AppTypography.labelStrong,
                ),
                subtitle: Text(
                  'HC ${m.handicap.toStringAsFixed(1)} · will be capped at $threshold',
                  style: AppTypography.micro.copyWith(color: AppColors.dark400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _voluntaryDiv1MemberIds.add(m.id));
                },
              )).toList(),
            ),
    );
  }

  Widget _buildLeaderboardsList() {
    if (_leaderboards.isEmpty) {
      return BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No leaderboards assigned',
                style: AppTypography.label.copyWith(
                  color: AppColors.dark400,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Add templates to track points throughout the season.',
                textAlign: TextAlign.center,
                style: AppTypography.micro.copyWith(
                  color: AppColors.dark400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: _leaderboards.asMap().entries.map((entry) {
          final idx = entry.key;
          final l = entry.value;
          final isLast = idx == _leaderboards.length - 1;
          
          return Column(
            children: [
              Dismissible(
                key: ValueKey(l.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.coral500,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.xl),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showBoxyArtDialog<bool>(
                    context: context,
                    title: 'Remove Leaderboard?',
                    message: 'This will remove "${l.name}" from the season and clear its calculated standings. This cannot be undone.',
                    confirmText: 'REMOVE',
                    isDangerous: true,
                    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
                    onConfirm: () async {
                      Navigator.of(context, rootNavigator: true).pop(true);
                    },
                  );
                },
                onDismissed: (_) {
                  setState(() => _leaderboards.removeWhere((item) => item.id == l.id));
                },
                child: InkWell(
                  onTap: () => _editLeaderboard(l),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.standard),
                  child: Row(
                    children: [
                    BoxyArtIconBadge(
                      icon: l.map(
                        orderOfMerit: (_) => Icons.format_list_numbered_rounded,
                        bestOfSeries: (_) => Icons.stars_rounded,
                        eclectic: (_) => Icons.grid_on_rounded,
                        markerCounter: (_) => Icons.park_rounded,
                      ),
                      color: Theme.of(context).colorScheme.primary,
                      isTinted: true,
                    ),
                    const SizedBox(width: AppSpacing.standard),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.name, style: AppTypography.cardTitle),
                          const SizedBox(height: 2),
                          Text(
                            _getFormatConfigSummary(l),
                            style: AppTypography.micro.copyWith(color: AppColors.dark400),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          BoxyArtIndicator(
                            label: switch (l.scope) {
                              LeaderboardScope.global => 'GLOBAL',
                              LeaderboardScope.invitationalsOnly => 'NON-SEASON',
                              LeaderboardScope.seasonOnly => 'SEASON LONG',
                            },
                            dotColor: switch (l.scope) {
                              LeaderboardScope.global => AppColors.lime500,
                              LeaderboardScope.invitationalsOnly => AppColors.amber500,
                              LeaderboardScope.seasonOnly => AppColors.teamA,
                            },
                            hasHorizontalMargin: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
              ),
              if (!isLast) const BoxyArtDivider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getFormatConfigSummary(LeaderboardConfig config) {
    return LeaderboardRuleTranslator.translate(config);
  }

  void _showTemplateSelector() async {
    final result = await context.push<LeaderboardConfig>(
      '/admin/leaderboards/create/picker',
    );

    if (result != null && mounted) {
      setState(() {
        _leaderboards.add(result);
      });
    }
  }

  void _editLeaderboard(LeaderboardConfig config) async {
    final result = await context.push<LeaderboardConfig>(
      '/admin/leaderboards/edit/local',
      extra: config,
    );

    if (result != null && mounted) {
      setState(() {
        final index = _leaderboards.indexWhere((l) => l.id == config.id);
        if (index != -1) {
          _leaderboards[index] = result;
        }
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _closeSeasonDialog() {
    showBoxyArtDialog(
      context: context,
      title: 'Close Season?',
      message: 'This will move "${widget.season!.name}" and all its events to the Archive. This cannot be undone.',
      confirmText: 'ARCHIVE',
      cancelText: 'CANCEL',
      isDangerous: true,
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      onConfirm: () async {
        await ref.read(seasonsRepositoryProvider).closeSeason(widget.season!.id, {
          'captain': 'TBD',
          'playerOfTheYear': 'TBD',
          'majorWinners': [],
        });
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          context.pop();
        }
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    
    final repo = ref.read(seasonsRepositoryProvider);
    final season = Season(
      id: widget.season?.id ?? '',
      name: _nameController.text,
      year: int.parse(_yearController.text),
      startDate: _startDate,
      endDate: _endDate,
      status: _status,
      isCurrent: _isCurrent,
      leaderboards: _leaderboards,
      divisionConfig: _divisionsEnabled
          ? DivisionConfig(
              threshold: double.tryParse(_thresholdController.text) ?? 12.0,
              genderSeparated: _genderSeparated,
              voluntaryDiv1MemberIds: _voluntaryDiv1MemberIds,
            )
          : null,
    );

    if (widget.season == null) {
      await repo.addSeason(season);
    } else {
      await repo.updateSeason(season);
    }

    if (_isCurrent) {
      await repo.setCurrentSeason(season.id);
    }

    if (mounted) context.pop();
  }
}
