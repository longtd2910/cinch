# Cinch

A mobile-first expense tracker built with Flutter. Cinch helps you log spending from receipt and payment screenshots—either manually or by scanning your photo library with on-device ML.

## Overview

Cinch is in active development toward a solo money-tracking MVP: fast capture, a calendar-centric view of transactions, and optional photo-based detection so you do not have to type every entry by hand. Data stays on the device (Hive local storage). Social and sync features are planned for later phases.

## Features

- **Calendar home** — Month view with daily transaction summaries; drill into a selected day.
- **Manual transactions** — Add amount, time, tags, location, payment source, and an optional receipt photo (camera or gallery). EXIF metadata can pre-fill the transaction time.
- **Photo detection** — Scan photos taken on a given day and surface likely transaction screenshots using an ONNX classifier (`teacher.onnx`) via ONNX Runtime.
- **Today tab** — Live scan of today’s library photos with progress and confidence scores.
- **Day timeline** — Search and filter transactions by type, tag, source, and location.
- **Scheduled background scan** — Optional daily auto-scan at a chosen time (Workmanager on Android/iOS).
- **Dark UI** — Obsidian-themed Material 3 interface (`m3e_design`).

## Tech stack

| Layer | Choices |
|--------|---------|
| Framework | Flutter (Dart SDK ^3.11) |
| State | `provider` |
| Storage | `hive_ce` / `hive_ce_flutter` |
| ML | `onnxruntime_v2`, `image` preprocessing |
| Photos | `photo_manager`, `image_picker`, `exif` |
| Background work | `workmanager` |
| UI | Material 3 (`m3e_design`, `navigation_bar_m3e`, `google_fonts`) |

## Project structure

```
lib/
├── components/          # Reusable UI (calendar, pickers, amount field, …)
├── core/
│   ├── models/          # Transaction, DetectionResult
│   ├── services/        # Storage, photo scan, classifier, background scan
│   └── utils/           # Money/date formatting, EXIF helpers
├── providers/           # App, calendar, detection, transactions
├── screens/             # Tabs: calendar, today detection, day list, settings
└── theme/               # Obsidian tokens and AppTheme
assets/models/           # ONNX weights (teacher.onnx bundled for inference)
docs/                    # Screen map, tracker plan, deploy notes
```

## Getting started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) stable channel matching Dart SDK `^3.11`
- Android Studio / Xcode for device emulators or physical devices
- For detection: photo library permission on a real device (recommended)

### Install and run

```bash
git clone <repository-url>
cd cinch
flutter pub get
flutter run
```

### ONNX model

Inference uses `assets/models/teacher.onnx` (declared in `pubspec.yaml`). Ensure the file is present before building; a `student.onnx` asset may exist for training/distillation but is not loaded by the app today.

### Platform permissions

The app reads images from the device library for detection and receipt capture:

- **Android** — `READ_MEDIA_IMAGES` (and legacy storage on older API levels)
- **iOS** — Photo library usage (configured in `ios/Runner/Info.plist`)

Grant access when prompted; detection and background scans require it.

## Main navigation

| Tab | Purpose |
|-----|---------|
| Home | Monthly calendar and spending overview |
| Today | Scan and review today’s photos for transactions |
| Center (+) | Add a transaction (long-press opens camera) |
| Gallery | Selected day’s transaction list and filters |
| Profile | Settings, manual detection by date, daily scan schedule |

## Roadmap

Planned work (auth, budgets, insights, backup/sync, social) is tracked in [`docs/tracker-plan.md`](docs/tracker-plan.md) and [`docs/screen-map.md`](docs/screen-map.md).

## License

Not specified yet.
