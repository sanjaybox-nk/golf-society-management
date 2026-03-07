import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';


import 'package:golf_society/domain/models/season.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import '../../../events/presentation/events_provider.dart';
import 'leaderboard_config_dialog.dart';
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
  bool _isSaving = false;
  bool _isRecalculating = false;

  late TextEditingController _nameController;
  late TextEditingController _yearController;
  
  late DateTime _startDate;
  late DateTime _endDate;
  late SeasonStatus _status;
  bool _isCurrent = false;
  
  // New Leaderboard List
  late List<LeaderboardConfig> _leaderboards;

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
      autoPrefix: false,
      showBack: true,
      onBack: () => context.pop(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm, top: AppSpacing.xs),
          child: BoxyArtButton(
            title: 'SAVE',
            isGhost: true,
            isLoading: _isSaving,
            textColor: AppColors.lime500,
            onTap: _save,
          ),
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 0),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BoxyArtSectionTitle(title: 'BASIC INFO', ),
                  BoxyArtCard(child: Column(
                      children: [
                        BoxyArtFormField(
                          label: 'Season Name',
                          controller: _nameController,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: BoxyArtFormField(
                                label: 'Year',
                                controller: _yearController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(child: _buildStatusDropdown()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  const BoxyArtSectionTitle(title: 'DATES',),
                  BoxyArtCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
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
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  
                  // LEADERBOARDS SECTION
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Section Header Manual Build (to avoid Align expansion)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs), // Added bottom padding to lift text slightly above baseline if buttons push row height
                        child: Text(
                          'LEADERBOARDS',
                          style: TextStyle(
                            fontSize: AppTypography.sizeLabel, // Match BoxyArtSectionTitle default
                            fontWeight: AppTypography.weightBlack,
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite.withValues(alpha: 0.54) : AppColors.textSecondary,
                            letterSpacing: 1.5,
                            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Refresh Action
                      if (widget.season != null)
                        Tooltip(
                          message: 'Recalculate Standings',
                          child: InkWell(
                            onTap: _isRecalculating ? null : _recalculateStandings,
                            borderRadius: AppShapes.xl,
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xs), // Minimized padding further to 4
                              child: _isRecalculating 
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                : Icon(Icons.refresh, size: AppShapes.iconSm, color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ),
                      const Spacer(),
                      // ADD Button (Far Right)
                      GestureDetector(
                        onTap: () => _openLeaderboardDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor, // Solid Primary Color
                            borderRadius: AppShapes.xl,
                            boxShadow: AppShadows.softScale,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: AppShapes.iconXs, color: AppColors.pureWhite),
                              const SizedBox(width: 6),
                              Text(
                                'ADD NEW', // Changed label for clarity
                                style: const TextStyle(
                                  color: AppColors.pureWhite,
                                  fontWeight: AppTypography.weightBold,
                                  fontSize: AppTypography.sizeCaptionStrong,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs), // Minimized gap to header
                  if (_leaderboards.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.x2l),
                      child: Center(child: Text('No leaderboards configured.', style: TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Remove critical default padding
                      padding: EdgeInsets.zero,
                      itemCount: _leaderboards.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm), // Standardize gap
                      itemBuilder: (context, index) {
                        final config = _leaderboards[index];
                        return _LeaderboardListTile(
                          config: config,
                          onEdit: () => _openLeaderboardDialog(existingConfig: config, index: index),
                          onDelete: () => setState(() => _leaderboards.removeAt(index)),
                        );
                      },
                    ),

                  const SizedBox(height: AppSpacing.md), // Reduced spacing to "Set as Current" (was 24)
                  BoxyArtSwitchField(
                    label: 'Set as Current Season',
                    value: _isCurrent,
                    onChanged: (v) => setState(() => _isCurrent = v),
                  ),
                  const SizedBox(height: AppSpacing.x4l),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.sm),
          child: Text(
            'Status',
            style: TextStyle(
              fontSize: AppTypography.sizeLabelStrong,
              fontWeight: AppTypography.weightBold,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : Colors.black,
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            ),
          ),
        ),
        Container(
          decoration: ShapeDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF5F5F5),
            shape: RoundedRectangleBorder(
              borderRadius: AppShapes.md,
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.pureWhite.withValues(alpha: 0.12) 
                    : const Color(0xFFE0E0E0),
                width: AppShapes.borderThin,
              ),
            ),
            shadows: AppShadows.inputSoft,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<SeasonStatus>(
              initialValue: _status,
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 0),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.black.withValues(alpha: 0.54)),
              style: TextStyle(
                fontSize: AppTypography.sizeBodySmall, 
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : Colors.black.withValues(alpha: 0.87),
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              ),
              items: SeasonStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _status = v!),
              dropdownColor: Theme.of(context).cardColor,
              borderRadius: AppShapes.md,
            ),
          ),
        ),
      ],
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

  Future<void> _openLeaderboardDialog({LeaderboardConfig? existingConfig, int? index}) async {
    LeaderboardConfig? result;
    
    if (existingConfig != null) {
      final dialogResult = await showDialog<LeaderboardConfig>(
        context: context,
        builder: (context) => LeaderboardConfigDialog(existingConfig: existingConfig),
      );
      result = dialogResult;

    } else {
      result = await context.push<LeaderboardConfig>('/admin/settings/leaderboards/create/picker');
    }

    if (result != null) {
      setState(() {
        if (index != null) {
          _leaderboards[index] = result!;
        } else {
          _leaderboards.add(result!);
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
      
      // Auto-recalculate standings for existing seasons so new leaderboards populate immediately
      try {
        await ref.read(leaderboardInvokerServiceProvider).recalculateAll(
          season.id,
          overrideConfigs: _leaderboards,
        );
      } catch (_) {
        // Silently continue if math fails so we don't block the UI pop
      }
    }

    if (_isCurrent) {
      await repo.setCurrentSeason(season.id);
    }

    if (mounted) context.pop();
  }

  Future<void> _recalculateStandings() async {
    if (widget.seasonId == null) return;
    
    setState(() => _isRecalculating = true);
    
    try {
      await ref.read(leaderboardInvokerServiceProvider).recalculateAll(
        widget.seasonId!,
        overrideConfigs: _leaderboards,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Standings updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating standings: $e'), backgroundColor: AppColors.coral500),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecalculating = false);
    }
  }
}

class _LeaderboardListTile extends StatelessWidget {
  final LeaderboardConfig config;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LeaderboardListTile({
    required this.config,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String typeLabel = '';
    IconData icon = Icons.leaderboard;
    Color color = Theme.of(context).primaryColor;
    
    config.map(
      orderOfMerit: (_) { typeLabel = 'ORDER OF MERIT'; icon = Icons.emoji_events_rounded; color = AppColors.amber500; },
      bestOfSeries: (_) { typeLabel = 'BEST OF SERIES'; icon = Icons.list_alt_rounded; color = AppColors.teamA; },
      eclectic: (_) { typeLabel = 'ECLECTIC'; icon = Icons.grid_on_rounded; color = AppColors.teamB; },
      markerCounter: (_) { typeLabel = 'BIRDIE TREE'; icon = Icons.park_rounded; color = AppColors.lime500; },
    );

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onEdit,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: AppColors.opacityLow),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppShapes.iconLg),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: AppTypography.label.copyWith(
                    color: isDark ? AppColors.dark300 : AppColors.dark400,
                    fontSize: AppTypography.sizeCaption,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  config.name,
                  style: AppTypography.body.copyWith(
                    fontWeight: AppTypography.weightExtraBold,
                    color: isDark ? AppColors.pureWhite : AppColors.dark900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: isDark ? AppColors.dark300 : AppColors.dark400, size: AppShapes.iconMd),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
