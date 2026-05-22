import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/society_config.dart';
import '../../domain/registration_logic.dart';

class RegistrationStatsCard extends ConsumerWidget {
  final GolfEvent event;
  final bool isCompact;

  const RegistrationStatsCard({
    super.key,
    required this.event,
    this.isCompact = false,
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
      final spacing = Theme.of(context).extension<AppSpacingTokens>();
      final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.lg;
      final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.xl;

      return BoxyArtCard(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
        child: _buildGridVersion(
          context, 
          _getCompactStats(event, stats, playingValue, reserveValue),
          isDark,
        ),
      );
    }

    return _buildFullVersion(context, stats, isDark, playingValue, reserveValue, currency, config);
  }

  List<ModernMetricStat> _getCompactStats(GolfEvent event, RegistrationStats stats, String playing, String reserve) {
    final availableBuggies = event.availableBuggies ?? 0;
    final buggyCapacity = availableBuggies * 2;
    return [
      // Capacity
      ModernMetricStat(value: '${event.maxParticipants ?? 0}', label: 'Capacity', icon: Icons.groups_rounded, isCompact: true),
      // People
      ModernMetricStat(value: playing, label: 'Playing', icon: Icons.check_circle_rounded, isCompact: true),
      ModernMetricStat(value: reserve, label: 'Reserve', icon: Icons.hourglass_top_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.confirmedGuests + stats.reserveGuests + stats.waitlistGuests}', label: 'Guests', icon: Icons.person_add_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.waitlistGolfers}', label: 'Waitlist', icon: Icons.priority_high_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.withdrawnCount}', label: 'Withdrawn', icon: Icons.person_remove_rounded, isCompact: true),
      // Food
      if (event.hasBreakfast) ModernMetricStat(value: '${stats.breakfastCount}', label: 'Breakfast', icon: Icons.breakfast_dining_rounded, isCompact: true),
      if (event.hasLunch) ModernMetricStat(value: '${stats.lunchCount}', label: 'Lunch', icon: Icons.lunch_dining_rounded, isCompact: true),
      if (event.hasDinner) ModernMetricStat(value: '${stats.dinnerCount}', label: 'Dinner', icon: Icons.restaurant_rounded, isCompact: true),
      // Misc
      ModernMetricStat(value: buggyCapacity > 0 ? '${stats.buggyCount}/$buggyCapacity' : '${stats.buggyCount}', label: 'Buggies', icon: Icons.electric_rickshaw_rounded, isCompact: true),
    ];
  }

  Widget _buildGridVersion(BuildContext context, List<Widget> items, bool isDark) {

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
    final availableBuggies = event.availableBuggies ?? 0;
    final buggyCapacity = availableBuggies * 2;

    final statsList = [
      // Capacity
      ModernMetricStat(value: '${event.maxParticipants ?? 0}', label: 'Capacity', icon: Icons.groups_rounded, isCompact: true),
      // People
      ModernMetricStat(value: playingValue, label: 'Playing', icon: Icons.check_circle_rounded, isCompact: true),
      ModernMetricStat(value: reserveValue, label: 'Reserve', icon: Icons.hourglass_top_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.confirmedGuests + stats.reserveGuests + stats.waitlistGuests}', label: 'Guests', icon: Icons.person_add_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.waitlistGolfers}', label: 'Waitlist', icon: Icons.priority_high_rounded, isCompact: true),
      ModernMetricStat(value: '${stats.withdrawnCount}', label: 'Withdrawn', icon: Icons.person_remove_rounded, isCompact: true),
      // Food
      if (event.hasBreakfast) ModernMetricStat(value: '${stats.breakfastCount}', label: 'Breakfast', icon: Icons.breakfast_dining_rounded, isCompact: true),
      if (event.hasLunch) ModernMetricStat(value: '${stats.lunchCount}', label: 'Lunch', icon: Icons.lunch_dining_rounded, isCompact: true),
      if (event.hasDinner) ModernMetricStat(value: '${stats.dinnerCount}', label: 'Dinner', icon: Icons.restaurant_rounded, isCompact: true),
      // Misc
      ModernMetricStat(value: buggyCapacity > 0 ? '${stats.buggyCount}/$buggyCapacity' : '${stats.buggyCount}', label: 'Buggies', icon: Icons.electric_rickshaw_rounded, isCompact: true),
    ];


    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.lg;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.xl;

    return BoxyArtCard(
      padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
      child: _buildGridVersion(context, statsList, isDark),
    );
  }
}
