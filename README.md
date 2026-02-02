# UV Exposure Monitor (Phase-1 Prototype)

A **Flutter-based prototype** for a personal UV exposure monitoring system. This app simulates tracking daily UV intake, learning user skin sensitivity, and providing adaptive safety thresholds.

> **Note:** This is a college demo/prototype. It uses **dummy data** simulation and has no backend or real sensor integration yet.

## 🚀 Features

*   **Adaptive Calibration**: Initial questionnaire to set personalized UV limits (Fitzpatrick scale logic).
*   **Real-time Dashboard**: Simulates live UV index and cumulative exposure tracking.
*   **Smart Alerts**: Visual warnings when approaching or exceeding daily safety limits.
*   **Human-in-the-Loop**: Daily feedback mechanism (Skin Discomfort check text) adjusts future thresholds.
*   **Explainability (XAI)**: Simple, human-readable explanations for why today's limit was set or changed.

## 🛠️ Tech Stack

*   **Framework**: Flutter (Dart)
*   **Architecture**: Modular / Feature-based
*   **State Management**: `setState` & `StreamBuilder` (kept simple for prototype)
*   **Design**: Material 3 (Minimalist Teal/White Theme)

## 📂 Project Structure

```
lib/
├── app/            # App configuration & Routes
├── core/           # Constants, Theme, Dummy Data Service
├── logic/          # Threshold algorithms & Explainability logic
├── models/         # Data models (UVModel)
├── screens/        # UI Screens (Onboarding, Dashboard, etc.)
└── widgets/        # Reusable UI components (Cards, Buttons)
```

## ⚡ How to Run

1.  **Prerequisites**: Ensure Flutter SDK is installed and valid (`flutter doctor`).
2.  **Clone/Open**: Open this folder in your terminal or VS Code.
3.  **Get Dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run**:
    ```bash
    flutter run
    ```

## 🔮 Future Roadmap (Phase 2)

*   [ ] Bluetooth (BLE) integration with hardware UV sensor.
*   [ ] Local Storage (Hive/SharedPreferences) to save user history.
*   [ ] Background Mode & Push Notifications.
*   [ ] Advanced ML model for precise threshold prediction.
