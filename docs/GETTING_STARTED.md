# Getting Started with FoodLens

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.7.2 or higher
- **Dart SDK**: Included with Flutter
- **Git**: For version control
- **Android Studio** or **Xcode**: For building and running on Android/iOS
- **Python**: For running the app (optional, for some tools)

### Install Flutter

1. Download Flutter from [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. Extract the Flutter archive to a desired location
3. Add Flutter to your PATH:
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```
4. Verify installation:
   ```bash
   flutter doctor
   ```

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/ovishkh/FoodLens.git
cd FoodLens
```

### 2. Install Dependencies

```bash
flutter pub get
```

This command reads the `pubspec.yaml` file and installs all required packages.

### 3. Get the Gemini API Key

FoodLens uses the Google Gemini API for AI-powered recipe generation. You need to:

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy your API key
4. Create a file at `lib/config/api_keys.dart` (create if not exists)
5. Add your API key:

```dart
class ApiKeys {
  static const String geminiApiKey = 'YOUR_API_KEY_HERE';
}
```

> **⚠️ Security Warning**: Never commit `api_keys.dart` to version control. It's already in `.gitignore`.

### 4. Run the Application

#### Android

```bash
flutter run
```

#### iOS

```bash
flutter run -d iphone
```

#### Web (Debug)

```bash
flutter run -d chrome
```

### 5. Build for Release

#### Android APK

```bash
flutter build apk --release
```

#### Android App Bundle

```bash
flutter build appbundle --release
```

#### iOS

```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart              # Entry point
├── config/                # Configuration files
├── constants/             # App constants
├── models/                # Data models
├── screens/               # UI screens
├── services/              # Services (API calls, etc.)
├── widgets/               # Reusable widgets
├── utils/                 # Utility functions
└── providers/             # State management (Provider)
```

## Troubleshooting

### Issue: Flutter doctor shows errors

**Solution**: Follow the instructions from `flutter doctor` output to install missing components.

### Issue: Build fails due to missing dependencies

**Solution**:

```bash
flutter clean
flutter pub get
flutter run
```

### Issue: API key not working

**Solution**:

1. Verify your API key is valid
2. Check that the API is enabled in Google Cloud Console
3. Ensure the key is correctly placed in `lib/config/api_keys.dart`

## Next Steps

- Read [PROJECT_ARCHITECTURE.md](PROJECT_ARCHITECTURE.md) to understand the app structure
- Check [DEPENDENCIES.md](DEPENDENCIES.md) for detailed package information
- See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for API details
- Review [CONFIGURATION.md](CONFIGURATION.md) for customization options

## Support

For issues or questions, please create an issue on GitHub or refer to the documentation files in this directory.
