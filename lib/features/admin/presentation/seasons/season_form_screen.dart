import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

import 'package:golf_society/domain/models/season.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../competitions/services/leaderboard_invoker_service.dart';

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
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      actions: [
        if (widget.season != null)
          BoxyArtGlassIconButton(
            icon: Icons.sync_rounded,
            onPressed: _syncStandings,
            tooltip: 'Sync Standings',
          ),
        const SizedBox(width: AppSpacing.sm),
      ],
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
                const BoxyArtSectionTitle(title: 'Assigned Leaderboards', isPeeking: true, followsCard: true),
                _buildLeaderboardsList(),
                const SizedBox(height: AppSpacing.standard),
                BoxyArtButton(
                  title: 'Add Leaderboard Templates',
                  isSecondary: true,
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
              ],
            ),
            ),
          ),
        ),
      ],
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
                    confirmText: 'Remove',
                    isDangerous: true,
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
                        markerCounter: (_) => Icons.emoji_events_rounded,
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
                            style: AppTypography.caption.copyWith(color: AppColors.dark400),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          BoxyArtIndicator(
                            label: l.scope == LeaderboardScope.global ? 'GLOBAL' : 'SEASON LONG',
                            dotColor: l.scope == LeaderboardScope.global 
                                ? AppColors.lime500 
                                : AppColors.teamA,
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
    return config.map(
      orderOfMerit: (o) => 'OOM (${o.source.name.toUpperCase()}) • ${o.rankingBasis.name.toUpperCase()}${o.bestN > 0 ? ' • Best ${o.bestN}' : ' • All rounds'}',
      bestOfSeries: (b) => 'Best of Series • ${b.metric.name.toUpperCase()}${b.bestN > 0 ? ' • Best ${b.bestN}' : ' • All rounds'}',
      eclectic: (e) => 'Eclectic • ${e.metric.name.toUpperCase()}${e.handicapPercentage > 0 ? ' • ${e.handicapPercentage}% HCP' : ' • Gross'}',
      markerCounter: (m) => 'Markers • ${m.targetTypes.length} Targets • ${m.holeFilter == HoleFilter.all ? 'All Holes' : m.holeFilter.name.toUpperCase()}',
    );
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

  Future<void> _syncStandings() async {
    if (widget.season == null) return;
    
    _showSnackBar('Syncing standings...', Icons.sync_rounded);
    
    try {
      final invoker = ref.read(leaderboardInvokerServiceProvider);
      await invoker.recalculateAll(widget.season!.id, overrideConfigs: _leaderboards);
      if (mounted) {
        _showSnackBar('Standings synchronized!', Icons.check_circle_rounded, color: AppColors.lime500);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Sync failed: $e', Icons.error_outline_rounded, color: AppColors.coral500);
      }
    }
  }

  void _showSnackBar(String message, IconData icon, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(message),
          ],
        ),
        backgroundColor: color ?? AppColors.dark700,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
