import 'package:golf_society/domain/models/society_config.dart';

/// A read-only view of the financial/commerce properties of [SocietyConfig].
/// Consumers that only need currency or pricing settings should watch
/// [financialConfigProvider] to avoid rebuilding on visual token changes.
class FinancialConfig {
  const FinancialConfig(this._c);
  final SocietyConfig _c;

  String get currencySymbol => _c.currencySymbol;
  String get currencyCode => _c.currencyCode;
  double get globalMarkupPercentage => _c.globalMarkupPercentage;
  double get guestMarkupExtra => _c.guestMarkupExtra;
  double get startingBalance => _c.startingBalance;
  List<FinancialEntry> get ledgerEntries => _c.ledgerEntries;
  List<Sponsor> get sponsors => _c.sponsors;
  bool get enablePenaltyFines => _c.enablePenaltyFines;
  double get penaltyFineAmount => _c.penaltyFineAmount;
  double get nrFineAmount => _c.nrFineAmount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FinancialConfig && other._c == _c);

  @override
  int get hashCode => _c.hashCode;
}
