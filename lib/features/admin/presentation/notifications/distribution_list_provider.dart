import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/models/distribution_list.dart';
import 'firestore_distribution_lists_repository.dart';

final distributionListProvider = StreamProvider<List<DistributionList>>((ref) {
  final repository = ref.watch(distributionListsRepositoryProvider);
  return repository.watchLists();
});
