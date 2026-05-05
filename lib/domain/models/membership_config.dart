import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/domain/models/handicap_system.dart';

/// A read-only view of the membership/renewal/society-cut properties of [SocietyConfig].
/// Consumers that only need handicap or renewal settings should watch
/// [membershipConfigProvider] to avoid rebuilding on visual token changes.
class MembershipConfig {
  const MembershipConfig(this._c);
  final SocietyConfig _c;

  // ── Handicap / game settings ─────────────────────────────────────────────
  bool get useWhsHandicaps => _c.useWhsHandicaps;
  HandicapSystem get handicapSystem => _c.handicapSystem;
  String get distanceUnit => _c.distanceUnit;
  String get groupingStrategy => _c.groupingStrategy;
  bool get separateGuestLeaderboard => _c.separateGuestLeaderboard;
  bool get showMatchPlayOverlay => _c.showMatchPlayOverlay;
  bool get enableGimmes => _c.enableGimmes;

  // ── Society cut ───────────────────────────────────────────────────────────
  SocietyCutMode get societyCutMode => _c.societyCutMode;
  Map<String, double> get societyCutRules => _c.societyCutRules;
  int get societyCutEventLimit => _c.societyCutEventLimit;
  bool get societyCutCountPlayedOnly => _c.societyCutCountPlayedOnly;
  bool get societyCutFilterSeason => _c.societyCutFilterSeason;
  bool get societyCutFilterInvitational => _c.societyCutFilterInvitational;

  // ── Renewal / membership lifecycle ───────────────────────────────────────
  DateTime? get globalMembershipEndDate => _c.globalMembershipEndDate;
  int get renewalWindowDays => _c.renewalWindowDays;
  bool get isRenewalActive => _c.isRenewalActive;
  DateTime? get renewalLaunchDate => _c.renewalLaunchDate;
  DateTime? get renewalDeadline => _c.renewalDeadline;
  DateTime? get renewalPaymentDeadline => _c.renewalPaymentDeadline;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MembershipConfig && other._c == _c);

  @override
  int get hashCode => _c.hashCode;
}
