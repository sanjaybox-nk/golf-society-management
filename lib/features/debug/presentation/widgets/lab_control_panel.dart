import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/models/competition.dart';
import 'package:golf_society/models/golf_event.dart';
import '../state/debug_providers.dart';
import '../../../../core/utils/seeding_controller.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../../core/services/seeding_service.dart';
import '../../../../core/utils/csv_export_service.dart';
import '../../../../core/services/persistence_service.dart';
import '../../../events/domain/registration_logic.dart';
import '../../../events/presentation/events_provider.dart';

class LabControlPanel extends ConsumerWidget {
  final String? eventId;
  const LabControlPanel({super.key, this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatOverride = ref.watch(gameFormatOverrideProvider);
    final emptyData = ref.watch(simulateEmptyDataProvider);
    final statusOverride = ref.watch(eventStatusOverrideProvider);
    final modeOverride = ref.watch(gameModeOverrideProvider);
    final allowanceOverride = ref.watch(handicapAllowanceOverrideProvider);
    final bestXOverride = ref.watch(teamBestXCountOverrideProvider);
    final aggOverride = ref.watch(aggregationMethodOverrideProvider);
    final statsReleasedOverride = ref.watch(isStatsReleasedOverrideProvider);
    final simulationHoles = ref.watch(simulationHoleCountOverrideProvider);
    final labEnabled = ref.watch(labModeEnabledProvider);
    
    final impersonated = ref.watch(impersonationProvider);
    final membersAsync = ref.watch(allMembersProvider);

    // Get event to find its natural format/mode for context-aware disabling
    final compAsync = ref.watch(competitionDetailProvider(eventId ?? ''));
    
    final currentMode = modeOverride ?? compAsync.asData?.value?.rules.mode ?? CompetitionMode.singles;
    
    final isTeamOrPairs = currentMode == CompetitionMode.teams || currentMode == CompetitionMode.pairs;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🧪 Lab Console', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            
            // 👤 IDENTITY SWITCHER (PEEK MODE)
            _buildSectionHeader('👤 PEEK MODE (IDENTITY)'),
            membersAsync.when(
              data: (members) => SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildIdentityCircle(
                        context: context,
                        name: 'Real Me',
                        isSelected: impersonated == null,
                        onTap: () => ref.read(impersonationProvider.notifier).clear(),
                      );
                    }
                    final member = members[index - 1];
                    return _buildIdentityCircle(
                      context: context,
                      name: member.firstName,
                      isSelected: impersonated?.id == member.id,
                      onTap: () => ref.read(impersonationProvider.notifier).set(member),
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Text('Error loading members'),
            ),
            const SizedBox(height: 20),
            
            // 🧪 MASTER LABS TOGGLE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: labEnabled ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: labEnabled ? Colors.orange.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: Colors.orange,
                title: const Text('🧪 MASTER LABS MODE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange)),
                subtitle: const Text('Enable experimental overrides & simulators', style: TextStyle(fontSize: 11)),
                value: labEnabled,
                onChanged: (_) => ref.read(labModeEnabledProvider.notifier).toggle(),
              ),
            ),
            const SizedBox(height: 12),
            
            // [NEW] RELEASE STATS OVERRIDE (Moved here to be independent of Master Labs Mode)
             _buildSectionHeader('📊 ANALYTICS & STATS'),
             SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeThumbColor: Colors.blue,
              title: const Text('Simulate Stats Released', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              subtitle: const Text('Overrides gated visibility for testing', style: TextStyle(fontSize: 11)),
              value: statsReleasedOverride ?? false,
              onChanged: (val) => ref.read(isStatsReleasedOverrideProvider.notifier).set(val),
            ),

            const SizedBox(height: 12),
            
            Opacity(
              opacity: labEnabled ? 1.0 : 0.4,
              child: AbsorbPointer(
                absorbing: !labEnabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

            // 🏁 EVENT STATUS
            _buildSectionHeader('🏁 EVENT STATUS'),
            _buildChipRow<EventStatus?>(
              values: [null, EventStatus.published, EventStatus.inPlay, EventStatus.completed],
              labels: ['OFF', 'Published', 'IN PLAY', 'Completed'],
              currentValue: statusOverride,
              onSelected: (val) {
                ref.read(eventStatusOverrideProvider.notifier).set(val);
                // [UX] Auto-enable simulation when switching to In Play for convenience
                if (val == EventStatus.inPlay && ref.read(simulationHoleCountOverrideProvider) == null) {
                   ref.read(simulationHoleCountOverrideProvider.notifier).set(12); // Default to 12 holes staggered
                }
              },
            ),
             
             // [NEW] LIVE SCORING SIMULATION (Moved here)
            if (statusOverride == EventStatus.inPlay || statusOverride == null) ...[ 
               const SizedBox(height: 12),
               _buildSectionHeader('🔴 LIVE SCORING SIMULATION'),
               SwitchListTile(
                 contentPadding: EdgeInsets.zero,
                 dense: true,
                 title: const Text('Enable Simulation', style: TextStyle(fontWeight: FontWeight.bold)),
                 subtitle: Text(simulationHoles != null ? 'Max Holes: $simulationHoles (Staggered)' : 'Off', style: const TextStyle(fontSize: 11)),
                 value: simulationHoles != null,
                 onChanged: (val) => ref.read(simulationHoleCountOverrideProvider.notifier).set(val ? 18 : null),
               ),
               if (simulationHoles != null)
                  Slider(
                    value: simulationHoles.toDouble(),
                    min: 0,
                    max: 18,
                    divisions: 18,
                    label: simulationHoles.toString(),
                    activeColor: Colors.red,
                    onChanged: (val) => ref.read(simulationHoleCountOverrideProvider.notifier).set(val.toInt()),
                  ),
            ],
            
            // 🎮 GAME FORMAT
            _buildSectionHeader('🎮 GAME FORMAT'),
            _buildChipRow<CompetitionFormat?>(
              values: [null, CompetitionFormat.stroke, CompetitionFormat.stableford, CompetitionFormat.matchPlay, CompetitionFormat.maxScore],
              labels: ['OFF', 'Stroke Play', 'Stableford', 'Match Play', 'Max Score'],
              currentValue: formatOverride,
              onSelected: (val) => ref.read(gameFormatOverrideProvider.notifier).set(val),
            ),

            if (formatOverride == CompetitionFormat.matchPlay && eventId != null) ...[
               const SizedBox(height: 12),
                _buildSectionHeader('🏆 MATCHPLAY GENERATORS'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabelWithStatus('Match Type', true),
                    _buildChipRow<CompetitionSubtype?>(
                      values: [null, CompetitionSubtype.none, CompetitionSubtype.fourball, CompetitionSubtype.foursomes],
                      labels: ['Default', 'Singles', 'Fourball', 'Foursomes'],
                      currentValue: ref.watch(matchplaySubtypeOverrideProvider),
                      onSelected: (val) => ref.read(matchplaySubtypeOverrideProvider.notifier).set(val),
                    ),
                    const SizedBox(height: 16),
                    _buildGeneratorAction(
                      context: context,
                      title: 'Manual Pairing Setup',
                      description: 'Open the full matchplay game builder.',
                      icon: Icons.settings_input_composite,
                      color: Colors.blueGrey,
                      onTap: () {
                         context.push('/admin/events/competitions/edit/$eventId');
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildGeneratorAction(
                      context: context,
                      title: 'Regen Matches (Singles)',
                      description: 'Clears and regenerates singles matching for all groups.',
                      icon: Icons.people_alt_outlined,
                      color: Colors.blue,
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final service = ref.read(seedingServiceProvider);
                        await service.generateTestMatches(eventId!);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('✅ Matches Generated for All Groups (Singles)')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildGeneratorAction(
                      context: context,
                      title: 'Regen Group Stage',
                      description: 'Creates round-robin pairings for group stage play.',
                      icon: Icons.grid_on_outlined,
                      color: Colors.teal,
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final service = ref.read(seedingServiceProvider);
                        await service.generateGroupStageMatches(eventId!);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('✅ Group Stage Generated (Round Robin)')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildGeneratorAction(
                      context: context,
                      title: 'Regen Bracket (8 Players)',
                      description: 'Seeds a standard 8-player knockout bracket.',
                      icon: Icons.account_tree_outlined,
                      color: Colors.purple,
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final service = ref.read(seedingServiceProvider);
                        await service.generateTestBracket(eventId!);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('✅ Bracket Generated (8 Players)')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildGeneratorAction(
                      context: context,
                      title: 'Simulate Results',
                      description: 'Fills hole-by-hole scores for all active matches.',
                      icon: Icons.bolt,
                      color: Colors.orange,
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final service = ref.read(seedingServiceProvider);
                        await service.simulateMatchScores(eventId!);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('✅ Match Results Simulated (Hole-by-Hole)')),
                        );
                      },
                    ),
                  ],
                ),
            ],

            // 👥 GAME MODE
            _buildSectionHeader('👥 GAME MODE'),
            _buildChipRow<CompetitionMode?>(
              values: [null, CompetitionMode.singles, CompetitionMode.pairs, CompetitionMode.teams],
              labels: ['OFF', 'Singles', 'Pairs', 'Teams'],
              currentValue: modeOverride,
              onSelected: (val) => ref.read(gameModeOverrideProvider.notifier).set(val),
            ),

             if (formatOverride == CompetitionFormat.maxScore) ...[
                const SizedBox(height: 12),
                _buildSectionHeader('⚖️ MAX SCORE CONFIG'),
                _buildChipRow<MaxScoreType?>(
                  values: [null, MaxScoreType.parPlusX, MaxScoreType.netDoubleBogey, MaxScoreType.fixed],
                  labels: ['OFF', 'Par + X', 'Net DB', 'Fixed'],
                  currentValue: ref.watch(maxScoreTypeOverrideProvider),
                  onSelected: (val) => ref.read(maxScoreTypeOverrideProvider.notifier).set(val),
                ),
                if (ref.watch(maxScoreTypeOverrideProvider) != null && ref.watch(maxScoreTypeOverrideProvider) != MaxScoreType.netDoubleBogey)
                  _buildChipRow<int?>(
                    values: [null, 1, 2, 3, 5, 8, 10],
                    labels: ['OFF', '1', '2', '3', '5', '8', '10'],
                    currentValue: ref.watch(maxScoreValueOverrideProvider),
                    onSelected: (val) => ref.read(maxScoreValueOverrideProvider.notifier).set(val),
                  ),
             ],

            // 📈 RULE TUNING
            _buildSectionHeader('📈 RULE TUNING'),
            
            // Handicap Allowance
            _buildLabelWithStatus('Handicap Allowance', true),
            _buildChipRow<double?>(
              values: [null, 1.0, 0.95, 0.9, 0.75],
              labels: ['OFF', '100%', '95%', '90%', '75%'],
              currentValue: allowanceOverride,
              onSelected: (val) => ref.read(handicapAllowanceOverrideProvider.notifier).set(val),
            ),
            
            // Team Best X Count
            _buildLabelWithStatus('Team Best X Count', isTeamOrPairs),
            _buildChipRow<int?>(
              values: [null, 1, 2, 3, 4],
              labels: ['OFF', '1', '2', '3', '4'],
              currentValue: bestXOverride,
              enabled: isTeamOrPairs,
              onSelected: (val) => ref.read(teamBestXCountOverrideProvider.notifier).set(val),
            ),

            // Aggregation Method
            _buildLabelWithStatus('Aggregation Method', isTeamOrPairs),
            _buildChipRow<String?>(
              values: [null, 'betterBall', 'combined'],
              labels: ['OFF', 'Better Ball', 'Combined'],
              currentValue: aggOverride,
              enabled: isTeamOrPairs,
              onSelected: (val) => ref.read(aggregationMethodOverrideProvider.notifier).set(val),
            ),

            const Divider(height: 32),
            
            _buildSectionHeader('📊 SCORING'),
            
            // Net / Gross
            _buildLabelWithStatus('Scoring Type', true),
            _buildChipRow<ScoringType?>(
              values: [null, ScoringType.net, ScoringType.gross],
              labels: ['OFF (Default)', 'Net', 'Gross'],
              currentValue: ref.watch(scoringTypeOverrideProvider),
              onSelected: (val) => ref.read(scoringTypeOverrideProvider.notifier).set(val),
            ),
            
             // Handicap Cap Override
            _buildLabelWithStatus('Handicap Cap', true),
            _buildChipRow<int?>(
              values: [null, 18, 24, 28, 36, 54],
              labels: ['OFF', '18', '24', '28', '36', '54'],
              currentValue: ref.read(handicapCapOverrideProvider),
              onSelected: (val) => ref.read(handicapCapOverrideProvider.notifier).set(val),
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader('⚠️ DATA ACTIONS'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.published_with_changes, color: Colors.blue),
              title: const Text('Reset Event Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              subtitle: const Text('Resets status to Published and clears Overrides', style: TextStyle(fontSize: 11)),
              onTap: () async {
                 if (eventId == null) return;
                 final messenger = ScaffoldMessenger.of(context);
                 try {
                   // 1. Clear Lab Status Override
                   ref.read(eventStatusOverrideProvider.notifier).set(null);
                   // Ensure key is removed even if Lab Mode is currently OFF
                   ref.read(persistenceServiceProvider).remove('lab_event_status');
                   
                   // 2. Re-seed registrations (which now resets the database status too)
                   await ref.read(seedingServiceProvider).seedRegistrations(eventId!, forceResetStatus: true);
                   
                   if (context.mounted) {
                     Navigator.of(context).pop();
                     messenger.showSnackBar(const SnackBar(content: Text('✅ Event Status & Overrides Reset!')));
                   }
                 } catch (e) {
                   messenger.showSnackBar(SnackBar(content: Text('❌ Reset failed: $e')));
                 }
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.refresh, color: Colors.orange),
              title: const Text('Regenerate All Results', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              subtitle: const Text('Re-seeds random scores (Data Loss Warning)', style: TextStyle(fontSize: 11)),
              onTap: () async {
                 if (eventId == null) return;
                 await ref.read(seedingControllerProvider).forceRegenerateEvent(eventId!);
                 if (context.mounted) {
                   Navigator.of(context).pop();
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Results Regenerated. Pull to refresh or reload.'))
                   );
                 }
              },
            ),
            
            const SizedBox(height: 12),
  
            _buildSectionHeader('⚙️ SEEDING & SETUP'),
            _buildGeneratorAction(
              context: context,
              title: 'Initialize Core Data',
              description: 'Seed courses and templates only.',
              icon: Icons.cloud_download_outlined,
              color: Colors.teal,
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final seeding = ref.read(seedingServiceProvider);
                  await seeding.seedInitialData();
                  messenger.showSnackBar(const SnackBar(content: Text('✅ Core data initialized!')));
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('❌ Initialization failed: $e')));
                }
              },
            ),
            const SizedBox(height: 12),
            _buildGeneratorAction(
              context: context,
              title: 'Seed Full Demo Data',
              description: 'Re-populate society with members, events, and scores.',
              icon: Icons.auto_awesome_motion_outlined,
              color: Colors.pinkAccent,
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final seeding = ref.read(seedingServiceProvider);
                  await seeding.seedStableFoundation();
                  messenger.showSnackBar(const SnackBar(content: Text('✅ Society seeded with demo data!')));
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('❌ Seeding failed: $e')));
                }
              },
            ),
            const SizedBox(height: 12),
            _buildGeneratorAction(
              context: context,
              title: 'Seed Team Logistics (Phase 3)',
              description: 'Scramble/Pairs historical seeding.',
              icon: Icons.groups_outlined,
              color: Colors.purple,
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final seeding = ref.read(seedingServiceProvider);
                  await seeding.seedTeamsPhase();
                  messenger.showSnackBar(const SnackBar(content: Text('✅ Phase 3 Ready!')));
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('❌ Seeding failed: $e')));
                }
              },
            ),
            const SizedBox(height: 12),
            _buildGeneratorAction(
              context: context,
              title: 'Hardening & Tie-Breaks (Phase 4)',
              description: 'Verify shared positions/countback.',
              icon: Icons.vibration_outlined,
              color: Colors.redAccent,
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final seeding = ref.read(seedingServiceProvider);
                  await seeding.seedHardeningPhase();
                  messenger.showSnackBar(const SnackBar(content: Text('✅ Phase 4 Ready!')));
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('❌ Seeding failed: $e')));
                }
              },
            ),
            if (eventId != null) ...[
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, child) {
                  final eventAsync = ref.watch(eventProvider(eventId!));
                  return eventAsync.maybeWhen(
                    data: (event) => _buildGeneratorAction(
                      context: context,
                      title: 'Export Registrations (CSV)',
                      description: 'Download participation details.',
                      icon: Icons.download_outlined,
                      color: Colors.blueAccent,
                      onTap: () {
                        final RenderBox? box = context.findRenderObject() as RenderBox?;
                        final shareOrigin = box != null
                            ? box.localToGlobal(Offset.zero) & box.size
                            : null;

                        CsvExportService.exportRegistrations(
                          event: event,
                          participants: RegistrationLogic.getSortedItems(event),
                          dinnerOnly: RegistrationLogic.getDinnerOnlyItems(event),
                          sharePositionOrigin: shareOrigin,
                        );
                      },
                    ),
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),

            // ⚙️ SYSTEM OVERRIDES
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Simulate Fresh Start', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Hide all seeded data (Empty Cards)', style: TextStyle(fontSize: 11)),
              value: emptyData,
              onChanged: (_) => ref.read(simulateEmptyDataProvider.notifier).toggle(),
            ),
            // [REMOVED] Force Active Scoring (Superceded by In Play Status)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Force Unlock Scoring', style: TextStyle(fontWeight: FontWeight.bold)),
              value: ref.watch(isScoringLockedOverrideProvider) == false,
              onChanged: (val) => ref.read(isScoringLockedOverrideProvider.notifier).set(val ? false : null),
            ),

            const SizedBox(height: 12),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildLabelWithStatus(String label, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8.0),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isEnabled ? Colors.grey : Colors.grey.withValues(alpha: 0.4))),
          if (!isEnabled) ...[
            const SizedBox(width: 8),
            const Text('(SINGLES ONLY)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red)),
          ],
        ],
      ),
    );
  }

  Widget _buildChipRow<T>({
    required List<T> values,
    required List<String> labels,
    required T currentValue,
    required Function(T) onSelected,
    bool enabled = true,
  }) {
    return AbsorbPointer(
      absorbing: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Wrap(
          spacing: 8,
          children: List.generate(values.length, (index) {
            return ChoiceChip(
              label: Text(labels[index], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              selected: currentValue == values[index],
              onSelected: (selected) { if (selected) onSelected(values[index]); },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGeneratorAction({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActionChip(
          onPressed: onTap,
          avatar: Icon(icon, size: 16, color: color),
          label: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          backgroundColor: color.withValues(alpha: 0.1),
          side: BorderSide(color: color.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            description,
            style: TextStyle(fontSize: 10, color: Colors.grey.withValues(alpha: 0.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityCircle({
    required BuildContext context,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.1);
    final textColor = isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
              boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
            ),
            child: Center(
               child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 10, 
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
