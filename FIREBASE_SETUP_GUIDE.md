# 🔥 Firebase Realtime Database Setup Guide

## ✅ Configuration Complete

Your Firebase project is now configured to read sensor readings from Firebase Realtime Database!

### Firebase Project Details
- **Project ID**: `ocupulse`
- **Database URL**: `https://ocupulse-default-rtdb.asia-southeast1.firebasedatabase.app/`
- **Region**: Asia-Southeast1
- **Secret Key**: `nwvnkapq22lUHkfbIAqEZvansEBfXVec2JxUCN4R`

---

## 📊 Database Structure

Your sensor data should be written to Firebase in this exact structure:

```json
{
  "sensor_data": {
    "distance": 5.23,          // Distance from sensor (cm)
    "area": 0.000078,          // Probe contact area (m²)
    "arf": 0.523,              // Acoustic Radiation Force (N)
    "deformation": 0.0523,     // Deformation (m)
    "current_iop": 20.45,      // IOP value (mmHg)
    "avg_iop": 19.87,          // Average IOP (mmHg)
    "connected": true,          // Connection status
    "timestamp": 1698765432000, // Timestamp in milliseconds
    "device_id": "esp8266_001"  // Device identifier
  }
}
```

---

## 🔧 ESP8266 Arduino Code

### Option 1: Using HTTP REST API

```cpp
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <ArduinoJson.h>

// WiFi credentials
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// Firebase configuration  
const char* firebaseHost = "https://ocupulse-default-rtdb.asia-southeast1.firebasedatabase.app";
const char* firebaseAuth = "nwvnkapq22lUHkfbIAqEZvansEBfXVec2JxUCN4R";

// Sensor pins
const int triggerPin = D1;  // HC-SR04 Trigger
const int echoPin = D2;     // HC-SR04 Echo

void setup() {
  Serial.begin(115200);
  
  // Setup sensor pins
  pinMode(triggerPin, OUTPUT);
  pinMode(echoPin, INPUT);
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println("\nConnected to WiFi!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    // Read sensor data
    float distance = readDistance();
    float area = calculateArea(1.0); // Probe diameter = 1.0 cm
    float arf = calculateARF(distance);
    float deformation = calculateDeformation(arf);
    float iop = calculateIOP(deformation);
    
    // Send to Firebase
    sendToFirebase(distance, area, arf, deformation, iop);
    
    // Print to Serial
    Serial.println("=== Sensor Readings ===");
    Serial.print("Distance: "); Serial.print(distance); Serial.println(" cm");
    Serial.print("Area: "); Serial.print(area, 6); Serial.println(" m²");
    Serial.print("ARF: "); Serial.print(arf, 4); Serial.println(" N");
    Serial.print("Deformation: "); Serial.print(deformation, 6); Serial.println(" m");
    Serial.print("IOP: "); Serial.print(iop, 2); Serial.println(" mmHg");
    Serial.println("=====================");
  }
  
  delay(2000); // Send data every 2 seconds
}

float readDistance() {
  // Trigger ultrasonic pulse
  digitalWrite(triggerPin, LOW);
  delayMicroseconds(2);
  digitalWrite(triggerPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(triggerPin, LOW);
  
  // Read echo
  long duration = pulseIn(echoPin, HIGH);
  float distance = duration * 0.034 / 2; // Convert to cm
  
  return distance;
}

float calculateArea(float diameter) {
  // Area = π * r² (convert cm² to m²)
  float radius = diameter / 2.0;
  return 3.14159 * radius * radius / 10000.0;
}

float calculateARF(float distance) {
  // Simplified ARF calculation
  // In real application, use proper ultrasound physics
  return 0.5 + (distance * 0.01);
}

float calculateDeformation(float arf) {
  // Simplified deformation calculation
  // Deformation = ARF / Stiffness
  const float stiffness = 10.0; // Example value
  return arf / stiffness;
}

float calculateIOP(float deformation) {
  // IOP = 15 + (deformation * IOP_SCALE)
  const float iopScale = 100.0;
  return 15.0 + (deformation * iopScale);
}

void sendToFirebase(float distance, float area, float arf, float deformation, float iop) {
  WiFiClient client;
  HTTPClient http;
  
  // Build Firebase URL with auth
  String url = String(firebaseHost) + "/sensor_data.json?auth=" + String(firebaseAuth);
  
  // Create JSON payload
  StaticJsonDocument<512> doc;
  doc["distance"] = distance;
  doc["area"] = area;
  doc["arf"] = arf;
  doc["deformation"] = deformation;
  doc["current_iop"] = iop;
  doc["avg_iop"] = iop; // Will be calculated by app
  doc["connected"] = true;
  doc["timestamp"] = millis();
  doc["device_id"] = "esp8266_001";
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  // Send HTTP PUT request
  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");
  
  int httpResponseCode = http.PUT(jsonString);
  
  if (httpResponseCode > 0) {
    Serial.print("✅ Data sent to Firebase! Response: ");
    Serial.println(httpResponseCode);
  } else {
    Serial.print("❌ Error sending data: ");
    Serial.println(http.errorToString(httpResponseCode));
  }
  
  http.end();
}
```

### Option 2: Using Firebase Arduino Library

```cpp
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>

// WiFi credentials
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// Firebase credentials
#define FIREBASE_HOST "ocupulse-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_AUTH "nwvnkapq22lUHkfbIAqEZvansEBfXVec2JxUCN4R"

FirebaseData firebaseData;
FirebaseConfig config;
FirebaseAuth auth;

void setup() {
  Serial.begin(115200);
  
  // Connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected!");
  
  // Configure Firebase
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // Read sensors
  float distance = readDistance();
  float area = calculateArea(1.0);
  float arf = calculateARF(distance);
  float deformation = calculateDeformation(arf);
  float iop = calculateIOP(deformation);
  
  // Write to Firebase
  Firebase.setFloat(firebaseData, "/sensor_data/distance", distance);
  Firebase.setFloat(firebaseData, "/sensor_data/area", area);
  Firebase.setFloat(firebaseData, "/sensor_data/arf", arf);
  Firebase.setFloat(firebaseData, "/sensor_data/deformation", deformation);
  Firebase.setFloat(firebaseData, "/sensor_data/current_iop", iop);
  Firebase.setFloat(firebaseData, "/sensor_data/avg_iop", iop);
  Firebase.setBool(firebaseData, "/sensor_data/connected", true);
  Firebase.setInt(firebaseData, "/sensor_data/timestamp", millis());
  Firebase.setString(firebaseData, "/sensor_data/device_id", "esp8266_001");
  
  delay(2000);
}
```

---

## 🔐 Firebase Security Rules

Set these rules in Firebase Console > Realtime Database > Rules:

```json
{
  "rules": {
    "sensor_data": {
      ".read": true,
      ".write": true
    }
  }
}
```

**For production, use authenticated access:**

```json
{
  "rules": {
    "sensor_data": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

---

## 📱 How It Works

1. **ESP8266 writes data** to Firebase Realtime Database at `/sensor_data/`
2. **App listens** to changes in real-time
3. **Dashboard updates automatically** when new data arrives
4. **No polling needed** - Firebase pushes updates instantly!

---

## 🧪 Testing Without Hardware

You can manually write data to Firebase using the Firebase Console:

1. Go to: https://console.firebase.google.com/project/ocupulse/database
2. Click on **Realtime Database**
3. Add this data structure:

```json
{
  "sensor_data": {
    "distance": 5.5,
    "area": 0.00007854,
    "arf": 0.55,
    "deformation": 0.055,
    "current_iop": 20.5,
    "avg_iop": 19.8,
    "connected": true,
    "timestamp": 1698765432000,
    "device_id": "manual_test"
  }
}
```

4. Watch your app dashboard update in real-time! ✨

---

## 🐛 Troubleshooting

### Firebase Connection Issues
- Check if database URL is correct
- Verify secret key is valid
- Ensure database rules allow read/write

### ESP8266 Not Connecting
- Verify WiFi credentials
- Check Firebase host URL (no https:// prefix for Arduino library)
- Ensure stable internet connection

### Data Not Appearing in App
- Check Firebase Console to see if data is being written
- Verify database path is exactly `/sensor_data/`
- Restart the app after writing test data

---

## 📊 Monitor Your Data

**Firebase Console**: 
https://console.firebase.google.com/project/ocupulse/database

**Your App**: 
Will automatically display real-time sensor readings on the dashboard!

---

## 🎉 You're All Set!

Your SonoSight app is now ready to receive real-time sensor data from Firebase!

Upload the ESP8266 code, and watch the beautiful yellow-themed dashboard come alive with live IOP readings! 🟡👁️

