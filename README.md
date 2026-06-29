# Breakout Room Activity — Firestore Todo App

A cross-platform Flutter todo list backed by **Cloud Firestore**. Built as a breakout-room activity to practice real-time data sync, CRUD operations, and Firebase integration.

## Features

- Add, edit, delete, and toggle todos
- Real-time list updates via Firestore snapshots
- Clear all completed todos in one action
- Works on Android, iOS, Web, macOS, Windows, and Linux

## Tech Stack

| Layer | Technology |
|-------|------------|
| UI | Flutter (Material Design) |
| Backend | Cloud Firestore |
| Auth / config | Firebase Core (FlutterFire) |

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.11)
- A [Firebase](https://console.firebase.google.com/) project with Firestore enabled
- FlutterFire CLI (optional, for regenerating config):

  ```bash
  dart pub global activate flutterfire_cli
  ```

## Getting Started

### 1. Clone and install dependencies

```bash
git clone <repository-url>
cd breakout-room-activity
flutter pub get
```

### 2. Firebase setup

Firebase config files are **not committed** (they contain API keys). Generate them locally:

1. Create a Firebase project and enable **Cloud Firestore**.
2. Install and log in to FlutterFire CLI:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   This creates `lib/firebase_options.dart` and platform `google-services` / `GoogleService-Info` files.

3. Deploy Firestore rules:

   ```bash
   firebase deploy --only firestore:rules
   ```

   Example templates (placeholders only) are in `*.example` files if you prefer manual setup.

### 3. Firestore index

The app orders todos by `timestamp`. Firestore may prompt you to create a composite index on first run — follow the link in the error message, or add this in the Firebase console:

- Collection: `todos`
- Fields: `timestamp` (Descending)

### 4. Run the app

```bash
# List available devices
flutter devices

# Run on a connected device or emulator
flutter run

# Web
flutter run -d chrome
```

## Firestore Data Model

Documents live in the `todos` collection:

| Field | Type | Description |
|-------|------|-------------|
| `task` | `string` | Todo text |
| `completed` | `boolean` | Completion status |
| `timestamp` | `timestamp` | Created at (server time) |
| `updatedAt` | `timestamp` | Last modified (optional) |

## Project Structure

```
lib/
├── main.dart                 # App entry + Firebase init
├── firebase_options.dart     # Generated platform Firebase config
├── screens/
│   └── todo_screens.dart     # TodoList UI (StreamBuilder + CRUD)
└── services/
    └── todo_service.dart     # Firestore CRUD helpers

firestore.rules               # Security rules (see note below)
firebase.json                 # Firebase project config
```

## API Keys & Secrets

Firebase client API keys were removed from this repo after a secret-scanning alert. **If keys were ever pushed, rotate them** in [Google Cloud Console](https://console.cloud.google.com/apis/credentials) → select each key → **Regenerate key**.

Also restrict keys by platform (Android package name, iOS bundle ID, HTTP referrers for web) so leaked keys cannot be abused from other apps.

Old keys remain in git history until you rewrite history or rotate them — rotation is the recommended fix.

## Security Rules

Current rules allow open read/write for development:

```javascript
match /todos/{todoId} {
  allow read, write: if true;
}
```

**Do not use these rules in production.** Before shipping, restrict access — for example with Firebase Authentication:

```javascript
match /todos/{todoId} {
  allow read, write: if request.auth != null;
}
```

## Testing

```bash
flutter test
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `FirebaseException: permission-denied` | Deploy `firestore.rules` or check rules in Firebase console |
| Missing index error | Create the `timestamp` index (link appears in console/logs) |
| `DefaultFirebaseOptions` not found | Run `flutterfire configure` |
| Build fails after clone | Run `flutter pub get` and `flutter clean` |

## License

This project is for educational use as part of a breakout room activity.
