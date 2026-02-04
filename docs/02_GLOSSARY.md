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
World Handicap System index. A measure of a golfer's potential ability. The app tracks this in the **Locker Room**.

**Tee-off Time**
The scheduled start time for a match or specific flight.

## App Mechanics (BoxyArt System)

**BoxyArt Theme**
The custom visual language of the app. Characterized by:
-   **Dynamic Branding**: Configurable primary color (default: Mustard Yellow) with automatic contrast calculation.
-   **Soft Shadows**: Custom shadows (`softScale`) that create a floating effect on cards.
-   **Rounded Shapes**: Cards use `BorderRadius.circular(25-30)`, inputs and buttons use `BorderRadius.circular(12)`.
-   **Semantic Status Colors**: Consistent color palette for status indicators (Positive/Green, Warning/Orange, Negative/Red, Neutral/Grey).
-   **Accessibility**: Automatic text color calculation ensures readability on any background.

**Locker Room**
The creative name for the **User Profile** section. Here, users can:
-   View their current Handicap Index.
-   Check their Win/Loss statistics.
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

**Status Pill**
A small, pill-shaped indicator used throughout the app to show status (e.g., "Active", "Paid", "Due"). Uses semantic colors from `StatusColors` and automatically adapts to light/dark mode. Also known as `BoxyArtStatusPill`.

**Notification Badge**
A small yellow circle indicating unread items (e.g., messages, new events).

**Storage Service**
The system responsible for securely handling file uploads, such as profile photos, to Firebase Storage. Enforces strict validation rules (e.g., 5MB file size limit).

**Avatar**
The user's profile photo, displayed in the Header Card and Member lists. Managed via the **Locker Room** or Admin Form.

**Communications Hub**
The administrative center for society messaging. It allows admins to compose notifications and manage audience distribution lists.

**Distribution List**
A custom group of members (e.g., "Spain Trip 2026", "New Joiners") saved by an admin for targeted messaging within the Communications Hub.

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
The method used to resolve tied scores by looking at the best performance over the final 9, 6, 3, or 1 holes.

**Gross Stableford**
A variation of Stableford scoring where points are awarded based on the raw score without any handicap adjustment.
