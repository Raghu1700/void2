# SonoSight - Glaucoma Detection App

An innovative Flutter application that uses ultrasound technology to measure intraocular pressure (IOP) for early glaucoma detection.

## Overview

SonoSight addresses the critical problem of glaucoma detection through affordable, non-invasive IOP measurement using ultrasonic technology. The app connects to ESP8266-based hardware that measures IOP using acoustic radiation force (ARF).

## Key Features

### 🎯 Main Features

- **Real-time Dashboard**: Live IOP readings from ESP8266 device with 3D interactive eye visualization
- **Risk Analysis**: AI-powered glaucoma risk assessment using camera input and multiple parameters
- **Reading History**: Complete history of IOP measurements with detailed analytics
- **Settings**: Device configuration and data management
- **About**: Information about SonoSight technology

### 📱 Pages

1. **Dashboard Page**
   - Current IOP display with status indicator
   - Interactive 3D eye model (rotatable and scalable)
   - Real-time sensor readings (ARF, Deformation, Resistance)
   - Device connection status
   - Start/Pause scan controls

2. **Risk Analysis Page**
   - Camera integration for eye image capture
   - AI model-based risk calculation
   - Circular gauge showing glaucoma risk score
   - Risk parameters visualization
   - Risk factors (Age, Family History, Diabetes, Blood Pressure)
   - Personalized recommendations

3. **History Page**
   - Chronological list of all readings
   - Detailed view for each reading
   - Status indicators
   - Export functionality

4. **Settings Page**
   - Bluetooth device configuration
   - Reading interval settings
   - Dark mode toggle
   - Data management
   - Version information

5. **About Page**
   - Technology overview
   - Problem statement
   - Solution details
   - Key advantages
   - Contact information

## Technology Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **3D Visualization**: Custom Paint with vector_math
- **Camera**: camera package
- **Charts**: charts_flutter
- **Networking**: HTTP, Dio, flutter_bluetooth_serial
- **Storage**: SharedPreferences, SQLite
- **UI**: Material Design 3 with custom theming

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Physical device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd sonosight
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Configuration

The app simulates ESP8266 connections by default. To connect to actual hardware:

1. Implement Bluetooth pairing in `ESPProvider`
2. Configure device UUID in settings
3. Update data parsing logic for your specific hardware protocol

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── screens/                     # Page screens
│   ├── home_screen.dart        # Main screen with bottom nav
│   ├── dashboard_page.dart     # Dashboard with 3D eye
│   ├── risk_calculation_page.dart  # Risk analysis page
│   ├── history_page.dart       # Reading history
│   ├── settings_page.dart      # Settings
│   └── about_page.dart         # About page
├── widgets/                     # Reusable widgets
│   ├── eye_visualization.dart  # 3D reconstruction widget
│   ├── risk_gauge.dart prediction gauge
│   ├── metric_card.dart        # Metric display card
│   └── connection_status.dart  # Connection indicator
├── providers/                   # State management
│   ├── esp_provider.dart       # ESP8266 communication
│   ├── camera_provider.dart    # Camera functionality
│   └── risk_provider.dart      # Risk calculation
└── theme/                       # UI theme
    └── app_theme.dart          # Theme configuration
```

## Features Explained

### 1. 3D Eye Visualization

The interactive eye model:
- Draggable rotation
- Pinch-to-zoom scaling
- Wireframe/solid view toggle
- Real-time updates based on sensor data

### 2. AI Risk Assessment

Risk calculation considers:
- **IOP Level** (40% weight)
- **Age** (20% weight)
- **Blood Pressure** (15% weight)
- **Family History** (15% weight)
- **Diabetes** (10% weight)

### 3. ESP8266 Communication

Simulates real-time data stream:
- ARF (Acoustic Radiation Force) measurements
- Deformation calculations
- Resistance computation
- IOP derivation

## UI/UX Highlights

- **Modern Design**: Clean, professional interface
- **Color-coded Status**: Visual indicators for IOP levels
- **Interactive Elements**: Gesture-based controls
- **Dark Mode Support**: System-based theming
- **Responsive Layout**: Adapts to different screen sizes
- **Smooth Animations**: Fluid transitions and effects

## IOP Status Levels

- **Low** (< 12 mmHg): Blue indicator
- **Normal** (12-21 mmHg): Green indicator
- **Elevated** (21-30 mmHg): Orange indicator
- **High** (> 30 mmHg): Red indicator - Consult doctor

## Future Enhancements

- [ ] Integration with actual ESP8266 hardware
- [ ] Cloud sync for reading history
- [ ] Multi-language support
- [ ] Enhanced AI model integration
- [ ] Patient profile management
- [ ] Telemedicine integration
- [ ] Export reports (PDF)
- [ ] Offline mode

## License

All rights reserved - SonoSight Team

## Contact

For questions or support, please reach out to the SonoSight team.

---

**Note**: This is a demonstration app. Actual ESP8266 integration requires hardware implementation and proper calibration.

