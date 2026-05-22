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

enum _FormSection { none, sponsorships, donations, expenditure }

class AdminSponsorshipHubScreen extends ConsumerStatefulWidget {
  const AdminSponsorshipHubScreen({super.key});

  @override
  ConsumerState<AdminSponsorshipHubScreen> createState() => _AdminSponsorshipHubScreenState();
}

class _AdminSponsorshipHubScreenState extends ConsumerState<AdminSponsorshipHubScreen> {
  // Sponsor form controllers
  final _nameController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  final _richDescriptionController = quill.QuillController.basic();
  SponsorTier _selectedTier = SponsorTier.partner;
  bool _isActive = true;
  String? _editingId;
  String? _editingFinancialId;
  String _selectedScope = 'season';
  String? _selectedEventId;
  bool _isPaymentPaid = false;

  // Shared financial controllers
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _notesController = TextEditingController();
  String _expenditureCategory = 'Merchandise';

  // Section state
  _FormSection _formSection = _FormSection.none;
  final Set<String> _expanded = {'sponsorships'};

  @override
  void dispose() {
    _nameController.dispose();
    _logoUrlController.dispose();
    _websiteUrlController.dispose();
    _richDescriptionController.dispose();
    _amountController.dispose();
    _sourceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _formSection = _FormSection.none;
      _editingId = null;
      _editingFinancialId = null;
      _nameController.clear();
      _logoUrlController.clear();
      _websiteUrlController.clear();
      _richDescriptionController.document = quill.Document();
      _selectedTier = SponsorTier.partner;
      _isActive = true;
      _selectedScope = 'season';
      _selectedEventId = null;
      _isPaymentPaid = false;
      _amountController.clear();
      _sourceController.clear();
      _notesController.clear();
      _expenditureCategory = 'Merchandise';
    });
  }

  Future<void> _pickImage(TextEditingController controller) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => controller.text = image.path);
  }

  Future<void> _submitSponsor() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final sponsorId = _editingId ?? const Uuid().v4();
    final descJson = jsonEncode(_richDescriptionController.document.toDelta().toJson());
    final descEmpty = _richDescriptionController.document.toPlainText().trim().isEmpty;

    final sponsor = Sponsor(
      id: sponsorId,
      name: name,
      logoUrl: _logoUrlController.text.trim().isEmpty ? null : _logoUrlController.text.trim(),
      websiteUrl: _websiteUrlController.text.trim().isEmpty ? null : _websiteUrlController.text.trim(),
      description: descEmpty ? null : descJson,
      tier: _selectedTier,
      isActive: _isActive,
    );

    if (_editingId != null) {
      await ref.read(themeControllerProvider.notifier).updateSponsor(sponsor);
    } else {
      await ref.read(themeControllerProvider.notifier).addSponsor(sponsor);
    }

    final amount = double.tryParse(_amountController.text.replaceAll('£', '').trim()) ?? 0.0;
    if (amount > 0) {
      final recordScope = _selectedScope == 'event' ? 'Event' : 'Season';

      final entry = FinancialEntry(
        id: _editingFinancialId ?? DateTime.now().microsecondsSinceEpoch.toString(),
        type: 'Sponsorship',
        source: name,
        amount: amount,
        date: DateTime.now(),
        isPaid: _isPaymentPaid,
        sponsorId: sponsorId,
        scope: recordScope,
        eventId: _selectedScope == 'event' ? _selectedEventId : null,
        description: descEmpty ? null : descJson,
        logoUrl: sponsor.logoUrl,
      );

      if (_editingFinancialId != null) {
        await ref.read(themeControllerProvider.notifier).updateLedgerEntry(entry);
      } else {
        await ref.read(themeControllerProvider.notifier).addLedgerEntry(entry);
      }
    }

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_editingId != null ? 'Partner updated' : 'Partner saved')));
    _resetForm();
  }

  Future<void> _submitDonation() async {
    final name = _sourceController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (name.isEmpty || amount <= 0) return;

    final entry = FinancialEntry(
      id: _editingFinancialId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: 'Donation',
      source: name,
      amount: amount,
      date: DateTime.now(),
      isPaid: _isPaymentPaid,
      scope: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (_editingFinancialId != null) {
      await ref.read(themeControllerProvider.notifier).updateLedgerEntry(entry);
    } else {
      await ref.read(themeControllerProvider.notifier).addLedgerEntry(entry);
    }

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donation recorded')));
    _resetForm();
  }

  Future<void> _submitExpenditure() async {
    final desc = _sourceController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (desc.isEmpty || amount <= 0) return;

    final entry = FinancialEntry(
      id: _editingFinancialId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: 'Expenditure',
      source: desc,
      amount: amount,
      date: DateTime.now(),
      isPaid: true,
      scope: _expenditureCategory,
      description: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (_editingFinancialId != null) {
      await ref.read(themeControllerProvider.notifier).updateLedgerEntry(entry);
    } else {
      await ref.read(themeControllerProvider.notifier).addLedgerEntry(entry);
    }

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expenditure recorded')));
    _resetForm();
  }

  void _loadSponsor(Sponsor sponsor) {
    final config = ref.read(themeControllerProvider);
    final entries = config.ledgerEntries.where((e) => e.sponsorId == sponsor.id && e.type == 'Sponsorship').toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _editingId = sponsor.id;
      _formSection = _FormSection.sponsorships;
      _expanded.add('sponsorships');
      _nameController.text = sponsor.name;
      _logoUrlController.text = sponsor.logoUrl ?? '';
      _websiteUrlController.text = sponsor.websiteUrl ?? '';
      if (sponsor.description != null && sponsor.description!.startsWith('[')) {
        try { _richDescriptionController.document = quill.Document.fromJson(jsonDecode(sponsor.description!)); } catch (_) {}
      }
      _selectedTier = sponsor.tier;
      _isActive = sponsor.isActive;

      if (entries.isNotEmpty) {
        final e = entries.first;
        _editingFinancialId = e.id;
        _amountController.text = e.amount.toStringAsFixed(0);
        _isPaymentPaid = e.isPaid;
        final scope = e.scope?.toLowerCase() ?? 'season';
        if (scope == 'event') {
          _selectedScope = 'event';
          _selectedEventId = e.eventId;
        } else {
          _selectedScope = 'season';
        }
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
    if (confirm == true) await ref.read(themeControllerProvider.notifier).removeSponsor(id);
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(themeControllerProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    final sponsors = config.sponsors;
    final sponsorEntries = config.ledgerEntries.where((e) => e.type == 'Sponsorship').toList();
    final donationEntries = config.ledgerEntries.where((e) => e.type == 'Donation').toList();
    final expenditureEntries = config.ledgerEntries.where((e) => e.type == 'Expenditure').toList();

    final totalSponsorships = sponsorEntries.fold(0.0, (s, e) => s + e.amount);
    final totalDonations = donationEntries.fold(0.0, (s, e) => s + e.amount);
    final totalExpenditure = expenditureEntries.fold(0.0, (s, e) => s + e.amount);
    final netPosition = totalSponsorships + totalDonations - totalExpenditure;
    final isProfit = netPosition >= 0;

    final orphanedEntries = sponsorEntries.where((e) => !config.sponsors.any((s) => s.id == e.sponsorId)).toList();

    return HeadlessScaffold(
      title: 'Finance Hub',
      subtitle: 'Society-level income & expenditure',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () {
        if (_formSection != _FormSection.none) {
          _resetForm();
        } else {
          context.pop();
        }
      },
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Net position hero
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.standard),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Society net position', style: AppTypography.micro.copyWith(color: AppColors.dark400)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${isProfit ? '+' : ''}£${netPosition.toStringAsFixed(2)}',
                          style: AppTypography.display.copyWith(
                            color: isProfit ? AppColors.lime500 : AppColors.coral500,
                          ),
                        ),
                      ],
                    ),
                    BoxyArtIconBadge(
                      icon: isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: isProfit ? AppColors.lime500 : AppColors.coral500,
                      isTinted: true,
                    ),
                  ],
                ),
              ),

              const BoxyArtSectionTitle(title: 'Sponsorships', followsCard: true),
              _FinanceSection(
                title: 'Sponsorships',
                icon: Icons.handshake_rounded,
                total: totalSponsorships,
                isIncome: true,
                isExpanded: _expanded.contains('sponsorships'),
                onToggle: () => setState(() {
                  if (_expanded.contains('sponsorships')) {
                    _expanded.remove('sponsorships');
                    if (_formSection == _FormSection.sponsorships) _resetForm();
                  } else {
                    _expanded.add('sponsorships');
                  }
                }),
                children: _formSection == _FormSection.sponsorships
                    ? [_buildSponsorForm(context)]
                    : [
                        ...(() {
                          final goldSponsors = sponsors.where((s) => s.tier == SponsorTier.gold).toList();
                          final silverSponsors = sponsors.where((s) => s.tier == SponsorTier.silver).toList();
                          final bronzeSponsors = sponsors.where((s) => s.tier == SponsorTier.bronze).toList();
                          final partnerSponsors = sponsors.where((s) => s.tier == SponsorTier.partner).toList();
                          return [
                            if (goldSponsors.isNotEmpty) ...[
                              const BoxyArtSectionTitle(title: 'Gold', isPeeking: true, horizontalPadding: 0),
                              ..._buildSponsorList(goldSponsors, config.ledgerEntries, spacing),
                            ],
                            if (silverSponsors.isNotEmpty) ...[
                              const BoxyArtSectionTitle(title: 'Silver', isPeeking: true, horizontalPadding: 0),
                              ..._buildSponsorList(silverSponsors, config.ledgerEntries, spacing),
                            ],
                            if (bronzeSponsors.isNotEmpty) ...[
                              const BoxyArtSectionTitle(title: 'Bronze', isPeeking: true, horizontalPadding: 0),
                              ..._buildSponsorList(bronzeSponsors, config.ledgerEntries, spacing),
                            ],
                            if (partnerSponsors.isNotEmpty) ...[
                              const BoxyArtSectionTitle(title: 'Partner', isPeeking: true, horizontalPadding: 0),
                              ..._buildSponsorList(partnerSponsors, config.ledgerEntries, spacing),
                            ],
                            if (orphanedEntries.isNotEmpty) ...[
                              const BoxyArtSectionTitle(title: 'Unlinked entries', isPeeking: true, horizontalPadding: 0),
                              ..._buildLedgerList(orphanedEntries, config.sponsors, spacing),
                            ],
                            if (sponsors.isEmpty && orphanedEntries.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.atomic),
                                child: Text('No sponsors added yet', style: AppTypography.bodySmall.copyWith(color: AppColors.dark300)),
                              ),
                            const SizedBox(height: AppSpacing.atomic),
                            BoxyArtButton(
                              title: 'Add Sponsor',
                              icon: Icons.add_rounded,
                              isTinted: true,
                              isPrimary: false,
                              fullWidth: true,
                              onTap: () => setState(() {
                                _formSection = _FormSection.sponsorships;
                                _expanded.add('sponsorships');
                              }),
                            ),
                          ];
                        })(),
                      ],
              ),

              const BoxyArtSectionTitle(title: 'Donations', followsCard: true),
              _FinanceSection(
                title: 'Donations',
                icon: Icons.volunteer_activism_rounded,
                total: totalDonations,
                isIncome: true,
                isExpanded: _expanded.contains('donations'),
                onToggle: () => setState(() {
                  if (_expanded.contains('donations')) {
                    _expanded.remove('donations');
                    if (_formSection == _FormSection.donations) _resetForm();
                  } else {
                    _expanded.add('donations');
                  }
                }),
                children: _formSection == _FormSection.donations
                    ? [_buildDonationForm(context)]
                    : [
                        if (donationEntries.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.atomic),
                            child: Text('No donations recorded yet', style: AppTypography.bodySmall.copyWith(color: AppColors.dark300)),
                          ),
                        ...donationEntries.reversed.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.atomic),
                          child: _DonationTile(
                            entry: entry,
                            onEdit: (e) => setState(() {
                              _editingFinancialId = e.id;
                              _sourceController.text = e.source;
                              _amountController.text = e.amount.toStringAsFixed(0);
                              _notesController.text = e.scope ?? '';
                              _isPaymentPaid = e.isPaid;
                              _formSection = _FormSection.donations;
                              _expanded.add('donations');
                            }),
                            onRemove: (id) => ref.read(themeControllerProvider.notifier).removeLedgerEntry(id),
                          ),
                        )),
                        const SizedBox(height: AppSpacing.atomic),
                        BoxyArtButton(
                          title: 'Add Donation',
                          icon: Icons.add_rounded,
                          isTinted: true,
                          isPrimary: false,
                          fullWidth: true,
                          onTap: () => setState(() {
                            _formSection = _FormSection.donations;
                            _expanded.add('donations');
                          }),
                        ),
                      ],
              ),

              const BoxyArtSectionTitle(title: 'Expenditure', followsCard: true),
              _FinanceSection(
                title: 'Expenditure',
                icon: Icons.shopping_bag_rounded,
                total: totalExpenditure,
                isIncome: false,
                isExpanded: _expanded.contains('expenditure'),
                onToggle: () => setState(() {
                  if (_expanded.contains('expenditure')) {
                    _expanded.remove('expenditure');
                    if (_formSection == _FormSection.expenditure) _resetForm();
                  } else {
                    _expanded.add('expenditure');
                  }
                }),
                children: _formSection == _FormSection.expenditure
                    ? [_buildExpenditureForm(context)]
                    : [
                        if (expenditureEntries.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.atomic),
                            child: Text('No expenditure recorded yet', style: AppTypography.bodySmall.copyWith(color: AppColors.dark300)),
                          ),
                        ...expenditureEntries.reversed.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.atomic),
                          child: _ExpenditureTile(
                            entry: entry,
                            onEdit: (e) => setState(() {
                              _editingFinancialId = e.id;
                              _sourceController.text = e.source;
                              _amountController.text = e.amount.toStringAsFixed(0);
                              _notesController.text = e.description ?? '';
                              _expenditureCategory = e.scope ?? 'Merchandise';
                              _formSection = _FormSection.expenditure;
                              _expanded.add('expenditure');
                            }),
                            onRemove: (id) => ref.read(themeControllerProvider.notifier).removeLedgerEntry(id),
                          ),
                        )),
                        const SizedBox(height: AppSpacing.atomic),
                        BoxyArtButton(
                          title: 'Add Expenditure',
                          icon: Icons.add_rounded,
                          isTinted: true,
                          isPrimary: false,
                          fullWidth: true,
                          onTap: () => setState(() {
                            _formSection = _FormSection.expenditure;
                            _expanded.add('expenditure');
                          }),
                        ),
                      ],
              ),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSponsorForm(BuildContext context) {
    return BoxyArtFormColumn(
        children: [
          BoxyArtInputField(label: 'Name', controller: _nameController),
          _buildUploadField('Logo image', _logoUrlController, () => _pickImage(_logoUrlController)),
          BoxyArtInputField(label: 'Website URL', controller: _websiteUrlController),
          BoxyArtDropdownField<String>(
            label: 'Scope',
            value: _selectedScope,
            items: const [
              DropdownMenuItem(value: 'season', child: Text('Season')),
              DropdownMenuItem(value: 'event', child: Text('Event')),
            ],
            onChanged: (val) => setState(() => _selectedScope = val!),
          ),
          if (_selectedScope == 'season')
            BoxyArtDropdownField<SponsorTier>(
              label: 'Sponsor tier',
              value: _selectedTier,
              items: SponsorTier.values.map((t) => DropdownMenuItem(
                value: t,
                child: Text(_capitalize(t == SponsorTier.partner ? 'Partner' : t.name)),
              )).toList(),
              onChanged: (v) => setState(() => _selectedTier = v!),
            ),
          if (_selectedScope == 'event')
            ref.watch(eventsProvider).when(
              data: (events) => BoxyArtDropdownField<String>(
                label: 'Target event',
                value: _selectedEventId,
                items: events.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title))).toList(),
                onChanged: (val) => setState(() => _selectedEventId = val),
              ),
              loading: () => const BoxyArtLoadingCard(useCard: false, isCompact: true, title: 'Loading events...'),
              error: (e, st) => const Text('Error loading events'),
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
            ],
          ),
          BoxyArtRichEditor(
            label: 'Brand message',
            controller: _richDescriptionController,
            placeholder: 'Describe the partner...',
            minHeight: 120,
          ),
          BoxyArtFormActionRow(
            saveLabel: _editingId != null ? 'Update' : 'Save',
            onSave: _submitSponsor,
            onCancel: _resetForm,
          ),
        ],
      );
  }

  Widget _buildDonationForm(BuildContext context) {
    return BoxyArtFormColumn(
        children: [
          BoxyArtInputField(
            label: 'Amount',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(Icons.currency_pound_rounded, size: 16),
          ),
          BoxyArtInputField(label: 'Supporter name', controller: _sourceController),
          BoxyArtInputField(label: 'Notes', controller: _notesController, hint: 'Optional...'),
          BoxyArtFormActionRow(
            saveLabel: _editingFinancialId != null ? 'Update' : 'Record',
            onSave: _submitDonation,
            onCancel: _resetForm,
          ),
        ],
      );
  }

  Widget _buildExpenditureForm(BuildContext context) {
    return BoxyArtFormColumn(
        children: [
          BoxyArtInputField(label: 'Description', controller: _sourceController, hint: 'e.g. Polo shirts × 40'),
          BoxyArtDropdownField<String>(
            label: 'Category',
            value: _expenditureCategory,
            items: const [
              DropdownMenuItem(value: 'Merchandise', child: Text('Merchandise')),
              DropdownMenuItem(value: 'Equipment', child: Text('Equipment')),
              DropdownMenuItem(value: 'Venue', child: Text('Venue')),
              DropdownMenuItem(value: 'Printing', child: Text('Printing')),
              DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _expenditureCategory = v!),
          ),
          BoxyArtInputField(
            label: 'Amount',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(Icons.currency_pound_rounded, size: 16),
          ),
          BoxyArtInputField(label: 'Notes', controller: _notesController, hint: 'Optional...'),
          BoxyArtFormActionRow(
            saveLabel: _editingFinancialId != null ? 'Update' : 'Record',
            onSave: _submitExpenditure,
            onCancel: _resetForm,
          ),
        ],
      );
  }

  List<Widget> _buildSponsorList(List<Sponsor> sponsors, List<FinancialEntry> ledger, AppSpacingTokens? spacing) {
    return [
      for (int i = 0; i < sponsors.length; i++) ...[
        _SponsorTile(
          sponsor: sponsors[i],
          entries: ledger.where((e) => e.sponsorId == sponsors[i].id).toList()..sort((a, b) => b.date.compareTo(a.date)),
          onEdit: _loadSponsor,
          onRemove: _removeSponsor,
        ),
        if (i < sponsors.length - 1) SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
      ],
    ];
  }

  List<Widget> _buildLedgerList(List<FinancialEntry> entries, List<Sponsor> sponsors, AppSpacingTokens? spacing) {
    return [
      for (int i = 0; i < entries.length; i++) ...[
        _SponsorshipLedgerTile(
          entry: entries[i],
          sponsor: sponsors.where((s) => s.id == entries[i].sponsorId).firstOrNull,
          onTap: () {
            final sponsor = sponsors.where((s) => s.id == entries[i].sponsorId).firstOrNull;
            if (sponsor != null) {
              _loadSponsor(sponsor);
            } else {
              setState(() {
                _formSection = _FormSection.sponsorships;
                _expanded.add('sponsorships');
                _nameController.text = entries[i].source;
                _logoUrlController.text = entries[i].logoUrl ?? '';
                _amountController.text = entries[i].amount.toStringAsFixed(0);
                _selectedScope = entries[i].scope ?? 'season';
              });
            }
          },
        ),
        if (i < entries.length - 1) SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
      ],
    ];
  }

  Widget _buildUploadField(String label, TextEditingController controller, VoidCallback onUpload) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();
    return BoxyArtFormColumn(
      spacing: spacing?.labelToCard ?? AppSpacing.xs,
      children: [
        if (label.isNotEmpty)
          Text(label.toUpperCase(), style: AppTypography.micro.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
            letterSpacing: AppTypography.lsLabel,
          )),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: spacing?.labelToCard ?? 16),
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
                  style: AppTypography.body.copyWith(color: AppColors.textTertiary, fontSize: AppTypography.sizeBodySmall),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              BoxyArtButton(title: 'Upload', onTap: onUpload, isSecondary: true, isSmall: true),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Finance section card ───────────────────────────────────────────────────────

class _FinanceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final double total;
  final bool isIncome;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _FinanceSection({
    required this.title,
    required this.icon,
    required this.total,
    required this.isIncome,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = isIncome ? AppColors.lime500 : AppColors.coral500;

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.atomic),
              child: Row(
                children: [
                  BoxyArtIconBadge(icon: icon, color: valueColor, isTinted: true),
                  const SizedBox(width: AppSpacing.standard),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.body.copyWith(
                        fontWeight: AppTypography.weightBold,
                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                      ),
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}£${total.toStringAsFixed(2)}',
                    style: AppTypography.body.copyWith(fontWeight: AppTypography.weightHeavy, color: valueColor),
                  ),
                  const SizedBox(width: AppSpacing.atomic),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: AppAnimations.fast,
                    child: Icon(Icons.keyboard_arrow_down_rounded, size: AppShapes.iconSm, color: AppColors.dark400),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: AppAnimations.medium,
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.standard, 0, AppSpacing.standard, AppSpacing.atomic),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BoxyArtDivider(),
                        const SizedBox(height: AppSpacing.atomic),
                        ...children,
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Expenditure tile ──────────────────────────────────────────────────────────

class _ExpenditureTile extends ConsumerWidget {
  final FinancialEntry entry;
  final ValueChanged<FinancialEntry> onEdit;
  final ValueChanged<String> onRemove;

  const _ExpenditureTile({required this.entry, required this.onEdit, required this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: Key('exp_${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(color: AppColors.coral500, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pureWhite),
      ),
      confirmDismiss: (_) async { onRemove(entry.id); return false; },
      child: BoxyArtCard(
        onTap: () => onEdit(entry),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            BoxyArtIconBadge(icon: Icons.shopping_bag_rounded, color: AppColors.coral500, isTinted: true),
            const SizedBox(width: AppSpacing.standard),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toSentenceCase(entry.source),
                    style: AppTypography.body.copyWith(
                      color: isDark ? AppColors.pureWhite : AppColors.dark900,
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
                  Text(
                    entry.scope ?? 'Other',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.dark400),
                  ),
                ],
              ),
            ),
            Text(
              '-£${entry.amount.toStringAsFixed(2)}',
              style: AppTypography.body.copyWith(fontWeight: AppTypography.weightHeavy, color: AppColors.coral500),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Existing widgets (unchanged) ──────────────────────────────────────────────

String formatSponsorshipScope(FinancialEntry entry, WidgetRef ref) {
  if (entry.scope?.toLowerCase() == 'event') {
    final events = ref.read(eventsProvider).value ?? [];
    final event = events.where((e) => e.id == entry.eventId).firstOrNull;
    if (event != null) return toTitleCase(event.title);
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
      onToggleActive: sponsor != null
          ? () => ref.read(themeControllerProvider.notifier).updateSponsor(sponsor!.copyWith(isActive: !sponsor!.isActive))
          : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visibility tied to historical record.'))),
      onTogglePaid: (e) => ref.read(themeControllerProvider.notifier).updateLedgerEntry(e.copyWith(isPaid: !e.isPaid)),
      onTap: onTap,
    );
  }
}

class _SponsorTile extends ConsumerWidget {
  final Sponsor sponsor;
  final List<FinancialEntry> entries;
  final Function(Sponsor) onEdit;
  final Function(String) onRemove;

  const _SponsorTile({required this.sponsor, this.entries = const [], required this.onEdit, required this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('sponsor_${sponsor.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(color: AppColors.coral500, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pureWhite),
      ),
      confirmDismiss: (_) async { onRemove(sponsor.id); return false; },
      child: BoxyArtSponsorshipCard(
        name: sponsor.name,
        logoUrl: sponsor.logoUrl,
        websiteUrl: sponsor.websiteUrl,
        entries: entries,
        isActive: sponsor.isActive,
        onToggleActive: () => ref.read(themeControllerProvider.notifier).updateSponsor(sponsor.copyWith(isActive: !sponsor.isActive)),
        onTogglePaid: (entry) => ref.read(themeControllerProvider.notifier).updateLedgerEntry(entry.copyWith(isPaid: !entry.isPaid)),
        onTap: () => onEdit(sponsor),
      ),
    );
  }
}

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
                    color: isActive ? (Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark900) : AppColors.textTertiary,
                    fontWeight: AppTypography.weightBold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entries.isNotEmpty)
                  ...entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      '${formatSponsorshipScope(entry, ref)} • £${entry.amount.toStringAsFixed(0)}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.dark400),
                    ),
                  ))
                else if (websiteUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(websiteUrl!, style: AppTypography.micro.copyWith(color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoxyArtStatusPill(isPaid: isActive, paidLabel: 'Visible', dueLabel: 'Hidden', onToggle: onToggleActive, showActionIcon: false),
              if (entries.isNotEmpty)
                ...entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: BoxyArtStatusPill(isPaid: entry.isPaid, paidLabel: 'Paid', dueLabel: 'Unpaid', onToggle: () => onTogglePaid?.call(entry), showActionIcon: false),
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
        width: size, height: size,
        decoration: BoxDecoration(color: AppColors.dark300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.business_rounded, color: AppColors.textTertiary),
      );
    }
    final isLocal = url!.startsWith('/') || url!.contains('cache') || url!.contains('com.google.android');
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: AppColors.dark300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isLocal
            ? Image.file(File(url!), fit: BoxFit.contain, errorBuilder: (ctx, err, st) => const Icon(Icons.business_rounded, color: AppColors.textTertiary))
            : BoxyArtImage(url: url!, errorWidget: const Icon(Icons.business_rounded, color: AppColors.textTertiary)),
      ),
    );
  }
}

class _DonationTile extends ConsumerWidget {
  final FinancialEntry entry;
  final ValueChanged<FinancialEntry> onEdit;
  final ValueChanged<String> onRemove;

  const _DonationTile({required this.entry, required this.onEdit, required this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: Key('donation_${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(color: AppColors.coral500, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pureWhite),
      ),
      confirmDismiss: (_) async { onRemove(entry.id); return false; },
      child: BoxyArtCard(
        onTap: () => onEdit(entry),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.dark300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.textTertiary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toTitleCase(entry.source),
                    style: AppTypography.body.copyWith(color: isDark ? AppColors.pureWhite : AppColors.dark900, fontWeight: AppTypography.weightBold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '£${entry.amount.toStringAsFixed(0)}${entry.scope != null ? ' • ${entry.scope}' : ''}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.dark400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            BoxyArtStatusPill(
              isPaid: entry.isPaid,
              paidLabel: 'Paid',
              dueLabel: 'Unpaid',
              onToggle: () => ref.read(themeControllerProvider.notifier).updateLedgerEntry(entry.copyWith(isPaid: !entry.isPaid)),
            ),
          ],
        ),
      ),
    );
  }
}
