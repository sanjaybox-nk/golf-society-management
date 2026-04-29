import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/audience_filter_rule.dart';

class SmartAudienceEvaluator {
  static List<String> evaluate({
    required List<Member> members,
    required List<AudienceFilterRule> rules,
    List<GolfEvent>? events,
  }) {
    if (rules.isEmpty) return [];

    return members.where((member) {
      // All rules must match (AND logic)
      return rules.every((rule) => _matchesRule(member, rule, events));
    }).map((m) => m.id).toList();
  }

  static bool _matchesRule(Member member, AudienceFilterRule rule, List<GolfEvent>? events) {
    switch (rule.property) {
      case AudienceProperty.membershipStatus:
        return _evaluateString(member.status.name, rule.operator, rule.value);
      
      case AudienceProperty.handicapIndex:
        return _evaluateDouble(member.handicap, rule.operator, rule.value);
      
      case AudienceProperty.debtBalance:
        // Debt is positive if they owe money. accountCredit is positive if they have credit.
        // In this system, accountCredit > 0 means they have money.
        // So debtBalance = -accountCredit.
        final debt = -member.accountCredit;
        return _evaluateDouble(debt, rule.operator, rule.value);
      
      case AudienceProperty.registrationStatus:
        if (events == null || events.isEmpty) return false;
        // Find the next upcoming event
        final upcomingEvents = events.where((e) => e.date.isAfter(DateTime.now())).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        
        if (upcomingEvents.isEmpty) return false;
        final nextEvent = upcomingEvents.first;
        final isRegistered = nextEvent.registrations.any((r) => r.memberId == member.id && r.isConfirmed);
        
        return _evaluateBool(isRegistered, rule.operator, rule.value);
    }
  }

  static bool _evaluateString(String actual, FilterOperator op, String target) {
    switch (op) {
      case FilterOperator.equals:
        return actual.toLowerCase() == target.toLowerCase();
      case FilterOperator.notEquals:
        return actual.toLowerCase() != target.toLowerCase();
      case FilterOperator.contains:
        return actual.toLowerCase().contains(target.toLowerCase());
      default:
        return false;
    }
  }

  static bool _evaluateDouble(double actual, FilterOperator op, String target) {
    final targetVal = double.tryParse(target) ?? 0.0;
    switch (op) {
      case FilterOperator.equals:
        return actual == targetVal;
      case FilterOperator.notEquals:
        return actual != targetVal;
      case FilterOperator.greaterThan:
        return actual > targetVal;
      case FilterOperator.lessThan:
        return actual < targetVal;
      default:
        return false;
    }
  }

  static bool _evaluateBool(bool actual, FilterOperator op, String target) {
    final targetVal = target.toLowerCase() == 'true' || target == '1';
    switch (op) {
      case FilterOperator.equals:
        return actual == targetVal;
      case FilterOperator.notEquals:
        return actual != targetVal;
      default:
        return false;
    }
  }
}
