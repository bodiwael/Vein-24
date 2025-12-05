/*
 * Stroke Detection System - ESP32 Firmware
 *
 * This firmware integrates MAX30102 (Heart Rate & SpO2),
 * MPU6050 (Motion/Asymmetry), and AD8232 (ECG) sensors
 * for early stroke risk detection.
 *
 * Data is sent to Firebase Realtime Database for monitoring via Flutter app.
 *
 * Hardware Connections:
 * MAX30102: SDA->GPIO21, SCL->GPIO22, VIN->3.3V, GND->GND
 * MPU6050:  SDA->GPIO21, SCL->GPIO22, VIN->3.3V, GND->GND (shared I2C)
 * AD8232:   LO+->GPIO4, LO-->GPIO2, OUTPUT->GPIO34 (ADC), VIN->3.3V, GND->GND
 */

#include <Wire.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include "MAX30105.h"
#include "heartRate.h"
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

// ===== WiFi Credentials =====
#define WIFI_SSID "YOUR_WIFI_SSID"          // Replace with your WiFi SSID
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"  // Replace with your WiFi password

// ===== Firebase Configuration =====
#define API_KEY "YOUR_FIREBASE_API_KEY"                    // Replace with your Firebase API Key
#define DATABASE_URL "YOUR_FIREBASE_DATABASE_URL"          // Replace with your Firebase Database URL
#define USER_EMAIL "YOUR_USER_EMAIL"                       // Firebase user email
#define USER_PASSWORD "YOUR_USER_PASSWORD"                 // Firebase user password

// ===== Device Configuration =====
#define DEVICE_ID "ESP32_STROKE_001"  // Unique device identifier
String userId = "user_001";           // Will be set after authentication

// ===== Pin Definitions =====
#define ECG_LO_PLUS 4    // AD8232 LO+ pin
#define ECG_LO_MINUS 2   // AD8232 LO- pin
#define ECG_OUTPUT 34    // AD8232 analog output (ADC1_CH6)

// ===== Sensor Objects =====
MAX30105 particleSensor;
Adafruit_MPU6050 mpu;

// ===== Firebase Objects =====
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// ===== Heart Rate Variables (MAX30102) =====
const byte RATE_SIZE = 4;
byte rates[RATE_SIZE];
byte rateSpot = 0;
long lastBeat = 0;
float beatsPerMinute = 0;
int beatAvg = 0;
long irValue = 0;
long redValue = 0;
float spo2 = 0;
bool fingerDetected = false;

// ===== Motion Variables (MPU6050) =====
float accelX, accelY, accelZ;
float gyroX, gyroY, gyroZ;
float temperature;
float motionAsymmetry = 0;

// ===== ECG Variables (AD8232) =====
int ecgValue = 0;
bool ecgLeadsOff = false;
float hrv = 0;  // Heart Rate Variability
int rrIntervals[10];
int rrIndex = 0;
unsigned long lastEcgBeat = 0;

// ===== Stroke Risk Detection Variables =====
bool atrialFibrillation = false;
bool lowSpO2Alert = false;
bool motionAsymmetryAlert = false;
int strokeRiskLevel = 0;  // 0: Normal, 1: Low, 2: Medium, 3: High

// ===== Timing Variables =====
unsigned long lastDataSend = 0;
unsigned long lastSensorRead = 0;
const unsigned long DATA_SEND_INTERVAL = 2000;    // Send data every 2 seconds
const unsigned long SENSOR_READ_INTERVAL = 100;   // Read sensors every 100ms

bool signupOK = false;

// ===== Function Declarations =====
void initWiFi();
void initFirebase();
void initSensors();
void readMAX30102();
void readMPU6050();
void readECG();
void detectStrokeRisk();
void sendDataToFirebase();
void sendAlert(String alertType, String message);

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("\n\n========================================");
  Serial.println("  Stroke Detection System - Starting   ");
  Serial.println("========================================\n");

  // Initialize WiFi
  initWiFi();

  // Initialize Firebase
  initFirebase();

  // Initialize Sensors
  initSensors();

  Serial.println("\n========================================");
  Serial.println("     System Ready - Monitoring...      ");
  Serial.println("========================================\n");
}

void loop() {
  unsigned long currentMillis = millis();

  // Read sensors at defined interval
  if (currentMillis - lastSensorRead >= SENSOR_READ_INTERVAL) {
    lastSensorRead = currentMillis;

    readMAX30102();
    readMPU6050();
    readECG();
    detectStrokeRisk();
  }

  // Send data to Firebase at defined interval
  if (currentMillis - lastDataSend >= DATA_SEND_INTERVAL) {
    lastDataSend = currentMillis;

    if (Firebase.ready() && signupOK) {
      sendDataToFirebase();
    }
  }
}

// ===== WiFi Initialization =====
void initWiFi() {
  Serial.print("Connecting to WiFi");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✓ WiFi Connected");
    Serial.print("  IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n✗ WiFi Connection Failed!");
  }
}

// ===== Firebase Initialization =====
void initFirebase() {
  Serial.println("\nInitializing Firebase...");

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // Sign in with user credentials
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  config.token_status_callback = tokenStatusCallback;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Wait for authentication
  int attempts = 0;
  while (!Firebase.ready() && attempts < 30) {
    Serial.print(".");
    delay(500);
    attempts++;
  }

  if (Firebase.ready()) {
    signupOK = true;
    userId = auth.token.uid.c_str();  // Get authenticated user ID
    Serial.println("\n✓ Firebase Connected");
    Serial.print("  User ID: ");
    Serial.println(userId);
  } else {
    Serial.println("\n✗ Firebase Connection Failed!");
  }
}

// ===== Sensor Initialization =====
void initSensors() {
  Serial.println("\nInitializing Sensors...");

  // Initialize I2C
  Wire.begin();

  // Initialize MAX30102
  if (particleSensor.begin(Wire, I2C_SPEED_FAST)) {
    Serial.println("✓ MAX30102 initialized");
    particleSensor.setup();
    particleSensor.setPulseAmplitudeRed(0x0A);
    particleSensor.setPulseAmplitudeGreen(0);
  } else {
    Serial.println("✗ MAX30102 initialization failed!");
  }

  // Initialize MPU6050
  if (mpu.begin()) {
    Serial.println("✓ MPU6050 initialized");
    mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
    mpu.setGyroRange(MPU6050_RANGE_500_DEG);
    mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
  } else {
    Serial.println("✗ MPU6050 initialization failed!");
  }

  // Initialize AD8232 ECG
  pinMode(ECG_LO_PLUS, INPUT);
  pinMode(ECG_LO_MINUS, INPUT);
  pinMode(ECG_OUTPUT, INPUT);
  Serial.println("✓ AD8232 ECG initialized");
}

// ===== Read MAX30102 Sensor =====
void readMAX30102() {
  irValue = particleSensor.getIR();
  redValue = particleSensor.getRed();

  // Check if finger is detected
  fingerDetected = (irValue > 50000);

  if (fingerDetected && checkForBeat(irValue)) {
    long delta = millis() - lastBeat;
    lastBeat = millis();

    beatsPerMinute = 60 / (delta / 1000.0);

    if (beatsPerMinute < 255 && beatsPerMinute > 20) {
      rates[rateSpot++] = (byte)beatsPerMinute;
      rateSpot %= RATE_SIZE;

      // Calculate average
      beatAvg = 0;
      for (byte x = 0; x < RATE_SIZE; x++)
        beatAvg += rates[x];
      beatAvg /= RATE_SIZE;
    }
  }

  // Calculate SpO2 (simplified - for accurate SpO2, use proper algorithm)
  if (fingerDetected && redValue > 0) {
    float ratio = (float)irValue / (float)redValue;
    spo2 = 110 - 25 * ratio;  // Simplified calculation
    spo2 = constrain(spo2, 0, 100);
  }
}

// ===== Read MPU6050 Sensor =====
void readMPU6050() {
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  accelX = a.acceleration.x;
  accelY = a.acceleration.y;
  accelZ = a.acceleration.z;

  gyroX = g.gyro.x;
  gyroY = g.gyro.y;
  gyroZ = g.gyro.z;

  temperature = temp.temperature;

  // Calculate motion asymmetry (simplified)
  // In a real implementation, compare left vs right side movements
  motionAsymmetry = abs(accelX) + abs(gyroX);
}

// ===== Read AD8232 ECG =====
void readECG() {
  // Check if leads are properly connected
  ecgLeadsOff = (digitalRead(ECG_LO_PLUS) == 1 || digitalRead(ECG_LO_MINUS) == 1);

  if (!ecgLeadsOff) {
    ecgValue = analogRead(ECG_OUTPUT);

    // Simple peak detection for HRV calculation
    if (ecgValue > 2000) {  // Threshold for R-peak detection
      unsigned long currentTime = millis();
      if (currentTime - lastEcgBeat > 300) {  // Debounce (min 200 BPM)
        int rrInterval = currentTime - lastEcgBeat;
        lastEcgBeat = currentTime;

        rrIntervals[rrIndex++] = rrInterval;
        rrIndex %= 10;

        // Calculate HRV (SDNN - Standard Deviation of NN intervals)
        float mean = 0;
        for (int i = 0; i < 10; i++) {
          mean += rrIntervals[i];
        }
        mean /= 10;

        float variance = 0;
        for (int i = 0; i < 10; i++) {
          variance += pow(rrIntervals[i] - mean, 2);
        }
        hrv = sqrt(variance / 10);
      }
    }
  }
}

// ===== Stroke Risk Detection Algorithm =====
void detectStrokeRisk() {
  strokeRiskLevel = 0;

  // 1. Atrial Fibrillation Detection (irregular heart rhythm)
  if (hrv > 100) {  // High HRV may indicate irregular rhythm
    atrialFibrillation = true;
    strokeRiskLevel += 2;
  } else {
    atrialFibrillation = false;
  }

  // 2. Low SpO2 Detection
  if (fingerDetected && spo2 < 90) {
    lowSpO2Alert = true;
    strokeRiskLevel += 1;
  } else {
    lowSpO2Alert = false;
  }

  // 3. Motion Asymmetry Detection
  if (motionAsymmetry > 15) {  // Threshold for asymmetry
    motionAsymmetryAlert = true;
    strokeRiskLevel += 1;
  } else {
    motionAsymmetryAlert = false;
  }

  // 4. Heart Rate Abnormalities
  if (beatAvg > 100 || beatAvg < 50) {
    strokeRiskLevel += 1;
  }

  // Determine risk level
  if (strokeRiskLevel >= 3) {
    strokeRiskLevel = 3;  // High Risk
    sendAlert("HIGH_RISK", "Critical stroke risk indicators detected!");
  } else if (strokeRiskLevel == 2) {
    strokeRiskLevel = 2;  // Medium Risk
  } else if (strokeRiskLevel == 1) {
    strokeRiskLevel = 1;  // Low Risk
  }
}

// ===== Send Data to Firebase =====
void sendDataToFirebase() {
  String path = "users/" + userId + "/devices/" + String(DEVICE_ID);

  // Create JSON object
  FirebaseJson json;

  // Timestamp
  json.set("timestamp", (unsigned long)millis());

  // MAX30102 Data
  json.set("heartRate/bpm", beatsPerMinute);
  json.set("heartRate/avgBpm", beatAvg);
  json.set("heartRate/irValue", (int)irValue);
  json.set("spo2/value", spo2);
  json.set("spo2/fingerDetected", fingerDetected);

  // MPU6050 Data
  json.set("motion/accelX", accelX);
  json.set("motion/accelY", accelY);
  json.set("motion/accelZ", accelZ);
  json.set("motion/gyroX", gyroX);
  json.set("motion/gyroY", gyroY);
  json.set("motion/gyroZ", gyroZ);
  json.set("motion/asymmetry", motionAsymmetry);
  json.set("temperature", temperature);

  // ECG Data
  json.set("ecg/value", ecgValue);
  json.set("ecg/leadsOff", ecgLeadsOff);
  json.set("ecg/hrv", hrv);

  // Stroke Risk Data
  json.set("strokeRisk/level", strokeRiskLevel);
  json.set("strokeRisk/atrialFib", atrialFibrillation);
  json.set("strokeRisk/lowSpO2", lowSpO2Alert);
  json.set("strokeRisk/motionAsymmetry", motionAsymmetryAlert);

  // Send to Firebase
  if (Firebase.RTDB.setJSON(&fbdo, path + "/currentData", &json)) {
    Serial.println("✓ Data sent to Firebase");
  } else {
    Serial.println("✗ Failed to send data: " + fbdo.errorReason());
  }

  // Also save to history (last 100 readings)
  String historyPath = path + "/history/" + String(millis());
  Firebase.RTDB.setJSON(&fbdo, historyPath, &json);

  // Print to Serial for debugging
  Serial.println("─────────────────────────────────────");
  Serial.printf("HR: %d BPM | SpO2: %.1f%% | Risk: %d\n", beatAvg, spo2, strokeRiskLevel);
  Serial.printf("Accel: X=%.2f Y=%.2f Z=%.2f\n", accelX, accelY, accelZ);
  Serial.printf("ECG: %d | HRV: %.2f\n", ecgValue, hrv);
  Serial.println("─────────────────────────────────────");
}

// ===== Send Alert to Firebase =====
void sendAlert(String alertType, String message) {
  String alertPath = "users/" + userId + "/alerts/" + String(millis());

  FirebaseJson alert;
  alert.set("type", alertType);
  alert.set("message", message);
  alert.set("timestamp", (unsigned long)millis());
  alert.set("deviceId", DEVICE_ID);
  alert.set("read", false);

  if (Firebase.RTDB.setJSON(&fbdo, alertPath, &alert)) {
    Serial.println("⚠ ALERT SENT: " + alertType);
  }
}
