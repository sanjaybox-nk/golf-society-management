import 'dart:convert';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:golf_society/utils/string_utils.dart';

enum HubTab { sponsorships, donations }

class AdminSponsorshipHubScreen extends ConsumerStatefulWidget {
  const AdminSponsorshipHubScreen({super.key});

  @override
  ConsumerState<AdminSponsorshipHubScreen> createState() => _AdminSponsorshipHubScreenState();
}

class _AdminSponsorshipHubScreenState extends ConsumerState<AdminSponsorshipHubScreen> {
  final _nameController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  
  // Financial Tracking Controllers
  final _amountController = TextEditingController();
  final _activityNameController = TextEditingController();
  final _richDescriptionController = quill.QuillController.basic();
  
  SponsorTier _selectedTier = SponsorTier.standard;
  bool _isActive = true;
  String? _editingId;
  String? _editingFinancialId;

  // Financial State
  String _selectedScope = 'season';
  String? _selectedEventId;
  bool _isPaymentPaid = false;

  // UI state
  bool _showForm = false;
  HubTab _currentTab = HubTab.sponsorships;

  @override
  void dispose() {
    _nameController.dispose();
    _logoUrlController.dispose();
    _websiteUrlController.dispose();
    _amountController.dispose();
    _activityNameController.dispose();
    _richDescriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _editingId = null;
      _editingFinancialId = null;
      _showForm = false;
      _nameController.clear();
      _logoUrlController.clear();
      _websiteUrlController.clear();
      _amountController.clear();
      _activityNameController.clear();
      _richDescriptionController.document = quill.Document();
      _selectedTier = SponsorTier.standard;
      _isActive = true;
      _selectedScope = 'season';
      _selectedEventId = null;
      _isPaymentPaid = false;
    });
  }

  Future<void> _pickImage(TextEditingController controller) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        controller.text = image.path;
      });
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final sponsorId = _editingId ?? const Uuid().v4();
    final brandDescriptionJson = jsonEncode(_richDescriptionController.document.toDelta().toJson());
    final isBrandDescriptionEmpty = _richDescriptionController.document.toPlainText().trim().isEmpty;

    final sponsor = Sponsor(
      id: sponsorId,
      name: name,
      logoUrl: _logoUrlController.text.trim().isEmpty ? null : _logoUrlController.text.trim(),
      websiteUrl: _websiteUrlController.text.trim().isEmpty ? null : _websiteUrlController.text.trim(),
      description: isBrandDescriptionEmpty ? null : brandDescriptionJson,
      tier: _selectedTier,
      isActive: _isActive,
    );

    // Save/Update Sponsor
    if (_editingId != null) {
      await ref.read(themeControllerProvider.notifier).updateSponsor(sponsor);
    } else {
      await ref.read(themeControllerProvider.notifier).addSponsor(sponsor);
    }

    // Optional: Record/Update Financial Entry
    final amountText = _amountController.text.replaceAll('£', '').trim();
    final amount = double.tryParse(amountText) ?? 0.0;
    
    if (amount > 0) {
      String recordScope;
      if (_selectedScope == 'bespoke') {
        recordScope = 'Bespoke: ${_activityNameController.text.isEmpty ? "Unnamed" : _activityNameController.text}';
      } else if (_selectedScope == 'event') {
        recordScope = 'Event';
      } else {
        recordScope = 'Season';
      }

      final entry = FinancialEntry(
        id: _editingFinancialId ?? DateTime.now().microsecondsSinceEpoch.toString(),
        type: 'Sponsorship',
        source: name,
        amount: amount,
        date: DateTime.now(),
        isPaid: _isPaymentPaid,
        sponsorId: sponsorId,
        scope: recordScope,
        eventId: (_selectedScope == 'event' || _selectedScope == 'bespoke') ? _selectedEventId : null,
        description: isBrandDescriptionEmpty ? null : brandDescriptionJson,
        logoUrl: sponsor.logoUrl,
      );
      
      if (_editingFinancialId != null) {
        await ref.read(themeControllerProvider.notifier).updateLedgerEntry(entry);
      } else {
        await ref.read(themeControllerProvider.notifier).addLedgerEntry(entry);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingId != null ? 'Partner updated' : 'Partner & Payment saved')),
      );
    }
    _resetForm();
  }


  void _loadSponsor(Sponsor sponsor) {
    setState(() {
      _editingId = sponsor.id;
      _showForm = true;
      _nameController.text = sponsor.name;
      _logoUrlController.text = sponsor.logoUrl ?? '';
      _websiteUrlController.text = sponsor.websiteUrl ?? '';
      
      if (sponsor.description != null && sponsor.description!.startsWith('[')) {
        try {
          _richDescriptionController.document = quill.Document.fromJson(jsonDecode(sponsor.description!));
        } catch (_) {
          _richDescriptionController.document = quill.Document();
        }
      } else {
        _richDescriptionController.document = quill.Document();
      }

      _selectedTier = sponsor.tier;
      _isActive = sponsor.isActive;
      
      // Load financial details if present
      final config = ref.read(themeControllerProvider);
      final relevantEntries = config.ledgerEntries
          .where((e) => e.sponsorId == sponsor.id && e.type == 'Sponsorship')
          .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      
      if (relevantEntries.isNotEmpty) {
        final entry = relevantEntries.first;
        _editingFinancialId = entry.id;
        _amountController.text = entry.amount.toStringAsFixed(0);
        _isPaymentPaid = entry.isPaid;
        
        final scope = entry.scope?.toLowerCase() ?? 'season';
        if (scope.contains('bespoke')) {
          _selectedScope = 'bespoke';
          _activityNameController.text = scope.split(':').last.trim();
        } else if (scope == 'event') {
          _selectedScope = 'event';
          _selectedEventId = entry.eventId;
        } else {
          _selectedScope = 'season';
        }
      } else {
        _editingFinancialId = null;
        _amountController.clear();
        _activityNameController.clear();
        _selectedScope = 'season';
        _selectedEventId = null;
        _isPaymentPaid = false;
      }
    });
  }

  Future<void> _removeSponsor(String id) async {
    final confirm = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Remove partner?',
      message: 'This will remove them from the visibility hub. Historical treasury records will remain intact.',
      confirmText: 'Remove',
    );

    if (confirm == true) {
      await ref.read(themeControllerProvider.notifier).removeSponsor(id);
    }
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(themeControllerProvider);
    final sponsors = config.sponsors;
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    // Group sponsors by tier
    final goldSponsors = sponsors.where((s) => s.tier == SponsorTier.gold).toList();
    final silverSponsors = sponsors.where((s) => s.tier == SponsorTier.silver).toList();
    final bronzeSponsors = sponsors.where((s) => s.tier == SponsorTier.bronze).toList();
    final standardSponsors = sponsors.where((s) => s.tier == SponsorTier.standard).toList();

    final orphanedEntries = config.ledgerEntries
        .where((e) => e.type == 'Sponsorship' && !config.sponsors.any((s) => s.id == e.sponsorId))
        .toList();

    final donationEntries = config.ledgerEntries
        .where((e) => e.type == 'Donation')
        .toList();

    return HeadlessScaffold(
      title: 'Sponsorship Hub',
      subtitle: 'Manage partners & branding',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () {
        if (_showForm) {
          setState(() {
            _showForm = false;
            _editingId = null;
            _resetForm();
          });
        } else {
          context.pop();
        }
      },
      slivers: [
        // 1. Tab Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.cardToLabel),
            child: ModernUnderlinedFilterBar<HubTab>(
              selectedValue: _currentTab,
              onTabSelected: (tab) => setState(() {
                _currentTab = tab;
                _showForm = false;
                _resetForm();
              }),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              isExpanded: true,
              tabs: const [
                ModernFilterTab(label: 'Sponsorships', value: HubTab.sponsorships, icon: Icons.handshake_rounded),
                ModernFilterTab(label: 'Donations', value: HubTab.donations, icon: Icons.volunteer_activism_rounded),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (_currentTab == HubTab.sponsorships) ...[
                if (!_showForm) ...[
                  BoxyArtButton(
                    title: 'Add Sponsor',
                    onTap: () => setState(() => _showForm = true),
                    fullWidth: true,
                  ),
                  
                  if (sponsors.isNotEmpty)
                    const BoxyArtSectionTitle(
                      title: 'Global Sponsorship',
                      isPeeking: true,
                    ),

                  if (goldSponsors.isNotEmpty) ...[
                    const BoxyArtSectionTitle(title: 'Gold Partners', isPeeking: true),
                    ..._buildSponsorList(goldSponsors, config.ledgerEntries, spacing),
                  ],

                  if (silverSponsors.isNotEmpty) ...[
                    const BoxyArtSectionTitle(title: 'Silver Partners', isPeeking: true),
                    ..._buildSponsorList(silverSponsors, config.ledgerEntries, spacing),
                  ],

                  if (bronzeSponsors.isNotEmpty) ...[
                    const BoxyArtSectionTitle(title: 'Bronze Partners', isPeeking: true),
                    ..._buildSponsorList(bronzeSponsors, config.ledgerEntries, spacing),
                  ],


                  if (standardSponsors.isNotEmpty) ...[
                    const BoxyArtSectionTitle(title: 'Standard Partners', isPeeking: true),
                    ..._buildSponsorList(standardSponsors, config.ledgerEntries, spacing),
                  ],

                  if (orphanedEntries.isNotEmpty) ...[
                    if (standardSponsors.isNotEmpty)
                      SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),
                    const BoxyArtSectionTitle(
                      title: 'Active Partners',
                      isPeeking: true,
                    ),
                    ..._buildLedgerList(
                      orphanedEntries, 
                      config.sponsors, 
                      spacing
                    ),
                  ],
                ],

                if (_showForm) ...[
                  const BoxyArtSectionTitle(title: 'Partner profile', isPeeking: true),
                  BoxyArtCard(
                    child: BoxyArtFormColumn(
                      children: [
                        BoxyArtInputField(
                          label: 'Name',
                          controller: _nameController,
                        ),
                        _buildUploadLabeledField(
                          label: 'Logo image',
                          controller: _logoUrlController,
                          onUpload: () => _pickImage(_logoUrlController),
                        ),
                        BoxyArtInputField(
                          label: 'Website URL',
                          controller: _websiteUrlController,
                        ),
                        BoxyArtDropdownField<SponsorTier>(
                          label: 'Sponsor tier',
                          value: _selectedTier,
                          items: SponsorTier.values.map((tier) {
                            return DropdownMenuItem(
                              value: tier,
                              child: Text(_capitalize(tier.name)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedTier = v!),
                        ),
                        
                        Row(
                          children: [
                            Expanded(
                              child: BoxyArtInputField(
                                label: 'Amount',
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: BoxyArtDropdownField<String>(
                                label: 'Scope',
                                value: _selectedScope,
                                items: const [
                                  DropdownMenuItem(value: 'season', child: Text('Season')),
                                  DropdownMenuItem(value: 'event', child: Text('Event')),
                                  DropdownMenuItem(value: 'bespoke', child: Text('Bespoke')),
                                ],
                                onChanged: (val) => setState(() => _selectedScope = val!),
                              ),
                            ),
                          ],
                        ),
                        
                        if (_selectedScope == 'event' || _selectedScope == 'bespoke')
                          ref.watch(eventsProvider).when(
                            data: (events) => BoxyArtDropdownField<String>(
                              label: 'Select target event',
                              value: _selectedEventId,
                              items: events.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title))).toList(),
                              onChanged: (val) => setState(() => _selectedEventId = val),
                            ),
                            loading: () => const BoxyArtLoadingCard(
                              useCard: false, 
                              isCompact: true, 
                              title: 'Searching fairway...',
                            ),
                            error: (err, stack) => const Text('Error loading events'),
                          ),

                        if (_selectedScope == 'bespoke')
                          BoxyArtInputField(
                            label: 'Activity name / hole #',
                            controller: _activityNameController,
                            hint: 'e.g. Dinner, Hole 1, Nearest Pin, etc.',
                          ),
                        
                        BoxyArtRichEditor(
                          label: 'Brand message / public description',
                          controller: _richDescriptionController,
                          placeholder: 'Describe the partner or add a specific message...',
                          minHeight: 120,
                        ),
                        
                        BoxyArtFormActionRow(
                          saveLabel: _editingId != null ? 'Update' : 'Save',
                          onSave: _submit,
                          onCancel: () => setState(() => _resetForm()),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              if (_currentTab == HubTab.donations) ...[
                if (!_showForm) ...[
                  BoxyArtButton(
                    title: 'Add donation',
                    onTap: () => setState(() => _showForm = true),
                    fullWidth: true,
                  ),
                  if (donationEntries.isNotEmpty) ...[
                    const BoxyArtSectionTitle(title: 'History'),
                    ...donationEntries.reversed.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _DonationTile(
                            entry: entry,
                            onEdit: (e) => setState(() {
                              _editingFinancialId = e.id;
                              _nameController.text = e.source;
                              _amountController.text = e.amount.toStringAsFixed(0);
                              _activityNameController.text = e.scope ?? '';
                              _isPaymentPaid = e.isPaid;
                              _showForm = true;
                            }),
                            onRemove: (id) => ref.read(themeControllerProvider.notifier).removeLedgerEntry(id),
                          ),
                        )),
                  ],
                ],

                if (_showForm) ...[
                  // DONATIONS VIEW (Relocated from Treasury)
                  const BoxyArtSectionTitle(title: 'Donation details', isPeeking: true),
                  BoxyArtCard(
                    child: BoxyArtFormColumn(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: BoxyArtInputField(
                                label: 'Amount',
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                prefixIcon: const Icon(Icons.currency_pound_rounded, size: 16),
                              ),
                            ),
                          ],
                        ),
                        BoxyArtInputField(
                          label: 'Supporter Name',
                          controller: _nameController,
                          hint: 'e.g. Local Golf Club, Personal Donation, etc.',
                        ),
                        BoxyArtInputField(
                          label: 'Reference / Notes',
                          controller: _activityNameController,
                          hint: 'Optional notes...',
                        ),
                        BoxyArtFormActionRow(
                          saveLabel: _editingFinancialId != null ? 'Update' : 'Record',
                          onSave: () async {
                            final name = _nameController.text.trim();
                            final amount = double.tryParse(_amountController.text) ?? 0.0;
                            if (name.isEmpty || amount <= 0) return;

                            final entry = FinancialEntry(
                              id: _editingFinancialId ?? DateTime.now().microsecondsSinceEpoch.toString(),
                              type: 'Donation',
                              source: name,
                              amount: amount,
                              date: DateTime.now(),
                              isPaid: _isPaymentPaid,
                              scope: _activityNameController.text.isEmpty ? null : _activityNameController.text,
                            );

                            if (_editingFinancialId != null) {
                              await ref.read(themeControllerProvider.notifier).updateLedgerEntry(entry);
                            } else {
                              await ref.read(themeControllerProvider.notifier).addLedgerEntry(entry);
                            }

                            if (!context.mounted) return;
                            _resetForm();
                            setState(() => _showForm = false);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donation recorded')));
                          },
                          onCancel: () => setState(() {
                            _resetForm();
                            _showForm = false;
                          }),
                        ),
                      ],
                    ),
                  ),
                ],

              ],

              SizedBox(height: spacing?.cardToLabel ?? 100),
            ]),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSponsorList(List<Sponsor> sponsors, List<FinancialEntry> ledger, AppSpacingTokens? spacing) {
    final list = <Widget>[];
    for (int i = 0; i < sponsors.length; i++) {
      final sponsor = sponsors[i];
      // Find ALL financial entries for this sponsor
      final relevantEntries = ledger.where((e) => e.sponsorId == sponsor.id).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      
      // If multiple entries exist, show them as a list under the tile or similar
      // For now, we'll pass the list to the tile to handle multi-row display
      list.add(_SponsorTile(
        sponsor: sponsor, 
        entries: relevantEntries,
        onEdit: _loadSponsor, 
        onRemove: _removeSponsor
      ));
      if (i < sponsors.length - 1) {
        list.add(SizedBox(height: spacing?.cardToCard ?? AppSpacing.md));
      }
    }
    return list;
  }

  List<Widget> _buildLedgerList(List<FinancialEntry> entries, List<Sponsor> sponsors, AppSpacingTokens? spacing) {
    final list = <Widget>[];
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final sponsor = sponsors.where((s) => s.id == entry.sponsorId).firstOrNull;
      
      list.add(_SponsorshipLedgerTile(
        entry: entry,
        sponsor: sponsor,
        onTap: () {
          if (sponsor != null) {
            _loadSponsor(sponsor);
          } else {
            // Seed a new sponsor from this entry
            setState(() {
              _showForm = true;
              _editingId = null;
              _nameController.text = entry.source;
              _logoUrlController.text = entry.logoUrl ?? '';
              _amountController.text = entry.amount.toStringAsFixed(0);
              _selectedScope = entry.scope ?? 'season';
            });
          }
        },
      ));
      if (i < entries.length - 1) {
        list.add(SizedBox(height: spacing?.cardToCard ?? AppSpacing.md));
      }
    }
    return list;
  }

  Widget _buildUploadLabeledField({required String label, required TextEditingController controller, required VoidCallback onUpload}) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();

    return BoxyArtFormColumn(
      spacing: spacing?.labelToCard ?? AppSpacing.xs,
      children: [
        if (label.isNotEmpty)
          Text(
            label.toUpperCase(),
            style: AppTypography.micro.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, 
            vertical: spacing?.labelToCard ?? 16,
          ),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? AppColors.dark600 : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(theme.extension<AppShapeTokens>()?.inputRadius ?? 12),
            border: Border.all(
              color: theme.brightness == Brightness.dark ? AppColors.dark500 : AppColors.lightBorder,
              width: AppShapes.borderThin,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.text.isEmpty ? 'No file selected' : controller.text.split('/').last,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: AppTypography.sizeBodySmall,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              BoxyArtButton(
                title: 'Upload',
                onTap: onUpload,
                isSecondary: true,
                isSmall: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String formatSponsorshipScope(FinancialEntry entry, WidgetRef ref) {
  if (entry.scope?.toLowerCase() == 'event') {
    final events = ref.read(eventsProvider).value ?? [];
    final event = events.where((e) => e.id == entry.eventId).firstOrNull;
    if (event != null) return toTitleCase(event.title);
    if (entry.eventId == 'event_invit_1') return 'Invitational Games';
    return 'Event';
  }
  return toSentenceCase(entry.scope ?? 'General');
}

class _SponsorshipLedgerTile extends ConsumerWidget {
  final FinancialEntry entry;
  final Sponsor? sponsor;
  final VoidCallback? onTap;
  const _SponsorshipLedgerTile({required this.entry, this.sponsor, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BoxyArtSponsorshipCard(
      name: entry.source,
      logoUrl: entry.logoUrl,
      entries: [entry],
      isActive: sponsor?.isActive ?? true,
      onToggleActive: sponsor != null ? () {
        ref.read(themeControllerProvider.notifier).updateSponsor(
          sponsor!.copyWith(isActive: !sponsor!.isActive),
        );
      } : () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visibility status for this entry is currently tied to its historical record.')),
        );
      },
      onTogglePaid: (e) {
        ref.read(themeControllerProvider.notifier).updateLedgerEntry(
          e.copyWith(isPaid: !e.isPaid),
        );
      },
      onTap: onTap,
    );
  }
}

class _SponsorTile extends ConsumerWidget {
  final Sponsor sponsor;
  final List<FinancialEntry> entries;
  final Function(Sponsor) onEdit;
  final Function(String) onRemove;

  const _SponsorTile({
    required this.sponsor,
    this.entries = const [],
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('sponsor_${sponsor.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.coral500,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pureWhite),
      ),
      onDismissed: (_) => onRemove(sponsor.id),
      confirmDismiss: (_) async {
         onRemove(sponsor.id);
         return false; 
      },
      child: BoxyArtSponsorshipCard(
        name: sponsor.name,
        logoUrl: sponsor.logoUrl,
        websiteUrl: sponsor.websiteUrl,
        entries: entries,
        isActive: sponsor.isActive,
        onToggleActive: () {
          ref.read(themeControllerProvider.notifier).updateSponsor(
            sponsor.copyWith(isActive: !sponsor.isActive),
          );
        },
        onTogglePaid: (entry) {
          ref.read(themeControllerProvider.notifier).updateLedgerEntry(
            entry.copyWith(isPaid: !entry.isPaid),
          );
        },
        onTap: () => onEdit(sponsor),
      ),
    );
  }
}

/// The unified sponsorship card used across the hub.
class BoxyArtSponsorshipCard extends ConsumerWidget {
  final String name;
  final String? logoUrl;
  final String? websiteUrl;
  final List<FinancialEntry> entries;
  final bool isActive;
  final VoidCallback? onToggleActive;
  final ValueChanged<FinancialEntry>? onTogglePaid;
  final VoidCallback? onTap;

  const BoxyArtSponsorshipCard({
    super.key,
    required this.name,
    this.logoUrl,
    this.websiteUrl,
    this.entries = const [],
    this.isActive = true,
    this.onToggleActive,
    this.onTogglePaid,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SponsorLogo(url: logoUrl, size: 48),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toTitleCase(name),
                  style: AppTypography.body.copyWith(
                    color: isActive 
                        ? (Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark900) 
                        : AppColors.textTertiary,
                    fontWeight: AppTypography.weightBold,
                    fontSize: 16,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entries.isNotEmpty)
                  ...entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      '${formatSponsorshipScope(entry, ref)} • £${entry.amount.toStringAsFixed(0)}',
                      style: AppTypography.label.copyWith(color: AppColors.dark300),
                    ),
                  ))
                else if (websiteUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      websiteUrl!,
                      style: AppTypography.micro.copyWith(color: AppColors.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Dedicated Status Column (Left-aligned internally)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoxyArtStatusPill(
                isPaid: isActive,
                paidLabel: 'Visible',
                dueLabel: 'Hidden',
                onToggle: onToggleActive,
              ),
              if (entries.isNotEmpty)
                ...entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: BoxyArtStatusPill(
                    isPaid: entry.isPaid,
                    paidLabel: 'Paid',
                    dueLabel: 'Unpaid',
                    onToggle: () => onTogglePaid?.call(entry),
                  ),
                )),
            ],
          ),
        ],
      ),
    );
  }
}

class _SponsorLogo extends StatelessWidget {
  final String? url;
  final double size;

  const _SponsorLogo({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.dark300.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.business_rounded, color: AppColors.textTertiary),
      );
    }

    final isUrlLocal = (url!.startsWith('/') || url!.contains('cache') || url!.contains('com.google.android'));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.dark300.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isUrlLocal
            ? Image.file(
                File(url!),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.business_rounded, color: AppColors.textTertiary),
              )
            : BoxyArtImage(
                url: url!,
                errorWidget: const Icon(Icons.business_rounded, color: AppColors.textTertiary),
              ),
      ),
    );
  }
}

class _DonationTile extends ConsumerWidget {
  final FinancialEntry entry;
  final ValueChanged<FinancialEntry> onEdit;
  final ValueChanged<String> onRemove;

  const _DonationTile({
    required this.entry,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('donation_${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.coral500,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pureWhite),
      ),
      onDismissed: (_) => onRemove(entry.id),
      confirmDismiss: (_) async {
         onRemove(entry.id);
         return false; 
      },
      child: BoxyArtCard(
        onTap: () => onEdit(entry),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.dark300.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.textTertiary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toTitleCase(entry.source),
                    style: AppTypography.body.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark900,
                      fontWeight: AppTypography.weightBold,
                      fontSize: 16,
                      letterSpacing: -0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '£${entry.amount.toStringAsFixed(0)}${entry.scope != null ? ' • ${entry.scope}' : ''}',
                    style: AppTypography.label.copyWith(color: AppColors.dark300),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            BoxyArtStatusPill(
              isPaid: entry.isPaid,
              paidLabel: 'Paid',
              dueLabel: 'Unpaid',
              onToggle: () {
                ref.read(themeControllerProvider.notifier).updateLedgerEntry(
                  entry.copyWith(isPaid: !entry.isPaid),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
