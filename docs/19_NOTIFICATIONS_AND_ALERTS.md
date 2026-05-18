# Notifications & Alerts Reference

This document catalogues every notification, alert, and in-app message the app generates — what triggers it, who receives it, and where it appears.

---

## 1. Persistent Notifications (Notification Inbox)

These are saved to Firestore and appear in the member's notification inbox (bell icon on home screen). They persist until the member deletes them.

### Model fields
- `recipientId` — single member ID
- `title` — short heading
- `message` — body text (plain or rich text Quill delta JSON)
- `category` — controls icon and accent colour (`Scoring`, `Announcement`, `Note`, `Urgent Alert`, `Event Update`, `Social`)
- `actionUrl` — optional deep-link destination
- `eventId` — optional event association
- `isRead` — read/unread state

---

### 1.1 Scoring — Verification Sign-off

**Trigger:** Player or marker taps the sign-off button on the verify screen.

| Scenario | Recipient | Title | Message |
|---|---|---|---|
| Player signs off first | Marker | Score Confirmation | "{PlayerName} has confirmed the scores you recorded" |
| Marker signs off first | Player | Scores Confirmed | "{MarkerName} has confirmed your scores — please sign off" |
| Both parties signed, card clean | All admins | Scorecard Verified | "{PlayerName}'s scorecard has been verified by both parties" |

**Where it appears:** Notification inbox → tapping the notification navigates to the event scores hub.

---

### 1.2 Scoring — Conflict Detected

**Trigger:** Both player and marker have signed off but hole scores don't match.

| Recipient | Message |
|---|---|
| Player | "Conflict on hole {X, Y} — speak to your scorer before leaving the course." |
| Marker | "Conflict on hole {X, Y} for {PlayerName} — speak to the scorer." |
| All admins | "{PlayerName} has conflicts on hole {X, Y} — please resolve before the field leaves." |

**Category:** Scoring (amber accent in inbox)

**Where it also appears:** Amber snackbar for the person who triggered sign-off: "Score conflict on hole X — scorer notified"

---

### 1.3 Scoring — Scorecard Unlocked by Admin

**Trigger:** Admin unlocks a submitted/reviewed scorecard for re-entry.

| Recipient | Message |
|---|---|
| Player | "An admin has unlocked your scorecard. Please review your scores and re-verify." |
| Marker (if different from player) | "An admin has unlocked {PlayerName}'s scorecard. Please re-verify their scores." |

**Best-effort send** — does not block the unlock operation if notification fails.

---

### 1.4 Scoring — Player Picked Up / Left Round

**Trigger:** Marker marks a player as "Picked Up" (DQ) on the story sheet during live scoring.

| Recipient | Message |
|---|---|
| Group captain | "{PlayerName} has picked up on hole {N} and left the round. Please reassign their marker." |
| Marker assigned to player | "{PlayerName} has left the round. A new marker will be assigned to your card." |

---

### 1.5 Admin Broadcast

**Trigger:** Admin composes and sends a notification from Admin → Comms → Compose.

**Recipients:** Dynamic — one of:
- All members
- Registered participants for a specific event
- A static distribution list
- A smart (rules-based) distribution list

**Categories available:** `Announcement`, `Note`, `Urgent Alert`, `Event Update`, `Social`

**Message format:** Rich text editor (Quill), supports inline images.

**Where it appears:** Notification inbox. `Urgent Alert` category shows a coral warning icon.

---

### 1.6 Event Feed / Newsletter

**Trigger:** Admin publishes a feed item (Newsletter, Flash Update, Poll) from the event broadcast screen.

**Recipients:** All members registered for the event.

**Where it appears:** 
- Notification inbox (individual copy per member)
- Event hub → feed section (shared feed item embedded in event)

---

## 2. In-App Snackbars (Transient Toasts)

Displayed at the bottom of the screen for ~3 seconds. Not stored anywhere. Colour-coded:
- **Lime / green** — success
- **Coral / red** — error
- **Amber** — warning or conflict
- **Default (dark)** — neutral feedback

### 2.1 Scoring & Verification

| Message | Trigger | Who sees it |
|---|---|---|
| "Score conflict on hole X — scorer notified" | Both parties signed off with discrepancy | Person who triggered sign-off |
| "{Player}'s scorecard submitted" | Clean sign-off complete | Person who triggered sign-off |
| "Your scorecard submitted" | Player signs their own clean card | Player |
| "Sign-off failed: {error}" | Sign-off operation errors | Scoring party |
| "Scorecard reopened for editing." | Player unsubmits scorecard | Player |
| "Scores synced successfully!" | Player copies partner scores | Player |
| "Failed to save score — check connection" | Live score entry save fails | Scorer |
| "All conflicts resolved — card marked as reviewed" | Admin resolves last conflicted hole | Admin/Scorer |
| "Error saving score: {error}" | Score save fails in admin editor | Admin/Scorer |

### 2.2 Event Administration

| Message | Trigger | Who sees it |
|---|---|---|
| "Grouping saved!" | Admin saves grouping | Admin |
| "Published!" / "Unpublished" | Admin toggles grouping visibility | Admin |
| "All PHCs recalculated from latest member profiles." | Admin recalculates PHCs | Admin |
| "Calculating stats..." / "Stats recalculated and saved!" | Stats recalculation | Admin |
| "Event Closed & Stats Finalized" | Admin closes event | Admin |
| "Event Reopened" | Admin reopens event | Admin |
| "Reminders sent to players with incomplete scorecards." | Admin sends completion reminders | Admin |
| "Manual cuts updated and PHCs recalculated" | Admin updates manual cuts | Admin |

### 2.3 Member Management

| Message | Trigger | Who sees it |
|---|---|---|
| "Please fill in all required fields." | Incomplete member profile save | User / Admin |
| "Uploading image..." / "Upload failed: {error}" | Profile photo upload | User / Admin |
| "Payment reminder sent to {Name}" | Admin sends renewal reminder | Admin |
| "Renewals processed successfully!" | Batch renewal processing | Admin |

### 2.4 Notifications & Comms

| Message | Trigger | Who sees it |
|---|---|---|
| "Note published successfully!" | Notification sent | Admin |
| "No recipients found." | No members match criteria | Admin |
| "Draft saved successfully!" | Notification saved as draft | Admin |
| "Distribution list created!" | New audience list saved | Admin |
| "List updated successfully!" | Distribution list edited | Admin |

### 2.5 Settings & Infrastructure

| Message | Trigger | Who sees it |
|---|---|---|
| "✅ Activity cleared (Scaffolding Preserved)" | Activity data wipe completes | Admin |
| "✅ System data wiped successfully" | Full factory reset completes | Admin |
| "✅ Member Roster Hardened Successfully" | Member seed completes | Admin |
| "✅ UAT Environment Ready" | UAT seed completes | Admin |

### 2.6 Gallery / Media

| Message | Trigger | Who sees it |
|---|---|---|
| "Photo uploaded successfully!" | Event photo uploaded | Member |
| "Error uploading: {error}" | Photo upload fails | Member |

---

## 3. Confirmation Dialogs

Modal dialogs that require the user to confirm or cancel before an action proceeds.

| Dialog title | Trigger | User | Options |
|---|---|---|---|
| "Submit Scorecard?" | Player submits scorecard | Player | SUBMIT / CANCEL |
| "Unsubmit Scorecard?" | Player withdraws submission | Player | UNSUBMIT / CANCEL |
| "Sync Scores?" | Player copies partner scores | Player | SYNC / CANCEL |
| "Pick Up — Disqualification" | Player picks up on hole | Player | ACCEPT DQ / CANCEL |
| "Not Played — Disqualification" | Player marks hole not played | Player | ACCEPT DQ / CANCEL |
| "Resolve Conflict — Hole {N}" | Admin edits a conflicted hole | Admin/Scorer | Text input for reason + CONFIRM / CANCEL |
| "Approve Scorecards?" | Admin approves all submitted cards | Admin | APPROVE / CANCEL |
| "Reassign Marker?" | Admin reassigns a marker | Admin | OPEN MARKER SHEET / CANCEL |
| "Confirm Send" (with recipient count) | Admin sends notification | Admin | CONFIRM / CANCEL |
| "Clear Events & Members?" | Admin wipes activity data | Admin | CLEAR / CANCEL |
| "Total System Wipe?" | Admin factory resets | Admin | WIPE ALL / CANCEL |
| "Initialize UAT?" | Admin seeds UAT data | Admin | INITIALIZE / CANCEL |

---

## 4. Bottom Sheets

Slide-up panels that provide additional context or controls without leaving the current screen.

| Sheet | Trigger | Content | Who sees it |
|---|---|---|---|
| Hole Story | Player taps hole tag during scoring | Gimme, Pick Up, Not Played, Penalty stroke options | Player / Marker |
| Scorecard Details | Viewing a scorecard from verify list | Hole-by-hole scores, verify / approve buttons | Scoring party / Admin |
| Member Details | Tapping a member anywhere | Profile fields, handicap, photo upload | All |
| Match Bracket | Tapping match play bracket link | Tournament bracket visualisation | Member / Admin |
| Marker Selection | Admin reassigning a marker | Player list for selection | Admin |
| Grouping Controls | Admin grouping screen | Group reassignment, player swaps | Admin |

---

## 5. Where Notifications Appear — Summary

| Notification surface | Location in app | Persistence |
|---|---|---|
| Notification inbox | Home screen → bell icon (top right) | Permanent until deleted |
| In-app snackbar | Bottom of screen, overlays nav bar | ~3 seconds |
| Confirmation dialog | Modal overlay, blocks interaction | Until confirmed or cancelled |
| Bottom sheet | Slides up from bottom | Until dismissed |
| Amber conflict banner | Inside scorecard editor, below player info | While conflicts remain unresolved |

---

## 6. Recipient Determination Logic

| Recipient | How resolved |
|---|---|
| Player | `scorecard.entryId` → matched to `event.registrations` |
| Marker | `scorecard.markerId` → matched to `event.registrations` |
| Group captain | First player with `isCaptain == true` in `event.grouping['groups']` |
| All admins | All members where `role == admin` or `role == superAdmin` |
| Event participants | `event.registrations.memberId` for all confirmed registrations |
| Guest players | Entry IDs have `_guest` suffix — base ID stripped before inbox delivery |

---

## 7. Notification Send Behaviour

- All notification sends are **best-effort** — wrapped in try/catch so a notification failure never blocks the action that triggered it (e.g. a failed DQ notification does not prevent the scorecard from being updated).
- Firestore path: `notifications/{notificationId}` (global) and `members/{memberId}/notifications/{notificationId}` (per-member stream).
- Notifications with an empty or missing `id` field use Firestore `.add()` (auto-ID) instead of `.doc(id).set()` to avoid an empty document path error.
