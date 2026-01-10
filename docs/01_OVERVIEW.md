# Project Overview

**Golf Society Management** is a modern Flutter application designed to manage golf societies, events, members, and handicaps. It features a premium "BoxyArt" design system with high-contrast aesthetics and fluid interactions.

## Core Features
1.  **Member Dashboard**: Personalized view with "Next Match" details and quick actions.
2.  **Events Hub**: Comprehensive listing of Upcoming and Past events, with registration capabilities.
3.  **Members Directory**: Searchable list of all society members with live filtering.
4.  **Locker Room**: User profile management, handicap tracking, and statistics.
5.  **Archive**: Historical data of past seasons and major winners.

## Technology Stack
-   **Framework**: Flutter (Dart)
-   **State Management**: Riverpod (riverpod_generator, annotations)
-   **Navigation**: go_router (StatefulShellRoute for persistent bottom nav)
-   **Backend**: Firebase (Firestore, Auth, Functions) - *Integration in progress*
-   **Typography**: Google Fonts (Poppins)

## visual Identity ("BoxyArt")
The app uses a strict design system called **BoxyArt**:
-   **Primary Color**: Mustard Yellow (`#F7D354`)
-   **Secondary Color**: Solid Black (`#000000`)
-   **Shapes**: High border radius (`30px` for cards, `100px` stadium for buttons).
-   **Shadows**: Custom "Soft Scale" and "Floating Alt" shadows (no default elevation).
