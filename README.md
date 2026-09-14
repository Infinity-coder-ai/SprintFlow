# SprintFlow

SprintFlow is a Flutter project for managing agile work, projects, tasks, and team updates with role-based dashboards for managers, employees, and clients.

## Project structure

- `lib/` — application source code
- `lib/screens/` — screens for auth, dashboard, employees, projects, and tasks
- `lib/services/` — Firebase and business logic services
- `lib/models/` — data models
- `lib/widgets/` — reusable UI widgets
- `android/`, `ios/` — platform-specific project files

## Notes

- This project uses Firebase for authentication, Firestore, storage, and messaging.
- Platform-specific folders for web, Linux, macOS, and Windows were removed to keep the workspace focused on the app’s current needs.
