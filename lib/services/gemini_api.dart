import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/meal_plan.dart';

class GeminiApiService {
  static const String _apiKey =
      'AQ.Ab8RN6LCkdM7GC5hkNflD-yeYeY6l4phHd9mWhuOEGMVuEcGpQ';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // ─── Models ────────────────────────────────────────────────────────────────
  // gemini-2.0-flash  → fast, free, supports text + vision
  // gemini-1.5-flash  → stable fallback, free, supports text + vision
  static const String _textModel = 'gemini-2.0-flash';
  static const String _visionModel = 'gemini-2.0-flash';

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Shared POST helper for the Gemini generateContent endpoint.
  Future<Map<String, dynamic>> _post(
    String model,
    List<Map<String, dynamic>> parts, {
    Map<String, dynamic>? generationConfig,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/models/$model:generateContent?key=$_apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'parts': parts}
        ],
        if (generationConfig != null) 'generationConfig': generationConfig,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json;
    } else {
      throw Exception(
        'Gemini API error ${response.statusCode}: ${response.body}',
      );
    }
  }

  /// Extracts the text output from a Gemini response.
  String _extractText(Map<String, dynamic> json) {
    try {
      return json['candidates'][0]['content']['parts'][0]['text'] as String;
    } catch (_) {
      throw Exception('Could not parse text from Gemini response');
    }
  }

  /// Converts an image file to a base64 inline_data part.
  Future<Map<String, dynamic>> _imagePart(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return {
      'inline_data': {
        'mime_type': 'image/jpeg',
        'data': base64Encode(bytes),
      },
    };
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Analyse a photo to extract a comma-separated list of ingredients.
  Future<String> extractIngredientsFromImage(File imageFile) async {
    try {
      final imgPart = await _imagePart(imageFile);
      final response = await _post(_visionModel, [
        {
          'text':
              'List all the ingredients visible in this image. '
              'Return ONLY a comma-separated list, nothing else.',
        },
        imgPart,
      ]);
      return _extractText(response).trim();
    } catch (e) {
      throw Exception('Failed to extract ingredients: $e');
    }
  }

  /// Generate a full recipe (title, ingredients, steps, nutrition) from text input.
  Future<Recipe> generateRecipe(
    String ingredients,
    String dietFilter,
    String preparationMethod,
    int servings,
  ) async {
    try {
      final diet =
          (dietFilter == 'None' || dietFilter.isEmpty) ? '' : '$dietFilter ';
      final method = (preparationMethod == 'Any Method' ||
              preparationMethod.isEmpty)
          ? 'any cooking method'
          : preparationMethod;

      final response = await _post(
        _textModel,
        [
          {
            'text': '''You are a professional chef. Create a ${diet}recipe using: $ingredients.
Preparation: $method. Servings: $servings.

Return ONLY valid JSON (no markdown, no extra text) with this exact shape:
{
  "title": "Recipe Name",
  "ingredients": ["item 1", "item 2"],
  "steps": ["Step 1 description", "Step 2 description"],
  "nutrition": "Calories: ~X kcal | Protein: Xg | Carbs: Xg | Fat: Xg"
}''',
          },
        ],
        generationConfig: {
          'temperature': 0.7,
          'maxOutputTokens': 1024,
          'responseMimeType': 'application/json',
        },
      );

      String raw = _extractText(response);
      // Strip any accidental markdown fences
      raw = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      // Find the JSON object boundaries
      final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(raw);
      if (match != null) raw = match.group(0)!;

      Map<String, dynamic> data;
      try {
        data = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        return _fallbackRecipe(ingredients, preparationMethod, servings);
      }

      final title =
          data['title']?.toString() ?? 'Recipe for $ingredients';
      final List<String> recipeIngredients = (data['ingredients'] is List)
          ? List<String>.from(
              (data['ingredients'] as List).map((e) => e.toString()))
          : ingredients.split(',').map((e) => e.trim()).toList();
      final List<String> steps = (data['steps'] is List)
          ? List<String>.from(
              (data['steps'] as List).map((e) => e.toString()))
          : ['Prepare all ingredients.', 'Cook using $method.'];
      final String nutrition =
          data['nutrition']?.toString() ?? 'Nutritional info not available';

      final imageUrl = _getThemeImageUrl(title);

      return Recipe(
        title: title,
        ingredients: recipeIngredients,
        steps: steps,
        imageUrl: imageUrl,
        nutrition: nutrition,
        preparationMethod: preparationMethod,
        servings: servings,
      );
    } catch (e) {
      return _fallbackRecipe(ingredients, preparationMethod, servings);
    }
  }

  /// Generate a 7-day meal plan based on preferences and diet.
  Future<MealPlan> generateMealPlan(
    String preferences,
    String dietFilter,
  ) async {
    final diet = (dietFilter == 'None' || dietFilter.isEmpty)
        ? 'balanced'
        : dietFilter;

    try {
      final response = await _post(
        _textModel,
        [
          {
            'text': '''You are a nutrition expert. Generate a 7-day meal plan starting Saturday.
Diet: $diet.
User preferences:
$preferences

Return ONLY valid JSON with this exact shape:
{
  "days": [
    {"name": "Saturday", "breakfast": "...", "lunch": "...", "dinner": "..."},
    {"name": "Sunday",   "breakfast": "...", "lunch": "...", "dinner": "..."},
    {"name": "Monday",   "breakfast": "...", "lunch": "...", "dinner": "..."},
    {"name": "Tuesday",  "breakfast": "...", "lunch": "...", "dinner": "..."},
    {"name": "Wednesday","breakfast": "...", "lunch": "...", "dinner": "..."},
    {"name": "Thursday", "breakfast": "...", "lunch": "...", "dinner": "..."},
    {"name": "Friday",   "breakfast": "...", "lunch": "...", "dinner": "..."}
  ]
}''',
          },
        ],
        generationConfig: {
          'temperature': 0.7,
          'maxOutputTokens': 1500,
          'responseMimeType': 'application/json',
        },
      );

      String raw = _extractText(response);
      raw = raw.replaceAll(RegExp(r'```json|```'), '').trim();

      final Map<String, dynamic> data = jsonDecode(raw);
      if (data['days'] is! List) {
        throw Exception('"days" field missing or not an array');
      }

      final days = (data['days'] as List)
          .map(
            (d) => DayPlan(
              name: d['name']?.toString() ?? 'Day',
              breakfast: d['breakfast']?.toString() ?? 'Not specified',
              lunch: d['lunch']?.toString() ?? 'Not specified',
              dinner: d['dinner']?.toString() ?? 'Not specified',
            ),
          )
          .toList();

      return MealPlan(days: days);
    } catch (e) {
      throw Exception('Failed to generate meal plan: $e');
    }
  }

  /// Analyse a food photo and return detailed nutrition data.
  Future<Map<String, dynamic>> analyzeNutritionFromImage(
      File imageFile) async {
    try {
      final imgPart = await _imagePart(imageFile);

      final response = await _post(
        _visionModel,
        [
          {
            'text': '''Analyse the food in this image and return detailed nutritional information.
Return ONLY valid JSON with this exact shape:
{
  "foodName": "name of the dish",
  "calories": 350,
  "macros": {
    "protein": 25,
    "carbs": 40,
    "fat": 12,
    "fiber": 5
  },
  "healthScore": 7,
  "description": "Brief healthy description of this meal.",
  "nutritionTips": ["Tip 1", "Tip 2"]
}
All quantities in grams except calories. Make educated estimates from what you see.''',
          },
          imgPart,
        ],
        generationConfig: {
          'temperature': 0.4,
          'maxOutputTokens': 1024,
          'responseMimeType': 'application/json',
        },
      );

      String raw = _extractText(response);
      raw = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(raw);
      if (match != null) raw = match.group(0)!;

      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        return _fallbackNutrition();
      }
    } catch (e) {
      return _fallbackNutrition();
    }
  }

  // ─── Fallbacks ─────────────────────────────────────────────────────────────

  Future<Recipe> _fallbackRecipe(
    String ingredients,
    String preparationMethod,
    int servings,
  ) async {
    final title =
        'Recipe with ${ingredients.split(',').take(3).join(', ')}';
    return Recipe(
      title: title,
      ingredients: ingredients.split(',').map((e) => e.trim()).toList(),
      steps: [
        'Prepare all ingredients.',
        'Combine in a suitable pan or dish.',
        'Cook using $preparationMethod.',
        'Serve in $servings portions and enjoy!',
      ],
      imageUrl: _getThemeImageUrl(title),
      nutrition: 'Nutritional info not available',
      preparationMethod: preparationMethod,
      servings: servings,
    );
  }

  Map<String, dynamic> _fallbackNutrition() => {
        'foodName': 'Unknown Food',
        'calories': 250,
        'macros': {'protein': 15, 'carbs': 30, 'fat': 10, 'fiber': 5},
        'healthScore': 6,
        'description': 'Nutritional analysis could not be completed accurately.',
        'nutritionTips': [
          'Eat a balanced diet with diverse food groups.',
          'Consult a nutritionist for personalised advice.',
        ],
      };

  // ─── Image URL helper ──────────────────────────────────────────────────────

  /// Returns a high-quality themed Unsplash photo URL based on the recipe title.
  /// This is used in place of AI image generation to avoid API quota errors.
  String _getThemeImageUrl(String recipeTitle) {
    final t = recipeTitle.toLowerCase();

    if (t.contains('pasta') || t.contains('spaghetti') || t.contains('noodle'))
      return 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800&auto=format&fit=crop';
    if (t.contains('salad') || t.contains('vegetable') || t.contains('vegan'))
      return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&auto=format&fit=crop';
    if (t.contains('chicken') || t.contains('poultry'))
      return 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=800&auto=format&fit=crop';
    if (t.contains('beef') || t.contains('steak') || t.contains('meat'))
      return 'https://images.unsplash.com/photo-1546241072-48010ad2862c?w=800&auto=format&fit=crop';
    if (t.contains('soup') || t.contains('stew'))
      return 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800&auto=format&fit=crop';
    if (t.contains('dessert') || t.contains('cake') || t.contains('sweet'))
      return 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=800&auto=format&fit=crop';
    if (t.contains('breakfast') || t.contains('egg') || t.contains('pancake'))
      return 'https://images.unsplash.com/photo-1533089860892-a9b969b76ab6?w=800&auto=format&fit=crop';
    if (t.contains('fish') || t.contains('seafood') || t.contains('salmon'))
      return 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=800&auto=format&fit=crop';
    if (t.contains('rice') || t.contains('biryani') || t.contains('pilaf'))
      return 'https://images.unsplash.com/photo-1536304929831-ee1ca9d44906?w=800&auto=format&fit=crop';
    if (t.contains('burger') || t.contains('sandwich') || t.contains('wrap'))
      return 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&auto=format&fit=crop';
    if (t.contains('pizza'))
      return 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&auto=format&fit=crop';
    if (t.contains('curry') || t.contains('dal') || t.contains('masala'))
      return 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=800&auto=format&fit=crop';

    // Default
    return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&auto=format&fit=crop';
  }
}
