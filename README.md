# Planora

A minimal, focused to-do list app built with Flutter for iOS and Android.

---

## ✨ Features

- **📊 Dashboard** — Task completion demographics with daily, weekly, and overall stats
- **📅 Calendar View** — Full month calendar with task dot markers; tap a date to see tasks below
- **✅ Task Management** — Create, edit, and delete tasks with title, description, priority, and due date
- **Filter & Search** — Filter tasks by status (All / To Do / In Progress / Done) and search by title
- **Priority Levels** — Low, Medium, and High with color-coded badges
- **Status Tracking** — To Do → In Progress → Done workflow
- **Swipe Actions** — Swipe right to complete, swipe left to delete (with undo)
- **Real-Time Sync** — Live Firestore streams keep data in sync across devices
- **Offline Support** — Firestore's built-in offline persistence for seamless offline usage
- **Optional Authentication** — Start immediately with anonymous usage, and optionally link an email later to sync devices
- **Dark Mode** — Full light and dark theme support via system preference
- **Cross-Platform** — One codebase for iOS and Android

---

## 🏗 Architecture

**Pattern:** MVVM + Repository
**State:** Riverpod · **Navigation:** GoRouter · **Backend:** Firebase (Auth + Firestore)

```
Models → Repository → Providers → ViewModels → Views
  │          │             │            │          │
  │  Firestore CRUD   Riverpod     UI logic   Presentation
  │  + Auth calls     wiring       + state     only
  │
  Pure data (freezed)
```

> 📐 See [`planora-architecture.md`](planora-architecture.md) for the full technical specification.

---

## 📁 Project Structure

```
lib/
├── main.dart                   # Entry point
├── app/
│   ├── app.dart                # MaterialApp + ProviderScope root
│   ├── router.dart             # GoRouter config (auth gate)
│   └── theme.dart              # Light + dark theme system
├── models/
│   └── models.dart             # Data classes (freezed)
├── repositories/
│   └── task_repository.dart    # Firestore CRUD + Auth
├── providers/
│   └── providers.dart          # Riverpod providers
├── viewmodels/                 # UI logic + state
├── views/                      # Screen widgets
└── components/                 # Reusable UI components
```

---

## 🛠 Tech Stack

| Layer          | Technology                          |
|----------------|-------------------------------------|
| **Language**   | Dart 3.11                           |
| **Framework**  | Flutter 3.41.1                      |
| **State**      | flutter_riverpod                    |
| **Navigation** | go_router                           |
| **Backend**    | Firebase Auth + Cloud Firestore     |
| **Models**     | freezed + json_serializable         |
| **Build**      | build_runner                        |

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.41.1+ (stable channel)
- Dart 3.11.0+
- Firebase project with Auth + Firestore enabled
- Android Studio (for Android) / Xcode (for iOS)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/planora.git
cd planora

# 2. Configure Firebase
dart pub global activate flutterfire_cli
flutterfire configure

# 3. Install dependencies
flutter pub get

# 4. Generate model code
dart run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run
```

### iOS Setup (requires macOS)

```bash
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
# Set Team in Signing & Capabilities, then Run ▶
```

> ⚠️ Free Apple ID certificates expire every 7 days. Reinstall with `flutter run --release`.

---

## 📋 Project Status

See [`project-status.md`](project-status.md) for detailed build progress across all phases.

---

## 🤖 AI Agent Instructions

See [`agents.md`](agents.md) for mandatory rules and conventions that AI agents must follow when contributing to this project.

---

## 📄 License

This project is for personal/educational use.
