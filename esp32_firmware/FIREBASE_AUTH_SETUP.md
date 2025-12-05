# Firebase Email/Password Authentication Setup Guide

## Quick Setup Checklist

Follow these steps to set up Firebase authentication for your ESP32 Stroke Guardian device.

## ✅ Step-by-Step Setup

### 1️⃣ Create Firebase Project
- [ ] Go to [Firebase Console](https://console.firebase.google.com/)
- [ ] Click "Create a project"
- [ ] Name: `StrokeGuardian` (or your preferred name)
- [ ] Click through setup wizard
- [ ] Wait for project creation

### 2️⃣ Enable Email/Password Authentication
- [ ] Open your Firebase project
- [ ] Click **Authentication** in left sidebar
- [ ] Click **Get Started**
- [ ] Go to **Sign-in method** tab
- [ ] Click **Email/Password**
- [ ] Toggle to **Enable**
- [ ] Click **Save**

### 3️⃣ Create User Account for ESP32
- [ ] Go to **Authentication > Users** tab
- [ ] Click **Add user**
- [ ] Enter credentials:
  - Email: `esp32device@gmail.com` (example)
  - Password: `YourSecurePassword123!`
- [ ] Click **Add user**
- [ ] **SAVE THESE CREDENTIALS** - you'll need them!

### 4️⃣ Enable Realtime Database
- [ ] Click **Realtime Database** in left sidebar
- [ ] Click **Create Database**
- [ ] Choose database location (closest to you)
- [ ] Start in **Test mode**
- [ ] Click **Enable**

### 5️⃣ Configure Database Security Rules
- [ ] In Realtime Database, go to **Rules** tab
- [ ] Paste this configuration:
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
- [ ] Click **Publish**

### 6️⃣ Get Your Credentials

#### API Key:
- [ ] Click ⚙️ **Settings** (next to Project Overview)
- [ ] Go to **Project settings**
- [ ] Copy **Web API Key**
- Example: `AIzaSyD1x2y3z4a5b6c7d8e9f0g1h2i3j4k5l6m`

#### Database URL:
- [ ] Go to **Realtime Database**
- [ ] Copy the database URL from top of page
- Example: `https://strokeguardian-default-rtdb.firebaseio.com/`
- ⚠️ **Include the trailing slash `/`**

#### User Credentials:
- [ ] Email: From Step 3
- [ ] Password: From Step 3

### 7️⃣ Update ESP32 Code

Open `StrokeDetection_ESP32.ino` and update:

```cpp
// ===== WiFi Credentials =====
#define WIFI_SSID "YourWiFiName"
#define WIFI_PASSWORD "YourWiFiPassword"

// ===== Firebase Configuration =====
#define API_KEY "AIzaSy___YOUR_API_KEY_HERE___"
#define DATABASE_URL "https://your-project-default-rtdb.firebaseio.com/"
#define USER_EMAIL "esp32device@gmail.com"
#define USER_PASSWORD "YourSecurePassword123!"
```

### 8️⃣ Upload and Test
- [ ] Connect ESP32 via USB
- [ ] Select correct board and port in Arduino IDE
- [ ] Click Upload
- [ ] Open Serial Monitor (115200 baud)
- [ ] Look for success message:

```
✓ Firebase Authentication Successful!
  Email: esp32device@gmail.com
  User ID: xXxYyYzZz123AbC456
```

---

## 📝 Configuration Template

Copy and fill out this template:

```cpp
// Your Configuration
#define WIFI_SSID "_________________"
#define WIFI_PASSWORD "_________________"
#define API_KEY "_________________"
#define DATABASE_URL "_________________"
#define USER_EMAIL "_________________"
#define USER_PASSWORD "_________________"
#define DEVICE_ID "ESP32_STROKE_001"
```

---

## 🔍 Verification Steps

After uploading, verify everything works:

1. **Check WiFi Connection**
   ```
   ✓ WiFi Connected
     IP Address: 192.168.1.xxx
   ```

2. **Check Firebase Authentication**
   ```
   ✓ Firebase Authentication Successful!
     Email: your-email@example.com
     User ID: xxxxxxxxxxxxxxxxxx
   ```

3. **Check Database Connection**
   ```
   Testing database connection... OK
   ```

4. **Check Data Streaming**
   - Go to Firebase Console > Realtime Database
   - Look for: `users > {your-user-id} > devices > ESP32_STROKE_001`
   - You should see real-time data appearing!

---

## ❌ Common Errors and Fixes

### Error: "Firebase Authentication Failed"

**Possible Causes:**
1. ❌ Email/Password not enabled in Firebase Console
   - ✅ Fix: Enable it in Authentication > Sign-in method

2. ❌ User account doesn't exist
   - ✅ Fix: Create user in Authentication > Users

3. ❌ Wrong email or password
   - ✅ Fix: Double-check credentials, they're case-sensitive!

4. ❌ Wrong API key
   - ✅ Fix: Copy correct key from Project Settings

5. ❌ Wrong Database URL
   - ✅ Fix: Copy URL from Realtime Database, include trailing `/`

### Error: "WiFi Connection Failed"

**Possible Causes:**
1. ❌ Wrong WiFi SSID or password
   - ✅ Fix: Verify credentials

2. ❌ Using 5GHz WiFi
   - ✅ Fix: ESP32 only supports 2.4GHz networks

3. ❌ Weak signal
   - ✅ Fix: Move ESP32 closer to router

---

## 🔒 Security Best Practices

1. **Use Strong Passwords**
   - Minimum 12 characters
   - Mix of letters, numbers, symbols
   - Don't use common passwords

2. **Never Share Credentials**
   - Don't commit credentials to GitHub
   - Don't share API keys publicly
   - Use environment variables for production

3. **Update Database Rules**
   - Move from Test mode to Production mode
   - Use proper authentication rules
   - Restrict access by user ID

4. **Rotate Credentials Regularly**
   - Change passwords periodically
   - Regenerate API keys if compromised
   - Monitor Firebase usage for anomalies

---

## 📞 Need Help?

If you're still having issues:

1. Check the detailed [ESP32 README](README.md)
2. Review Firebase Console for error messages
3. Check Serial Monitor output at 115200 baud
4. Verify all steps were completed exactly as described

---

## ✅ Success Checklist

Before considering setup complete:

- [ ] WiFi connects successfully
- [ ] Firebase authentication succeeds
- [ ] Database connection test passes
- [ ] Data appears in Firebase Console under `users/{uid}/devices/{DEVICE_ID}`
- [ ] Sensor readings update every 2 seconds
- [ ] No error messages in Serial Monitor

---

**You're all set!** 🎉 Your ESP32 is now authenticated and sending data to Firebase!
