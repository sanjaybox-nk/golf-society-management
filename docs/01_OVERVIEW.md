# Project Overview

**Golf Society Management** is a modern Flutter application designed to manage golf societies, events, members, and handicaps. It features a premium "BoxyArt" design system with high-contrast aesthetics and fluid interactions.

## Core Features
6.  **Member Dashboard**: Personalized view with dynamic notifications, "Next Match" details, and quick actions.
7.  **Communications Hub (Admin)**: A sophisticated broadcasting system with custom distribution lists and targeting.
8.  **Events Hub**: Comprehensive listing of Upcoming and Past events, with registration capabilities.
9.  **Members Directory**: Searchable list of all society members with live filtering and photo uploads.
10. **Locker Room**: User profile management (Bio, Photo), handicap tracking, and statistics.
11. **Archive**: Historical data of past seasons and major winners.
12. **Season Standings**: Advanced leaderboards (OoM, Birdie Tree, Eclectic) with industry-standard point systems.
13. **Testing Lab (Admin)**: A sophisticated sandbox for seeding historical data and verifying scoring logic across development phases.

## Technology Stack
-   **Framework**: Flutter (Dart)
-   **State Management**: Riverpod (riverpod_generator, annotations)
-   **Navigation**: go_router (StatefulShellRoute for persistent bottom nav)
-   **Backend**: Firebase (Firestore, Auth, Functions) - *Integration in progress*
-   **Typography**: Google Fonts (Poppins)

## Detailed Documentation
For deep dives into specific system logic, see:
-   [Registration Logic](file:///Users/sanjaypatel/Documents/Projects/Golf%20Society%20Management/docs/10_REGISTRATION_LOGIC.md)
-   [Grouping & Tee Sheets](file:///Users/sanjaypatel/Documents/Projects/Golf%20Society%20Management/docs/11_GROUPING_LOGIC.md)
-   [Games & Competitions](file:///Users/sanjaypatel/Documents/Projects/Golf%20Society%20Management/docs/13_GAMES_AND_COMPETITIONS.md)
-   [Testing Lab & Seeding](file:///Users/sanjaypatel/Documents/Projects/Golf%20Society%20Management/docs/14_TESTING_LAB_AND_SEEDING.md)

## Visual Identity ("BoxyArt")
The app uses a strict design system called **BoxyArt**:
-   **Primary Color**: Configurable seed color (e.g., Mustard Yellow `#F7D354`, Navy, Indigo).
-   **Secondary Color**: Solid Black (`#000000`)
-   **Shapes**: High border radius (`30px` for cards, `100px` stadium for buttons).
-   **Shadows**: Custom "Soft Scale" and "Floating Alt" shadows (no default elevation).
