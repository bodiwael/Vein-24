# Stroke Guardian - Early Stroke Risk Detection System

<div align="center">

![Stroke Guardian Logo](https://via.placeholder.com/150)

**A Low-Cost Wearable Early Stroke Risk Detection System**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![ESP32](https://img.shields.io/badge/ESP32-Compatible-green.svg)](https://www.espressif.com/en/products/socs/esp32)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)

</div>

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Hardware Components](#hardware-components)
- [Software Components](#software-components)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Usage](#usage)
- [Medical Disclaimer](#medical-disclaimer)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

Stroke Guardian is a comprehensive early stroke risk detection system designed to provide affordable, accessible, and continuous health monitoring. The system combines wearable biomedical sensors with an ESP32 microcontroller and a Flutter mobile application to detect early indicators of stroke risks such as atrial fibrillation, oxygen desaturation, and unilateral muscle weakness.

### Target Population

This system is particularly suitable for:
- Individuals with high stroke risk factors
- Elderly populations
- Regions with limited access to healthcare (e.g., Egypt)
- Home health monitoring scenarios
- Preventive health management

### Key Objectives

1. **Early Detection**: Identify stroke risk indicators before symptoms appear
2. **Affordability**: Use low-cost components accessible in developing regions
3. **Accessibility**: Provide continuous monitoring without hospital visits
4. **Real-time Alerts**: Immediate notification to users and caregivers
5. **Data-Driven**: Historical tracking for better health management

## ✨ Features

### Hardware System (ESP32 + Sensors)

- ✅ Real-time vital signs monitoring
  - Heart rate and heart rate variability (HRV)
  - Blood oxygen saturation (SpO2)
  - Body temperature
  - ECG signal monitoring
  - Motion and asymmetry detection

- ✅ Stroke risk assessment
  - Atrial fibrillation detection
  - Low oxygen saturation alerts
  - Movement asymmetry detection
  - Multi-factor risk level calculation

- ✅ Wireless connectivity
  - WiFi integration for data transmission
  - Firebase real-time database sync
  - Low power consumption design

### Mobile Application (Flutter)

- ✅ User authentication and profiles
- ✅ Real-time dashboard with live data
- ✅ ECG waveform visualization
- ✅ Historical data with interactive charts
- ✅ Push notifications for alerts
- ✅ Emergency contact management
- ✅ Multi-device support
- ✅ Cross-platform (Android & iOS)

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interaction                        │
│                   (Flutter Mobile App)                       │
│  ┌─────────────┬─────────────┬─────────────┬─────────────┐ │
│  │  Dashboard  │   History   │   Alerts    │   Profile   │ │
│  └─────────────┴─────────────┴─────────────┴─────────────┘ │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ Firebase Services
                            │ (Realtime DB, Auth, FCM)
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    ESP32 Microcontroller                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            Stroke Risk Detection Algorithm            │  │
│  │  - Atrial Fibrillation Detection                     │  │
│  │  - SpO2 Level Monitoring                             │  │
│  │  - Motion Asymmetry Analysis                         │  │
│  │  - Heart Rate Abnormality Detection                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                                 │
│  ┌─────────────┬──────────┴──────────┬──────────────────┐  │
│  │  MAX30102   │       MPU6050       │     AD8232       │  │
│  │  (HR, SpO2) │  (Motion, Accel)    │     (ECG)        │  │
│  └─────────────┴─────────────────────┴──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Hardware Components

| Component | Purpose | Specifications |
|-----------|---------|----------------|
| **ESP32** | Main microcontroller | WiFi, BLE, dual-core, 240MHz |
| **MAX30102** | Heart rate & SpO2 sensor | I2C interface, 3.3V |
| **MPU6050** | Motion & acceleration sensor | 6-axis, I2C interface |
| **AD8232** | ECG sensor module | Analog output, 3.3V |
| **Battery** | Power supply | Li-Po 3.7V, 1000mAh+ |

### Cost Breakdown (Approximate)

| Item | Estimated Cost (USD) |
|------|---------------------|
| ESP32 Development Board | $5 - $10 |
| MAX30102 Sensor | $5 - $8 |
| MPU6050 Sensor | $2 - $5 |
| AD8232 ECG Module | $15 - $25 |
| Battery & Accessories | $5 - $10 |
| **Total System Cost** | **$32 - $58** |

## 💻 Software Components

### ESP32 Firmware

- **Platform**: Arduino IDE / PlatformIO
- **Language**: C++
- **Libraries**:
  - Firebase ESP32 Client
  - SparkFun MAX3010x
  - Adafruit MPU6050
  - Wire (I2C)

### Flutter Mobile App

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **Key Packages**:
  - firebase_core, firebase_auth
  - firebase_database, cloud_firestore
  - firebase_messaging
  - fl_chart, syncfusion_flutter_charts
  - google_fonts, provider

## 🚀 Getting Started

### Prerequisites

**Hardware:**
- ESP32 development board
- MAX30102, MPU6050, AD8232 sensors
- Jumper wires and breadboard
- USB cable for programming
- (Optional) Battery and charging module

**Software:**
- Arduino IDE 1.8+ or 2.0+
- Flutter SDK 3.0+
- Firebase account (free tier)
- Android Studio / Xcode
- Git

### Quick Start Guide

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/stroke-guardian.git
   cd stroke-guardian
   ```

2. **Set Up Firebase**
   - Create a Firebase project
   - Enable Authentication, Realtime Database, and Cloud Messaging
   - Download configuration files

3. **Configure ESP32**
   - Follow instructions in `esp32_firmware/README.md`
   - Update WiFi and Firebase credentials
   - Upload firmware to ESP32

4. **Set Up Flutter App**
   - Follow instructions in `flutter_app/README.md`
   - Configure Firebase for Android/iOS
   - Run the app

## 📦 Installation

### ESP32 Firmware Setup

Detailed instructions: [ESP32 Firmware README](esp32_firmware/README.md)

```bash
# 1. Install required Arduino libraries
# 2. Update configuration in StrokeDetection_ESP32.ino
# 3. Connect ESP32 via USB
# 4. Upload firmware
```

### Flutter App Setup

Detailed instructions: [Flutter App README](flutter_app/README.md)

```bash
cd flutter_app
flutter pub get
flutter run
```

## 📱 Usage

### For End Users

1. **Wearing the Device**
   - Attach MAX30102 sensor to index finger
   - Place MPU6050 on wrist or arm
   - Position AD8232 electrodes on chest
   - Power on the ESP32 device

2. **Using the Mobile App**
   - Create an account and log in
   - Add your device using the device ID
   - Monitor real-time data on the dashboard
   - Review history and trends
   - Respond to alerts promptly

3. **Interpreting Alerts**
   - **Green (Normal)**: All parameters within normal range
   - **Yellow (Low Risk)**: One risk indicator detected
   - **Orange (Medium Risk)**: Two risk indicators detected
   - **Red (High Risk)**: Three or more risk indicators detected

### For Developers

See detailed documentation in:
- ESP32 Development Guide: `esp32_firmware/README.md`
- Flutter Development Guide: `flutter_app/README.md`

## ⚕️ Medical Disclaimer

**⚠️ IMPORTANT NOTICE**

This device is designed for **educational and preventive purposes only**. It is **NOT** intended for:
- Medical diagnosis
- Treatment of medical conditions
- Replacement of professional medical care
- Emergency medical situations

### Critical Guidelines

1. **Not FDA Approved**: This device has not been evaluated or approved by the FDA or any medical regulatory body

2. **Accuracy Limitations**: Sensor readings may not be medically accurate and should not be used for clinical decisions

3. **Emergency Response**: In case of stroke symptoms (F.A.S.T. - Face drooping, Arm weakness, Speech difficulty, Time to call emergency), immediately call emergency services

4. **Professional Consultation**: Always consult with healthcare professionals for medical advice, diagnosis, or treatment

5. **Not a Substitute**: This device supplements but does not replace regular medical checkups and professional monitoring

### Stroke Warning Signs (F.A.S.T.)

- **F**ace: Ask the person to smile. Does one side of the face droop?
- **A**rms: Ask the person to raise both arms. Does one arm drift downward?
- **S**peech: Ask the person to repeat a simple phrase. Is speech slurred or strange?
- **T**ime: If you observe any of these signs, call emergency services immediately

## 📊 Project Structure

```
Vein-24/
├── esp32_firmware/              # ESP32 firmware code
│   ├── StrokeDetection_ESP32.ino
│   └── README.md
├── flutter_app/                 # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   ├── services/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── utils/
│   ├── android/
│   ├── ios/
│   ├── pubspec.yaml
│   └── README.md
├── docs/                        # Documentation
└── README.md                    # This file
```

## 🤝 Contributing

We welcome contributions from the community!

### Ways to Contribute

- 🐛 Report bugs and issues
- 💡 Suggest new features
- 📝 Improve documentation
- 🔧 Submit bug fixes
- ✨ Add new features
- 🧪 Write tests

## 📄 License

This project is for educational and research purposes.

## 🙏 Acknowledgments

- **SparkFun Electronics** for MAX30105 library
- **Adafruit Industries** for MPU6050 library
- **Firebase Team** for excellent backend services
- **Flutter Community** for amazing framework and packages
- **Open Source Contributors** worldwide

## 📞 Contact & Support

For issues and questions, please create an issue on GitHub.

---

<div align="center">

**Made with ❤️ for accessible healthcare**

</div>