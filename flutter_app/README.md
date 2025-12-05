# Stroke Guardian - Flutter Application

A comprehensive Flutter application for monitoring stroke risk using wearable ESP32-based sensors.

## Overview

Stroke Guardian is a mobile health monitoring application that receives real-time data from wearable sensors (MAX30102, MPU6050, AD8232) connected to an ESP32 microcontroller. The app displays vital signs, detects stroke risk indicators, and sends alerts to users and caregivers.

## Features

### 1. Authentication
- Email/Password authentication via Firebase
- User registration with profile creation
- Password reset functionality
- Secure session management

### 2. Real-time Dashboard
- Live monitoring of:
  - Heart Rate (BPM)
  - Blood Oxygen Saturation (SpO2)
  - Heart Rate Variability (HRV)
  - Motion Asymmetry
  - Body Temperature
- Stroke Risk Level indicator (0-3)
- Real-time ECG waveform visualization
- Connection status indicator

### 3. Historical Data & Analytics
- Interactive charts for all metrics
- Time-series data visualization
- Statistical analysis (average, min, max)
- Recent readings list
- Exportable data (coming soon)

### 4. Alert System
- Real-time push notifications
- Alert categorization (Critical, Warning, Caution, Info)
- Unread alert badges
- Alert details and history
- Emergency contact integration

### 5. User Profile
- Personal information management
- Device management
- Emergency contacts
- Medical ID
- Settings and preferences

## Technology Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Backend**: Firebase
  - Authentication
  - Realtime Database
  - Cloud Firestore
  - Cloud Messaging
- **Charts**: FL Chart, Syncfusion Flutter Charts
- **UI**: Material Design 3, Google Fonts
- **Notifications**: Firebase Cloud Messaging, Local Notifications

## Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)
- Firebase CLI
- Git

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/stroke-guardian.git
cd stroke-guardian/flutter_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "Stroke Guardian"
3. Enable the following services:
   - **Authentication** (Email/Password provider)
   - **Realtime Database**
   - **Cloud Firestore**
   - **Cloud Messaging**

#### Configure Firebase for Android

1. In Firebase Console, add an Android app
2. Register app with package name: `com.yourdomain.stroke_detection_app`
3. Download `google-services.json`
4. Place it in `android/app/` directory

5. Update `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

6. Update `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

#### Configure Firebase for iOS

1. In Firebase Console, add an iOS app
2. Register app with bundle ID: `com.yourdomain.strokeDetectionApp`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory

5. Update `ios/Podfile`:
```ruby
platform :ios, '13.0'
```

6. Run:
```bash
cd ios
pod install
cd ..
```

#### Firebase Realtime Database Rules

Set up security rules in Firebase Console > Realtime Database > Rules:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

#### Cloud Firestore Rules

Set up security rules in Firebase Console > Firestore > Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Update Configuration

Update the following in your code:

**lib/services/firebase_service.dart** - Already configured to use Firebase Auth

**lib/main.dart** - Already configured with Firebase initialization

### 5. Run the Application

#### Android
```bash
flutter run
```

#### iOS
```bash
flutter run
```

#### Web (Optional)
```bash
flutter run -d chrome
```

## Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── models/                   # Data models
│   │   ├── sensor_data.dart      # Sensor data structures
│   │   ├── alert_model.dart      # Alert data model
│   │   └── user_model.dart       # User profile model
│   ├── services/                 # Business logic & API
│   │   ├── firebase_service.dart # Firebase integration
│   │   └── notification_service.dart # Push notifications
│   ├── screens/                  # UI screens
│   │   ├── auth/                 # Authentication screens
│   │   ├── dashboard/            # Main dashboard
│   │   ├── history/              # Data history & charts
│   │   ├── alerts/               # Alert notifications
│   │   ├── profile/              # User profile
│   │   └── home/                 # Navigation wrapper
│   ├── widgets/                  # Reusable UI components
│   │   ├── sensor_card.dart      # Sensor display card
│   │   ├── risk_indicator_card.dart # Risk level display
│   │   ├── vital_signs_card.dart # Vital signs summary
│   │   ├── ecg_waveform_widget.dart # ECG visualization
│   │   ├── custom_button.dart    # Custom button widget
│   │   └── custom_text_field.dart # Custom input field
│   └── utils/                    # Utilities & constants
│       └── app_colors.dart       # Color palette
├── android/                      # Android platform code
├── ios/                          # iOS platform code
├── assets/                       # Images, fonts, etc.
└── pubspec.yaml                  # Dependencies
```

## Usage

### First Time Setup

1. **Create Account**
   - Launch the app
   - Tap "Sign Up"
   - Enter your name, email, and password
   - Agree to terms and conditions
   - Tap "Sign Up"

2. **Add Device**
   - Go to Profile > Connected Devices
   - Tap "Add Device"
   - Enter your ESP32 device ID (e.g., `ESP32_STROKE_001`)
   - Tap "Add"

3. **Configure Notifications**
   - Allow notification permissions when prompted
   - Critical alerts will be sent automatically

### Daily Monitoring

1. **View Dashboard**
   - Open the app
   - Dashboard shows real-time data from your device
   - Check the connection status indicator

2. **Review History**
   - Tap "History" tab
   - Select a metric to view (Heart Rate, SpO2, etc.)
   - Scroll through charts and statistics

3. **Check Alerts**
   - Tap "Alerts" tab
   - Review any warnings or critical notifications
   - Tap an alert for more details

### Emergency Procedures

If a HIGH RISK alert is received:

1. **Immediate Actions**
   - Check if symptoms are present:
     - Face drooping
     - Arm weakness
     - Speech difficulty
     - Time to call emergency

2. **Call Emergency Services**
   - Tap "Call Emergency" button in the alert
   - Or dial emergency number directly

3. **Contact Caregiver**
   - Emergency contacts are notified automatically (if configured)

## Customization

### Changing Theme Colors

Edit `lib/utils/app_colors.dart`:

```dart
static const Color primary = Color(0xFF2196F3); // Your primary color
```

### Adjusting Alert Thresholds

The thresholds are set in the ESP32 firmware. To modify them in the app display:

Edit `lib/widgets/risk_indicator_card.dart` for visual changes.

### Adding New Metrics

1. Update `lib/models/sensor_data.dart` to include new data fields
2. Modify `lib/services/firebase_service.dart` to handle new data
3. Create visualization widgets in `lib/widgets/`
4. Add to dashboard in `lib/screens/dashboard/dashboard_screen.dart`

## Troubleshooting

### Firebase Connection Issues

**Problem**: App cannot connect to Firebase

**Solutions**:
- Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) are in correct locations
- Check Firebase project configuration matches app package name
- Ensure internet connection is available
- Check Firebase Console for any service outages

### No Data Showing

**Problem**: Dashboard shows "No sensor data available"

**Solutions**:
- Verify ESP32 device is powered on and connected to WiFi
- Check device ID matches in both ESP32 code and Flutter app
- Verify Firebase Realtime Database rules allow read access
- Check Firebase Console to see if data is being received

### Notifications Not Working

**Problem**: Alerts not appearing as notifications

**Solutions**:
- Grant notification permissions in device settings
- Check Firebase Cloud Messaging is enabled
- Verify FCM token is generated (check logs)
- Test with a manual notification from Firebase Console

### Build Errors

**Problem**: App fails to build

**Solutions**:
- Run `flutter clean` then `flutter pub get`
- Update Flutter SDK: `flutter upgrade`
- Check minimum SDK versions (Android 21+, iOS 13+)
- Verify all dependencies are compatible

## Performance Optimization

### Reducing Data Usage

Adjust polling interval in ESP32 firmware:
```cpp
const unsigned long DATA_SEND_INTERVAL = 5000; // 5 seconds instead of 2
```

### Battery Optimization

- Enable battery optimization in Android settings
- Use app only when monitoring is needed
- Close app when not in use (background monitoring coming soon)

## Security Considerations

- Never share your Firebase credentials
- Use strong passwords for user accounts
- Keep the app updated to latest version
- Report security vulnerabilities to the development team

## Roadmap

### Upcoming Features

- [ ] Data export to PDF/CSV
- [ ] Multi-device support
- [ ] Family sharing and caregiver access
- [ ] ML-based risk prediction
- [ ] Integration with health platforms (Google Fit, Apple Health)
- [ ] Offline mode with local data storage
- [ ] Medication reminders
- [ ] Doctor appointment scheduling

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

This project is for educational and research purposes. Not intended for medical diagnosis.

## Support

For issues and questions:
- Create an issue on GitHub
- Email: support@strokeguardian.example.com
- Documentation: [Wiki](https://github.com/yourusername/stroke-guardian/wiki)

## Acknowledgments

- SparkFun for MAX30105 library
- Adafruit for MPU6050 library
- Firebase team for excellent backend services
- Flutter community for amazing widgets and packages

---

**⚠️ MEDICAL DISCLAIMER**: This application is for educational and preventive purposes only. It is NOT a medical diagnostic tool and should not be used as a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.
