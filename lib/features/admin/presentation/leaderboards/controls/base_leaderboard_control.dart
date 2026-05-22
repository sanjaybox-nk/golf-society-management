import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';

mixin BaseLeaderboardControlMixin<T extends StatefulWidget> on State<T> {

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  Widget buildInfoCard(List<(String, String)> rows) {
    final primary = Theme.of(context).colorScheme.primary;
    return BoxyArtCard(
      backgroundColor: primary.withValues(alpha: AppColors.opacityLow),
      border: Border.all(
        color: primary.withValues(alpha: AppColors.opacityBorder),
        width: AppShapes.borderThin,
      ),
      padding: const EdgeInsets.all(AppSpacing.standard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows.map((r) => Padding(
          padding: EdgeInsets.only(bottom: r == rows.last ? 0 : AppSpacing.sm),
          child: buildInfoRow(r.$1, r.$2),
        )).toList(),
      ),
    );
  }

  Widget buildInfoRow(String label, String value, {bool isBold = false}) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label.toUpperCase(),
            style: AppTypography.micro.copyWith(
              fontWeight: AppTypography.weightBold,
              color: primary,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            style: AppTypography.micro.copyWith(
              fontWeight: isBold ? AppTypography.weightBold : AppTypography.weightRegular,
              color: isDarkMode ? AppColors.dark200 : AppColors.dark400,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInfoBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        text,
        style: AppTypography.micro.copyWith(
          color: isDarkMode ? AppColors.dark200 : AppColors.dark400,
          fontWeight: AppTypography.weightRegular,
        ),
      ),
    );
  }

  String formatEnum(String val) {
    final exp = RegExp(r'(?<=[a-z])[A-Z]');
    final result = val.replaceAllMapped(exp, (m) => ' ${m.group(0)}');
    return result.toUpperCase();
  }

  String ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  Widget buildPointRow({
    required int position,
    required int points,
    required void Function(int pos, int val) onChanged,
    required void Function(int pos) onRemove,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.standard,
        vertical: AppSpacing.standard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${ordinal(position).toUpperCase()} PLACE',
            style: AppTypography.labelStrong.copyWith(
              fontWeight: AppTypography.weightBold,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 72,
            child: TextFormField(
              initialValue: points.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTypography.labelStrong.copyWith(
                fontWeight: AppTypography.weightHeavy,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppSpacing.atomic,
                  horizontal: AppSpacing.xs,
                ),
              ),
              onChanged: (val) {
                final v = int.tryParse(val);
                if (v != null) onChanged(position, v);
              },
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'PTS',
            style: AppTypography.micro.copyWith(
              color: isDark ? AppColors.dark200 : AppColors.dark400,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
          const SizedBox(width: AppSpacing.atomic),
          GestureDetector(
            onTap: () => onRemove(position),
            child: Icon(
              Icons.remove_circle_outline_rounded,
              size: AppShapes.iconMd,
              color: theme.colorScheme.error.withValues(alpha: AppColors.opacityStrong),
            ),
          ),
        ],
      ),
    );

    return Dismissible(
      key: ValueKey('pos_$position'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(position),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.standard),
        color: theme.colorScheme.error.withValues(alpha: AppColors.opacityLow),
        child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
      ),
      child: content,
    );
  }

  Widget buildAddButton({
    required String label,
    required VoidCallback onTap,
    IconData icon = Icons.add_rounded,
  }) {
    return BoxyArtButton(
      title: label,
      onTap: onTap,
      isTinted: true,
      icon: icon,
      fullWidth: true,
    );
  }

  Widget buildScopeSelector({
    required LeaderboardScope value,
    required ValueChanged<LeaderboardScope?> onChanged,
  }) {
    final description = switch (value) {
      LeaderboardScope.seasonOnly => 'Only counts Standard Season events.',
      LeaderboardScope.invitationalsOnly => 'Only counts Non-Season events.',
      LeaderboardScope.global => 'Counts ALL events in the season date range.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtDropdownField<LeaderboardScope>(
          label: 'Event Scope',
          prefixIcon: const Icon(Icons.public_rounded),
          value: value,
          items: LeaderboardScope.values
              .map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(v == LeaderboardScope.invitationalsOnly
                        ? 'NON-SEASON ONLY'
                        : formatEnum(v.name)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
        buildInfoBubble(description),
      ],
    );
  }
}
