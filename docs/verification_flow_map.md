# Verification Flow Map
## Scorecard lifecycle: member view → admin view → notifications

---

## Admin Screen Architecture (agreed model)

Four lists. Players start in Live Field and graduate out as their card progresses.

```
┌─────────────────────────────────────────┐
│  LIVE FIELD  (all players in progress)  │
│  ⚫ Grey  = Still playing               │
│  🟡 Amber = Wrapping up / validating    │
│                                         │
│  Cards EXIT this list when:             │
│  • Conflict detected → Conflicts        │
│  • Both signed, clean → Ready to Verify │
└─────────────────────────────────────────┘
           ↓ conflict          ↓ both signed, clean
┌──────────────────┐  ┌──────────────────────┐
│   CONFLICTS      │  │   READY TO VERIFY    │
│  🔴 Red header   │  │   Admin closes card  │
│  Needs resolving │  │   before field leaves│
└──────────────────┘  └──────────────────────┘
                                ↓ admin approves
                      ┌──────────────────────┐
                      │      VERIFIED        │
                      │  🟢 Green / lime     │
                      │  Card closed         │
                      └──────────────────────┘
```

**Colour is at badge-border level in Live Field only.**  
Red does not appear in the Live Field list — conflict cards leave it entirely.  
The Conflicts list existing is itself the red signal for admin.

---

## Status Definitions

| Status | Meaning |
|--------|---------|
| `draft` | Scores being entered, not submitted |
| `submitted` | Submitted; awaiting sign-off(s) |
| `finalScore` | Both parties signed off, scores agree — ready for admin |
| `reviewed` | Conflict was resolved (admin corrected scores) |
| `approved` | Admin/scorer has verified and approved the card |

---

## Live Field — Badge Colour & Subtext

| Badge border | Subtext | Card state |
|---|---|---|
| ⚫ Grey | Still playing | `draft`, holes incomplete |
| 🟡 Amber | Round complete — validating | `draft`, all 18 holes filled |
| 🟡 Amber | Awaiting sign-off | `submitted`, neither signed |
| 🟡 Amber | Marker not yet signed off | `submitted`, player signed only |
| 🟡 Amber | Player not yet signed off | `submitted`, marker signed only |
| 🟡 Amber | Withdrawn | WD scoring status |
| 🟡 Amber | Disqualified | DQ scoring status |
| 🟡 Amber | No return | NR scoring status |

Cards leave this list when:
- Conflict detected → **Conflicts list**
- `finalScore` or `reviewed` (both signed, no conflict) → **Ready to Verify list**
- `approved` → **Verified list**

---

## Conflicts List

Cards appear here when both parties have signed off but scores disagree on one or more holes.  
The list header is coral/red — its existence is the urgent signal.

**What admin sees per card:**
- Player name
- Which holes have conflicts
- Both scores side by side

**Admin actions:**
1. Open card in editor
2. Correct score for conflicted holes (adds `HoleAuditEntry` to audit log)
3. Card status moves to `reviewed`
4. Card graduates to **Ready to Verify**

**Member notifications on conflict:**
- Player: "Score Conflict — Action Required" — conflict on hole X, speak to your scorer
- Marker: "Score Conflict — Action Required" — conflict on hole X for [Player]
- Admins: "Score Conflict Needs Resolution" — [Player] has conflicts on hole X

---

## Ready to Verify List

Cards appear here when both parties have signed off with matching scores.  
Admin confirms the card is correct and closes it.

**Condition:** `status == finalScore` (clean) OR `status == reviewed` (conflict resolved)

**What admin sees per card:**
- Player name + gross / net score
- Whether any audit corrections were made
- Approve button in card editor

**Admin actions:**
1. Open card in editor
2. Review scores, check audit log
3. Tap **Approve Card**
4. Card moves to Verified

**Member notification on approval:**
- "Scorecard Verified"
- If amendments: "X score amendment(s) were made — tap to view your card"
- Taps through to Scorecard tab

---

## Verified List

Cards appear here once admin has approved them. This is the permanent record.

**Condition:** `status == approved`

**What member sees:**
- "Verified" badge (lime green)
- Scorecard fully locked
- Score Amendments card visible if `holeAuditLog` is non-empty
- Notification already sent at approval

---

## Stage-by-Stage: What Member Sees & Actions Required

### 1. Still Playing (grey)
**Member view:** Scoring tab active, +/− inputs enabled, marker's card alongside  
**Action:** Enter scores hole by hole  
**Next state:** Round complete — validating (all 18 filled)

### 2. Round Complete — Validating (amber)
**Member view:** "Verify Score" badge tappable, scoring tab shows complete card  
**Action:** Player and marker compare scores side by side, then player taps Verify Score  
**Next state:** Awaiting sign-off

### 3. Awaiting Sign-off (amber)
**Member view:** "Submitted" badge, scoring locked  
**Action:** Both player and marker open verification sheet and sign off  
**Notification sent:** When player signs → marker notified. When marker signs → player notified.  
**Next state (clean):** Card leaves Live Field → Ready to Verify  
**Next state (conflict):** Card leaves Live Field → Conflicts

### 4. Conflicts (red list)
**Member view:** "Conflict" badge (coral), conflicted holes highlighted  
**Action:** Player and marker agree on correct score; one corrects their entry  
**Notification sent:** Both parties + admins alerted with hole numbers  
**Next state:** Card moves to Ready to Verify once resolved

### 5. Ready to Verify (admin action)
**Member view:** "Final Score" badge, everything locked, waiting for admin  
**Action:** None — admin takes over  
**Next state:** Verified (on admin approval)

### 6. Verified
**Member view:** "Verified" badge, Score Amendments card if applicable  
**Action:** None  
**Notification:** "Scorecard Verified" with link to Scorecard tab

---

## Notification Summary

| Trigger | Recipient | Title | Message |
|---------|-----------|-------|---------|
| Player signs off | Marker | Scorecard Verification | "[Player] has confirmed your scores — please sign off" |
| Marker signs off | Player | Scorecard Verification | "[Marker] has confirmed the scores you recorded" |
| Both sign, clean | All admins | Score Ready for Approval | "[Player]'s scorecard has been verified by both parties" |
| Both sign, conflict | Player | Score Conflict — Action Required | "Conflict on hole X — speak to your scorer before leaving the course" |
| Both sign, conflict | Marker | Score Conflict — Action Required | "Conflict on hole X for [Player] — speak to the scorer" |
| Both sign, conflict | All admins | Score Conflict Needs Resolution | "[Player] has conflicts on hole X — resolve before the field leaves" |
| Admin approves | Player | Scorecard Verified | "Your scorecard for [Event] has been verified. [Amendment note if applicable]" |

---

## Notification Gaps (to address)

- No `actionUrl` on conflict notifications — member cannot tap to navigate to their card
- No nudge when a card has been amber (awaiting) for a set time after round ends
- No notification to player when admin manually corrects a score mid-review (only at final approval)

---

## ⚠️ Bug Fixed

`validateAndFinalizeHandshake` previously set `status = submitted` when both parties signed cleanly. This meant cards were invisible in admin — they didn't appear in any list. Fixed to `status = finalScore`.

---

## Test Checklist (per stage)

- [ ] **Still playing** — grey badge, +/− inputs active, marker card visible
- [ ] **Round complete — validating** — amber badge, "Verify Score" tappable, all 18 holes filled
- [ ] **Awaiting sign-off** — amber badge, scoring locked, correct party notified
- [ ] **Conflict** — card leaves Live Field, appears in Conflicts list, both parties notified
- [ ] **Ready to Verify** — card leaves Live Field, appears in Ready to Verify, "Final Score" badge on member view
- [ ] **Verified** — "Verified" badge, amendments card if applicable, notification navigates to Scorecard tab
- [ ] **Marker card** — always visible on Scoring tab regardless of lock state
- [ ] **ADD / REMOVE CARD** — always visible regardless of lock state
