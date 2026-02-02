# Adding Data

The application now features a fully functional **Admin Console**, so you no longer need to add data manually in the Firebase Console.

## 1. Accessing Admin Console
1.  Open the app.
2.  Navigate to the **Admin** tab.
3.  You will see dashboards for **Events**, **Members**, and **Communications**.

## 2. Managing Members
You can now manage members via the **Member List**, including **Profile Pictures**, **Roles**, and **Payment Status**:
1.  Go to **Admin > Members**.
2.  **Add Member**: Tap the **+** (plus) icon.
3.  **Edit Member**: Tap any member to see their details, then tap the **Edit** (pencil) icon.
4.  **Smarter Inputs**: 
    - **Country Code**: Searchable autocomplete with **Flag Emojis** for easy identification.
    - **Date Picker**: Standardized pill-style date entry for membership start dates.
    - **Society Roles**: Picker-based selection for committee positions (President, Captain, etc.).
5.  **Photo Upload**: Tap the camera icon on the profile card to pick an image from your gallery.
6.  **Quick Toggles**: Tap the **Status** (Active/Inactive) or **Fee** (Due/Paid) badges directly from the list to update without opening the full profile.

## 3. Managing Events
1.  Go to **Admin > Events**.
2.  Tap **Create Event**.
3.  Enter **Title**, **Course Name**, **Course Details**, **Date**, and **Description**.
4. Tap **Save Event**.

## 4. Managing Registrations
From the **Admin > Events** dashboard, tap **Registrations** on any event to manage participants:
1.  **Status Toggles**: Tap a status badge (e.g., `CONFIRMED`) to cycle through manual overrides.
2.  **Buggy Toggles**: Tap the buggy icon to manually assign/waitlist buggy requests.
3.  **History**: Scroll to the bottom of a participant's details to view their registration history (audit trail).
4.  **Groupings**: Tap **Groupings** to auto-generate and publish tee sheets.

---

## Fallback: Manual Firestore Entry
*Only use this if the Admin Console is unavailable.*

### Events Collection
- **Collection ID**: `events`
- **Fields**:
  - `title` (string)
  - `courseName` (string)
  - `courseDetails` (string)
  - `date` (timestamp)
  - `description` (string)
  - `buggyCost` (number)
  - `availableBuggies` (number)
  - `maxParticipants` (number)
  - `showRegistrationButton` (boolean)
