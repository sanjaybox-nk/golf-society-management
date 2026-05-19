# Membership Renewal System (Society Model)

## Overview
The Golf Society Management system uses a society-wide, season-based renewal model. Instead of individual member expiry dates, the entire society transitions together at the end of a season.

## Key Components

### 1. Society Configuration (`SocietyConfig`)
- **Global Expiry Date**: The single date when all memberships expire (e.g., Dec 31st).
- **Renewal Window**: A period (default 30 days) before expiry where members are alerted.
- **Activation Toggle**: Admin can manually trigger the "Renew Now" flow.

### 2. Member Status (`MemberRenewalStatus`)
Members can select one of three intents during the renewal window:
- **Renew**: Continue as an active member.
- **Suspend**: Temporarily pause membership (account preserved).
- **Leave**: Withdraw from the society (account archived).

### 3. Home Screen Alerts
Renewal alerts are restricted to the **Home Screen** only. This prevents UI clutter in profiles or member lists while ensuring high visibility for the annual action.

### 4. Admin Renewal Hub
The central command center for processing submissions, accessed via the **RENEWALS** tile in the Admin Dashboard.
- **Architecture**: (April 2026 Refactor) Implemented using the **Thin Shell Presentation** pattern.
    - **Controllers**: Logic resides in `RenewalController` (Riverpod 2.0 Notifier) for selection, filtering, and bulk processing.
    - **Service Layer**: Nudges and notifications are delegated to the shared `AdminActionService`.
    - **Modular Widgets**: UI elements (tiles, sheets) are isolated in `renewal_widgets.dart` for atomic maintainability.
- **Terminology (Design 4.x)**: 
    - **Pending**: Members who have been sent a reminder but have not yet chosen a status.
    - **Renewing**: Members who have chosen to renew but have not yet been marked as "Paid".
    - **Paid**: Members whose renewal fees are confirmed by the Admin.
- **Nudge Tracking**: A dedicated action pill allows Admins to send push notifications to unpaid members.
    - **Visual Indicator**: Uses a **Notification Bell (🔔)** icon to distinguish communication from state-editing.
    - **Nudge Counter**: Displays the frequency of reminders sent (e.g., `NUDGE (3)`) to prevent over-communication.
- **Status Button Affordance**: Interactive status pills (Paid/Renewing) feature a subtle background tint, border, and **Pencil (✎)** icon to indicate they are clickable toggles.
- **Lifecycle Finalization**: marking a member as "Paid" does not automatically make them "Active". Once all payments are tracked in the **PAID** tab, the Admin clicks **"Process Renewals"** to bulk-update lifecycle statuses from `Expired` -> `Active`.
- **Archival**: Suspended or leaving members can be archived with one click.

## Logical Flow
1. **End of Season Approaches**: Admin sets the `globalMembershipEndDate`.
2. **Renewal Opens**: Admin toggles `isRenewalActive`.
3. **Member Decision**: Member sees a banner on Home Screen -> Clicks "Renew Now" -> Selects Status.
4. **Admin Review**: Admin opens Renewal Hub -> Reviews submissions.
5. **Finalization**: Admin clicks "Batch Confirm" -> Member dates are synced -> Season resets.

## Social Membership at Renewal

When `SocietyConfig.enableSocialMembership` is on, the renewal flow has an additional tier choice.

**Social member renewing:**
- Sees `socialMemberFee` (set in Operations → Society Configuration → Treasury Settings)
- Can request upgrade to full membership — admin approves, fee difference tracked manually
- If toggle is later turned off, existing social members retain their status; they must choose Full or Leave at next renewal

**Full member downgrade:**
- A full member can request to downgrade to social at renewal
- Admin approves via member profile → Administrative Controls → "Promote to Full Member" (works in reverse by manually editing role/status)

**Fee configuration:**
- `SocietyConfig.socialMemberFee` — set in Treasury Settings (visible only when `enableSocialMembership` is on)
- Full membership fee is tracked separately in the renewal system

**Phase status (as of 2026-05-19):**
- Phase 1 (model + access gating): complete
- Phase 2 (financial integration + renewal flow UI): planned
