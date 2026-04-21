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
      titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      actions: [
        const SizedBox(width: AppSpacing.md),
        if (widget.season != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: BoxyArtButton(
              title: 'Sync',
              isGhost: true,
              icon: Icons.sync_rounded,
              onTap: _syncStandings,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm, top: AppSpacing.xs),
          child: BoxyArtButton(
            title: 'Save',
            isGhost: true,
            isLoading: _isSaving,
            textColor: AppColors.lime500,
            onTap: _save,
          ),
        ),
      ],
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: MediaQuery.of(context).padding.bottom + 100,
          ),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: _formKey,
            child: BoxyArtFormColumn(
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
                const BoxyArtSectionTitle(title: 'Dates'),
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
                BoxyArtSwitchField(
                  label: 'Set as current season',
                  value: _isCurrent,
                  onChanged: (v) => setState(() => _isCurrent = v),
                ),

                const BoxyArtSectionTitle(title: 'Season Standings'),
                _buildLeaderboardsList(),
                BoxyArtButton(
                  title: 'Add from Template',
                  isSecondary: true,
                  icon: Icons.add_to_photos_rounded,
                  fullWidth: true,
                  onTap: _showTemplateSelector,
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

    return BoxyArtFormColumn(
      spacing: AppSpacing.md,
      children: _leaderboards.map((l) => BoxyArtCard(
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
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: BoxyArtFormColumn(
                spacing: AppSpacing.xs,
                children: [
                  Text(l.name, style: AppTypography.cardTitle),
                  Row(
                    children: [
                      BoxyArtPill.status(
                        label: toSentenceCase(l.scope.name),
                        color: l.scope == LeaderboardScope.global 
                            ? AppColors.lime500 
                            : AppColors.teamA,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _getFormatConfigSummary(l),
                          style: AppTypography.micro.copyWith(color: AppColors.dark400),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral500),
              onPressed: () => _removeLeaderboard(l),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      )).toList(),
    );
  }

  String _getFormatConfigSummary(LeaderboardConfig config) {
    return config.map(
      orderOfMerit: (o) => 'OOM • ${o.rankingBasis.name.toUpperCase()} • Best ${o.bestN}',
      bestOfSeries: (b) => 'Best of Series • Best ${b.bestN}',
      eclectic: (e) => 'Eclectic • ${e.metric.name.toUpperCase()}',
      markerCounter: (m) => 'Markers • ${m.targetTypes.length} Targets',
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


  void _removeLeaderboard(LeaderboardConfig config) {
    BoxyArtDialog.show(
      context: context,
      title: 'Remove Leaderboard?',
      message: 'This will remove "${config.name}" from the season and clear its calculated standings. This cannot be undone.',
      confirmText: 'Remove',
      isDangerous: true,
      onConfirm: () {
        setState(() => _leaderboards.removeWhere((l) => l.id == config.id));
        Navigator.pop(context);
      },
    );
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
