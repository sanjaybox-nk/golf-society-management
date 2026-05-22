import 'package:golf_society/domain/models/division_config.dart';
import 'package:golf_society/domain/models/member.dart';

class DivisionHelper {
  DivisionHelper._();

  /// Assigns a [Division] to a member given the season's [DivisionConfig].
  /// Returns null if divisions are not configured for the season.
  static Division? assignDivision(Member member, DivisionConfig? config) {
    if (config == null) return null;

    final isVoluntaryUpgrade = config.voluntaryDiv1MemberIds.contains(member.id);
    final isDiv1 = isVoluntaryUpgrade || member.handicap <= config.threshold;
    final isLadies = config.genderSeparated &&
        member.gender?.toLowerCase() == 'female';

    if (config.genderSeparated) {
      if (isLadies) return isDiv1 ? Division.div1Ladies : Division.div2Ladies;
      return isDiv1 ? Division.div1 : Division.div2;
    }
    return isDiv1 ? Division.div1 : Division.div2;
  }

  /// Returns the effective playing handicap for a member in context of divisions.
  /// Voluntary Div 1 upgrades have their handicap capped at [threshold].
  static double effectiveHandicap(Member member, DivisionConfig? config) {
    if (config == null) return member.handicap;
    final isVoluntary = config.voluntaryDiv1MemberIds.contains(member.id);
    if (isVoluntary && member.handicap > config.threshold) {
      return config.threshold;
    }
    return member.handicap;
  }

  /// Human-readable label for a division.
  static String label(Division division) {
    return switch (division) {
      Division.div1 => 'Division 1',
      Division.div2 => 'Division 2',
      Division.div1Ladies => 'Division 1 Ladies',
      Division.div2Ladies => 'Division 2 Ladies',
    };
  }

  /// Short label (for badges, chips, etc.)
  static String shortLabel(Division division) {
    return switch (division) {
      Division.div1 => 'DIV 1',
      Division.div2 => 'DIV 2',
      Division.div1Ladies => 'DIV 1 L',
      Division.div2Ladies => 'DIV 2 L',
    };
  }

  /// All divisions active for a given config.
  static List<Division> activeDivisions(DivisionConfig config) {
    if (config.genderSeparated) {
      return [Division.div1, Division.div2, Division.div1Ladies, Division.div2Ladies];
    }
    return [Division.div1, Division.div2];
  }

  /// Returns true if [memberId] belongs to [division] given [config] and [members].
  static bool memberBelongsToDivision(
    String memberId,
    Division division,
    DivisionConfig config,
    List<Member> members,
  ) {
    final member = members.where((m) => m.id == memberId).firstOrNull;
    if (member == null) return false;
    return assignDivision(member, config) == division;
  }
}
