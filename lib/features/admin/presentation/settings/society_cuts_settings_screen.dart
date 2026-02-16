import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared_ui/headless_scaffold.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';

class SocietyCutsSettingsScreen extends ConsumerStatefulWidget {
  const SocietyCutsSettingsScreen({super.key});

  @override
  ConsumerState<SocietyCutsSettingsScreen> createState() => _SocietyCutsSettingsScreenState();
}

class _SocietyCutsSettingsScreenState extends ConsumerState<SocietyCutsSettingsScreen> {
  late Map<String, double> _rules;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    final config = ref.read(themeControllerProvider);
    _rules = Map<String, double>.from(config.societyCutRules);
    _enabled = config.enableSocietyCuts == true;
  }

  void _updateRule(String key, String value) {
    final double? val = double.tryParse(value);
    if (val != null) {
      setState(() {
        _rules[key] = val;
      });
      ref.read(themeControllerProvider.notifier).setSocietyCutRules(_rules);
    }
  }

  @override
  Widget build(BuildContext context) {

    return HeadlessScaffold(
      title: 'Society Cuts',
      subtitle: 'Handicap adjustment rules',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ModernCard(
                child: Column(
                  children: [
                    ModernSwitchRow(
                      label: 'Enable Society Cuts',
                      subtitle: 'Apply penalties to top finishers for subsequent events.',
                      icon: Icons.auto_graph_rounded,
                      value: _enabled,
                      onChanged: (v) {
                        setState(() => _enabled = v);
                        ref.read(themeControllerProvider.notifier).setEnableSocietyCuts(v);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_enabled) ...[
                const BoxyArtSectionTitle(title: 'Cut Rules (Shots)', padding: EdgeInsets.zero),
                const SizedBox(height: 12),
                ModernCard(
                  child: Column(
                    children: _rules.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold))),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  suffixText: 'pt',
                                  isDense: true,
                                ),
                                controller: TextEditingController(text: entry.value.toString()),
                                onSubmitted: (v) => _updateRule(entry.key, v),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Cuts are applied to the player\'s WHS PHC calculation. For standard "Demo Season," these will be cumulative.',
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}
