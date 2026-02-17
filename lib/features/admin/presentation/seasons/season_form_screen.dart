import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';


import '../../../../models/season.dart';
import '../../../../models/leaderboard_config.dart';
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
        TextButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : Text('SAVE', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BoxyArtSectionTitle(title: 'BASIC INFO', padding: EdgeInsets.only(left: 4, bottom: 8)),
                  ModernCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        BoxyArtFormField(
                          label: 'Season Name',
                          controller: _nameController,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: BoxyArtFormField(
                                label: 'Year',
                                controller: _yearController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatusDropdown()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const BoxyArtSectionTitle(title: 'DATES', padding: EdgeInsets.only(left: 4, bottom: 8)),
                  ModernCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: BoxyArtDatePickerField(
                            label: 'Starts',
                            value: DateFormat.yMMMd().format(_startDate),
                            onTap: () => _pickDate(isStart: true),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                  const SizedBox(height: 24),
                  
                  // LEADERBOARDS SECTION
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Section Header Manual Build (to avoid Align expansion)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4), // Added bottom padding to lift text slightly above baseline if buttons push row height
                        child: Text(
                          'LEADERBOARDS',
                          style: TextStyle(
                            fontSize: 12, // Match BoxyArtSectionTitle default
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey,
                            letterSpacing: 1.5,
                            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Refresh Action
                      if (widget.season != null)
                        Tooltip(
                          message: 'Recalculate Standings',
                          child: InkWell(
                            onTap: _isRecalculating ? null : _recalculateStandings,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0), // Minimized padding further to 4
                              child: _isRecalculating 
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                : Icon(Icons.refresh, size: 16, color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ),
                      const Spacer(),
                      // ADD Button (Far Right)
                      GestureDetector(
                        onTap: () => _openLeaderboardDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor, // Solid Primary Color
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'ADD NEW', // Changed label for clarity
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), // Minimized gap to header
                  if (_leaderboards.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No leaderboards configured.', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero, // Remove critical default padding
                      itemCount: _leaderboards.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8), // Standardize gap
                      itemBuilder: (context, index) {
                        final config = _leaderboards[index];
                        return _LeaderboardListTile(
                          config: config,
                          onEdit: () => _openLeaderboardDialog(existingConfig: config, index: index),
                          onDelete: () => setState(() => _leaderboards.removeAt(index)),
                        );
                      },
                    ),

                  const SizedBox(height: 12), // Reduced spacing to "Set as Current" (was 24)
                  BoxyArtSwitchField(
                    label: 'Set as Current Season',
                    value: _isCurrent,
                    onChanged: (v) => setState(() => _isCurrent = v),
                  ),
                  const SizedBox(height: 40),
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
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            'Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            ),
          ),
        ),
        Container(
          decoration: ShapeDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF5F5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white12 
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            shadows: AppShadows.inputSoft,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<SeasonStatus>(
              initialValue: _status,
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              style: TextStyle(
                fontSize: 14, 
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              ),
              items: SeasonStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _status = v!),
              dropdownColor: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
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
      result = await context.push<LeaderboardConfig>('/admin/seasons/leaderboards/create/picker');
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
      await ref.read(leaderboardInvokerServiceProvider).recalculateAll(widget.seasonId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Standings updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating standings: $e'), backgroundColor: Colors.red),
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
    String typeLabel = '';
    IconData icon = Icons.leaderboard;
    
    config.map(
      orderOfMerit: (_) { typeLabel = 'ORDER OF MERIT'; icon = Icons.emoji_events; },
      bestOfSeries: (_) { typeLabel = 'BEST OF SERIES'; icon = Icons.list_alt; },
      eclectic: (_) { typeLabel = 'ECLECTIC'; icon = Icons.grid_on; },
      markerCounter: (_) { typeLabel = 'BIRDIE TREE'; icon = Icons.park; },
    );

    return ModernCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onEdit,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  config.name,
                  style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
