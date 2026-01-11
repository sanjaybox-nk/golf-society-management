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
-   **Mustard Yellow & Black**: High contrast branding.
-   **Soft Shadows**: Custom shadows (`softScale`) that create a floating effect on white cards.
-   **Pill Shapes**: All inputs and buttons are fully rounded (Stadium border).

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

**Status Chip**
A small, pill-shaped indicator used on Event Cards to show status (e.g., "Register", "Full", "Completed"). In the BoxyArt theme, these are typically Black with White text.

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

**Registration**
1.  Navigate to **Events**.
2.  Tap on an **Upcoming Event** card.
3.  Tap the **Register** chip (Black pill).
4.  (Future) Pay entry fee via Stripe integration.

**Member Search**
1.  Go to **Members**.
2.  Tap the floating **Search** button at the bottom.
3.  Type a name. The list filters in real-time.
