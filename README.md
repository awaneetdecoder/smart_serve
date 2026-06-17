# SmartServe — Flutter Mobile App

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?style=flat-square&logo=dart)
![Provider](https://img.shields.io/badge/Provider-6.0-purple?style=flat-square)
![JWT](https://img.shields.io/badge/JWT-Auth-orange?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

> Flutter frontend for **SmartServe** — a digital queue management system. Students join queues from their phone and see a live wait-time estimate; admins manage the queue in real time. Built to replace physical token systems.

**Backend Repo:** [smartserve-backend](https://github.com/awaneetdecoder/smartserve-backend)

---

## App Flow

```
Splash Screen
     ↓
Role Selection  →  Student  →  Login/Register  →  User Dashboard
                →  Admin    →  Admin Login     →  Admin Dashboard
```

---

## Features

### Student
- Generate a queue token for any department
- See a live wait-time estimate, calculated backend-side from each department's average serving time — not a static number
- Cancel a token anytime
- Auto-login on app restart (JWT persisted on device)

### Admin
- View all active tokens in real time
- Serve next, skip, hold, or mark a token as done

---

## Tech Stack

| Package | Version | Purpose |
|---|---|---|
| Flutter | 3.x | UI framework |
| provider | ^6.0.0 | State management |
| dio | ^5.3.0 | HTTP client |
| shared_preferences | ^2.2.2 | JWT persistence |

---

## Project Structure

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

## Getting Started

### Prerequisites
- [Flutter SDK 3.x](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) (for emulator)
- Backend running — see [smartserve-backend](https://github.com/awaneetdecoder/smartserve-backend)

### Installation

```bash
git clone https://github.com/awaneetdecoder/smart_serve.git
cd smart_serve
flutter pub get
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

> Make sure the backend is running before starting the app.

---

## JWT Authentication Flow

```
LOGIN
  Flutter → POST /api/auth/login
  Backend → returns JWT token
  Flutter → saves token to SharedPreferences
  Flutter → sets "Authorization: Bearer <token>" on all future requests

APP RESTART
  Flutter reads JWT from SharedPreferences
  Restores token to Dio headers automatically
  User stays logged in

LOGOUT
  JWT removed from Dio headers
  SharedPreferences cleared
  Returns to Role Selection screen
```

---

## Architecture

```
Screen → Provider → Service → ApiService (Dio) → Spring Boot Backend
```

- **Screen** — displays UI, reads from Provider
- **Provider** — manages state, calls Service
- **Service** — business logic per domain (auth, queue)
- **ApiService** — singleton Dio client, handles all HTTP + JWT headers

---

## Honest current limitations

- Tested manually on emulator and a physical device during development — not yet used by real students or admins in a live department.
- No automated widget/integration tests yet.
- Not published to Play Store / App Store — run via `flutter run` for now.

---

## Roadmap

- [ ] Push notifications when token is about to be served
- [ ] Automated widget tests
- [ ] Play Store release build

---

## Author

**Awaneet Mishra** — [@awaneetdecoder](https://github.com/awaneetdecoder)

---

## License

MIT License
