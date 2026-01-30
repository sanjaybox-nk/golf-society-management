import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/theme/theme_controller.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: const BoxyArtAppBar(title: 'General Settings', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const BoxyArtSectionTitle(title: 'Localisation'),
          const SizedBox(height: 12),
          BoxyArtFloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 8),
                  child: Text(
                    'Currency',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: Text(
                    config.currencySymbol,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  title: Text(
                    config.currencyCode,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Tap to change currency'),
                  trailing: const Icon(Icons.arrow_drop_down_circle_outlined),
                  onTap: () => context.push('/admin/settings/general/currency'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const BoxyArtSectionTitle(title: 'App Info'),
          const SizedBox(height: 12),
          BoxyArtFloatingCard(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Version'),
                  trailing: Text('1.0.0 (Build 61)'),
                ),
                ListTile(
                  title: const Text('Platform'),
                  trailing: Text(Theme.of(context).platform.name.toUpperCase()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
