import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';



class MemberDebtSummary {
  final Member member;
  final double totalDebt;
  final double totalCredit;
  final List<GolfEvent> unpaidEvents;
  final List<EventFine> unpaidFines;
  final double totalEventFeesOwed;
  final double totalFinesOwed;

  MemberDebtSummary({
    required this.member,
    required this.totalDebt,
    required this.totalCredit,
    required this.unpaidEvents,
    required this.unpaidFines,
    required this.totalEventFeesOwed,
    required this.totalFinesOwed,
  });

  double get netBalance => totalCredit - totalDebt;
}

class DebtLedgerController extends Notifier<void> {
  @override
  void build() {}

  Future<void> settleDebts(MemberDebtSummary summary, {double? partialAmount, bool isPayout = false}) async {
    if (partialAmount != null) {
      final adjustment = isPayout ? -partialAmount : partialAmount;
      await ref.read(membersRepositoryProvider).updateMember(
        summary.member.copyWith(accountCredit: summary.member.accountCredit + adjustment),
      );
      return;
    }

    final allEvents = ref.read(eventsProvider).value ?? [];
    final eventsToUpdate = <String, GolfEvent>{};

    for (final e in summary.unpaidEvents) {
      if (!eventsToUpdate.containsKey(e.id)) {
        final latestEvt = allEvents.firstWhere((evt) => evt.id == e.id);
        eventsToUpdate[e.id] = latestEvt;
      }
      var evt = eventsToUpdate[e.id]!;
      final newRegs = List<EventRegistration>.from(evt.registrations);
      final idx = newRegs.indexWhere((r) => r.memberId == summary.member.id);
      if (idx >= 0) {
        newRegs[idx] = newRegs[idx].copyWith(hasPaid: true, finePaid: true);
      }
      eventsToUpdate[e.id] = evt.copyWith(registrations: newRegs);
    }
    
    for (final evt in eventsToUpdate.values) {
      await ref.read(eventsRepositoryProvider).updateEvent(evt);
    }

    double remainingCredit = summary.totalCredit;
    if (summary.totalCredit > 0) {
      if (summary.totalDebt >= summary.totalCredit) {
        remainingCredit = 0.0;
      } else {
        remainingCredit = summary.totalCredit - summary.totalDebt;
      }
      await ref.read(membersRepositoryProvider).updateMember(summary.member.copyWith(accountCredit: remainingCredit));
    }
  }
}

final debtLedgerControllerProvider = NotifierProvider<DebtLedgerController, void>(
  DebtLedgerController.new,
);

final debtSummariesProvider = Provider.autoDispose.family<List<MemberDebtSummary>, String>((ref, search) {
  final membersAsync = ref.watch(allMembersProvider);
  final eventsAsync = ref.watch(eventsProvider);

  return membersAsync.maybeWhen(
    data: (members) {
      return eventsAsync.maybeWhen(
        data: (events) {
          final summaries = <MemberDebtSummary>[];

          for (final member in members) {
            double eventFeesOwed = 0.0;
            double finesOwed = 0.0;
            final unpaidEvts = <GolfEvent>[];
            final unpaidFines = <EventFine>[];

            for (final evt in events) {
              final reg = evt.registrations.firstWhere(
                (r) => r.memberId == member.id, 
                orElse: () => const EventRegistration(memberId: '', memberName: '')
              );
              if (reg.memberId.isNotEmpty) {
                if (!reg.hasPaid && reg.cost > 0 && reg.isConfirmed) {
                  eventFeesOwed += reg.cost;
                  unpaidEvts.add(evt);
                }
                if (!reg.finePaid && reg.fineAmount > 0) {
                  finesOwed += reg.fineAmount;
                  unpaidFines.addAll(reg.fines);
                  if (!unpaidEvts.contains(evt)) {
                    unpaidEvts.add(evt);
                  }
                }
              }
            }

            final totalDebt = eventFeesOwed + finesOwed;
            final totalCredit = member.accountCredit;

            if (totalDebt != 0 || totalCredit != 0) {
              summaries.add(MemberDebtSummary(
                member: member,
                totalDebt: totalDebt,
                totalCredit: totalCredit,
                unpaidEvents: unpaidEvts,
                unpaidFines: unpaidFines,
                totalEventFeesOwed: eventFeesOwed,
                totalFinesOwed: finesOwed,
              ));
            }
          }

          if (search.isEmpty) return summaries;
          return summaries.where((s) => s.member.displayName.toLowerCase().contains(search.toLowerCase())).toList();
        },
        orElse: () => [],
      );
    },
    orElse: () => [],
  );
});
