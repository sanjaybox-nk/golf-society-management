# App Glossary & Mechanics

This document defines the key terms, concepts, and mechanics used within the Golf Society Management application.

## Domain Terms (Golf)

**Society**
A group of golfers who organize regular events and competitions. The app serves the needs of this entire group.

**Flight**
A subgroup of golfers (usually 3-4) who play together in a specific match.

**Stableford**
The primary scoring system used. Points are awarded based on the number of strokes taken at each hole relative to par, adjusted for the player's handicap.
-   *Net Par*: 2 Points
-   *Net Birdie*: 3 Points
-   *Net Eagle*: 4 Points

**Handicap (WHS)**
World Handicap System index. A measure of a golfer's potential ability. The app tracks this in the **Locker Room** and strictly formats the display to one decimal place (e.g., `8.4`) using the premium `BoxyArtPill.hc()` component.

**Tee-off Time**
The scheduled start time for a match or specific flight.

**Society Cuts**
Automated handicap adjustments applied to the top 3 finishers of an event. These are temporary "cuts" that reduce a player's starting handicap for a specific duration to maintain field parity.

**Additive (Stacking) Model**
A system where multiple cuts stack together (e.g., -2.0 from a win + -1.0 from a 2nd place = -3.0 total). This ensures that frequent winners face increasing challenges, preventing "dead" achievements.

## App Mechanics (BoxyArt System)

**BoxyArt Theme**
The custom visual language of the app. Characterized by:
-   **Dynamic Branding**: Configurable primary color (default: Mustard Yellow) with automatic contrast calculation.
-   **Soft Shadows**: Custom shadows (`softScale`) that create a floating effect on cards.
-   **Rounded Shapes**: Cards use `BorderRadius.circular(18)` (`AppShapes.rXl`), inputs and buttons use `AppShapes.pill`.
-   **True Minimal Legends**: Minimalist dot + text indicators that eliminate background "pills" for a cleaner, high-density look.
- **True Minimal (v4.5)**: Adherence to Title Case for all content; structural metadata and UI field labels use **ALL-CAPS** with 1.2 letter spacing for maximum distinction.
-   **Design Token Studio**: The expert administrative interface for fine-tuning the society's visual identity. It controls over 30 semantic tokens including semantic colors, radii, and mechanical detailing.
-   **Scoring Aesthetics**: A specialized branding palette that defines the colors for specific golf scores (Eagle, Birdie, etc.) and team identities (Team A/B).
-   **Accessibility**: Automatic text color calculation ensures readability on any background.
-   **Admin Identity**: The mandatory `ADMIN` pill suffix on all administrative scaffolds.

**Locker Room**
The creative name for the **User Profile** section. Here, users can:
-   View their current Handicap Index.
-   Check their Win/Loss statistics.
-   View their **Active Society Cut** breakdown, including recent podium finishes and the remaining event validity for each adjustment.
-   Edit personal details.

**Events Hub**
The central tab for all competition info.
-   **Upcoming**: Future events you can register for.
-   **Past Results**: History of completed matches.
-   **Event Statuses**:
    -   *Draft*: Event being prepared (Admin only).
    -   *Published*: Visible to members and open for registration/scoring.
    -   *Completed*: Event finished and archived in history.
    -   *Cancelled*: Event that was abandoned or called off.

**Floating Bottom Search**
A specialized search bar found in the **Members Directory**. Instead of sitting at the top, it "floats" at the bottom of the screen for easier thumb reach. It contains:
-   **Search**: Triggers real-time text input filtering.
-   **Filter Toggles**: 
  - **C (Current)**: Shows strictly Active members.
  - **O (Other)**: Shows Inactive, Pending, and Archived members.
  - **★ (Committee)**: Filters the list to show only members holding a society role (e.g., Captain).

**Admin Sub-grouping**
To improve management efficiency, the Member List (Admin View) automatically sub-groups "Other" members by their specific status (Pending, Suspended, etc.) with clearly labeled section headers.

**Status Legend**
A minimalist dot + text indicator used throughout the app to show state (e.g., "Active", "Paid", "Due"). Uses semantic colors from `StatusColors`. Also known as `BoxyArtPill.status` (implementing the Legend taxonomy).

**Notification Badge**
A small yellow circle indicating unread items (e.g., messages, new events).

**Storage Service**
The system responsible for securely handling file uploads, such as profile photos, to Firebase Storage. Enforces strict validation rules (e.g., 5MB file size limit).

**Avatar**
The user's profile photo, displayed in the Header Card and Member lists. Managed via the **Locker Room** or Admin Form.

**Communications Hub**
The administrative center for society messaging. It allows admins to compose notifications (broadcasts), manage audience distribution lists, and target specific events using the **Event Picker**.

**Event Comms**
The rebranded term for the event-specific feed management. It allows admins to reorder and pin posts (notes, reports, etc.) within an event's dedicated feed.

**Distribution List**
A custom group of members (e.g., "Spain Trip 2026", "New Joiners") saved by an admin for targeted messaging within the Communications Hub.

**Note Studio**
The rebranded communications suite (formerly Newsletter) for composing dynamic, multi-section notifications with rich text and photo attributions.

**Deep Link**
An action associated with a notification that redirects the user to a specific part of the app (e.g., a specific event details page or their profile) when tapped.

## User Flows

**Registration Statuses**
The app uses a 5-state system to manage event entries:
-   **Confirmed** (Green): Member has registered and paid within the allowed capacity.
-   **Reserved** (Orange): Member has registered but not yet paid (within capacity).
-   **Waitlist** (Red): Registered after capacity was reached. Position is tracked for automatic promotion.
-   **Dinner** (Blue): Member is attending the dinner/social only (not playing golf). Excluded from golfer headcount.
-   **Withdrawn** (Grey): Member has cancelled participation but remains in admin records for history.
-   **Registration History**: A structured audit trail stored within each registration, logging timestamps, actors (Admin/Member), and specific actions (e.g., status updates or detail edits).

**Confirmed but Withdrawn Metric**
A specialized metric displayed in brackets (e.g., `21 (1)`). It simulates the registration queue to identify participants who held a potential confirmed spot but later withdrew.

**FCFS (First-Come, First-Served)**
The core priority system. Event spots and budget buggy spaces are allocated strictly based on the `registeredAt` timestamp.

**Buggy Allocation**
Automatically calculated based on the available buggy count defined by the admin. The system assigns "Confirmed" buggy status to the first N players who requested one, moving others to the "Waitlist" buggy status. **Buggy Cost** is an optional per-buggy fee tracked for each event.

**Registration**
1.  Navigate to **Events**.
2.  Tap on an **Upcoming Event** card.
3.  Tap the **Register** chip (Black pill).
4.  Choose Golf and/or Dinner options.
5.  State is tracked in real-time.

**Member Search**
1.  Go to **Members**.
2.  Tap the floating **Search** button at the bottom.
3.  Type a name. The list filters in real-time.

## Scoring & Competition Concepts

**Game Template**
A reusable set of scoring rules (Format, Mode, Handicap Allowance) that can be applied to any event. Adhering to templates ensures consistency across the society season.

**Handicap Allowance**
The percentage of a player's course handicap used for a specific competition (e.g., 95% for individual Stableford).

**Scramble (Texas/Florida)**
A team format where every player tees off, the best shot is selected, and all players play their next shot from that position. **Texas** usually requires a minimum number of tee shots per player; **Florida** involves the player whose shot was selected sitting out the next stroke.

**Countback (Tie-Break)**
The method used to resolve tied scores by looking at the best performance over the final 9, 6, 3, or 1 holes. To provide clarity on the leaderboard, the system displays these metrics progressively (e.g., `B9: 18 • B6: 12 • B3: 6`).

**Gross Stableford**
A variation of Stableford scoring where points are awarded based on the raw score without any handicap adjustment.

**Max Score**
A stroke-play format with a scoring cap per hole (e.g., Par + 5 or a fixed value like 10). This prevents a single "blow-up" hole from ruining a player's entire round and speeds up play.

**Female Tee Position**
An explicit configuration at the event level that defines which set of tees (e.g., "Red") female players should use. This ensures gender parity in scoring and handicap calculations.

**Explicit Tee Mapping**
The system logic that prioritizes individual player gender and assigned tee positions (Men's Default vs. Female Tee) to resolve the correct Par, SI, and Course Rating data for every scorecard and leaderboard calculation.

**Scoring Force Active**
An admin-level override that allows scoring to be enabled for an event before its official scheduled date. Useful for early starts or testing.

**Scoring Lock**
A security state where an admin freezes all scorecards for an event. Once locked, no further edits can be made by members, ensuring the finality and integrity of the results.

**Matchplay Competition**
A tournament structure (usually a Knockout Bracket or League) that tracks a series of matchplay matches over time.

**Match Play Overlay**
A specialized feature that allows Match Play scoring to be enabled on top of a standard competition (e.g., Stableford). This "Format + Feature" model enables dual-scoring leaderboards.

**Tournament Style Grouping**
A grouping mode for dedicated Match Play events (Ryder Cup, Knockouts) where pairings are determined by a seeded draw or bracket rather than standard society grouping rules.

**Seasonal Standings Hub**
A centralized feature for long-term competition tracking. Supports multiple formats like OoM and Eclectic.

**Order of Merit (OoM)**
A season-long point race where player performance in individual events is converted into a point total based on ranking.

**Eclectic**
A competition format that rewards consistency across the season by constructing a "perfect round" from a player's best scores on each individual hole.

**Birdie Tree**
A specialized leaderboard tracking achievement-style metrics like total Birdies, Eagles, and Albatrosses over the course of a season.

**Best of Series**
A leaderboard format that calculates a player's total based on their best $N$ scores of the season (e.g., Best 8 of 11).

**Podium View**
A high-fidelity UI component featuring visual podiums (Gold, Silver, Bronze) for the top 3 players in any seasonal competition.

## 11. Event Financials

**Club Bill**
The total automated cost owed by the society to the golf club venue. It is calculated dynamically based on confirmed registrations (Green Fees) and confirmed meal choices (Catering). This appears as a single, immutable line item in the event ledger to prevent manual entry errors.

**Miscellaneous Expenses**
Manual expense entries (e.g., "Engraving", "Taxis") added by an admin via the **Cost Control** screen. These are subtracted from the total revenue to calculate the net financial position.

**Indicative Costs**
Costs that are tracked for member information but do not impact the society treasury. For example, **Buggy Cost** is an indicative cost usually paid directly by the member to the Pro Shop.

**Control Tower**
The central administrative hub for an event. It consolidates all management functions—including grouping, registrations, costs, awards, and **Event Comms**—into a single, card-based interface.

## 13. Membership Tiers

**Full Member** (`MemberRole.member`)
Standard golf society membership. Full access to register for golf events, enter scores, and view all content.

**Social Member** (`MemberRole.socialMember`)
A reduced membership tier for people who want to be part of the society socially but do not play golf. Social members can view all events, scores, and leaderboards, and register for social (non-golf) events. They cannot register for golf events and the My Card scoring tab is hidden. Enabled per-society via `SocietyConfig.enableSocialMembership`. Social members pay `socialMemberFee` at renewal instead of the full membership fee. Admins can promote a social member to full membership in the member profile.

**Social Membership Toggle**
A society-level configuration flag (`enableSocialMembership`) in the Society Configuration section of Operations. When off, no new social members can be created, but existing social members retain their restricted access for historical seasons.

**Season Financials**
A rolling P&L view across all season events accessible from Operations → Finance & Analytics. Shows actual net position (collected revenue minus costs) and projected net position (actual + outstanding unpaid fees). Per-event breakdown shows each event's net and any outstanding fees.

## 12. Financial Concepts

**Account Credit**
A member's positive balance within the society treasury. It can be used to offset future event entry fees or withdrawn as a cash payout.

**Voucher Credit**
A specialized form of Account Credit often awarded for competition wins. In the app, this is synonymous with a positive `accountCredit` balance.

**Debt Settlement**
The process of reconciling outstanding event fees and fines against a member's available credit. Accessible via the **Admin Central Debt Ledger**.
