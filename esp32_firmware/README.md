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

The ESP32 uses **Email/Password Authentication** to securely connect to Firebase. Follow these steps carefully:

#### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter a project name (e.g., "StrokeGuardian")
4. Accept terms and click "Continue"
5. Disable Google Analytics (optional) and click "Create project"
6. Wait for project creation, then click "Continue"

#### Step 2: Enable Authentication with Email/Password
1. In Firebase Console, click on **"Authentication"** in the left sidebar
2. Click **"Get Started"** if it's your first time
3. Go to **"Sign-in method"** tab
4. Click on **"Email/Password"**
5. Toggle **"Enable"** to ON
6. Click **"Save"**

#### Step 3: Create a User Account for ESP32
⚠️ **Important**: The ESP32 needs a user account to authenticate with Firebase.

1. Still in **Authentication**, go to the **"Users"** tab
2. Click **"Add user"** button
3. Enter:
   - **Email**: `esp32@yourdomain.com` (or any email you prefer)
   - **Password**: Create a strong password (min 6 characters)
4. Click **"Add user"**
5. **Save these credentials** - you'll need them for the ESP32 code

**Example:**
```
Email: esp32device@gmail.com
Password: MySecurePass123!
```

#### Step 4: Enable Realtime Database
1. In Firebase Console, click on **"Realtime Database"** in the left sidebar
2. Click **"Create Database"**
3. Select a database location (choose closest to you)
4. Start in **"Test mode"** for development (you can change this later)
5. Click **"Enable"**

#### Step 5: Set Database Security Rules (Important!)
1. In Realtime Database, go to **"Rules"** tab
2. Replace the rules with:
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
3. Click **"Publish"**

This ensures only authenticated users can read/write their own data.

#### Step 6: Get Firebase Credentials

**1. Get API Key:**
   - Click on the **⚙️ Settings icon** (gear icon next to "Project Overview")
   - Go to **"Project settings"**
   - Scroll down to **"Your apps"** section
   - Under **"Web API Key"**, copy the key
   - Example: `AIzaSyD1x2y3z4a5b6c7d8e9f0g1h2i3j4k5l6m`

**2. Get Database URL:**
   - Go to **"Realtime Database"** in sidebar
   - Look at the top of the page for the database URL
   - It should look like: `https://your-project-default-rtdb.firebaseio.com/`
   - Copy the entire URL including `https://` and trailing `/`

**3. Use Your User Credentials:**
   - Email: The email you created in Step 3
   - Password: The password you created in Step 3

#### Step 7: Update ESP32 Firmware

Open `StrokeDetection_ESP32.ino` and update these lines:

```cpp
// ===== Firebase Configuration =====
#define API_KEY "AIzaSyD1x2y3z4a5b6c7d8e9f0g1h2i3j4k5l6m"  // Your Web API Key
#define DATABASE_URL "https://strokeguardian-default-rtdb.firebaseio.com/"  // Your Database URL
#define USER_EMAIL "esp32device@gmail.com"  // Email you created in Authentication
#define USER_PASSWORD "MySecurePass123!"    // Password for that email account
```

**Example Configuration:**
```cpp
// Real example (replace with your own!)
#define API_KEY "AIzaSyBxC2yD3zE4aF5bG6cH7dI8eJ9fK0gL1h"
#define DATABASE_URL "https://stroke-guardian-abc123.firebaseio.com/"
#define USER_EMAIL "esp32device@gmail.com"
#define USER_PASSWORD "SecurePassword123"
```

⚠️ **Security Note:**
- Never share your API key or credentials publicly
- Use different credentials for development and production
- Change default passwords to strong, unique passwords

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

### Firebase Authentication Issues

**Problem**: ESP32 shows "✗ Firebase Authentication Failed!"

**Solutions**:

1. **Verify Email/Password Provider is Enabled**
   - Go to Firebase Console > Authentication > Sign-in method
   - Ensure "Email/Password" is **Enabled**
   - If not, enable it and click Save

2. **Check User Account Exists**
   - Go to Firebase Console > Authentication > Users
   - Verify the email you're using in the code exists in the users list
   - If not, click "Add user" and create the account

3. **Verify Credentials are Correct**
   - Double-check the email and password in your code
   - Make sure there are no typos or extra spaces
   - Password is case-sensitive!
   ```cpp
   #define USER_EMAIL "esp32device@gmail.com"  // Must match Firebase exactly
   #define USER_PASSWORD "YourPassword123"     // Case-sensitive!
   ```

4. **Check API Key and Database URL**
   - Verify your API Key is correct (from Project Settings)
   - Ensure Database URL ends with `.firebaseio.com/` (with trailing slash)
   - Example: `https://your-project-default-rtdb.firebaseio.com/`

5. **Test User Credentials Manually**
   - Try logging into Firebase Console with the same email/password
   - If it doesn't work, reset the password in Authentication > Users

6. **Check Serial Monitor Output**
   When authentication fails, the ESP32 will show detailed error messages:
   ```
   ✗ Firebase Authentication Failed!
   ─────────────────────────────────────
     Possible reasons:
     1. Invalid email or password
     2. User account doesn't exist in Firebase
     3. Internet connection issues
     4. Incorrect API key or Database URL
     5. Email/Password authentication not enabled
   ```

7. **Verify Internet Connection**
   - Make sure ESP32 successfully connected to WiFi
   - Look for "✓ WiFi Connected" message
   - Check that you can access Firebase from your network

8. **Database Rules Configuration**
   - Ensure your Realtime Database rules allow authenticated access:
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

9. **Check Firebase Quota Limits**
   - Firebase free tier has usage limits
   - Check Firebase Console > Usage for any quota exceeded warnings

**Expected Success Output:**
```
========================================
  Initializing Firebase Authentication
========================================
Authenticating user: esp32device@gmail.com
Waiting for authentication.............

✓ Firebase Authentication Successful!
─────────────────────────────────────
  Email: esp32device@gmail.com
  User ID: xXxYyYzZz123AbC456
  Token Type: id_token
─────────────────────────────────────
Testing database connection... OK
```

### Firebase Connection Issues
- Verify API key and database URL format
- Check user credentials match Firebase exactly
- Ensure Realtime Database rules allow authenticated read/write
- Verify internet connectivity and WiFi connection

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
