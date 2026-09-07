# Smart BP — AI Powered Health Monitoring

A cross-platform Flutter app for blood pressure monitoring with AI-assisted insights.

## Overview

Smart BP connects to a Bluetooth blood pressure monitor, records and tracks measurements over time, and provides an AI-assisted screen for health insights. The app supports both Arabic and English, includes PDF export of health reports, and displays measurement history with charts.

## Features

- **Bluetooth connectivity** — scan for and connect to a BP measurement device
- **Measurement tracking** — record and view blood pressure readings
- **History & charts** — visualize past measurements over time (`fl_chart`)
- **AI screen** — AI-assisted health insights
- **Patient / medical background profile** — store relevant patient info
- **PDF export** — generate and print health reports
- **Localization** — Arabic and English support (`easy_localization`)
- **Local notifications** — reminders via `flutter_local_notifications`

## Tech Stack

- **Flutter / Dart**
- `flutter_blue_plus` — Bluetooth Low Energy connectivity
- `flutter_local_notifications` — local reminders
- `fl_chart` — measurement history charts
- `pdf` / `printing` — report generation and export
- `easy_localization` — Arabic/English localization
- `csv` — data import/export
- `http` — network requests

## Repository structure

```
.
├── lib/
│   ├── main.dart
│   ├── splash_screen.dart
│   ├── profile_screen.dart
│   ├── medical_background_screen.dart
│   ├── patient_details_screen.dart
│   ├── home_screen.dart
│   ├── measurement_screen.dart
│   ├── history_screen.dart
│   ├── settings_screen.dart
│   ├── ai_screen.dart
│   ├── bluetooth_scan_screen.dart
│   ├── bluetooth_service.dart
│   ├── responsive.dart
│   └── app_translations.dart
├── pubspec.yaml
└── README.md
```

> Note: `assets/` (images, translation files, sample data, fonts) referenced in `pubspec.yaml` are not included in this repository.

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (SDK `>=3.11.3`).
2. Clone the repo:
   ```bash
   git clone https://github.com/<your-username>/<repo-name>.git
   cd <repo-name>
   ```
3. Add the required assets referenced in `pubspec.yaml` (`assets/logoB.jpg`, `assets/logo.jpg`, `assets/translations/`, `assets/data/avg_data.csv`, `assets/fonts/Amiri.ttf`).
4. Install dependencies and run:
   ```bash
   flutter pub get
   flutter run
   ```

## Team

- Areen Al-Akaleek
- Huda Shqerat

Idea by: Joud
