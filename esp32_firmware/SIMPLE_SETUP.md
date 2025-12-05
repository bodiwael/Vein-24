# Firebase Simple Authentication Setup Guide

## Quick & Easy Setup - Just 2 Credentials Needed!

This guide shows you how to set up Firebase using **Database URL + Database Secret** - no complex authentication required!

---

## ✅ Step-by-Step Setup

### 1️⃣ Create Firebase Project
- [ ] Go to [Firebase Console](https://console.firebase.google.com/)
- [ ] Click "Create a project"
- [ ] Name your project (e.g., "StrokeGuardian")
- [ ] Click through the setup wizard
- [ ] Wait for project creation

### 2️⃣ Enable Realtime Database
- [ ] In your Firebase project, click **"Realtime Database"** in left sidebar
- [ ] Click **"Create Database"**
- [ ] Choose database location (select closest to you)
- [ ] Start in **"Test mode"** (we'll secure it in next step)
- [ ] Click **"Enable"**

### 3️⃣ Configure Database Security Rules

**Important:** These rules allow access with database secret authentication.

- [ ] In Realtime Database, go to **"Rules"** tab
- [ ] Replace the rules with:

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

- [ ] Click **"Publish"**

**What this does:** Allows read/write access to anyone authenticated with the database secret.

### 4️⃣ Get Your Two Credentials

You only need **2 things**:

#### 📍 **Credential 1: Database URL**

1. Go to **Realtime Database** in Firebase Console
2. Look at the top of the page
3. Copy the database URL

**Example:** `https://strokeguardian-abc123-default-rtdb.firebaseio.com/`

⚠️ **Make sure to include the trailing slash `/`**

---

#### 🔑 **Credential 2: Database Secret**

1. Click ⚙️ **Settings** icon (next to Project Overview)
2. Go to **"Project settings"**
3. Click **"Service accounts"** tab
4. Scroll down to **"Database secrets"** section
5. Click **"Show"** to reveal your secret
6. Click **"Copy"** to copy the secret key

**Example:** `xXxYyYzZz123AbC456DeF789GhI012JkL`

⚠️ **Keep this secret safe!** Don't share it publicly or commit it to GitHub.

---

### 5️⃣ Update ESP32 Code

Open `StrokeDetection_ESP32.ino` and update these 4 lines:

```cpp
// ===== WiFi Credentials =====
#define WIFI_SSID "YourWiFiName"
#define WIFI_PASSWORD "YourWiFiPassword"

// ===== Firebase Configuration =====
#define DATABASE_URL "https://strokeguardian-abc123-default-rtdb.firebaseio.com/"
#define DATABASE_SECRET "xXxYyYzZz123AbC456DeF789GhI012JkL"
```

**That's it!** No email, no password, no tokens!

---

### 6️⃣ Upload and Test

- [ ] Connect ESP32 via USB
- [ ] Select correct board in Arduino IDE: **Tools > Board > ESP32 Dev Module**
- [ ] Select correct port: **Tools > Port > [Your ESP32 Port]**
- [ ] Click **Upload** ⬆️
- [ ] Open **Serial Monitor** (115200 baud)
- [ ] Look for success message:

```
========================================
      Connecting to Firebase
========================================
Database URL: https://your-project.firebaseio.com/
Connecting.........

✓ Firebase Connected Successfully!
─────────────────────────────────────
  Database: https://your-project.firebaseio.com/
  User ID: user_001
  Device ID: ESP32_STROKE_001
─────────────────────────────────────
Testing database write access... OK
```

---

## 🎯 Configuration Template

Copy this template and fill in your values:

```cpp
// WiFi Configuration
#define WIFI_SSID "_________________"
#define WIFI_PASSWORD "_________________"

// Firebase Configuration
#define DATABASE_URL "_________________"
#define DATABASE_SECRET "_________________"

// Device Configuration (can keep defaults)
#define DEVICE_ID "ESP32_STROKE_001"
#define USER_ID "user_001"
```

---

## ✅ Verification

After uploading, check that everything works:

### 1. Check Serial Monitor Output

You should see:
```
✓ WiFi Connected
  IP Address: 192.168.1.xxx

✓ Firebase Connected Successfully!
  Database: https://your-project.firebaseio.com/

Testing database write access... OK

✓ MAX30102 initialized
✓ MPU6050 initialized
✓ AD8232 ECG initialized

System Ready - Monitoring...
```

### 2. Check Firebase Console

1. Go to **Realtime Database** in Firebase Console
2. Look for the path: `users/user_001/devices/ESP32_STROKE_001`
3. You should see real-time data appearing!

**Example Data Structure:**
```
users
  └── user_001
      ├── devices
      │   └── ESP32_STROKE_001
      │       ├── status: "online"
      │       └── currentData
      │           ├── heartRate
      │           │   ├── bpm: 72
      │           │   └── avgBpm: 71
      │           ├── spo2
      │           │   └── value: 98
      │           └── strokeRisk
      │               └── level: 0
      └── alerts
          └── (alerts appear here)
```

---

## ❌ Troubleshooting

### Problem: "Firebase Connection Failed"

**Check these:**

1. ✅ **Database URL is correct**
   - Format: `https://your-project-default-rtdb.firebaseio.com/`
   - Must include `https://` and trailing `/`

2. ✅ **Database Secret is valid**
   - Copy from: Project Settings > Service accounts > Database secrets
   - No extra spaces or characters
   - Case-sensitive!

3. ✅ **Database rules allow access**
   - Rules should be:
   ```json
   {
     "rules": {
       ".read": "auth != null",
       ".write": "auth != null"
     }
   }
   ```

4. ✅ **WiFi is connected**
   - Check for "✓ WiFi Connected" message
   - ESP32 only works with 2.4GHz networks (not 5GHz)

5. ✅ **Internet connection works**
   - Make sure router has internet access
   - Check firewall isn't blocking Firebase

---

### Problem: "Testing database write access... Failed"

**This usually means:**

1. **Wrong database rules** - Make sure you published the correct rules
2. **Invalid database secret** - Re-copy the secret from Firebase Console
3. **Database URL doesn't match** - Verify the URL exactly matches your database

**Fix:**
- Go to Firebase Console > Realtime Database > Rules
- Verify rules allow authenticated access
- Click "Publish" to apply

---

## 🔒 Security Notes

### Production Security

For production use, tighten your security rules:

```json
{
  "rules": {
    "users": {
      "$userId": {
        ".read": "auth != null && $userId === auth.uid",
        ".write": "auth != null && $userId === auth.uid"
      }
    }
  }
}
```

### Best Practices

1. **Never share your database secret publicly**
   - Don't commit to GitHub
   - Don't share in forums or chat

2. **Rotate secrets periodically**
   - Generate new secret every few months
   - Update ESP32 code with new secret

3. **Monitor database usage**
   - Check Firebase Console > Usage
   - Watch for unexpected activity

4. **Use environment variables for production**
   - Don't hardcode secrets in production code

---

## 📊 What You Should See

### In Serial Monitor:
```
========================================
  Stroke Detection System - Starting
========================================

Connecting to WiFi.......
✓ WiFi Connected
  IP Address: 192.168.1.100

========================================
      Connecting to Firebase
========================================
Database URL: https://your-project.firebaseio.com/
Connecting....

✓ Firebase Connected Successfully!
─────────────────────────────────────
  Database: https://your-project.firebaseio.com/
  User ID: user_001
  Device ID: ESP32_STROKE_001
─────────────────────────────────────
Testing database write access... OK

Initializing Sensors...
✓ MAX30102 initialized
✓ MPU6050 initialized
✓ AD8232 ECG initialized

========================================
     System Ready - Monitoring...
========================================

─────────────────────────────────────
HR: 72 BPM | SpO2: 98.0% | Risk: 0
Accel: X=0.12 Y=-0.05 Z=9.81
ECG: 512 | HRV: 45.23
─────────────────────────────────────
✓ Data sent to Firebase
```

### In Firebase Console:
You'll see data updating every 2 seconds under:
- `users/user_001/devices/ESP32_STROKE_001/currentData`
- `users/user_001/devices/ESP32_STROKE_001/history/{timestamp}`

---

## 🎉 Success!

If you see:
- ✅ WiFi connected
- ✅ Firebase connected
- ✅ Database write test passed
- ✅ Sensors initialized
- ✅ Data appearing in Firebase Console

**You're all set!** Your ESP32 is now sending stroke detection data to Firebase! 🚀

---

## 🆘 Need More Help?

Check the detailed [ESP32 README](README.md) for:
- Hardware wiring diagrams
- Sensor troubleshooting
- Advanced configuration options

---

**Simple. Secure. No complications!** 🎯
