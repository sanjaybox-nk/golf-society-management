import '../../../../../models/distribution_list.dart';

abstract class DistributionListsRepository {
  Stream<List<DistributionList>> watchLists();
  Future<void> createList(DistributionList list);
  Future<void> updateList(DistributionList list);
  Future<void> deleteList(String listId);
}
