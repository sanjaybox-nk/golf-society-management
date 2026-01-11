import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/models/distribution_list.dart';

class DistributionListNotifier extends Notifier<List<DistributionList>> {
  @override
  List<DistributionList> build() {
    // Initial mock data
    return [
      DistributionList(
        id: '1',
        name: 'Committee',
        memberIds: [], // Empty for now, logic will handle "all committee"
        createdAt: DateTime.now(),
      ),
    ];
  }

  void addList(DistributionList list) {
    state = [...state, list];
  }

  void removeList(String id) {
    state = state.where((l) => l.id != id).toList();
  }
}

final distributionListProvider = NotifierProvider<DistributionListNotifier, List<DistributionList>>(DistributionListNotifier.new);
