/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'FoodLens';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered Recipe & Meal Planner';

  // API Configuration
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com';
  static const String geminiModel = 'gemini-pro';
  static const String geminiApiVersion = 'v1beta';

  // Asset Paths
  static const String assetsPath = 'assets/';
  static const String imagesPath = '${assetsPath}images/';
  static const String iconsPath = '${assetsPath}icons/';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheExpiry = Duration(hours: 24);

  // Feature Flags
  static const bool enableOfflineMode = false;
  static const bool enableAnalytics = true;
  static const bool enableVoiceInput = true;
  static const bool enableImageAnalysis = true;

  // Cache Configuration
  static const int maxRecipesCache = 50;
  static const int maxMealPlansCache = 10;
  static const int maxNutritionItems = 100;

  // Generation Parameters
  static const double defaultTemperature = 0.7;
  static const int defaultTopK = 40;
  static const double defaultTopP = 0.95;
  static const int defaultMaxTokens = 2048;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 2.0;
}

/// API Constants
class ApiConstants {
  static const String recipesEndpoint = 'recipes';
  static const String mealPlansEndpoint = 'meal-plans';
  static const String nutritionEndpoint = 'nutrition';
  static const String imageAnalysisEndpoint = 'analyze-image';
}

/// String Constants
class StringConstants {
  // App Strings
  static const String appTitle = 'FoodLens';
  static const String appSubtitle = 'AI Recipe & Meal Planner';

  // Feature Names
  static const String recipeGeneration = 'Recipe Generation';
  static const String mealPlanning = 'Meal Planning';
  static const String nutritionAnalysis = 'Nutrition Analysis';
  static const String imageAnalysis = 'Image Analysis';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorApiKey = 'API key is not configured.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorInvalidInput = 'Please enter valid input.';

  // Success Messages
  static const String successRecipeGenerated = 'Recipe generated successfully!';
  static const String successMealPlanGenerated =
      'Meal plan generated successfully!';
  static const String successDataSaved = 'Data saved successfully!';
}

/// Dietary Preferences
class DietaryPreferences {
  static const String none = 'None';
  static const String keto = 'Keto';
  static const String halal = 'Halal';
  static const String highProtein = 'High-Protein';
  static const String nutritious = 'Nutritious';
  static const String vegan = 'Vegan';
  static const String vegetarian = 'Vegetarian';
  static const String glutenFree = 'Gluten-Free';

  static const List<String> all = [
    none,
    keto,
    halal,
    highProtein,
    nutritious,
    vegan,
    vegetarian,
    glutenFree,
  ];
}

/// Duration Constants
class DurationConstants {
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration toastDuration = Duration(seconds: 2);
  static const Duration snackBarDuration = Duration(seconds: 4);
}
