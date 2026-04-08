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

## Society Surveys (**Communications Hub**)
The administrative center for society messaging. It allows admins to compose notifications (broadcasts), manage audience distribution lists, and target specific events using the **Event Picker**.

**Event Comms**
The rebranded term for the event-specific feed management. It allows admins to reorder and pin posts (notes, reports, etc.) within an event's dedicated feed.

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

## Event Comms & News Reports

The Event Dashboard includes a dynamic news feed for broadcasting updates, notes, and reports. 

### Hub-Based Creation
As of April 2026, creating news items and flash updates has been consolidated into the global **Communications Hub**.
1. **Navigate**: Go to the Communications Hub (Admin Home or Event Control Tower -> Event Comms -> Create).
2. **Context**: Use the **Event Picker** to associate the post with a specific event.
3. **Drafting**: Compose the message using rich text or simple text.
4. **Publishing**: Once sent, the item is automatically appended to the Event's Feed and sent as a push notification to members.

### Deep-Linking & Routing
The feed supports robust deep-linking to ensure that shared links to specific news items always resolve correctly across all platforms (iOS/Android).

- **Member Route**: `/events/:id/feed/:itemId`
- **Admin Route**: `/admin/events/manage/:id/comms/:itemId`

### EventCommsScreen (Management)
The `EventCommsScreen` (formerly Broadcast/CMS) provides an interface for administrators to reorder, pin, or delete existing feed items for a specific event.

## Technical Details
- **Models**: `Survey`, `SurveyQuestion` (now stores question prompts as Quill Delta JSON), and expanded `EventFeedItem` with `pollData`.
- **State Management**: `SurveysNotifier` (Riverpod) for predictable lifecycle handling.
- **Design Standard**: BoxyArt v4.1 "True Minimal" (April 2026).
- **Tactile Option Management**: `SurveyEditorScreen` implements a stable secondary state map (`_optionIds`) to manage unique identifiers for each option. This prevents widget reconciliation issues when deleting or reordering items in nested `ReorderableListView` components.
