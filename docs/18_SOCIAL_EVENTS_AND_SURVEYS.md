# Social Events & Society Surveys

The Golf Society Management system supports both golf and non-golf events, along with a sophisticated feedback engine comprising quick polls and multi-question surveys.

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
A comprehensive survey system is available in the Communications Admin section.
- **Survey Manager**: Centralized hub to list, edit, and publish society-wide questionnaires.
- **Multi-Question Form**: Supports single-choice, multiple-choice, and open-ended text questions.
- **Visibility Controls**: Detailed "Draft" vs. "Live" states for managing survey lifecycles.

## Technical Details
- **Models**: `Survey`, `SurveyQuestion`, and expanded `EventFeedItem` with `pollData`.
- **State Management**: `SurveysNotifier` (Riverpod) for predictable lifecycle handling.
- **Design Standard**: BoxyArt 3.1.
