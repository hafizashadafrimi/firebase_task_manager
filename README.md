# Firebase Task Manager

Flutter + Firebase assignment app: authentication, Firestore task CRUD, FCM push notifications, and local notifications (including foreground handling).

UI follows the provided Flutter Firebase Figma screens.

## Features

- Email/password sign up and sign in
- Google Sign-In
- Password reset
- Firestore task CRUD (title, description, due date, priority, completed, created date)
- Task list with search and All / Pending / Completed filters
- Delete confirmation sheet
- FCM token saved on `users/{uid}`
- Foreground FCM → local notification (`flutter_local_notifications`)
- Background / terminated FCM shown by Firebase
- Notification tap opens the related task when `taskId` is in the payload
- Priority-colored notifications (high / medium / low)

## Package name

- Android: `com.assignment.firebase_task_manager`
- iOS bundle id: `com.assignment.firebaseTaskManager`

## 1. Firebase setup

1. Create a Firebase project.
2. Enable **Authentication** → Email/Password and Google.
3. Create a **Cloud Firestore** database (start in test mode, then paste `firestore.rules`).
4. Enable **Cloud Messaging**.
5. Add an Android app with package `com.assignment.firebase_task_manager`.
6. Add the debug SHA-1 (required for Google Sign-In):

```bash
cd android
./gradlew signingReport
```

On Windows PowerShell:

```powershell
cd android
.\gradlew signingReport
```

Copy the `SHA1` under `Variant: debug` into Firebase → Project settings → your Android app.

7. Generate FlutterFire files from the project root:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This replaces `lib/firebase_options.dart`, `android/app/google-services.json`, and (for iOS) `ios/Runner/GoogleService-Info.plist`.

8. In Firestore, publish the rules from `firestore.rules`.

9. Run:

```bash
flutter pub get
flutter run
```

Until `flutterfire configure` is run, the app shows a **Connect Firebase** setup screen.

## 2. Authentication

Login includes email, password, Sign In, Continue with Google, and Sign Up.

Google Sign-In needs:

- Google provider enabled in Firebase Auth
- SHA-1 on the Android app
- Matching `google-services.json` from FlutterFire

## 3. Task data

Tasks live at:

```
users/{uid}/tasks/{taskId}
```

Fields: `title`, `description`, `dueDate`, `priority`, `completed`, `createdAt`, `course`.

The user's FCM token is stored at `users/{uid}.fcmToken`.

## 4. Push + local notifications

### Foreground

FCM does **not** show a system banner while the app is open. The app:

1. Receives `FirebaseMessaging.onMessage`
2. Reads title / body / `taskId` / `priority`
3. Shows a **local notification** with `flutter_local_notifications`

Creating a task also shows a local notification:

- Title: `New Task`
- Body: `You have a new task: {title}`

### Background

Send a message that includes a `notification` block. Android/iOS display it automatically.

### Terminated

`getInitialMessage()` (FCM) and local-notification launch details open the matching task.

### Test from Firebase Console

1. Run the app, sign in, then **Copy FCM token** from the task-list menu (or read `users/{uid}.fcmToken` in Firestore).
2. Firebase Console → **Messaging** → **New campaign** → **Firebase Notification messages**.
3. Use:

- Title: `New Task`
- Text: `You have a new task: Complete Flutter Assignment`
- Additional custom data:
  - `taskId` = a real task document id
  - `priority` = `high` | `medium` | `low`

4. Test:

- App open → local notification appears
- App in background → system notification from FCM
- App killed → tap notification → task list / that task

## 5. Notification click

Payload `taskId` is passed as the local notification payload. Tapping it opens **Edit Task** for that document. If the id is missing, the task list opens.

## Project structure

```
lib/
  main.dart
  firebase_options.dart
  core/
  models/
  services/
  screens/
  widgets/
```
