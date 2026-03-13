# FoodLens Project Architecture

## Overview

FoodLens is built using a clean, professional architecture that follows Flutter best practices. The app is organized into layers to promote maintainability, scalability, and testability.

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
├── services/                    # Business logic & API calls
│   └── gemini_api.dart         # Gemini API service
├── widgets/                     # Reusable UI components
│   ├── nutrition_card.dart
│   ├── nutrition_chart.dart
│   └── recipe_card.dart
├── utils/                       # Utility functions
│   ├── app_theme.dart
│   └── helpers.dart
└── providers/                   # State Management (Provider)
    ├── recipe_provider.dart
    └── meal_plan_provider.dart
```

## Architecture Layers

### 1. **Presentation Layer** (Screens & Widgets)

- **Location**: `lib/screens/`, `lib/widgets/`
- **Responsibility**: UI rendering and user interaction
- **Key Classes**: Stateful/Stateless widgets, screens
- **Example**: `HomeScreen`, `RecipeCard`

### 2. **Business Logic Layer** (Providers & Services)

- **Location**: `lib/providers/`, `lib/services/`
- **Responsibility**: State management and business logic
- **Key Classes**: ChangeNotifier providers, API services
- **Example**: `RecipeProvider`, `GeminiApiService`

### 3. **Data Layer** (Models & Services)

- **Location**: `lib/models/`, `lib/services/`
- **Responsibility**: Data models and API interactions
- **Key Classes**: Data classes, API clients
- **Example**: `Recipe`, `MealPlan`, `GeminiApiService`

### 4. **Configuration & Constants**

- **Location**: `lib/config/`, `lib/constants/`
- **Responsibility**: App configuration and app-wide constants
- **Key Files**: Theme settings, API endpoints, constants

## State Management

FoodLens uses **Provider** package for state management:

```dart
// Example: RecipeProvider
class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  Future<void> generateRecipe(String ingredients) async {
    // Call API
    // Update _recipes
    notifyListeners();
  }
}
```

### Usage in Screens

```dart
@override
Widget build(BuildContext context) {
  return Consumer<RecipeProvider>(
    builder: (context, recipeProvider, child) {
      return ListView(
        children: recipeProvider.recipes
            .map((recipe) => RecipeCard(recipe: recipe))
            .toList(),
      );
    },
  );
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
│ Provider/Event  │ (Handle state)
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

1. **Provider Pattern**: For state management
2. **Singleton Pattern**: For API service and local storage
3. **Factory Pattern**: For creating providers
4. **Observer Pattern**: Through Provider's ChangeNotifier
5. **Strategy Pattern**: For different recipe generation modes (text, voice, image)

## Best Practices

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **DRY (Don't Repeat Yourself)**: Common widgets and utilities are reused
3. **SOLID Principles**: Single responsibility, open/closed, etc.
4. **Error Handling**: Try-catch blocks and user-friendly error messages
5. **Code Organization**: Clear folder structure and naming conventions
6. **Documentation**: Code comments for complex logic

## Future Improvements

- Implement cloud database (Firebase Firestore)
- Add offline capabilities
- Implement caching strategies
- Add more sophisticated error handling
- Add unit and widget tests
- Implement dependency injection
