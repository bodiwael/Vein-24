# ESP32 Stroke Detection System - Firmware

## Overview
This firmware integrates three sensors for early stroke risk detection:
- **MAX30102**: Heart rate, SpO2 monitoring
- **MPU6050**: Motion tracking and asymmetry detection
- **AD8232**: ECG and heart rate variability (HRV)

## Hardware Requirements

### Components
- ESP32 Development Board
- MAX30102 Pulse Oximeter and Heart Rate Sensor
- MPU6050 6-Axis Accelerometer and Gyroscope
- AD8232 ECG Module
- Jumper wires
- Power supply (5V or 3.3V)

### Wiring Diagram

#### MAX30102 Connections
```
MAX30102    ->    ESP32
VIN         ->    3.3V
GND         ->    GND
SDA         ->    GPIO 21 (I2C SDA)
SCL         ->    GPIO 22 (I2C SCL)
INT         ->    Not connected
```

#### MPU6050 Connections (Shared I2C Bus)
```
MPU6050     ->    ESP32
VCC         ->    3.3V
GND         ->    GND
SDA         ->    GPIO 21 (I2C SDA)
SCL         ->    GPIO 22 (I2C SCL)
```

#### AD8232 ECG Connections
```
AD8232      ->    ESP32
3.3V        ->    3.3V
GND         ->    GND
OUTPUT      ->    GPIO 34 (ADC1_CH6)
LO+         ->    GPIO 4
LO-         ->    GPIO 2
```

#### ECG Electrode Placement
- **RA (Right Arm)**: Right shoulder/upper chest
- **LA (Left Arm)**: Left shoulder/upper chest
- **RL (Right Leg/Reference)**: Lower right abdomen/hip

## Software Requirements

### Arduino IDE Setup

1. **Install Arduino IDE** (version 1.8.x or 2.x)
   - Download from: https://www.arduino.cc/en/software

2. **Install ESP32 Board Support**
   - Open Arduino IDE
   - Go to `File > Preferences`
   - Add to "Additional Board Manager URLs":
     ```
     https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
     ```
   - Go to `Tools > Board > Boards Manager`
   - Search for "ESP32" and install "esp32 by Espressif Systems"

3. **Install Required Libraries**

   Go to `Sketch > Include Library > Manage Libraries` and install:

   - **Firebase ESP32 Client** by Mobizt
     - Search: "Firebase ESP Client"
     - Version: Latest

   - **MAX3010x Library**
     - Search: "MAX30105"
     - Install: "SparkFun MAX3010x Pulse and Proximity Sensor Library"

   - **Adafruit MPU6050**
     - Search: "Adafruit MPU6050"
     - Install: "Adafruit MPU6050" (will also install dependencies)

   - **Adafruit Unified Sensor**
     - Should be installed automatically with MPU6050

### Library Versions (Tested)
```
- Firebase ESP32 Client: v4.3.x or higher
- SparkFun MAX3010x: v1.1.x
- Adafruit MPU6050: v2.2.x
- Adafruit Unified Sensor: v1.1.x
```

## Configuration

### 1. WiFi Configuration
Open `StrokeDetection_ESP32.ino` and update:
```cpp
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"
```

### 2. Firebase Configuration

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable **Realtime Database**
   - Go to `Build > Realtime Database`
   - Click "Create Database"
   - Start in "Test Mode" (for development)
4. Enable **Authentication**
   - Go to `Build > Authentication`
   - Enable "Email/Password" provider
   - Create a user account

#### Get Firebase Credentials
1. **API Key**:
   - Go to Project Settings (gear icon)
   - Under "General" tab, copy "Web API Key"

2. **Database URL**:
   - Go to Realtime Database
   - Copy the URL (e.g., `https://your-project.firebaseio.com/`)

3. **User Credentials**:
   - Use the email/password you created in Authentication

#### Update Firmware
```cpp
#define API_KEY "YOUR_FIREBASE_API_KEY"
#define DATABASE_URL "https://your-project.firebaseio.com/"
#define USER_EMAIL "user@example.com"
#define USER_PASSWORD "your_password"
```

### 3. Device ID Configuration
Update the device ID to uniquely identify your device:
```cpp
#define DEVICE_ID "ESP32_STROKE_001"
```

## Firebase Database Structure

The firmware creates the following structure in Firebase:
```
users/
  └── {userId}/
      ├── devices/
      │   └── {DEVICE_ID}/
      │       ├── currentData/
      │       │   ├── timestamp
      │       │   ├── heartRate/
      │       │   │   ├── bpm
      │       │   │   ├── avgBpm
      │       │   │   └── irValue
      │       │   ├── spo2/
      │       │   │   ├── value
      │       │   │   └── fingerDetected
      │       │   ├── motion/
      │       │   │   ├── accelX, accelY, accelZ
      │       │   │   ├── gyroX, gyroY, gyroZ
      │       │   │   └── asymmetry
      │       │   ├── ecg/
      │       │   │   ├── value
      │       │   │   ├── leadsOff
      │       │   │   └── hrv
      │       │   └── strokeRisk/
      │       │       ├── level (0-3)
      │       │       ├── atrialFib
      │       │       ├── lowSpO2
      │       │       └── motionAsymmetry
      │       └── history/
      │           └── {timestamp}/
      │               └── [same structure as currentData]
      └── alerts/
          └── {timestamp}/
              ├── type
              ├── message
              ├── timestamp
              ├── deviceId
              └── read
```

## Uploading the Firmware

1. **Connect ESP32** to your computer via USB
2. **Select Board**: `Tools > Board > ESP32 Dev Module`
3. **Select Port**: `Tools > Port > [Your ESP32 Port]`
4. **Upload**: Click the Upload button or `Sketch > Upload`
5. **Monitor**: Open Serial Monitor (`Tools > Serial Monitor`) at 115200 baud

## Operation

### Startup Sequence
1. WiFi connection established
2. Firebase authentication
3. Sensor initialization
4. Continuous monitoring begins

### Data Collection
- Sensors read every 100ms
- Data sent to Firebase every 2 seconds
- Alerts sent immediately when risk detected

### Stroke Risk Levels
- **0 (Normal)**: All parameters within normal range
- **1 (Low Risk)**: One risk indicator detected
- **2 (Medium Risk)**: Two risk indicators detected
- **3 (High Risk)**: Three or more risk indicators detected

### Risk Indicators
1. **Atrial Fibrillation**: Irregular heart rhythm (HRV > 100ms)
2. **Low SpO2**: Oxygen saturation < 90%
3. **Motion Asymmetry**: Significant left-right movement difference
4. **Heart Rate Abnormalities**: BPM > 100 or < 50

## Troubleshooting

### MAX30102 Not Found
- Check I2C connections (SDA, SCL)
- Verify power supply (3.3V)
- Try different I2C address if needed

### MPU6050 Not Found
- Ensure not conflicting with MAX30102 on I2C bus
- Check I2C address (default: 0x68)
- Verify power supply

### WiFi Connection Issues
- Verify SSID and password
- Check 2.4GHz network (ESP32 doesn't support 5GHz)
- Ensure signal strength is adequate

### Firebase Connection Issues
- Verify API key and database URL
- Check user credentials
- Ensure Realtime Database rules allow read/write
- Check internet connectivity

### ECG Noise/No Signal
- Verify electrode placement and skin contact
- Ensure cables are properly connected
- Check LO+ and LO- pins for lead-off detection

## Calibration

### SpO2 Calibration
The SpO2 calculation is simplified. For accurate readings:
1. Calibrate against a medical-grade pulse oximeter
2. Adjust the formula in `readMAX30102()` function
3. Consider using the SparkFun library's built-in SpO2 algorithm

### Motion Asymmetry Threshold
Adjust thresholds in `detectStrokeRisk()` based on:
- User's baseline movement patterns
- Testing with normal vs. impaired movement
- Clinical input from healthcare professionals

## Safety Notes

⚠️ **IMPORTANT**: This device is for **preventive warning only** and is **NOT a medical diagnostic tool**.

- Do not rely solely on this device for medical decisions
- Seek immediate medical attention if stroke symptoms occur
- Regular calibration and medical validation recommended
- Not FDA approved or medically certified

## License
This project is for educational and research purposes.

## Support
For issues and questions, please refer to the project documentation or contact the development team.
