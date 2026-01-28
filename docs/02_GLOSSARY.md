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

**Floating Bottom Search**
A specialized search bar found in the **Members Directory**. Instead of sitting at the top, it "floats" at the bottom of the screen for easier thumb reach. It contains:
-   **Search**: Triggers text input.
-   **Filter**: Opens advanced filtering options.

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

**FCFS (First-Come, First-Served)**
The core priority system. Event spots and budget buggy spaces are allocated strictly based on the `registeredAt` timestamp.

**Buggy Allocation**
Automatically calculated based on the available buggy count defined by the admin. The system assigns "Confirmed" buggy status to the first N players who requested one, moving others to the "Waitlist" buggy status.

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
