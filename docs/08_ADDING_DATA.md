# Adding Golf Events to Firestore

Since we don't have an "Admin App" yet, you will add events directly in the Firebase Console.

## Steps
1.  Go to **Firebase Console** -> **Build** -> **Firestore Database**.
2.  Click **Start collection**.
3.  **Collection ID**: `events` (Lower case).
4.  Click **Next**.
5.  **Document ID**: Click **Auto-ID**.
6.  **Fields** (Add these carefully):

| Field | Type | Value Example |
| :--- | :--- | :--- |
| **title** | string | `Spring Championship` |
| **location** | string | `Royal Pines` |
| **description** | string | `18 Holes Stroke Play` |
| **date** | timestamp | *Pick a date/time* |
| **teeOffTime** | timestamp | *Pick a date/time* |

7.  Click **Save**.

## Repeat
Add 2-3 events (some in future, some in past) to test the app.
The app will automatically update (Real-time!) when you click Save.
