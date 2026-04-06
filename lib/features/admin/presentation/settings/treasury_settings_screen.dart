import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/utils/string_utils.dart';

class TreasurySettingsScreen extends ConsumerStatefulWidget {
  const TreasurySettingsScreen({super.key});

  @override
  ConsumerState<TreasurySettingsScreen> createState() => _TreasurySettingsScreenState();
}

class _TreasurySettingsScreenState extends ConsumerState<TreasurySettingsScreen> {
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final quill.QuillController _richDescriptionController = quill.QuillController.basic();
  String _selectedType = 'Other';
  bool _isPaid = true;
  String? _editingId;

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _logoUrlController.dispose();
    _richDescriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _sourceController.clear();
    _amountController.clear();
    _logoUrlController.clear();
    _richDescriptionController.document = quill.Document();
    _selectedType = 'Other';
    _isPaid = true;
    _editingId = null;
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (_sourceController.text.isEmpty || amount <= 0) return;

    final descriptionJson = jsonEncode(_richDescriptionController.document.toDelta().toJson());
    final isDescriptionEmpty = _richDescriptionController.document.toPlainText().trim().isEmpty;
    final logoUrl = _logoUrlController.text.trim().isEmpty ? null : _logoUrlController.text.trim();

    final entry = FinancialEntry(
      id: _editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: _selectedType,
      source: _sourceController.text.trim(),
      description: isDescriptionEmpty ? null : descriptionJson,
      logoUrl: logoUrl,
      amount: amount,
      date: DateTime.now(),
      isPaid: _isPaid,
    );

    if (_editingId != null) {
      ref.read(themeControllerProvider.notifier).updateLedgerEntry(entry);
    } else {
      ref.read(themeControllerProvider.notifier).addLedgerEntry(entry);
    }
    
    setState(() => _resetForm());
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(themeControllerProvider);
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();
    final ledger = config.ledgerEntries.where((e) => e.type != 'Sponsorship' && e.type != 'Donation').toList();

    return HeadlessScaffold(
      title: 'Treasury & Finance',
      subtitle: 'Society ledger and opening balance',
      showBack: true,
      onBack: () => Navigator.of(context).pop(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, 
            vertical: spacing?.labelToCard ?? AppSpacing.labelToCard
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'Balance'),
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.standard),
                child: Column(
                  children: [
                    BoxyArtInputField(
                      label: 'Opening bank balance',
                      controller: TextEditingController(text: config.startingBalance.toStringAsFixed(0)),
                      prefixIcon: const Icon(Icons.account_balance_rounded),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) {
                        final balance = double.tryParse(val) ?? 0.0;
                        ref.read(themeControllerProvider.notifier).setStartingBalance(balance);
                      },
                    ),
                  ],
                ),
              ),
              const BoxyArtSectionTitle(title: 'Society ledger'),
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.standard),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: BoxyArtDropdownField<String>(
                            label: 'Entry type',
                            value: _selectedType,
                            items: ['Other'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (val) => setState(() => _selectedType = val!),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.standard),
                        Expanded(
                          child: BoxyArtInputField(
                            label: 'Amount',
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.standard),
                    BoxyArtInputField(
                      label: 'Source / Name (e.g. Acme Corp)',
                      controller: _sourceController,
                      prefixIcon: const Icon(Icons.business_rounded),
                    ),
                    const SizedBox(height: AppSpacing.standard),
                    BoxyArtInputField(
                      label: 'Notes / Reference (Optional)',
                      controller: _logoUrlController,
                      prefixIcon: const Icon(Icons.note_rounded),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    BoxyArtSwitchField(
                      label: 'Mark as paid',
                      value: _isPaid,
                      onChanged: (val) => setState(() => _isPaid = val),
                    ),
                    const SizedBox(height: AppSpacing.standard),
                    BoxyArtButton(
                      title: _editingId != null ? 'Update' : 'Add entry',
                      icon: _editingId != null ? Icons.save_rounded : Icons.add_circle_outline_rounded,
                      onTap: _submit,
                      fullWidth: true,
                    ),
                    if (_editingId != null) ...[
                      const SizedBox(height: AppSpacing.atomic),
                      TextButton(onPressed: () => setState(() => _resetForm()), child: const Text('Cancel edit')),
                    ],
                  ],
                ),
              ),
              if (ledger.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Current entries', style: AppTypography.micro.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.standard),
                ...ledger.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.standard),
                  child: BoxyArtCard(
                    padding: const EdgeInsets.all(AppSpacing.standard),
                    child: Row(
                      children: [
                        BoxyArtIconBadge(
                          icon: entry.type == 'Sponsorship' ? Icons.handshake_rounded : Icons.volunteer_activism_rounded,
                          color: entry.isPaid ? AppColors.lime500 : AppColors.amber500,
                          isTinted: true,
                        ),
                        const SizedBox(width: AppSpacing.standard),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                toSentenceCase(entry.source), 
                                style: AppTypography.body.copyWith(
                                  color: theme.brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark900,
                                  fontWeight: AppTypography.weightBold,
                                  fontSize: AppTypography.sizeBody,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              Text(
                                '${toSentenceCase(entry.type)}${entry.scope != null ? ' • ${toSentenceCase(entry.scope!)}' : ''} • £${entry.amount.toStringAsFixed(0)}', 
                                style: AppTypography.label.copyWith(color: AppColors.dark300)
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          onPressed: () => setState(() {
                            _editingId = entry.id;
                            _sourceController.text = entry.source;
                            _amountController.text = entry.amount.toStringAsFixed(0);
                            
                            // Handle potential rich text vs plain text migration
                            if (entry.description != null) {
                              if (entry.description!.startsWith('[{"insert"')) {
                                _richDescriptionController.document = quill.Document.fromJson(jsonDecode(entry.description!));
                              } else {
                                _richDescriptionController.document = quill.Document()..insert(0, entry.description!);
                              }
                            } else {
                              _richDescriptionController.document = quill.Document();
                            }

                            _selectedType = entry.type;
                            _logoUrlController.text = entry.logoUrl ?? '';
                            _isPaid = entry.isPaid;
                          }),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.coral500),
                          onPressed: () => ref.read(themeControllerProvider.notifier).removeLedgerEntry(entry.id),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

