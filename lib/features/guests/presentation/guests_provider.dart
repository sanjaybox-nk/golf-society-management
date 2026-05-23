import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/guest_profile.dart';
import 'package:golf_society/features/guests/data/guest_repository.dart';

final allGuestsProvider = StreamProvider<List<GuestProfile>>((ref) {
  return ref.watch(guestRepositoryProvider).watchAll();
});

class GuestSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String query) => state = query;
}

final guestSearchQueryProvider = NotifierProvider<GuestSearchQueryNotifier, String>(GuestSearchQueryNotifier.new);

final guestByIdProvider = Provider.autoDispose.family<GuestProfile?, String>((ref, id) {
  return ref.watch(allGuestsProvider).value?.firstWhereOrNull((g) => g.id == id);
});

final filteredGuestsProvider = Provider.autoDispose<AsyncValue<List<GuestProfile>>>((ref) {
  final guestsAsync = ref.watch(allGuestsProvider);
  final query = ref.watch(guestSearchQueryProvider).toLowerCase().trim();

  return guestsAsync.whenData((guests) {
    if (query.isEmpty) return guests;
    return guests.where((g) =>
      g.name.toLowerCase().contains(query) ||
      g.email.toLowerCase().contains(query),
    ).toList();
  });
});
