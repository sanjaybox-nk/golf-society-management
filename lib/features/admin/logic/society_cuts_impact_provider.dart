import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/design_system/theme/theme_controller.dart';
import 'society_cuts_engine.dart';

/// A data model representing a member's current active society cut,
/// either systemic (Global rules) or manual (Event overrides).
class MemberCutImpact {
  final Member member;
  final CutBreakdown breakdown;
  final bool isManual;

  const MemberCutImpact({
    required this.member,
    required this.breakdown,
    this.isManual = false,
  });
}

/// A provider that aggregates all members who currently have a persistent cut applied.
final societyCutsImpactProvider = Provider<AsyncValue<List<MemberCutImpact>>>((ref) {
  final membersAsync = ref.watch(allMembersProvider);
  final eventsAsync = ref.watch(adminEventsProvider);
  final config = ref.watch(themeControllerProvider);

  if (membersAsync is AsyncLoading || eventsAsync is AsyncLoading) {
    return const AsyncValue.loading();
  }

  if (membersAsync.hasError) return AsyncValue.error(membersAsync.error!, membersAsync.stackTrace!);
  if (eventsAsync.hasError) return AsyncValue.error(eventsAsync.error!, eventsAsync.stackTrace!);

  return AsyncValue.data(
    membersAsync.value!.map((member) {
      // 1. Calculate Systemic Global Cut
      final systemicBreakdown = SocietyCutsEngine.calculateActiveCut(
        memberId: member.id,
        allEvents: eventsAsync.value!,
        config: config,
      );

      // 2. Identify Manual Overrides for NEXT upcoming event (if in Manual Mode)
      // Note: Manual cuts are truly event-specific, so we look at the 'next' event
      // as the primary point of impact.
      if (config.societyCutMode == SocietyCutMode.manual) {
        final upcoming = eventsAsync.value!.where((e) => e.date.isAfter(DateTime.now())).toList();
        upcoming.sort((a, b) => a.date.compareTo(b.date));
        
        final nextEvent = upcoming.isEmpty ? null : upcoming.first;
        if (nextEvent != null && nextEvent.manualCuts.containsKey(member.id)) {
          final manualAmount = nextEvent.manualCuts[member.id] ?? 0.0;
          if (manualAmount != 0) {
            return MemberCutImpact(
              member: member,
              isManual: true,
              breakdown: CutBreakdown(
                totalCut: manualAmount,
                sources: [
                  ActiveCutSource(
                    eventId: nextEvent.id,
                    eventName: nextEvent.title,
                    eventDate: nextEvent.date,
                    finish: 'Manual',
                    cutAmount: manualAmount,
                  ),
                ],
              ),
            );
          }
        }
      }

      return MemberCutImpact(
        member: member,
        breakdown: systemicBreakdown,
        isManual: false,
      );
    }).where((impact) => impact.breakdown.totalCut != 0).toList()
      ..sort((a, b) => b.breakdown.totalCut.compareTo(a.breakdown.totalCut)),
  );
});
