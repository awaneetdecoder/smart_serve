# SmartServe — Flutter Mobile App

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?style=flat-square&logo=dart)
![Provider](https://img.shields.io/badge/Provider-6.0-purple?style=flat-square)
![JWT](https://img.shields.io/badge/JWT-Auth-orange?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

> The Flutter mobile frontend for **SmartServe** — a digital queue management system. Students join queues digitally and admins manage them in real time. Replaces physical token systems with a clean mobile experience.

**Backend Repo:** [smartserve-backend](https://github.com/awaneetdecoder/smartserve-backend)

---

## 📱 App Flow

```
Splash Screen
     ↓
Role Selection  →  Student  →  Login/Register  →  User Dashboard
                →  Admin    →  Admin Login     →  Admin Dashboard
```

---

## ✨ Features

### Student
- 🎫 Generate queue token for any department
- ⏱️ View real-time estimated wait time
- ❌ Cancel token anytime
- 🔄 Auto-login on app restart (JWT saved to device)

### Admin
- 📊 View all active tokens in real time
- ▶️ Serve next customer
- ⏭️ Skip token
- ⏸️ Hold token
- ✅ Mark as done

---

## 🛠️ Tech Stack

| Package | Version | Purpose |
|---|---|---|
| Flutter | 3.x | UI framework |
| provider | ^6.0.0 | State management |
| dio | ^5.3.0 | HTTP client |
| shared_preferences | ^2.2.2 | JWT persistence |

---

## 📁 Project Structure

```
lib/
├── app/
│   └── app_routes.dart          # All named routes
├── core/
│   └── constants/
│       └── api_endpoints.dart   # Base URL + all endpoints
├── features/
│   ├── auth/
│   │   ├── auth_provider.dart   # Login/register/auto-login state
│   │   ├── login_screen.dart
│   │   └── role_selection_screen.dart
│   ├── user_queue/
│   │   ├── queue_provider.dart
│   │   ├── user_dashboard_screen.dart
│   │   ├── generate_token_screen.dart
│   │   └── queue_status_screen.dart
│   ├── admin/
│   │   ├── admin_provider.dart
│   │   └── admin_dashboard_screen.dart
│   └── splash/
│       └── splash_screen.dart
├── models/
│   ├── user_model.dart          # Includes jwtToken field
│   └── token_model.dart
├── services/
│   ├── api_service.dart         # Singleton Dio client with JWT headers
│   ├── auth_service.dart
│   └── queue_service.dart
└── main.dart                    # MultiProvider setup
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK 3.x](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) (for emulator)
- Backend running — see [smartserve-backend](https://github.com/awaneetdecoder/smartserve-backend)

### Installation

```bash
# Clone the repo
git clone https://github.com/awaneetdecoder/smartserve-flutter.git
cd smartserve-flutter

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Base URL Configuration

Open `lib/core/constants/api_endpoints.dart`:

```dart
// Android Emulator
static const String baseUrl = 'http://10.0.2.2:8080';

// Physical device (replace with your computer's local IP)
// static const String baseUrl = 'http://192.168.1.X:8080';
```

> **Note:** Make sure the backend is running before starting the app.

---

## 🔐 JWT Authentication Flow

```
LOGIN
  Flutter → POST /api/auth/login
  Backend → returns JWT token
  Flutter → saves token to SharedPreferences
  Flutter → sets "Authorization: Bearer <token>" on all future requests

APP RESTART
  Flutter reads JWT from SharedPreferences
  Restores token to Dio headers automatically
  User stays logged in ✅

LOGOUT
  JWT removed from Dio headers
  SharedPreferences cleared
  Returns to Role Selection screen
```

---

## 🏗️ Architecture

```
Screen → Provider → Service → ApiService (Dio) → Spring Boot Backend
```

Each layer has one job:
- **Screen** — displays UI, reads from Provider
- **Provider** — manages state, calls Service
- **Service** — business logic per domain (auth, queue)
- **ApiService** — singleton Dio client, handles all HTTP + JWT headers

---

## 👨‍💻 Author

**Awaneet Mishra** — [@awaneetdecoder](https://github.com/awaneetdecoder)

---

## 📄 License

MIT License
