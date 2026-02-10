
import '../../../../models/golf_event.dart';
import 'match_definition.dart';

extension GolfEventMatchExtensions on GolfEvent {
  List<MatchDefinition> get matches {
    if (grouping.containsKey('matches')) {
      final matchesList = grouping['matches'] as List?;
      if (matchesList == null) return [];
      return matchesList.map((m) => MatchDefinition.fromJson(m as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
