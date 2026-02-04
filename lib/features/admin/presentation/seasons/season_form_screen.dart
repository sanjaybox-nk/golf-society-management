import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    return Scaffold(
      // backgroundColor: Colors.black, // Removed to respect theme
      appBar: BoxyArtAppBar(
        title: widget.season == null ? 'NEW SEASON' : 'EDIT SEASON',
        centerTitle: true,
        isLarge: true,
        leadingWidth: 80,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              Text(
                'Back',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BoxyArtSectionTitle(title: 'BASIC INFO'),
              BoxyArtFloatingCard(
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
              const BoxyArtSectionTitle(title: 'DATES'),
              BoxyArtFloatingCard(
                child: Row(
                  children: [
                    Expanded(
                      child: BoxyArtDatePickerField(
                        label: 'Starts',
                        value: DateFormat.yMMMd().format(_startDate),
                        onTap: () => _pickDate(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: BoxyArtSectionTitle(title: 'ACTIVE LEADERBOARDS', padding: EdgeInsets.zero)),
                  Row(
                    children: [
                      // Recalculate Button
                      if (widget.season != null)
                        TextButton.icon(
                          onPressed: _isRecalculating ? null : _recalculateStandings,
                          icon: _isRecalculating 
                            ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.refresh, size: 16),
                          label: Text(_isRecalculating ? 'UPDATING...' : 'RECALCULATE', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary),
                        ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _openLeaderboardDialog(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('ADD', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_leaderboards.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No leaderboards configured.', style: TextStyle(color: Colors.grey))),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _leaderboards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final config = _leaderboards[index];
                    return _LeaderboardListTile(
                      config: config,
                      onEdit: () => _openLeaderboardDialog(existingConfig: config, index: index),
                      onDelete: () => setState(() => _leaderboards.removeAt(index)),
                    );
                  },
                ),

              const SizedBox(height: 24),
              BoxyArtSwitchField(
                label: 'Set as Current Season',
                value: _isCurrent,
                onChanged: (v) => setState(() => _isCurrent = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
        DropdownButton<SeasonStatus>(
          value: _status,
          isExpanded: true,
          // dropdownColor: Colors.grey.shade900, // Removed
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black),
          underline: const SizedBox(),
          onChanged: (v) => setState(() => _status = v!),
          items: SeasonStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
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
    // Navigate to Picker or Builder
    LeaderboardConfig? result;
    
    if (existingConfig != null) {
      // Edit Mode - Go directly to builder via router? 
      // Current router setup for 'picker' mode doesn't easily support 'edit' in place without ID.
      // For now, we'll keep using the Dialog for direct inline edits OR refactor to push/pop.
      // Given the user request for "same process", we should ideally use the screen.
      // Let's fallback to the Dialog for EDITING an in-memory item for now to avoid complex state passing,
      // BUT for NEW items we use the picker.
      
      // Actually, let's use the selection screen for NEW.
      // For EDIT, we can't easily jump to a builder route without saving state first.
      // So we will stick to the Dialog for EDIT, but use Picker for NEW.
      
      // Wait, user said "mimic the theme as well" and "create leaderboards... same process".
      // So we should try to use the screens.
      // We can pass the config object? Routing with objects is tricky.
      
      // Let's use the Dialog for now for EDIT to avoid breaking flow, but use Picker for ADD.
      final dialogResult = await showDialog<LeaderboardConfig>(
        context: context,
        builder: (context) => LeaderboardConfigDialog(existingConfig: existingConfig),
      );
      result = dialogResult;

    } else {
      // ADD Mode - Use the Router Picker
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
      // Removed legacy fields: pointsMode, bestN, tiePolicy
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
    // Determine type label and icon
    String typeLabel = '';
    IconData icon = Icons.leaderboard;
    
    config.map(
      orderOfMerit: (_) { typeLabel = 'ORDER OF MERIT'; icon = Icons.emoji_events; },
      bestOfSeries: (_) { typeLabel = 'BEST OF SERIES'; icon = Icons.list_alt; },
      eclectic: (_) { typeLabel = 'ECLECTIC'; icon = Icons.grid_on; },
      markerCounter: (_) { typeLabel = 'BIRDIE TREE'; icon = Icons.park; },
    );

    return BoxyArtFloatingCard(
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
