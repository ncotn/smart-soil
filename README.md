# Smart Soil - IoT Irrigation & Soil Moisture Monitoring System

A comprehensive Internet-of-Things (IoT) smart agriculture solution built for Final Year Projects (FYP) and real-world precision farming. The system features a responsive Flutter mobile dashboard connected to an ESP32 microcontroller with a capacitive soil moisture sensor and relay-controlled water pump via Firebase Realtime Database.

---

## 🌟 Key Features

1. **Real-Time Moisture Gauge**:
   * Custom glowing circular sweep gauge displaying current soil moisture percentage (`0% – 100%`).
   * Animated transitions for smooth real-time reading updates.
2. **Soil Condition Classification**:
   * **Dry Soil** (`< 35%`): Red warning badge & alert triggers.
   * **Optimal Moisture** (`35% – 75%`): Lush emerald green.
   * **Wet / Saturated** (`> 75%`): Water blue indicator.
3. **Hardware Connectivity Detection**:
   * Automatic offline detection (`Hardware Disconnected / Waiting for Tool`).
   * Reconnects automatically as soon as the ESP32 pushes live telemetry.
4. **Custom Low-Moisture Threshold & Push Alerts**:
   * Interactive slider to customize watering threshold (`10% – 60%`).
   * Real-time warning banner with quick-action *"Start Pump"* and *"Dismiss"* buttons.
5. **Water Pump & Smart Irrigation Actuator**:
   * Toggle between **Smart Auto Irrigation** and **Manual Water Now**.
   * Bidirectional sync with ESP32 relay GPIO.
6. **Interactive Historical Trend Chart**:
   * Custom sparkline area curve showing historical moisture changes, peak/trough records, and reference threshold lines.
7. **Firebase & ESP32 Configuration**:
   * Settings view to update your Firebase Realtime Database URL, check pinout references, and adjust calibration constants.

---

## 📁 Repository Structure

```text
smart_irrigation_app/
├── lib/
│   ├── main.dart                                  # App entry point & theme configuration
│   ├── data/
│   │   ├── models/moisture_reading.dart           # Domain data models & status logic
│   │   └── services/firebase_service.dart         # Live Firebase stream & REST polling
│   └── ui/
│       ├── core/theme.dart                        # Obsidian dark mode palette & design tokens
│       ├── features/
│       │   ├── dashboard/
│       │   │   ├── view_models/irrigation_view_model.dart # MVVM state management
│       │   │   ├── views/dashboard_view.dart              # Main dashboard screen
│       │   │   └── widgets/
│       │   │       ├── moisture_gauge.dart        # Custom arc gauge painter
│       │   │       ├── status_badge.dart          # Pill status indicator
│       │   │       ├── quick_stats_grid.dart      # 4-card metric overview
│       │   │       ├── pump_control_card.dart     # Pump actuation card
│       │   │       ├── history_chart_card.dart    # Custom sparkline trend chart
│       │   │       └── threshold_dialog.dart      # Bottom sheet slider dialog
│       │   └── settings/settings_view.dart        # Hardware pinout & Firebase config
├── firmware/
│   └── esp32_irrigation_firebase.ino              # Complete ESP32 Arduino/C++ firmware
├── assets/
│   └── icon/app_icon.png                          # App branding & launcher icon
├── android/                                       # Native Android configuration
└── pubspec.yaml                                   # Flutter dependencies & assets
```

---

## 🔌 Hardware Connections (ESP32)

| Component | Pin on Sensor/Relay | Pin on ESP32 | Description |
| :--- | :--- | :--- | :--- |
| **Soil Moisture Sensor** | VCC | 3.3V | Power supply |
| **Soil Moisture Sensor** | GND | GND | Ground |
| **Soil Moisture Sensor** | AOUT | GPIO 34 | Analog-to-Digital (ADC1) |
| **5V Relay Module (Pump)** | IN | GPIO 23 | Digital Output Trigger |
| **5V Relay Module (Pump)** | VCC | 5V / VIN | External 5V Power |
| **5V Relay Module (Pump)** | GND | GND | Shared Ground |

---

## 🚀 How to Run the App

### Requirements
* Flutter SDK (`>= 3.0.0`)
* Android Studio or VS Code with Flutter extension
* Android Device with Developer Mode enabled or Android Emulator

### Steps
1. Clone this repository:
   ```bash
   git clone <REPO_URL>
   cd smart_irrigation_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run on connected device:
   ```bash
   flutter run
   ```
4. Build APK:
   ```bash
   flutter build apk --release
   ```
   The generated APK will be in `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📝 License
MIT License. Created for FYP Smart Agriculture & IoT Soil Monitoring.
