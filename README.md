# Usapho Dashboard

This is the board-facing Flutter web dashboard for Usapho Foundation. It uses:

- Flutter Web
- Firebase Authentication
- Cloud Firestore
- Firebase Hosting

## Free Board Link

Use Firebase Hosting's free default URL:

- `https://usapho-dashboard.web.app`
- or `https://usapho-dashboard.firebaseapp.com`

No paid custom domain is required.

## What Is Included

- Executive dashboard with KPI cards, alerts, filters, and charts
- `Entries` tab for editing and deleting records
- Data-entry dialog for:
  - funding opportunities
  - partnerships
  - programs
  - campaigns
  - financials
- Email/password login plus self-service sign-up
- Firestore profile records in `users/{uid}`
- Starter Firestore security rules for authenticated users

## Local Run

```bash
flutter pub get
flutter run -d chrome
```

## Firebase Console Setup

### 1. Enable Authentication

In Firebase Console:

1. Go to `Authentication`
2. Click `Get started`
3. Enable `Email/Password`

### 2. Create Board Users

In Firebase Console:

1. Go to `Authentication`
2. Add users for board/admin members

### 3. Assign Roles In Firestore

Create a `users` collection with one document per authenticated user:

- document id = the Firebase Auth user UID

Example:

```json
{
  "email": "boardmember@example.org",
  "role": "board",
  "displayName": "Board Member"
}
```

Allowed roles:

- `admin`
- `board`
- `staff`
- `viewer`

Recommended:

- admins: administrative use
- board: board access
- staff: operational team access
- viewer: optional read-only role if you later tighten rules again

## Firestore Collections

This app expects:

- `funding_opportunities`
- `partnerships`
- `programs`
- `campaigns`
- `financials`
- `users`

## Deploy To Free Firebase Link

Install the Firebase CLI if needed:

```bash
npm install -g firebase-tools
```

Login:

```bash
firebase login
```

Build the app:

```bash
flutter build web --release
```

Deploy hosting and Firestore rules:

```bash
firebase deploy --only hosting,firestore:rules,firestore:indexes
```

After deploy, Firebase will print the live URL.

## Security Notes

- The login page is in the app and uses Firebase Authentication
- Firestore rules are in [firestore.rules](/C:/FlutterProjects/usapho_dashboard/firestore.rules)
- Only signed-in users can access the dashboard data in the current rules setup

## Files Added For Hosting And Security

- [.firebaserc](/C:/FlutterProjects/usapho_dashboard/.firebaserc)
- [firebase.json](/C:/FlutterProjects/usapho_dashboard/firebase.json)
- [firestore.rules](/C:/FlutterProjects/usapho_dashboard/firestore.rules)
- [firestore.indexes.json](/C:/FlutterProjects/usapho_dashboard/firestore.indexes.json)

## Recommended Next Step

After the first deploy, sign in with an admin account and start entering real board data. If needed, the next improvement should be password reset support and a lightweight user management screen for admins.
