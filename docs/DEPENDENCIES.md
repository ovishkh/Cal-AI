# Cal AI Dependencies

## Overview

This document lists all the dependencies used in the Cal AI project, their purposes, and versions.

## Core Dependencies

### Flutter

```yaml
flutter:
  sdk: flutter
```

- **Purpose**: The Flutter framework itself for building the UI
- **Version**: SDK ^3.7.2
- **Documentation**: [https://flutter.dev/docs](https://flutter.dev/docs)

### Cupertino Icons

```yaml
cupertino_icons: ^1.0.8
```

- **Purpose**: Provides iOS-style icons for the app
- **Use**: Icon widgets in UI, especially for iOS platforms
- **Documentation**: [https://pub.dev/packages/cupertino_icons](https://pub.dev/packages/cupertino_icons)

## State Management

### Provider

```yaml
provider: ^6.1.1
```

- **Purpose**: Dependency injection and state management
- **Use**: Managing app state across screens (recipes, meal plans, user data)
- **Benefits**:
  - Simple and lightweight
  - Easy to understand and implement
  - Great for medium-sized apps
  - Excellent performance with Consumer widgets
- **Documentation**: [https://pub.dev/packages/provider](https://pub.dev/packages/provider)

**Example Usage in Cal AI**:

```dart
// Creating a provider
class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];

  Future<void> generateRecipe(String ingredients) async {
    final recipe = await _geminiService.generateRecipe(ingredients);
    _recipes.add(recipe);
    notifyListeners();
  }
}

// Using in widget
Consumer<RecipeProvider>(
  builder: (context, recipeProvider, child) {
    return ListView(...);
  },
)
```

## Local Storage

### SharedPreferences

```yaml
shared_preferences: ^2.2.2
```

- **Purpose**: Persistent local storage for key-value data
- **Use**: Storing user preferences, recipe history, app settings
- **Storage Locations**:
  - Android: App-specific directory
  - iOS: Standard NSUserDefaults
- **Size Limit**: ~1-2MB per app
- **Documentation**: [https://pub.dev/packages/shared_preferences](https://pub.dev/packages/shared_preferences)

**Example Usage in Cal AI**:

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('lastRecipe', recipeName);
String? lastRecipe = prefs.getString('lastRecipe');
```

## Media & Image Handling

### Image Picker

```yaml
image_picker: ^1.0.7
```

- **Purpose**: Allow users to capture images or select from gallery
- **Use**: Taking ingredient photos for recipe generation
- **Features**:
  - Camera access
  - Gallery/File picker access
  - Image cropping
  - Video picking (optional)
- **Platform Support**: Android, iOS, Web
- **Documentation**: [https://pub.dev/packages/image_picker](https://pub.dev/packages/image_picker)

**Example Usage in Cal AI**:

```dart
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.camera);

if (image != null) {
  final bytes = await image.readAsBytes();
  // Send to Gemini API for analysis
}
```

## Networking

### HTTP

```yaml
http: ^1.2.0
```

- **Purpose**: Making HTTP requests to external APIs
- **Use**: Communicating with Google Gemini API
- **Features**:
  - Simple GET/POST/PUT/DELETE requests
  - Supports streaming
  - Cookie management
  - Automatic gzip compression
- **Documentation**: [https://pub.dev/packages/http](https://pub.dev/packages/http)

**Example Usage in Cal AI**:

```dart
Future<Recipe> generateRecipe(String ingredients) async {
  final response = await http.post(
    Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'contents': [
        {'parts': [{'text': 'Generate recipe for: $ingredients'}]}
      ]
    }),
  );
  // Handle response
}
```

## Development Dependencies

### Flutter Test

```yaml
flutter_test:
  sdk: flutter
```

- **Purpose**: Widget testing framework for Flutter
- **Use**: Testing UI components and integration

## Optional/Commented Dependencies

### PDF Generation

```yaml
# pdf: ^3.10.4
# printing: ^5.12.0
```

- **Currently commented** to avoid build issues
- **Purpose**: PDF export for meal plans
- **Future**: Can be enabled once other issues are resolved

## Setting Up Dependencies

### 1. Install All Dependencies

```bash
flutter pub get
```

### 2. Upgrade Dependencies

```bash
flutter pub upgrade
```

### 3. Check for Outdated Packages

```bash
flutter pub outdated
```

### 4. Adding a New Dependency

```bash
flutter pub add package_name
```

## Dependency Management Best Practices

1. **Keep dependencies updated**: Regularly check for updates
2. **Minimize dependencies**: Only use necessary packages
3. **Check compatibility**: Ensure packages are compatible with each other
4. **Read documentation**: Understand how each package works
5. **Version constraints**:
   - `^1.2.3`: Compatible with 1.2.3 and up to 2.0.0
   - `1.2.3`: Exact version
   - `>=1.2.3 <2.0.0`: Range specification

## Troubleshooting Dependency Issues

### Issue: Dependency conflict

```bash
flutter pub get
flutter clean
flutter pub get
```

### Issue: Platform-specific dependencies failing

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..  # For iOS
```

### Issue: Finding compatible versions

```bash
flutter pub outdated
flutter pub upgrade
```

## API Keys & Configuration

### Gemini API Key

- **Where to Add**: `lib/config/api_keys.dart`
- **How to Get**: [Google AI Studio](https://makersuite.google.com/app/apikey)
- **Security**: Never commit API keys to version control
- **File**: `.gitignore` already prevents this

## Performance Considerations

1. **Provider**: Minimal performance overhead
2. **SharedPreferences**: Fast for small to medium data
3. **ImagePicker**: Asynchronous operations prevent UI blocking
4. **HTTP**: Connection pooling and keep-alive management

## Future Dependency Recommendations

- **GetX**: If state management becomes complex
- **Firebase**: For backend and authentication
- **Isar**: For local database (better than SharedPreferences for large data)
- **Riverpod**: Modern alternative to Provider
- **Bloc**: For event-driven architecture

## Related Documentation

- [GETTING_STARTED.md](GETTING_STARTED.md): Setup instructions
- [CONFIGURATION.md](CONFIGURATION.md): Configuration details
- [API_DOCUMENTATION.md](API_DOCUMENTATION.md): API integration details
