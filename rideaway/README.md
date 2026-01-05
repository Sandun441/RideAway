# 🛡️ Smart Ride Safety (RideAway)

A Flutter application designed to enhance rider safety through accident detection and emergency response systems. This app monitors ride metrics and automatically alerts emergency contacts in the event of a crash.

## 📱 Features

### ✅ Completed
- **Splash & Onboarding:** Smooth introduction to the app's value proposition.
- **Authentication System:**
  - Secure Email & Password Login.
  - **Google Sign-In** integration.
  - User Registration with Password Confirmation.
  - Input validation and loading states.
- **Cloud Database:**
  - Automatic user profile creation in **Cloud Firestore** upon registration or first Google Login.
- **Navigation:** robust routing system (`AppRoutes`).

### 🚧 In Progress / Roadmap
- [ ] **Accident Detection:** Background service using accelerometer/gyroscope.
- [ ] **Emergency Contacts:** UI to add/edit trusted contacts in Firestore.
- [ ] **Ride History:** Logging trip routes and timestamps.
- [ ] **SMS Alerts:** Automated text messaging with GPS coordinates.
- [ ] **Google Maps Integration:** Live location tracking.

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **Language:** Dart
- **Backend:** Firebase (Core, Auth, Firestore)
- **Packages:**
  - `firebase_auth`: User authentication.
  - `cloud_firestore`: NoSQL database.
  - `google_sign_in`: Google OAuth provider.

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites
- Flutter SDK installed.
- Android Studio / VS Code set up.
- An Android Emulator or Physical Device.

