import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/season.dart';
import '../../events/presentation/events_provider.dart';

// Mock Season Data
// Note: Since Season model is minimal, we might need to rely on the 'agmData' map for details
// or just standard fields if we updated the model. Checked model: has `agmData` map.

final archiveSeasonsProvider = Provider<AsyncValue<List<Season>>>((ref) {
  final seasonsAsync = ref.watch(seasonsProvider);
  return seasonsAsync.whenData((seasons) {
    return seasons.where((s) => s.status == SeasonStatus.closed).toList();
  });
});
