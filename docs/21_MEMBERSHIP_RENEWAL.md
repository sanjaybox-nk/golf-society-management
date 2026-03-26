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
The central command center for processing submissions.
- **Grouped Views**: Members are categorized by their chosen status.
- **Batch Processing**: Admins can confirm renewals in bulk, which updates the `membershipEndDate` to the next cycle and resets the renewal intent.
- **Archival**: Suspended or leaving members can be archived with one click.

## Logical Flow
1. **End of Season Approaches**: Admin sets the `globalMembershipEndDate`.
2. **Renewal Opens**: Admin toggles `isRenewalActive`.
3. **Member Decision**: Member sees a banner on Home Screen -> Clicks "Renew Now" -> Selects Status.
4. **Admin Review**: Admin opens Renewal Hub -> Reviews submissions.
5. **Finalization**: Admin clicks "Batch Confirm" -> Member dates are synced -> Season resets.
