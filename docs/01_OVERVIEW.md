# Project Overview

**Golf Society Management** is a modern Flutter application designed to manage golf societies, events, members, and handicaps. It features a premium "BoxyArt" design system with high-contrast aesthetics and fluid interactions.

## Core Features
1. **Member Dashboard**: Personalized view with dynamic notifications, "Next Match" details, and quick actions.
2. **Society Reporting Hub**: Comprehensive reporting engine for finances, member engagement, and competition analytics.
3. **Communications Hub (Admin)**: A sophisticated broadcasting system with custom distribution lists and targeting.
4. **Events Hub**: Comprehensive listing of Upcoming and Past events, with registration capabilities.
5. **Members Directory**: Searchable list of all society members with live filtering and photo uploads.
6. **Locker Room**: User profile management (Bio, Photo), handicap tracking, and statistics.
7. **Season Standings**: Advanced leaderboards (OoM, Birdie Tree, Eclectic) with industry-standard point systems.
8. **Demo Seeding (Admin)**: A sophisticated system for populating historical data across development and testing environments.

-   **Typography**: Inter (Body, Labels), Fredoka (Display)

## Code Health & Standards
-   **Zero Error State**: The project adheres to a strict "Zero Warning/Error" policy for `flutter analyze`. 
-   **Architecture**: Follows a Clean Architecture pattern with distinct `domain`, `features`, and `design_system` layers.
-   **Async Safety**: Standardized use of `mounted` guards across all asynchronous operations.
-   **Universal Parity**: 1:1 visual alignment between Admin and Member scoring components.

## Detailed Documentation
For deep dives into specific system logic, see:
-   [Architecture Registry](file:///Users/sanjaypatel/Documents/Projects/Golf%20Society%20Management/docs/04_ARCHITECTURE.md)
-   [Registration Logic](file:///Users/sanjaypatel/Documents/Projects/Golf%20Society%20Management/docs/10_REGISTRATION_LOGIC.md)
-   [Grouping & Tee Sheets](file:///Users/sanjaypatel/Documents/Projects/Golf%20Society%20Management/docs/11_GROUPING_LOGIC.md)
-   [Games & Competitions](file:///Users/sanjaypatel/Documents/Projects/Golf%20Society%20Management/docs/13_GAMES_AND_COMPETITIONS.md)
-   [Demo Data & Seeding](file:///Users/sanjaypatel/Documents/Projects/Golf%20Society%20Management/docs/14_DEMO_DATA_AND_SEEDING.md)

## Visual Identity ("BoxyArt True Minimal")
The app uses a centralized design system called **BoxyArt**:
-   **Primary Color**: Configurable seed color (e.g., Mustard Yellow `#F7D354`, Navy, Indigo).
-   **Secondary Color**: Solid Black (`#000000`)
-   **True Minimal Legend**: Minimalist dot + text indicators (No background pills).
-   **Universal Title Case**: 100% adherence to Title Case for all labels and headers.
-   **Shapes**: High border radius (`16px` for cards, `AppShapes.rLg`).
-   **Shadows**: Custom "Soft Scale" and "Floating Alt" shadows (no default elevation).
