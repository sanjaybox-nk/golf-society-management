import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';

/// Shared Design 4.x helper methods for all leaderboard controls.
/// Mirrors the [BaseCompetitionControl] pattern so the two families stay in sync.
mixin BaseLeaderboardControlMixin<T extends StatefulWidget> on State<T> {
  // ─────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  /// Tinted info card with (label, description) rows — Design 4.x primary accent.
  Widget buildInfoCard(List<(String, String)> rows) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.x2l),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: isDarkMode ? 0.08 : 0.05),
        borderRadius: AppShapes.md,
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: isDarkMode ? 0.15 : 0.1),
          width: 1,
        ),
      ),
      child: BoxyArtFormColumn(
        spacing: AppSpacing.md,
        children: rows.map((r) => buildInfoRow(r.$1, r.$2, isLast: r == rows.last)).toList(),
      ),
    );
  }

  /// Single label + description row inside an info card.
  Widget buildInfoRow(String label, String value, {bool isBold = false, bool isLast = false}) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label.toUpperCase(),
              style: AppTypography.micro.copyWith(
                fontWeight: AppTypography.weightBlack,
                color: theme.colorScheme.primary,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            style: AppTypography.label.copyWith(
              height: 1.4,
              fontWeight: isBold
                  ? AppTypography.weightBold
                  : AppTypography.weightRegular,
              color: isDarkMode ? AppColors.dark100 : AppColors.dark700,
            ),
          ),
        ),
      ],
    );
  }

  /// Standardised monochromatic hint text below a field.
  Widget buildInfoBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.micro.copyWith(
          color: isDarkMode ? AppColors.dark200 : AppColors.dark400,
          height: 1.4,
          fontWeight: AppTypography.weightRegular,
        ),
      ),
    );
  }

  /// Converts camelCase enum name to "Title Case".
  String formatEnum(String val) {
    if (val == 'holeInOne') return 'Hole In One';
    final exp = RegExp(r'(?<=[a-z])[A-Z]');
    final result = val.replaceAllMapped(exp, (m) => ' ${m.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
  }

  /// Ordinal suffix for position numbers (1st, 2nd, 3rd…).
  String ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  /// Design 4.x points row — position label + numeric input + pts pill + remove.
  Widget buildPointRow({
    required int position,
    required int points,
    required void Function(int pos, int val) onChanged,
    required void Function(int pos) onRemove,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.standard),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Position label ─────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ordinal(position),
                  style: AppTypography.cardTitle.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
                Text(
                  'Place',
                  style: AppTypography.micro.copyWith(
                    color: isDark ? AppColors.dark300 : AppColors.dark400,
                    fontWeight: AppTypography.weightRegular,
                  ),
                ),
              ],
            ),
          ),

          // ── Points input ───────────────────────
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: points.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTypography.cardTitle.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: AppTypography.weightExtraBold,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md, horizontal: AppSpacing.sm),
                fillColor: isDark ? AppColors.dark600 : AppColors.lightHeader,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: AppShapes.md,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppShapes.md,
                  borderSide: BorderSide(
                    color: isDark ? AppColors.dark500 : AppColors.dark100,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppShapes.md,
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (val) {
                final v = int.tryParse(val);
                if (v != null) onChanged(position, v);
              },
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Pts pill ───────────────────────────
          BoxyArtPill.format(
            label: 'PTS',
            color: theme.colorScheme.primary,
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Remove button ──────────────────────
          GestureDetector(
            onLongPress: () => onRemove(position),
            child: IconButton(
              icon: Icon(
                Icons.remove_circle_outline_rounded,
                size: AppShapes.iconMd,
                color: isDark ? AppColors.dark400 : AppColors.dark200,
              ),
              onPressed: () => onRemove(position),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Remove',
            ),
          ),
        ],
      ),
    );
  }

  /// Secondary "Add" action button — always outlined, never solid.
  Widget buildAddButton({
    required String label,
    required VoidCallback onTap,
    IconData icon = Icons.add_circle_outline_rounded,
  }) {
    return Center(
      child: BoxyArtButton(
        title: label,
        onTap: onTap,
        isSecondary: true,
        icon: icon,
      ),
    );
  }

  /// Shared scope selector for filtering events (Season vs Invitational).
  Widget buildScopeSelector({
    required LeaderboardScope value,
    required ValueChanged<LeaderboardScope?> onChanged,
  }) {
    final description = switch (value) {
      LeaderboardScope.seasonOnly => 'Only counts Standard Season events.',
      LeaderboardScope.invitationalsOnly => 'Only counts Invitational / Non-Season events.',
      LeaderboardScope.global => 'Counts ALL events in the season date range.',
    };

    return BoxyArtFormColumn(
      spacing: AppSpacing.xs,
      children: [
        BoxyArtDropdownField<LeaderboardScope>(
          label: 'Event Scope',
          value: value,
          items: LeaderboardScope.values
              .map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(formatEnum(v.name)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
        buildInfoBubble(description),
      ],
    );
  }
}
