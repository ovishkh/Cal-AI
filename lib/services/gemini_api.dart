import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../models/recipe.dart';
import '../models/meal_plan.dart';

class GeminiApiService {
  static const String _apiKey = 'AIzaSyBi49loxPg7EPtgMgDWMxrHWBs4wHJl7vg';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // Method to extract ingredients from an image
  Future<String> extractIngredientsFromImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(
          '$_baseUrl/models/gemini-2.0-flash:generateContent?key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'List all the ingredients visible in this image. Format as a comma-separated list.',
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('Invalid response structure from Gemini API');
        }
      } else {
        throw Exception(
          'API request failed with status: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to extract ingredients: $e');
    }
  }

  // Method to generate recipe from ingredients
  Future<Recipe> generateRecipe(
    String ingredients,
    String dietFilter,
    String preparationMethod,
    int servings,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/models/gemini-2.0-flash:generateContent?key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''You are a professional chef who creates recipes. Generate a recipe in JSON format with these fields: 
                  "title" (string), 
                  "ingredients" (array of strings), 
                  "steps" (array of strings), 
                  "nutrition" (string with nutrition facts).
                  
                  Create a ${dietFilter != 'None' ? dietFilter : ''} recipe for $ingredients, prepared using ${preparationMethod != 'Any Method' ? preparationMethod : 'any cooking method'}, serving $servings people.
                  Your response must be VALID JSON only. Do not include any explanation, markdown formatting, or text outside the JSON structure.''',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
            'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Raw API response: ${response.body}');

        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          final content =
              jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          print('Raw content from Gemini: $content');

          // More aggressive cleaning - remove any non-JSON content
          String cleanedContent =
              content.replaceAll(RegExp(r'```json|```'), '').trim();

          // Try to find JSON within the text (in case there's additional text)
          final jsonMatch = RegExp(
            r'\{.*\}',
            dotAll: true,
          ).firstMatch(cleanedContent);
          if (jsonMatch != null) {
            cleanedContent = jsonMatch.group(0)!;
          }

          print('Cleaned content for parsing: $cleanedContent');

          Map<String, dynamic> recipeData;
          try {
            recipeData = jsonDecode(cleanedContent);
          } catch (e) {
            print('JSON parsing error: $e');
            // If parsing fails, try to create a fallback recipe
            return _createFallbackRecipe(
              ingredients,
              dietFilter,
              preparationMethod,
              servings,
            );
          }

          // Validate required fields with fallback
          String title = 'Recipe for $ingredients';
          if (recipeData.containsKey('title') && recipeData['title'] != null) {
            title = recipeData['title'].toString();
          }

          List<String> ingredientsList = [];
          if (recipeData.containsKey('ingredients') &&
              recipeData['ingredients'] is List) {
            for (var item in recipeData['ingredients']) {
              ingredientsList.add(item.toString());
            }
          } else {
            // Fallback - use the provided ingredients
            ingredientsList =
                ingredients.split(',').map((e) => e.trim()).toList();
          }

          List<String> stepsList = [];
          if (recipeData.containsKey('steps') && recipeData['steps'] is List) {
            for (var item in recipeData['steps']) {
              stepsList.add(item.toString());
            }
          } else {
            // Fallback step
            stepsList = [
              'Combine all ingredients and cook using $preparationMethod method.',
            ];
          }

          String nutrition = 'Nutritional information not available';
          if (recipeData.containsKey('nutrition') &&
              recipeData['nutrition'] != null) {
            nutrition = recipeData['nutrition'].toString();
          }

          // Generate image for the recipe
          final imageUrl = await generateRecipeImage(title);

          return Recipe(
            title: title,
            ingredients: ingredientsList,
            steps: stepsList,
            imageUrl: imageUrl,
            nutrition: nutrition,
            preparationMethod: preparationMethod,
            servings: servings,
          );
        } else {
          print('Invalid response structure from API');
          return _createFallbackRecipe(
            ingredients,
            dietFilter,
            preparationMethod,
            servings,
          );
        }
      } else {
        print(
          'API request failed with status: ${response.statusCode}, ${response.body}',
        );
        return _createFallbackRecipe(
          ingredients,
          dietFilter,
          preparationMethod,
          servings,
        );
      }
    } catch (e) {
      print('Recipe generation error: $e');
      return _createFallbackRecipe(
        ingredients,
        dietFilter,
        preparationMethod,
        servings,
      );
    }
  }

  // Helper method to create a fallback recipe when API fails
  Future<Recipe> _createFallbackRecipe(
    String ingredients,
    String dietFilter,
    String preparationMethod,
    int servings,
  ) async {
    final title = 'Recipe with ${ingredients.split(',').take(3).join(', ')}';
    final ingredientsList =
        ingredients.split(',').map((e) => e.trim()).toList();

    return Recipe(
      title: title,
      ingredients: ingredientsList,
      steps: [
        'Prepare all ingredients.',
        'Combine ingredients in a suitable container.',
        'Cook using $preparationMethod method.',
        'Portion into $servings servings and enjoy!',
      ],
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2032&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      nutrition: 'Nutritional information not available',
      preparationMethod: preparationMethod,
      servings: servings,
    );
  }

  // Method to generate an image for a recipe using Gemini
  Future<String> generateRecipeImage(String recipeTitle) async {
    try {
      print('Generating image for recipe: $recipeTitle');

      // Format request with an enhanced, detailed prompt for better recipe likeness
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/models/gemini-2.0-flash-exp-image-generation:generateContent?key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Create a photorealistic food image of '$recipeTitle'. The image should show this exact dish from a top-down perspective, with all ingredients visible. Plated on a beautiful dish with restaurant-quality presentation, professional food photography, soft natural lighting, high detail, shallow depth of field, garnished appropriately.",
                },
              ],
            },
          ],
          "generationConfig": {
            "responseModalities": ["TEXT", "IMAGE"],
            "temperature": 1.0,
            "topP": 0.99,
          },
        }),
      );

      print('Image generation response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        print('Received 200 response from image generation API');
        final jsonResponse = jsonDecode(response.body);
        print('Response structure: ${jsonResponse.keys.join(", ")}');

        bool imageFound = false;
        String base64Image = "";

        // Extract image data by inspecting the full response structure
        try {
          if (jsonResponse['candidates'] != null &&
              jsonResponse['candidates'].isNotEmpty) {
            var candidate = jsonResponse['candidates'][0];
            print('Candidate keys: ${candidate.keys.join(", ")}');

            if (candidate['content'] != null) {
              var content = candidate['content'];
              print('Content keys: ${content.keys.join(", ")}');

              if (content['parts'] != null) {
                var parts = content['parts'];
                print('Found ${parts.length} parts');

                for (var part in parts) {
                  print('Part keys: ${part.keys.join(", ")}');

                  if (part.containsKey('inlineData')) {
                    var inlineData = part['inlineData'];
                    print('InlineData keys: ${inlineData.keys.join(", ")}');

                    if (inlineData.containsKey('data')) {
                      base64Image = inlineData['data'];
                      int length = base64Image.length;
                      print('Found base64 image data of length: $length');
                      imageFound = true;
                      return 'data:image/png;base64,$base64Image';
                    }
                  }
                }
              }
            }
          }

          if (!imageFound) {
            print('Could not find image data in response structure');
            String responseText = jsonResponse.toString();
            print(
              'Response preview: ${responseText.substring(0, min(200, responseText.length))}...',
            );
          }
        } catch (e) {
          print('Error parsing response: $e');
        }
      }

      // Since image generation failed, let's fall back to a themed image by category
      print('Image generation failed. Using themed fallback image.');
      return _getFallbackImageUrl(recipeTitle);
    } catch (e) {
      print('Exception during image generation: $e');
      return _getFallbackImageUrl(recipeTitle);
    }
  }

  // Helper to get a fallback image URL based on recipe type
  String _getFallbackImageUrl(String recipeTitle) {
    final lowerTitle = recipeTitle.toLowerCase();

    // Check for some common food categories to return more relevant fallback images
    if (lowerTitle.contains('pasta') ||
        lowerTitle.contains('spaghetti') ||
        lowerTitle.contains('noodle')) {
      return 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=2032&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (lowerTitle.contains('salad') ||
        lowerTitle.contains('vegetable') ||
        lowerTitle.contains('vegan')) {
      return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (lowerTitle.contains('chicken') ||
        lowerTitle.contains('poultry')) {
      return 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?q=80&w=2076&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (lowerTitle.contains('beef') ||
        lowerTitle.contains('steak') ||
        lowerTitle.contains('meat')) {
      return 'https://images.unsplash.com/photo-1546241072-48010ad2862c?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (lowerTitle.contains('soup') || lowerTitle.contains('stew')) {
      return 'https://images.unsplash.com/photo-1547592166-23ac45744acd?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (lowerTitle.contains('dessert') ||
        lowerTitle.contains('cake') ||
        lowerTitle.contains('sweet')) {
      return 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?q=80&w=2187&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (lowerTitle.contains('breakfast') || lowerTitle.contains('egg')) {
      return 'https://images.unsplash.com/photo-1533089860892-a9b969b76ab6?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    }

    // Default fallback
    return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
  }

  Future<MealPlan> generateMealPlan(
    String preferences,
    String dietFilter,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/models/gemini-2.0-flash:generateContent?key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''You are a nutrition expert who creates meal plans. Generate a 7-day meal plan in JSON format with an array called "days" containing objects with these fields: "name" (day of week), "breakfast", "lunch", and "dinner".
                  
                  Create a 7-day meal plan starting from Saturday with these preferences: $preferences. Diet type: ${dietFilter != 'None' ? dietFilter : 'balanced'}.
                  Return ONLY valid JSON with no additional text.''',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
            'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          final content =
              jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          // Sometimes, the model might include ```json and ``` around the JSON. Let's clean that up.
          final cleanedContent =
              content.replaceAll(RegExp(r'```json|```'), '').trim();
          final mealPlanData = jsonDecode(cleanedContent);

          if (!mealPlanData.containsKey('days') ||
              !(mealPlanData['days'] is List)) {
            throw Exception(
              'Invalid meal plan data: "days" field is missing or not an array',
            );
          }

          final List<DayPlan> days = [];

          try {
            days.addAll(
              (mealPlanData['days'] as List)
                  .map(
                    (day) => DayPlan(
                      name: day['name']?.toString() ?? 'Day',
                      breakfast:
                          day['breakfast']?.toString() ?? 'Not specified',
                      lunch: day['lunch']?.toString() ?? 'Not specified',
                      dinner: day['dinner']?.toString() ?? 'Not specified',
                    ),
                  )
                  .toList(),
            );
          } catch (e) {
            throw Exception('Error parsing meal plan data: $e');
          }

          return MealPlan(days: days);
        } else {
          throw Exception('Invalid response structure from API');
        }
      } else {
        throw Exception(
          'API request failed with status: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to generate meal plan: $e');
    }
  }

  // Method to analyze nutrition from a food image
  Future<Map<String, dynamic>> analyzeNutritionFromImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(
          '$_baseUrl/models/gemini-2.0-flash:generateContent?key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''Analyze the food in this image and provide detailed nutritional information.
                  Return your response as JSON with the following structure:
                  {
                    "foodName": "name of the food",
                    "calories": number,
                    "macros": {
                      "protein": number,
                      "carbs": number,
                      "fat": number,
                      "fiber": number
                    },
                    "healthScore": number between 1-10,
                    "description": "brief healthy description",
                    "nutritionTips": ["tip1", "tip2"]
                  }
                  All numbers should be in grams except calories. Make educated estimates based on what you see.''',
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
            'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          final content =
              jsonResponse['candidates'][0]['content']['parts'][0]['text'];

          // Clean up in case there's markdown or text
          String cleanedContent =
              content.replaceAll(RegExp(r'```json|```'), '').trim();

          // Try to find the JSON
          final jsonMatch = RegExp(
            r'\{.*\}',
            dotAll: true,
          ).firstMatch(cleanedContent);
          if (jsonMatch != null) {
            cleanedContent = jsonMatch.group(0)!;
          }

          try {
            final nutritionData = jsonDecode(cleanedContent);
            return nutritionData;
          } catch (e) {
            print('Error parsing nutrition JSON: $e');
            return _createFallbackNutritionData();
          }
        }
      }

      return _createFallbackNutritionData();
    } catch (e) {
      print('Error analyzing nutrition: $e');
      return _createFallbackNutritionData();
    }
  }

  // Create fallback nutrition data when analysis fails
  Map<String, dynamic> _createFallbackNutritionData() {
    return {
      "foodName": "Unknown Food",
      "calories": 250,
      "macros": {"protein": 15, "carbs": 30, "fat": 10, "fiber": 5},
      "healthScore": 6,
      "description": "Nutritional analysis couldn't be completed accurately.",
      "nutritionTips": [
        "Try to eat a balanced diet with diverse food groups",
        "Consider consulting a nutritionist for personalized advice",
      ],
    };
  }
}
