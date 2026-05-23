# Planora — Flutter Architecture

**App:** To-Do List · **Platform:** iOS + Android · **Language:** Dart · **UI:** Flutter · **Pattern:** MVVM + Repository
> ✅ One codebase, both platforms.

---

## 1. Project Structure

```
planora/
├── lib/
│   ├── main.dart                        # Entry point
│   │
│   ├── app/
│   │   ├── app.dart                     # MaterialApp + ProviderScope root
│   │   ├── router.dart                  # GoRouter config (auth gate + all routes)
│   │   └── theme.dart                   # Light + dark theme (AppColors)
│   │
│   ├── models/
│   │   └── models.dart                  # All data classes (freezed)
│   │
│   ├── repositories/
│   │   └── task_repository.dart         # Firestore CRUD, stream subscriptions
│   │
│   ├── providers/
│   │   └── providers.dart               # Riverpod providers
│   │
│   ├── viewmodels/
│   │   ├── auth_viewmodel.dart
│   │   ├── dashboard_viewmodel.dart     # Completion stats logic
│   │   ├── calendar_viewmodel.dart      # Selected date + filtered tasks
│   │   └── task_viewmodel.dart          # CRUD operations
│   │
│   ├── views/
│   │   ├── auth/
│   │   │   └── auth_screen.dart         # Login + Register tabs
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart    # Task completion demographics
│   │   ├── calendar/
│   │   │   └── calendar_screen.dart     # Full calendar + tasks for selected date
│   │   ├── tasks/
│   │   │   ├── tasks_screen.dart        # Task list with CRUD
│   │   │   ├── task_detail_screen.dart  # View + edit a task
│   │   │   └── create_task_sheet.dart   # Bottom sheet to add a task
│   │   └── profile/
│   │       └── profile_screen.dart
│   │
│   └── components/
│       ├── task_card.dart
│       ├── priority_badge.dart
│       ├── due_date_chip.dart
│       ├── status_badge.dart
│       ├── stat_card.dart               # Reusable stat tile for dashboard
│       ├── empty_state_view.dart
│       └── auth_text_field.dart
│
├── test/
│   ├── unit/                            # ViewModel + repository tests
│   └── widget/                          # Widget tests
│
├── pubspec.yaml
└── firebase_options.dart                # FlutterFire CLI generated
```

---

## 2. Data Models (`lib/models/models.dart`)

```dart
@freezed
class AppUser with _$AppUser {
  factory AppUser({
    required String id,
    required String name,
    required String email,
  }) = _AppUser;
  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

@freezed
class Task with _$Task {
  factory Task({
    required String id,
    required String userId,         // → AppUser (owner)
    required String title,
    String? description,
    required TaskPriority priority, // low | medium | high
    required TaskStatus status,     // todo | inProgress | done
    DateTime? dueDate,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Task;
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

enum TaskPriority { low, medium, high }

enum TaskStatus { todo, inProgress, done }
```

### Firestore Document Shape

```
/users/{userId}
  name: String
  email: String

/tasks/{taskId}
  userId: String
  title: String
  description: String?
  priority: "low" | "medium" | "high"
  status: "todo" | "inProgress" | "done"
  dueDate: Timestamp?
  createdAt: Timestamp
  completedAt: Timestamp?
```

---

## 3. State Management

**Package:** `flutter_riverpod`

```
main.dart
  └── ProviderScope  ← root, single source of truth
        └── MaterialApp (via app.dart)
              └── GoRouter auth gate
                    ├── [unauthenticated] → AuthScreen
                    └── [authenticated]   → MainScaffold (BottomNavigationBar — 3 tabs)
                          ├── Tab 1: DashboardScreen  (ref.watch(tasksProvider) → stats)
                          ├── Tab 2: CalendarScreen   (ref.watch(selectedDateTasksProvider))
                          ├── Tab 3: TasksScreen      (ref.watch(tasksProvider) → CRUD)
                          │            └── TaskDetailScreen
                          │            └── CreateTaskSheet
                          └── ProfileScreen            (ref.watch(authProvider))
```

### Provider Declarations (`lib/providers/providers.dart`)

```dart
// Auth — who is logged in
final authProvider = StateNotifierProvider<AuthViewModel, AsyncValue<AppUser?>>((ref) {
  return AuthViewModel(ref.read(taskRepositoryProvider));
});

// All tasks for the current user — live Firestore stream
final tasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final user = ref.watch(authProvider).value;
  if (user == null) return const Stream.empty();
  return ref.read(taskRepositoryProvider).tasksStream(user.id);
});

// ── Calendar module ──

// Currently selected date on the calendar (defaults to today)
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Tasks for the selected calendar date — derived, no extra Firestore calls
final selectedDateTasksProvider = Provider.autoDispose<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final date = ref.watch(selectedDateProvider);
  return tasks.where((t) =>
    t.dueDate != null &&
    t.dueDate!.year == date.year &&
    t.dueDate!.month == date.month &&
    t.dueDate!.day == date.day
  ).toList();
});

// ── Dashboard module ──

// Tasks completed today
final todayCompletedProvider = Provider.autoDispose<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final today = DateTime.now();
  return tasks.where((t) =>
    t.status == TaskStatus.done &&
    t.completedAt != null &&
    t.completedAt!.year == today.year &&
    t.completedAt!.month == today.month &&
    t.completedAt!.day == today.day
  ).toList();
});

// Tasks completed this week (Monday–Sunday)
final weekCompletedProvider = Provider.autoDispose<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));
  return tasks.where((t) =>
    t.status == TaskStatus.done &&
    t.completedAt != null &&
    t.completedAt!.isAfter(weekStart) &&
    t.completedAt!.isBefore(weekEnd)
  ).toList();
});

// Pending tasks (not done)
final pendingTasksProvider = Provider.autoDispose<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  return tasks.where((t) => t.status != TaskStatus.done).toList();
});

// Overdue tasks (past due date and not done)
final overdueTasksProvider = Provider.autoDispose<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final now = DateTime.now();
  return tasks.where((t) =>
    t.status != TaskStatus.done &&
    t.dueDate != null &&
    t.dueDate!.isBefore(now)
  ).toList();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());
```

---

## 4. Navigation (`lib/app/router.dart`)

**Package:** `go_router`

```dart
final router = GoRouter(
  // No strict auth gate. App uses anonymous auth by default.
  // /auth is accessed voluntarily from the Profile screen to sync tasks.
  initialLocation: '/',
  routes: [
    GoRoute(path: '/auth', builder: (_,__) => const AuthScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => MainScaffold(shell: shell),
      branches: [
        // Tab 1 — Dashboard
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/',
            builder: (_,__) => const DashboardScreen(),
          ),
        ]),
        // Tab 2 — Calendar
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/calendar',
            builder: (_,__) => const CalendarScreen(),
          ),
        ]),
        // Tab 3 — Tasks
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/tasks',
            builder: (_,__) => const TasksScreen(),
            routes: [
              GoRoute(
                path: ':taskId',
                builder: (_, state) => TaskDetailScreen(
                  taskId: state.pathParameters['taskId']!,
                ),
              ),
            ],
          ),
        ]),
        // Profile (accessed via AppBar icon, not a bottom tab)
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_,__) => const ProfileScreen()),
        ]),
      ],
    ),
  ],
);
```

### Bottom Navigation Tabs

| Index | Label     | Icon                          | Route       |
|-------|-----------|-------------------------------|-------------|
| 0     | Dashboard | `Icons.dashboard_rounded`     | `/`         |
| 1     | Calendar  | `Icons.calendar_month_rounded`| `/calendar` |
| 2     | Tasks     | `Icons.check_circle_rounded`  | `/tasks`    |

---

## 5. Screen Specifications

### AuthScreen *(Optional "Link Account")*
- Accessed voluntarily from `ProfileScreen` to sync tasks across devices
- `TabBar` with Login / Register (Link) tabs
- Login: email + password → `authViewModel.login()`
- Register (Link): email, password → `authViewModel.linkAccount()`
- Inline error display via `AsyncValue.error`
- Reusable `AuthTextField` component

### DashboardScreen *(Tab 1 — Statistics)*
- **Summary cards** at top:
  - Total tasks
  - Completed today
  - Completed this week
  - Overdue count
- **Completion rate** — circular progress indicator (done / total)
- **Priority breakdown** — horizontal bar or pie showing Low · Medium · High distribution
- **Recent completions** — short list of last 5 completed tasks
- All data derived from `tasksProvider` — no extra Firestore calls
- Uses `StatCard` component for each metric

### CalendarScreen *(Tab 2 — Calendar + Tasks)*
- **Full month calendar** at top via `table_calendar` package
  - Dot markers on dates that have tasks
  - Tap a date → updates `selectedDateProvider`
  - Swipe left/right to change month
- **Task list below** — shows tasks for the selected date
  - `ListView` of `TaskCard` widgets sorted by `priority`
  - Tap a card → navigate to `TaskDetailScreen`
- `EmptyStateView` when no tasks exist for the selected date
- `FloatingActionButton` → `CreateTaskSheet` (pre-fills selected date as due date)

### TasksScreen *(Tab 3 — Full Task List + CRUD)*
- **Filter chips** at top: **All · To Do · In Progress · Done**
- **Search bar** — filter tasks by title
- `ListView` of `TaskCard` widgets, sorted by `dueDate` then `priority`
- **Swipe right** on a card → mark complete
- **Swipe left** on a card → delete (with undo `SnackBar`)
- `EmptyStateView` per filter when no tasks match
- `FloatingActionButton` → `CreateTaskSheet`

### CreateTaskSheet *(Bottom Sheet)*
- **Title** — required text field
- **Description** — optional, multiline
- **Priority** — `SegmentedButton`: Low · Medium · High (default: Medium)
- **Due Date** — optional, tap chip → `showDatePicker()`
- Submit → `taskViewModel.createTask()`

### TaskDetailScreen
- Full view of a single task
- All fields editable inline (title, description, priority, due date)
- **Status toggle** — `SegmentedButton`: To Do · In Progress · Done
- Auto-saves on field change (debounced 500ms)
- Delete button in AppBar `PopupMenuButton`

### ProfileScreen
- Display user email (if linked), or "Anonymous User" (if not linked)
- Accessed via profile icon in AppBar (not a bottom nav tab)
- If anonymous: Show "Sign Up / Log In to Sync" button → navigates to `/auth`
- If linked: Show "Log Out" button → `authViewModel.logout()`

---

## 6. Repository — Key Operations (`lib/repositories/task_repository.dart`)

| Operation | Repository Method |
|---|---|
| Anonymous Sign-In | `signInAnonymously()` (Auto-run if no user) |
| Link Account | `linkAccount(email, password)` (Upgrades user) |
| Login | `login(email, password)` |
| Logout | `logout()` |
| Stream all tasks | `tasksStream(userId)` — real-time |
| Create task | `createTask(task)` |
| Update task | `updateTask(task)` |
| Delete task | `deleteTask(taskId)` |
| Toggle complete | `toggleComplete(taskId, isComplete)` |

```dart
class TaskRepository {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Real-time task stream for current user
  Stream<List<Task>> tasksStream(String userId) {
    return _db
      .collection('tasks')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
        .map((d) => Task.fromJson({...d.data(), 'id': d.id}))
        .toList());
  }

  Future<void> createTask(Task task) async {
    await _db.collection('tasks').add(task.toJson());
  }

  Future<void> updateTask(Task task) async {
    await _db.collection('tasks').doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  Future<void> toggleComplete(String taskId, bool isComplete) async {
    await _db.collection('tasks').doc(taskId).update({
      'status':      isComplete ? 'done' : 'todo',
      'completedAt': isComplete ? Timestamp.now() : null,
    });
  }
}
```

---

## 7. Persistence & Backend

**Firebase — Authentication + Firestore**

### Authentication — `firebase_auth`
```dart
// Anonymous Sign-In (Default)
await FirebaseAuth.instance.signInAnonymously();

// Link Account (Upgrade from anonymous)
final credential = EmailAuthProvider.credential(email: email, password: password);
await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);

// Login (Existing user)
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email, password: password,
);

// Auth state stream
FirebaseAuth.instance.authStateChanges();
```

### Database — `cloud_firestore`

```
/users/{userId}        ← profile info
/tasks/{taskId}        ← all tasks (filtered by userId in queries)
```

**Firestore Security Rules**

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /tasks/{taskId} {
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### Offline Support
Firestore's built-in offline persistence is enabled by default on mobile — tasks load instantly from local cache even without internet, and sync automatically when reconnected.

---

## 8. Module Responsibilities

| Module | Responsibility |
|---|---|
| `models.dart` | Pure immutable value types. No logic. |
| `task_repository.dart` | All Firestore reads/writes and Firebase Auth calls. |
| `providers/` | Riverpod wiring — exposes streams and ViewModels to the widget tree. |
| `viewmodels/` | UI logic — loading states, form validation, error handling. |
| `views/` | Presentation only. Reads providers, calls ViewModel methods. |
| `components/` | Reusable widgets with no provider dependency. |

---

## 9. Task Priority & Status

```dart
enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label => name[0].toUpperCase() + name.substring(1);
  Color get color {
    switch (this) {
      case TaskPriority.low:    return const Color(0xFF22C55E); // green
      case TaskPriority.medium: return const Color(0xFFF59E0B); // amber
      case TaskPriority.high:   return const Color(0xFFEF4444); // red
    }
  }
  IconData get icon {
    switch (this) {
      case TaskPriority.low:    return Icons.arrow_downward_rounded;
      case TaskPriority.medium: return Icons.remove_rounded;
      case TaskPriority.high:   return Icons.arrow_upward_rounded;
    }
  }
}

enum TaskStatus { todo, inProgress, done }

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:       return 'To Do';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.done:       return 'Done';
    }
  }
  Color get color {
    switch (this) {
      case TaskStatus.todo:       return const Color(0xFF94A3B8); // slate
      case TaskStatus.inProgress: return const Color(0xFF3B82F6); // blue
      case TaskStatus.done:       return const Color(0xFF22C55E); // green
    }
  }
}
```

---

## 10. Color Scheme

### Brand Palette

| Token | Light Mode | Dark Mode | Usage |
|---|---|---|---|
| `primary` | `#7C3AED` (Violet 600) | `#8B5CF6` (Violet 500) | Buttons, FAB, active tabs |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` | Text/icons on primary |
| `secondary` | `#06B6D4` (Cyan 500) | `#22D3EE` (Cyan 400) | Accent chips, highlights |
| `surface` | `#FFFFFF` | `#1E1B2E` (Deep Violet) | Cards, sheets, dialogs |
| `background` | `#F5F3FF` (Violet 50) | `#0F0D1A` (Near Black) | App background |
| `error` | `#EF4444` (Red 500) | `#F87171` (Red 400) | Errors, delete actions |
| `onSurface` | `#1E1B2E` | `#EDE9FE` (Violet 100) | Body text |
| `outline` | `#DDD6FE` (Violet 200) | `#2E2A45` | Borders, dividers |

### Task Priority Colors

| Priority | Color | Hex |
|---|---|---|
| 🟢 Low | Green | `#22C55E` |
| 🟡 Medium | Amber | `#F59E0B` |
| 🔴 High | Red | `#EF4444` |

### Task Status Colors

| Status | Color | Hex |
|---|---|---|
| ⬜ To Do | Slate | `#94A3B8` |
| 🔵 In Progress | Blue | `#3B82F6` |
| ✅ Done | Green | `#22C55E` |

### Implementation (`lib/app/theme.dart`)

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary       = Color(0xFF7C3AED);
  static const primaryDark   = Color(0xFF8B5CF6);
  static const secondary     = Color(0xFF06B6D4);
  static const secondaryDark = Color(0xFF22D3EE);

  // Backgrounds
  static const background      = Color(0xFFF5F3FF);
  static const backgroundDark  = Color(0xFF0F0D1A);
  static const surface         = Color(0xFFFFFFFF);
  static const surfaceDark     = Color(0xFF1E1B2E);

  // Text
  static const textPrimary     = Color(0xFF1E1B2E);
  static const textPrimaryDark = Color(0xFFEDE9FE);
  static const textSecondary   = Color(0xFF6B7280);

  // Borders
  static const outline         = Color(0xFFDDD6FE);
  static const outlineDark     = Color(0xFF2E2A45);

  // Task priority
  static const priorityLow    = Color(0xFF22C55E);
  static const priorityMedium = Color(0xFFF59E0B);
  static const priorityHigh   = Color(0xFFEF4444);

  // Task status
  static const statusTodo       = Color(0xFF94A3B8);
  static const statusInProgress = Color(0xFF3B82F6);
  static const statusDone       = Color(0xFF22C55E);

  // Semantic
  static const error   = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
}

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary:   AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    surface:   AppColors.surface,
    error:     AppColors.error,
    outline:   AppColors.outline,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 1,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.outline),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor:     AppColors.surface,
    selectedItemColor:   AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    elevation: 0,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AppColors.outline),
    ),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary:   AppColors.primaryDark,
    onPrimary: Colors.white,
    secondary: AppColors.secondaryDark,
    surface:   AppColors.surfaceDark,
    error:     Color(0xFFF87171),
    outline:   AppColors.outlineDark,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textPrimaryDark,
    elevation: 0,
    scrolledUnderElevation: 1,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.outlineDark),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor:     AppColors.surfaceDark,
    selectedItemColor:   AppColors.primaryDark,
    unselectedItemColor: AppColors.textSecondary,
    elevation: 0,
  ),
);
```

### Wire into `app.dart`

```dart
MaterialApp.router(
  title: 'Planora',
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.system,
  routerConfig: router,
);
```

---

## 11. System Requirements

### Toolchain

| Tool | Version |
|---|---|
| Flutter | 3.41.1 (stable channel) |
| Dart | 3.11.0 |
| DevTools | 2.54.1 |

### iOS Build (Direct Device Install)

> ⚠️ **iOS builds require a Mac.**

**Distribution method: Direct Device Install (Free Apple ID)**

| Requirement | Notes |
|---|---|
| macOS Ventura (13) or later | Required to run Xcode |
| Xcode — latest stable or beta | Free from Mac App Store |
| CocoaPods — latest | `sudo gem install cocoapods` |
| Free Apple ID | No $99 account needed |
| iPhone running iOS 13 or later | Flutter 3.41 supports iOS 13–26 |

App certificate expires every **7 days** with a free Apple ID. Reinstall with `flutter run --release`.

### Android Build

| Requirement | Version |
|---|---|
| Android Studio | Latest stable |
| Android SDK | API 24+ (Android 7.0) |
| `minSdkVersion` | 24 |
| `targetSdkVersion` | 36 |
| JDK | 17 (bundled with Android Studio) |

---

## 12. `pubspec.yaml` — Key Dependencies

```yaml
name: planora
description: A minimal, focused to-do app.

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.x.x
  firebase_auth: ^5.x.x
  cloud_firestore: ^5.x.x

  # State management
  flutter_riverpod: ^2.x.x
  riverpod_annotation: ^2.x.x

  # Navigation
  go_router: ^14.x.x

  # Models
  freezed_annotation: ^2.x.x
  json_annotation: ^4.x.x

  # Utilities
  uuid: ^4.x.x
  intl: ^0.19.x
  table_calendar: ^3.x.x          # Calendar UI widget

dev_dependencies:
  build_runner: ^2.x.x
  freezed: ^2.x.x
  json_serializable: ^6.x.x
  riverpod_generator: ^2.x.x
  flutter_test:
    sdk: flutter
```

---

## 13. GitHub & Setup

```bash
# 1. Create Flutter project
flutter create planora --platforms=ios,android
cd planora

# 2. Push to GitHub
git init
git add .
git commit -m "initial commit"
git remote add origin https://github.com/yourusername/planora.git
git branch -M main
git push -u origin main

# 3. Configure Firebase
dart pub global activate flutterfire_cli
flutterfire configure

# 4. Install dependencies
flutter pub get

# 5. Generate freezed + riverpod code
dart run build_runner build --delete-conflicting-outputs

# 6a. Run on Android
flutter run

# 6b. Run on iPhone (direct install)
cd ios && pod install && cd ..
open ios/Runner.xcworkspace   # set Team in Signing & Capabilities, then hit Run ▶
```

### `.gitignore` — Key Entries

```
# Generated files
*.g.dart
*.freezed.dart

# Firebase (re-run flutterfire configure after cloning)
google-services.json
GoogleService-Info.plist
firebase_options.dart

# iOS
ios/Pods/

# Build
build/
.dart_tool/
```

> ⚠️ Never commit Firebase config files. Run `flutterfire configure` after every fresh clone to regenerate them.
