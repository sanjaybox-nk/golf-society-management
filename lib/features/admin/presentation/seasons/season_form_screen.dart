import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

import 'package:golf_society/domain/models/season.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import '../../../events/presentation/events_provider.dart';
import '../../utils/leaderboard_rule_translator.dart';
import '../../data/member_group_config_repository.dart';
import 'package:golf_society/domain/models/member_group_config.dart';
import '../../services/leaderboard_invoker_service.dart' show leaderboardInvokerServiceProvider;

final _assignedTemplatesProvider =
    StreamProvider.autoDispose.family<List<LeaderboardConfig>, List<String>>((ref, ids) {
  if (ids.isEmpty) return Stream.value([]);
  return ref.watch(leaderboardTemplatesRepositoryProvider).watchTemplatesByIds(ids);
});

final _memberGroupConfigsProvider = StreamProvider<List<MemberGroupConfig>>((ref) {
  return ref.watch(memberGroupConfigRepositoryProvider).watchConfigs();
});

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
  late List<String> _leaderboardIds;
  bool _isSaving = false;
  bool _isCurrent = false;

  bool _divisionsEnabled = false;
  String? _memberGroupConfigId;

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
    _leaderboardIds = List.from(s?.leaderboardIds ?? []);
    _memberGroupConfigId = s?.memberGroupConfigId;
    _divisionsEnabled = _memberGroupConfigId != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeadlessScaffold(
      title: widget.season == null ? 'Create Season' : 'Edit Season',
      subtitle: (widget.season?.name != null) ? widget.season!.name : 'Configure season properties',
      topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
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
    final configsAsync = ref.watch(_memberGroupConfigsProvider);
    final selectedConfig = configsAsync.value
        ?.where((c) => c.id == _memberGroupConfigId)
        .firstOrNull;

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          BoxyArtSwitchTile(
            icon: Icons.workspaces_rounded,
            label: 'Enable Member Groups',
            subtitle: 'Split members into groups for standings filtering.',
            value: _divisionsEnabled,
            onChanged: (v) => setState(() {
              _divisionsEnabled = v;
              if (!v) _memberGroupConfigId = null;
            }),
          ),
          if (_divisionsEnabled) ...[
            const BoxyArtDivider(),
            if (selectedConfig != null)
              BoxyArtNavTile(
                icon: Icons.workspaces_rounded,
                title: selectedConfig.name,
                subtitle: '${selectedConfig.groups.map((g) => g.name).join(' · ')} · Tap to change',
                onTap: _pickConfig,
              )
            else
              BoxyArtNavTile(
                icon: Icons.add_rounded,
                title: 'Select Group Config',
                subtitle: 'Pick a config from the gallery',
                onTap: _pickConfig,
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickConfig() async {
    final result = await context.pushNamed<MemberGroupConfig>(
      'admin-division-templates',
      queryParameters: {'picker': 'true'},
    );
    if (result != null) {
      setState(() => _memberGroupConfigId = result.id);
    }
  }

  Widget _buildLeaderboardsList() {
    if (_leaderboardIds.isEmpty) {
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

    final configsAsync = ref.watch(_assignedTemplatesProvider(_leaderboardIds));

    return configsAsync.when(
      loading: () => const BoxyArtCard(
        padding: EdgeInsets.all(AppSpacing.x2l),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (configs) => BoxyArtCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: configs.asMap().entries.map((entry) {
            final idx = entry.key;
            final l = entry.value;
            final isLast = idx == configs.length - 1;

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
                    setState(() => _leaderboardIds = _leaderboardIds.where((i) => i != l.id).toList());
                  },
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
                                LeaderboardRuleTranslator.translate(l),
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
                if (!isLast) const BoxyArtDivider(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTemplateSelector() async {
    final result = await context.push<LeaderboardConfig>(
      '/admin/leaderboards/create/picker',
    );

    if (result != null && mounted) {
      final id = result.id;
      if (id.isNotEmpty && !_leaderboardIds.contains(id)) {
        setState(() => _leaderboardIds = [..._leaderboardIds, id]);
      }
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

  Future<void> _closeSeasonDialog() async {
    final confirmed = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Close Season?',
      message: 'Final standings will be calculated and frozen. The season moves to the Archive. This cannot be undone.',
      confirmText: 'ARCHIVE',
      cancelText: 'CANCEL',
      isDangerous: true,
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Calculating final standings…')));

    try {
      await ref.read(leaderboardInvokerServiceProvider).recalculateAll(widget.season!.id);
    } catch (_) {
      // Don't block the close if recalc fails — standings may already be correct
    }

    if (!mounted) return;
    await ref.read(seasonsRepositoryProvider).closeSeason(widget.season!.id, {
      'captain': 'TBD',
      'playerOfTheYear': 'TBD',
      'majorWinners': [],
    });
    if (mounted) context.pop();
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
      leaderboardIds: _leaderboardIds,
      memberGroupConfigId: _divisionsEnabled ? _memberGroupConfigId : null,
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
