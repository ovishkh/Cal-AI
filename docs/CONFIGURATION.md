# Cal AI Configuration Guide

## Overview

This guide explains all configuration options in Cal AI and where to change them.

## Table of Contents

1. [App Configuration](#app-configuration)
2. [Theme Configuration](#theme-configuration)
3. [API Configuration](#api-configuration)
4. [Build Configuration](#build-configuration)

## App Configuration

### Application Constants

**File**: `lib/constants/app_constants.dart`

```dart
class AppConstants {
  // App Information
  static const String appName = 'Cal AI';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com';
  static const String geminiModel = 'gemini-pro';

  // Asset Paths
  static const String assetsPath = 'assets/';
  static const String imagesPath = '${assetsPath}images/';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheExpiry = Duration(hours: 24);

  // Feature Flags
  static const bool enableOfflineMode = false;
  static const bool enableAnalytics = true;

  // API Configuration
  static const int maxRecipesCache = 50;
  static const int maxMealPlansCache = 10;
}
```

### Where to Change

| Setting       | File                               | How to Change                |
| ------------- | ---------------------------------- | ---------------------------- |
| App name      | `lib/constants/app_constants.dart` | Update `appName` constant    |
| App version   | `pubspec.yaml`                     | Update `version: x.y.z+n`    |
| API timeout   | `lib/constants/app_constants.dart` | Update `apiTimeout` duration |
| feature flags | `lib/constants/app_constants.dart` | Toggle boolean flags         |

## Theme Configuration

### App Theme

**File**: `lib/config/app_theme.dart` (or `lib/utils/app_theme.dart`)

```dart
class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFFFF6B35);      // Orange
  static const Color secondaryColor = Color(0xFF004E89);    // Blue
  static const Color accentColor = Color(0xFF1DD1A1);       // Green

  // Background Colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);

  // ThemeData
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    // ... other theme settings
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Color(0xFF121212),
    // ... other theme settings
  );
}
```

### Change Colors

To change the app colors:

1. Open `lib/config/app_theme.dart`
2. Update the color constants:

```dart
// Before
static const Color primaryColor = Color(0xFFFF6B35);

// After (e.g., change to purple)
static const Color primaryColor = Color(0xFF7C3AED);
```

### Color Formats

- **Hex Format**: `#FF6B35` → `Color(0xFFFF6B35)`
- **Named Colors**: `Colors.red`, `Colors.blue`, etc.

### Available Color Tools

- [Material Color Tool](https://material.io/resources/color/)
- [Coolors.co](https://coolors.co/)
- [Color Picker](https://www.google.com/search?q=color+picker)

## API Configuration

### Gemini API Setup

**Files to Configure**:

- `lib/config/api_keys.dart` - API Key
- `lib/services/gemini_api.dart` - API service
- `lib/constants/app_constants.dart` - API constants

### 1. Add Your API Key

Create or edit `lib/config/api_keys.dart`:

```dart
class ApiKeys {
  static const String geminiApiKey = 'YOUR_API_KEY_HERE';

  // Optional: For multiple environments
  static const String geminiApiKeyDev = 'DEV_KEY_HERE';
  static const String geminiApiKeyProd = 'PROD_KEY_HERE';
}
```

### 2. Change API Model

Edit `lib/services/gemini_api.dart`:

```dart
class GeminiApiService {
  static const String baseUrl = 'https://generativelanguage.googleapis.com';
  static const String apiVersion = 'v1beta'; // or 'v1'

  // Change model here
  static const String modelName = 'gemini-pro'; // or 'gemini-pro-vision'
}
```

### 3. Adjust Generation Parameters

Edit `lib/services/gemini_api.dart`:

```dart
Map<String, dynamic> generationConfig = {
  'temperature': 0.7,           // 0.0 = deterministic, 2.0 = creative
  'topK': 40,                   // Number of token options
  'topP': 0.95,                 // Nucleus sampling
  'maxOutputTokens': 2048,      // Max response length
};
```

**Parameter Guide**:

- **temperature**: Lower for consistent results, higher for creativity
- **maxOutputTokens**: Increase for longer responses, decrease to save API calls

## Build Configuration

### Android Configuration

**File**: `android/app/build.gradle.kts`

```kotlin
// Update app namespace and ID
android {
    namespace = "com.calai"  // Change here

    compileSdk = 34  // Update if needed
}

defaultConfig {
    applicationId = "com.calai"  // Change here
    minSdk = 21                     // Minimum supported Android version
    targetSdk = 34                  // Target Android version
    versionCode = 1                 // Increment for releases
    versionName = "1.0.0"           // Update version
}
```

### iOS Configuration

**File**: `ios/Podfile`

Update pod specifications as needed:

```ruby
# Change iOS deployment target
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    # Set iOS deployment target
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'FLUTTER_ROOT=\$(SRCROOT)/Flutter',
      ]
    end
  end
end
```

### Flutter Configuration

**File**: `pubspec.yaml`

```yaml
# Update app name
name: cal_ai

# Update description
description: "Cal AI - A generative AI recipe & meal planner app."

# Update version
version: 1.0.0+1

# Set Flutter SDK version
environment:
  sdk: ^3.7.2
```

## Environment-Specific Configuration

### Development vs Production

Create separate configuration files:

**File**: `lib/constants/environment_config.dart`

```dart
enum Environment { dev, prod }

class EnvironmentConfig {
  static const Environment currentEnv = Environment.dev;

  static String get apiBaseUrl {
    switch (currentEnv) {
      case Environment.dev:
        return 'https://dev.api.calai.com';
      case Environment.prod:
        return 'https://api.calai.com';
    }
  }

  static String get apiKey {
    switch (currentEnv) {
      case Environment.dev:
        return ApiKeys.geminiApiKeyDev;
      case Environment.prod:
        return ApiKeys.geminiApiKeyProd;
    }
  }
}
```

### Usage

```dart
// In your API service
const String apiKey = EnvironmentConfig.apiKey;
```

## Feature Flags

Enable/disable features without rebuilding:

**File**: `lib/constants/app_constants.dart`

```dart
class FeatureFlags {
  // Beta Features
  static const bool enableVoiceInput = true;
  static const bool enableImageGeneration = false;
  static const bool enablePdfExport = true;

  // Performance
  static const bool enableCache = true;
  static const bool enableAnalytics = true;
}
```

### Conditional Implementation

```dart
import 'package:cal_ai/constants/app_constants.dart';

if (FeatureFlags.enableVoiceInput) {
  VoiceInputWidget();
}
```

## Performance Configuration

### Cache Settings

Edit `lib/constants/app_constants.dart`:

```dart
class CacheConfig {
  static const Duration recipesCacheDuration = Duration(hours: 24);
  static const Duration mealPlansCacheDuration = Duration(days: 7);
  static const int maxRecipesInCache = 50;
  static const int maxMealPlansInCache = 10;
}
```

### API Timeout

```dart
static const Duration apiTimeout = Duration(seconds: 30);
```

## Logging & Debugging

### Enable Debug Logging

**File**: `lib/main.dart`

```dart
void main() {
  // Enable debug logging
  if (kDebugMode) {
    print('Running in Debug Mode');
  }

  runApp(const Cal AIApp());
}
```

### Debug Service Class

Create `lib/services/debug_service.dart`:

```dart
class DebugService {
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[Cal AI] $message');
    }
  }

  static void logError(String error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[ERROR] $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
```

## Common Configuration Changes

### Change App Name

1. Update `lib/constants/app_constants.dart`: `appName`
2. Update `pubspec.yaml`: `name: new_app_name`
3. Update Android: `android/app/build.gradle.kts`
4. Update iOS: `ios/Runner/Info.plist`

### Change Primary Color

1. Update `lib/config/app_theme.dart`: `primaryColor`
2. Rebuild the app

### Change API Endpoint

1. Update `lib/constants/app_constants.dart`: `geminiBaseUrl`
2. Update `lib/services/gemini_api.dart` if needed

### Enable New Feature

1. Update `lib/constants/app_constants.dart`: Feature flag
2. Rebuild the app

## Troubleshooting Configuration

| Issue                  | Solution                                              |
| ---------------------- | ----------------------------------------------------- |
| App crashes on startup | Check `lib/main.dart` and constants for null values   |
| Colors not updating    | Clear build cache: `flutter clean && flutter pub get` |
| API not connecting     | Verify API key and base URL in configuration          |
| Theme not applying     | Ensure `MaterialApp` uses the theme from `AppTheme`   |

## Related Documentation

- [DEPENDENCIES.md](DEPENDENCIES.md): Package configuration
- [API_DOCUMENTATION.md](API_DOCUMENTATION.md): API setup
- [GETTING_STARTED.md](GETTING_STARTED.md): Initial setup
