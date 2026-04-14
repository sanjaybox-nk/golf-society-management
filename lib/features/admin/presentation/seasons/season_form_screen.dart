import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';


import 'package:golf_society/domain/models/season.dart';
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
  
  late TextEditingController _nameController;
  late TextEditingController _yearController;
  
  late DateTime _startDate;
  late DateTime _endDate;
  late SeasonStatus _status;
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 0),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: AppSpacing.md),
                  BoxyArtSwitchField(
                    label: 'Set as current season',
                    value: _isCurrent,
                    onChanged: (v) => setState(() => _isCurrent = v),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
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
      leaderboards: widget.season?.leaderboards ?? [],
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
