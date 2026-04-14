import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/society_config.dart';

class CutBreakdown {
  final double totalCut;
  final List<ActiveCutSource> sources;

  const CutBreakdown({
    required this.totalCut,
    required this.sources,
  });

  static const zero = CutBreakdown(totalCut: 0, sources: []);
}

class ActiveCutSource {
  final String eventId;
  final String eventName;
  final DateTime eventDate;
  final String finish; // e.g., "1st", "2nd"
  final double cutAmount;

  const ActiveCutSource({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.finish,
    required this.cutAmount,
  });
}

class SocietyCutsEngine {
  /// Calculates the active society cut for a member based on global rules.
  static CutBreakdown calculateActiveCut({
    required String memberId,
    required List<GolfEvent> allEvents,
    required SocietyConfig config,
    DateTime? relativeTo, // Used to calculate cuts as of a specific event
  }) {
    if (config.societyCutMode != SocietyCutMode.global) {
      return CutBreakdown.zero;
    }

    final now = relativeTo ?? DateTime.now();
    
    // 1. Get previous completed events in the same season
    var eligibleEvents = allEvents.where((e) => 
      e.status == EventStatus.completed && 
      e.date.isBefore(now)
    ).toList();

    // 2. Filter by Category
    eligibleEvents = eligibleEvents.where((e) {
      if (e.isInvitational) return config.societyCutFilterInvitational;
      if (e.isSeasonEvent) return config.societyCutFilterSeason;
      return true; // Ad-hoc events always count? Or assume Season if not specified
    }).toList();

    // 3. Sort by date descending (Newest first)
    eligibleEvents.sort((a, b) => b.date.compareTo(a.date));

    // 4. Identify the events the member actually played in
    final List<ActiveCutSource> activeSources = [];
    int eventsPlayedCount = 0;
    final limit = config.societyCutEventLimit;

    for (var event in eligibleEvents) {
      final result = event.results.firstWhere(
        (r) => r['memberId'] == memberId,
        orElse: () => {},
      );

      final hasPlayed = result.isNotEmpty;
      
      if (hasPlayed) {
        eventsPlayedCount++;
        
        // If we are over the limit, stop looking at older events
        // Note: 0 means Unlimited/Rest of Season
        if (limit > 0 && eventsPlayedCount > limit) {
          break;
        }

        final position = (result['position'] as num?)?.toInt() ?? 0;
        final finishKey = _getOrdinal(position);
        
        final cutAmount = config.societyCutRules[finishKey] ?? 0.0;
        
        if (cutAmount > 0) {
          activeSources.add(ActiveCutSource(
            eventId: event.id,
            eventName: event.title,
            eventDate: event.date,
            finish: finishKey,
            cutAmount: cutAmount,
          ));
        }
      } else {
        // [NEW] Duration Type Logic: Count Played vs Count All
        if (!config.societyCutCountPlayedOnly) {
          eventsPlayedCount++; // Increment even if they didn't play if "Count All" is selected
          if (limit > 0 && eventsPlayedCount > limit) {
            break;
          }
        }
      }
    }

    final total = activeSources.fold<double>(0, (sum, src) => sum + src.cutAmount);

    return CutBreakdown(
      totalCut: total,
      sources: activeSources,
    );
  }

  static String _getOrdinal(int position) {
    if (position == 1) return '1st';
    if (position == 2) return '2nd';
    if (position == 3) return '3rd';
    return '${position}th';
  }
}
