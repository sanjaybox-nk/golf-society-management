import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/distribution_list.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/audience_filter_rule.dart';
import 'firestore_distribution_lists_repository.dart';
import 'smart_audience_evaluator.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';

class DistributionListModal extends ConsumerStatefulWidget {
  final DistributionList? listToEdit;
  const DistributionListModal({super.key, this.listToEdit});

  @override
  ConsumerState<DistributionListModal> createState() => _DistributionListModalState();
}

class _DistributionListModalState extends ConsumerState<DistributionListModal> {
  final _nameController = TextEditingController();
  final Set<String> _selectedMemberIds = {};
  String _searchQuery = '';
  
  bool _isDynamic = false;
  final List<AudienceFilterRule> _rules = [];

  @override
  void initState() {
    super.initState();
    if (widget.listToEdit != null) {
      _nameController.text = widget.listToEdit!.name;
      _selectedMemberIds.addAll(widget.listToEdit!.memberIds);
      _isDynamic = widget.listToEdit!.isDynamic;
      _rules.addAll(widget.listToEdit!.filterCriteria);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMember(String id) {
    setState(() {
      if (_selectedMemberIds.contains(id)) {
        _selectedMemberIds.remove(id);
      } else {
        _selectedMemberIds.add(id);
      }
    });
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a list name')));
      return;
    }
    if (!_isDynamic && _selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one member')));
      return;
    }

    final repo = ref.read(distributionListsRepositoryProvider);

    if (widget.listToEdit != null) {
      final updatedList = widget.listToEdit!.copyWith(
        name: _nameController.text.trim(),
        memberIds: _isDynamic ? [] : _selectedMemberIds.toList(),
        isDynamic: _isDynamic,
        filterCriteria: _isDynamic ? _rules : [],
      );
      await repo.updateList(updatedList);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('List updated successfully!')));
    } else {
      final newList = DistributionList(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        memberIds: _isDynamic ? [] : _selectedMemberIds.toList(),
        isDynamic: _isDynamic,
        filterCriteria: _isDynamic ? _rules : [],
        createdAt: DateTime.now(),
      );
      await repo.createList(newList);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Distribution list created!'), backgroundColor: AppColors.lime500),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final eventsAsync = ref.watch(adminEventsProvider);
    final isEditing = widget.listToEdit != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final members = membersAsync.value ?? [];
    final events = eventsAsync.value ?? [];
    
    final calculatedReach = _isDynamic 
      ? SmartAudienceEvaluator.evaluate(members: members, rules: _rules, events: events).length
      : _selectedMemberIds.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: BoxyArtInputField(
                  label: 'List Name',
                  hint: 'e.g. Committee 2026',
                  controller: _nameController,
                ),
              ),
              const Divider(height: AppSpacing.xl),
              BoxyArtSwitchTile(
                icon: Icons.auto_awesome_rounded,
                label: 'Smart List',
                subtitle: 'Automatically update members based on rules',
                value: _isDynamic,
                onChanged: (v) {
                  setState(() => _isDynamic = v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x2l),

        if (_isDynamic) ...[
          // Reach Metric Card
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            backgroundColor: isDark ? AppColors.dark800 : AppColors.dark50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      '$calculatedReach',
                      style: AppTypography.displayHero.copyWith(
                        color: AppColors.lime500,
                        fontSize: 48,
                      ),
                    ),
                    Text(
                      'ESTIMATED REACH',
                      style: AppTypography.micro.copyWith(
                        fontWeight: AppTypography.weightBold,
                        letterSpacing: 2.0,
                        color: isDark ? AppColors.dark400 : AppColors.dark500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          const BoxyArtSectionTitle(title: 'Audience Rules', isPeeking: true),
          const SizedBox(height: AppSpacing.md),
          _buildRuleBuilder(),
        ] else ...[
          const BoxyArtSectionTitle(title: 'Selected Members', isPeeking: true),
          const SizedBox(height: AppSpacing.md),
        if (_selectedMemberIds.isNotEmpty)
          membersAsync.when(
            data: (members) {
              final selectedMembers = members.where((m) => _selectedMemberIds.contains(m.id)).toList();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedMembers.map((m) {
                  return Chip(
                    label: Text('${m.firstName} ${m.lastName}', style: AppTypography.label),
                    backgroundColor: isDark ? AppColors.dark800 : AppColors.dark100,
                    deleteIconColor: AppColors.coral500,
                    shape: RoundedRectangleBorder(borderRadius: AppShapes.md),
                    side: BorderSide.none,
                    onDeleted: () => _toggleMember(m.id),
                  );
                }).toList(),
              );
            },
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
          )
        else
          Center(
            child: Text(
              'No members selected yet',
              style: AppTypography.micro.copyWith(color: AppColors.textTertiary),
            ),
          ),
        
        const SizedBox(height: AppSpacing.x2l),
        const BoxyArtSectionTitle(title: 'Add Members', isPeeking: true),
        const SizedBox(height: AppSpacing.md),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              BoxyArtInputField(
                label: 'Search Members',
                hint: 'Search by name or email...',
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                membersAsync.when(
                  data: (members) {
                    final filtered = members.where((m) {
                      final term = _searchQuery.trim();
                      if (term.isEmpty) return false;
                      return (m.firstName + m.lastName).toLowerCase().contains(term) && !_selectedMemberIds.contains(m.id);
                    }).toList();
                    
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text('No results found', style: AppTypography.micro),
                      );
                    }

                    return Column(
                      children: filtered.map((m) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${m.firstName} ${m.lastName}', style: AppTypography.bodySmall.copyWith(fontWeight: AppTypography.weightBold)),
                        subtitle: Text(m.email, style: AppTypography.label),
                        trailing: Icon(Icons.add_circle_outline_rounded, color: theme.primaryColor),
                        onTap: () => _toggleMember(m.id),
                      )).toList(),
                    );
                  },
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: CircularProgressIndicator(),
                  )),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ],
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.x2l),
      BoxyArtButton(
        title: isEditing ? 'Save Changes' : 'Create Audience',
        onTap: _save,
        fullWidth: true,
      ),
    ],
  );
}

  Widget _buildRuleBuilder() {
    return Column(
      children: [
        ..._rules.asMap().entries.map((entry) {
          final index = entry.key;
          final rule = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: BoxyArtCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: BoxyArtDropdownField<AudienceProperty>(
                          label: 'Property',
                          value: rule.property,
                          items: AudienceProperty.values.map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                          )).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _rules[index] = rule.copyWith(property: v));
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral500),
                        onPressed: () {
                          setState(() => _rules.removeAt(index));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: BoxyArtDropdownField<FilterOperator>(
                          label: 'Operator',
                          value: rule.operator,
                          items: _getOperatorsForProperty(rule.property).map((op) => DropdownMenuItem(
                            value: op,
                            child: Text(_getOperatorName(op)),
                          )).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _rules[index] = rule.copyWith(operator: v));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 3,
                        child: BoxyArtFormField(
                          label: 'Value',
                          initialValue: rule.value,
                          onChanged: (v) {
                            _rules[index] = rule.copyWith(value: v);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        BoxyArtButton(
          title: 'Add Rule',
          isSecondary: true,
          icon: Icons.add_rounded,
          onTap: () {
            setState(() {
              _rules.add(const AudienceFilterRule(
                property: AudienceProperty.membershipStatus,
                operator: FilterOperator.equals,
                value: 'member',
              ));
            });
          },
        ),
      ],
    );
  }

  List<FilterOperator> _getOperatorsForProperty(AudienceProperty prop) {
    switch (prop) {
      case AudienceProperty.handicapIndex:
      case AudienceProperty.debtBalance:
        return [FilterOperator.equals, FilterOperator.greaterThan, FilterOperator.lessThan];
      case AudienceProperty.membershipStatus:
      case AudienceProperty.registrationStatus:
        return [FilterOperator.equals, FilterOperator.notEquals];
    }
  }

  String _getOperatorName(FilterOperator op) {
    switch (op) {
      case FilterOperator.equals: return 'Is';
      case FilterOperator.notEquals: return 'Is Not';
      case FilterOperator.greaterThan: return 'Greater than';
      case FilterOperator.lessThan: return 'Less than';
      case FilterOperator.contains: return 'Contains';
    }
  }
}
