# Social Events & Society Surveys

The Golf Society Management system supports both golf and non-golf events, along with a sophisticated feedback engine comprising quick polls and multi-question surveys.

## Society Polls & Surveys

As of the March 2026 Architectural Update, Polls and Surveys have been elevated from event-specific items to **Global Society Features**.

### Global Aggregation
- **Member Home Screen**: Active polls from all upcoming events are now aggregated in a dedicated "Society Polls" section immediately upon app launch.
- **Admin Dashboard**: Administrators can now monitor and manage all active surveys across all events from the main Admin Console dashboard.

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

## Technical Details
- **Models**: `Survey`, `SurveyQuestion` (now stores question prompts as Quill Delta JSON), and expanded `EventFeedItem` with `pollData`.
- **State Management**: `SurveysNotifier` (Riverpod) for predictable lifecycle handling.
- **Design Standard**: BoxyArt 4.0 "Admin Hub".
