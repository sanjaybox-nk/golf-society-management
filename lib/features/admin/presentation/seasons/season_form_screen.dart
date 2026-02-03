import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/season.dart';
import '../../../events/presentation/events_provider.dart';

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

  late TextEditingController _nameController;
  late TextEditingController _yearController;
  late TextEditingController _bestNController;
  
  late DateTime _startDate;
  late DateTime _endDate;
  late PointsMode _pointsMode;
  late TiePolicy _tiePolicy;
  late SeasonStatus _status;
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    final s = widget.season;
    _nameController = TextEditingController(text: s?.name ?? '');
    _yearController = TextEditingController(text: (s?.year ?? DateTime.now().year).toString());
    _bestNController = TextEditingController(text: (s?.bestN ?? 8).toString());
    _startDate = s?.startDate ?? DateTime(DateTime.now().year, 1, 1);
    _endDate = s?.endDate ?? DateTime(DateTime.now().year, 12, 31);
    _pointsMode = s?.pointsMode ?? PointsMode.position;
    _tiePolicy = s?.tiePolicy ?? TiePolicy.countback;
    _status = s?.status ?? SeasonStatus.active;
    _isCurrent = s?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _bestNController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: BoxyArtAppBar(
        title: widget.season == null ? 'NEW SEASON' : 'EDIT SEASON',
        centerTitle: true,
        isLarge: true,
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
              const BoxyArtSectionTitle(title: 'STANDINGS RULES'),
              BoxyArtFloatingCard(
                child: Column(
                  children: [
                    _buildPointsModeSelector(),
                    const SizedBox(height: 16),
                    BoxyArtFormField(
                      label: 'Best N Rounds (Count for Standings)',
                      controller: _bestNController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTiePolicySelector(),
                  ],
                ),
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
        const Text('Status', style: TextStyle(color: Colors.white70, fontSize: 12)),
        DropdownButton<SeasonStatus>(
          value: _status,
          isExpanded: true,
          dropdownColor: Colors.grey.shade900,
          style: const TextStyle(color: Colors.white),
          underline: const SizedBox(),
          onChanged: (v) => setState(() => _status = v!),
          items: SeasonStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
        ),
      ],
    );
  }

  Widget _buildPointsModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('POINTS MODE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: PointsMode.values.map((pm) {
            final isSelected = _pointsMode == pm;
            return ChoiceChip(
              label: Text(pm.name.toUpperCase()),
              selected: isSelected,
              onSelected: (val) => setState(() => _pointsMode = pm),
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 10),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTiePolicySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TIE POLICY', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TiePolicy.values.map((tp) {
            final isSelected = _tiePolicy == tp;
            return ChoiceChip(
              label: Text(tp.name.toUpperCase()),
              selected: isSelected,
              onSelected: (val) => setState(() => _tiePolicy = tp),
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 10),
            );
          }).toList(),
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
        if (isStart) _startDate = picked; else _endDate = picked;
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
      pointsMode: _pointsMode,
      bestN: int.parse(_bestNController.text),
      tiePolicy: _tiePolicy,
    );

    if (widget.season == null) {
      await repo.addSeason(season);
    } else {
      await repo.updateSeason(season);
    }

    if (_isCurrent) {
      // In a real app, the repository handles atomicity, but let's assume it works
      await repo.setCurrentSeason(season.id);
    }

    if (mounted) context.pop();
  }
}
