# Cal AI — Codebase Map

> A complete breakdown of every page, its source file, and all the code that powers it.

---

## App Entry Point

| File | Role |
|------|------|
| `lib/main.dart` | App bootstrap, routing, `MaterialApp`, `MultiProvider`, bottom nav shell (`MainNavigationScreen`), and three global state providers: `AppState`, `TabNavigationState`, `AuthState` |

**Routes registered in `main.dart`**

| Route | Screen | Nav Index |
|-------|--------|-----------|
| `/login` | `LoginScreen` | — |
| `/signup` | `SignupScreen` | — |
| `/home` | `MainNavigationScreen(index: 0)` → `HomeScreen` | 0 |
| `/planner` | `MainNavigationScreen(index: 1)` → `PlannerScreen` | 1 |
| `/calorie_ai` | `MainNavigationScreen(index: 2)` → `CalorieAIScreen` | 2 |
| `/profile` | `MainNavigationScreen(index: 3)` → `ProfileScreen` | 3 |
| `/about` | `AboutScreen` | — |

---

## Page 1 — Recipe (Home)

> **Tab index 0 · Icon: `restaurant_menu`**

### Primary Screen
| File | Description |
|------|-------------|
| `lib/screens/home.dart` | `HomeScreen` — the full Recipe generation page |

### What the code does
- **Input mode toggle** — switches between `Image` mode (camera/gallery) and `Text` mode (free-text field).
- **Image → Ingredients pipeline** — `_pickImage()` captures a photo; `_processImageToExtractIngredients()` sends it to Gemini Vision and auto-populates the text field with detected ingredients.
- **Recipe filters** — dropdown for `Dietary Filter` (None / Vegan / Nut-free / Vegetarian / Keto / Gluten-free / Dairy-free), `Preparation Method` (Any / Steamed / Baked / Slow Cooked / Grilled / Stir Fried / Fried / Raw), and `Servings` count (1–12).
- **Recipe generation** — `_generateRecipe()` calls `GeminiApiService.generateRecipe()`, then `generateRecipeImage()` to produce an AI food photo.
- **Recent recipes** — saved to `SharedPreferences` (max 5), displayed below the generator, and synced with the Profile page.
- **Cross-tab navigation** — listens to `AppState.selectedRecipe` so tapping a recipe on the Profile tab jumps back here and displays it.

### Supporting files used by this page
| File | Purpose |
|------|---------|
| `lib/widgets/recipe_card.dart` | `RecipeCard` widget — renders the generated recipe (image, title, ingredients, steps, nutrition) |
| `lib/models/recipe.dart` | `Recipe` data model with `toJson` / `fromJson` for local storage |
| `lib/services/gemini_api.dart` | `extractIngredientsFromImage()`, `generateRecipe()`, `generateRecipeImage()` |
| `lib/utils/app_theme.dart` | `AppTheme` colors, text styles, button styles |
| `lib/main.dart` | `AppState` (selected recipe state), `TabNavigationState` |

---

## Page 2 — Planner

> **Tab index 1 · Icon: `calendar_month`**

### Primary Screen
| File | Description |
|------|-------------|
| `lib/screens/planner.dart` | `PlannerScreen` — AI-powered 7-day meal planner |

### What the code does
- **Dietary filter dropdown** — same diet options as the Recipe page.
- **10-question preferences quiz** — rendered as `ChoiceChip` widgets covering skill level, prep time, allergies, goal (weight loss / muscle / maintenance / energy), servings, seasonal ingredients, meal prep count, budget, cuisine preference, and snack inclusion.
- **Meal plan generation** — `_generateMealPlan()` assembles quiz answers into a prompt string and calls `GeminiApiService.generateMealPlan()`.
- **7-day output** — displays Breakfast / Lunch / Dinner for each day (Saturday → Friday) inside `Card` widgets.
- **PDF export** — `_exportToPdf()` builds an A4 PDF via the `pdf` package (preferences summary + all 7 days), saves it to the temp directory, and opens it with `open_file`.

### Supporting files used by this page
| File | Purpose |
|------|---------|
| `lib/models/meal_plan.dart` | `MealPlan` and `DayPlan` data models |
| `lib/services/gemini_api.dart` | `generateMealPlan()` — calls `gemini-2.0-flash` with a JSON-mode config |

---

## Page 3 — CalorieAI

> **Tab index 2 · Icon: `monitor_weight`**

### Primary Screen
| File | Description |
|------|-------------|
| `lib/screens/calorie_ai.dart` | `CalorieAIScreen` — instant AI nutrition analysis from a food photo |

### What the code does
- **Image capture** — `_pickImage()` opens camera or gallery; on success, immediately triggers `_analyzeImage()`.
- **AI nutrition analysis** — sends the base64-encoded image to `GeminiApiService.analyzeNutritionFromImage()` which calls the Gemini Vision API and returns structured JSON.
- **Animated results display** — `NutritionChart` widget slides in with a `CurvedAnimation` showing calories, macros (protein / carbs / fat / fiber), a health score, a description, and nutrition tips.
- **Error handling** — styled error card with icon; fallback data returned if the API call fails.

### Supporting files used by this page
| File | Purpose |
|------|---------|
| `lib/widgets/nutrition_chart.dart` | `NutritionChart` widget — renders macros, calorie ring, health score, and tips |
| `lib/widgets/nutrition_card.dart` | `NutritionCard` widget — individual nutrition stat tile used inside `NutritionChart` |
| `lib/models/nutrition_info.dart` | `NutritionInfo` model (`foodName`, `calories`, `macros`, `healthScore`, `description`, `nutritionTips`) |
| `lib/services/gemini_api.dart` | `analyzeNutritionFromImage()` |
| `lib/utils/app_theme.dart` | `AppTheme.accentColor` and shared design tokens |

---

## Page 4 — Profile

> **Tab index 3 · Icon: `person`**

### Primary Screen
| File | Description |
|------|-------------|
| `lib/screens/profile.dart` | `ProfileScreen` — user activity summary and saved recipes |

### What the code does
- **Profile card** — gradient banner showing username (`Ovi Shekh`) and total recipe count loaded from `SharedPreferences`.
- **Recent recipes list** — reads up to 5 saved recipes from `SharedPreferences`; each item shows title, ingredient count, and step count.
  - Tapping a recipe sets `AppState.selectedRecipe` and switches to the Recipe tab (index 0) to display it.
- **Logout** — calls `AuthState.logout()` and navigates to `/login`.

### Supporting files used by this page
| File | Purpose |
|------|---------|
| `lib/models/recipe.dart` | `Recipe` model for deserializing stored recipes |
| `lib/utils/app_theme.dart` | Theme colors and text styles |
| `lib/main.dart` | `AppState` (recipe selection), `TabNavigationState` (tab switching), `AuthState` (logout) |

---

## Auth Screens (Pre-login)

| File | Screen | Description |
|------|--------|-------------|
| `lib/screens/login.dart` | `LoginScreen` | Email + password login form; calls `AuthState.login()` on success; link to signup |
| `lib/screens/signup.dart` | `SignupScreen` | Registration form; on success navigates to `/home` |
| `lib/screens/splash.dart` | `SplashScreen` | Brief animated splash before routing to login or home |

---

## Shared Services & Utilities

### `lib/services/gemini_api.dart` — `GeminiApiService`
The single service class used by all AI-powered pages.

| Method | Used By | API Model |
|--------|---------|-----------|
| `extractIngredientsFromImage(File)` | Recipe page | `gemini-2.0-flash` (vision) |
| `generateRecipe(ingredients, diet, method, servings)` | Recipe page | `gemini-2.0-flash` (JSON mode) |
| `generateRecipeImage(title)` | Recipe page | `gemini-2.0-flash-exp-image-generation` |
| `generateMealPlan(preferences, diet)` | Planner page | `gemini-2.0-flash` (JSON mode) |
| `analyzeNutritionFromImage(File)` | CalorieAI page | `gemini-2.0-flash` (vision + JSON mode) |

### `lib/utils/app_theme.dart`
Global design system — colors (`primaryColor`, `accentColor`, `primaryLight`), `ThemeData`, reusable `TextStyle` constants, `ButtonStyle`s, and `InputDecoration` factory.

### `lib/constants/app_constants.dart`
App-wide string/int constants.

### `lib/config/api_keys.dart`
API key configuration (currently also hardcoded in `gemini_api.dart`).

---

## Data Models

| File | Model(s) | Used By |
|------|----------|---------|
| `lib/models/recipe.dart` | `Recipe` | Recipe page, Profile page |
| `lib/models/meal_plan.dart` | `MealPlan`, `DayPlan` | Planner page |
| `lib/models/nutrition_info.dart` | `NutritionInfo`, `MacroInfo` | CalorieAI page |

---

## Widgets

| File | Widget | Used By |
|------|--------|---------|
| `lib/widgets/recipe_card.dart` | `RecipeCard` | Recipe page |
| `lib/widgets/nutrition_chart.dart` | `NutritionChart` | CalorieAI page |
| `lib/widgets/nutrition_card.dart` | `NutritionCard` | CalorieAI page (via `NutritionChart`) |

---

## State Management (Provider)

All providers are registered in `main.dart` via `MultiProvider`.

| Provider | State it holds | Consumed by |
|----------|---------------|-------------|
| `AppState` | `recipeCount`, `selectedRecipe` | Recipe page, Profile page |
| `TabNavigationState` | `currentIndex` | `MainNavigationScreen`, Profile page |
| `AuthState` | `isLoggedIn` | Routing guard, Profile page (logout) |
| `RecipeProvider` (`lib/providers/recipe_provider.dart`) | Provider stub (see README) | — |

---

## File Tree Summary

```
lib/
├── main.dart                        ← App entry, routing, providers, bottom nav
├── config/
│   └── api_keys.dart                ← API key config
├── constants/
│   └── app_constants.dart           ← App-wide constants
├── models/
│   ├── recipe.dart                  ← Recipe model
│   ├── meal_plan.dart               ← MealPlan + DayPlan models
│   └── nutrition_info.dart          ← NutritionInfo model
├── providers/
│   └── recipe_provider.dart         ← Recipe provider stub
├── screens/
│   ├── splash.dart                  ← Splash screen
│   ├── login.dart                   ← Login screen
│   ├── signup.dart                  ← Signup screen
│   ├── home.dart                    ← 🍽️ Recipe page (Tab 0)
│   ├── planner.dart                 ← 📅 Planner page (Tab 1)
│   ├── calorie_ai.dart              ← ⚖️ CalorieAI page (Tab 2)
│   ├── profile.dart                 ← 👤 Profile page (Tab 3)
│   └── about.dart                   ← About screen
├── services/
│   └── gemini_api.dart              ← All Gemini API calls (shared service)
├── utils/
│   └── app_theme.dart               ← Global design system / theme
└── widgets/
    ├── recipe_card.dart             ← Recipe display card
    ├── nutrition_chart.dart         ← Nutrition results chart
    └── nutrition_card.dart          ← Individual nutrition stat tile
```
