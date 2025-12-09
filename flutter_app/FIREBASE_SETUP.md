# Firebase Setup for Flutter App

## 🔴 Fixing: "Failed to load FirebaseOptions from resource"

This guide will help you add Firebase configuration to your Flutter app.

---

## ✅ Step-by-Step Setup

### 1️⃣ Create/Open Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click on your existing project or create a new one
3. Project name: `StrokeGuardian` (or use existing)

### 2️⃣ Add Android App to Firebase

1. In your Firebase project, click the **Android icon** (or ⚙️ Settings > Add app)
2. Fill in the details:
   - **Android package name**: `com.yourdomain.stroke_detection_app`
   - **App nickname** (optional): Stroke Detection App
   - **Debug signing certificate SHA-1** (optional for now)
3. Click **Register app**

### 3️⃣ Download Configuration File

1. **Download `google-services.json`** (Firebase will provide this)
2. **Important**: Save this file!

### 4️⃣ Add Configuration File to Flutter Project

**Copy `google-services.json` to:**
```
flutter_app/android/app/google-services.json
```

**Full path should be:**
```
Vein-24/
└── flutter_app/
    └── android/
        └── app/
            └── google-services.json  ← Put file here!
```

### 5️⃣ Enable Firebase Services

In Firebase Console, enable these services:

#### Enable Authentication
1. Go to **Build > Authentication**
2. Click **Get Started**
3. Go to **Sign-in method** tab
4. Enable **Email/Password**
5. Click **Save**

#### Enable Realtime Database
1. Go to **Build > Realtime Database**
2. Click **Create Database**
3. Choose location (closest to you)
4. Start in **Test mode**
5. Click **Enable**

#### Set Database Rules
In Realtime Database > Rules:
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```
Click **Publish**.

#### Enable Cloud Messaging (Optional)
1. Go to **Build > Cloud Messaging**
2. Click **Get Started**
3. (Automatically enabled)

### 6️⃣ Verify File Structure

Your Android folder should look like this:
```
flutter_app/android/
├── app/
│   ├── google-services.json       ← Must be here!
│   ├── build.gradle
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml
│           └── kotlin/
└── build.gradle
```

### 7️⃣ Run Flutter App

```bash
cd flutter_app
flutter clean
flutter pub get
flutter run
```

---

## 📱 For iOS (Optional)

If you want to run on iOS:

### 1. Add iOS App in Firebase Console
1. Click the **iOS icon**
2. **iOS bundle ID**: `com.yourdomain.strokeDetectionApp`
3. Click **Register app**

### 2. Download `GoogleService-Info.plist`

### 3. Add to iOS Project
```
flutter_app/ios/Runner/GoogleService-Info.plist
```

### 4. Update Podfile
In `flutter_app/ios/Podfile`, set minimum iOS version:
```ruby
platform :ios, '13.0'
```

### 5. Install Pods
```bash
cd ios
pod install
cd ..
```

---

## ✅ Verification Checklist

After setup, verify:

- [ ] `google-services.json` is in `android/app/` folder
- [ ] File has valid JSON content (open and check)
- [ ] Firebase project has Authentication enabled
- [ ] Firebase project has Realtime Database enabled
- [ ] Database rules are set
- [ ] Package name in Firebase matches: `com.yourdomain.stroke_detection_app`
- [ ] Run `flutter clean` and `flutter pub get`
- [ ] App runs without Firebase errors

---

## 🔍 Troubleshooting

### Error Still Appears?

**Check 1: File Location**
```bash
# File should be at:
ls flutter_app/android/app/google-services.json
```
If file not found, you put it in wrong location!

**Check 2: File Content**
Open `google-services.json` and verify it has:
- `"project_info"` section
- `"client"` section
- `"package_name": "com.yourdomain.stroke_detection_app"`

**Check 3: Package Name Match**
In `google-services.json`, find:
```json
{
  "client": [
    {
      "client_info": {
        "android_client_info": {
          "package_name": "com.yourdomain.stroke_detection_app"
        }
      }
    }
  ]
}
```

Must match the package name in:
- `android/app/build.gradle` → `applicationId`
- Firebase Console → Android app package name

**Check 4: Clean and Rebuild**
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

---

## 📝 Quick Command Summary

```bash
# Navigate to flutter_app directory
cd flutter_app

# Clean project
flutter clean

# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Or build APK
flutter build apk
```

---

## 🎯 Expected Result

After successful setup, app should launch without errors:

```
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Installing build/app/outputs/flutter-apk/app.apk...
Syncing files to device...
Flutter run key commands.
r Hot reload.
R Hot restart.
```

You should see the login screen without any Firebase errors!

---

## 🆘 Still Having Issues?

Common mistakes:

1. **File in wrong location**
   - Should be: `android/app/google-services.json`
   - Not: `android/google-services.json`

2. **Wrong package name**
   - Firebase package name must match `build.gradle` applicationId

3. **Didn't enable Firebase services**
   - Must enable Authentication and Realtime Database

4. **Didn't run flutter clean**
   - Always run `flutter clean` after adding configuration

5. **Old cached data**
   - Delete `build` folder and rebuild

---

## 📞 Need Help?

If you're still stuck:

1. Check Firebase Console for any warnings
2. Verify `google-services.json` is valid JSON
3. Ensure package name matches everywhere
4. Try rebuilding from scratch with `flutter clean`

---

**That's it!** Once `google-services.json` is in place, the Firebase error will be resolved! 🎉
