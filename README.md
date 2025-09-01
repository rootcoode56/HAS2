# HAS (Hospital Appointment System)

A comprehensive Flutter application for managing hospital appointments, patient records, and healthcare services.

Get Apps in ### Apps folder

## Features

### 🔐 Authentication
- Email/Password login and registration
- Google Sign-In integration
- Password reset functionality
- Email verification

### 🏥 Healthcare Services
- **Specialist Search**: Find and book appointments with specialists
- **Symptom Checker**: Search symptoms and get potential diagnoses
- **Prescription Management**: Upload and manage prescriptions
- **Hospital Locator**: Find nearby healthcare facilities
- **AI Chat Assistant**: Get health-related queries answered

### 📱 User Experience
- Modern glass morphism UI design
- Custom fonts and theming
- Smooth animations and transitions
- Responsive design
- Offline data caching

## Tech Stack

### Frontend
- **Framework**: Flutter 3.32.5+
- **Language**: Dart 3.0+
- **State Management**: Provider + GetX
- **Architecture**: Clean Architecture with Repository Pattern

### Backend & Services
- **Backend**: Firebase
  - Authentication (Firebase Auth)
  - Database (Cloud Firestore)
  - Real-time Database
  - File Storage (Firebase Storage)
- **Maps**: Google Maps Flutter
- **Location Services**: Geolocator
- **AI Integration**: ChatGPT SDK

### Key Dependencies
- `firebase_core: ^4.0.0` - Firebase core functionality
- `firebase_auth: ^6.0.1` - Authentication services
- `cloud_firestore: ^6.0.0` - NoSQL database
- `google_sign_in: ^7.1.1` - Google authentication
- `provider: ^6.1.2` - State management
- `google_maps_flutter: ^2.9.0` - Maps integration
- `image_picker: ^1.1.2` - Camera and gallery access
- `pdf: ^3.11.1` & `printing: ^5.13.2` - PDF generation
- `geolocator: ^14.0.2` - Location services
- `chat_gpt_sdk: ^3.1.5` - AI chat integration

## Getting Started

### Prerequisites
- Flutter SDK 3.16.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/has.git
   cd has
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── themes/
│   ├── utils/
│   └── services/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── appointments/
│   ├── prescriptions/
│   └── chat/
├── shared/
│   ├── widgets/
│   └── models/
├── assets/
│   ├── images/
│   ├── data/
│   └── fonts/
└── main.dart
```

## Build & Deploy

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```
##IOS is not available at this moment

## Testing

Run tests with:
```bash
flutter test
```

## Code Quality

This project uses comprehensive linting rules and analysis options.

Run analysis:
```bash
flutter analyze
```

Format code:
```bash
dart format .
```

## Performance Optimizations Applied

- ✅ Updated to latest compatible dependencies
- ✅ Organized asset structure for better loading
- ✅ Implemented comprehensive linting rules
- ✅ Added proper error handling
- ✅ Optimized Google Sign-In implementation
- ✅ Created centralized constants for maintainability
- ✅ Fixed deprecated API usage
- ✅ Improved code structure and organization

## License

This project is licensed under the NO Lisence.

## Support

For support, create an issue in this repository.

---

**Note**: This is a healthcare application. Please ensure compliance with relevant healthcare regulations in your region before deployment.
