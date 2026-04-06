# Social Events & Society Surveys

The Golf Society Management system supports both golf and non-golf events, along with a sophisticated feedback engine comprising quick polls and multi-question surveys.

## Society Polls & Surveys

As of the March 2026 Architectural Update, Polls and Surveys have been elevated from event-specific items to **Global Society Features**.

### Global Aggregation
- **Member Home Screen**: Active polls and surveys are aggregated in a dedicated "Member Surveys" section. These cards have been refactored to the **Design 4.x "Branded" layout** (Identity | Content | Action), utilizing `BoxyArtCard`, `BoxyArtSquareBadge` (for identifying icons), and premium `BoxyArtPill` status indicators.
- **Admin Dashboard**: Administrators can monitor and manage all active surveys from the main Admin Console dashboard, sharing consistent 4.x card aesthetics.

### Implementation Patterns
Polls are defined within `EventFeedItem` models with `FeedItemType.poll`. While created in the context of an event (for scoping), they are surfaced globally to maximize engagement and visibility.

1. **MemberHome**: Uses `activeSurveysProvider` to fetch and display polls.
2. **AdminDashboard**: Surfaces a summary of active surveys for quick oversight.
3. **Event Hub**: Polls are filtered *out* of event-specific dashboards to prevent redundancy, promoting a centralized communication strategy.

## Social Events
Events are no longer restricted to golf competitions. Admins can create "Social" events (covering AGMs, get-togethers, dinners, etc.).
- **Dynamic Interface**: Social events automatically hide golf-specific fields (Tee Times, Course Selection, Prizes).
- **Consolidated Pricing**: Social events use a single "Event Cost" field, simplifying the fee structure for non-golf gatherings.
- **Registration Only**: The "Groups" and "Scores" tabs are hidden for social events, focusing the organizer on registration and communications.

## Interactive Polls (Event Room)
Admins can broadcast instant polls directly to the event feed.
- **Real-time Results**: Members can vote directly on their feed and see live percentage breakdowns with progress bars.
- **BoxyArt Aesthetics**: High-contrast branded visualization for all poll choices.

## Society Surveys (Communications)
A comprehensive survey system is available in the Communications Admin section, modernized for the Design 4.x "Admin Hub" aesthetic.
- **Survey Manager**: Centralized hub to list, edit, and publish society-wide questionnaires.
- **WYSIWYG Editor**: Question prompts now support full rich text (bold, italics, links, lists) powered by `BoxyArtRichEditor`.
- **Drag-and-Drop Reordering**: Admins can reorder both questions and options using tactile drag handles (⋮⋮).
- **Multi-Question Form**: Supports single-choice, multiple-choice, and open-ended text questions with premium segmented type selectors.
- **Visibility Controls**: Detailed "Draft" vs. "Live" states for managing survey lifecycles.
- **Dynamic Labeling**: Option numbering automatically updates during reordering to maintain a clean structure.
- **Survey Seeding (Demo)**: The system includes a comprehensive seeding engine that generates multi-question surveys with realistic member response distributions (50-60% participation) to verify reporting and visualization logic.

### Member Experience (Survey Details)
- **Design 4.x Detail Screen**: The `SurveyDetailScreen` has been fully refactored to follow the Design 4.x token system and "Branded" layout standards.
- **Branded Header**: Uses the 3-column "Branded" layout (Identity | Content | Action) with a 72px identity zone and `BoxyArtSquareBadge`.
- **Token-Driven Selection**: Interactive question cards utilize `primaryColor` tokens for selection states (8% background tint, 1.5px borders).
- **Responsive Typography**: Standardized using `AppTypography.displayHeading` and `AppTypography.bodySmall` for maximum legibility across devices.
- **Syntax & Spacing**: All padding, margin, and color token references have been audited and corrected to ensure strict adherence to the 4.x design system.

## Technical Details
- **Models**: `Survey`, `SurveyQuestion` (now stores question prompts as Quill Delta JSON), and expanded `EventFeedItem` with `pollData`.
- **State Management**: `SurveysNotifier` (Riverpod) for predictable lifecycle handling.
- **Design Standard**: BoxyArt 4.0 "Admin Hub".
- **Tactile Option Management**: `SurveyEditorScreen` implements a stable secondary state map (`_optionIds`) to manage unique identifiers for each option. This prevents widget reconciliation issues when deleting or reordering items in nested `ReorderableListView` components.
