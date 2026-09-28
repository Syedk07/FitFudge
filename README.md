# FitFudge

**Elite Athletic Training & Performance System** — a cross-platform Flutter application for tracking workouts, body measurements, and fitness progress.

---

## Features

- **Dashboard** — at-a-glance overview of your training stats and recent activity
- **Workout Templates** — create and manage reusable workout plans
- **Active Workout** — log sets, reps, and weights in real time
- **Workout History** — review past sessions and track progress over time
- **Exercise Library** — browse exercises with detailed instructions and muscle-group info
- **Body Measurements** — log and visualise body metrics over time
- **Fitness Calculator** — BMI, TDEE, and other health calculators
- **Profile** — manage personal info and app preferences

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart ≥ 3.0) |
| State Management | Provider 6.x |
| Local Database | SQLite via sqflite 2.x |
| Date Formatting | intl 0.19 |
| UI | Material Design 3 (custom dark theme) |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0
- Android SDK / Xcode (for mobile builds)
- A connected device or emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/Syedk07/FitFudge.git
cd FitFudge

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

---

## Project Structure

```
lib/
├── data/
│   ├── calculator/   # Fitness calculation logic
│   ├── db/           # SQLite database helper
│   ├── exercises/    # Exercise data definitions
│   └── model/        # Data models
├── providers/        # State management (Provider)
└── ui/
    ├── screens/      # App screens
    ├── theme/        # App theme & colours
    └── widgets/      # Shared UI components
```

---

## Supported Platforms

- Android (minSdk 21+)
- iOS (12.0+)
- Web
- Windows / macOS / Linux (desktop Flutter)

---

## License

This project is for personal and educational use. All rights reserved © FitFudge.
