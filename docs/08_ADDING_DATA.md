# Adding Data

The application now features a fully functional **Admin Console**, so you no longer need to add data manually in the Firebase Console.

## 1. Accessing Admin Console
1.  Open the app.
2.  Navigate to the **Admin** tab.
3.  You will see dashboards for **Events**, **Members**, and **Communications**.

## 2. Managing Members
You can now add members directly from the app, including **Profile Pictures**:
1.  Go to **Admin > Members**.
2.  Tap the **Add Member** button (top right).
3.  Fill in the details (Name, Email, Handicap, etc.).
4.  **Upload Photo**: Tap the camera icon to pick an image from your gallery.
5.  Tap **Save Member**.
    - *Note*: This automatically handles Firestore creation & Image Storage.

## 3. Managing Events
1.  Go to **Admin > Events**.
2.  Tap **Create Event**.
3.  Enter Title, Location, Date, and Description.
4.  Tap **Save Event**.

---

## Fallback: Manual Firestore Entry
*Only use this if the Admin Console is unavailable.*

### Events Collection
- **Collection ID**: `events`
- **Fields**:
  - `title` (string)
  - `location` (string)
  - `date` (timestamp)
  - `description` (string)
