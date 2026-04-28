# Cal AI Project Architecture

## Overview

Cal AI is built using a clean, professional architecture that follows Flutter best practices. The app is organized into layers to promote maintainability, scalability, and testability.

## Directory Structure

```
lib/
├── main.dart                    # Application entry point
├── config/                      # Configuration & setup
│   └── app_theme.dart          # Theme and styling
├── constants/                   # App-wide constants
│   ├── api_constants.dart       # API endpoints and constants
│   └── app_constants.dart       # General app constants
├── models/                      # Data models
│   ├── meal_plan.dart
│   ├── nutrition_info.dart
│   └── recipe.dart
├── screens/                     # UI Screens (Pages)
│   ├── splash.dart
│   ├── login.dart
│   ├── signup.dart
│   ├── home.dart
│   ├── planner.dart
│   ├── calorie_ai.dart
│   ├── profile.dart
│   └── about.dart
├── controllers/          # State Management (GetX)
│   ├── auth_controller.dart
│   ├── app_controller.dart
│   └── navigation_controller.dart
└── services/             # Business logic & API calls
    ├── gemini_api.dart         # Gemini API service
    ├── firebase_auth_service.dart
    └── firestore_service.dart
```

## Architecture Layers

### 1. **Presentation Layer** (Screens & Widgets)

- **Location**: `lib/screens/`, `lib/widgets/`
- **Responsibility**: UI rendering and user interaction
- **Key Classes**: Stateful/Stateless widgets, screens
- **Example**: `HomeScreen`, `RecipeCard`

### 2. **Logic Layer** (Controllers & Services)

- **Location**: `lib/controllers/`, `lib/services/`
- **Responsibility**: Reactive state management and external service interactions
- **Key Classes**: GetxController, Firebase services, API services
- **Example**: `AuthController`, `AppController`, `GeminiApiService`

### 3. **Data Layer** (Models & Services)

- **Location**: `lib/models/`, `lib/services/`
- **Responsibility**: Data models and API interactions
- **Key Classes**: Data classes, API clients
- **Example**: `Recipe`, `MealPlan`, `GeminiApiService`

### 4. **Configuration & Constants**

- **Location**: `lib/config/`, `lib/constants/`
- **Responsibility**: App configuration and app-wide constants
- **Key Files**: Theme settings, API endpoints, constants

Cal AI uses **GetX** for state management, providing a reactive and decoupled architecture:

```dart
// Example: AppController
class AppController extends GetxController {
  final Rxn<Recipe> _selectedRecipe = Rxn<Recipe>();
  Recipe? get selectedRecipe => _selectedRecipe.value;

  void setSelectedRecipe(Recipe recipe) {
    _selectedRecipe.value = recipe;
  }
}
```

### Usage in Screens

```dart
@override
Widget build(BuildContext context) {
  return Obx(() {
    final controller = Get.find<AppController>();
    return RecipeCard(recipe: controller.selectedRecipe);
  });
}
```

## Data Flow

```
┌─────────────┐
│   Screen    │ (User interaction)
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ GetxController  │ (Manage state)
└──────┬──────────┘
       │
       ▼
┌──────────────┐
│   Service    │ (Business logic)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  API/Data    │ (External/Local)
└──────────────┘
```

## Key Screens

### 1. **Splash Screen**

- Initial app loading screen
- Handles app initialization

### 2. **Authentication Screens**

- `LoginScreen`: User login
- `SignupScreen`: New user registration

### 3. **Home Screen**

- Main app dashboard
- Display featured recipes
- Quick access to features

### 4. **Recipe Generation**

- Input ingredients (text, image, or voice)
- Select dietary filters
- Display generated recipes

### 5. **Meal Planner**

- Generate weekly meal plans
- Answer preference questions
- Export meal plan as PDF

### 6. **Calorie AI (Nutrition Analyzer)**

- Analyze nutrition information
- Visualize nutritional content
- Compare recipes nutritionally

### 7. **Profile Screen**

- User profile and statistics
- Previously generated recipes
- User preferences

### 8. **About Screen**

- App information
- Team details
- Technology stack

## Services

### GeminiApiService

- Handles all API calls to Google Gemini
- Recipe generation
- Meal plan creation
- Nutrition analysis
- Image analysis

**Location**: `lib/services/gemini_api.dart`

## Models

### Recipe

```dart
class Recipe {
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final NutritionInfo nutrition;
  final String imageUrl;
}
```

### MealPlan

```dart
class MealPlan {
  final List<Recipe> meals;
  final String dietaryPreference;
  final DateTime weekStartDate;
}
```

### NutritionInfo

```dart
class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
}
```

## Design Patterns Used

1. **GetX Pattern**: For state and route management
2. **Repository Pattern**: Abstracting data sources (Firestore, Gemini)
3. **Singleton Pattern**: For services and controller initialization
4. **Reactive Pattern**: Using `Obx` and `Rx` types for UI updates
5. **Strategy Pattern**: For different recipe generation modes (text, voice, image)

## Best Practices

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **DRY (Don't Repeat Yourself)**: Common widgets and utilities are reused
3. **SOLID Principles**: Single responsibility, open/closed, etc.
4. **Error Handling**: Try-catch blocks and user-friendly error messages
5. **Code Organization**: Clear folder structure and naming conventions
6. **Documentation**: Code comments for complex logic

## Future Improvements

- Add offline capabilities with local caching
- Implement background sync for recipes
- Add comprehensive unit and widget tests
- Enhance security rules in Firestore
