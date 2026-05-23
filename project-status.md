# Planora — Project Status

**Last Updated:** 2026-05-23

---

## Overview

| Detail       | Value                                       |
|--------------|---------------------------------------------|
| **App**      | Planora — To-Do List                        |
| **Platform** | iOS + Android                               |
| **Language** | Dart                                        |
| **UI**       | Flutter 3.41.1                              |
| **Pattern**  | MVVM + Repository                           |
| **Backend**  | Firebase (Auth + Firestore)                 |
| **State**    | Riverpod                                    |
| **Nav**      | GoRouter                                    |

---

## Build Phases

### Phase 1 — Project Setup & Firebase
> Flutter project creation, dependency installation, Firebase configuration.

| Task                                  | Status |
|---------------------------------------|--------|
| Create Flutter project (iOS + Android)| ✅ Done |
| Configure `pubspec.yaml` dependencies | ✅ Done |
| Firebase project creation             | ✅ Done |
| `flutterfire configure`               | ✅ Done |
| Platform configs (Android SDK, iOS)   | ✅ Done |

### Phase 2 — Data Layer
> Models, repository, Firestore CRUD, Firebase Auth integration.

| Task                                  | Status |
|---------------------------------------|--------|
| `models.dart` (AppUser, Task, enums)  | ✅ Done |
| Code generation (`freezed`, `json`)   | ✅ Done |
| `task_repository.dart` (CRUD + streams)| ✅ Done |
| Firestore security rules              | ✅ Done |

### Phase 3 — State Management
> Riverpod providers and ViewModels.

| Task                                     | Status |
|------------------------------------------|--------|
| `providers.dart` (auth, tasks, calendar, dashboard stats) | ✅ Done |
| `auth_viewmodel.dart`                    | ✅ Done |
| `dashboard_viewmodel.dart`               | ✅ Done |
| `calendar_viewmodel.dart`                | ✅ Done |
| `task_viewmodel.dart`                    | ✅ Done |

### Phase 4 — App Shell & Navigation
> MaterialApp root, GoRouter, theme system, bottom navigation scaffold (3 tabs).

| Task                                     | Status |
|------------------------------------------|--------|
| `app.dart` (MaterialApp + ProviderScope) | ✅ Done |
| `router.dart` (GoRouter + auth gate)     | ✅ Done |
| `theme.dart` (light + dark themes)       | ✅ Done |
| `main.dart` refactor (Firebase init)     | ✅ Done |
| MainScaffold + BottomNavigationBar (3 tabs) | ✅ Done |

### Phase 5 — Views & Components
> All screens and reusable UI components across 3 modules.

| Task                                     | Status |
|------------------------------------------|--------|
| **Auth**                                 |        |
| `AuthScreen` (Optional Link Account)     | ✅ Done |
| **Module 1 — Dashboard**                 |        |
| `DashboardScreen` (stats + demographics) | ✅ Done |
| `StatCard` component                     | ✅ Done |
| **Module 2 — Calendar**                  |        |
| `CalendarScreen` (full calendar + task list) | ✅ Done |
| `table_calendar` integration             | ✅ Done |
| **Module 3 — Tasks**                     |        |
| `TasksScreen` (filter chips + search + list) | ✅ Done |
| `CreateTaskSheet` (bottom sheet)         | ✅ Done |
| `TaskDetailScreen` (view + edit)         | ✅ Done |
| Swipe-to-complete / swipe-to-delete      | ✅ Done |
| **Shared Components**                    |        |
| `TaskCard` component                     | ✅ Done |
| `PriorityBadge` component               | ✅ Done |
| `StatusBadge` component                  | ✅ Done |
| `DueDateChip` component                 | ✅ Done |
| `EmptyStateView` component              | ✅ Done |
| `AuthTextField` component               | ✅ Done |
| **Profile**                              |        |
| `ProfileScreen`                          | ✅ Done |

### Phase 6 — Testing & Polish
> Unit tests, widget tests, final polish.

| Task                                     | Status |
|------------------------------------------|--------|
| ViewModel unit tests                     | ✅ Done |
| Repository unit tests                    | ✅ Done |
| Widget tests (key screens)               | ✅ Done |
| UI polish & animations                   | ✅ Done |

---

## Current Phase

> **Phase 6 — Testing & Polish**
>
> Phase 5 is fully complete. The app now features all UI screens and components, wired to Riverpod and GoRouter. The final phase involves writing tests and performing UI polish.

---

## Status Legend

| Icon | Meaning |
|------|---------|
| ✅   | Done |
| 🔨   | In Progress |
| 🔲   | Not Started |
| ⚠️   | Blocked |

---

## Architecture Reference

> 📐 See [`planora-architecture.md`](planora-architecture.md) for the full technical specification including data models, Firestore schema, navigation graph, color system, and module responsibilities.
