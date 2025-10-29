# SonoSight Setup Guide

## Quick Start

1. **Install Flutter** (if not already installed)
   ```bash
   # Check Flutter installation
   flutter doctor
   ```

2. **Get Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Platform-Specific Setup

### Android
- Ensure you have Android Studio installed
- Create an Android emulator or connect a physical device
- Enable Developer Options and USB Debugging on physical devices

### iOS (Mac only)
```bash
cd ios
pod install
cd ..
flutter run
```

## Expected Linter Errors

Initial linter errors about missing packages are expected and will be resolved after running `flutter pub get`.

## Features to Test

### Dashboard Page
- IOP readings update every 2 seconds
- 3D eye is interactive (drag to rotate, pinch to zoom)
- Connection status shows in top-right

### Risk Analysis Page  
- Tap camera icon to enable camera preview
- Capture image to trigger AI analysis
- Risk factors can be toggled
- Risk gauge updates based on inputs

### History Page
- View all readings in chronological order
- Tap any reading to see detailed view
- Latest reading is highlighted

## ESP8266 Integration

Currently, the app simulates ESP8266 data. To connect to actual hardware:

1. Update `lib/providers/esp_provider.dart`
2. Implement Bluetooth pairing logic
3. Parse incoming data according to your hardware protocol
4. Update device UUID in settings

## Troubleshooting

### Dependencies not found
```bash
flutter clean
flutter pub get
```

### Build errors
```bash
flutter doctor
flutter clean
flutter pub get
flutter run
```

### Camera not working
- Ensure camera permissions are granted
- Check Android manifest has camera permissions
- Test on physical device (emulators may not support camera)

### 3D eye not displaying
- Check if animation controller is working
- Verify device supports gestures
- Test on physical device for best performance

