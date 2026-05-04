import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/services/persistence_service.dart';

// Tab Notifier for event scoring tabs
class SelectedTabNotifier extends Notifier<int> {
  final String key;
  SelectedTabNotifier(this.key);
  @override
  int build() => int.tryParse(ref.watch(persistenceServiceProvider).getString(key) ?? '0') ?? 0;
  void set(int val) {
    state = val;
    ref.read(persistenceServiceProvider).setString(key, val.toString());
  }
}

final eventScoresHubTabProvider = NotifierProvider<SelectedTabNotifier, int>(() => SelectedTabNotifier('event_scores_hub_tab'));

// New provider for SCORING vs SCORECARD views
final eventScoringTabProvider = NotifierProvider<SimpleTabNotifier, int>(() => SimpleTabNotifier());

class SimpleTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int val) => state = val;
}
enum MarkerTab { player, verifier, verify }

final eventFieldTabProvider = NotifierProvider<SimpleTabNotifier, int>(() => SimpleTabNotifier());
