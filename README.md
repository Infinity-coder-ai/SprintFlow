gi# SprintFlow

**Agile project management, built around how real teams work.**

SprintFlow is a Flutter + Firebase app for running projects with three clear roles: **managers** who plan and track, **employees** who execute and log progress, and **clients** who follow along. Everyone signs in to the same app and lands on a workspace built for their job — dark themed, realtime, and structured to stay maintainable as it grows.

---

## What it does

### Manager workspace
- Dashboard with live stats, overall-progress ring, task-status donut, team weekly-hours chart, and recent projects
- Create projects with a client, start/end dates
- Invite registered employees to a project (search + pick, no typing blind emails)
- Create tasks and assign them to joined employees only
- Full task board with status filters, task details, and status updates
- Post updates to clients (clients get notified)
- Team, clients, invitations, updates, and notifications screens

### Employee workspace
- Dashboard with greeting, task stats, today's tasks by deadline, completion ring, and a weekly productivity bar chart
- My projects (assigned + accepted invitations, kept in sync live)
- My tasks with search and status filters, task details
- Update task progress with a slider, hours, and a message — project stats recalculate automatically
- Accept / reject project invitations
- Personal work-update history and notifications

### Client workspace
- Dashboard with project stats, overall progress ring, recent projects, and latest manager updates
- Project details with live progress, task progress view, team size, and per-project updates
- Full updates feed and notifications

### Auth
- Email/password sign-in and self-registration for all three roles
- **Email verification gate**: every new account must verify its inbox link before reaching any dashboard — no stale or mistyped address can enter the database (`users` record is created only after verification; the signup waits in `pending_users`)
- Duplicate-address retries recover gracefully (sign in with the same password instead of dead-ending)

---

## Tech stack

| Layer        | Choice                                      |
| ------------ | ------------------------------------------- |
| UI           | Flutter (Material 3, custom dark theme)     |
| Charts       | fl_chart                                    |
| State        | Provider (`AuthProvider` + per-screen state)|
| Backend      | Firebase Auth, Cloud Firestore              |
| Rules/indexes| `firestore.rules`, `firestore.indexes.json`|
| Launcher icon| `flutter_launcher_icons` (generated rocket) |

---

## Project structure

The codebase is split into small modules (no file is over ~220 lines) in three clean layers:

```
lib/
├── main.dart                  # App entry + role-based routing (AuthWrapper)
├── ui/                        # Presentation layer (one folder per role)
│   ├── auth/                  # Login, sign-ups, forgot + verify screens, forms, widgets/
│   ├── manager/               # Dashboard, projects, tasks, team, invites, updates…
│   ├── employee/              # Dashboard, tasks, progress, invitations…
│   ├── client/                # Dashboard, projects, updates…
│   └── splash_screen.dart
├── business_logic/            # App state + use cases
│   └── providers/auth_provider (+ registration/management/verification parts)
├── database/                  # Data layer (Firestore only, no UI imports)
│   ├── models/                # Entities (+ serialization/helper parts)
│   └── services/              # Auth, users, projects, tasks, invitations, updates
├── core/                      # Shared foundation
│   ├── constants/  theme/     # (feature widgets live with their feature)
└── test/                      # Launcher-icon generator test
```

Rules of thumb the code follows: screens stay thin (state + layout), reusable pieces live in `*_widgets` / `*_tiles` / `*_forms` modules, business rules live in `*_logic` modules, and every Firestore touch goes through `database/services`.

---

## Getting started

### Prerequisites
- Flutter SDK (3.x) with Dart
- An Android device/emulator (or Chrome for a quick look)
- A Firebase project with **Email/Password sign-in enabled**

### 1. Clone and install
```bash
git clone <your-repo-url>
cd SprintFlow
flutter pub get
```

### 2. Connect Firebase (Android)
1. In the Firebase console, add an Android app with package name `com.example.sprint_flow` (or update `android/app/build.gradle.kts` to match yours).
2. Download `google-services.json` into `android/app/`.
3. Deploy the security rules and indexes:
```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

> Email verification and password-reset emails use Firebase's built-in templates — no extra setup. If reset/verification mails don't arrive, check spam and console → Authentication → Templates.

### 3. Run
```bash
flutter run
```

### 4. Build a release/debug APK
```bash
flutter build apk --debug
# output: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Key flows worth knowing

- **Invite flow** — manager picks a project + a registered employee → employee gets an in-app invitation + notification → accept adds them to the project on both sides.
- **Work updates** — employee posts progress + hours → task status, hours, and project aggregates update everywhere automatically.
- **Verification flow** — signup stores the profile in `pending_users` (owner-only rules) → user verifies via inbox link → first Continue/sign-in migrates it into `users` and deletes the pending doc.
- **Launcher icon** — the rocket is generated, not hand-drawn: `flutter test test/app_icon_generator_test.dart` renders `assets/icon/app_icon.png`, then `dart run flutter_launcher_icons` produces the platform icons. Swap in your own 1024px PNG at that path and re-run the same two commands.

---

## Status

Under active development. Manager, employee, and client flows are functional end to end against the deployed rules in `firestore.rules`.

Built with Flutter by the SprintFlow team.
