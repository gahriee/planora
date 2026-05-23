# Planora — Agent Instructions

> **This file must be read by every AI agent before performing any work on this project.**

---

## Mandatory Pre-Read

Before writing, editing, or suggesting any code for the Planora project, **always** read the following files in order:

1. **[`planora-architecture.md`](planora-architecture.md)** — The single source of truth for the entire application architecture. Contains:
   - Project structure and file tree
   - Data models (AppUser, Task) and Firestore document shapes
   - State management design (Riverpod providers, ViewModels)
   - Navigation graph (GoRouter with auth gate)
   - Screen specifications and component contracts
   - Repository API surface
   - Color scheme and theme system
   - System requirements and toolchain versions
   - `pubspec.yaml` dependencies
   - Firebase configuration and security rules

2. **[`project-status.md`](project-status.md)** — Current build progress. Check which phases are complete, in-progress, or not started to understand what exists and what needs to be built.

---

## Core Principles

### 1. Architecture-First Development
- **Never deviate** from the architecture document without explicit user approval.
- All file paths, class names, and module boundaries must match the spec.
- If the architecture doesn't cover something, ask the user rather than improvising.

### 2. MVVM + Repository Pattern
- **Models** → Pure data classes (freezed). No logic.
- **Repository** → All Firestore reads/writes and Firebase Auth calls. One repository.
- **Providers** → Riverpod wiring. Exposes streams and ViewModels to the widget tree.
- **ViewModels** → UI logic, loading states, form validation, error handling.
- **Views** → Presentation only. Read providers, call ViewModel methods. No direct Firestore access.
- **Components** → Reusable widgets with no provider dependency.

### 3. State Management Rules
- Use `flutter_riverpod` exclusively.
- `ProviderScope` wraps the entire app at the root.
- Use `StreamProvider` for real-time Firestore data.
- Use derived `Provider` for filtered views (today, upcoming) — no extra Firestore calls.
- **CRITICAL:** Due to `flutter_riverpod` version >= 3.x, legacy APIs like `StateNotifier`, `StateNotifierProvider`, and `StateProvider` are removed. You **must** use modern `Notifier` and `AsyncNotifier` with `NotifierProvider` and `AsyncNotifierProvider` for ViewModels and mutable state.

### 4. Navigation Rules
- Use `go_router` exclusively.
- Auth gate via `redirect` — unauthenticated users go to `/auth`, authenticated users skip it.
- Use `StatefulShellRoute.indexedStack` for bottom navigation.
- **CRITICAL:** The number of `StatefulShellBranch` objects MUST exactly match the number of `BottomNavigationBarItem`s. Any screens not meant for the bottom tab bar (e.g., Profile, Auth) must be placed as top-level `GoRoute`s outside the shell.
- Use explicit parameter names `(context, state)` in route builders instead of multiple underscores `(_, __)` to avoid analyzer lint warnings.
- Never use `Navigator.push` directly.

### 5. Styling & Theme
- Use the centralized theme system (`lib/app/theme.dart`).
- Reference `AppColors` constants — never hard-code hex values in widgets.
- Support both light and dark mode via `ThemeMode.system`.
- Use Material 3 (`useMaterial3: true`).

### 6. Firebase & Data
- All Firestore operations go through `TaskRepository`.
- Inject document IDs via `{...d.data(), 'id': d.id}` pattern.

### 7. Refactoring & Testing
- When replacing the default Flutter `MyApp` with a custom root widget (e.g., `PlanoraApp`), you **must** immediately update `test/widget_test.dart` to pump the new widget to prevent test compilation errors (`creation_with_non_type`).
- Firestore security rules must enforce `userId` ownership.
- Never commit Firebase config files (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`).

### 8. Code Generation
- Models use `freezed` + `json_serializable`.
- **CRITICAL:** Due to Freezed >= 3 and Dart analyzer rules, any Freezed model class using the `with _$ModelName` mixin **must be declared as `abstract`** (e.g., `@freezed abstract class AppUser with _$AppUser`). Failing to do so causes a `non_abstract_class_inherits_abstract_member` error.
- Run `dart run build_runner build --delete-conflicting-outputs` after model changes.
- Generated files (`*.g.dart`, `*.freezed.dart`) are gitignored.

### 9. Flutter 3.27+ API Changes & Imports
- **Color Opacity**: `Color.withOpacity()` is deprecated in modern Flutter. You **must** use `.withValues(alpha: X)` instead (e.g., `AppColors.primary.withValues(alpha: 0.3)`).
- **Chips**: `ActionChip` does not support the `onDeleted` property. If you need a chip with a delete/close icon, use `InputChip`.
- **Dependencies**: Whenever integrating a new package (like `table_calendar`), always ensure it is actually added to `pubspec.yaml` via `flutter pub add <package>` before running static analysis.

---

## Status Updates

After completing any phase or significant task:
1. Update `project-status.md` with the new status (✅ / 🔨 / 🔲).
2. Update the "Current Phase" section to reflect what's active.
3. Update the "Last Updated" date.

---

## Quick Reference

| What | Where |
|------|-------|
| Architecture spec | `planora-architecture.md` |
| Build progress | `project-status.md` |
| App entry point | `lib/main.dart` |
| App root | `lib/app/app.dart` |
| Router | `lib/app/router.dart` |
| Theme | `lib/app/theme.dart` |
| Models | `lib/models/models.dart` |
| Repository | `lib/repositories/task_repository.dart` |
| Providers | `lib/providers/providers.dart` |
| ViewModels | `lib/viewmodels/` |
| Dashboard (Module 1) | `lib/views/dashboard/` |
| Calendar (Module 2) | `lib/views/calendar/` |
| Tasks (Module 3) | `lib/views/tasks/` |
| Auth | `lib/views/auth/` |
| Profile | `lib/views/profile/` |
| Components | `lib/components/` |
| Tests | `test/unit/`, `test/widget/` |
