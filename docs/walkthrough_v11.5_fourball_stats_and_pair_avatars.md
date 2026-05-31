# Walkthrough v11.5 — Fourball Stats Audit & Pair Avatar Display

**Session**: 2026-05-31  
**Scope**: Stats engine correctness for Fourball, pair avatar layout in leaderboard and groups, Stableford + Match Play Overlay context.

---

## 1. Stats Engine Audit — Fourball (Betterball)

### Problem: 17-vs-16 participant discrepancy

The analysis engine counts all individual scorecards (17 in the test field), while the leaderboard and groupings show 16 players (8 pairs). The odd-field case means one player has a scorecard but no pair. This discrepancy surfaced in the Stableford distribution chart — the engine reported 17 buckets across individual scores rather than 8 pair scores.

### Fix: Rebucket distribution from `data.leaderboard`

In `event_stats_tab.dart`, after the analysis engine runs, the Stableford distribution is overridden for Fourball by iterating `data.leaderboard` (pair entries) and re-assigning each pair's total score to a bucket:

```dart
if (isFourball && isStableford) {
  stablefordBuckets = {'<20': 0, '20-25': 0, '26-30': 0, '31-35': 0, '36+': 0};
  for (final entry in data.leaderboard) {
    final pts = entry.score;
    if (pts < 20) { stablefordBuckets['<20'] = stablefordBuckets['<20']! + 1; }
    else if (pts <= 25) { stablefordBuckets['20-25'] = stablefordBuckets['20-25']! + 1; }
    else if (pts <= 30) { stablefordBuckets['26-30'] = stablefordBuckets['26-30']! + 1; }
    else if (pts <= 35) { stablefordBuckets['31-35'] = stablefordBuckets['31-35']! + 1; }
    else { stablefordBuckets['36+'] = stablefordBuckets['36+']! + 1; }
  }
}
```

Chart title → `"PAIR SCORE DISTRIBUTION"`, footer → `"Counts how many pairs finished within each point range."`.

### Fix: Personal tab uses individual `holePoints`

`data.leaderboard` entries carry pair best-ball `holePoints`. The personal tab must show the signed-in player's *individual* contribution, not the pair's best-ball:

```dart
holePoints: isFourball
    ? (myScoreEntry.result.holePoints)
    : (myLbEntry?.holePoints ?? []),
```

### Fourball context footnotes

`isFourball` is propagated to:
- `RoundHoleGrid` — shows subtitle: *"Your individual points — not the pair's best-ball score"* (Stableford + Fourball only)
- `ConsistencyStatCard` — footnote: stats based on individual scores
- `BounceBackStatCard` — footnote under the recovery metric
- `StablefordDistributionChart` — title/footer use "pair" language

---

## 2. Pair Avatar Display

### Problem

Fourball leaderboard entries showed a single "G" badge avatar (using the first player's initial), with no indication of the second pair member.

### Solution: Stacked vertical column in `BoxyArtMemberRow`

When `partnerInitials` is non-null, `_buildAvatar()` returns a `Column` instead of a single `BoxyArtAvatar`:

```dart
Widget _buildAvatar(BuildContext context) {
  if (partnerInitials != null) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BoxyArtAvatar(url: avatarUrl, initials: extractInitials(initials), radius: 20),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: BoxyArtAvatar(url: partnerAvatarUrl, initials: extractInitials(partnerInitials!), radius: 20),
        ),
      ],
    );
  }
  return BoxyArtAvatar(url: avatarUrl, initials: extractInitials(initials), radius: 24);
}
```

**Why `bottom: 6`**: The `Row` uses `crossAxisAlignment: stretch` and `IntrinsicHeight`. `spaceBetween` puts the second avatar at the card bottom edge — `bottom: 6` nudges it up to align with the second name row. Avatar radius shrinks to 20 (from 24) in pair mode to fit two stacked vertically.

### Data flow

`event_leaderboard.dart`:
```dart
final String? partnerId = e.teamMemberIds.length > 1 ? e.teamMemberIds[1] : null;
final partnerMember = partnerId != null ? memberMap[partnerId] : null;
// → partnerAvatarUrl: partnerMember?.avatarUrl,
```

`LeaderboardEntry` → new field `partnerAvatarUrl`

`leaderboard_widget.dart`:
```dart
partnerAvatarUrl: isPair ? entry.partnerAvatarUrl : null,
partnerInitials: isPair && entry.teamMemberNames != null && entry.teamMemberNames!.length > 1
    ? entry.teamMemberNames![1]
    : null,
```

Same partner lookup in `event_shared_logic.dart` for the scorecard modal flow.

### Groups tab (`grouping_card.dart`)

`buildPairScoreTile` replaced its single combined-initials avatar with the same vertical column:

```dart
Column(
  mainAxisSize: MainAxisSize.max,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    BoxyArtAvatar(url: pair[0]... avatarUrl, initials: pair[0].name[0].toUpperCase(), radius: 20),
    if (pair.length > 1)
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: BoxyArtAvatar(url: pair[1]... avatarUrl, initials: pair[1].name[0].toUpperCase(), radius: 20),
      ),
  ],
),
```

Note: `extractInitials` is not available in `grouping_card.dart` — uses `pair[i].name[0].toUpperCase()` directly.

---

## 3. Stableford + Match Play Overlay Context

The "Seed Stableford + Match Play Overlay" seeder creates a **new event** with a timestamped ID — it does **not** clear any existing activity data. Safe to run alongside other seeds.

---

## Files Changed

| File | Change |
|---|---|
| `lib/features/events/presentation/tabs/event_stats_tab.dart` | Fourball distribution rebucket, individual holePoints for personal tab, propagate `isFourball` flag |
| `lib/features/events/presentation/widgets/rich_stats/performance_metrics.dart` | Fourball footnotes in ConsistencyStatCard, BounceBackStatCard, RoundHoleGrid subtitle |
| `lib/features/events/presentation/widgets/rich_stats/distribution_charts.dart` | Pair language in StablefordDistributionChart |
| `lib/design_system/widgets/boxy_art_member_row.dart` | `partnerAvatarUrl`, `partnerInitials` fields; stacked column avatar layout |
| `lib/features/competitions/presentation/widgets/leaderboard_widget.dart` | `partnerAvatarUrl` on `LeaderboardEntry`; pass to `BoxyArtMemberRow` |
| `lib/features/events/presentation/widgets/event_leaderboard.dart` | Partner member lookup, `partnerAvatarUrl` populated |
| `lib/features/events/presentation/tabs/event_shared_logic.dart` | Same partner lookup for scorecard modal path |
| `lib/features/events/presentation/widgets/grouping_card.dart` | `buildPairScoreTile` — stacked column avatar layout |
