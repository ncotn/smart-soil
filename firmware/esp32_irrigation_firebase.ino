/*
  ========================================================================
  FYP: Smart Irrigation & Soil Moisture Monitoring System
  ESP32 Firmware with Capacitive Soil Moisture Sensor & Firebase Sync
  ========================================================================
  Hardware Connections:
  - Capacitive Soil Moisture Sensor VCC -> ESP32 3.3V
  - Capacitive Soil Moisture Sensor GND -> ESP32 GND
  - Capacitive Soil Moisture Sensor AOUT -> ESP32 GPIO 34 (ADC1)
  - (Optional) Relay IN Pin -> ESP32 GPIO 23 (For water pump)
  ========================================================================
*/

#include <WiFi.h>
#include <HTTPClient.h>

// Wi-Fi Credentials
const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// Firebase Realtime Database URL (without trailing slash)
// Example: "https://your-fyp-project-default-rtdb.firebaseio.com"
const char* FIREBASE_HOST = "https://your-fyp-project-default-rtdb.firebaseio.com";

// Pin Configuration
const int SENSOR_PIN = 34;   // GPIO 34 (Analog ADC1)
const int RELAY_PIN = 23;    // GPIO 23 (Active LOW or HIGH Relay)

// Calibration Constants (Determine using calibration test)
const int AIR_VALUE = 3200;   // Sensor reading in completely dry air (0% moisture)
const int WATER_VALUE = 1400; // Sensor reading in water up to limit line (100% moisture)

// Loop timing
unsigned long lastSendTime = 0;
const unsigned long sendInterval = 2000; // Send reading every 2 seconds

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("\n--- Smart Soil System Initializing ---");

  pinMode(SENSOR_PIN, INPUT);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW); // Relay initially OFF

  // Connect to Wi-Fi
  Serial.print("Connecting to Wi-Fi: ");
  Serial.println(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWi-Fi Connected Successfully!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  unsigned long currentMillis = millis();

  if (currentMillis - lastSendTime >= sendInterval) {
    lastSendTime = currentMillis;

    // Read analog value with multi-sample averaging for stable readings
    int rawTotal = 0;
    const int sampleCount = 10;
    for (int i = 0; i < sampleCount; i++) {
      rawTotal += analogRead(SENSOR_PIN);
      delay(10);
    }
    int rawValue = rawTotal / sampleCount;

    // Convert raw reading to moisture percentage (0% - 100%)
    int moisturePercentage = map(rawValue, AIR_VALUE, WATER_VALUE, 0, 100);
    moisturePercentage = constrain(moisturePercentage, 0, 100);

    // Determine status
    String status = "Normal";
    if (moisturePercentage < 35) {
      status = "Dry";
    } else if (moisturePercentage > 75) {
      status = "Wet";
    }

    // Print to Serial Monitor
    Serial.println("----------------------------------------");
    Serial.printf("Raw ADC Value: %d\n", rawValue);
    Serial.printf("Soil Moisture: %d %%\n", moisturePercentage);
    Serial.printf("Status: %s\n", status.c_str());

    // Send payload to Firebase Realtime Database
    if (WiFi.status() == WL_CONNECTED) {
      sendToFirebase(rawValue, moisturePercentage, status);
      checkPumpControl();
    } else {
      Serial.println("Wi-Fi disconnected! Reconnecting...");
      WiFi.reconnect();
    }
  }
}

void sendToFirebase(int raw, int percentage, String status) {
  HTTPClient http;
  String url = String(FIREBASE_HOST) + "/soil_moisture.json";

  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  // Construct JSON payload
  String jsonPayload = "{";
  jsonPayload += "\"raw\":" + String(raw) + ",";
  jsonPayload += "\"percentage\":" + String(percentage) + ",";
  jsonPayload += "\"status\":\"" + status + "\",";
  jsonPayload += "\"timestamp\":" + String(millis());
  jsonPayload += "}";

  int httpResponseCode = http.PUT(jsonPayload);

  if (httpResponseCode > 0) {
    Serial.printf("Firebase Synced! HTTP Response: %d\n", httpResponseCode);
  } else {
    Serial.printf("HTTP Error on Firebase Sync: %s\n", http.errorToString(httpResponseCode).c_str());
  }

  http.end();
}

void checkPumpControl() {
  HTTPClient http;
  String url = String(FIREBASE_HOST) + "/pump_control.json";

  http.begin(url);
  int httpResponseCode = http.GET();

  if (httpResponseCode == 200) {
    String payload = http.getString();
    if (payload.indexOf("\"pump_on\":true") != -1) {
      digitalWrite(RELAY_PIN, HIGH);
      Serial.println(">> Water Pump Activated by App/Auto");
    } else if (payload.indexOf("\"pump_on\":false") != -1) {
      digitalWrite(RELAY_PIN, LOW);
      Serial.println(">> Water Pump Stopped");
    }
  }

  http.end();
}
