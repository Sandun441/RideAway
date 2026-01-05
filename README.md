# 🛡️ Smart Ride Safety (RideAway)

**An AI-powered emergency response application that uses on-device Machine Learning to detect vehicle accidents in real-time.**

RideAway transforms your smartphone into a safety companion. By continuously analyzing sensor data (Accelerometer & Gyroscope) using a custom-trained TensorFlow Lite model, the app can instantly distinguish between normal riding patterns and crash impacts, automatically triggering alerts to your emergency contacts.

## 🧠 The Core Technology (Machine Learning)

At the heart of RideAway is a lightweight **Deep Learning Model** optimized for mobile devices.

* **Data Source:** Captures 3-axis accelerometer and gyroscope data directly from the device hardware.
* **The Model:** A pre-trained Neural Network (deployed via `.tflite`) that classifies movement patterns.
* **Inference:** Runs locally on the device (Edge AI) for zero-latency detection, ensuring alerts work even with poor internet connection.
* **Thresholding:** Filters out false positives (like dropping the phone or sudden braking) to ensure reliability.



## 📱 Key Features

### 🚀 Core Intelligence
- **Real-time Crash Detection:** Continuous background monitoring of vehicle dynamics.
- **Smart Filtering:** AI logic to differentiate between a "Hard Stop" and a "Crash."
- **Automatic SOS:** Sends SMS with precise GPS coordinates immediately after a confirmed accident.

### ✅ Completed Modules
- **Authentication System:**
  - Secure Email/Password & **Google Sign-In**.
  - Cloud Firestore User Profiles.
- **User Interface:**
  - Modern, responsive UI with Onboarding and Safety Dashboard.
- **Navigation:** Robust routing architecture.

### 🚧 Roadmap
- [ ] Integration of the `.tflite` model into the Flutter background isolate.
- [ ] Emergency Contact Management (CRUD).
- [ ] Ride History & Analytics.
- [ ] False Alarm Cancellation (Countdown timer before sending alert).

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Machine Learning:**
  - TensorFlow Lite (Model export)
  - `tflite_flutter` (In-app inference)
- **Backend:** Firebase (Auth, Firestore)
- **State Management:** `setState` (transitioning to Provider/Bloc)

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone [https://github.com/yourusername/smart-ride-safety.git](https://github.com/yourusername/smart-ride-safety.git)
cd smart-ride-safety
