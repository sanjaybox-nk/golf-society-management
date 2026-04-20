import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/design_system/widgets/metrics.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/society_config.dart';
import '../../domain/registration_logic.dart';

class RegistrationStatsCard extends ConsumerWidget {
  final GolfEvent event;
  final bool isCompact;
  final bool showAdminMetrics;

  const RegistrationStatsCard({
    super.key,
    required this.event,
    this.isCompact = false,
    this.showAdminMetrics = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = RegistrationLogic.getRegistrationStats(event);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);
    final currency = config.currencySymbol;

    final playingValue = stats.confirmedGuests > 0 
        ? '${stats.confirmedGolfers} (${stats.confirmedGuests})' 
        : '${stats.confirmedGolfers}';
    final reserveValue = stats.reserveGuests > 0 
        ? '${stats.reserveGolfers} (${stats.reserveGuests})' 
        : '${stats.reserveGolfers}';

    if (isCompact) {
      return _buildGridVersion(
        context, 
        _getCompactStats(event, stats, playingValue, reserveValue),
        isDark,
      );
    }

    return _buildFullVersion(context, stats, isDark, playingValue, reserveValue, currency, config);
  }

  List<ModernMetricStat> _getCompactStats(GolfEvent event, RegistrationStats stats, String playing, String reserve) {
    return [
      ModernMetricStat(value: '${event.maxParticipants ?? 0}', label: 'Capacity', icon: Icons.groups_rounded, isCompact: true),
      ModernMetricStat(value: playing, label: 'Playing', icon: Icons.check_circle_rounded, isCompact: true),
      ModernMetricStat(value: reserve, label: 'Reserve', icon: Icons.hourglass_top_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.confirmedGuests + stats.reserveGuests + stats.waitlistGuests}', label: 'Guests', icon: Icons.person_add_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.buggyCount}', label: 'Buggies', icon: Icons.electric_rickshaw_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.waitlistGolfers}', label: 'Waitlist', icon: Icons.priority_high_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.withdrawnCount}', label: 'Withdrawn', icon: Icons.person_remove_rounded, isCompact: true),
    ];
  }

  Widget _buildGridVersion(BuildContext context, List<Widget> items, bool isDark) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.lg;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.xl;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate grid with 4 columns
        const int crossAxisCount = 3;
        final double totalGapWidth = AppSpacing.md * (crossAxisCount - 1);
        final double itemWidth = (constraints.maxWidth - totalGapWidth) / crossAxisCount;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: items.map((item) => SizedBox(
            width: itemWidth,
            child: item,
          )).toList(),
        );
      },
    );
  }

  Widget _buildFullVersion(
    BuildContext context, 
    RegistrationStats stats, 
    bool isDark,
    String playingValue,
    String reserveValue,
    String currency,
    SocietyConfig config,
  ) {
    final double totalPaidFees = event.registrations
        .where((r) => r.hasPaid == true)
        .fold(0.0, (sum, r) {
          double golfCost = 0.0;
          if (r.isConfirmed && r.attendingGolf) golfCost += event.memberCost ?? 0.0;
          if (r.guestIsConfirmed && r.guestName != null && r.guestName!.isNotEmpty) golfCost += event.guestCost ?? 0.0;
          return sum + golfCost;
        });

    final double totalDinnerFees = event.registrations
        .where((r) => r.hasPaid == true)
        .fold(0.0, (sum, r) => sum +
            (r.attendingDinner == true && r.isConfirmed == true ? (event.dinnerCost ?? 0.0) : 0.0) +
            (r.guestAttendingDinner == true && r.guestIsConfirmed == true ? (event.dinnerCost ?? 0.0) : 0.0));

    final double totalBreakfastFees = event.registrations
        .where((r) => r.hasPaid == true)
        .fold(0.0, (sum, r) => sum +
            (r.attendingBreakfast == true && r.isConfirmed == true ? (event.breakfastCost ?? 0.0) : 0.0) +
            (r.guestAttendingBreakfast == true && r.guestIsConfirmed == true ? (event.breakfastCost ?? 0.0) : 0.0));

    final double totalLunchFees = event.registrations
        .where((r) => r.hasPaid == true)
        .fold(0.0, (sum, r) => sum +
            (r.attendingLunch == true && r.isConfirmed == true ? (event.lunchCost ?? 0.0) : 0.0) +
            (r.guestAttendingLunch == true && r.guestIsConfirmed == true ? (event.lunchCost ?? 0.0) : 0.0));

    final availableBuggies = event.availableBuggies ?? 0;
    final buggyCapacity = availableBuggies * 2;

    final statsList = [
      ModernMetricStat(value: '${event.maxParticipants ?? 0}', label: 'Capacity', icon: Icons.groups_rounded, isCompact: true),
      ModernMetricStat(value: playingValue, label: 'Playing', icon: Icons.check_circle_rounded, isCompact: true),
      ModernMetricStat(value: reserveValue, label: 'Reserve', icon: Icons.hourglass_top_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.confirmedGuests + stats.reserveGuests + stats.waitlistGuests}', label: 'Guests', icon: Icons.person_add_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.buggyCount}/$buggyCapacity', label: 'Buggies', icon: Icons.electric_rickshaw_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.breakfastCount}', label: 'Breakfast', icon: Icons.breakfast_dining_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.lunchCount}', label: 'Lunch', icon: Icons.lunch_dining_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.dinnerCount}', label: 'Dinner', icon: Icons.restaurant_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.waitlistGolfers}', label: 'Waitlist', icon: Icons.priority_high_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.withdrawnCount}', label: 'Withdrawn', icon: Icons.person_remove_rounded, isCompact: true),
    ];

    final adminStatsList = [
      ModernMetricStat(value: '$currency${totalPaidFees.toStringAsFixed(0)}', label: 'Paid', icon: Icons.payments_rounded, isCompact: true),
      ModernMetricStat(value: '$currency${totalBreakfastFees.toStringAsFixed(0)}', label: 'Breakfast', icon: Icons.breakfast_dining_rounded, isCompact: true),
      ModernMetricStat(value: '$currency${totalLunchFees.toStringAsFixed(0)}', label: 'Lunch', icon: Icons.lunch_dining_rounded, isCompact: true),
      ModernMetricStat(value: '$currency${totalDinnerFees.toStringAsFixed(0)}', label: 'Dinner', icon: Icons.restaurant_menu_rounded, isCompact: true),
    ];

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.lg;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.xl;

    return BoxyArtCard(
      padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGridVersion(context, statsList, isDark),
          if (showAdminMetrics) ...[
            SizedBox(height: (spacing?.cardToCard ?? AppSpacing.xl) * 1.5),
            const Divider(),
            SizedBox(height: (spacing?.cardToCard ?? AppSpacing.xl) * 1.5),
            _buildGridVersion(context, adminStatsList, isDark),
            const SizedBox(height: AppSpacing.x2l),
            const Divider(),
          ],
        ],
      ),
    );
  }
}
